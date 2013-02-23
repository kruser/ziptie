package ZipTie::Adapters::Juniper::JUNOS::ChangePassword;

use strict;
use warnings;

use ZipTie::Adapters::Juniper::JUNOS::AutoLogin;
use ZipTie::Adapters::Juniper::JUNOS::Disconnect qw(disconnect);
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
	my ( $connectionPath, $username, $newPassword ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'set cli screen-length 0', $promptRegex );
	my $configPrompt = '#\s*$';
	my $response = $cliProtocol->send_and_wait_for( 'configure', $configPrompt );

	$_	= $cliProtocol->send_and_wait_for( 'set system login user ?', $configPrompt );
	if ( $username =~ /^\S+$/i && $newPassword =~ /^\S+$/i )
	{
		if ( /^\s*$username\s+/mi )
		{
			$response .= $cliProtocol->send_and_wait_for( "set system login user $username authentication plain-text-password", 'New password:' );
			$response .= $cliProtocol->send_and_wait_for( "$newPassword", 'error:|Retype new password:' );
			if ( $response =~ /Retype new/mi )
			{
				$response .= $cliProtocol->send_and_wait_for( "$newPassword", 'error:|'.$configPrompt );
			}
		}
	}
	if ( $response !~ /error:/mi )
	{
		$response .= $cliProtocol->send_and_wait_for( 'commit', $configPrompt );
	}
	$response .= $cliProtocol->send_and_wait_for( 'exit', $promptRegex );

	disconnect($cliProtocol);

	return $response;
}

1;
