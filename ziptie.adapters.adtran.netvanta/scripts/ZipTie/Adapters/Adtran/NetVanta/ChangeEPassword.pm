package ZipTie::Adapters::Adtran::NetVanta::ChangeEPassword;

use strict;
use warnings;

use ZipTie::Adapters::Adtran::NetVanta::AutoLogin;
use ZipTie::Adapters::Utils qw(mask_to_bits);
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $newPassword ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol		= ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex		= ZipTie::Adapters::Adtran::NetVanta::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $configPrompt	= '#\s*$';
	my $response		= $cliProtocol->send_and_wait_for( 'configure terminal', $configPrompt );

	if ( $newPassword =~ /^\S+$/i )
	{
		$response .= $cliProtocol->send_and_wait_for( "enable password md5 $newPassword", $configPrompt );
	}

	$response .= $cliProtocol->send_and_wait_for( "exit", $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( "write memory", $promptRegex );

	_disconnect($cliProtocol);

	return $response;
}

sub _disconnect
{
	# Grab the ZipTie::CLIProtocol object passed in
	my $cli_protocol = shift;

	# Close this session and exit
	$cli_protocol->send("exit");
}

1;
