package ZipTie::Adapters::Eltek::BCJC;

use strict;

use ZipTie::Adapters::Eltek::BCJC::AutoLogin;
use ZipTie::Adapters::Eltek::BCJC::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

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

sub backup
{
	my $packageName = shift;
	my $backupDoc   = shift;    # how to backup this device
	my $responses   = {};       # will contain device responses to be handed to the Parsers module

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ($connectionPath) = ZipTie::Typer::translate_document( $backupDoc, 'connectionPath' );

	# Set up the XmlPrint object for printing the ZiptieElementDocument (ZED)
	my $filehandle = get_model_filehandle( 'Eltek BC/JC', $connectionPath->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Make a Telnet or SSH connection
	my ( $cliProtocol, $promptRegex ) = _connect($connectionPath);
	$responses->{systemInfo} = $cliProtocol->send_and_wait_for( 'get system info',        $promptRegex, '60' );
	$responses->{interfaces} = $cliProtocol->send_and_wait_for( 'get ipconfig all',       $promptRegex, '60' );
	$responses->{traps}      = $cliProtocol->send_and_wait_for( 'get ipconfig TrapDest1', $promptRegex, '60' );
	$responses->{trapVer}    = $cliProtocol->send_and_wait_for( 'get snmp TrapVersion',   $promptRegex, '60' );

	# hardware
	$responses->{rect} = $cliProtocol->send_and_wait_for( 'get rect info', $promptRegex, '60' );
	$responses->{lvd}  = $cliProtocol->send_and_wait_for( 'get lvd info',  $promptRegex, '60' );

	# Config objects
	$responses->{config}->{setpoint} = $cliProtocol->send_and_wait_for( 'get setpoint FloatV', $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint HVSD',        $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint CurLmtState', $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint CurLimit',    $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint HVAlarm',     $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint BDAlarm',     $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint LVAlarm',     $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint CommAlarm',   $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint CommAsACF',   $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint IShare',      $promptRegex, 60 );
	$responses->{config}->{setpoint} .= $cliProtocol->send_and_wait_for( 'get setpoint RedunAlarm',  $promptRegex, 60 );
	$responses->{config}->{temp}                = $cliProtocol->send_and_wait_for( 'get temp all',  $promptRegex, 60 );
	$responses->{config}->{'battery boost'}     = $cliProtocol->send_and_wait_for( 'get boost all', $promptRegex, 60 );
	$responses->{config}->{'battery discharge'} = $cliProtocol->send_and_wait_for( 'get bdt all',   $promptRegex, 60 );
	$responses->{config}->{'battery recharge'}  = $cliProtocol->send_and_wait_for( 'get brcl operState', $promptRegex, 60 );
	$responses->{config}->{'battery recharge'} .= $cliProtocol->send_and_wait_for( 'get brcl adminState', $promptRegex, 60 );
	$responses->{config}->{'battery recharge'} .= $cliProtocol->send_and_wait_for( 'get brcl iLimitsp', $promptRegex, 60 );

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
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

	ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'Eltek BC/JC', $cliProtocol, $commands,
		$devicePromptRegex . '|(#|\$|>)\s*$' );
	_disconnect($cliProtocol);
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
	my $devicePromptRegex = ZipTie::Adapters::Eltek::BCJC::AutoLogin::execute( $cliProtocol, $connectionPath );

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

1;
