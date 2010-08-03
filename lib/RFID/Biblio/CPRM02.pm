package RFID::Biblio::CPRM02;

=head1 NAME

RFID::Biblio::CPRM02 - support for CPR-M02 RFID reader

=head1 DESCRIPTION

This module implements serial protocol over usb/serial adapter with CPR-M02
reader as described in document C<H20800-16e-ID-B.pdf>

=cut

use warnings;
use strict;

use base 'RFID::Biblio';
use RFID::Biblio;

use Time::HiRes;
use Data::Dump qw(dump);

my $debug = 1;

sub serial_settings {{
	device    => "/dev/ttyUSB0",
	baudrate  => "38400",
	databits  => "8",
	parity	  => "even",
	stopbits  => "1",
	handshake => "none",
}}

sub cpr_m02_checksum {
	my $data = shift;

	my $preset = 0xffff;
	my $polynom = 0x8408;

	my $crc = $preset;
	foreach my $i ( 0 .. length($data) - 1 ) {
		$crc ^= ord(substr($data,$i,1));
		for my $j ( 0 .. 7 ) {
			if ( $crc & 0x0001 ) {
				$crc = ( $crc >> 1 ) ^ $polynom;
			} else {
				$crc = $crc >> 1;
			}
		}
#		warn sprintf('%d %04x', $i, $crc & 0xffff);
	}

	return pack('v', $crc);
}

sub wait_device {
	Time::HiRes::sleep 0.010;
}

our $port;

sub cpr {
	my ( $hex, $description, $coderef ) = @_;
	my $bytes = hex2bytes($hex);
	my $len = pack( 'c', length( $bytes ) + 3 );
	my $send = $len . $bytes;
	my $checksum = cpr_m02_checksum($send);
	$send .= $checksum;

	warn "##>> ", as_hex( $send ), "\t\t[$description]\n";
	$port->write( $send );

	wait_device;

	my $r_len = $port->read(1);

	my $count = 100;
	while ( ! $r_len ) {
		if ( $count-- == 0 ) {
			warn "no response from device";
			return;
		}
		wait_device;
		$r_len = $port->read(1);
	}

	wait_device;

	my $data_len = ord($r_len) - 1;
	my $data = $port->read( $data_len );
	warn "##<< ", as_hex( $r_len . $data ),"\n";

	wait_device;

	$coderef->( $data ) if $coderef;

}

# FF = COM-ADDR any

sub init {
	my $self = shift;

	$port = $self->port;

cpr( 'FF  52 00',	'Boud Rate Detection' );

cpr( 'FF  65',		'Get Software Version' );

cpr( 'FF  66 00',	'Get Reader Info - General hard and firware' );

cpr( 'FF  69',		'RF Reset' );

	return 1;
}


sub inventory {

	my @tags;

cpr( 'FF  B0  01 00', 'ISO - Inventory', sub {
	my $data = shift;
	if (length($data) < 5 + 2 ) {
		warn "# no tags in range\n";
		return;
	}

	my $data_sets = ord(substr($data,3,1));
	$data = substr($data,4);
	foreach ( 1 .. $data_sets ) {
		my $tr_type = substr($data,0,1);
		die "FIXME only TR-TYPE=3 ISO 15693 supported" unless $tr_type eq "\x03";
		my $dsfid   = substr($data,1,1);
		my $uid     = substr($data,2,8);
		$data = substr($data,10);
		warn "# TAG $_ ",as_hex( $tr_type, $dsfid, $uid ),$/;
		push @tags, hex_tag $uid;
		
	}
});

	warn "# tags ",dump(@tags),$/;
	return @tags;
}


sub read_blocks {
	my $tag = shift;
	$tag = shift if ref $tag;

	my $max_block;

	cpr( "FF  B0 2B  01  $tag", "Get System Information $tag", sub {
		my $data = shift;

		warn "# data ",as_hex($data);

		my $DSFID    = substr($data,5-2,1);
		my $UID      = substr($data,6-2,8);
		my $AFI      = substr($data,14-2,1);
		my $MEM      = substr($data,15-2,1);
		my $SIZE     = substr($data,16-2,1);
		my $IC_REF   = substr($data,17-2,1);

		warn "# split ",as_hex( $DSFID, $UID, $AFI, $MEM, $SIZE, $IC_REF );

		$max_block = ord($SIZE);
	});

	my $tag_blocks;

	my $block = 0;
	while ( $block < $max_block ) {
		cpr( sprintf("FF  B0 23  01  $tag %02x 04", $block), "Read Multiple Blocks $block", sub {
			my $data = shift;

			my $DB_N    = ord substr($data,5-2,1);
			my $DB_SIZE = ord substr($data,6-2,1);

			$data = substr($data,7-2,-2);
#			warn "# DB N: $DB_N SIZE: $DB_SIZE ", as_hex( $data ), " transponder_data: [$transponder_data] ",length($transponder_data),"\n";
			foreach my $n ( 1 .. $DB_N ) {
				my $sec = ord(substr($data,0,1));
				my $db  = substr($data,1,$DB_SIZE);
				warn "## block $n ",dump( $sec, $db ) if $debug;
				$tag_blocks->{$tag}->[$block+$n-1] = reverse split(//,$db);
				$data = substr($data, $DB_SIZE + 1);
			}
		});
		$block += 4;
	}

	warn "# tag_blocks ",dump($tag_blocks),$/;
	return $tag_blocks;
}


1
