package ZipTie::Adapters::Cisco::LocalDirector;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::BaseAdapter;
use ZipTie::Adapters::Cisco::LocalDirector::AutoLogin;
use ZipTie::Adapters::Cisco::LocalDirector::GetConfig qw(get_config);
use ZipTie::Adapters::Cisco::LocalDirector::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Cisco::LocalDirector::Disconnect
	qw(disconnect);
use ZipTie::Adapters::Cisco::LocalDirector::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;
	my $backup_doc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Local Director', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	# Get rid of the more prompt
	my $termLen = $cli_protocol->send_and_wait_for( "no pager", $prompt_regex );
	if ($termLen =~ /Type help or|Invalid|Command not valid/i)
	{
		# set the --more-- prompt if the term length 0 didn't go through
		$cli_protocol->set_more_prompt( '<--- More --->\s*$', '20');
	}

	$responses->{config}	= get_config($cli_protocol, $connection_path);
	$responses->{hw}		= $cli_protocol->send_and_wait_for( "show hw", $prompt_regex );
	$responses->{version}	= $cli_protocol->send_and_wait_for( "show version", $prompt_regex );
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{hw};
	delete $responses->{version};

  create_config( $responses, $printer );

	$responses->{interfaces} = $cli_protocol->send_and_wait_for( "show interface", $prompt_regex );
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};

	parse_local_accounts( $responses, $printer );

	parse_snmp( $responses, $printer );

	$responses->{routes} = $cli_protocol->send_and_wait_for( "show route", $prompt_regex );
	parse_static_routes( $responses, $printer );
	delete $responses->{routes};

	delete $responses->{config};

	# Disconnect from the device
	disconnect($cli_protocol);

	# close out the ZiptieElementDocument
	$printer->close_model();
	
	# Make sure to close the model file handle
	close_model_filehandle($filehandle);
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $device_prompt_regex ) = _connect( $connection_path );
	
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Local Director', $cli_protocol, $commands, '(#|\$|>)\s*$');
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
	my $device_prompt_regex = ZipTie::Adapters::Cisco::LocalDirector::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
