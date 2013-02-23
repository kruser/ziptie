package ZipTie::Adapters::Cisco::IOS::DeleteLocalAccount;

use strict;
use warnings;

use ZipTie::Adapters::Cisco::IOS::AutoLogin;
use ZipTie::Adapters::Cisco::IOS::Disconnect qw(disconnect);
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $username ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol	= ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex	= ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response     = $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	if ( $username =~ /^\S+$/i )
	{
		$response .= $cliProtocol->send_and_wait_for( "no username $username", $configPrompt );
	}
	$response .= $cliProtocol->send_and_wait_for( 'end',       $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );

	disconnect($cliProtocol);

	return $response;
}

1;
