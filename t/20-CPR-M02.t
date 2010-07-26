#!/usr/bin/perl

use Test::More tests => 3;
use Data::Dump qw(dump);

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Serial::CPRM02' );
}

ok( my $o = RFID::Serial::CPRM02->new( device => '/dev/ttyUSB0' ), 'new' );

ok( my @tags = $o->inventory, 'inventory' );

ok( my $blocks = $o->read_blocks( $_ ), "read_blocks $_" ) foreach @tags;

