package ZipTie::Adapters::Cisco::CatOS::Loginbanner;

use strict;
use warnings;
use MIME::Base64 'decode_base64';

use ZipTie::Adapters::Cisco::CatOS::AutoLogin;
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
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	
	my $delimeter = ($banner !~ /!/) ? '!' : '$';
	my $response = $cliProtocol->send_and_wait_for( 'set banner motd '.$delimeter.''.$banner.''.$delimeter, $promptRegex );
	$cliProtocol->send('exit');
	return $response;
}

1;
