#!/usr/bin/perl -T

use Test::More tests => 8;

BEGIN {
	use lib 'lib';
	use_ok( 'RFID::Biblio' );
	use_ok( 'RFID::Biblio::Reader::API' );
	use_ok( 'RFID::Biblio::Reader::Serial' );
	use_ok( 'RFID::Biblio::Reader::3M810' );
	use_ok( 'RFID::Biblio::Reader::CPRM02' );
	use_ok( 'RFID::Biblio::Reader::librfid' );
	use_ok( 'RFID::Biblio::Reader' );
	use_ok( 'RFID::Biblio::RFID501' );
}

diag( "Testing RFID::Biblio $RFID::Biblio::VERSION, Perl $], $^X" );
