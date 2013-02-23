package ZipTie::Adapters::Juniper::ScreenOS::NameServer;

use strict;
use warnings;

use ZipTie::Adapters::Juniper::ScreenOS::AutoLogin;
use ZipTie::Adapters::Juniper::ScreenOS::Disconnect qw(disconnect);
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
	my $promptRegex = ZipTie::Adapters::Juniper::ScreenOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response	= $cliProtocol->send_and_wait_for( 'set console page 0', $promptRegex );

	if ( $nsAddress =~ /^[\da-f\:\.]+$/i )
	{
		$_			= $cliProtocol->send_and_wait_for( "get dns host settings", $promptRegex );
		$response	.= $_;
		if ( $nsAction eq 'add' )
		{
			if ( /Primary\s+:\s+(\S+)/mi )
			{
				$response .= $cliProtocol->send_and_wait_for( "set dns host dns2 $1", $promptRegex );
				$response .= $cliProtocol->send_and_wait_for( "set dns host dns1 $nsAddress", $promptRegex );
			}
		}
		elsif ( $nsAction eq 'delete' )
		{
			if ( /Primary\s+:\s+(\S+)/mi )
			{
				$response .= $cliProtocol->send_and_wait_for( "set dns host dns2 $1", $promptRegex );
				$response .= $cliProtocol->send_and_wait_for( "set dns host dns1 0.0.0.0", $promptRegex );
			}
		}
	}
	if ( $domainSuffixName =~ /^[\da-z\.\-]+$/i )
	{
		$response .= $cliProtocol->send_and_wait_for( "set domain $domainSuffixName", $promptRegex );
	}
	$response .= $cliProtocol->send_and_wait_for( 'save', $promptRegex );
	disconnect($cliProtocol);
	return $response;
}

1;
