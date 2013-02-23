package ZipTie::Adapters::Cisco::CatOS::Portvlan;

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
	my $pkg = shift;
	my $doc = shift;

	# Initial connection
	my ( $connectionPath, $interfaces ) = ZipTie::Typer::translate_document( $doc, 'connectionPath' );
	my $interfacesHash = $interfaces->{interface};
	my $cliProtocol    = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex    = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );

	my $response;
	for my $intName ( sort keys %$interfacesHash )
	{
		my $vlan = $interfacesHash->{$intName}->{vlanNumber};
		$response .= $cliProtocol->send_and_wait_for( 'set vlan '. $vlan.' ' . $intName, $promptRegex );
	}
	disconnect($cliProtocol);
	return $response;
}

1;
