package ZipTie::Adapters::Nokia::Checkpoint;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Nokia::Checkpoint::AutoLogin;
use ZipTie::Adapters::Nokia::Checkpoint::GetConfig qw(get_config);
use ZipTie::Adapters::Nokia::Checkpoint::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Nokia::Checkpoint::Disconnect
	qw(disconnect);
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
	my ( $connection_path, $credentials ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path, $credentials );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Checkpoint', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$responses->{hostname}					= $cli_protocol->send_and_wait_for( "hostname", $prompt_regex );
	$responses->{kern_osrelease}			= $cli_protocol->send_and_wait_for( "ipsctl kern:osrelease", $prompt_regex );
	$responses->{bios_version}				= $cli_protocol->send_and_wait_for( "ipsctl hw:bios:version", $prompt_regex );
	$responses->{motherboard}				= $cli_protocol->send_and_wait_for( "ipsctl hw:motherboard:serialnumber", $prompt_regex );
	$responses->{motherboard}				.= $cli_protocol->send_and_wait_for( "ipsctl hw:motherboard:revision", $prompt_regex );
	$responses->{motherboard}				.= $cli_protocol->send_and_wait_for( "ipsctl hw:motherboard:modelname", $prompt_regex );
	$responses->{snmp}						= $cli_protocol->send_and_wait_for( "cat /var/etc/snmpd.conf", $prompt_regex );
	$responses->{uptime}					= $cli_protocol->send_and_wait_for( "uptime", $prompt_regex );
	$responses->{dmesg}						= $cli_protocol->send_and_wait_for( "dmesg", $prompt_regex );
	$responses->{'hw:chassis:serialnumber'} = $cli_protocol->send_and_wait_for( "ipsctl hw:chassis:serialnumber", $prompt_regex );
	$responses->{'product:model'} 			= $cli_protocol->send_and_wait_for( "dbget product:model", $prompt_regex );
	$responses->{interfaces}				= $cli_protocol->send_and_wait_for( "ifconfig -a", $prompt_regex );
	$responses->{users}						= $cli_protocol->send_and_wait_for( "cat /etc/passwd", $prompt_regex );

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $fts				= sprintf "%4d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec;
	$fts				= "config";
	my $config_filename = "$fts.ziptie_backup";

	$responses->{config}	= "";
	$responses->{config2}	= "";
	#$responses->{'tar'} = $cli_protocol->send_and_wait_for( "tar -cf ./$config_filename.tar ".'/config/db/ /config/active $FWDIR/conf/fw.license $FWDIR/conf/*.C $FWDIR/conf/*.W $FWDIR/conf/*.fws $FWDIR/conf/*.NDB $FWDIR/conf/fwmusers $FWDIR/conf/gui-clients $FWDIR/conf/*.conf $FWDIR/conf/*.keys $FWDIR/conf/serverkeys.* $FWDIR/conf/*.if $FWDIR/conf/masters $FWDIR/state/* $FWDIR/policy/* $FWDIR/database/*.NDB $FWDIR/database/*.conf $FWDIR/database/*.keys $FWDIR/database/*.C', $prompt_regex );
	# delete file before creating the new one
	$responses->{'rm'} = $cli_protocol->send_and_wait_for( "rm -f ./$config_filename.tar.gz", $prompt_regex );
	$cli_protocol->send_and_wait_for( "rm -f ./$config_filename.2.tar.gz", $prompt_regex );
	if ( $responses->{'rm'} =~ /No match/ )
	{
		$cli_protocol->send_and_wait_for( "rm ./$config_filename.tar.gz", $prompt_regex );
		$cli_protocol->send_and_wait_for( "rm ./$config_filename.2.tar.gz", $prompt_regex );
	}
	# create tar.gz and download it
	$responses->{'tar'} = $cli_protocol->send_and_wait_for( "tar -cf ./$config_filename.tar ".'/config/db/ /config/active $FWDIR/conf/fw.license $FWDIR/conf/*.C $FWDIR/conf/*.W $FWDIR/conf/*.fws $FWDIR/conf/*.NDB $FWDIR/conf/fwmusers $FWDIR/conf/gui-clients $FWDIR/conf/*.conf $FWDIR/conf/*.keys $FWDIR/conf/serverkeys.* $FWDIR/conf/*.if $FWDIR/conf/masters', $prompt_regex );
	$responses->{'tar2'} = $cli_protocol->send_and_wait_for( "tar -cf ./$config_filename.2.tar ".'$FWDIR/state/* $FWDIR/policy/* $FWDIR/database/*.NDB $FWDIR/database/*.conf $FWDIR/database/*.keys $FWDIR/database/*.C', $prompt_regex );
	$responses->{'gzip'} = $cli_protocol->send_and_wait_for( "gzip -f ./$config_filename.tar", $prompt_regex );
	$responses->{'gzip2'} = $cli_protocol->send_and_wait_for( "gzip -f ./$config_filename.2.tar", $prompt_regex );
	if ( $responses->{'gzip'} !~ /No\s+such\s+file\s+or\s+directory/ )
	{
		$responses->{config} = get_config( $cli_protocol, $connection_path, $config_filename );
		$_ = $config_filename.".2";
		$responses->{config2} = get_config( $cli_protocol, $connection_path, $_ );
		# repetitively send empty command to get rid of garbage after prompt message
		#for ( my $t = 1; $t < 3; $t ++ )
		#{
		#	$cli_protocol->send_and_wait_for( "", '.*' );
		#}
		$responses->{'rm'} = $cli_protocol->send_and_wait_for( "rm -f ./$config_filename.tar.gz", $prompt_regex );
		$cli_protocol->send_and_wait_for( "rm -f ./$config_filename.2.tar.gz", $prompt_regex );
		if ( $responses->{'rm'} =~ /No match/ )
		{
			$cli_protocol->send_and_wait_for( "rm ./$config_filename.tar.gz", $prompt_regex );
			$cli_protocol->send_and_wait_for( "rm ./$config_filename.2.tar.gz", $prompt_regex );
		}
		# parse tar.gz file to directory tree
		$responses->{unzipped} = parse_targz_data($responses->{config}, '\/(conf|policy|database)\/');
		$responses->{unzipped2} = parse_targz_data($responses->{config2}, '\/(conf|policy|database)\/');
	}
	delete $responses->{'tar'};
	delete $responses->{'tar2'};
	delete $responses->{'gzip'};
	delete $responses->{'gzip2'};
	delete $responses->{'rm'};

	$responses->{acl_rules}		= $cli_protocol->send_and_wait_for( "clish -c \"show aclrules\"", $prompt_regex );
	$responses->{static_routes}	= $cli_protocol->send_and_wait_for( "clish -c \"show route\"", $prompt_regex );

	# get information about HDDs
	my $next_disk = 1;
	my $idx = 0;
	$responses->{hdd} = "";
	while ($next_disk)
	{
		my $temp_response = $cli_protocol->send_and_wait_for( "clish -c \"show disk $idx\"", $prompt_regex );
		if ($temp_response =~ /^model\s+\S+/mi)
		{
			$responses->{hdd} .= $temp_response."\n";
			$idx ++;						
		}
		else
		{
			$next_disk = undef;
		}
	}

	parse_system( $responses, $printer );
	delete $responses->{uptime};
	delete $responses->{kern_osrelease};
	delete $responses->{bios_version};

	parse_chassis( $responses, $printer );
	delete $responses->{'hw:chassis:serialnumber'};
	delete $responses->{'product:model'};
	delete $responses->{hdd};
	delete $responses->{dmesg};

	create_config( $responses, $printer );
	unlink($responses->{config});
	delete $responses->{config};
	unlink($responses->{config2});
	delete $responses->{config2};

	parse_filters( $responses, $printer );
	delete $responses->{acl_rules};

	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};

	parse_local_accounts( $responses, $printer );
	delete $responses->{users};

	parse_snmp( $responses, $printer );
	delete $responses->{snmp};
	delete $responses->{hostname};

	# stp and vlans are not available
	
	parse_static_routes( $responses, $printer );
	delete $responses->{static_routes};

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
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Checkpoint', $cli_protocol, $commands, '(#|\$|>)\s*$');
	disconnect($cli_protocol);
	return $result;
}

sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );

	# Check to see if SCP is available
	my $scp_protocol  = $connection_path->get_protocol_by_name("SCP")  if ( defined($connection_path) );

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
	my $device_prompt_regex =ZipTie::Adapters::Nokia::Checkpoint::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;
