package ZipTie::Adapters::Cisco::CatOS::Snmpcommunitychange;

use strict;
use warnings;

use ZipTie::Adapters::Cisco::CatOS::AutoLogin;
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
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );

	my $response;
	
	if ( $removeCommunity->{community} )
	{
		$response .= "\n**** The community string '".$removeCommunity->{community}."' can be removed by being overwritten. ****\n\n";
	}
	
	if ( $addCommunity->{community} )
	{
		my $accessType = ( $addCommunity->{accessType} =~ /ro/i )? 'read-only' : 'read-write'; 
		$response .= $cliProtocol->send_and_wait_for( 'set snmp community '.$accessType.' '. $addCommunity->{community}, $promptRegex );
	}


	$cliProtocol->send('exit');
	return $response;
}

1;
