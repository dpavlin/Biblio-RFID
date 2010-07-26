package RFID::Serial::3M810;

use base 'RFID::Serial';
use RFID::Serial;

sub serial_settings {{
	device    => "/dev/ttyUSB0",
	baudrate  => "19200",
	databits  => "8",
	parity	  => "none",
	stopbits  => "1",
	handshake => "none",
}}

sub cmd {
	my ( $hex, $description, $coderef ) = @_;
	my $bytes = hex2bytes($hex);
	if ( substr($bytes,0,1) ne "\xD5" ) {
		my $len = pack( 'c', length( $bytes ) + 3 );
		$bytes = $len . $bytes;
		my $checksum = checksum($bytes);
		$bytes = "\xD6\x00" . $bytes . $checksum;
	}

	warn ">> ", as_hex( $bytes ), "\t\t[$description]\n";
	$port->write( $bytes );

	my $r_len = $port->read(3);

	while ( ! $r_len ) {
		warn "# wait for response length 5ms\n";
		$r_len = $port->read(3);
	}

	my $data_len = ord(substr($r_len,2,1)) - 1;
	my $data = $port->read( $data_len );
	warn "<< ", as_hex( $r_len . $data ),"\n";

	$coderef->( $data ) if $coderef;

}

sub assert {
	my ( $got, $expected ) = @_;
	die "got ", as_hex($got), " expected ", as_hex($expected)
	unless substr($expected,0,length($got)) eq $got;
}

sub init {
	my $self = shift;

cmd( 'D5 00  05   04 00 11' => 'hw version' . sub {
	my $data = shift;
	assert $data => '04 00 01';
	my $hw_ver = join('.', unpack('CCCC', substr($data,3)));
	print "hardware version $hw_ver\n";
});

cmd(
'13  04  01 00 02 00 03 00 04 00', 'FIXME: stats?', sub { assert(shift,
'13  00  02 01 01 03 02 02 03 00'
)});

}

1
