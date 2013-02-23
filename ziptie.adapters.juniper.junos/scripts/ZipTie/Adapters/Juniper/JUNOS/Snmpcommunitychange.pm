package ZipTie::Adapters::Juniper::JUNOS::Snmpcommunitychange;

use strict;
use warnings;

use ZipTie::Adapters::Juniper::JUNOS::AutoLogin;
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
	my $cliProtocol  = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex  = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $configPrompt = '#\s*$';
	my $response     = $cliProtocol->send_and_wait_for( 'configure', $configPrompt );

	if ( $addCommunity->{community} )
	{
		my $authorization = ( $addCommunity->{accessType} =~ /RW/i ) ? 'read-write' : 'read-only';
		$response .=
		  $cliProtocol->send_and_wait_for(
			'set snmp community ' . $addCommunity->{community} . ' authorization ' . $authorization,
			$configPrompt );
	}

	if ( $removeCommunity->{community} )
	{
		$response .=
		  $cliProtocol->send_and_wait_for( 'delete snmp community ' . $removeCommunity->{community}, $configPrompt );
	}

	$response .= $cliProtocol->send_and_wait_for( 'commit', $configPrompt );
	$response .= $cliProtocol->send_and_wait_for( 'quit',   $promptRegex );
	$cliProtocol->send('exit');
	return $response;
}

1;
