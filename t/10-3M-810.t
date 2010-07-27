#!/usr/bin/perl

use Test::More tests => 3;
use Data::Dump qw(dump);

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Serial::3M810' );
}

ok( my $o = RFID::Serial::3M810->new( device => '/dev/ttyUSB0' ), 'new' );

ok( my @tags = $o->inventory, 'inventory' );
diag dump @tags;

ok( my $blocks = $o->read_blocks( $_ ), "read_blocks $_" ) foreach @tags;

ok( my $afi = $o->read_afi( $_ ), "read_afi $_" ) foreach @tags;

ok( my $visible = $o->scan, 'scan' );
diag dump $visible;

