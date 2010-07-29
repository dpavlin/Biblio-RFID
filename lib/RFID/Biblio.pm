package RFID::Biblio;

use warnings;
use strict;

use base 'Exporter';
our @EXPORT = qw( hex2bytes as_hex hex_tag );

use Device::SerialPort qw(:STAT);
use Data::Dump qw(dump);

=head1 NAME

RFID::Biblio - support serial RFID devices

=cut

our $VERSION = '0.01';

my $debug = 0;


=head1 SYNOPSIS

This module tries to support USB serial RFID readers wsing simple API
which is sutable for direct mapping to REST JSONP service.

Perhaps a little code snippet.

    use RFID::Biblio;

    my $rfid = RFID::Biblio->new(
		device => '/dev/ttyUSB0', # with fallback to RFID_DEVICE
	);
	my $visible = $rfid->scan;

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
	my $class = shift;
	my $self = {@_};
	bless $self, $class;

	$self->port;

	$self->init;

	return $self;
}

=head2 port

  my $serial_obj = $self->port;

=cut

sub port {
	my $self = shift;

	return $self->{port} if defined $self->{port};

	my $settings = $self->serial_settings;
	$settings->{device} ||= $ENV{RFID_DEVICE};
	warn "# settings ",dump $settings;

	$self->{port} = Device::SerialPort->new( $settings->{device} )
	|| die "can't open serial port: $!\n";

	$self->{port}->$_( $settings->{$_} )
	foreach ( qw/handshake baudrate databits parity stopbits/ );

}

=head2 scan

  my $visible = $rfid->scan;

Returns hash with keys which match tag UID and values with blocks

=cut

sub scan {
	my $self = shift;

	warn "# scan tags in reader range\n";
	my @tags = $self->inventory;

	my $visible;
	# FIXME this is naive implementation which just discards other tags
	foreach my $tag ( @tags ) {
		my $blocks = $self->read_blocks( $tag );
		if ( ! $blocks ) {
			warn "ERROR: can't read tag $tag\n";
			delete $visible->{$tag};
		} else {
			$visible->{$tag} = $blocks->{$tag};
		}
	}

	return $visible;
}


=head1 MANDATORY IMPLEMENTATIONS

Each reader must implement following hooks as sub-classes.

=head2 init

  $self->init;

=head2 inventory

  my @tags = $self->invetory;

=head2 read_blocks

  my $hash = $self->read_blocks $tag;

All blocks are under key which is tag UID

  $hash = { 'E000000123456789' => [ undef, 'block1', 'block2', ... ] };

L<RFID::Biblio::3M810> sends tag UID with data payload, so we might expect
to receive response from other tags from protocol specification, 


=head1 EXPORT

Formatting functions are exported

=head2 hex2bytes

  my $bytes = hex2bytes($hex);

=cut

sub hex2bytes {
	my $str = shift || die "no str?";
	my $b = $str;
	$b =~ s/\s+//g;
	$b =~ s/(..)/\\x$1/g;
	$b = "\"$b\"";
	my $bytes = eval $b;
	die $@ if $@;
	warn "## str2bytes( $str ) => $b => ",as_hex($bytes) if $debug;
	return $bytes;
}

=head2 as_hex

  print as_hex( $bytes );

=cut

sub as_hex {
	my @out;
	foreach my $str ( @_ ) {
		my $hex = uc unpack( 'H*', $str );
		$hex =~ s/(..)/$1 /g if length( $str ) > 2;
		$hex =~ s/\s+$//;
		push @out, $hex;
	}
	return join(' | ', @out);
}

=head2 hex_tag

  print hex_tag $8bytes;

=cut

sub hex_tag { uc(unpack('H16', shift)) }


=head1 AUTHOR

Dobrica Pavlinusic, C<< <dpavlin at rot13.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-rfid-serial at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=RFID-Biblio>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RFID::Biblio


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=RFID-Biblio>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/RFID-Biblio>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/RFID-Biblio>

=item * Search CPAN

L<http://search.cpan.org/dist/RFID-Biblio/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Dobrica Pavlinusic.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut

1; # End of RFID::Biblio
