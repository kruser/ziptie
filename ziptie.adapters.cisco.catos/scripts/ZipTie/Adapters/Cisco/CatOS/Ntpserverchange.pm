package ZipTie::Adapters::Cisco::CatOS::Ntpserverchange;

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
	my ( $connectionPath, $newHosts, $removeHosts ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );
	my $response = $cliProtocol->last_match;
	foreach my $server (keys %{$newHosts->{server}})
	{
		$response .= $cliProtocol->send_and_wait_for( 'set ntp server '.$server, $promptRegex );
	}
	
	foreach my $server (keys %{$removeHosts->{server}})
	{
		$response .= $cliProtocol->send_and_wait_for( 'clear ntp server '.$server, $promptRegex );
	}
	$cliProtocol->send('exit');
	return $response;
}

1;
