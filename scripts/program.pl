#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Readers;
use RFID::Biblio::RFID501;

my $only;

GetOptions(
	'only=s', => \$only,
) || die $!;

my ( $sid, $content ) =  @ARGV;
die "usage: $0 E0_RFID_SID content\n" unless $sid && $content;

my @rfid = RFID::Biblio::Readers->available( $only );

foreach my $rfid ( @rfid ) {
	my $visible = $rfid->scan;
	foreach my $tag ( keys %$visible ) {
		next unless $tag eq $sid;
		warn "PROGRAM $tag with $content\n";
		$rfid->write_blocks( $tag, RFID::Biblio::RFID501->from_hash({ content => $content }) );
	}
}

