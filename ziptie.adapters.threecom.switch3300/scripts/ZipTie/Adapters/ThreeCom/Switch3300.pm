package ZipTie::Adapters::ThreeCom::Switch3300;

use strict;

use ZipTie::Adapters::ThreeCom::Switch3300::AutoLogin;
use ZipTie::Adapters::ThreeCom::Switch3300::Disconnect qw(disconnect);
use ZipTie::Adapters::ThreeCom::Switch3300::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;

use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;

use ZipTie::SNMP;
use ZipTie::SnmpSessionFactory;
use ZipTie::Typer;

#use Data::Dumper;


# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;
	my $backup_doc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'ThreeCom Switch', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};
	
	# The initial adapter makes use of SNMP to gather well known pieces of information
	# such as the system uptime, the system name and interface layer 2 and 3 addresses.
	my $snmpSession = ZipTie::SnmpSessionFactory->create($connection_path);
	
	
	$responses->{'system'} = $cli_protocol->send_and_wait_for( 'system display', $prompt_regex );
	
	parse_system( $responses, $printer );

	parse_chassis( $responses, $printer );

	delete $responses->{'system'};
	
	create_config( $responses, $printer );
	
	$responses->{interfaces} = ZipTie::Adapters::GenericAdapter::get_interfaces($snmpSession);
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};

	$responses->{users} = $cli_protocol->send_and_wait_for( 'system security user display', $prompt_regex );
	parse_local_accounts( $responses, $printer );
	delete $responses->{users};

	$responses->{snmp}       = ZipTie::Adapters::GenericAdapter::get_snmp($snmpSession);
	parse_snmp( $responses, $printer );
	delete $responses->{snmp};

	$responses->{stp} = $cli_protocol->send_and_wait_for( 'bridge display', $prompt_regex );
	parse_stp( $responses, $printer );
	delete $responses->{stp};
	
	my $vlans = $cli_protocol->send_and_wait_for( 'bridge vlan summary all', $prompt_regex );
	while ($vlans =~  /\s*(\d+)\s+\S+\s+(.+)$/mig)
	{
		my $id = $1;	
		$responses->{vlan}->{$id} = $cli_protocol->send_and_wait_for( "bridge vlan detail $id" , $prompt_regex);	
	}
	parse_vlans( $responses, $printer );
	delete $responses->{vlan};

	# close out the ZiptieElementDocument
	$printer->close_model();

	# Make sure to close the model file handle
	close_model_filehandle($filehandle);

	# Disconnect from the device
	disconnect($cli_protocol);
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $device_prompt_regex ) = _connect( $connection_path );
	
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('ThreeCom Switch', $cli_protocol, $commands, '(#|\$|>)\s*$');
	disconnect($cli_protocol);
	return $result;
}

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the device
	my $device_prompt_regex = ZipTie::Adapters::ThreeCom::Switch3300::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
