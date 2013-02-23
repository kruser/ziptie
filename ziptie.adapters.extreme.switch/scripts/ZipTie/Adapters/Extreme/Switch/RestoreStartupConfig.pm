package ZipTie::Adapters::Extreme::Switch::RestoreStartupConfig;

use strict;
use warnings;

use ZipTie::Response;
use ZipTie::TransferProtocolFactory;
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(escape_filename);

my $LOGGER = ZipTie::Logger::get_logger();

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $startupFile, $promptRegex, $attempt ) = @_;
	my $tftpFileServer    = $connectionPath->get_file_server_by_name("TFTP");
	my $startupConfigName = escape_filename ( $cliProtocol->get_ip_address() ) . ".startup-config";
	my $startupConfigFile = $tftpFileServer->get_root_dir() . "/$startupConfigName";

	# Write out the file to the TFTP directory
	open( STARTUP, ">$startupConfigFile" );
	print STARTUP $startupFile->get_blob();
	close(STARTUP);
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('reboot the system\? \(Y\/N\)', \&_finish));
	push(@responses, ZipTie::Response->new('(?i:ERROR)', \&restore_via_tftp));
	
	#the device is too slow, and it constantly resets the connection
	#due to this fact, we therefore make 3 attempts
	unless ($attempt <= 4)
	{
		$attempt--;
		$LOGGER->fatal("Impossible to restore configuration in $attempt attempts");
	}
		
	$LOGGER->debug("Going for attempt # $attempt");
	$cliProtocol->send( "download configuration " . $tftpFileServer->get_ip_address() . " " . $startupConfigFile );
	my $response = $cliProtocol->wait_for_responses( \@responses, 180 );
	unlink($startupConfigFile);

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{
		# Return the configuration found
		return &$next_interaction( $connectionPath, $cliProtocol, $startupFile, $promptRegex, ++$attempt);
	}
	else
	{
		$LOGGER->fatal("Unable to continue interacting with device, there was a problem getting the next interaction subroutine");
	}
}

sub _finish
{
	my $connectionPath = shift;
	my $cli_protocol = shift;
	
	#at this point, the device is waiting for us to tell it
	#whether we want to reboot or not, fo the new config to become active
	
	
	# answering no to the question
	$cli_protocol->send( 'n' );

	# Grab the prompt that was retrieved by the auto-login.
	my $prompt = $cli_protocol->get_prompt_by_name("prompt");

	# Check to see if the enable prompt was set on the device.  If not, fall back to matching '>|#'
	my $regex = defined($prompt) ? $prompt : '>|#';
	
	my $response = $cli_protocol->wait_for($regex);
}


1;
