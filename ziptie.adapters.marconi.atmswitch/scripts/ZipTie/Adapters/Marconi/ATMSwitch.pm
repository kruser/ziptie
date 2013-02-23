package ZipTie::Adapters::Marconi::ATMSwitch;

use strict;

use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Marconi::ATMSwitch::AutoLogin;
use ZipTie::Adapters::Marconi::ATMSwitch::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
#use ZipTie::Adapters::Marconi::ATMSwitch::Disconnect qw(disconnect);
use ZipTie::Adapters::Marconi::ATMSwitch::GetConfig qw(get_config);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;
use ZipTie::Adapters::GenericAdapter;
use ZipTie::SNMP;
use ZipTie::SnmpSessionFactory;

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
	my $filehandle = get_model_filehandle( 'ATM Switch', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();
	
	#Use SNMP to gather uptime
	my $snmpSession = ZipTie::SnmpSessionFactory->create($connection_path);

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$_ = $cli_protocol->send_and_wait_for( 'rows 0', $prompt_regex );
	if ( /ERROR:/ )
	{
		$cli_protocol->set_more_prompt( 'Press <return> for more', '20');
	}

	$responses->{'system'}	= $cli_protocol->send_and_wait_for( 'system show', $prompt_regex );
	$responses->{version}	= $cli_protocol->send_and_wait_for( 'system version', $prompt_regex );
	$responses->{fabric}	= $cli_protocol->send_and_wait_for( 'hardware fabric show', $prompt_regex );
	$responses->{scp}		= $cli_protocol->send_and_wait_for( 'hardware scp show', $prompt_regex );
	$responses->{portcard}	= $cli_protocol->send_and_wait_for( 'hardware portcard show', $prompt_regex );
	$responses->{netmod}	= $cli_protocol->send_and_wait_for( 'hardware netmod show', $prompt_regex );
	$responses->{free}		= $cli_protocol->send_and_wait_for( 'filesystem free', $prompt_regex );
	$responses->{dir}		= $cli_protocol->send_and_wait_for( 'dir', $prompt_regex );
	$responses->{power}		= $cli_protocol->send_and_wait_for( 'hardware power', $prompt_regex );
	$responses->{uptime} = _get_uptime($snmpSession);

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );

	delete $responses->{'system'};
	delete $responses->{version};
	delete $responses->{fabric};
	delete $responses->{scp};
	delete $responses->{portcard};
	delete $responses->{netmod};
	delete $responses->{free};
	delete $responses->{dir};
	delete $responses->{power};

	$responses->{'config'} = get_config( $cli_protocol, $connection_path );
	create_config( $responses, $printer );
	delete $responses->{'config'};

	#security login-> show
	$responses->{if_show}	= $cli_protocol->send_and_wait_for( 'interfaces if show', $prompt_regex );
	$responses->{ip_show}	= $cli_protocol->send_and_wait_for( 'interfaces ip show', $prompt_regex );
	$responses->{auto_neg}	= $cli_protocol->send_and_wait_for( 'hardware port ethernet auto-negotiation show', $prompt_regex );
	#$responses->{stp_ports}	= $cli_protocol->send_and_wait_for( 'ethernet bridge stp port configuration show', $prompt_regex );
	parse_interfaces( $responses, $printer );
	delete $responses->{if_show};
	delete $responses->{ip_show};
	delete $responses->{auto_neg};

	$responses->{stp}		= $cli_protocol->send_and_wait_for( 'ethernet bridge stp configuration show', $prompt_regex );
	$responses->{bridge}	= $cli_protocol->send_and_wait_for( 'ethernet bridge show', $prompt_regex );
	parse_stp( $responses, $printer );
	delete $responses->{stp};
	delete $responses->{bridge};

	$responses->{routes} = $cli_protocol->send_and_wait_for( 'interfaces ip route show', $prompt_regex );
	parse_static_routes( $responses, $printer );
	delete $responses->{routes};

	$responses->{vlans} = $cli_protocol->send_and_wait_for( 'ethernet vlan show', $prompt_regex );
	if ( $responses->{vlans} =~ /ERROR:/mi )
	{
		$responses->{vlans} = $cli_protocol->send_and_wait_for( 'ethernet bridge vlan show', $prompt_regex );
	}
	#parse_vlans( $responses, $printer );
	delete $responses->{vlans};

	# close out the ZiptieElementDocument
	$printer->close_model();

	# Make sure to close the model file handle
	close_model_filehandle($filehandle);

	# Disconnect from the device
	_disconnect($cli_protocol);
}

sub commands
{
	my $packageName = shift;
	my $commandDoc  = shift;

	my ( $connectionPath, $commands ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );
	my ( $cliProtocol, $devicePromptRegex ) = _connect($connectionPath);

	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'ATM Switch', $cliProtocol, $commands, $devicePromptRegex . '|(#|\$|>)\s*$' );
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
	my $devicePromptRegex = ZipTie::Adapters::Marconi::ATMSwitch::AutoLogin::execute( $cliProtocol, $connectionPath );

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
