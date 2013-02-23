package ZipTie::Adapters::Argus::Cordex;

use strict;

use ZipTie::Adapters::Argus::Cordex::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::CLIProtocol;
use ZipTie::CLIProtocolFactory;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Logger;
use ZipTie::Model::XmlPrint;
use ZipTie::SNMP;
use ZipTie::SnmpSessionFactory;
use ZipTie::HTTP;
use ZipTie::Typer;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

sub backup
{
	my $packageName = shift;
	my $backupDoc   = shift;    # how to backup this device
	my $responses    = {};       # will contain device responses to be handed to the Parsers module

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ($connectionPath) = ZipTie::Typer::translate_document( $backupDoc, 'connectionPath' );

	# Grab the ZipTie::Credentials object from the connection path
	my $credentials = $connectionPath->get_credentials();

	# Grab the ZipTie::ConnectionPath::Protocol object that represents an HTTP/HTTPS protocol.
	# If the "HTTPS" is not specified, look for "HTTP"
	my $http_protocol = $connectionPath->get_protocol_by_name("HTTPS");
	$http_protocol = $connectionPath->get_protocol_by_name("HTTP") if (!defined($http_protocol));
	
	# If neither a HTTP or HTTPS protocol could be found, then that is fatal
	if ( !defined($http_protocol) )
	{
		$LOGGER->fatal("No 'HTTP' or 'HTTPS' protocol defined within the specified connection path!  Please make sure that either is 'HTTP' or 'HTTPS' protocol defined!");
	}
	
	# Create a new ZipTie::HTTP agent and connect to it using the information from the ZipTie::ConnectionPath
	# and ZipTie::Credentials objects.
	my $http_agent = ZipTie::HTTP->new();
	$http_agent->connect(
		$http_protocol->get_name(),
		$connectionPath->get_ip_address(),
		$http_protocol->get_port(),
		$credentials->{username},
		$credentials->{password},
	);
	
	# Set up the XmlPrint object for printing the ZiptieElementDocument (ZED)
	my $filehandle = get_model_filehandle( 'Cordex System Controller', $connectionPath->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Use HTTP/HTTPS to capture some data
	$responses->{'system_info'} = _issue_get($http_agent, 'sys_contactinfo.htm');
	$responses->{'version'} = _issue_get($http_agent, 'controller_live.htm');
	$responses->{'factory_info'} = _issue_get($http_agent, 'controller_info.htm');
	$responses->{'cards'} = _issue_get($http_agent, 'detinventory.xml');
	$responses->{'snmp_users'} = _issue_get($http_agent, 'snmp_community_string_setup.htm');
	$responses->{'config'} = _issue_get($http_agent, 'Config_Data.cfg');
	
	# Use SNMP to capture SNMP and Interface configurations
	my $snmpSession = ZipTie::SnmpSessionFactory->create($connectionPath);
	$responses->{snmp}       = ZipTie::Adapters::GenericAdapter::get_snmp($snmpSession);
	$responses->{interfaces} = ZipTie::Adapters::GenericAdapter::get_interfaces($snmpSession);
	$responses->{uptime} = _get_uptime($snmpSession);
	
	# Print out the model based on the HTTP and SNMP data we retrieved
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	create_config( $responses, $printer );
	parse_interfaces( $responses, $printer );
	parse_snmp( $responses, $printer );

	$printer->close_model();                # close out the ZiptieElementDocument
	close_model_filehandle($filehandle);    # Make sure to close the model file handle
}

sub _issue_get
{
	my $httpAgent = shift;
	my $command = shift;	
	
	$LOGGER->debug("======================================================");
	$LOGGER->debug("ISSUING GET REQUEST TO: $command");
	$LOGGER->debug("======================================================");
	my $resp = $httpAgent->get($command);
	$LOGGER->debug($resp);
	
	return $resp;
}

sub _issue_post
{
	my $httpAgent = shift;
	my $command = shift;	
	
	$LOGGER->debug("======================================================");
	$LOGGER->debug("ISSUING POST REQUEST TO: $command");
	$LOGGER->debug("======================================================");
	my $resp = $httpAgent->post($command);
	$LOGGER->debug($resp);
	
	return $resp;
}

sub _get_uptime
{

	# retrieve the sysUpTime via SNMP
	my $snmpSession = shift;

	$snmpSession->translate( [ '-timeticks' => 0, ] );    # turn off Net::SNMP translation of timeticks
	my $sysUpTimeOid = '.1.3.6.1.2.1.1.3.0';                              # the OID for sysUpTime
	my $getResult = ZipTie::SNMP::get( $snmpSession, [$sysUpTimeOid] );
	return $getResult->{$sysUpTimeOid};
}

1;
