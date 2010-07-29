#!/usr/bin/perl

use Test::More;
use Data::Dump qw(dump);

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Biblio::CPRM02' );
}

ok( my $o = RFID::Biblio::CPRM02->new( device => '/dev/ttyUSB0' ), 'new' );

ok( my @tags = $o->inventory, 'inventory' );

ok( my $blocks = $o->read_blocks( $_ ), "read_blocks $_" ) foreach @tags;

ok( my $visible = $o->scan, 'scan' );
diag dump $visible;

done_testing;
