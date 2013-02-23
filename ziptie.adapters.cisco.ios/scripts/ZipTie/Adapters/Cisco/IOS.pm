package ZipTie::Adapters::Cisco::IOS;

use strict;
use warnings;

use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::Adapters::BaseAdapter;
use ZipTie::Adapters::Cisco::IOS::AutoLogin;
use ZipTie::Adapters::Cisco::IOS::GetRunningConfig qw(get_running_config);
use ZipTie::Adapters::Cisco::IOS::GetStartupConfig qw(get_startup_config);
use ZipTie::Adapters::Cisco::IOS::Parsers
  qw(parse_vtp parse_static_routes parse_vlans parse_routing parse_access_ports parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_stp parse_services parse_mpls parse_qos);
use ZipTie::Adapters::Cisco::IOS::Disconnect qw(disconnect);
use ZipTie::Adapters::Cisco::IOS::RestoreStartupConfig;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::ConnectionPath;
use ZipTie::Typer;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;

	# Retrieve the operation XML document that contains all of the IP, protocol, credential, and file server information
	# that is needed to successfully backup a device.
	my $backup_doc = shift;
	my $responses  = {};

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ($connection_path) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the device prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);

	# Get rid of the more prompt
	my $termLen = $cli_protocol->send_and_wait_for( "terminal length 0", $enable_prompt_regex );

	# Grab an output filehandle for the model
	my $filehandle = get_model_filehandle( "IOS", $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'cisco', "http://www.ziptie.org/model/cisco/1.0 cisco.xsd" );
	$printer->open_model();

	# Gather inputs for the model
	$responses->{version}        = $cli_protocol->send_and_wait_for( "show version", $enable_prompt_regex );
	my $isCat1900 = $responses->{version} =~ /Catalyst (19|28)\w+/i;
	$responses->{running_config} = get_running_config( $cli_protocol,                $connection_path );
	$responses->{snmp}           = $cli_protocol->send_and_wait_for( "show snmp",    $enable_prompt_regex );
	parse_system( $responses, $printer );
	$responses->{show_fs} = $cli_protocol->send_and_wait_for( "show file systems", $enable_prompt_regex );
	foreach my $fileSys ( _get_file_systems( $responses->{show_fs} ) )
	{
		$responses->{file_systems}->{$fileSys} = $cli_protocol->send_and_wait_for( "show " . $fileSys, $enable_prompt_regex );
	}

	if ( $responses->{version} =~ /\bWS-C\d{4}|Cisco\s*76\d{2}/i )
	{
		# on switches and 7600 routers execute...
		
		my $shMod = $cli_protocol->send_and_wait_for( "show module",    $enable_prompt_regex );
		if ( $shMod !~ /Invalid|Incomplete/mi ) #only set {show_module} if the command was successful
		{
			$responses->{show_module} = $shMod;
		}
		
		$responses->{show_power}     = $cli_protocol->send_and_wait_for( "show power",     $enable_prompt_regex );
		$responses->{show_inventory} = $cli_protocol->send_and_wait_for( "show inventory", $enable_prompt_regex );
		$responses->{show_mod_ver}   = $cli_protocol->send_and_wait_for( "show mod ver",   $enable_prompt_regex );
	}
	else
	{

		# try show diagbus first
		my $diagbus = $cli_protocol->send_and_wait_for( "show diagbus", $enable_prompt_regex );
		if ( $diagbus =~ /Invalid/mi )
		{

			# use "show diag" when diagbus fails
			my $diag = $cli_protocol->send_and_wait_for( "show diag", $enable_prompt_regex );
			if ( $diag !~ /Invalid|Incomplete/mi )
			{
				$responses->{show_diag} = $diag;
			}
		}
		else
		{
			$responses->{show_diag} = $diagbus;
		}

	}

	parse_chassis( $responses, $printer );
	delete $responses->{version};

	$responses->{startup_config} = get_startup_config( $cli_protocol, $connection_path ) if (!$isCat1900);
	create_config( $responses, $printer );
	delete $responses->{startup_config};

	parse_access_ports( $responses, $printer );

	$responses->{access_lists} = $cli_protocol->send_and_wait_for( "show access-lists", $enable_prompt_regex, 120 );
	parse_filters( $responses, $printer );
	delete $responses->{access_lists};

	$responses->{interfaces} = $cli_protocol->send_and_wait_for( "show interfaces", $enable_prompt_regex, 120 );
	$responses->{ospf_ints} = $cli_protocol->send_and_wait_for( "show ip ospf interface", $enable_prompt_regex );
	$responses->{standby} = $cli_protocol->send_and_wait_for( "show standby", $enable_prompt_regex );
	$responses->{vrrp} = $cli_protocol->send_and_wait_for( "show vrrp", $enable_prompt_regex );
	$responses->{glbp} = $cli_protocol->send_and_wait_for( "show glbp", $enable_prompt_regex );
	my $subnets = parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	delete $responses->{ospf_ints};

	parse_local_accounts( $responses, $printer );
	
	parse_mpls( $responses, $printer );
	parse_qos( $responses, $printer );

	$responses->{ospf}      = $cli_protocol->send_and_wait_for( "show ip ospf",           $enable_prompt_regex );
	$responses->{protocols} = $cli_protocol->send_and_wait_for( "show ip protocols",      $enable_prompt_regex );
	$responses->{eigrp}     = $cli_protocol->send_and_wait_for( "show ip eigrp topology", $enable_prompt_regex );
	parse_routing( $responses, $printer );
	delete $responses->{ospf};
	delete $responses->{protocols};
	delete $responses->{eigrp};

	parse_services( $responses, $printer );

	parse_snmp( $responses, $printer );

	$responses->{stp} = $cli_protocol->send_and_wait_for( "show spanning-tree", $enable_prompt_regex );
	parse_stp( $responses, $printer );
	delete $responses->{stp};
	delete $responses->{stp_summary};
	
	parse_static_routes( $responses, $printer, $subnets );
	delete $responses->{running_config};

	$responses->{vlans} = $cli_protocol->send_and_wait_for( "show vlan", $enable_prompt_regex );
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};

	$responses->{vtp_status} = $cli_protocol->send_and_wait_for( "show vtp status", $enable_prompt_regex );
	parse_vtp( $responses, $printer );
	delete $responses->{vtp_status};

	$printer->close_model;

	# Close the model output file handle
	close_model_filehandle($filehandle);

	# Disconnect from the specified device
	disconnect($cli_protocol);
}

sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );

	# Check to see if either TFTP or SCP are supported
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );
	my $scp_protocol  = $connection_path->get_protocol_by_name("SCP")  if ( defined($connection_path) );

	if ( $restoreFile->get_path() =~ /startup-config/i )
	{
		if ( defined($tftp_protocol) )
		{
			my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);
			ZipTie::Adapters::Cisco::IOS::RestoreStartupConfig::restore_via_tftp( $connection_path, $cli_protocol, $restoreFile );
			disconnect($cli_protocol);
		}
		elsif ( defined($scp_protocol) )
		{
			ZipTie::Adapters::GenericAdapter::scp_restore( $connection_path, $restoreFile );
		}
		else
		{
			$LOGGER->fatal("Unable to restore startup config.  Protocols SCP and TFTP are not available.");
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

	# Make a connection to and successfully authenticate with the IOS device
	my $enable_prompt_regex = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the found prompt as "enablePrompt" on the specified CLI protocol.
	$cli_protocol->set_prompt_by_name( "enablePrompt", $enable_prompt_regex );

	# Return the created ZipTie::CLIProtocol object and the enable prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $enable_prompt_regex );
}

sub _get_file_systems
{

	# give the output of "show file systems", this method returns
	# and array of the file systems
	my $showFileSystems = shift;
	my @fs;
	while ( $showFileSystems =~ /^\*?\s+\d+\s+\d+\s+\b(\S+)\b\s+[A-Za-z]+\s+(\S+):/mg )
	{
		my $type = $1;
		my $name = $2;
		if ( $type !~ /opaque|nvram/i )
		{
			push( @fs, $name );
		}
	}
	return @fs;
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Cisco::IOS - Adapter for performing various operations against Cisco IOS devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::IOS;
	ZipTie::Adapters::Cisco::IOS::backup( $backup_document );

=head1 DESCRIPTION

This module represents an adapter that can be used to perform various operations against against Cisco IOS devices.

Generally you would run this module through the ZipTie C<invoke.pl> script.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<backup($backup_document)>

Performs the backup of the device that is described in the specified XML document.  This XML document contains
a "connectionPath" element that contains the IP/hostname, protocol, credential, and file server information that
may be needed to connect to, authenticate with, and back up the device in question.  This XML will be parsed into
a C<ZipTie::ConnectionPath> object to help easily access this vital information.

The act of backing up a device means that information about a device will be retreived, as well as the configuration
data/files for that device.  All of this collected information will be used to populate the ZipTie Element Document,
which is an open and extensible format for describing a network device.

The return value for this method will be a string containing the successfully populated ZipTie Element Document.

=back

=head1 PRIVATE SUB-ROUTINES

=over 12

=item C<_connect($connection_path)>

Creates the initial CLI connection to the device.  A list is returned containing two elements: the first is a
C<ZipTie::CLIProtocol> object that is a CLI client that can communitcate with the device, and the second is a
regular expression that can be used to match the primary prompt of the device.  This is useful when sending
commands to and receiving responses from the device through the C<ZipTie::CLIProtocol> object and being able to
know when a command has generated all the output and returned back to the primary prompt.

=item C<_get_file_systems($show_file_systems_response)>

Parses the response of the "show file systems" and returns an array representing the file system of the Cisco Security
Appliance device.

=back

=head1 LICENSE

The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS"
basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
License for the specific language governing rights and limitations
under the License.

The Original Code is Ziptie Client Framework.

The Initial Developer of the Original Code is AlterPoint.
Portions created by AlterPoint are Copyright (C) 2006,
AlterPoint, Inc. All Rights Reserved.

=head1 AUTHOR

Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut
