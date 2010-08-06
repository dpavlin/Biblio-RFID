package RFID::Biblio::Reader::API;

use warnings;
use strict;

=head1 NAME

RFID::Biblio::Reader::API - low-level RFID reader documentation

=cut

=head1 METHODS

=head2 new

Just calls C<init> in reader implementation so this class
can be used as simple stub base class like
L<RFID::Biblio::Reader::librfid> does

=cut

sub new {
	my $class = shift;
	my $self = {@_};
	bless $self, $class;
	$self->init && return $self;
}

1;
