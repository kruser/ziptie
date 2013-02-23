package ZipTie::Adapters::Nortel::Passport::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(escape_filename);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub execute
{
	my ( $connection_path, $cli_protocol, $enable_prompt_regex, $restoreFile ) = @_;

	# Check to see if either TFTP or SCP are supported
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );

	if ( defined($tftp_protocol) )
	{
		restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
	}
	else
	{
		$LOGGER->fatal("Unable to restore config.  Protocol TFTP is not available.");
	}    
}

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $tftpServerIP   = $tftpFileServer->get_ip_address();
	my $configName     = escape_filename($cliProtocol->get_ip_address() . ".config");
	my $configFile     = $tftpFileServer->get_root_dir() . "/$configName";

	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $promoteFile->get_blob();
	close(CONFIG_FILE);

	my @responses = ();
	push( @responses, ZipTie::Response->new( 'ERROR', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( 'already existing, overwrite \(y\/n\)', \&_confirm ) );
	push( @responses, ZipTie::Response->new( $promptRegex, \&_finish ) );

	$cliProtocol->send( "copy $tftpServerIP:$configName " . $promoteFile->get_path() );
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
	push( @responses, ZipTie::Response->new( 'ERROR', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( 'already existing, overwrite \(y\/n\)', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( $promptRegex, \&_finish ) );

	$cliProtocol->send("y");
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
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $configName     = escape_filename($cliProtocol->get_ip_address() . ".config");
	my $configFile     = $tftpFileServer->get_root_dir() . "/$configName";
	unlink($configFile);

	return 0;
}

1;
