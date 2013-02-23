package ZipTie::Adapters::Sunhillo::RICI;

use strict;

use ZipTie::Adapters::Sunhillo::RICI::AutoLogin;
use ZipTie::Adapters::Sunhillo::RICI::Parsers
  qw(parse_ntp parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Sunhillo::RICI::GetBackUpFiles qw(get_backup_files);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle parse_targz_data);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::CLIProtocol;
use ZipTie::CLIProtocolFactory;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Logger;
use ZipTie::Model::XmlPrint;
use ZipTie::SNMP;
use ZipTie::SnmpSessionFactory;

#use ZipTie::Typer;

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
	my $filehandle = get_model_filehandle( 'Sunhillo RICI', $connectionPath->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# The initial adapter makes use of SNMP to gather well known pieces of information
	# such as the system uptime, the system name and interface layer 2 and 3 addresses.
	my $snmpSession = ZipTie::SnmpSessionFactory->create($connectionPath);
	$responses->{snmp}       = ZipTie::Adapters::GenericAdapter::get_snmp($snmpSession);
	$responses->{interfaces} = ZipTie::Adapters::GenericAdapter::get_interfaces($snmpSession);
	$responses->{uptime}     = _get_uptime($snmpSession);

	# Make a Telnet or SSH connection
	my ( $cliProtocol, $promptRegex ) = _connect($connectionPath);
	$responses->{version} = $cliProtocol->send_and_wait_for( '/home/web/cgi/version.sh', $promptRegex, '60' );
	$responses->{cpuinfo} = $cliProtocol->send_and_wait_for( 'cat /proc/cpuinfo',        $promptRegex, '60' );
	$responses->{dmesg}   = $cliProtocol->send_and_wait_for( 'dmesg',                    $promptRegex, '60' );

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );

	# Get the name of the active config file
	my $activeFileResponse = $cliProtocol->send_and_wait_for( 'cat /home/dcg/activeFile', $promptRegex, '60' );
	( $responses->{'activeConfig'} ) = $activeFileResponse =~ m/(\S+\.xml)/m;
	$LOGGER->debug( 'The active configuration file is ' . $responses->{'activeConfig'} );

	# Create a tarball of all the XML configuration files and SCP it back
	my $filelist = '/home/dcg/active* /home/dcg/userpath.xml /home/dcg/baseline /etc/conf.d/telnetd /etc/conf.d/ftpd /etc/init.d/telnetd';
	
	my $hostname = $cliProtocol->send_and_wait_for( 'hostname', $promptRegex, '60' );
	if ($hostname =~ /\d{5}([a-z\d]{3})/im)
	{
		my $LID = lc($1);	
		$filelist .= ' /home/dcg/'.$LID.'*';
	}
	
	$cliProtocol->send_and_wait_for( 'tar -cvf /tmp/backup.tar '.$filelist, $promptRegex, '60' );
	my $localBackupFile = get_backup_files( $cliProtocol, $connectionPath, "/tmp/backup.tar" );
	$responses->{unzippedBackup} = _parse_tarball($localBackupFile);
	create_config( $responses, $printer );
	unlink($localBackupFile);

	$responses->{activeConfigContents} = $cliProtocol->send_and_wait_for( 'cat /home/dcg/'.$responses->{activeConfig}, $promptRegex, '60' );
	
	# Interfaces come from SNMP walks
	parse_interfaces( $responses, $printer );

	# Local Accounts come from /etc/passwd	
	$responses->{passwd} = $cliProtocol->send_and_wait_for( 'cat /etc/passwd', $promptRegex, '60' );
	parse_local_accounts( $responses, $printer );
	
	# NTP
	$responses->{ntp} = $cliProtocol->send_and_wait_for( 'cat /etc/ntp.conf', $promptRegex, '60' );
	parse_ntp( $responses, $printer );
	
	# SNMP Information
	$responses->{snmpd} = $cliProtocol->send_and_wait_for( 'cat /etc/snmpd.conf', $promptRegex, '60' );
	parse_snmp( $responses, $printer );
	
	# Static Routes
	$responses->{static_routes} = $cliProtocol->send_and_wait_for( "netstat -rn", $promptRegex );
	parse_static_routes( $responses, $printer );

	_disconnect($cliProtocol);
	$printer->close_model();                         # close out the ZiptieElementDocument
	close_model_filehandle($filehandle);             # Make sure to close the model file handle
}

# this function untars a file.  I'm specifically not using
# the ZipTie::Adapters::Utils function for this because the gunzip
# is not reading the bits packed by the RICI properly
sub _parse_tarball
{
	my $tarFilename    = shift;
	my $filenameFilter = shift;

	if ( !$filenameFilter )
	{
		$filenameFilter = ".*";
	}

	# create file pointer for tar file
	my $tar = Archive::Tar->new($tarFilename);

	# get file list from temp tar file and sort them
	my @filenames = sort { lc($a) cmp lc($b) } $tar->list_files;

	# this variable will store the configuration of each file in tar archive
	my $configRepository = {};

	# run through the file list
	for my $filename (@filenames)
	{
		if ( $filename =~ /$filenameFilter/ )
		{
			my $fileContents = $tar->get_content($filename);    # get the content of this file
			if ($fileContents)                                  # directories don't need to be specifically created
			{
				my @pieces        = split( /\//, $filename );
				my $size          = @pieces;
				my $lastFolder    = $configRepository;
				my $hashStatement = "\$configRepository";
				for ( my $i = 0 ; $i < $size ; $i++ )
				{
					my $name = $pieces[$i];
					$hashStatement .= "->{\'$name\'}";
				}
				eval( $hashStatement .= " = \$fileContents;" );
			}
		}
	}

	return $configRepository;
}

sub commands
{
	my $packageName = shift;
	my $commandDoc  = shift;

	my ( $connectionPath, $commands ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );
	my ( $cliProtocol, $devicePromptRegex ) = _connect($connectionPath);

	ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'Sunhillo RICI',
		$cliProtocol, $commands, $devicePromptRegex . '|(#|\$|>)\s*$' );
	_disconnect($cliProtocol);
}

sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );

	# Check to see if SCP is available
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP")
	  if ( defined($connection_path) );

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
	my $connectionPath = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);

	# Make a connection to and successfully authenticate with the device
	my $devicePromptRegex = ZipTie::Adapters::Sunhillo::RICI::AutoLogin::execute( $cliProtocol, $connectionPath );

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
