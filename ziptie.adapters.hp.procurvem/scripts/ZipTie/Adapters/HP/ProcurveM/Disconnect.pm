# Disconnect helps automate the exit and disconnect process from the devices.
#
# Author:	Dylan White (dylamite@ziptie.org)
# Customized to work with !IOS devices: Mekhman Kourbanov (mkourbanov@isthmusit.com)
package ZipTie::Adapters::HP::ProcurveM::Disconnect;

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
	# Grab the CLI protocol
	my $cliProtocol = shift;

	# Keep sending the "exit" command until we have successfully exited the device
	_send_exit($cliProtocol);
	
	# Finally, disconnect from our CLIProtocol
	$cliProtocol->disconnect();
}

# Repeatedly send the "exit" command to a device that a CLIProtocol is already connected to until it
# has successfully closed out its connection.
#
# Input:	$cliProtocol -	A valid ZipTie::CLIProtocol object that is already connected to a device.
#
# Returns:	Nothing.
sub _send_exit
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Send the "exit" command
	$cliProtocol->send_as_bytes('30');
	my $response = $cliProtocol->get_response(0.25);

	# Based on the response of the device, determine the next interaction that should be executed.
	if ($response)
	{
		_send_yes($cliProtocol);
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

# Send the "n" option to a device when it asks for configuration saving
#
# Input:	$cliProtocol -	A valid ZipTie::CLIProtocol object that is already connected to a device.
#
# Returns:	Nothing.
sub _send_yes
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Send the "Y" command
	$cliProtocol->send_as_bytes('59');
	my $response = $cliProtocol->get_response(0.25);
	
	# Based on the response of the device, determine the next interaction that should be executed.
	if (!$response)
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

1;