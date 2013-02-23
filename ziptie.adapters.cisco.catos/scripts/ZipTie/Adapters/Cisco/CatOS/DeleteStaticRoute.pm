package ZipTie::Adapters::Cisco::CatOS::DeleteStaticRoute;

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
	my ( $connectionPath, $staticRoutes ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );
	my $staticRoutesHash	= $staticRoutes->{staticRoute};
	my $cliProtocol			= ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex			= ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response			= $cliProtocol->send_and_wait_for( 'set length 0', $promptRegex );

	foreach my $key ( @{$staticRoutesHash} )
	{
		my ( $destAddress, $destMask, $gwAddress ) = ( $key->{destAddress}, $key->{destMask}, $key->{gwAddress} );
		$destMask = mask_to_bits( $destMask );
		$response .= $cliProtocol->send_and_wait_for( "clear ip route $destAddress $gwAddress", $promptRegex );
	}

	disconnect($cliProtocol);

	return $response;
}

1;
