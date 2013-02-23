package ZipTie::Adapters::Aruba::ArubaOS::GetConfig;

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

	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;

	# Check to see if either TFTP is supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the configuration
	if ( defined($tftp_protocol) )
	{
		$response = _get_config_tftp($cli_protocol, $connection_path, $filename);
	}

	# Otherwise, fall back to CLI protocol only
	else
	{
		$response = _get_config_cli($cli_protocol, $filename);
	}

	# Return the configuration found
	return $response;
}

sub _get_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol	= shift;
	my $filename		= shift;
	
	# Sending "show config all" command
	my $command = "show $filename";
	$cli_protocol->send( $command );
	
	# Fall back to matching '#'
	my $regex = '#\s*$';
	my $response = $cli_protocol->wait_for($regex, 120);

	# remove the prompt
	$response =~ s/^\S+ #\s*$//;

	# remove show command
	$response =~ s/^show $filename\s*//;

	# Return the configuration found
	return $response;
}

sub _get_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path	= shift;
	my $filename		= shift;

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('>|#', \&_finish));

	my $cfgFile	= escape_filename ( $cli_protocol->get_ip_address() ) . ".".$filename;
	create_empty_file($tftp_file_server->get_root_dir() . "/$cfgFile");
	
	# Sending "copy $configfile tftp: LocalHostIP DeviceIP.$configfile" command
	my $command	= "copy $filename tftp: ".$tftp_file_server->get_ip_address()." $cfgFile";
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
		return &$next_interaction($cli_protocol, $connection_path, $filename);
	}
}

sub _finish
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol	= shift;
	my $connection_path = shift;
	my $filename		= shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Retrieve the configuration file from the TFTP server
	my $config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".$filename";
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";

	# Open up the configuration file and read it into memory
	open(CONFIG, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file'!");
	my @entire_file = <CONFIG>;
	close(CONFIG);
	my $config_contents = join("", @entire_file);

	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($config_file);

	# Record the file transfer of the config
    # Arguments: protocol name, file name, response/contents
    $RECORDING->create_xfer_interaction( $tftp_file_server->get_protocol(), $connection_path->get_ip_address(), $config_contents );

	# Return the contents of the configuration
	return $config_contents;
}

1;

__END__