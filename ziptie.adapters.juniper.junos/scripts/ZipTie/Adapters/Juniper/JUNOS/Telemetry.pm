package ZipTie::Adapters::Juniper::JUNOS::Telemetry;

use strict;
use warnings;

use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Juniper::JUNOS::AutoLogin;
use ZipTie::Adapters::Juniper::JUNOS::Disconnect qw(disconnect);
use ZipTie::Adapters::Juniper::JUNOS::Parsers qw(parse_arp parse_telemetry_interfaces parse_routing_neighbors parse_discovery_neighbors);
use ZipTie::Adapters::Utils qw(choose_admin_ip get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg               = shift;
	my $connectionPathDoc = shift;
	
	# setup work
	my ($connectionPath, $discoveryParams) = ZipTie::Typer::translate_document( $connectionPathDoc, 'connectionPath' );
	my $filehandle = get_model_filehandle( "JunOS", $connectionPath->get_ip_address() );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $responses = {};
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'telemetry');
	$printer->attributes(1);
	$printer->open_discovery_event();

	# Make a connection to device and get the data necessary to fill out the discovery event document 
	my $promptRegex = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for('set cli screen-length 0', $promptRegex);
	$printer->open_element('neighbors');
	
	# process the ARP table
	$responses->{arp} = $cliProtocol->send_and_wait_for('show arp no-resolve', $promptRegex);
	parse_arp($responses, $printer);
	delete $responses->{arp};
	
	# process the routing neighbors
	$responses->{ospf} = $cliProtocol->send_and_wait_for('show ospf neighbor', $promptRegex);
	$responses->{rip} = $cliProtocol->send_and_wait_for('show rip neighbor', $promptRegex);
	$responses->{bgp} = $cliProtocol->send_and_wait_for('show bgp neighbor', $promptRegex);
	parse_routing_neighbors($responses, $printer);
	delete $responses->{ospf};
	delete $responses->{rip};
	delete $responses->{bgp};
	
	$responses->{ndp} = $cliProtocol->send_and_wait_for('show ipv6 neighbors', $promptRegex);
	parse_discovery_neighbors($responses, $printer);
	delete $responses->{ndp};
	
	$printer->close_element('neighbors');
	
	# process the interfaces and their status
	$responses->{interfaces} = $cliProtocol->send_and_wait_for('show interfaces | display xml', $promptRegex);
	my $interfacesHash = parse_telemetry_interfaces($responses, $printer);
	delete $responses->{interfaces};
	
	my $adminIp    = $connectionPath->get_ip_address();
	if ( $discoveryParams->{calculateAdminIp} eq 'true' )
	{
		$adminIp = choose_admin_ip($connectionPath->get_ip_address(), $interfacesHash);
	}
	$printer->print_element( 'adminIp', $adminIp );
	
	# tear down work
	$printer->close_element('DiscoveryEvent');
	close_model_filehandle($filehandle);
	disconnect($cliProtocol);
}

1;
