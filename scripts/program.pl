#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use Biblio::RFID::Reader;
use Biblio::RFID::RFID501;

my $reader;
my $afi;
my $debug = 0;

GetOptions(
	'reader=s', => \$reader,
	'afi=i',    => \$afi,
	'debug+',   => \$debug,
) || die $!;

my ( $sid, $content ) =  @ARGV;
die "usage: $0 [--reader regex_filter] [--afi 214] E0_RFID_SID [barcode]\n" unless $sid && ( $content | $afi );

my $rfid = Biblio::RFID::Reader->new( $reader );
$Biblio::RFID::debug = $debug;

foreach my $tag ( $rfid->tags ) {
	warn "visible $tag\n";
	next unless $tag eq $sid;
	warn "PROGRAM $tag with $content\n";
	$rfid->write_blocks( $tag => Biblio::RFID::RFID501->from_hash({ content => $content }) );
	$rfid->write_afi(    $tag => chr($afi) ) if $afi;
}

