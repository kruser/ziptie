package ZipTie::Adapters::Enterasys::SSR;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Enterasys::SSR::AutoLogin;
use ZipTie::Adapters::Enterasys::SSR::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Enterasys::SSR::Disconnect qw(disconnect);
use ZipTie::Adapters::Enterasys::SSR::GetConfig qw(get_config);
use ZipTie::Adapters::Enterasys::SSR::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;
use ZipTie::Adapters::GenericAdapter;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $packageName = shift;
	my $backupDoc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path, $credentials )	= ZipTie::Typer::translate_document( $backupDoc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex )		= _connect( $connection_path, $credentials );

	# Set up the XmlPrint object for printing the ZiptieElementDocument (ZED)
	my $filehandle = get_model_filehandle( 'Enterasys SSR Switch Routers', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$cli_protocol->send_and_wait_for( 'configure', '\(config\)#\s*$' );
	$cli_protocol->send_and_wait_for( 'system set terminal rows 0', '\(config\)#\s*$' );
	$cli_protocol->send_and_wait_for( 'exit', $prompt_regex );

	#$cli_protocol->set_more_prompt( '<SPACE>|-+ More -+', '20');

	$responses->{sys_contact}	= $cli_protocol->send_and_wait_for( 'system show contact', $prompt_regex );
	$responses->{sys_location}	= $cli_protocol->send_and_wait_for( 'system show location', $prompt_regex );
	$responses->{sys_name}		= $cli_protocol->send_and_wait_for( 'system show name', $prompt_regex );
	$responses->{uptime}		= $cli_protocol->send_and_wait_for( 'system show uptime', $prompt_regex );
	$responses->{version}		= $cli_protocol->send_and_wait_for( 'system show version', $prompt_regex );
	$responses->{hardware}		= $cli_protocol->send_and_wait_for( 'system show hardware', $prompt_regex );

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );

	delete $responses->{hardware};
	delete $responses->{uptime};
	delete $responses->{version};

	$responses->{'active-config'}	= get_config ( $cli_protocol, $connection_path, 'active' );
	$responses->{'startup-config'}	= get_config ( $cli_protocol, $connection_path, 'startup' );
	create_config( $responses, $printer );
	delete $responses->{'active-config'};
	delete $responses->{'startup-config'};

	#$responses->{interfaces}	= $cli_protocol->send_and_wait_for( 'interface show ip all', $prompt_regex );
	#$responses->{mau}			= $cli_protocol->send_and_wait_for( 'port show MAU all-ports', $prompt_regex );
	#$responses->{ports}			= $cli_protocol->send_and_wait_for( 'port show port-status all-ports', $prompt_regex );
	$cli_protocol->send( 'interface show ip all' );
	$responses->{interfaces} = $cli_protocol->get_response(0.25);
	$cli_protocol->send( 'port show MAU all-ports' );
	$responses->{mau} = $cli_protocol->get_response(0.25);
	$cli_protocol->send( 'port show port-status all-ports' );
	$responses->{ports} = $cli_protocol->get_response(0.25);
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	delete $responses->{mau};
	delete $responses->{ports};

	$responses->{snmp_community} = $cli_protocol->send_and_wait_for( 'snmp show community', $prompt_regex );
	#$cli_protocol->send( 'snmp show community' );
	#$responses->{snmp_community} = $cli_protocol->get_response(0.25);
	parse_snmp( $responses, $printer );
	delete $responses->{snmp_community};
	delete $responses->{sys_contact};
	delete $responses->{sys_location};
	delete $responses->{sys_name};

	$responses->{stp} = $cli_protocol->send_and_wait_for( 'stp show bridging-info', $prompt_regex );
	# validation shows a lot of errors because some stp info is not available
	#parse_stp( $responses, $printer );
	delete $responses->{stp};

	$responses->{route} = $cli_protocol->send_and_wait_for( 'ip show routes', $prompt_regex );
	parse_static_routes( $responses, $printer );
	delete $responses->{route};

	# close out the ZiptieElementDocument
	$printer->close_model();

	# Make sure to close the model file handle
	close_model_filehandle($filehandle);

	# Disconnect from the device
	disconnect($cli_protocol);
}

sub commands
{
	my $packageName = shift;
	my $commandDoc  = shift;

	my ( $connectionPath, $commands ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );
	my ( $cliProtocol, $devicePromptRegex ) = _connect($connectionPath);

	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'Enterasys SSR Switch Routers', $cliProtocol, $commands, $devicePromptRegex . '|(#|\$|>)\s*$' );
	disconnect($cliProtocol);
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
	my $devicePromptRegex = ZipTie::Adapters::Enterasys::SSR::AutoLogin::execute( $cliProtocol, $connectionPath );

	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cliProtocol->set_prompt_by_name( 'prompt', $devicePromptRegex );

	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cliProtocol, $devicePromptRegex );
}

1;
