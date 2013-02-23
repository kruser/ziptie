package ZipTie::Adapters::Extreme::Switch::Loginbanner;

use strict;
use warnings;
use MIME::Base64 'decode_base64';

use ZipTie::Adapters::Extreme::Switch::AutoLogin;
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
	$banner =~ s/^\s*$//m;
	my $cliProtocol  = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex  = ZipTie::Adapters::Extreme::Switch::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $configPrompt = '#\s*$';

	my $response;
	$response .= $cliProtocol->send('configure banner');
	$response .= $cliProtocol->send($banner);
	$response .= $cliProtocol->send('');                                                 # empty line ends the banner
	$response .= $cliProtocol->send_and_wait_for( 'save config primary', 'database|overwrite it\? \(y\/n\)' );
	$response .= $cliProtocol->send_and_wait_for( 'y', $configPrompt, 300 );
	$cliProtocol->send('exit');
	return $response;
}

1;
