package ZipTie::Adapters::Cisco::SecurityAppliance::DeleteStaticRoute;

use strict;
use warnings;

use ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin;
use ZipTie::Adapters::Cisco::SecurityAppliance::Disconnect qw(disconnect);
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
	my $promptRegex			= ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'term pager 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response = $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	my $ifs		= $cliProtocol->send_and_wait_for( "show interface", $configPrompt );
	$response	.= $ifs;
	foreach my $key ( @{$staticRoutesHash} )
	{
		my ( $destAddress, $destMask, $gwAddress ) = ( $key->{destAddress}, $key->{destMask}, $key->{gwAddress} );
		while ( $ifs =~ /^Interface\s+\S+\s+"([^\s"]+)"\,\s+is\s+up\,\s+line\s+protocol\s+is\s+up/mig )
		{
			my $ifName = $1;
			$response .= $cliProtocol->send_and_wait_for( "no route $ifName $destAddress $destMask $gwAddress", $configPrompt );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( 'end', $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );

	disconnect($cliProtocol);

	return $response;
}

1;
