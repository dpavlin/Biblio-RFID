package RFID::Biblio::librfid;

use warnings;
use strict;

use base 'RFID::Biblio';
use RFID::Biblio;

use Data::Dump qw(dump);

=head1 NAME

RFID::Biblio::librfid - execute librfid-tool

=head2 DESCRIPTION

This is wrapper around C<librfid-tool> from

L<http://openmrtd.org/projects/librfid/>

=head2 SYOPSYS



=cut

sub serial_settings {} # don't open serial

our $bin = '/rest/cvs/librfid/utils/librfid-tool';

sub init {
	my $self = shift;
	warn "# no $bin found\n" if ! -e $bin;
}

sub _grep_tool {
	my ( $param, $coderef ) = @_;

	warn "# _grep_tool $bin $param\n";
	open(my $s, '-|', "$bin $param") || die $!;
	while(<$s>) {
		chomp;
		warn "## $_\n";
		$coderef->( $_ );
	}


}

sub inventory {

	my @tags; 
	_grep_tool '--scan' => sub {
		if ( m/success.+:\s+(.+)/ ) {
			push @tags, $1;
		}
	};
	warn "# invetory ",dump(@tags);
	return @tags;
}

sub read_blocks {

	my $blocks;
	_grep_tool '--read -1' => sub {
		$blocks->[$1] = hex2bytes($2)
		if m/block\[\s*(\d+):.+data.+:\s*(.+)/;
	};
	warn "# read_blocks ",dump($blocks);
	return $blocks;
}

sub write_blocks {}
sub read_afi {}
sub write_afi {}

1
