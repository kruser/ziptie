package ZipTie::Adapters::Cisco::CatOS::AddStaticRoute;

use strict;
use warnings;

use ZipTie::Adapters::Cisco::CatOS::AutoLogin;
use ZipTie::Adapters::Cisco::CatOS::Disconnect qw(disconnect);
use ZipTie::Adapters::Utils qw(mask_to_bits);
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $destAddress, $destMask, $gwAddress ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response	= $cliProtocol->send_and_wait_for( 'set length 0', $promptRegex );

	if ( $destAddress =~ /^\S+$/i && $destMask =~ /^\S+$/i && $gwAddress =~ /^\S+$/i )
	{
		$destMask = mask_to_bits( $destMask );
		$response .= $cliProtocol->send_and_wait_for( "set ip route $destAddress/$destMask $gwAddress", $promptRegex );
	}

	disconnect($cliProtocol);

	return $response;
}

1;
