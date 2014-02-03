#!/usr/bin/perl

use warnings;
use strict;

use Data::Dump qw(dump);
use Getopt::Long;
use lib 'lib';
use Biblio::RFID::Reader;
use Biblio::RFID::RFID501;
use Storable;

my $evolis_dir = '/home/dpavlin/klin/Printer-EVOLIS'; # FIXME
use lib '/home/dpavlin/klin/Printer-EVOLIS/lib';
use Printer::EVOLIS::Parallel;

my $loop = 1;
my $reader = '3M';
my $debug = 0;
my $afi   = 0x00; # XXX
my $test  = 0;

my $log_print = 'log.print';
mkdir $log_print unless -d $log_print;

GetOptions(
	'loop!'     => \$loop,
	'reader=s', => \$reader,
	'debug+'    => \$debug,
	'test+'     => \$test,
) || die $!;

die "Usage: $0 print.txt\n" unless @ARGV;

my $programmed;
my $numbers;
foreach my $log_path ( glob( "$log_print/*.txt" ) ) {
	warn "# loading $log_path";
	open( my $in, '<', $log_path ) || die $!;
	while(<$in>) {
		chomp;
		my ( $date, $sid, $nr ) = split(/,/,$_,3);
		$programmed->{ $sid } = $nr;
		$numbers->{ $nr } = $sid;	
	}
}

warn "# ", scalar keys %$numbers, " programmed cards found\n";

my @queue;
my @done;
warn "# reading tab-delimited input: number login\@domain name surname\n";
while(<>) {
	chomp;
	my @a = split(/\t/,$_);
	die "invalid: @a in line $_" if $a[0] !~ m/\d{12}/ && $a[1] !~ m/\@/;
	push @queue, [ @a ] if ! $numbers->{ $a[0] } || $ENV{REPRINT};
}

# sort by card number
@queue = sort { $b->[0] <=> $a->[0] } @queue;

print "# queue ", dump @queue;

my $rfid = Biblio::RFID::Reader->new( $reader );
$Biblio::RFID::debug = $debug;

sub tag {
	my $tag = shift;
	return $tag
		, " AFI: "
		, uc unpack('H2', $rfid->afi($tag))
		, " "
		, dump( $rfid->to_hash( $tag ) )
		, $/
		;
}

sub iso_date {
	my @t = localtime(time);
	return sprintf "%04d-%02d-%02dT%02d:%02d:%02d", $t[5]+1900,$t[4]+1,$t[3],$t[2],$t[1],$t[0];
}

sub print_card;
sub render_card;

my $log_path = "$log_print/" . iso_date . ".txt";
die "$log_path exists" if -e $log_path;

sub write_log {
	my ( $tag, $number ) = @_;
	open(my $log, '>>', $log_path) || die "$log_path: $!";
	my $date = iso_date;
	print $log "$date,$tag,$number\n";
	close($log);
	print "LOG $date $tag $number\n";
}

while ( $rfid->tags ) {
	print "ERROR: remove all tags from output printer tray\n";
	sleep 1;
}

print_card;

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

				while ( 1 ) {
					eval {
						$rfid->write_blocks( $tag => Biblio::RFID::RFID501->from_hash({ content => $number }) );
						$rfid->write_afi( $tag => chr($afi) ) if $afi;
					};
					last unless $!;
					warn "RETRY PROGRAM $tag $number\n";
					sleep 1;
				}

				write_log $tag => $number;
				$programmed->{$tag} = $number;

				render_card; # pre-render next one
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

sub _counters {
	my $p = shift;
	my $counters;
	$counters->{$_} = $p->command("Rco;$_") foreach ( qw/p c a m n l b e f i k s/ );
	return $counters;
}

sub render_card {
	return unless @queue;
	my @data = @{$queue[0]};
	my $nr = $data[0];

	if ( $ENV{REPRINT} ) {
		unlink $_ foreach glob("out/$nr.*");
		warn "REPRINT: $nr";
	}

	if ( ! ( -e "out/$nr.front.pbm" && -e "out/$nr.back.pbm" ) ) {
		print "RENDER @data\n";
		system "$evolis_dir/scripts/inkscape-render.pl", "$evolis_dir/card/ffzg-2011.svg", @data;
	}
}

sub print_card {

	if ( ! @queue ) {
		print "QUEUE EMPTY - printing finished\n";
		print "$log_path ", -s $log_path, " bytes created\n";
		exit;
	}

	my @data = @{$queue[0]};
	my $nr = $data[0];
	print "PRINT @data\n";

	my $p = Printer::EVOLIS::Parallel->new( '/dev/usb/lp0' );

	my $before = _counters $p;

	if ( $test ) {

		print "insert card ", $p->command( 'Si' ),$/;
		sleep 1;
		print "eject card ", $p->command( 'Ser' ),$/;

	} else {

		render_card;
		system "$evolis_dir/scripts/evolis-driver.pl out/$nr.front.pbm out/$nr.back.pbm > /dev/usb/lp0";

	}

	my $after = _counters $p;

	if ( $before->{p} = $after->{p} - 2 ) {
		print "OK printerd card $nr\n";
	} else {
		die "ERROR printing card $nr\n";
	}

	warn "# counters ", dump( $before, $after );

}

