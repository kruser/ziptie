package ZipTie::Adapters::Cisco::IOS::NameServer;

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
	my ( $connectionPath, $nsAddress, $nsAction, $domainSuffixName ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response = $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	if ( $nsAddress =~ /^[\da-f\:\.]+$/i )
	{
		if ( $nsAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "ip name-server $nsAddress", $configPrompt );
		}
		elsif ( $nsAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "no ip name-server $nsAddress", $configPrompt );
		}
	}
	if ( $domainSuffixName =~ /^[\da-z\.\-]+$/i )
	{
		$response .= $cliProtocol->send_and_wait_for( "ip domain-name $domainSuffixName", $configPrompt );
	}
	$response .= $cliProtocol->send_and_wait_for( 'end', $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );
	disconnect($cliProtocol);
	return $response;
}

1;
