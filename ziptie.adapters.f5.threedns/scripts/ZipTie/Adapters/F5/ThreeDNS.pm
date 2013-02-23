package ZipTie::Adapters::F5::ThreeDNS;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::F5::ThreeDNS::AutoLogin;
use ZipTie::Adapters::F5::ThreeDNS::GetBackUpFiles qw(get_backup_files);
use ZipTie::Adapters::F5::ThreeDNS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::F5::ThreeDNS::Disconnect qw(disconnect);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle parse_targz_data);
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
	my ($connection_path) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect($connection_path);

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'ThreeDNS', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$responses->{hostname} = $cli_protocol->send_and_wait_for( "hostname",                                              $prompt_regex );
	$responses->{dd}       = $cli_protocol->send_and_wait_for( "dd bs=65k count=10 skip=15 </dev/mem|strings|grep REV", $prompt_regex );
	$responses->{df}       = $cli_protocol->send_and_wait_for( "df",                                                    $prompt_regex );
	$responses->{uptime}   = $cli_protocol->send_and_wait_for( "uptime",                                                $prompt_regex );
	$responses->{dmesg}    = $cli_protocol->send_and_wait_for( "dmesg",                                                 $prompt_regex );
	my $ucsLocation = "/usr/local/ucs/";
	my $ucsPrefix = "ziptie_backup";
	$responses->{config_save} = $cli_protocol->send_and_wait_for( 'bigpipe config save ' . $ucsPrefix, $prompt_regex );
	if ( $responses->{config_save} =~ /Creating UCS for config save request.../mi )
	{
		# if the extension of file is not gz ZLib returns an error
		$responses->{config_rename} = $cli_protocol->send_and_wait_for( "mv -f $ucsLocation$ucsPrefix.ucs $ucsLocation$ucsPrefix.tar.gz", $prompt_regex );

		# download config backup file
		$responses->{ucsFileLocation} = get_backup_files( $cli_protocol, $connection_path, $ucsLocation.$ucsPrefix.".tar.gz");

		# remove the artifact
		$responses->{config_rename} = $cli_protocol->send_and_wait_for( "rm -f $ucsLocation$ucsPrefix.tar.gz", $prompt_regex );

		# parse ucs(tar.gz) file to directory tree
		$responses->{unzippedUcs} = parse_targz_data( $responses->{ucsFileLocation}, '\.conf|\.license' );
	}
	delete $responses->{config_save};
	if ( defined $responses->{unzippedUcs}->{"config"}->{"bigip.license"} )
	{
		$responses->{license} = $responses->{unzippedUcs}->{"config"}->{"bigip.license"};
	}
	else
	{
		$responses->{license} = $cli_protocol->send_and_wait_for( "cat /config/bigip.license", $prompt_regex );
	}
	if ( defined $responses->{unzippedUcs}->{"etc"}->{"snmpd.conf"} )
	{
		$responses->{snmp} = $responses->{unzippedUcs}->{"etc"}->{"snmpd.conf"};
	}
	else
	{
		$responses->{snmp} = $cli_protocol->send_and_wait_for( "cat /etc/snmpd.conf", $prompt_regex );
	}

	if ( defined $responses->{unzippedUcs}->{"config"}->{"ucs_version"} )
	{
		$responses->{ucsv} = $responses->{unzippedUcs}->{"config"}->{"ucs_version"};
	}
	else
	{
		$responses->{ucsv} = $cli_protocol->send_and_wait_for( "cat /config/ucs_version", $prompt_regex );
	}
	if ( defined $responses->{unzippedUcs}->{"etc"}->{"passwd"} )
	{
		$responses->{users} = $responses->{unzippedUcs}->{"etc"}->{"passwd"};
	}
	else
	{
		$responses->{users} = $cli_protocol->send_and_wait_for( "cat /etc/passwd", $prompt_regex );
	}

	parse_system( $responses, $printer );
	delete $responses->{ucsv};
	delete $responses->{uptime};

	parse_chassis( $responses, $printer );
	delete( $responses->{dd} );
	delete( $responses->{df} );
	delete( $responses->{license} );
	delete( $responses->{dmesg} );

	create_config( $responses, $printer );    
	delete $responses->{config};
	delete $responses->{unzippedUcs};
	unlink( $responses->{ucsFileLocation} );

	$responses->{interfaces} = $cli_protocol->send_and_wait_for( "ifconfig -a", $prompt_regex );
	parse_interfaces( $responses, $printer );
	delete( $responses->{interfaces} );

	parse_local_accounts( $responses, $printer );
	delete( $responses->{users} );

	parse_snmp( $responses, $printer );
	delete( $responses->{snmp} );
	delete( $responses->{hostname} );

	$responses->{static_routes} = $cli_protocol->send_and_wait_for( "netstat -rn", $prompt_regex );
	parse_static_routes( $responses, $printer );
	delete( $responses->{static_routes} );

	$responses->{vlans} = $cli_protocol->send_and_wait_for( "bigpipe vlan show", $prompt_regex );
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};

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
	my $command_doc  = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'ThreeDNS', $cli_protocol, $commands, $enable_prompt_regex );
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

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the device
	my $device_prompt_regex = ZipTie::Adapters::F5::ThreeDNS::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );

	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
