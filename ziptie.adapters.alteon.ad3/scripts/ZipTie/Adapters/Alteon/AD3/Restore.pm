package ZipTie::Adapters::Alteon::AD3::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Alteon::AD3::AutoLogin;
use ZipTie::Adapters::Alteon::AD3::Disconnect qw(disconnect);
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

	# Disconnect from the specified device
	disconnect($cli_protocol);
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
	my $device_prompt_regex = ZipTie::Adapters::Alteon::AD3::AutoLogin::execute( $cli_protocol, $connection_path );
	
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
		# enter to cfg option
		$enable_prompt_regex =~ s/Main/Configuration/i;
		$cli_protocol->send_and_wait_for( 'cfg', $enable_prompt_regex );

		# restore the config
		restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
	}
	else
	{
		$LOGGER->fatal("Unable to restore Alteon AD3 config. Protocol TFTP is not available.");
	}
}

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push(@responses, ZipTie::Response->new('successfully tftp\'d', \&_finish));	
	push(@responses, ZipTie::Response->new('Enter hostname or IP address of TFTP server:', \&_specify_tftp_address));
	push(@responses, ZipTie::Response->new('Enter name of file on TFTP server:', \&_specify_source_file));
	push(@responses, ZipTie::Response->new('Timeout|File not found', undef, $TFTP_ERROR));

	$cliProtocol->send("gtcfg");
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ( $response )
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _specify_tftp_address
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");

	my @responses = ();
	push(@responses, ZipTie::Response->new('Enter name of file on TFTP server:', \&_specify_source_file));
	push(@responses, ZipTie::Response->new('successfully tftp\'d', \&_finish));	
	push(@responses, ZipTie::Response->new('Timeout|File not found|Enter hostname or IP address of TFTP server:', undef, $TFTP_ERROR));

	$cliProtocol->send( $tftpFileServer->get_ip_address() );
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _specify_source_file
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer	= $connectionPath->get_file_server_by_name("TFTP");
	my $configName		= escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile		= $tftpFileServer->get_root_dir() . "/$configName";

	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $promoteFile->get_blob();
	close( CONFIG_FILE );

	my @responses = ();
	push(@responses, ZipTie::Response->new('successfully tftp\'d', \&_finish));	
	push(@responses, ZipTie::Response->new('Timeout|File not found|Enter hostname or IP address of TFTP server:|Enter name of file on TFTP server:', undef, $TFTP_ERROR));

	$cliProtocol->send($configName);
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _finish
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer	= $connectionPath->get_file_server_by_name("TFTP");
	my $configName		= escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile		= $tftpFileServer->get_root_dir() . "/$configName";
	unlink($configFile);

	# exit from cfg option
	$promptRegex =~ s/Configuration/Main/i;
	$cliProtocol->send_and_wait_for( 'up', $promptRegex );

	# save and apply config
	$cliProtocol->send_and_wait_for( "save", 'Confirm saving without first applying' );
	$cliProtocol->send_and_wait_for( "y", 'Confirm saving to FLASH' );
	$cliProtocol->send_and_wait_for( "y", $promptRegex );
	$cliProtocol->send( "apply", $promptRegex );

	return 0;
}

1;
