package ZipTie::Adapters::Nortel::Passport1600::GetConfig;

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

	# Check to see if either TFTP is supported	
	my $tftp_protocol	= $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the configuration
	if ( defined($tftp_protocol) )
	{
		$response = _get_config_tftp($cli_protocol, $connection_path);
	}
	else
	{
		$LOGGER->fatal("Unable to backup without TFTP!");
	}

	# Return the configuration found
	return $response;
}

sub _get_config_tftp
{
	# Grab our ZipTie::CLIProtocol, ZipTie::ConnectionPath objects and the filename
	my $cli_protocol		= shift;
	my $connection_path 	= shift;

	# Get the prompt regex
	my $prompt_regex		= $cli_protocol->get_prompt_by_name("prompt");
	my $tftp_file_server	= $connection_path->get_file_server_by_name("TFTP");

	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Failure!', undef, $TFTP_ERROR));
	#push(@responses, ZipTie::Response->new('\.{70,}', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('Upload configuration.*Done\.', \&_finish));

	# Create the local file
	my $relative_filename = escape_filename($cli_protocol->get_ip_address() . ".config");
	my $filepath = $tftp_file_server->get_root_dir() . "/" . $relative_filename;
	open (CFG_FILE,">$filepath");
	close (CFG_FILE);

	# Get remote file
	# upload configuration ###.###.###.### ###.###.###.###.config
	my $command = "upload configuration " . $tftp_file_server->get_ip_address() . " $relative_filename";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses(\@responses, 180);

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
	my $filename		= $cli_protocol->get_ip_address().".config";

	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");

	# Retrieve the configuration file from the TFTP server
	my $config_file = $tftp_file_server->get_root_dir() . "/" . escape_filename( $filename );

	# Open up the configuration file and read it into memory
	open(CONFIG, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file'!");
	my @entire_file = <CONFIG>;
	close(CONFIG);
	my $config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($config_file);
	
	# Record the file transfer of the config
    # Arguments: protocol name, file name, response/contents
    $RECORDING->create_xfer_interaction($tftp_file_server->get_protocol(), $filename, $config_contents);
	
	# Return the contents of the configuration
	return $config_contents;
}

1;