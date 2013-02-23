package ZipTie::Adapters::Juniper::ScreenOS::DeleteStaticRoute;

use strict;
use warnings;

use ZipTie::Adapters::Juniper::ScreenOS::AutoLogin;
use ZipTie::Adapters::Juniper::ScreenOS::Disconnect qw(disconnect);
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
	my $cliProtocol 		= ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex			= ZipTie::Adapters::Juniper::ScreenOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response			= $cliProtocol->send_and_wait_for( 'set console page 0', $promptRegex );

	my $ifs		= $cliProtocol->send_and_wait_for( "get interface", $promptRegex );
	$response	.= $ifs;
	foreach my $key ( @{$staticRoutesHash} )
	{
		my ( $destAddress, $destMask, $gwAddress ) = ( $key->{destAddress}, $key->{destMask}, $key->{gwAddress} );
		$destMask = mask_to_bits( $destMask );
		while ( $ifs =~ /^(\S+)\s+\d+\..+$/mig )
		{
			my $ifName = $1;
			$response .= $cliProtocol->send_and_wait_for( "unset route $destAddress/$destMask interface $ifName gateway $gwAddress", $promptRegex );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( 'save', $promptRegex );

	disconnect($cliProtocol);

	return $response;
}

1;
