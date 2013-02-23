package ZipTie::Adapters::Enterasys::VerticalHorizon::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Enterasys::VerticalHorizon::AutoLogin;
use ZipTie::Logger;
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
	my $device_prompt_regex = ZipTie::Adapters::Enterasys::VerticalHorizon::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'enablePrompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

sub execute
{
	my ($connection_path, $cli_protocol, $enable_prompt_regex, $restoreFile) = @_;

	# Check to see if TFTP is supported
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	if ( defined($tftp_protocol) )
	{
		restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
	}
	else
	{
		$LOGGER->fatal("Unable to restore VH config. Protocol TFTP is not available.");
	}
}

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer	= $connectionPath->get_file_server_by_name("TFTP");
	my $configName		= escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile		= $tftpFileServer->get_root_dir() . "/$configName";

	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $promoteFile->get_blob();
	close( CONFIG_FILE );

	# enter management setup menu
	$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow
	$cliProtocol->send_as_bytes('0D'); # enter
	
	# enter  configuration save & restore option
	for (1..5)
	{
		$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow
	}
	$cliProtocol->send_as_bytes('0D'); # enter

	$_ = $cliProtocol->get_response(0.25);
	if ( $_ !~ /Configuration Download/mi )
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

	# set cursor to Download Server IP field
	$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow
	$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow
	$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow

	# send tftp server ip
	$cliProtocol->send( $tftpFileServer->get_ip_address() );

	# set cursor to Download Filename field
	$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow

	# send config filename
	$cliProtocol->send( $configName );

	# set cursor to [Process TFTP Download] button
	$cliProtocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow

	$cliProtocol->send_as_bytes('0D'); # enter

	$_ = $cliProtocol->get_response(0.25);
	if ( /Do you want to continue/ )
	{
		$cliProtocol->send_as_bytes('59');
		for (1..100)
		{
			$_ = $cliProtocol->get_response(0.25);
			last if ( /\s*Complete/mi );
		}
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!\nConfirmation message was expected");
	}

	if ( /\s*Complete/mi )
	{
		return _finish( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("[$TFTP_ERROR]\nCouldn't restore the config!");
	}
}

sub _finish
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer	= $connectionPath->get_file_server_by_name("TFTP");
	my $configName		= escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile		= $tftpFileServer->get_root_dir() . "/$configName";
	unlink($configFile);

	return 0;
}

1;
