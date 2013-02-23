package ZipTie::Adapters::Alcatel::Omniswitch;

use strict;

use ZipTie::Adapters::Alcatel::Omniswitch::AutoLogin;
use ZipTie::Adapters::Alcatel::Omniswitch::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Alcatel::Omniswitch::Restore;

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
use ZipTie::Typer;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $packageName = shift;
	my $backupDoc   = shift;    # how to backup this device
	my $responses    = {};       # will contain device responses to be handed to the Parsers module

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ($connectionPath) = ZipTie::Typer::translate_document( $backupDoc, 'connectionPath' );

	# Set up the XmlPrint object for printing the ZiptieElementDocument (ZED)
	my $filehandle = get_model_filehandle( 'Alcatel-Lucent Omniswitch', $connectionPath->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# The initial adapter makes use of SNMP to gather well known pieces of information
	# such as the system uptime, the system name and interface layer 2 and 3 addresses.
	my $snmpSession = ZipTie::SnmpSessionFactory->create($connectionPath);
	$responses->{snmp}       = ZipTie::Adapters::GenericAdapter::get_snmp($snmpSession);
	$responses->{interfaces} = ZipTie::Adapters::GenericAdapter::get_interfaces($snmpSession);

	# Make a Telnet or SSH connection
	my ( $cliProtocol, $promptRegex ) = _connect($connectionPath);
	$cliProtocol->send_and_wait_for( 'uic', 'Redraw\)\s*:');
	$cliProtocol->send_and_wait_for( '2=off', 'Redraw\)\s*:');
	$cliProtocol->send_and_wait_for( 'save', $promptRegex);

	$responses->{info} = $cliProtocol->send_and_wait_for( 'info', $promptRegex );
	$responses->{slot} = $cliProtocol->send_and_wait_for( 'slot', $promptRegex );
	$responses->{uptime} = _get_uptime($snmpSession);
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	
	$cliProtocol->send_and_wait_for( 'cli', '->\s*$');
	$cliProtocol->send_and_wait_for( 'dump all file apconfig', '->\s*$', 60);
	$cliProtocol->send_and_wait_for( 'exit', $promptRegex);
	$cliProtocol->send_and_wait_for( 'file', '%\s*$');
	$responses->{config} = $cliProtocol->send_and_wait_for( 'view apconfig', '%\s*$');
	create_config( $responses, $printer );
	parse_interfaces( $responses, $printer );
	parse_snmp( $responses, $printer );

	_disconnect($cliProtocol);
	$printer->close_model();                # close out the ZiptieElementDocument
	close_model_filehandle($filehandle);    # Make sure to close the model file handle
}

sub commands
{
	my $packageName = shift;
	my $commandDoc  = shift;

	my ( $connectionPath, $commands ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );
	my ( $cliProtocol, $devicePromptRegex ) = _connect($connectionPath);

	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'Alcatel-Lucent Omniswitch', $cliProtocol, $commands, $devicePromptRegex . '|(#|\$|>)\s*$' );
	_disconnect($cliProtocol);
	return $result;
}

sub _connect
{

	# Grab our arguments
	my $connectionPath = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);

	# Make a connection to and successfully authenticate with the device
	my $devicePromptRegex = ZipTie::Adapters::Alcatel::Omniswitch::AutoLogin::execute( $cliProtocol, $connectionPath );

	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cliProtocol->set_prompt_by_name( 'prompt', $devicePromptRegex );

	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cliProtocol, $devicePromptRegex );
}

sub _disconnect
{

	# Grab the ZipTie::CLIProtocol object passed in
	my $cliProtocol = shift;

	# Close this session and exit
	$cliProtocol->send("exit");
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
