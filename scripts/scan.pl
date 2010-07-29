#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Readers;

my $loop = 0;
my $only;

GetOptions(
	'loop!'   => \$loop,
	'only=s', => \$only,
) || die $!;

my @rfid = RFID::Biblio::Readers->available( $only );

do {
	foreach my $rfid ( @rfid ) {
		my $visible = $rfid->scan;
		foreach my $tag ( keys %$visible ) {
		warn "XXX $tag";
			print ref($rfid),"\t$tag\t", join('', @{ $visible->{$tag} }), $/;
		}
	}

} while $loop;
