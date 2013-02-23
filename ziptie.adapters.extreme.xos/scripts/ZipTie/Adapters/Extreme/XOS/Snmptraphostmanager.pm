package ZipTie::Adapters::Extreme::XOS::Snmptraphostmanager;

use strict;
use warnings;

use ZipTie::Adapters::Extreme::XOS::AutoLogin;
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $traphostName, $communityName, $traphostAction ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Extreme::XOS::AutoLogin::execute( $cliProtocol, $connectionPath );

	my $response = $cliProtocol->send_and_wait_for( 'disable clipaging', $promptRegex );
	$cliProtocol->set_more_prompt( 'Press <SPACE> to continue or <Q> to quit:', '20');
	$promptRegex =~ s/^\\\*\\\s+//;

	my $configRegex = '\*\s+'.$promptRegex;
	if ( $traphostName =~ /^\S+$/i )
	{
		if ( $traphostAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "configure snmp add trapreceiver $traphostName community $communityName", $configRegex );
		}
		elsif ( $traphostAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "configure snmp delete trapreceiver $traphostName", $configRegex );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( 'save', 'overwrite it\?' );
	$response .= $cliProtocol->send_and_wait_for( 'yes', $promptRegex );

	_disconnect($cliProtocol);

	return $response;
}

sub _disconnect
{
	# Grab the ZipTie::CLIProtocol object passed in
	my $cli_protocol = shift;

	# Close this session and exit
	$cli_protocol->send("exit");
}

1;
