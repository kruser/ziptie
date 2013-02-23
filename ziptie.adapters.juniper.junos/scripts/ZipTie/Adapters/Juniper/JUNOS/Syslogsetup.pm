package ZipTie::Adapters::Juniper::JUNOS::Syslogsetup;

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
	my ( $connectionPath, $newHosts, $removeHosts ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $configPrompt = '#\s*$';
	my $response = $cliProtocol->send_and_wait_for( 'configure', $configPrompt );
	
	foreach my $server (keys %{$newHosts->{server}})
	{
		$response .= $cliProtocol->send_and_wait_for( 'edit system syslog host ' . $server. ' any', $configPrompt );
		$response .= $cliProtocol->send_and_wait_for( 'set any', $configPrompt );
		$response .= $cliProtocol->send_and_wait_for( 'top', $configPrompt );
	}
	
	foreach my $server (keys %{$removeHosts->{server}})
	{
		$response .= $cliProtocol->send_and_wait_for( 'delete system syslog host ' . $server, $configPrompt );
	}
	
	$response .= $cliProtocol->send_and_wait_for( 'commit', $configPrompt );
	$response .= $cliProtocol->send_and_wait_for( 'quit', $promptRegex );
	$cliProtocol->send('exit');
	return $response;
}

1;
