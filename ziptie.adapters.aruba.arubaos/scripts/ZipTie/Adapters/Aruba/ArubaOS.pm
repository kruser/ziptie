package ZipTie::Adapters::Aruba::ArubaOS;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Aruba::ArubaOS::AutoLogin;
use ZipTie::Adapters::Aruba::ArubaOS::GetConfig qw(get_config);
use ZipTie::Adapters::Aruba::ArubaOS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Aruba::ArubaOS::Disconnect
	qw(disconnect);
use ZipTie::Adapters::Aruba::ArubaOS::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
use ZipTie::Adapters::GenericAdapter;
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
	my ( $connection_path, $credentials ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path, $credentials );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'ArubaOS', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$cli_protocol->send_and_wait_for( 'no paging', $prompt_regex );

	$responses->{switchinfo}	= $cli_protocol->send_and_wait_for( 'show switchinfo', $prompt_regex );
	$responses->{contact}		= $cli_protocol->send_and_wait_for( 'show syscontact', $prompt_regex );
	$responses->{config_plain}	= $cli_protocol->send_and_wait_for( 'show config', $prompt_regex, 120 );

	parse_system( $responses, $printer );

	$responses->{storage}		= $cli_protocol->send_and_wait_for( 'show storage', $prompt_regex );
	$responses->{dir}			= $cli_protocol->send_and_wait_for( 'dir', $prompt_regex );
	$responses->{inventory}		= $cli_protocol->send_and_wait_for( 'show inventory', $prompt_regex );

	parse_chassis( $responses, $printer );
	delete $responses->{storage};
	delete $responses->{dir};
	delete $responses->{inventory};

	$responses->{'running-config'} = get_config($cli_protocol, $connection_path, 'running-config');
	$responses->{'startup-config'} = get_config($cli_protocol, $connection_path, 'startup-config');

	create_config( $responses, $printer );

	$responses->{destination}	= $cli_protocol->send_and_wait_for( 'show netdestination', $prompt_regex );
	$responses->{netservice}	= $cli_protocol->send_and_wait_for( 'show netservice', $prompt_regex );
	$responses->{acls}			= $cli_protocol->send_and_wait_for( 'show access-list brief', $prompt_regex );
	while ( $responses->{acls} =~ /^(\S+)\s+(?:session|standard|extended)\s.*$/mig )
	{
		$responses->{"acl_$1"} = $cli_protocol->send_and_wait_for( "show access-list $1", $prompt_regex );
	}
	delete $responses->{acls};

	parse_filters( $responses, $printer );
	delete $responses->{destination};
	delete $responses->{netservice};
	while ((my $key,my $value) = each%{$responses})
	{
		delete $responses->{$key} if ( $key =~ /^acl_/ );
	}

	$responses->{span_tree}		= $cli_protocol->send_and_wait_for( 'show spantree', $prompt_regex );
	while ( $responses->{config_plain} =~ /^interface (mgmt|fastethernet|gigabitethernet|vlan)(\s+\d+(?:\/(\d+))?)?.+?(?=!)/migs )
	{
		my $prefix	= lc($1);
		my $name	= $2;
		my $if_blob	= $3;
		if ( $if_blob !~ /shutdown/mi )
		{
			if ( defined $name )
			{
				$name								=~ s/^\s*//;
				$name								=~ s/\s*$//;
				$responses->{"if-$prefix-$name"}	= $cli_protocol->send_and_wait_for( "show interface $prefix $name", $prompt_regex );
			}
			else
			{
				$responses->{"if-$prefix"} = $cli_protocol->send_and_wait_for( "show interface $prefix", $prompt_regex );
			}
		}
	}

	my $subnets = parse_interfaces( $responses, $printer );
	while ((my $key,my $value) = each%{$responses})
	{
		delete $responses->{$key} if ( $key =~ /^if-/ );
	}

	parse_local_accounts( $responses, $printer );

	$responses->{snmp_comm}		= $cli_protocol->send_and_wait_for( 'show snmp community', $prompt_regex );
	parse_snmp( $responses, $printer );
	delete $responses->{contact};

	parse_stp( $responses, $printer );
	delete $responses->{span_tree};

	$responses->{ip_route}		= $cli_protocol->send_and_wait_for( 'show ip route', $prompt_regex );
	parse_static_routes( $responses, $printer, $subnets );
	delete $responses->{ip_route};
	
	$responses->{vlans} = $cli_protocol->send_and_wait_for( "show vlan", $prompt_regex );
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};

	delete $responses->{config_plain};
	delete $responses->{switchinfo};

	# close out the ZiptieElementDocument
	$printer->close_model();
	
	# Make sure to close the model file handle
	close_model_filehandle($filehandle);

	# Disconnect from the specified device
	disconnect($cli_protocol);
}

sub commands
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt ) = _connect($connection_path);
	my $termLen = $cli_protocol->send_and_wait_for( "no paging", $prompt );
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'ArubaOS', $cli_protocol, $commands, $prompt.'|(#|\$|>)\s*$' );
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
	my $device_prompt_regex =ZipTie::Adapters::Aruba::ArubaOS::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
