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
my $debug = 0;

GetOptions(
	'loop!'     => \$loop,
	'reader=s', => \$reader,
	'debug+'    => \$debug,
) || die $!;

my $rfid = RFID::Biblio::Reader->new( $reader );
$RFID::Biblio::debug = $debug;

sub tag {
	my $tag = shift;
	return $tag
		, " AFI: "
		, uc unpack('H2', $rfid->afi($tag))
		, " "
		, dump( RFID::Biblio::RFID501->to_hash( $rfid->blocks($tag) ) )
		, $/
		;
}

do {
	my @visible = $rfid->tags(
		enter => sub {
			my $tag = shift;
			print "enter $tag ", tag($tag);

		},
		leave => sub {
			my $tag = shift;
			print "leave $tag ", tag($tag);
		},
	);

	warn scalar localtime, " visible: ",join(' ',@visible),"\n";

} while $loop;
