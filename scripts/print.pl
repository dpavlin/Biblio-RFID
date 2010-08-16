#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Reader;
use RFID::Biblio::RFID501;

use lib '/home/dpavlin/klin/Printer-EVOLIS/lib';
use Printer::EVOLIS::Parallel;

my $loop = 1;
my $reader = '3M';
my $debug = 0;

GetOptions(
	'loop!'     => \$loop,
	'reader=s', => \$reader,
	'debug+'    => \$debug,
) || die $!;

die "Usage: $0 print.txt\n" unless @ARGV;

my @queue;
my @done;
warn "# reading tab-delimited input\n";
while(<>) {
	chomp;
	my @a = split(/\t/,$_);
	push @queue, [ @a ];
}

print "# queue ", dump @queue;

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

my @stack;

sub print_card;

while ( $rfid->tags ) {
	print "ERROR: remove all tags from output printer tray\n";
	sleep 1;
}

print_card;

do {
	my @visible = $rfid->tags(
		enter => sub {
			my $tag = shift;
			print localtime()." enter ", tag($tag);
			push @stack, [ 'enter', $tag ];
			warn dump @stack;

			print_card;
		},
		leave => sub {
			my $tag = shift;
			print localtime()." leave ", tag($tag);
			push @stack, [ 'leave', $tag ];
			warn dump @stack;
		},
	);

	warn localtime()." visible: ",join(' ',@visible),"\n";

	sleep 1;
} while $loop;

sub print_card {

	print "XXX print_card\n";

	my $p = Printer::EVOLIS::Parallel->new( '/dev/usb/lp0' );
	print "insert card ", $p->command( 'Si' );
	print "eject card ", $p->command( 'Ser' );
}

