package ZipTie::Adapters::Cisco::SecurityAppliance::ChangeVtyPassword;

use strict;
use warnings;

use ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin;
use ZipTie::Adapters::Cisco::SecurityAppliance::Disconnect qw(disconnect);
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

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'term pager 0', $promptRegex );
	my $configPrompt	= '#\s*$';
	my $response		= $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	if ( $newPassword =~ /^\S+$/i )
	{
		$response .= $cliProtocol->send_and_wait_for( "passwd $newPassword", $configPrompt );
	}

	$response .= $cliProtocol->send_and_wait_for( 'end', $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );

	disconnect($cliProtocol);

	return $response;
}

1;
