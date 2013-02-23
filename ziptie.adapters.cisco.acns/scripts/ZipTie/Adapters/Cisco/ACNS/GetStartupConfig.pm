package ZipTie::Adapters::Cisco::ACNS::GetStartupConfig;

use strict;
use warnings;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::TransferProtocolFactory;
use ZipTie::TransferProtocol;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::ConnectionPath::FileServer;
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(create_empty_file escape_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_startup_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_startup_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Create an undef reference that can eventually hold the startup configuration contents that are found
	my $response = undef;

	# Check to see if either TFTP or SCP are supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the startup configuration
	if ( defined($tftp_protocol) )
	{
		_touch_file_for_tftp($cli_protocol, $connection_path);
		$response = _get_startup_config_tftp($cli_protocol, $connection_path);
	}
	
	# Otherwise, fall back to CLI protocol only
	else
	{
		$response = _get_startup_config_cli($cli_protocol);
	}
	
	# Return the startup configuration found
	return $response;
}

sub _get_startup_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol = shift;
	
	# Sending "show startup-config" command
	my $command = "show startup-config";
	$cli_protocol->send( $command );
	
	# Grab the enable prompt that was retrieved by the auto-login of the IOS device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Check to see if the enable prompt was set on the device.  If not, fall back to matching '>|#'
	my $regex = defined($enable_prompt) ? $enable_prompt : '>|#';
	my $response = $cli_protocol->wait_for($regex, 120);
	
	# remove the prompt
	$response =~ s/$regex$//;

	# remove any --More-- prompt lines from older (1900) devices
	$response =~ s/^--More--\s*$//mg;

	# remove any extra spaces between !
	$response =~ s/!\n\n!/!\n!/g;
	
	# remove leading cruft from the 'show' command output
	$response =~ s/^.*?(?=^!)//ms;
	
	# Return the startup configuration found
	return $response;
}

sub _get_startup_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;

	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $startupConfigName = escape_filename ( $cli_protocol->get_ip_address() ) . ".startup-config";
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('Copy running-config to tftp failed.', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));

	# Sending "copy startup-config tftp" command
	my $command = "copy startup-config tftp " . $tftp_file_server->get_ip_address() . " $startupConfigName";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses(\@responses);

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
		# Return the startup configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _finish
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Retrieve the startup configuration file from the TFTP server
	my $startup_config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".startup-config";
	my $startup_config_file = $tftp_file_server->get_root_dir() . "/$startup_config_name";
	
	# Open up the startup configuration file and read it into memory
	open(STARTUP_CONFIG, $startup_config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved startup configuration file stored in '$startup_config_file'");
	my @entire_file = <STARTUP_CONFIG>;
	close(STARTUP_CONFIG);
	my $startup_config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($startup_config_file);
	
	# remove any extra spaces between !
	$startup_config_contents =~ s/!\n\n!/!\n!/g;
	
	# Record the file transfer of the startup config
	# Arguments: protocol name, file name, response/contents
	$RECORDING->create_xfer_interaction($tftp_file_server->get_protocol(), $startup_config_name, $startup_config_contents);
	
	# Return the contents of the startup configuration
	return $startup_config_contents;
}

sub _touch_file_for_tftp
{
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $startup_config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".startup-config";
	create_empty_file($tftp_file_server->get_root_dir() . "/$startup_config_name");
}

1;
