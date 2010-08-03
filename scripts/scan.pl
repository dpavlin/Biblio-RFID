#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Readers;
use RFID::Biblio::RFID501;

my $loop = 0;
my $reader;

GetOptions(
	'loop!'     => \$loop,
	'reader=s', => \$reader,
) || die $!;

my @rfid = RFID::Biblio::Readers->available( $reader );

do {
	foreach my $rfid ( @rfid ) {
		my $visible = $rfid->scan;
		foreach my $tag ( keys %$visible ) {
			my $afi = $rfid->read_afi( $tag );
			print ref($rfid)
				, " $tag AFI: "
				, uc unpack('H2', $afi)
				, " "
				, dump( RFID::Biblio::RFID501->to_hash( join('', @{ $visible->{$tag} }) ) )
				, $/
				;
		}
	}

} while $loop;
