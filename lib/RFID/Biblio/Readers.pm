package RFID::Biblio::Readers;

=head1 NAME

RFID::Biblio::Readers - autodetect supported readers

=head1 FUNCTIONS

=head2 available

Probe each RFID reader supported and returns succefull ones

  my @rfid = RFID::Biblio::Readers->available( $regex_filter );

=head1 SEE ALSO

=head2 RFID reader implementations

L<RFID::Biblio::3M810>

L<RFID::Biblio::CPRM02>

L<RFID::Biblio::librfid>

=cut

use warnings;
use strict;

use lib 'lib';

my @readers = ( '3M810', 'CPRM02', 'librfid' );

sub available {
	my ( $self, $filter ) = @_;

	my @rfid;

	foreach my $reader ( @readers ) {
		next if $reader !~ /$filter/i;
		my $module = "RFID::Biblio::$reader";
		eval "use $module";
		die $@ if $@;
		if ( my $rfid = $module->new( device => '/dev/ttyUSB0' ) ) {
			push @rfid, $rfid;
			warn "# added $module\n";
		} else {
			warn "# ignored $module\n";
		}
	}

	die "no readers found" unless @rfid;

	return @rfid;
}

