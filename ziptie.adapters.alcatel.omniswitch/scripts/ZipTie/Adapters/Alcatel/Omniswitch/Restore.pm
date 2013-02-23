package ZipTie::Adapters::Alcatel::Omniswitch::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Alcatel::Omniswitch::AutoLogin;
use ZipTie::Logger;
use ZipTie::FTP;
use ZipTie::Adapters::Utils qw(escape_filename);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $package_name = shift;
	my $command_doc  = shift; # how to restore config

	# Initial connection
	my ( $connectionPath, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connectionPath );

	# Restore the config
	execute( $connectionPath, $cli_protocol, $prompt_regex, $restoreFile );

	# Disconnect from the specified device
	_disconnect($cli_protocol);
}

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the device
	my $device_prompt_regex = ZipTie::Adapters::Alcatel::Omniswitch::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'enablePrompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

sub _disconnect
{
	# Grab the ZipTie::CLIProtocol object passed in
	my $cli_protocol = shift;

	# Close this session and exit
	$cli_protocol->send("exit");
}

sub execute
{
	my ($connection_path, $cli_protocol, $enable_prompt_regex, $restoreFile) = @_;

	# Check to see if TFTP is supported
	my $ftp_protocol = $connection_path->get_protocol_by_name("FTP") if ( defined($connection_path) );

	if ( $restoreFile->get_path() =~ /config/i )
	{
		if ( defined($ftp_protocol) )
		{
			restore_via_ftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
		}
		else
		{
			$LOGGER->fatal("Unable to restore OMNISwtich config. Protocol FTP is not available.");
		}
	}
	else
	{
		$LOGGER->fatal( "Unable to promote this type of configuration '" . $restoreFile->get_path() . "'." );
	}
}

sub restore_via_ftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $ftpProtocol		= $connectionPath->get_file_server_by_name("FTP");
	my $configName		= escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile		= $ftpProtocol->get_root_dir() . "/$configName";

	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $promoteFile->get_blob();
	close( CONFIG_FILE );

	# Store the configuration file to the device
	my $ftpClient = ZipTie::TransferProtocolFactory::create( $connectionPath );
	$ftpClient->connect(	$connectionPath->get_ip_address(),
							$ftpClient->get_port(),
							$connectionPath->get_credential_by_name("username"),
							$connectionPath->get_credential_by_name("password"),
							0,
	 );

	$ftpClient->put( $configFile, $promoteFile->get_path() );
	$ftpClient->disconnect();

	return _finish( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
}

sub _finish
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $ftpProtocol		= $connectionPath->get_file_server_by_name("FTP");
	my $configName		= escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile		= $ftpProtocol->get_root_dir() . "/$configName";
	unlink($configFile);

	return 0;
}

1;
