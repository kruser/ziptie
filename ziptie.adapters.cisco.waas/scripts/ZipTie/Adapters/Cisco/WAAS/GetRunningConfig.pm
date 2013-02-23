package ZipTie::Adapters::Cisco::WAAS::GetRunningConfig;

use strict;

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
our @EXPORT_OK = qw(get_running_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_running_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Create an undef reference that can eventually hold the running configuration contents that are found
	my $response = undef;

	# Check to see if either TFTP or SCP are supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the running configuration
	if ( defined($tftp_protocol) )
	{
		_touch_file_for_tftp($cli_protocol, $connection_path);
		$response = _get_running_config_tftp($cli_protocol, $connection_path);
	}
	
	# Otherwise, fall back to CLI protocol only
	else
	{
		$response = _get_running_config_cli($cli_protocol);
	}
	
	# Return the running configuration found
	return $response;
}

sub _get_running_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol = shift;
	
	# Sending "show running-config" command
	my $command = "show running-config";
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
	
	# remove leading cruft from the 'show' command output
	$response =~ s/^.*?(?=^!)//ms;
	
	# Return the running configuration found
	return $response;
}

sub _get_running_config_tftp

{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error opening nvram', undef, $NVRAM_CORRUPTION_ERROR));
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Ss]ource [Ff]ilename', \&_specify_source_running_file));
	push(@responses, ZipTie::Response->new('[Rr]emote host', \&_specify_tftp_address));
	
	# The WAE/WAAS platform appears to like having all parameters passed to the TFTP command at once, so ...
	push(@responses, ZipTie::Response->new('[Ii]ncomplete command', \&_specify_all_info));

	# Grab the enable prompt that was retrieved by the auto-login of the WAAS device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	my $bad_command_regex = '%\s*[Ii]nvalid input.*[\n\r]+' . $enable_prompt;
	push(@responses, ZipTie::Response->new($bad_command_regex, \&_copy_nvram));

	# Sending "copy running-config tftp" command
	my $command = "copy running-config tftp";
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _copy_nvram()
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Grab the enable prompt that was retrieved by the auto-login of the WAAS device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error: Configuration upload operation failed', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
	
	my $bad_command_regex = '%\s*[Ii]nvalid input.*[\n\r]+' . $enable_prompt;
	push(@responses, ZipTie::Response->new($bad_command_regex, \&_get_running_config_cli));
	
	# Sending "copy nvram tftp://" command and append the IP of the TFTP server as well
	# as the name to save the file as
	my $tftp_server_ip = $tftp_file_server->get_ip_address();
	my $nvram_config_file = escape_filename ( $cli_protocol->get_ip_address() ) . ".running-config";
	my $command = "copy nvram tftp://$tftp_server_ip/$nvram_config_file";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses(\@responses, 120);
	
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_source_running_file()
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error opening nvram', undef, $NVRAM_CORRUPTION_ERROR));
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Rr]emote host|ostname', \&_specify_tftp_address));
	
	# Sending "running-config" as the source file name for the running configuration.
	my $command = "running-config";
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_tftp_address
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('filename|file to write', \&_specify_running_config_name));
	
	# Sending the TFTP server address
	$cli_protocol->send( $tftp_file_server->get_ip_address() );
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_running_config_name
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error opening tftp|Error reading|timed out|cannot copy|%Error|Failed', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error opening nvram', undef, $NVRAM_CORRUPTION_ERROR));
	push(@responses, ZipTie::Response->new('confirm', \&_confirm_tftp));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
	
	# Sending the name of the file that we want to save the running config as
	my $runningConfigName = escape_filename ( $cli_protocol->get_ip_address() ) . ".running-config";
	$cli_protocol->send( $runningConfigName );
	
	# Wait 120 seconds for any TFTP transaction to complete
	my $response = $cli_protocol->wait_for_responses(\@responses, 120);
	
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_all_info

{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;

	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $runningConfigName = escape_filename ( $cli_protocol->get_ip_address() ) . ".running-config";
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));

	# Sending "copy running-config tftp" command
	my $command = "copy running-config tftp " . $tftp_file_server->get_ip_address() . " $runningConfigName";
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}


sub _confirm_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error opening tftp|Error reading|timed out|cannot copy|%Error|Failed', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error opening nvram', undef, $NVRAM_CORRUPTION_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
	
	# Sending a newline to confirm
	$cli_protocol->send( "" );
	
	# Wait 120 seconds for any TFTP transaction to complete
	my $response = $cli_protocol->wait_for_responses(\@responses, 120);
	
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
		# Return the running configuration found
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
	
	# Retrieve the running configuration file from the TFTP server
	my $running_config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".running-config";
	my $running_config_file = $tftp_file_server->get_root_dir() . "/$running_config_name";
	
	# Open up the running configuration file and read it into memory
	open(RUNNING_CONFIG, $running_config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved running configuration file stored in '$running_config_file'!");
	my @entire_file = <RUNNING_CONFIG>;
	close(RUNNING_CONFIG);
	my $running_config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($running_config_file);
	
	# Record the file transfer of the running config
    # Arguments: protocol name, file name, response/contents
	$RECORDING->create_xfer_interaction($tftp_file_server->get_protocol(), $running_config_name, $running_config_contents);
	
	# Return the contents of the running configuration
	return $running_config_contents;
}

sub _touch_file_for_tftp
{
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $running_config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".running-config";
	create_empty_file($tftp_file_server->get_root_dir() . "/$running_config_name");
}

1;
