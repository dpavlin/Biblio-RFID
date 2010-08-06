#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Reader;
use RFID::Biblio::RFID501;

my $reader;
my $afi;

GetOptions(
	'reader=s', => \$reader,
	'afi=i',    => \$afi,
) || die $!;

my ( $sid, $content ) =  @ARGV;
die "usage: $0 [--reader regex_filter] [--afi 214] E0_RFID_SID [barcode]\n" unless $sid && ( $content | $afi );

my @rfid = RFID::Biblio::Reader->available( $reader );

foreach my $rfid ( @rfid ) {
	my $visible = $rfid->scan;
	foreach my $tag ( keys %$visible ) {
		next unless $tag eq $sid;
		warn "PROGRAM $tag with $content\n";
		$rfid->write_blocks( $tag => RFID::Biblio::RFID501->from_hash({ content => $content }) );
		$rfid->write_afi(    $tag => chr($afi) ) if $afi;
	}
}

