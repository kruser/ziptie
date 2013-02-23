package ZipTie::Adapters::Juniper::ScreenOS::Telemetry;

use strict;
use warnings;

use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Juniper::ScreenOS::AutoLogin;
use ZipTie::Adapters::Juniper::ScreenOS::Disconnect qw(disconnect);
use ZipTie::Adapters::Juniper::ScreenOS::Parsers qw(parse_arp parse_mac_table parse_telemetry_interfaces);
use ZipTie::Adapters::Utils qw(choose_admin_ip get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg               = shift;
	my $connectionPathDoc = shift;
	
	# setup work
	my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathDoc, 'connectionPath' );
	my $filehandle = get_model_filehandle( "ScreenOS", $connectionPath->get_ip_address() );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $responses = {};
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'telemetry');
	$printer->attributes(1);
	$printer->open_discovery_event();

	# Make a connection to device and get the data necessary to fill out the discovery event document 
	my $promptRegex = ZipTie::Adapters::Juniper::ScreenOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for('set console page 0', $promptRegex);
	$printer->open_element('neighbors');
	
	# process the ARP table
	$responses->{arp} = $cliProtocol->send_and_wait_for('get arp', $promptRegex);
	parse_arp($responses, $printer);
	delete $responses->{arp};

	# process the MAC address table 
	$responses->{mac} = $cliProtocol->send_and_wait_for('get mac-learn', $promptRegex);
	parse_mac_table($responses, $printer);
	delete $responses->{mac};

	$printer->close_element('neighbors');

	# process the interfaces and their status
	$responses->{interfaces} = $cliProtocol->send_and_wait_for('show interfaces', $promptRegex);
	#
	while ( $in->{interfaces} =~ /^\s*(\S+)\s+(?:[\da-f\.\:]+)\/\d+\s+\S+\s+(?:[\da-f\.\:\-]+)\s+\S+\s+(?:\S+)\s+\S+\s*$/mig )
	{
		$responses->{"if_counter_$1"} = $cliProtocol->send_and_wait_for("get counter statistics interface $1", $promptRegex);
	}
	my $interfacesHash = parse_telemetry_interfaces($responses, $printer);
	delete $responses->{interfaces};
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
