#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Reader;
use RFID::Biblio::RFID501;

my $loop = 0;
my $reader;

GetOptions(
	'loop!'     => \$loop,
	'reader=s', => \$reader,
) || die $!;

my $rfid = RFID::Biblio::Reader->new( $reader );

do {
	my @visible = $rfid->tags;
	foreach my $tag ( @visible ) {
		print $tag
			, " AFI: "
			, uc unpack('H2', $rfid->afi($tag))
			, " "
			, dump( RFID::Biblio::RFID501->to_hash( $rfid->blocks($tag) ) )
			, $/
			;
	}
} while $loop;
