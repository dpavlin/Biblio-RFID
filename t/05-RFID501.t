#!/usr/bin/perl

use Test::More tests => 3;
use Data::Dump qw(dump);

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Serial::Decode::RFID501' );
}

ok( my $hash = RFID::Serial::Decode::RFID501->to_hash( "\x04\x11\x00\x00200912310123\x00\x00\x00\x00" ), 'decode_tag' );
diag dump $hash;

ok( my $hash = RFID::Serial::Decode::RFID501->to_hash( "\x04\x11\x00\x011301234567\x00\x00\x00\x00\x00\x00" ), 'decode_tag' );
diag dump $hash;

