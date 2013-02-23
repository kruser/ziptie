package ZipTie::Adapters::Cisco::CatOS::ChangePassword;

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
	my ( $connectionPath, $username, $newPassword ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $credentials = $connectionPath->get_credentials();
	my $oldPassword = $credentials->{password};
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response	= $cliProtocol->send_and_wait_for( 'set length 0', $promptRegex );

	if ( $username =~ /^\S+$/i && $newPassword =~ /^\S+$/i )
	{
		$response .= $cliProtocol->send_and_wait_for( "set password", 'old\s+password:' );
		$response .= $cliProtocol->send_and_wait_for( "$oldPassword ", 'new\s+password:|incorrect' );
		if ( $response =~ /new\s+password/mi )
		{
			$response .= $cliProtocol->send_and_wait_for( "$newPassword ", 'new\s+password:' );
			$response .= $cliProtocol->send_and_wait_for( "$newPassword ", $promptRegex );
		}
	}

	disconnect($cliProtocol);

	return $response;
}

1;
