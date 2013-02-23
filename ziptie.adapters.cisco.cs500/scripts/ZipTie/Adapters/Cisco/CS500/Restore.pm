package ZipTie::Adapters::Cisco::CS500::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Cisco::CS500::AutoLogin;
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
	my $device_prompt_regex = ZipTie::Adapters::Cisco::CS500::AutoLogin::execute( $cli_protocol, $connection_path );
	
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
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	if ( defined($tftp_protocol) )
	{
		restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
	}
	else
	{
		$LOGGER->fatal("Unable to restore CS500 config. Protocol TFTP is not available.");
	}
}

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Hh]ost or network',							\&_send_host ) );
	push( @responses, ZipTie::Response->new( '[Aa]ddress of remote host',					\&_send_tftp_ip ) );
	push( @responses, ZipTie::Response->new( '[Nn]ame of configuration file',				\&_send_source_filename ) );
	push( @responses, ZipTie::Response->new( '\[confirm\]',									\&_confirm ) );
	push( @responses, ZipTie::Response->new( 'timed out|File not found|[Ee]rror|[Ff]ail',	undef, $TFTP_ERROR ) );

	$cliProtocol->send( "configure network" );
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

sub _send_host
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Aa]ddress of remote host',					\&_send_tftp_ip ) );
	push( @responses, ZipTie::Response->new( '[Nn]ame of configuration file',				\&_send_source_filename ) );
	push( @responses, ZipTie::Response->new( '\[confirm\]',									\&_confirm ) );
	push( @responses, ZipTie::Response->new( 'timed out|File not found|[Ee]rror|[Ff]ail|[Hh]ost or network', undef, $TFTP_ERROR ) );

	$cliProtocol->send( "host" );
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

sub _send_tftp_ip
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");

	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Nn]ame of configuration file',				\&_send_source_filename ) );
	push( @responses, ZipTie::Response->new( '\[confirm\]',									\&_confirm ) );
	push( @responses, ZipTie::Response->new( 'timed out|File not found|[Ee]rror|[Ff]ail|[Hh]ost or network|[Aa]ddress of remote host', undef, $TFTP_ERROR ) );

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

sub _send_source_filename
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
	push( @responses, ZipTie::Response->new( '\[confirm\]',									\&_confirm ) );
	push( @responses, ZipTie::Response->new( 'timed out|File not found|[Ee]rror|[Ff]ail|[Hh]ost or network|[Aa]ddress of remote host|[Nn]ame of configuration file', undef, $TFTP_ERROR ) );

	$cliProtocol->send( $configName );
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

sub _confirm
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push( @responses, ZipTie::Response->new( $promptRegex, \&_finish ) );
	push( @responses, ZipTie::Response->new( 'timed out|File not found|[Ee]rror|[Ff]ail|[Hh]ost or network|[Aa]ddress of remote host|[Nn]ame of configuration file|\[confirm\]', undef, $TFTP_ERROR ) );

	$cliProtocol->send( "y" );
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

	return 0;
}

1;
