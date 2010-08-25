#!/usr/bin/perl -T

use Test::More tests => 7;

BEGIN {
	use lib 'lib';
    use_ok( 'Biblio::RFID' );
    use_ok( 'Biblio::RFID::Reader::API' );
    use_ok( 'Biblio::RFID::Reader::Serial' );
    use_ok( 'Biblio::RFID::Reader::3M810' );
    use_ok( 'Biblio::RFID::Reader::CPRM02' );
    use_ok( 'Biblio::RFID::Reader::librfid' );
    use_ok( 'Biblio::RFID::Reader' );
}

diag( "Testing Biblio::RFID $Biblio::RFID::VERSION, Perl $], $^X" );
