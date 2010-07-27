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

use lib 'lib';

do {
	foreach my $reader ( '3M810', 'CPRM02' ) {
		next if $only && $only ne $reader;
		my $module = "RFID::Serial::$reader";
		eval "use $module";
		die $@ if $@;
		my $rfid = $module->new( device => '/dev/ttyUSB0' );
		my $visible = $rfid->scan;
		foreach my $tag ( keys %$visible ) {
		warn "XXX $tag";
			print "$reader\t$tag\t", join('', @{ $visible->{$tag} }), $/;
		}
	}

} while $loop;
