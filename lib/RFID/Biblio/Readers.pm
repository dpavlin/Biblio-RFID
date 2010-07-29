package RFID::Biblio::Readers;

use warnings;
use strict;

use lib 'lib';

my @readers = ( '3M810', 'CPRM02' );

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

	return @rfid;
}

