package ZipTie::Adapters::Cisco::CatOS;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::Adapters::Cisco::CatOS::AutoLogin;
use ZipTie::Adapters::Cisco::CatOS::RestoreConfig;
use ZipTie::Adapters::Cisco::CatOS::GetConfig qw(get_config);
use ZipTie::Adapters::Cisco::CatOS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_vtp parse_services);
use ZipTie::Adapters::Cisco::CatOS::Disconnect
	qw(disconnect);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
use ZipTie::ConnectionPath;
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
	
	# Retrieve the operation XML document that contains all of the IP, protocol, credential, and file server information
	# that is needed to successfully backup a device.
	my $backup_doc = shift;

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the device prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $enable_prompt_regex ) = _connect( $connection_path );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'CatOS', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'cisco', "http://www.ziptie.org/model/cisco/1.0 cisco.xsd" );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};
	
	# Get rid of the more prompt
    	my $termLen = $cli_protocol->send_and_wait_for( "set length 0", $enable_prompt_regex );
	if ($termLen =~ /Type help or|Invalid|Command not valid/i)
	{
    		$termLen = $cli_protocol->send_and_wait_for( "terminal length 0", $enable_prompt_regex );
    	}
    	if ($termLen =~ /Type help or|Invalid|Command not valid/i)
    	{
    		# set the --more-- prompt if the term length 0 didn't go through
        	$cli_protocol->set_more_prompt( '(?:<--- More --->|--More--)\s*$', '20');
    	}

    	my $logging = $cli_protocol->send_and_wait_for( "show logging", $enable_prompt_regex );
    	if ($logging =~ /Logging\s+Session:\s+Enable/i)
    	{
    		$cli_protocol->send_and_wait_for( "set logging session disable", $enable_prompt_regex );
    	}
	
	$responses->{config} = get_config( $cli_protocol, $connection_path );

	$responses->{version}	= $cli_protocol->send_and_wait_for( 'show version', $enable_prompt_regex );
	$responses->{bootinfo} = $cli_protocol->send_and_wait_for( 'whichboot', $enable_prompt_regex );
	$responses->{module}	= $cli_protocol->send_and_wait_for( 'show module', $enable_prompt_regex );
	$responses->{mod_ver}	= $cli_protocol->send_and_wait_for( 'show mod ver', $enable_prompt_regex );
	$responses->{'system'}	= $cli_protocol->send_and_wait_for( 'show system', $enable_prompt_regex );
	$responses->{show_fs}   = $cli_protocol->send_and_wait_for( 'show flash devices', $enable_prompt_regex );
	
	foreach my $fileSys ( _get_file_systems( $responses->{show_fs} ) )
	{
		if ($fileSys =~ /disk\d+|slot\d+|bootdisk|bootflash/i)
		{
			$responses->{file_systems}->{$fileSys} = $cli_protocol->send_and_wait_for( "show flash " . $fileSys . ":" , $enable_prompt_regex );
		}
	}

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{version};
	delete $responses->{module};
	delete $responses->{'system'};
	delete $responses->{show_fs};

	create_config( $responses, $printer );

	$responses->{ifalias}		= $cli_protocol->send_and_wait_for( "show snmp ifalias", $enable_prompt_regex );
	if ( $responses->{ifalias} =~ /\bUsage:/mi )
	{
		$responses->{ifalias} = $cli_protocol->send_and_wait_for( "show port ifIndex", $enable_prompt_regex );
	}
	$responses->{interfaces}	= $cli_protocol->send_and_wait_for( "show interface", $enable_prompt_regex );
	$responses->{ports}			= $cli_protocol->send_and_wait_for( "show port", $enable_prompt_regex, 90 );
	$responses->{stp}			= $cli_protocol->send_and_wait_for( "show spantree", $enable_prompt_regex );
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	delete $responses->{ports};
	delete $responses->{ifalias};

	parse_local_accounts( $responses, $printer );

	parse_services( $responses, $printer );

	parse_snmp( $responses, $printer );
	delete $responses->{config};

	parse_stp( $responses, $printer );
	delete $responses->{stp};

	$responses->{static_routes} = $cli_protocol->send_and_wait_for( "show ip route", $enable_prompt_regex );
	parse_static_routes( $responses, $printer );
	delete $responses->{static_routes};

	$responses->{vlans} = $cli_protocol->send_and_wait_for( "show vlan", $enable_prompt_regex );
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};

	$responses->{vtp_info} = $cli_protocol->send_and_wait_for( "show vtp domain", $enable_prompt_regex );
	parse_vtp( $responses, $printer );
	delete $responses->{vtp_info};
	
	# Disconnect from the specified device
	disconnect($cli_protocol);

	# close out the ZiptieElementDocument
	$printer->close_model();

	# Make sure to close the model file handle
	close_model_filehandle($filehandle);
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $enable_prompt_regex ) = _connect( $connection_path );
    	my $termLen = $cli_protocol->send_and_wait_for( "set length 0", $enable_prompt_regex );
    	if ($termLen =~ /Type help or|Invalid|Command not valid/i)
    	{
    		# set the --more-- prompt if the term length 0 didn't go through
        	$cli_protocol->set_more_prompt( '<--- More --->\s*$', '20');
    	}
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('CatOS', $cli_protocol, $commands, '(#|\$|>)\s*$|'.$enable_prompt_regex);
	disconnect($cli_protocol);
	return $result;
}

sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	
	# Check to see if either TFTP or SCP are supported
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );
	my $scp_protocol  = $connection_path->get_protocol_by_name("SCP")  if ( defined($connection_path) );
	
	if ( $restoreFile->get_path() =~ /config/i )
	{
		if ( defined($tftp_protocol) )
		{
			my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);
			ZipTie::Adapters::Cisco::CatOS::RestoreConfig::restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
			disconnect($cli_protocol);
		}
		elsif ( defined($scp_protocol) )
		{
			ZipTie::Adapters::GenericAdapter::scp_restore( $connection_path, $restoreFile );
		}
		else
		{
			$LOGGER->fatal("Unable to restore CatOS config.  Protocols SCP and TFTP are not available.");
		}
	}
	else
	{
		$LOGGER->fatal( "Unable to promote this type of configuration '" . $restoreFile->get_path() . "'." );
	}
}

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the CatOS device
	my $enable_prompt_regex = ZipTie::Adapters::Cisco::CatOS::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the found prompt as "enablePrompt" on the specified CLI protocol.
	$cli_protocol->set_prompt_by_name( "enablePrompt", $enable_prompt_regex );

	# Return the created ZipTie::CLIProtocol object and the enable prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $enable_prompt_regex );
}

sub _get_file_systems
{

	# Given the output of "show flash devices", this method returns
	# an array of the flash file systems
	my @showFileSystems = shift;
	my @fs;
	foreach (@showFileSystems)
	{
		if ($_ =~ /(\S+,.+$)/m)		# Expect a comma delimited list of file systems ...
		{
			@fs = split(/,\s/, $1);
		}
                elsif ($_ =~ /^(\w+)\s*$/m) 	# ... or a single file system.
                {
                        push (@fs, $1);
                }
	}
	return @fs;
}

1;
