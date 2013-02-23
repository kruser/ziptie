package ZipTie::Adapters::Cisco::VxWorks;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::HTTP;
use ZipTie::Adapters::Cisco::VxWorks::AutoLogin;
use ZipTie::Adapters::Cisco::VxWorks::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;

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

	# Grab the ZipTie::Credentials object from the connection path
	my $credentials = $connection_path->get_credentials();

	# Grab the ZipTie::ConnectionPath::Protocol object that represents an HTTP/HTTPS protocol.
	my $http_protocol = $connection_path->get_protocol_by_name("HTTPS");
	$http_protocol = $connection_path->get_protocol_by_name("HTTP") if ( !defined($http_protocol) );

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
		$connection_path->get_ip_address(),
		$http_protocol->get_port(),
		$credentials->{username},
		$credentials->{password},
	);

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Cisco VxWorks', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$responses->{home} = $http_agent->get("");
	$responses->{snmp} = $http_agent->get("SetSNMP.shm");

	$_ = $http_agent->get("SetConfiguration.shm");
	if ( /<a href="\/?([^"]+)">Download <b>All<\/b> System Configuration/ )
	{
		$responses->{config} = $http_agent->get($1);
	}

	$responses->{users}		= $http_agent->get("ShowUsers.shm");
	$responses->{routes}	= $http_agent->get("SetRouting.shm");

	my ( $if_blob ) = $responses->{home} =~ /Network Ports(.+)\[Home\]/mis;
	while ( $if_blob =~ /<[^>]+><a\s+href="\/?([^"]+)">([^<]+)/mig )
	{
		$_ = $1;
		if ( /ifIndex=(\d+)/i )
		{
			my $if_id = $1;
			$responses->{'ifs'.$if_id} = $http_agent->get($_);
		}
	}

	$responses->{setup} = $http_agent->get("Setup.shm");
	while ( $responses->{setup} =~ /<a href="\/?([^"\s]+)">Identification<\/a>/mig )
	{
		$_ = $1;
		if ( /ifIndex=(\d+)/i )
		{
			my $if_id = $1;
			$responses->{'ifi'.$if_id} = $http_agent->get($_);
		}
	}

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	create_config( $responses, $printer );
	my $subnets = parse_interfaces( $responses, $printer );
	parse_local_accounts( $responses, $printer );
	parse_snmp( $responses, $printer );

	while ( ( my $key, my $value ) = each (%{$responses}) )
	{
		delete $responses->{$key};
	}

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
	
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Cisco VxWorks', $cli_protocol, $commands, '(#|\$|>)\s*$');
	_disconnect($cli_protocol);
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
	my $device_prompt_regex = ZipTie::Adapters::Cisco::VxWorks::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

sub _disconnect
{
	# Grab the ZipTie::CLIProtocol object passed in
	my $cli_protocol = shift;

	# Close this session and exit
	$cli_protocol->send("exit");
}

1;
