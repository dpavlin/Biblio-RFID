#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'RFID::Serial' ) || print "Bail out!
";
}

diag( "Testing RFID::Serial $RFID::Serial::VERSION, Perl $], $^X" );
