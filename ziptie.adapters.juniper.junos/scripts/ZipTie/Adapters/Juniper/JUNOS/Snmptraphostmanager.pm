package ZipTie::Adapters::Juniper::JUNOS::Snmptraphostmanager;

use strict;
use warnings;

use ZipTie::Adapters::Juniper::JUNOS::AutoLogin;
use ZipTie::Adapters::Juniper::JUNOS::Disconnect qw(disconnect);
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $traphostName, $communityName, $traphostAction ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'set cli screen-length 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response = $cliProtocol->send_and_wait_for( 'configure', $configPrompt );

	if ( $traphostName =~ /^\S+$/i )
	{
		if ( $traphostAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "set snmp trap-group $communityName targets $traphostName", $configPrompt );
		}
		elsif ( $traphostAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "delete snmp trap-group $communityName", $configPrompt );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( 'commit', $configPrompt );
	$response .= $cliProtocol->send_and_wait_for( 'exit', $promptRegex );
	disconnect($cliProtocol);
	return $response;
}

1;
