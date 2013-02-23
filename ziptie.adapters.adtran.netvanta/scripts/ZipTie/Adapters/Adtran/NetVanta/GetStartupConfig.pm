package ZipTie::Adapters::Adtran::NetVanta::GetStartupConfig;

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
	
	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;

	# Check to see if either TFTP is supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );
		
	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the configuration
	if ( defined($tftp_protocol) )
	{
		_touch_file_for_tftp($cli_protocol, $connection_path);
		$response = _copy_startup_config_tftp($cli_protocol, $connection_path);
	}
	
	# Otherwise, fall back to CLI protocol only
	else 
	{
		$response = _get_startup_config_cli($cli_protocol);
	}
	 
	# Return the configuration found
	return $response;
}

sub _get_startup_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol = shift;
	
	# Sending "show config all" command
	my $command = "show startup-config";
	$cli_protocol->send( $command );
	
	# Grab the enable prompt that was retrieved by the auto-login of the NetVanta device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Check to see if the enable prompt was set on the device.  If not, fall back to matching '>|#'
	my $regex = defined($enable_prompt) ? $enable_prompt : '>|#';
	my $response = $cli_protocol->wait_for($regex);
	
	# remove the prompt
	$response =~ s/$regex$//;
	
	# remove any --More-- prompt lines from older devices
	$response =~ s/--MORE--[\x8\s]*//mgi;
	
	$response =~ /show startup-config\s*Using \d+ bytes\s*(.*)$/mis;
	
	# Return the configuration found
	return $1;
}


sub _copy_startup_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('% Invalid or incomplete command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('% Timed out waiting on packet', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP connection fail', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP write error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Dd]estination [Ff]ilename\?', \&_specify_dest_file));
	push(@responses, ZipTie::Response->new('[Aa]ddress of remote host\?', \&_specify_tftp_address));
	
	# Grab the enable prompt that was retrieved by the auto-login of the NetVanta device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Sending "copy config tftp" command
	my $command = "copy startup-config tftp";
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _write_command
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('y\/n', \&_confirm_tftp));
	push(@responses, ZipTie::Response->new('% Invalid or incomplete command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('% Timed out waiting on packet', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP connection fail', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP write error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Ss]ource [Ff]ilename', \&_specify_source_file));
	push(@responses, ZipTie::Response->new('[Rr]emote host', \&_specify_tftp_address));
	
	# Grab the enable prompt that was retrieved by the auto-login of the NetVanta device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Grab the TFTP server IP address
	my $tftp_ip_address = $tftp_file_server->get_ip_address();
	
	# Compute the name of the file that we want to save the config as
	my $config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".config";
	
	# Sending "write" command and append the IP address of the TFTP server as well as the name of the config
	my $command = "write $tftp_ip_address $config_name";
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_dest_file()
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('% Invalid or incomplete command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('% Timed out waiting on packet', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP connection fail', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP write error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Aa]ddress of remote host\?', \&_specify_tftp_address));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	my $config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".config";
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";
	$cli_protocol->send( $config_name );
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
		# Return the configuration found
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
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Specify the responses to check for	
	my @responses = ();
	push(@responses, ZipTie::Response->new('[Dd]estination [Ff]ilename\?', \&_specify_dest_file));
	push(@responses, ZipTie::Response->new('% Invalid or incomplete command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('% Timed out waiting on packet', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP connection fail', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP write error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
	
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
		# Return the configuration found
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
	push(@responses, ZipTie::Response->new('No response from host', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP connection fail', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('TFTP write error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
	
	# Sending "yes" to confirm
	$cli_protocol->set_timeout(30);
	$cli_protocol->send( "yes" );
	
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
		# Return the configuration found
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
	
	# Retrieve the configuration file from the TFTP server
	my $config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".config";
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";
	
	sleep (10);
	
	# Open up the configuration file and read it into memory
	open(CONFIG, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file'!");
	my @entire_file = <CONFIG>;
	close(CONFIG);
	my $config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($config_file);
	
	# Record the file transfer of the config
    # Arguments: protocol name, file name, response/contents
    $RECORDING->create_xfer_interaction($tftp_file_server->get_protocol(), $config_name, $config_contents);
	
	# Return the contents of the configuration
	$config_contents =~ s/^--MORE--\s+//gis;
	return $config_contents;
}

sub _touch_file_for_tftp
{
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $configName = escape_filename ( $cli_protocol->get_ip_address() ) . ".config";
	create_empty_file( $tftp_file_server->get_root_dir() . "/$configName");
}

1;

__END__
