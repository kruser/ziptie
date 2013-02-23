package ZipTie::Adapters::Alteon::AD3::GetConfig;

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
use ZipTie::Adapters::Utils qw(escape_filename);

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

	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the configuration
	if ( defined($tftp_protocol) )
	{
		$response = _get_config_tftp( $cli_protocol, $connection_path );
	}

	# Otherwise, throw fatal error
	else
	{
		$LOGGER->fatal("Unable to backup without TFTP/SCP.");
	}
	
	# Return the configuration found
	return $response;
}

sub _get_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error|nknown command', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('Enter name of file on TFTP server:', \&_specify_target_file));
	push(@responses, ZipTie::Response->new('Enter hostname or IP address of TFTP server:', \&_specify_tftp_address));
	push(@responses, ZipTie::Response->new('successfully tftp\'d', \&_finish));	

	# Sending "ptimg" command
	my $command = "ptcfg";
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

sub _specify_tftp_address
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error|nknown command|Enter hostname or IP address of TFTP server:', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('Enter name of file on TFTP server:', \&_specify_target_file));
	push(@responses, ZipTie::Response->new('successfully tftp\'d', \&_finish));	
	
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

sub _specify_target_file()
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error|nknown command|Enter hostname or IP address of TFTP server:|Enter name of file on TFTP server:', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('successfully tftp\'d', \&_finish));	

	# create the file in local computer
	my $command	 = escape_filename ( $cli_protocol->get_ip_address() ) . ".config";
	my $filepath = $tftp_file_server->get_root_dir() . "/$command";
	open (CFG_FILE,">$filepath");
	close (CFG_FILE);

	# Sending "ip.filname" as the target file name for the configuration.
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

sub _finish
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Retrieve the configuration file from the TFTP server
	my $config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".config";
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";

	# Open up the configuration file and read it into memory
	open(CONFIG, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file'!");
	my @entire_file = <CONFIG>;
	close(CONFIG);
	my $config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($config_file);

	# Add the contents of the active configuration to the ZipTie::Recording object
	my $interaction = ZipTie::Recording::Interaction->new(
		xferProtocol => 'FTP',
		xferResponse => $config_name,
	);

	$RECORDING->start_current_interaction($interaction);
	$RECORDING->finish_current_interaction();

	# Return the contents of the configuration
	return $config_contents;
}

1;

__END__