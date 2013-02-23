package ZipTie::Adapters::Thales::Radio;

use strict;

use ZipTie::Adapters::Thales::Radio::AutoLogin;
use ZipTie::Adapters::Thales::Radio::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_ntp);
use ZipTie::Adapters::Thales::Radio::GetBackUpFiles qw(get_backup_files);
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
	my $filehandle = get_model_filehandle( 'Thales Radio', $connectionPath->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	my ( $cliProtocol, $promptRegex ) = _connect($connectionPath);
	$responses->{uptime}   = $cliProtocol->send_and_wait_for( 'uptime',            $promptRegex, '60' );
	$responses->{hostname} = $cliProtocol->send_and_wait_for( 'hostname -v',       $promptRegex, '60' );
	$responses->{cpuinfo}  = $cliProtocol->send_and_wait_for( 'cat /proc/cpuinfo', $promptRegex, '60' );
	$responses->{version}  = $cliProtocol->send_and_wait_for( 'uname -a',          $promptRegex, '60' );
	$responses->{memory}   = $cliProtocol->send_and_wait_for( 'free',              $promptRegex, '60' );

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );

	# Configuration files come from all over
	my $filelist =
'/usr/local/etc/default/*.xml /usr/local/etc/default/*.cfg /usr/local/etc/backup/*.xml /usr/local/etc/backup/*.cfg /etc/snmp/snmp* /etc/ssh/sshd_config /etc/ntp.conf /etc/ntp/ntpservers';
	$cliProtocol->send_and_wait_for( 'tar -cvf /tmp/backup.tar ' . $filelist, $promptRegex, '60' );
	my $localBackupFile = get_backup_files( $cliProtocol, $connectionPath, "/tmp/backup.tar" );
	$responses->{unzippedBackup} = _parse_tarball($localBackupFile);
	create_config( $responses, $printer );

	# Interfaces come from the ifconfig output
	$responses->{ifconfig} = $cliProtocol->send_and_wait_for( '/sbin/ifconfig -a', $promptRegex, '60' );
	parse_interfaces( $responses, $printer );

	# Local Accounts come from /etc/passwd
	$responses->{passwd} = $cliProtocol->send_and_wait_for( 'cat /etc/passwd', $promptRegex, '60' );
	parse_local_accounts( $responses, $printer );

	# NTP
	$responses->{ntp} = $cliProtocol->send_and_wait_for( 'cat /etc/ntp.conf', $promptRegex, '60' );
	parse_ntp( $responses, $printer );

	# SNMP comes from the snmpd.conf file retrieved in the configuration tarball
	parse_snmp( $responses, $printer );

	# Static Routes
	$responses->{static_routes} = $cliProtocol->send_and_wait_for( "netstat -rn", $promptRegex );
	parse_static_routes( $responses, $printer );

	_disconnect($cliProtocol);
	$printer->close_model();                # close out the ZiptieElementDocument
	close_model_filehandle($filehandle);    # Make sure to close the model file handle
	unlink($localBackupFile);
}

sub commands
{
	my $packageName = shift;
	my $commandDoc  = shift;

	my ( $connectionPath, $commands ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );
	my ( $cliProtocol, $devicePromptRegex ) = _connect($connectionPath);

	ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'Thales Radio', $cliProtocol, $commands, $devicePromptRegex . '|(#|\$|>)\s*$' );
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
	my $devicePromptRegex = ZipTie::Adapters::Thales::Radio::AutoLogin::execute( $cliProtocol, $connectionPath );

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

# this function untars a file.  I'm specifically not using
# the ZipTie::Adapters::Utils function for this because the gunzip
# is not reading the bits packed by the Thales properly
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

1;
