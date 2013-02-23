package ZipTie::Adapters::Extreme::Switch::Snmpcommunitychange;

use strict;
use warnings;

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
	my ( $connectionPath, $addCommunity, $removeCommunity ) =
	  ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );
	my $cliProtocol  = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex  = ZipTie::Adapters::Extreme::Switch::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $configPrompt = '#\s*$';
	my $response;
	if ( $addCommunity->{community} )
	{
		my $authorization = ( $addCommunity->{accessType} =~ /RW/i ) ? 'readwrite' : 'readonly';
		$response .= $cliProtocol->send_and_wait_for( 'configure snmp add community '.$authorization.' '.$addCommunity->{community}, $configPrompt );
	}

	if ( $removeCommunity->{community} )
	{
		my $authorization = ( $removeCommunity->{accessType} =~ /RW/i ) ? 'readwrite' : 'readonly';
		$response .= $cliProtocol->send_and_wait_for( "configure snmp delete community $authorization " . $removeCommunity->{community}, $configPrompt );
	}
	
	$response .=    $cliProtocol->send_and_wait_for('save config primary', 'database|overwrite it\? \(y\/n\)');
	$response .=    $cliProtocol->send_and_wait_for('y', $configPrompt, 300);
	$cliProtocol->send('exit');
	return $response;
}

1;
