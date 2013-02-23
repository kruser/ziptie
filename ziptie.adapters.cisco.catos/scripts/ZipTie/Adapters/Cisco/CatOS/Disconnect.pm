# ZipTie::IOS::Disconnect helps automate the exit and disconnect process from IOS-based devices.
# This includes IOS, CatIOS, and MSFC.
#
# Author:	Dylan White (dylamite@ziptie.org)
package ZipTie::Adapters::Cisco::CatOS::Disconnect;

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
	
	# Send the Control-C command which is 0x03 in hexidecimal
	$cliProtocol->send_as_bytes("03");
	my $enablePrompt = $cliProtocol->get_prompt_by_name("enablePrompt");
	my $response = $cliProtocol->wait_for($enablePrompt);
	
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
	
	# Specify the responses to handle
	my @responses = ();
	push(@responses, ZipTie::Response->new("#|>", \&_send_exit));
	push(@responses, ZipTie::Response->new(".*"));
	
	# Send the "exit" command
	$cliProtocol->send("exit");
	my $response = $cliProtocol->wait_for_responses(\@responses);
	
	# Based on the response of the device, determine the next interaction that should be executed.
	my $nextInteraction = undef;
	if ($response)
	{
		$nextInteraction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
	
	# Call the next interaction if there is one to call
	if ($nextInteraction)
	{
		return &$nextInteraction($cliProtocol);
	}
}

1;