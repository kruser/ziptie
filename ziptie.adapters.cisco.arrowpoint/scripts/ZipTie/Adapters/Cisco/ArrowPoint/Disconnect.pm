package ZipTie::Adapters::Cisco::ArrowPoint::Disconnect;
use strict;
use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Logger;

use Exporter 'import';
our @EXPORT_OK =
  qw(disconnect);
  
# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Attempts to disconnect from an IOS-based device that a CLIProtocol object is currently connected to.
# If all is well, the device will be successfully disconnected from and no error will occur.
#
# Input:	$cliProtocol -	A valid ZipTie::CLIProtocol object that is already connected to a device.
#			$debug -		Whether or not to display debug information.
#
# Returns:	Nothing.
sub disconnect
{
	my $cliProtocol = shift;
	my $responseRegex = '/.*/im' ;
	$cliProtocol->send('exit');
	$cliProtocol->disconnect();	
}

sub send_no
{	
	my $cliProtocol = shift;
	my $bye = "";
	my $reg = /.+/ ;
	$cliProtocol->send_as_bytes_and_wait('6E',$reg);
	$cliProtocol->send_as_bytes('6E');
}

sub send_enter
{	
	my $cliProtocol = shift;
	my $bye = "";
	$cliProtocol->send_as_bytes('6E');
}

1;