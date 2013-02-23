package ZipTie::Adapters::Extreme::Switch::Snmptraphostmanager;

use strict;
use warnings;

use ZipTie::Adapters::Extreme::Switch::AutoLogin;
use ZipTie::Adapters::Extreme::Switch::Disconnect qw(disconnect);
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
	my $promptRegex = ZipTie::Adapters::Extreme::Switch::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response;

	my $configRegex = '(?:\*\s+)?'.$promptRegex;
	if ( $traphostName =~ /^\S+$/i )
	{
		if ( $traphostAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "configure snmp add trapreceiver $traphostName community $communityName", $configRegex );
		}
		elsif ( $traphostAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "configure snmp delete trapreceiver $traphostName", $configRegex );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( 'save', 'Do you want to save' );
	$response .= $cliProtocol->send_and_wait_for( '!.!', $promptRegex, 150 );

	disconnect($cliProtocol);

	return $response;
}

1;
