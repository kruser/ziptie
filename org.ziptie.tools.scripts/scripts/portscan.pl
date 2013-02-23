#!/usr/bin/perl
use strict;

use ZipTie::Logger;
use IO::Socket::INET;

#Auto-flush.
$| = 1;

my $device = shift(@ARGV);

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my @ports = ( 20, 21, 22, 23, 69, 80, 161, 443, );
print $device;
foreach my $port (@ports)
{
	#Attempt to connect to $host on $port.
	my $socket;
	my $success = eval {
		$socket = IO::Socket::INET->new(
			PeerAddr => $device,
			PeerPort => $port,
			Proto    => 'tcp'
		);
	};

	#If the port was opened, say it was and close it.
	if ($success) {
		print ',UP';
		shutdown( $socket, 2 );
	}
	else
	{
		print ',DOWN';
	}
}
print "\n";
