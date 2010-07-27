#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);

use lib 'lib';

foreach my $reader ( '3M810', 'CPRM02' ) {
	my $module = "RFID::Serial::$reader";
	eval "use $module";
	die $@ if $@;
	my $rfid = $module->new( device => '/dev/ttyUSB0' );
	my $visible = $rfid->scan;
	foreach my $tag ( keys %$visible ) {
	warn "XXX $tag";
		print "$tag\t", join('', @{ $visible->{$tag} }), $/;
	}
}

