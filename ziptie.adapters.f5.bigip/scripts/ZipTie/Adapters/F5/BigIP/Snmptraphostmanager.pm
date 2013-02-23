package ZipTie::Adapters::F5::BigIP::Snmptraphostmanager;

use strict;
use warnings;

use ZipTie::Adapters::F5::BigIP::AutoLogin;
use ZipTie::Adapters::F5::BigIP::Disconnect qw(disconnect);
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $traphostName, $communityName, $traphostAction  ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::F5::BigIP::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response;

	my $trapHostPort	= 161;
	my $trapHostVersion	= 2;
	if ( $traphostName =~ /^\S+$/i )
	{
		if ( $traphostAction eq 'add' )
		{
			$response .= $cliProtocol->send_and_wait_for( "echo -e \"trapsess -v $trapHostVersion -c $communityName $traphostName:$trapHostPort\n\" >> /config/snmp/snmpd.conf", $promptRegex );
		}
		elsif ( $traphostAction eq 'delete' )
		{
			$response .= $cliProtocol->send_and_wait_for( "sed -e '/^trapsess[ ]*-v[ ]*[0-9][ ]*-c[ ]*[^ ]*[ ]*$traphostName/d' /config/snmp/snmpd.conf > /config/snmp/snmpd.conf.tmp", $promptRegex );
			$response .= $cliProtocol->send_and_wait_for( "mv -f /config/snmp/snmpd.conf.tmp /config/snmp/snmpd.conf", $promptRegex );
		}
	}
	disconnect($cliProtocol);
	return $response;
}

1;
