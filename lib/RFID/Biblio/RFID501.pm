package RFID::Biblio::RFID501;

use warnings;
use strict;

=head1 NAME

RFID::Biblio::RFID501 - RFID Standard for Libraries

=head1 DESCRIPTION

This module tries to decode tag format as described in document

  RFID 501: RFID Standards for Libraries

L<http://solutions.3m.com/wps/portal/3M/en_US/3MLibrarySystems/Home/Resources/CaseStudiesAndWhitePapers/RFID501/>

Goal is to be compatibile with existing 3M Alphanumeric tag format
which, as far as I know, isn't specificed anywhere. My documentation about
this format is available at

L<http://saturn.ffzg.hr/rot13/index.cgi?hitchhikers_guide_to_rfid>

=head1 Data model

=head2 3M Alphanumeric tag

 0   04 is 00 tt   i [4 bit] = number of item in set	[1 .. i .. s]
                   s [4 bit] = total items in set
                   tt [8 bit] = item type

 1   dd dd dd dd   dd [16 bytes] = barcode data
 2   dd dd dd dd
 3   dd dd dd dd
 4   dd dd dd dd

 5   bb bl ll ll   b [12 bit] = branch [unsigned]
                   l [20 bit] = library [unsigned]

 6   cc cc cc cc   c [32 bit] = custom signed integer

=head2 3M Manufacturing Blank

 0   55 55 55 55
 1   55 55 55 55
 2   55 55 55 55
 3   55 55 55 55
 4   55 55 55 55
 5   55 55 55 55
 6   00 00 00 00 

=head2 Generic blank

 0   00 00 00 00
 1   00 00 00 00
 2   00 00 00 00

=head1 METHODS

=head2 decode_tag

  my $hash = RFID::Biblio::Decode::RFID501->to_hash( $bytes );

  my $hash = RFID::Biblio::Decode::RFID501->to_hash( [ 'blk1', 'blk2', ... , 'blk7' ] );

=cut

my $item_type = {
	1 => 'Book',
	6 => 'CD/CD ROM',
	2 => 'Magazine',
	13 => 'Book with Audio Tape',
	9 => 'Book with CD/CD ROM',
	0 => 'Other',

	5 => 'Video',
	4 => 'Audio Tape',
	3 => 'Bound Journal',
	8 => 'Book with Diskette',
	7 => 'Diskette',
};

sub to_hash {
	my ( $self, $data ) = @_;

	return unless $data;

	$data = join('', @$data) if ref $data eq 'ARRAY';

	warn "## to_hash $data\n";

	my ( $u1, $set_item, $u2, $type, $content, $br_lib, $custom ) = unpack('C4Z16Nl>',$data);
	my $hash = {
		u1 => $u1,	# FIXME
		set => ( $set_item & 0xf0 ) >> 4,
		total => ( $set_item & 0x0f ),

		u2 => $u2,	# FIXME

		type => $type,
		type_label => $item_type->{$type},
		content => $content,

		branch => $br_lib >> 20,
		library => $br_lib & 0x000fffff,

		custom => $custom,
	};

	return $hash;
}

1;
