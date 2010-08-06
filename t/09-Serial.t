#!/usr/bin/perl

use Test::More tests => 1;

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Biblio::Reader::Serial' );
}

