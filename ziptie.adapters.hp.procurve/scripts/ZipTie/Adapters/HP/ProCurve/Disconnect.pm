package ZipTie::Adapters::HP::ProCurve::Disconnect;

use strict;
use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Logger;

use Exporter 'import';
our @EXPORT_OK = qw(disconnect);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Attempts to disconnect from an ProCurve-based device that a CLIProtocol object is currently connected to.
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
	
	# Specify the responses to handle
	my @responses = ();
	push(@responses, ZipTie::Response->new('log\s+out\s+\[y\/n\]', \&_send_yes));
	push(@responses, ZipTie::Response->new('save.*\[y\/n\]', \&_send_no));
	push(@responses, ZipTie::Response->new('#|>', \&_send_exit));
	push(@responses, ZipTie::Response->new('.*'));
	
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

sub _send_yes
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Specify the responses to handle
	my @responses = ();
	push(@responses, ZipTie::Response->new("save.*[y/n]", \&_send_no));
	push(@responses, ZipTie::Response->new(".*"));
	
	# Send a "y"
	$cliProtocol->send("y");
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

sub _send_no
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Specify the responses to handle
	my @responses = ();
	push(@responses, ZipTie::Response->new(".*"));
	
	# Send an "n"
	$cliProtocol->send("n");
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
