package ZipTie::Adapters::Nortel::BayStack;

use strict;

use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::Nortel::BayStack::AutoLogin;
use ZipTie::Adapters::Nortel::BayStack::Disconnect qw(disconnect);
use ZipTie::Adapters::Nortel::BayStack::GetConfig qw(get_config);
use ZipTie::Adapters::Nortel::BayStack::Parsers qw(parse_vlans parse_stp create_config parse_static_routes parse_chassis parse_snmp parse_system parse_interfaces);
use ZipTie::Adapters::Nortel::BayStack::RestoreConfig;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Model::XmlPrint;
use ZipTie::Typer;
use ZipTie::Logger;
use ZipTie::SNMP;
use ZipTie::SnmpSessionFactory;
use ZipTie::Adapters::GenericAdapter;
use Data::Dumper;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $packageName = shift;
	my $responses   = {};

	# Retrieve the operation XML document that contains all of the IP, protocol, credential, and file server information
	# that is needed to successfully backup a device.
	my $backup_doc = shift;

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ($connection_path) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the device prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $prompt_regex ) = _connect($connection_path);

	# Grab an output filehandle for the model
	my $filehandle = get_model_filehandle( "BayStack", $connection_path->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, "common" );
	$printer->open_model();

	if ($prompt_regex)
	{

		# in CLI mode
		my $resp = $cli_protocol->send_and_wait_for( 'term length 0', $prompt_regex );
		if ( $resp =~ /invalid/i )
		{
			$cli_protocol->send_and_wait_for( 'term length 132', $prompt_regex );
		}
		$responses->{ip_config} = $cli_protocol->send_and_wait_for( 'show ip',    $prompt_regex );
		$responses->{system} = $cli_protocol->send_and_wait_for( 'show sys-info',    $prompt_regex );
		$responses->{snmp}   = $cli_protocol->send_and_wait_for( 'show snmp-server', $prompt_regex );
		$responses->{tech}   = $cli_protocol->send_and_wait_for( 'show tech', $prompt_regex );

		# test for running-config
		$resp = $cli_protocol->send_and_wait_for( 'copy running-config', $prompt_regex );
		my $hasRunningConfig = ( $resp =~ /incomplete command/i ) ? 1 : 0;

		$responses->{config} = get_config( $cli_protocol, $connection_path, 'cli' );
		if ($hasRunningConfig)
		{
			$responses->{running_config} = get_config( $cli_protocol, $connection_path, 'cli_running' );
		}
	}
	else
	{
		$cli_protocol->get_response(0.25);    # flush out the buffer
		
		$cli_protocol->send_as_bytes('73');   # send a 's' for system
		$responses->{system} = $cli_protocol->get_response(0.25);

		unless ( $responses->{system} =~ /SW:V([3-5])/i )    # establish lowest and highest supported code versions
		{
			$LOGGER->fatal("Unsupported software version!");
		}

		$cli_protocol->send_as_bytes_and_wait( '03', 'select option.*$' );    # ctrl+c to get back to main menu
		
		$cli_protocol->send_as_bytes('69');   # send a 'i' for ip configuration
		$responses->{ip_config} = $cli_protocol->get_response(0.25);
		$cli_protocol->send_as_bytes_and_wait( '03', 'select option.*$' );    # ctrl+c to get back to main menu

		$cli_protocol->send_as_bytes('6D');
		$responses->{snmp} = $cli_protocol->get_response(0.25);
		if ( $responses->{snmp} =~ /ommunity Strings and Trap Addresses/ )
		{
			$cli_protocol->send_as_bytes('63');
			$responses->{snmp} = $cli_protocol->get_response(0.25);
		}
		$cli_protocol->send_as_bytes_and_wait( '03', 'select option.*$' );    # ctrl+c to get back to main menu

		$cli_protocol->send_as_bytes_and_wait( '77', 'Configuration.*$' );    # switch configuration
		$cli_protocol->send_as_bytes('70');                                   # port configuration
		$responses->{ports} = $cli_protocol->get_response(0.25);
		if ( $responses->{ports} =~ /More.../ )
		{
			$cli_protocol->send_as_bytes('0E');                               # ctrl+n to get the next ports
			$responses->{ports} .= $cli_protocol->get_response(0.25);
		}
		$cli_protocol->send_as_bytes_and_wait( '03', 'select option.*$' );    # ctrl+c to get back to main menu

		$cli_protocol->send_as_bytes_and_wait( '70', 'Menu.*$' );             # spanning-tree mode
		$cli_protocol->send_as_bytes('63');
		$responses->{stp_ports} = $cli_protocol->get_response(0.25);
		if ( $responses->{stp_ports} =~ /More.../ )
		{
			$cli_protocol->send_as_bytes('0E');                               # ctrl+n to get the next ports
			$responses->{stp_ports} .= $cli_protocol->get_response(0.25);
		}
		$cli_protocol->send_as_bytes_and_wait( '03', 'select option.*$' );    # ctrl+c to get back to main menu

		$responses->{config} = get_config( $cli_protocol, $connection_path, 'menu' );
	}
	disconnect($cli_protocol);

	# Create a Net::SNMP session
	my $snmp_session = ZipTie::SnmpSessionFactory->create($connection_path);

	# Use SNMP to gather the interfaces model
	$LOGGER->debug("Retrieving interfaces via SNMP.  This may take awhile ...");
	$responses->{snmp_interfaces} = ZipTie::Adapters::GenericAdapter::get_interfaces($snmp_session);
	$responses->{snmp_system}     = ZipTie::Adapters::GenericAdapter::get_snmp($snmp_session);
	$responses->{snmp_stp}        = ZipTie::SNMP::walk( $snmp_session, '.1.3.6.1.4.1.2272.1.13' );     # rcStg
	$responses->{snmp_vlans}      = ZipTie::SNMP::walk( $snmp_session, '.1.3.6.1.4.1.2272.1.3' );      # rcVlan

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	create_config( $responses, $printer );
	my $subnets = parse_interfaces( $responses, $printer );
	parse_snmp( $responses, $printer );
	parse_stp( $responses, $printer );
	parse_static_routes( $responses, $printer, $subnets );
	parse_vlans( $responses, $printer );
	$printer->close_model();

	while ( (my $k, my $v) = each(%{$responses}) )
	{
		delete $responses->{$k};
	}

	# Close the model output file handle
	close_model_filehandle($filehandle);
}

sub restore
{
	my $packageName = shift;
	my $commandDoc  = shift;
	my ( $connectionPath, $restoreFile ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );

	# Check to see if TFTP is supported
	my $tftpProtocol = $connectionPath->get_protocol_by_name("TFTP") if ( defined($connectionPath) );

	if ( $restoreFile->get_path() =~ /^\/?config$/ )
	{
		if ( defined($tftpProtocol) )
		{
			my ( $cliProtocol, $promptRegex ) = _connect($connectionPath);
			ZipTie::Adapters::Nortel::BayStack::RestoreConfig::restore_via_tftp( $connectionPath, $cliProtocol, $restoreFile, $promptRegex );
			disconnect($cliProtocol);
		}
		else
		{
			$LOGGER->fatal("Unable to restore the BayStack config without TFTP enabled.");
		}
	}
	else
	{
		$LOGGER->fatal( "Unable to promote this type of configuration '" . $restoreFile->get_path() . "'." );
	}
}

#
sub vt_output
{
	print Dumper(@_);
	my ( $vtobject, $type, $arg1, $arg2, $private ) = @_;

	if ( $type eq 'OUTPUT' )
	{
		$private->print($arg1);
	}
}

sub commands
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect($connection_path);
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'BayStack', $cli_protocol, $commands, $prompt_regex . '|(#|\$|>)\s*$' );
	disconnect($cli_protocol);
	return $result;
}

sub _connect
{

	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the BayStack device
	my $prompt_regex = ZipTie::Adapters::Nortel::BayStack::AutoLogin::execute( $cli_protocol, $connection_path );
	if (!$prompt_regex)
	{
		$cli_protocol->turn_vt102_on( 150, 25 );
	}

	# Return the created ZipTie::CLIProtocol object and the prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $prompt_regex );
}

1;
