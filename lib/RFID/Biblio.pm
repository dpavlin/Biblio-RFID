package RFID::Biblio;

use warnings;
use strict;

use base 'Exporter';
our @EXPORT = qw( hex2bytes as_hex hex_tag );

use Data::Dump qw(dump);

=head1 NAME

RFID::Biblio - perl tools to use different RFID readers for library use 

=cut

our $VERSION = '0.02';

my $debug = 0;


=head1 DESCRIPTION

Main idea is to develop simple API to reader, and than provide useful
abstractions on top of it to quickly write applications to respond on
tags which come in range of RFID reader using L<RFID::Biblio::Reader>.

Writing support for new RFID readers should be easy.
L<RFID::Biblio::Reader::API> provides documentation on writing support
for different readers.

Currently, two serial RFID readers based on L<RFID::Biblio::Reader::Serial>
are implemented:

=over 4

=item *

L<RFID::Biblio::Reader::3M810>

=item *

L<RFID::Biblio::Reader::CPRM02>

=back

There is also simple read-only reader using shell commands in
L<RFID::Biblio::Reader::librfid>.

For implementing application take a look at L<RFID::Biblio::Reader>

C<scripts/RFID-JSONP-server.pl> is example of such application. It's local
interface to RFID reader and JSONP REST server.

C<examples/koha-rfid.js> is jQuery based JavaScript code which can be inserted
in Koha Library System to provide overlay with tags in range and
check-in/check-out form-fill functionality.

=for readme stop

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

=for readme continue

=head1 HARDWARE SUPPORT

=head2 3M 810

L<RFID::Biblio::Reader::3M810>

=head2 CPR-M02

L<RFID::Biblio::Reader::CPRM02>

=head2 librfid

L<RFID::Biblio::Reader::librfid>


=head1 AUTHOR

Dobrica Pavlinusic, C<< <dpavlin at rot13.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-rfid-biblio at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=RFID-Biblio>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RFID::Biblio
    perldoc RFID::Biblio::Reader
    perldoc RFID::Biblio::Reader::API


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
