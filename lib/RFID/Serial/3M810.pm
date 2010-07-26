package RFID::Serial::3M810;

use base 'RFID::Serial';
use RFID::Serial;

use Carp qw(confess);
use Time::HiRes;
use Digest::CRC;

sub serial_settings {{
	device    => "/dev/ttyUSB1", # FIXME comment out before shipping
	baudrate  => "19200",
	databits  => "8",
	parity	  => "none",
	stopbits  => "1",
	handshake => "none",
}}

my $port;
sub init {
	my $self = shift;
	$port = $self->port;

	# drain on startup
	my ( $count, $str ) = $port->read(3);
	my $data = $port->read( ord(substr($str,2,1)) );
	warn "drain ",as_hex( $str, $data ),"\n";

	setup();

}

sub checksum {
	my $bytes = shift;
	my $crc = Digest::CRC->new(
		# midified CCITT to xor with 0xffff instead of 0x0000
		width => 16, init => 0xffff, xorout => 0xffff, refout => 0, poly => 0x1021, refin => 0,
	) or die $!;
	$crc->add( $bytes );
	pack('n', $crc->digest);
}

sub wait_device {
	Time::HiRes::sleep 0.015;
}

sub cmd {
	my ( $hex, $description, $coderef ) = @_;
	my $bytes = hex2bytes($hex);
	if ( substr($bytes,0,1) !~ /(\xD5|\xD6)/ ) {
		my $len = pack( 'n', length( $bytes ) + 2 );
		$bytes = $len . $bytes;
		my $checksum = checksum($bytes);
		$bytes = "\xD6" . $bytes . $checksum;
	}

	warn ">> ", as_hex( $bytes ), "\t\t[$description]\n";
	$port->write( $bytes );

	wait_device;

	my $r_len = $port->read(3);

	while ( ! $r_len ) {
		wait_device;
		$r_len = $port->read(3);
	}

	my $len = ord( substr($r_len,2,1) );
	$data = $port->read( $len );
	warn "<< ", as_hex($r_len,$data)," $len\n";

	$coderef->( $data ) if $coderef;

}

sub assert {
	my ( $got, $expected ) = @_;
	$expected = hex2bytes($expected);

	my $len = length($got);
	$len = length($expected) if length $expected < $len;

	confess "got ", as_hex($got), " expected ", as_hex($expected)
	unless substr($got,0,$len) eq substr($expected,0,$len);
}

sub setup {

cmd(
'D5 00  05   04 00 11   8C66', 'hw version', sub {
	my $data = shift;
	assert $data => '04 00 11';
	my $hw_ver = join('.', unpack('CCCC', substr($data,3)));
	print "hardware version $hw_ver\n";
});

cmd(
'13  04 01 00 02 00 03 00 04 00','FIXME: stats? rf-on?', sub { assert(shift,
'13  00 02 01 01 03 02 02 03 00'
)});
}

1
