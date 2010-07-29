#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;

my $loop = 0;
my $only;

GetOptions(
	'loop!'   => \$loop,
	'only=s', => \$only,
) || die $!;

my @readers = ( '3M810', 'CPRM02' );
my @rfid;

foreach my $reader ( @readers ) {
	next if $only && $only ne $reader;
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

use lib 'lib';

do {
	foreach my $rfid ( @rfid ) {
		my $visible = $rfid->scan;
		foreach my $tag ( keys %$visible ) {
		warn "XXX $tag";
			print ref($rfid),"\t$tag\t", join('', @{ $visible->{$tag} }), $/;
		}
	}

} while $loop;
