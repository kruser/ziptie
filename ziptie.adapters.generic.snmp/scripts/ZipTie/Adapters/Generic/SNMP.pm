package ZipTie::Adapters::Generic::SNMP;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::BaseAdapter;
use ZipTie::Adapters::Generic::SNMP::Parsers
  qw(parse_chassis parse_system create_config);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;
use ZipTie::SnmpSessionFactory;
use Data::Dumper;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;
	my $backup_doc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ($connection_path) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Grab the ZipTie::Credentials object from the connection path
	my $credentials = $connection_path->get_credentials();

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Generic', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();
	my $responses = {};

	# Create a Net::SNMP session
	my $snmp_session = ZipTie::SnmpSessionFactory->create( $connection_path, $credentials );

	$responses->{snmp} = ZipTie::Adapters::GenericAdapter::get_snmp($snmp_session);
	
	
	# Gather the system uptime
	$snmp_session->translate(['-timeticks' => 0,]);
	my $sysUpTimeOid = '.1.3.6.1.2.1.1.3.0';
	my $getResult = ZipTie::SNMP::get($snmp_session, [$sysUpTimeOid]);
	$responses->{uptime} = $getResult->{$sysUpTimeOid};
	
	parse_system($responses, $printer);
	parse_chassis($responses, $printer);
	create_config($responses, $printer);

	$printer->print_element( 'interfaces', ZipTie::Adapters::GenericAdapter::get_interfaces($snmp_session) );
	$printer->print_element( 'snmp',       $responses->{snmp} );
	$printer->close_model();

	# Make sure to close the model file handle
	close_model_filehandle($filehandle);

}

1;
