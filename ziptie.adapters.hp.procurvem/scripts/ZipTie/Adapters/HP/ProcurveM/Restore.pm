package ZipTie::Adapters::HP::ProcurveM::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::HP::ProcurveM::AutoLogin;
use ZipTie::Adapters::HP::ProcurveM::Disconnect
	qw(disconnect);
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

	# change terminal type
	$cli_protocol->turn_vt102_on(150,25); # set terminal size

	$cli_protocol->get_response(0.25);    # flush out the buffer

	$cli_protocol->send_as_bytes('35'); # enter to Diagnostics Menu
	$cli_protocol->send_as_bytes('34'); # enter to Command Prompt
	my $dv_prompt_regex = '(DEFAULT_VLAN:)|(-- MORE --)|Press RETURN when ready|Press RETURN when done';
	$cli_protocol->send_and_wait_for( "\n", $dv_prompt_regex ); # confirm Command Prompt

	$cli_protocol->send_and_wait_for( "page", $dv_prompt_regex ); # paging off

	$cli_protocol->turn_vt102_off();

	# Restore the config
	execute( $connectionPath, $cli_protocol, $dv_prompt_regex, $restoreFile );

	$cli_protocol->send( 'exit' ); # exit from command prompt
	$cli_protocol->send_as_bytes('30'); # exit to the main menu
	$cli_protocol->get_response(0.25);

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
	my $device_prompt_regex = ZipTie::Adapters::HP::ProcurveM::AutoLogin::execute( $cli_protocol, $connection_path );

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

	if ( $restoreFile->get_path() =~ /config/i )
	{
		if ( defined($tftp_protocol) )
		{
			restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
		}
		else
		{
			$LOGGER->fatal("Unable to restore Procurve config. Protocol TFTP is not available.");
		}
	}
	else
	{
		$LOGGER->fatal( "Unable to promote this type of configuration '" . $restoreFile->get_path() . "'." );
	}
}

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer	= $connectionPath->get_file_server_by_name("TFTP");
	my $configName		= escape_filename($cliProtocol->get_ip_address() . ".config");
	my $configFile		= $tftpFileServer->get_root_dir() . "/$configName";

	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $promoteFile->get_blob();
	close( CONFIG_FILE );

	my @responses = ();
	push(@responses, ZipTie::Response->new('[Ee]rror|[Ff]ail|Peer unreachable', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('do you want to continue', \&_confirm));
	push(@responses, ZipTie::Response->new('Validating and Writing Config to FLASH', \&_finish));

	$cliProtocol->send( "get ".$tftpFileServer->get_ip_address()." ".$promoteFile->get_path()." $configName" );
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

sub _confirm
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push(@responses, ZipTie::Response->new('[Ee]rror|[Ff]ail|Peer unreachable', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new("Validating and Writing Config to FLASH|$promptRegex", \&_finish));

	$cliProtocol->send_as_bytes( '79' );
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

sub _finish
{
	sleep(30); # when prompt regex is returned inmediatly after confirming tftp upload so we gonna sleep for 30 seconds and then delete the file

	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer	= $connectionPath->get_file_server_by_name("TFTP");
	my $configName		= escape_filename($cliProtocol->get_ip_address() . ".config");
	my $configFile		= $tftpFileServer->get_root_dir() . "/$configName";
	unlink($configFile);

	return 0;
}

1;
