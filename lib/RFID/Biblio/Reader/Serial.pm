package RFID::Biblio::Reader::Serial;

use warnings;
use strict;

use Device::SerialPort qw(:STAT);
use Data::Dump qw(dump);

=head1 NAME

RFID::Biblio::Reader::Serial - base class for serial RFID readers

=head1 METHODS

=head2 new

Open serial port (if needed) and init reader

=cut

sub new {
	my $class = shift;
	my $self = {@_};
	bless $self, $class;

	$self->port;

	$self->init && return $self;
}


=head2 port

  my $serial_obj = $self->port;

=cut

sub port {
	my $self = shift;

	return $self->{port} if defined $self->{port};

	my $settings = $self->serial_settings;
	my $device   = $settings->{device} ||= $ENV{RFID_DEVICE};
	warn "# settings ",dump $settings;

	if ( ! $device ) {
		warn "# no device, serial port not opened\n";
		return;
	}

	$self->{port} = Device::SerialPort->new( $settings->{device} )
	|| die "can't open serial port: $!\n";

	$self->{port}->$_( $settings->{$_} )
	foreach ( qw/handshake baudrate databits parity stopbits/ );

}

1
__END__

=head1 SEE ALSO

L<RFID::Biblio::Reader::3M810>

L<RFID::Biblio::Reader::CPRM01>

L<RFID::Biblio::Reader::API>

