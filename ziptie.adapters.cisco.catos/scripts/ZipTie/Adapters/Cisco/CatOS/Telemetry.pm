package ZipTie::Adapters::Cisco::CatOS::Telemetry;

use strict;
use warnings;

use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Cisco::CatOS::AutoLogin;
use ZipTie::Adapters::Cisco::CatOS::Disconnect qw(disconnect);
use ZipTie::Adapters::Cisco::CatOS::Parsers qw(parse_arp parse_cdp parse_mac_table parse_telemetry_interfaces);
use ZipTie::Adapters::Utils qw(choose_admin_ip get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg               = shift;
	my $connectionPathDoc = shift;

	# setup work
	my ($connectionPath, $discoveryParams) = ZipTie::Typer::translate_document( $connectionPathDoc, 'connectionPath' );
	my $filehandle = get_model_filehandle( "CatOS", $connectionPath->get_ip_address() );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $responses = {};
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'telemetry');
	$printer->attributes(1);
	$printer->open_discovery_event();

	# Make a connection to device and get the data necessary to fill out the discovery event document 
	my $promptRegex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for('set length 0', $promptRegex);
	$printer->open_element('neighbors');

	# process the ARP table
	$responses->{arp} = $cliProtocol->send_and_wait_for('show arp', $promptRegex);
	parse_arp($responses, $printer);
	delete $responses->{arp};

	# process the CDP neighbors
	$responses->{cdp} = $cliProtocol->send_and_wait_for('show cdp neighbors', $promptRegex);
	$responses->{cdp} .= $cliProtocol->send_and_wait_for('show cdp', $promptRegex);
	parse_cdp($responses, $printer);
	delete $responses->{cdp};

	# process the MAC address table 
	$responses->{mac} = $cliProtocol->send_and_wait_for('show cam dynamic', $promptRegex);
	parse_mac_table($responses, $printer);
	delete $responses->{mac};

	$printer->close_element('neighbors');

	# process the interfaces and their status
	$responses->{port_status} = $cliProtocol->send_and_wait_for('show port status', $promptRegex);
	$responses->{interface} = $cliProtocol->send_and_wait_for('show interface', $promptRegex);
	my ( $status_blob ) = $responses->{port_status} =~ /^[-\s]+^(.+)/imsg;
	while ( $status_blob =~ /^\s*(\S+)(?:\s+\S+)?\s+(\S+)\s+(\d+)\s+\S+\s+\S+\s+\S+\s+(?:No Connector|\S+)\s*$/mig )
	{
		$responses->{"port_counters_$1"} = $cliProtocol->send_and_wait_for("show counters $1", $promptRegex);
	}
	my $interfacesHash = parse_telemetry_interfaces($responses, $printer);
	delete $responses->{interface};
	delete $responses->{port_status};
	while ( ( my $key, my $value ) = each%{$responses} )
	{
		delete $responses->{$key};
	}

	my $adminIp    = $connectionPath->get_ip_address();
	if ( $discoveryParams->{calculateAdminIp} eq 'true' )
	{
		$adminIp = choose_admin_ip($connectionPath->get_ip_address(), $interfacesHash);
	}
	$printer->print_element( 'adminIp', $adminIp );
	$interfacesHash = 0;

	# tear down work
	$printer->close_element('DiscoveryEvent');
	close_model_filehandle($filehandle);
	disconnect($cliProtocol);
}

1;
