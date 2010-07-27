#!/usr/bin/perl

use warnings;
use strict;

use lib 'lib';

foreach my $reader ( '3M810', 'CPRM02' ) {
	my $module = "RFID::Serial::$reader";
	eval "use $module";
	die $@ if $@;
	my $rfid = $module->new( device => '/dev/ttyUSB0' );
	$rfid->scan;
}

