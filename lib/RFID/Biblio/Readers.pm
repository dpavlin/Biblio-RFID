package RFID::Biblio::Readers;

use warnings;
use strict;

use lib 'lib';

=head1 NAME

RFID::Biblio::Readers - autodetect supported readers

=head1 FUNCTIONS

=head2 new

  my $rfid = RFID::Biblio::Readers->new( 'optional reader filter' );

=cut

sub new {
	my ( $class, $filter ) = @_;
	my $self = {};
	bless $self, $class;
	$self->{_readers} = [ $self->_available( $filter ) ];
	return $self;
}


=head1 PRIVATE

=head2 _available

Probe each RFID reader supported and returns succefull ones

  my $rfid_readers = RFID::Biblio::Readers->_available( $regex_filter );

=cut

my @readers = ( '3M810', 'CPRM02', 'librfid' );

sub _available {
	my ( $self, $filter ) = @_;

	$filter = '' unless defined $filter;

	warn "# filter: $filter";

	my @rfid;

	foreach my $reader ( @readers ) {
		next if $filter && $reader !~ /$filter/i;
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

	return @rfid;
}

=head1 AUTOLOAD

On any other function calls, we just marshall to all readers

=cut

# we don't want DESTROY to fallback into AUTOLOAD
sub DESTROY {}

our $AUTOLOAD;
sub AUTOLOAD {
	my $self = shift;
	my $command = $AUTOLOAD;
	$command =~ s/.*://;

	my @out;

	foreach my $r ( @{ $self->{_readers} } ) {
		push @out, $r->$command(@_);
	}

	return @out;
}

1
__END__

=head1 SEE ALSO

=head2 RFID reader implementations

L<RFID::Biblio::3M810>

L<RFID::Biblio::CPRM02>

L<RFID::Biblio::librfid>

