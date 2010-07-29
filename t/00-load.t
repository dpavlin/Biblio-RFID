#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'RFID::Biblio' ) || print "Bail out!
";
}

diag( "Testing RFID::Biblio $RFID::Biblio::VERSION, Perl $], $^X" );
