#!/usr/bin/perl

use Test::More tests => 4;
use Data::Dump qw(dump);

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Biblio::RFID501' );
}

ok( my $hash = RFID::Biblio::RFID501->to_hash( "\x04\x11\x00\x00200912310123\x00\x00\x00\x00" ), 'decode_tag' );
diag dump $hash;

ok( $hash = RFID::Biblio::RFID501->to_hash( "\x04\x11\x00\x011301234567\x00\x00\x00\x00\x00\x00" ), 'decode_tag' );
diag dump $hash;

my $tag = [
	"\4\21\0\0",
	2009,
	"0101",
	"0123",
	"\0\0\0\0",
	"\xFF\xFF\xFF\xFF",
	"\x7F\xFF\xFF\xFF",
	"\0\0\0\0",
];

ok( $hash = RFID::Biblio::RFID501->to_hash( $tag ), 'decode_tag' );
diag dump $hash;

