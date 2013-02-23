package ZipTie::Adapters::Juniper::ScreenOS::Snmptraphostmanager;

use strict;
use warnings;

use ZipTie::Adapters::Juniper::ScreenOS::AutoLogin;
use ZipTie::Adapters::Juniper::ScreenOS::Disconnect qw(disconnect);
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
	my $promptRegex = ZipTie::Adapters::Juniper::ScreenOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response	= $cliProtocol->send_and_wait_for( 'set console page 0', $promptRegex );

	if ( $traphostName =~ /^\S+$/i )
	{
		if ( $traphostAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "set snmp host $communityName $traphostName", $promptRegex );
		}
		elsif ( $traphostAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "unset snmp host $communityName $traphostName", $promptRegex );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( 'save', $promptRegex );
	disconnect($cliProtocol);
	return $response;
}

1;
