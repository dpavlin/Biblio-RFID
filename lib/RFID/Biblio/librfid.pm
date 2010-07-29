package RFID::Biblio::librfid;

use warnings;
use strict;

use base 'RFID::Biblio';
use RFID::Biblio;

=head1 NAME

RFID::Biblio::librfid - execute librfid-tool

=head2 DESCRIPTION

This is wrapper around C<librfid-tool> from

L<http://openmrtd.org/projects/librfid/>

=cut

sub serial_settings {} # don't open serial

our $tool = '/rest/cvs/librfid/utils/librfid-tool';

sub init {
	warn "# no $tool found\n" if ! -e $tool;
}

sub inventory {

	my @tags; 

	open(my $s, '-|', "$tool --scan") || die $!;
	while(<$s>) {
		chomp;
		warn "## $_\n";
		if ( m/success.+:\s+(.+)/ ) {
			push @tags, $1;
		}
	}

	return @tags;
}


1
