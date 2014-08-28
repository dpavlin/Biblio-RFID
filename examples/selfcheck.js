
// configure timeouts
var end_timeout   = 3000; // ms from end page to start page
var error_timeout = 5000; // ms from error page to start page
var tag_rescan    = 200;  // ms rescan tags every 0.2s

// mock console
if(!window.console) {
	window.console = new function() {
		this.info = function(str) {};
		this.error = function(str) {};
		this.debug = function(str) {};
	};
}

var state;
var scan_timeout;
var pending_jsonp = 0;

function change_page(new_state) {
	if ( state != new_state ) {

		if ( new_state == 'checkin' ) {
			new_state = 'circulation'; // page has different name
			$('.checkout').hide();
			$('.checkin').show();
			circulation_type = 'checkin';
			borrower_cardnumber = 0; // fake
		} else if ( new_state == 'checkout' ) {
			new_state = 'circulation'; // page has different name
			$('.checkout').show();
			$('.checkin').hide();
			circulation_type = 'checkout';
		}

		state = new_state;

		$('.page').each( function(i,el) {
			if ( el.id != new_state ) {
				$(el).hide();
			} else {
				$(el).show();
			}
		});
		console.info('change_page', state);

		if ( state == 'start' ) {
			circulation_type = 'checkout';
			book_barcodes = {};
			$('ul#books').html(''); // clear book list
			$('#books_count').html( 0 );
			scan_tags();
		}

		if ( state == 'end' ) {
			window.setTimeout(function(){
				//change_page('start');
				location.reload(); // force js VM to GC?
			},end_timeout);
		}

		if ( state == 'error' ) {
			window.setTimeout(function(){
				change_page('start');
			},error_timeout);
		}
	}
}

function got_visible_tags(data,textStatus) {
	var html = 'No tags in range';
	if ( data.tags ) {
		html = '<ul class="tags">';
		$.each(data.tags, function(i,tag) {
			console.debug( i, tag );
			html += '<li><tt class="' + tag.security + '">' + tag.sid;
			var content = tag.content || tag.borrower.cardnumber;

			if ( content ) {
				var link;
				if ( content.length = 10 && content.substr(0,3) == 130 ) { // book
					link = 'catalogue/search.pl?q=';
				} else if ( content.length == 12 && content.substr(0,2) == 20 ) {
					link = 'members/member.pl?member=';
				} else {
					html += '<b>UNKNOWN TAG</b> '+content;
				}

				if ( link ) {
					html += ' <a href="http://koha.example.com:8080/cgi-bin/koha/'
						+ link + content
						+ '" title="lookup in Koha" target="koha-lookup">' + content + '</a>';
						+ '</tt>';
				}

				console.debug( 'calling', state, content );
				window[state]( content, tag.sid ); // call function with barcode

			}
		});
		html += '</ul>';

	}

	var arrows = Array( 8592, 8598, 8593, 8599, 8594, 8600, 8595, 8601 );

	html = '<div class=status>'
		+ textStatus
		+ ' &#' + arrows[ data.time % arrows.length ] + ';'
		+ '</div>'
		+ html
		;
	$('#tags').html( html ); // FIXME leaks memory?

	pending_jsonp--;
};

function scan_tags() {
	if ( pending_jsonp ) {
		console.debug('scan_tags disabled ', pending_jsonp, ' requests waiting');
	} else {
		console.info('scan_tags');
		pending_jsonp++;
		$.getJSON("/scan?callback=?", got_visible_tags);
	}

	scan_timeout = window.setTimeout(function(){
		scan_tags();
	},tag_rescan);	// re-scan every 200ms
}

$(document).ready(function() {
		$('div#tags').click( function() {
			scan_tags();
		});

		change_page('start');
});

function fill_in( where, value ) {
	$('.'+where).each(function(i, el) {
		$(el).html(value);
	});

}

/* Selfcheck state actions */

var borrower_cardnumber;
var circulation_type;
var book_barcodes = {};

function start( cardnumber ) {

	if ( cardnumber.length != 12 || cardnumber.substr(0,2) != "20" ) {
		console.error(cardnumber, ' is not borrower card');
		return;
	}

	borrower_cardnumber = cardnumber; // for circulation

	fill_in( 'borrower_number', cardnumber );

	pending_jsonp++;
	$.getJSON('/sip2/patron_info/'+cardnumber)
	.done( function( data ) {
		console.info('patron', data);
		fill_in( 'borrower_name', data['AE'] );
		fill_in( 'borrower_email', data['BE'] );
		fill_in( 'hold_items',    data['fixed'].substr( 2 + 14 + 3 + 18 + ( 0 * 4 ), 4 ) ) * 1;
		fill_in( 'overdue_items', data['fixed'].substr( 2 + 14 + 3 + 18 + ( 1 * 4 ), 4 ) ) * 1;
		fill_in( 'charged_items', data['fixed'].substr( 2 + 14 + 3 + 18 + ( 2 * 4 ), 4 ) ) * 1;
		fill_in( 'fine_items',    data['fixed'].substr( 2 + 14 + 3 + 18 + ( 3 * 4 ), 4 ) ) * 1;
		pending_jsonp--;
		change_page('borrower_info');
	}).fail( function(data) {
		pending_jsonp--;
		change_page('error');
	});
}

function borrower_info() {
	// nop
}

function circulation( barcode, sid ) {
	if ( barcode
			&& barcode.length == 10
			&& barcode.substr(0,3) == 130
			&& book_barcodes[barcode] != 1
	) { // book, not seen yet
		book_barcodes[ barcode ] = 1;
		pending_jsonp++;
		$.getJSON('/sip2/'+circulation_type+'/'+borrower_cardnumber+'/'+barcode+'/'+sid , function( data ) {
			console.info( circulation_type, data );
			$('ul#books').append('<li>' + ( data['AJ'] || barcode ) + ( data['AF'] ? ' <b>' + data['AF'] + '</b>' : '' ) + '</li>');
			$('#books_count').html( $('ul#books > li').length );
			console.debug( book_barcodes );
			pending_jsonp--;
		}).fail( function() {
			change_page('error');
			pending_jsonp--;
		});
	}
}

function end() {
	// nop
}
