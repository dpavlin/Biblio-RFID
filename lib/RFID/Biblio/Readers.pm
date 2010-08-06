package RFID::Biblio::Readers;

=head1 NAME

RFID::Biblio::Readers - autodetect supported readers

=head1 FUNCTIONS

=head2 _available

Probe each RFID reader supported and returns succefull ones

  my $rfid_readers = RFID::Biblio::Readers->_available( $regex_filter );

=head1 SEE ALSO

=head2 RFID reader implementations

L<RFID::Biblio::3M810>

L<RFID::Biblio::CPRM02>

L<RFID::Biblio::librfid>

=head1 SEE ALSO

=head2 RFID reader implementations

L<RFID::Biblio::3M810>

L<RFID::Biblio::CPRM02>

L<RFID::Biblio::librfid>

=cut

use warnings;
use strict;

use lib 'lib';

my @readers = ( '3M810', 'CPRM02', 'librfid' );

sub _available {
	my ( $self, $filter ) = @_;

	$filter = 'all' unless defined $filter;

	return $self->{_available}->{$filter} if defined $self->{_available}->{$filter};

	my @rfid;

	foreach my $reader ( @readers ) {
		next if $reader !~ /$filter/i;
		my $module = "RFID::Biblio::$reader";
		eval "use $module";
		die $@ if $@;
		if ( my $rfid = $module->new( device => '/dev/ttyUSB0' ) ) {
			push @rfid, $rfid;
			warn "# added $module\n";
		} else {
			warn "# ignored $module\n";
		}
	}

	die "no readers found" unless @rfid;

	$self->{_available}->{$filter} = [ @rfid ];
}

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

# we don't want DESTROY to fallback into AUTOLOAD
sub DESTROY {}

our $AUTOLOAD;
sub AUTOLOAD {
	my $self = shift;
	my $command = $AUTOLOAD;
	$command =~ s/.*://;

	foreach my $r ( @{ $self->_available } ) {
		$r->$command(@_);
	}
}

1
