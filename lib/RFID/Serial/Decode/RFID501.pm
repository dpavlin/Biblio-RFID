package RFID::Serial::Decode::RFID501;

use warnings;
use strict;

=head1 NAME

RFID::501 - RFID Standard for Libraries

=head1 DESCRIPTION

This module tries to decode tag format as specified in document

  RFID 501: RFID Standards for Libraries

However, document is lacking real specification, so tag decoding
was done to be compliant with 3M implementation

=head1 METHODS

=head2 decode_tag

  my $hash = RFID::Serial::Decode::RFID501->to_hash( $bytes );

  my $hash = RFID::Serial::Decode::RFID501->to_hash( [ 'blk1', 'blk2', ... , 'blk7' ] );

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
		u2 => $u2,	# FIXME
		set => ( $set_item & 0xf0 ) >> 4,
		total => ( $set_item & 0x0f ),

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
