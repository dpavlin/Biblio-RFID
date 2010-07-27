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

=cut

sub to_hash {
	my ( $self, $data ) = @_;

	my ( $u1, $set_item, $u2, $type, $content, $br_lib, $custom ) = unpack('C4Z16Nl>',$data);
	my $hash = {
		u1 => $u1,	# FIXME
		u2 => $u2,	# FIXME
		set => ( $set_item & 0xf0 ) >> 4,
		total => ( $set_item & 0x0f ),

		type => $type,
		content => $content,

		branch => $br_lib >> 20,
		library => $br_lib & 0x000fffff,

		custom => $custom,
	};

	return $hash;
}

1;
