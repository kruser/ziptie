package ZipTie::Adapters::Enterasys::VerticalHorizon;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Enterasys::VerticalHorizon::AutoLogin;
use ZipTie::Adapters::Enterasys::VerticalHorizon::GetConfig qw(get_config);
use ZipTie::Adapters::Enterasys::VerticalHorizon::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Enterasys::VerticalHorizon::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle trim);
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
	my $filehandle = get_model_filehandle( 'Vertical Horizon', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	# enter general system information option
	$cli_protocol->send_as_bytes('0D');

	# enter system information option
	$cli_protocol->send_as_bytes('0D');
	$responses->{'system'} = $cli_protocol->get_response(0.25);

	# exit information option
	$cli_protocol->send_as_bytes('1B5B41'); # 1B5B41 -> up arrow
	$cli_protocol->send_as_bytes('0D');

	# enter switch information option
	$cli_protocol->send_as_bytes('09');
	my $more_units = 1;
	$responses->{switch} = "";
	my $existing_units;
	while ( $more_units )
	{
		$cli_protocol->send_as_bytes('0D');
		$_ = $cli_protocol->get_response(0.25);
		s/^.+\s+(Switch Information)/$1/mis;
		s/\s+<PREV UNIT.+$//mis;
		if ( /^Switch Information : Unit: (\d+)/mi )
		{
			if ( $existing_units->{$1} )
			{
				$more_units = 0;
			}
			else
			{
				$responses->{switch} .= "$_\n";
				$existing_units->{$1} = 1;
			}
		}
		$cli_protocol->send_as_bytes('09');
		$cli_protocol->send_as_bytes('09');
	}
	$responses->{switch} = trim( $responses->{switch} );

	# exit switch option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# exit general system information option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{switch};

	# enter management setup option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# enter snmp configuration option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# enter snmp communities option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');
	$responses->{snmp_communities} = $cli_protocol->get_response(0.25);

	# exit snmp communities option
	$cli_protocol->send_as_bytes('1B5B41'); # 1B5B41 -> up arrow
	$cli_protocol->send_as_bytes('0D');

	# enter snmp traps option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');
	$responses->{snmp_traps} = $cli_protocol->get_response(0.25);
	# exit snmp traps option
	$cli_protocol->send_as_bytes('1B5B41'); # 1B5B41 -> up arrow
	$cli_protocol->send_as_bytes('0D');

	# exit snmp configuration option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# highlight configuration save & restore option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');

	# download configuration file
	#$responses->{config} = "";
	$responses->{config} = get_config ( $cli_protocol, $connection_path );

	# exit management setup option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# enter device control option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');
	$_ = $cli_protocol->get_response(0.25);

	create_config( $responses, $printer );

	# enter port configuration option and store the ports info
	my $more_ports = 1;
	$responses->{interfaces} = "";
	my $existing_ports;
	while ( $more_ports )
	{
		$cli_protocol->send_as_bytes('0D');
		$_ = $cli_protocol->get_response(0.25);
		s/^.+\s+-+\s+//mis;
		s/\s+<APPLY.+$//mis;
		if ( /^(\d+)\s+\d+\/\d+/mi )
		{
			if ( $existing_ports->{$1} )
			{
				$more_ports = 0;
			}
			else
			{
				$responses->{interfaces} .= "$_\n";
			}
		}
		while ( /^\s*(\d+)\s+\d+\/\d+/mig )
		{
			$existing_ports->{$1} = 1;
		}
		$cli_protocol->send_as_bytes('1B5B41'); # 1B5B41 -> up arrow
	}
	$responses->{interfaces} = trim( $responses->{interfaces} );
	# exit port configuration option
	for (1..5)
	{
		$cli_protocol->send_as_bytes('1B5B41'); # 1B5B41 -> up arrow
	}
	$cli_protocol->send_as_bytes('0D');

	# enter stp configuration option
	for (1..5)
	{
		$cli_protocol->send_as_bytes('1B5B42'); # 1B5B42 -> down arrow
	}
	$cli_protocol->send_as_bytes('0D');

	# enter bridge configuration option
	$cli_protocol->send_as_bytes('0D');
	$responses->{bridge_conf} = $cli_protocol->get_response(0.25);
	# exit bridge configuration option
	for (1..6)
	{
		$cli_protocol->send_as_bytes('09');
	}
	$cli_protocol->send_as_bytes('0D');

	# enter stp port configuration option and store ports info
	$cli_protocol->send_as_bytes('09');
	# reset ports hash
	while ( (my $key, my $value) = each(%{$existing_ports}) )
	{
		delete $existing_ports->{$key};
	}
	$more_ports = 1;
	$responses->{ports_stp} = "";
	$existing_ports;
	while ( $more_ports )
	{
		$cli_protocol->send_as_bytes('0D');
		$_ = $cli_protocol->get_response(0.25);
		s/^.+\s+-+\s+//mis;
		s/\s+<APPLY.+$//mis;
		if ( /^(\d+)\s+\d+\/\d+/mi )
		{
			if ( $existing_ports->{$1} )
			{
				$more_ports = 0;
			}
			else
			{
				$responses->{ports_stp} .= "$_\n";
			}
		}
		while ( /^\s*(\d+)\s+\d+\/\d+/mig )
		{
			$existing_ports->{$1} = 1;
		}
		$cli_protocol->send_as_bytes('1B5B41'); # 1B5B41 -> up arrow
	}
	$responses->{ports_stp} = trim( $responses->{ports_stp} );
	# exit stp configuration option
	for (1..5)
	{
		$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	}
	$cli_protocol->send_as_bytes('0D');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# enter stp info option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# enter bridge info option
	$cli_protocol->send_as_bytes('0D');
	$responses->{bridge_info} = $cli_protocol->get_response(0.25);

	# exit bridge info option
	$cli_protocol->send_as_bytes('0D');

	# exit stp info option
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('09');
	$cli_protocol->send_as_bytes('0D');

	# exit device control menu
	$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	$cli_protocol->send_as_bytes('0D');

	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	delete $responses->{ports_stp};

	parse_snmp( $responses, $printer );
	delete $responses->{snmp_communities};
	delete $responses->{snmp_traps};
	delete $responses->{'system'};

	parse_stp( $responses, $printer );
	delete $responses->{bridge_info};
	delete $responses->{bridge_conf};

	# close out the ZiptieElementDocument
	$printer->close_model();
	
	# Make sure to close the model file handle
	close_model_filehandle($filehandle);
	
	# Disconnect from the device
	_disconnect($cli_protocol);
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $device_prompt_regex ) = _connect( $connection_path );
	
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Vertical Horizon', $cli_protocol, $commands, '(#|\$|>)\s*$');
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
	my $device_prompt_regex = ZipTie::Adapters::Enterasys::VerticalHorizon::AutoLogin::execute( $cli_protocol, $connection_path );
	
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

	# exit from menu
	$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	$cli_protocol->send_as_bytes('1B5B42'); # 1B5B41 -> down arrow
	$cli_protocol->send_as_bytes('0D');
}

1;
