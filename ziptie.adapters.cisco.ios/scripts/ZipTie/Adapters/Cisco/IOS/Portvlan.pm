package ZipTie::Adapters::Cisco::IOS::Portvlan;

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
	my $pkg = shift;
	my $doc = shift;

	# Initial connection
	my ( $connectionPath, $interfaces ) = ZipTie::Typer::translate_document( $doc, 'connectionPath' );
	my $interfacesHash = $interfaces->{interface};
	my $cliProtocol    = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex    = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response     = $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	for my $intName ( sort keys %$interfacesHash )
	{
		my $vlan = $interfacesHash->{$intName}->{vlanNumber};
		$response .= $cliProtocol->send_and_wait_for( 'interface ' . $intName, $configPrompt );
		$response .= $cliProtocol->send_and_wait_for( 'switchport access vlan '.$vlan, $configPrompt );
	}

	$response .= $cliProtocol->send_and_wait_for( 'end',       $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );
	disconnect($cliProtocol);
	return $response;
}

1;
