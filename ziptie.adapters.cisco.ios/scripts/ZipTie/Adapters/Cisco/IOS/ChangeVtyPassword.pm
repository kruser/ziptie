package ZipTie::Adapters::Cisco::IOS::ChangeVtyPassword;

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
	my ( $connectionPath, $newPassword ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );
	my $configPrompt	= '#\s*$';
	my $rconfig			= $cliProtocol->send_and_wait_for( 'show running-config', $promptRegex );
	my $response    	= $cliProtocol->send_and_wait_for( 'config term', $configPrompt );

	if ( $newPassword =~ /^\S+$/i )
	{
		# grab vty config
		my ( $vty_config ) = $rconfig =~ /^(line\s+vty\s+\d+\s+\d+.+?)!/mis;
		if ( $vty_config )
		{
			# reprint all the vty config but password line
			while ( $vty_config =~ /^(.+)$/mg )
			{
				$_ = $1;
				if ( $_ !~ /^password/i )
				{
					$response .= $cliProtocol->send_and_wait_for( "$_", $configPrompt );
				}
				else
				{
					$response .= $cliProtocol->send_and_wait_for( "password $newPassword", $configPrompt );
				}
			}
		}
		else
		{
			$response .= $cliProtocol->send_and_wait_for( "line vty 0 4", $configPrompt );
			$response .= $cliProtocol->send_and_wait_for( "password $newPassword", $configPrompt );
		}
	}

	$response .= $cliProtocol->send_and_wait_for( 'end',       $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( 'write mem', $promptRegex );

	disconnect($cliProtocol);

	return $response;
}

1;
