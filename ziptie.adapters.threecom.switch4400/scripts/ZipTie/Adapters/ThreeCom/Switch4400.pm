package ZipTie::Adapters::ThreeCom::Switch4400;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::ThreeCom::Switch4400::AutoLogin;
use ZipTie::Adapters::ThreeCom::Switch4400::GetConfig qw(get_config);
use ZipTie::Adapters::ThreeCom::Switch4400::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_port_ip_by_vlan);
use ZipTie::Adapters::ThreeCom::Switch4400::Disconnect
	qw(disconnect);
use ZipTie::Adapters::ThreeCom::Switch4400::Restore;
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
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'ThreeCom Switch', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$responses->{'system'} = $cli_protocol->send_and_wait_for( 'system summary', $prompt_regex );

	parse_system( $responses, $printer );

	parse_chassis( $responses, $printer );

	delete $responses->{'system'};

	$responses->{users} = $cli_protocol->send_and_wait_for( 'security device user summary', $prompt_regex );

	$responses->{routes} = $cli_protocol->send_and_wait_for( 'protocol ip route summary', $prompt_regex );

	$responses->{stp} = $cli_protocol->send_and_wait_for( 'bridge summary', $prompt_regex );

	$responses->{all_vlans}	= $cli_protocol->send_and_wait_for( 'bridge vlan summary all', $prompt_regex );
	$responses->{vlans}			= "";
	while ( $responses->{all_vlans} =~ /^\s*(\d+)\s+/mig )
	{
		$responses->{vlans} .= "\n".'---NEXT VLAN---'."\n".$cli_protocol->send_and_wait_for( 'bridge vlan detail '.$1, $prompt_regex ).'\n---NEXT VLAN---';
	}
	$responses->{vlan_ips} = $cli_protocol->send_and_wait_for( 'protocol ip interface summary all', $prompt_regex );
	my $ports_ips = parse_port_ip_by_vlan( $responses );
	delete $responses->{all_vlans};
	delete $responses->{vlans};
	delete $responses->{vlan_ips};

	my $command		= 'physicalInterface ethernet summary all';
	while ( )
	{
		if ( $command eq 'physicalInterface ethernet summary all' )
		{
			$_ = $cli_protocol->send_and_wait_for( $command, '\s+Next|\s+Prev' );
		}
		else
		{
			$cli_protocol->send_as_bytes($command);
			$_ = $cli_protocol->get_response(0.25);
		}
		$command = '4E';
		s/\x1b//mig;
		s/\[5;1H/\n/mig;
		s/\[[0-9a-f]+;[0-9a-f]+H//mig;
		last if ( /\s+Prev/ );
		$responses->{eth_summary} .= $_;
	}
	$cli_protocol->send_as_bytes('51');

	while ( $responses->{eth_summary} =~ /^(\d+:\d+)\s+\S+\s+(\S+\s.+)(?=\d)/mig )
	{
		$_ = $1;
		$responses->{"eth_$_"} = $cli_protocol->send_and_wait_for( "physicalInterface ethernet detail $_", 'Utilizations|Select menu option:' );
		$cli_protocol->send_as_bytes('51');
		$cli_protocol->get_response(0.25);
	}

	$responses->{'config'} = get_config($cli_protocol, $connection_path);
	create_config( $responses, $printer );

	my $subnets = parse_interfaces( $responses, $printer, $ports_ips );
	while ( ( my $key, my $value ) = each(%{$responses}) )
	{
		if ( $key =~ /^eth_/i )
		{
			delete $responses->{$key};
		}
	}

	parse_local_accounts( $responses, $printer );
	delete $responses->{users};

	parse_snmp( $responses, $printer );
	delete $responses->{'config'};

	parse_stp( $responses, $printer );
	delete $responses->{stp};

	parse_static_routes( $responses, $printer, $subnets );
	delete $responses->{routes};

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
	my $device_prompt_regex = ZipTie::Adapters::ThreeCom::Switch4400::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
