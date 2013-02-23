package ZipTie::Adapters::Cisco::IOS::Snmpcommunitychange;

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
	my ( $connectionPath, $addCommunity, $removeCommunity ) =
	  ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response     = $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	if ( $addCommunity->{community} )
	{
		$response .= $cliProtocol->send_and_wait_for( 'snmp-server community ' . $addCommunity->{community} . ' ' . $addCommunity->{accessType}, $configPrompt );
	}

	if ( $removeCommunity->{community} )
	{
		$response .= $cliProtocol->send_and_wait_for( 'no snmp-server community ' . $removeCommunity->{community}, $configPrompt ); }

	$response .= $cliProtocol->send_and_wait_for( 'end',       $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );
	disconnect($cliProtocol);
	return $response;
}

1;
