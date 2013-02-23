package ZipTie::Adapters::Cisco::CatOS::Snmptraphostmanager;

use strict;
use warnings;

use ZipTie::Adapters::Cisco::CatOS::AutoLogin;
use ZipTie::Adapters::Cisco::CatOS::Disconnect qw(disconnect);
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
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response	= $cliProtocol->send_and_wait_for( 'set length 0', $promptRegex );

	if ( $traphostName =~ /^\S+$/i )
	{
		if ( $traphostAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "set snmp trap $traphostName $communityName", $promptRegex );
		}
		elsif ( $traphostAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "clear snmp trap $traphostName", $promptRegex );
		}
	}
	disconnect($cliProtocol);
	return $response;
}

1;
