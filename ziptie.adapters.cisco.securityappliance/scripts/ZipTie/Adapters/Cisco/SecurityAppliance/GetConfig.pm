package ZipTie::Adapters::Cisco::SecurityAppliance::GetConfig;

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
use ZipTie::Adapters::Utils qw(create_empty_file create_unique_filename escape_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename		= shift;

	# Create an undef reference that can eventually hold the startup configuration contents that are found
	my $response = undef;

	# Check to see if either TFTP or SCP are supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP") if ( defined($connection_path) );

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the startup configuration
	if ( defined($tftp_protocol) )
	{
		_touch_file_for_tftp($cli_protocol, $connection_path, $filename);
		$response = _get_config_tftp($cli_protocol, $connection_path, $filename);
	}
	
	# Check to see if SCP is supported.  If so, a SCP client will be used to retrieve the startup configuration
	elsif ( defined($scp_protocol) )
	{
		$response = _get_config_scp($connection_path, $filename);
	}
	
	# Otherwise, fall back to CLI protocol only
	else
	{
		$response = _get_config_cli($cli_protocol, $filename);
	}
	
	# Return the startup configuration found
	return $response;
}

sub _get_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol = shift;
	my $filename	 = shift;

	# Sending "show startup-config" command
	my $command = "show $filename";
	$cli_protocol->send( $command );
	
	# Grab the enable prompt that was retrieved by the auto-login of the IOS device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Check to see if the enable prompt was set on the device.  If not, fall back to matching '>|#'
	#my $regex = defined($enable_prompt) ? $enable_prompt : '>|#';
	my $regex = '#\s*';
	my $response = $cli_protocol->wait_for($regex, 120);
	
	if ($response =~ /% Invalid input detected/)
	{
		$LOGGER->fatal_error_code($INSUFFICIENT_PRIVILEGE, $cli_protocol->get_ip_address(), "Unable to issue \"$command\"");
	}
	
	# remove the prompt
	$response =~ s/$regex$//;
	
	# remove any --More-- prompt lines from older (1900) devices
	$response =~ s/^--More--\s*$//m;
	
	# remove leading cruft from the 'show' command output
	$response =~ s/^.*?(?=^!)//ms;
	
	# Return the startup configuration found
	return $response;
}

sub _get_config_scp
{
	# Grab our ZipTie::ConnectionPath object
	my $connection_path = shift;
	my $filename	 	= shift;

	# Grab the ZipTie::ConnectionPath::Protocol object representing SCP from the ZipTie::ConnectionPath object
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP");

	# Retrieve the startup configuration file from the device
	my $xfer_client = ZipTie::TransferProtocolFactory::create( $scp_protocol->get_name() );
	$xfer_client->connect(	$connection_path->get_ip_address(),
							$scp_protocol->get_port(),
							$connection_path->get_credential_by_name("username"),
							$connection_path->get_credential_by_name("password") );

	my $temp_filename = create_unique_filename();
	$xfer_client->get( $filename, $temp_filename );

	# Open up the startup configuration file and read it into memory
	open(STARTUP_CONFIG, $temp_filename) || $LOGGER->fatal("[$SCP_ERROR]\nCould not open the retrieved startup configuration file stored in '$temp_filename'");
	my @entire_file = <STARTUP_CONFIG>;
	close(STARTUP_CONFIG);
	my $config_contents = join( "", @entire_file );

	# Record the file transfer of the startup config
    # Arguments: protocol name, file name, response/contents, whether or not ZipTie acted as the file transfer server
    $RECORDING->create_xfer_interaction($scp_protocol->get_name(), $filename, $config_contents, 0);

	# Return the contents of the startup configuration
	return $config_contents;
}

sub _get_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error opening nvram', undef, $NVRAM_CORRUPTION_ERROR));
	push(@responses, ZipTie::Response->new('Error|Unrecognized command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('% Invalid input detected at', undef, $INSUFFICIENT_PRIVILEGE));
	push(@responses, ZipTie::Response->new('[Uu]sage:', \&_write_net));
	push(@responses, ZipTie::Response->new('[Ss]ource [Ff]ilename', \&_specify_source_file));
	push(@responses, ZipTie::Response->new('[Rr]emote host', \&_specify_tftp_address));
	push(@responses, ZipTie::Response->new('[Dd]estination [Ff]ilename', \&_specify_destination_file));
	push(@responses, ZipTie::Response->new('bytes copied in [\d\.]+ secs|OK|#\s*', \&_finish));

	# Sending "copy $filename tftp" command
	my $command = "copy $filename tftp";
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
		return &$next_interaction( $cli_protocol, $connection_path, $filename );
	}
}

sub _write_net()
{
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('Error opening nvram', undef, $NVRAM_CORRUPTION_ERROR));
	push(@responses, ZipTie::Response->new('Error|Unrecognized command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('% Invalid input detected at', undef, $INSUFFICIENT_PRIVILEGE));
	push(@responses, ZipTie::Response->new('OK|#\s*', \&_finish));

	# Build destination filename
	my $full_filename = escape_filename( $cli_protocol->get_ip_address() ) . ".$filename";

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server	= $connection_path->get_file_server_by_name("TFTP");
	my $tftp_server_address	= $tftp_file_server->get_ip_address();

	# Sending "write net <tftp_server_address>:filename" command
	my $command = "write net $tftp_server_address:$full_filename";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses( \@responses, 120 );

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
		return &$next_interaction( $cli_protocol, $connection_path, $filename );
	}
}

sub _specify_destination_file()
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error|Unrecognized command|[Rr]emote host|[Dd]estination [Ff]ilename', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('bytes copied in [\d\.]+ secs|OK|#\s*', \&_finish));

	# Sending "<ipAddress>.$fielname" as the destination file name for the configuration.
	my $command = escape_filename( $cli_protocol->get_ip_address() ) . ".$filename";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses( \@responses, 120 );

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
		return &$next_interaction( $cli_protocol, $connection_path, $filename );
	}
}

sub _specify_tftp_address
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error|Unrecognized command|[Ss]ource [Ff]ilename|[Rr]emote host', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Dd]estination [Ff]ilename', \&_specify_destination_file));
	push(@responses, ZipTie::Response->new('bytes copied in [\d\.]+ secs|OK|#\s*', \&_finish));

	# Sending the TFTP server address
	$cli_protocol->send( $tftp_file_server->get_ip_address() );
	my $response = $cli_protocol->wait_for_responses( \@responses );
	
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
		return &$next_interaction( $cli_protocol, $connection_path, $filename );
	}
}


sub _specify_source_file
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error|Unrecognized command|[Ss]ource [Ff]ilename', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Dd]estination [Ff]ilename', \&_specify_destination_file));
	push(@responses, ZipTie::Response->new('[Rr]emote host', \&_specify_tftp_address));
	push(@responses, ZipTie::Response->new('bytes copied in [\d\.]+ secs|OK|#\s*', \&_finish));
 
	# Sending the TFTP server address
	$cli_protocol->send( $filename );
	my $response = $cli_protocol->wait_for_responses( \@responses );
	
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
		return &$next_interaction( $cli_protocol, $connection_path, $filename );
	}
}

sub _finish
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Retrieve the startup configuration file from the TFTP server
	my $config_name = escape_filename( $cli_protocol->get_ip_address() ) . ".$filename";
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";
	
	# Open up the startup configuration file and read it into memory
	open(CONFIG_FILE, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file'");
	my @entire_file = <CONFIG_FILE>;
	close(CONFIG_FILE);
	my $config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($config_file);
	
	# Record the file transfer of the startup config
    # Arguments: protocol name, file name, response/contents
    $RECORDING->create_xfer_interaction($tftp_file_server->get_protocol(), $config_name, $config_contents);
	
	# Return the contents of the startup configuration
	return $config_contents;
}

sub _touch_file_for_tftp
{
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename	 	= shift;
	
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $config_name = escape_filename( $cli_protocol->get_ip_address() ) . ".$filename";
	create_empty_file($tftp_file_server->get_root_dir() . "/$config_name");
}

1;
