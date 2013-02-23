package ZipTie::Adapters::Juniper::JUNOS::Loginbanner;

use strict;
use warnings;
use MIME::Base64 'decode_base64';

use ZipTie::Adapters::Juniper::JUNOS::AutoLogin;
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $banner ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );
	$banner = decode_base64($banner);
	$banner =~ s/"//;
	my $cliProtocol  = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex  = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $configPrompt = '#\s*$';
	my $response     = $cliProtocol->send_and_wait_for( 'configure', $configPrompt );

	my @lines = split( /[\n\r]/, $banner );
	$response .= $cliProtocol->put( 'set system login message "', $configPrompt );
	foreach my $line (@lines)
	{
		chomp($line);
		$response .= $cliProtocol->put( $line . '\n' );
	}
	$response .= $cliProtocol->send( '"', $configPrompt );
	$response .= $cliProtocol->send_and_wait_for( 'commit', $configPrompt );
	$response .= $cliProtocol->send_and_wait_for( 'quit',   $promptRegex );
	$cliProtocol->send('exit');
	return $response;
}

1;
