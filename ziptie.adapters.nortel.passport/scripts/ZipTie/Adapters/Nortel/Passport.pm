package ZipTie::Adapters::Nortel::Passport;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Nortel::Passport::AutoLogin;
use ZipTie::Adapters::Nortel::Passport::GetConfig qw(get_config);
use ZipTie::Adapters::Nortel::Passport::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Nortel::Passport::Disconnect
	qw(disconnect);
use ZipTie::Adapters::Nortel::Passport::Restore;
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
	my $package_name = shift;
	my $backup_doc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path, $credentials ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path, $credentials );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Passport', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	# Get rid of the more prompt
    my $termLen = $cli_protocol->send_and_wait_for( "config cli more false", $prompt_regex );
    if ($termLen =~ /Type help or|Invalid|Command not valid|Incomplete command/i)
    {
    	# set the --more-- prompt if the term length 0 didn't go through
        $cli_protocol->set_more_prompt( '--More-- (q = quit)\s*$', '20');
    }

	$responses->{config_plain}	= $cli_protocol->send_and_wait_for( "show config", $prompt_regex );
	$responses->{directory}		= $cli_protocol->send_and_wait_for( "directory", $prompt_regex );
	$responses->{sys_info}		= $cli_protocol->send_and_wait_for( "show sys info", $prompt_regex );
	$responses->{sys_perf}		= $cli_protocol->send_and_wait_for( "show sys perf", $prompt_regex );
	$responses->{sys_sw}		= $cli_protocol->send_and_wait_for( "show sys sw", $prompt_regex );
	$responses->{config_plain}	=~ s/^\s*^//mig;
	$responses->{directory}		=~ s/^\s*^//mig;
	$responses->{sys_info}		=~ s/^\s*^//mig;
	$responses->{sys_perf}		=~ s/^\s*^//mig;
	$responses->{sys_sw}		=~ s/^\s*^//mig;
	
	parse_system( $responses, $printer );

	$responses->{cards} = $cli_protocol->send_and_wait_for( "show sys info card", $prompt_regex );	
	$responses->{cards} =~ s/^\s*^//mig;
	parse_chassis( $responses, $printer );
	delete $responses->{cards};
	delete $responses->{sys_perf};

	my ($rt_file_name) = $responses->{sys_sw} =~ /^\s*Default Runtime Config File : (\S+)/mi;
	my ($bt_file_name) = $responses->{sys_sw} =~ /^\s*Default Boot Config File : (\S+)/mi;

	delete $responses->{sys_sw};

	$responses->{config}			= get_config( $cli_protocol, $connection_path, $rt_file_name );
	$responses->{boot_config}		= get_config( $cli_protocol, $connection_path, $bt_file_name );
	$responses->{running_config}	= $cli_protocol->send_and_wait_for( "show config verbose", $prompt_regex, 90 );
	create_config( $responses, $printer );
	delete $responses->{config_plain};
	delete $responses->{directory};
	delete $responses->{running_config};
	delete $responses->{boot_config};
	delete $responses->{config};

	$responses->{ip_arp}		= $cli_protocol->send_and_wait_for( "show ip arp info", $prompt_regex );
	$responses->{vlan_ip}		= $cli_protocol->send_and_wait_for( "show vlan info ip", $prompt_regex );
	$responses->{port_if}		= $cli_protocol->send_and_wait_for( "show ports info interface", $prompt_regex );
	$responses->{port_name}		= $cli_protocol->send_and_wait_for( "show ports info name", $prompt_regex );
	$responses->{port_ospf}		= $cli_protocol->send_and_wait_for( "show ports info ospf", $prompt_regex );
	$responses->{port_stg}		= $cli_protocol->send_and_wait_for( "show ports info stg main", $prompt_regex );
	$responses->{vlan_ports}	= $cli_protocol->send_and_wait_for( "show vlan info ports", $prompt_regex );
	$responses->{interfaces}	= $cli_protocol->send_and_wait_for( "show ip interface", $prompt_regex );
	$responses->{interfaces}	=~ s/^\s*^//mig;
	$responses->{ip_arp}		=~ s/^\s*^//mig;
	$responses->{vlan_ip}		=~ s/^\s*^//mig;
	$responses->{port_if}		=~ s/^\s*^//mig;
	$responses->{port_name}		=~ s/^\s*^//mig;
	$responses->{port_ospf}		=~ s/^\s*^//mig;
	$responses->{port_stg}		=~ s/^\s*^//mig;
	$responses->{vlan_ports}	=~ s/^\s*^//mig;
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	delete $responses->{ip_arp};
	delete $responses->{port_if};
	delete $responses->{port_name};
	delete $responses->{port_ospf};
	delete $responses->{port_stg};
	delete $responses->{vlan_ports};

	$responses->{users} = $cli_protocol->send_and_wait_for( "show cli password", $prompt_regex );
	$responses->{users} =~ s/^\s*^//mig;
	parse_local_accounts( $responses, $printer );
	delete $responses->{users};

	parse_snmp( $responses, $printer );
	delete $responses->{snmp};
	delete $responses->{sys_info};

	$responses->{stg_status} = $cli_protocol->send_and_wait_for( "show stg info status", $prompt_regex );
	$responses->{stg_config} = $cli_protocol->send_and_wait_for( "show stg info config", $prompt_regex );
	$responses->{stg_status} =~ s/^\s*^//mig;
	$responses->{stg_config} =~ s/^\s*^//mig;

	parse_stp( $responses, $printer );
	delete $responses->{stg_status};
	delete $responses->{stg_config};

	$responses->{routes} = $cli_protocol->send_and_wait_for( "show ip route info", $prompt_regex );
	$responses->{routes} =~ s/^\s*^//mig;
	parse_static_routes( $responses, $printer );
	delete $responses->{routes};

	$responses->{vlan_basic}	= $cli_protocol->send_and_wait_for( "show vlan info basic", $prompt_regex );
	$responses->{vlan_advance}	= $cli_protocol->send_and_wait_for( "show vlan info advance", $prompt_regex );
	$responses->{vlan_basic}	=~ s/^\s*^//mig;
	$responses->{vlan_advance}	=~ s/^\s*^//mig;
	parse_vlans( $responses, $printer );
	delete $responses->{vlan_basic};
	delete $responses->{vlan_advance};
	delete $responses->{vlan_ip};

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
	my ( $cli_protocol, $prompt_regex) = _connect( $connection_path );
    $cli_protocol->send_and_wait_for( "config cli more false", $prompt_regex );
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Passport', $cli_protocol, $commands, $prompt_regex.'|(#|\$|>)\s*$');
	disconnect($cli_protocol);
	return $result;
}

# Invockes the restore module
sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;

	# Get the connection path and the restore file
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the enable prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $enable_prompt_regex ) = _connect( $connection_path );

	# Restore the configuration
	ZipTie::Adapters::Nortel::Passport::Restore::execute( $connection_path, $cli_protocol, $enable_prompt_regex, $restoreFile );

	# Disconnect from the specified device
	disconnect($cli_protocol);
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
	my $device_prompt_regex =ZipTie::Adapters::Nortel::Passport::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
