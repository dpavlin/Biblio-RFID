#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use RFID::Biblio::Reader;
use RFID::Biblio::RFID501;
use Storable;

my $evolis_dir = '/home/dpavlin/klin/Printer-EVOLIS'; # FIXME
use lib '/home/dpavlin/klin/Printer-EVOLIS/lib';
use Printer::EVOLIS::Parallel;

my $loop = 1;
my $reader = '3M';
my $debug = 0;
my $afi   = 0x42;
my $test  = 0;

GetOptions(
	'loop!'     => \$loop,
	'reader=s', => \$reader,
	'debug+'    => \$debug,
	'test+'     => \$test,
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

sub print_card;

while ( $rfid->tags ) {
	print "ERROR: remove all tags from output printer tray\n";
	sleep 1;
}

print_card;

my $persistant_path = '/tmp/programmed.storable';
my $programmed;
if ( -e $persistant_path ) {
	$programmed = retrieve($persistant_path);
	warn "# loaded ", scalar keys %$programmed, " programmed cards\n";
}

do {
	my @visible = $rfid->tags(
		enter => sub {
			my $tag = shift;
			print localtime()." enter ", eval { tag($tag) };
			return if $@;

			if ( ! $programmed->{$tag} ) {
				my $card = shift @queue;
				my $number = $card->[0];
				print "PROGRAM $tag $number\n";
				$rfid->write_blocks( $tag => RFID::Biblio::RFID501->from_hash({ content => $number }) );
				$rfid->write_afi( $tag => chr($afi) ) if $afi;

				$programmed->{$tag} = $number;
				store $programmed, $persistant_path;
			}

		},
		leave => sub {
			my $tag = shift;

			print_card if $programmed->{$tag};
		},
	);

	warn localtime()." visible: ",join(' ',@visible),"\n";

	sleep 1;
} while $loop;

sub print_card {

	if ( ! @queue ) {
		print "QUEUE EMPTY - printing finished\n";
		exit;
	}

	my @data = @{$queue[0]};
	print "XXX print_card @data\n";

	if ( $test ) {

		my $p = Printer::EVOLIS::Parallel->new( '/dev/usb/lp0' );
		print "insert card ", $p->command( 'Si' ),$/;
		sleep 1;
		print "eject card ", $p->command( 'Ser' ),$/;

	} else {

		system "$evolis_dir/scripts/inkscape-render.pl", "$evolis_dir/card/ffzg-2010.svg", @data;
		my $nr = $data[0];
		system "$evolis_dir/scripts/evolis-driver.pl out/$nr.front.pbm out/$nr.back.pbm > /dev/usb/lp0";

	}

}

