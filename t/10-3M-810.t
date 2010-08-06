#!/usr/bin/perl

use Test::More; # tests => 3;
use Data::Dump qw(dump);

use lib 'lib';

BEGIN {
	use_ok( 'RFID::Biblio::Reader::3M810' );
}

ok( my $o = RFID::Biblio::Reader::3M810->new( device => '/dev/ttyUSB0' ), 'new' );

ok( my @tags = $o->inventory, 'inventory' );
diag dump @tags;

my $old_afi;

foreach my $tag ( @tags ) {

	ok( my $blocks = $o->read_blocks( $tag ), "read_blocks $tag" );

	ok( my $afi = $o->read_afi( $tag ), "read_afi $tag" );

	ok( $o->write_blocks( $tag, $blocks->{$tag} ), "write_blocks $tag" );

	my $new_afi = "\x42";

	ok( $o->write_afi( $tag, $new_afi ), sprintf( "write_afi %s %x", $tag, $new_afi ) );

	cmp_ok( $o->read_afi( $tag ), 'eq', $new_afi, 'AFI check' );

	ok( $o->write_afi( $tag, $afi ), sprintf( "write_afi %s %x", $tag, $afi ) );

}

done_testing();
