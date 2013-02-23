package ZipTie::Adapters::Nortel::BayStack::GetConfig;

use strict;
use ZipTie::Response;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::ConnectionPath::FileServer;
use ZipTie::TransferProtocol;
use ZipTie::TransferProtocolFactory;
use ZipTie::Logger;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::Adapters::Utils qw(create_empty_file escape_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_config
{

	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol    = shift;
	my $connection_path = shift;
	my $type            = shift;

	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the running configuration
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	if ( defined($tftp_protocol) )
	{
		if ( $type eq 'menu' )
		{
			return _menu_tftp_config( $cli_protocol, $connection_path );
		}
		elsif ( $type eq 'menu_ascii' )
		{
			$response = _menu_tftp_ascii_config( $cli_protocol, $connection_path );
		}
		elsif ( $type eq 'cli' )
		{
			$response = _cli_tftp_config( $cli_protocol, $connection_path );

		}
		elsif ( $type eq 'cli_running' )
		{
			$response = _cli_tftp_running( $cli_protocol, $connection_path );
		}
	}
	else
	{
		$LOGGER->fatal("[$TFTP_ERROR] TFTP must be enabled.");
	}
	return $response;
}

sub _cli_tftp_config
{
	my $cli_protocol    = shift;
	my $connection_path = shift;
	my $prompt          = $cli_protocol->get_prompt_by_name("prompt");

	my @responses = ();
	push( @responses, ZipTie::Response->new( 'timed out', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( $prompt, \&_finish ) );

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	my $temp_filename = escape_filename($connection_path->get_ip_address());
	create_empty_file( $tftp_file_server->get_root_dir() . '/' . $temp_filename );
	$cli_protocol->send( 'copy config tftp address ' . $tftp_file_server->get_ip_address() . ' filename ' . $temp_filename );
	my $response = $cli_protocol->wait_for_responses( \@responses, 300 );

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
		return &$next_interaction( $cli_protocol, $connection_path );
	}
}

sub _cli_tftp_running
{
	my $cli_protocol    = shift;
	my $connection_path = shift;
	my $prompt          = $cli_protocol->get_prompt_by_name("prompt");

	my @responses = ();
	push(
		@responses,
		ZipTie::Response->new(
			'Invalid|Cannot start upload|Load host not found or not respondin|TFTP unknown error|Operation aborted|Previous operation is currently in progress',
			undef,
			$TFTP_ERROR
		)
	);
	push( @responses, ZipTie::Response->new( 'completed|' . $prompt, \&_finish_running ) );
	push( @responses, ZipTie::Response->new( 'Error|TFTP Operation timed', undef, $TFTP_ERROR) );

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $filename         = escape_filename($connection_path->get_ip_address());
	create_empty_file( $tftp_file_server->get_root_dir() . '/' . $filename );
	$cli_protocol->send( 'copy running-config tftp address ' . $tftp_file_server->get_ip_address() . ' filename ' . $filename );
	my $response = $cli_protocol->wait_for_responses( \@responses, 90 );

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
		return &$next_interaction( $cli_protocol, $connection_path );
	}
}

sub _menu_tftp_config
{

	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol    = shift;
	my $connection_path = shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;

	$cli_protocol->send_as_bytes('67');    # g
	$response = $cli_protocol->get_response(0.25);

	# enter in a deeper menu
	if ( $response =~ /Ascii Configuration File Download\.\./ )
	{
		$cli_protocol->send_as_bytes('63');    # c
		$response = $cli_protocol->get_response(0.25);
	}

	my $filename = escape_filename($connection_path->get_ip_address());
	create_empty_file( $tftp_file_server->get_root_dir() . '/' . $filename );

	$cli_protocol->send($filename);            # filename
	$response = $cli_protocol->get_response(0.25);
	$cli_protocol->send_as_bytes('1b5b42');    # down arrow
	$response = $cli_protocol->get_response(0.25);
	$cli_protocol->send( $tftp_file_server->get_ip_address() );    # TFTP server IP
	$response = $cli_protocol->get_response(0.25);
	$cli_protocol->send_as_bytes('1b5b42');                        # down arrow
	$response = $cli_protocol->get_response(0.25);
	if ( $response =~ /\[\s*No\s*\]/ )
	{
		$cli_protocol->send_as_bytes('20');                        # space bar
		$response = $cli_protocol->get_response(0.25);
		if ( $response =~ /Access is read-only/i )
		{
			$LOGGER->fatal($INSUFFICIENT_PRIVILEGE);
		}
	}
	$cli_protocol->send('');                                       # enter

	# Wait for the TFTP response
	for ( my $i = 0 ; $i < 15 ; $i++ )
	{
		$response = $cli_protocol->get_response(0.25);
		if ( $response =~ /TFTP unknown error|Operation aborted|Error accessing configuration file|File not found/i )
		{
			$LOGGER->fatal($TFTP_ERROR);
		}
		elsif ( $response =~ /Access is read-only/i )
		{
			$LOGGER->fatal("[$INSUFFICIENT_PRIVILEGE] Access is read-only\n");
		}
		elsif ( $response =~ /Configuration file successfully/i )
		{
			return _finish( $cli_protocol, $connection_path );
		}
		else
		{
			sleep 5;    # wait 5 seconds for the TFTP to complete or fall over
		}
	}

	# fail if we fell through the loop
	$LOGGER->fatal($TFTP_ERROR);
}

sub _finish
{

	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol    = shift;
	my $connection_path = shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Retrieve the running configuration file from the TFTP server
	my $config_file = $tftp_file_server->get_root_dir() . "/" . escape_filename($connection_path->get_ip_address());

	# Open up the binary configuration file and read it into memory
	open( CONFIG, $config_file ) || $LOGGER->fatal("Error: Could not open $config_file");
	binmode(CONFIG);
	my $config_contents;
	while ( read( CONFIG, $b, 1 ) )
	{
		$config_contents .= $b;
	}
	close(CONFIG);

	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink($config_file);

	# Record the file transfer of the config
	# Arguments: protocol name, file name, response/contents
	$RECORDING->create_xfer_interaction( $tftp_file_server->get_protocol(), $connection_path->get_ip_address(), $config_contents );

	# Return the contents of the running configuration
	return $config_contents;
}

sub _finish_running
{

	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol    = shift;
	my $connection_path = shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Retrieve the running configuration file from the TFTP server
	my $config_name = escape_filename( $connection_path->get_ip_address() );
	my $configFile  = $tftp_file_server->get_root_dir() . "/" . $config_name;

	# Open up the binary configuration file and read it into memory
	open( CONFIG, $configFile ) || $LOGGER->fatal("Error: Could not open $configFile");
	my @entireFile = <CONFIG>;
	close(CONFIG);
	my $configContents = join( "", @entireFile );

	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink($configFile);

	# Record the file transfer of the running config
	# Arguments: protocol name, file name, response/contents
	$RECORDING->create_xfer_interaction( $tftp_file_server->get_protocol(), $config_name, $configContents );

	# Return the contents of the running configuration
	return $configContents;
}

1;
