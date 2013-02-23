package ZipTie::Adapters::F5::BigIP;

use strict;

use ZipTie::Adapters::F5::BigIP::AutoLogin;
use ZipTie::Adapters::F5::BigIP::GetBackUpFiles qw(get_backup_files);
use ZipTie::Adapters::F5::BigIP::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::F5::BigIP::Disconnect qw(disconnect);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle parse_targz_data);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Model::XmlPrint;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Logger;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;

	# Retrieve the operation XML document that contains all of the IP, protocol, credential, and file server information
	# that is needed to successfully backup a device.
	my $backup_doc = shift;

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ($connection_path) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the device prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $device_prompt_regex ) = _connect($connection_path);

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'BigIP', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$responses->{dmesg}    = $cli_protocol->send_and_wait_for( "dmesg",                                                 $device_prompt_regex );
	$responses->{global}   = $cli_protocol->send_and_wait_for( "bigpipe global",                                        $device_prompt_regex );
	$responses->{hostname} = $cli_protocol->send_and_wait_for( "hostname -v -i",                                        $device_prompt_regex );
	$responses->{dd}       = $cli_protocol->send_and_wait_for( "dd bs=65k count=10 skip=15 </dev/mem|strings|grep REV", $device_prompt_regex );
	$responses->{uptime}   = $cli_protocol->send_and_wait_for( "uptime",                                                $device_prompt_regex );
	my $ucsPrefix = "ziptie_backup";
	$responses->{config_save} = $cli_protocol->send_and_wait_for( "bigpipe config save $ucsPrefix.ucs", $device_prompt_regex, 300 );
	if ( $responses->{config_save} =~ /(Creating UCS for config save request|Saving active configuration).../mi )
	{
		$responses->{config_rename} = $cli_protocol->send_and_wait_for( "mv -f /var/local/ucs/$ucsPrefix.ucs /var/local/ucs/$ucsPrefix.tar.gz", $device_prompt_regex );
		
		# download config backup file
		$responses->{ucsFileLocation} = get_backup_files( $cli_protocol, $connection_path, $ucsPrefix.'.tar.gz' );

		# parse ucs(tar.gz) file to directory tree
		$responses->{unzippedUcs} = parse_targz_data( $responses->{ucsFileLocation}, '\.conf|\.license' );
		
		# remove the artifact
		$responses->{config_rename} = $cli_protocol->send_and_wait_for( "rm -f /var/local/ucs/$ucsPrefix.tar.gz", $device_prompt_regex );
	}
	delete $responses->{config_save};

	if ( defined $responses->{unzippedUcs}->{"config"}->{"bigip.license"} )
	{
		$responses->{license} = $responses->{unzippedUcs}->{"config"}->{"bigip.license"};
	}
	else
	{
		$responses->{license} = $cli_protocol->send_and_wait_for( "cat /config/bigip.license", $device_prompt_regex );
	}
	if ( defined $responses->{unzippedUcs}->{"config"}->{"snmp"}->{"snmpd.conf"} )
	{
		$responses->{snmp} = $responses->{unzippedUcs}->{"config"}->{"snmp"}->{"snmpd.conf"};
	}
	else
	{
		$responses->{snmp} = $cli_protocol->send_and_wait_for( "cat /config/snmp/snmpd.conf", $device_prompt_regex );
	}
	if ( defined $responses->{unzippedUcs}->{"config"}->{"ucs_version"} )
	{
		$responses->{ucsv} = $responses->{unzippedUcs}->{"config"}->{"ucs_version"};
	}
	else
	{
		$responses->{ucsv} = $cli_protocol->send_and_wait_for( "cat /config/ucs_version", $device_prompt_regex );
	}
	if ( defined $responses->{unzippedUcs}->{"etc"}->{"passwd"} )
	{
		$responses->{users} = $responses->{unzippedUcs}->{"etc"}->{"passwd"};
	}
	else
	{
		$responses->{users} = $cli_protocol->send_and_wait_for( "cat /etc/passwd", $device_prompt_regex );
	}

	parse_system( $responses, $printer );
	delete $responses->{ucsv};
	delete $responses->{dd};
	delete $responses->{uptime};

	parse_chassis( $responses, $printer );
	delete $responses->{license};
	delete $responses->{dmesg};
	delete $responses->{global};

	create_config( $responses, $printer );
	delete $responses->{config};
	delete $responses->{unzippedUcs};    
	unlink( $responses->{ucsFileLocation} );

	$responses->{interfaces} = $cli_protocol->send_and_wait_for( "bigpipe interface show all", $device_prompt_regex );
	$responses->{mgmt}       = $cli_protocol->send_and_wait_for( "bigpipe mgmt show all",      $device_prompt_regex );
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	delete $responses->{mgmt};

	parse_local_accounts( $responses, $printer );
	delete $responses->{users};

	parse_snmp( $responses, $printer );
	delete $responses->{snmp};
	delete $responses->{hostname};

	$responses->{stp} = $cli_protocol->send_and_wait_for( "bigpipe stp show all", $device_prompt_regex );
	parse_stp( $responses, $printer );
	delete $responses->{stp};

	$responses->{static_routes} = $cli_protocol->send_and_wait_for( "route -n", $device_prompt_regex );
	parse_static_routes( $responses, $printer );
	delete $responses->{static_routes};

	$responses->{vlans} = $cli_protocol->send_and_wait_for( "bigpipe vlan show all", $device_prompt_regex );
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};

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
	my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'BigIP', $cli_protocol, $commands, $enable_prompt_regex );
	disconnect($cli_protocol);
	return $result;
}

sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );

	# Check to see if SCP is available
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP") if ( defined($connection_path) );

	if ( defined($scp_protocol) )
	{
		ZipTie::Adapters::GenericAdapter::scp_restore( $connection_path, $restoreFile );
	}
	else
	{
		$LOGGER->fatal("Unable to restore file.  Protocol SCP is not available.");
	}
}

sub _connect
{

	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the BigIP device
	my $device_prompt_regex = ZipTie::Adapters::F5::BigIP::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the found prompt as "prompt" on the specified CLI protocol.
	$cli_protocol->set_prompt_by_name( "prompt", $device_prompt_regex );

	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
