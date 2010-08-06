#!/usr/bin/perl -T

use Test::More tests => 7;

BEGIN {
	use lib 'lib';
    use_ok( 'RFID::Biblio' );
    use_ok( 'RFID::Biblio::Reader::API' );
    use_ok( 'RFID::Biblio::Reader::Serial' );
    use_ok( 'RFID::Biblio::Reader::3M810' );
    use_ok( 'RFID::Biblio::Reader::CPRM02' );
    use_ok( 'RFID::Biblio::Reader::librfid' );
    use_ok( 'RFID::Biblio::Reader' );
}

diag( "Testing RFID::Biblio $RFID::Biblio::VERSION, Perl $], $^X" );
