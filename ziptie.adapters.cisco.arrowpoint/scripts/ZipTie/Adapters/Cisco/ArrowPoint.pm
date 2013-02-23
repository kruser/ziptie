package ZipTie::Adapters::Cisco::ArrowPoint;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Cisco::ArrowPoint::GetConfig qw(get_startup_config get_running_config get_boot_config);
use ZipTie::Adapters::Cisco::ArrowPoint::RestoreStartupConfig;
use ZipTie::Adapters::Cisco::ArrowPoint::AutoLogin;
use ZipTie::Adapters::Cisco::ArrowPoint::Disconnect qw(disconnect);
use ZipTie::Adapters::Cisco::ArrowPoint::Parsers
  qw(parse_routing create_config  parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp get_file_list);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
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
	my $backup_doc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path, $credentials ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path, $credentials );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'ArrowPoint', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'cisco', "http://www.ziptie.org/model/cisco/1.0 cisco.xsd" );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	# 	Disabling Terminal Length
	my $termLen = $cli_protocol->send_and_wait_for( 'no terminal more', $prompt_regex );

	# Executting necesary commands to get the device's configuration data
	$responses->{config} = get_startup_config( $cli_protocol, $connection_path, $prompt_regex );
	$responses->{version}    = $cli_protocol->send_and_wait_for( 'show version',           $prompt_regex );
	$responses->{chassis}    = $cli_protocol->send_and_wait_for( 'show chassis',           $prompt_regex );
	$responses->{inventory}  = $cli_protocol->send_and_wait_for( 'show chassis inventory', $prompt_regex );
	$responses->{uptime}     = $cli_protocol->send_and_wait_for( 'show uptime',            $prompt_regex );
	$responses->{interfaces} = $cli_protocol->send_and_wait_for( 'show interface',         $prompt_regex );
	$responses->{memory}     = $cli_protocol->send_and_wait_for( 'show system-resources',  $prompt_regex );
	$responses->{disk}       = $cli_protocol->send_and_wait_for( 'show disk',              $prompt_regex );
	$responses->{circuits}   = $cli_protocol->send_and_wait_for( 'show circuits',          $prompt_regex );
	$responses->{routes}     = $cli_protocol->send_and_wait_for( 'show ip routes static',  $prompt_regex );

	# Calling the parsers.
	parse_system( $responses, $printer );
	delete $responses->{version};
	delete $responses->{uptime};
	parse_chassis( $responses, $printer );
	delete $responses->{disk};
	delete $responses->{memory};
	delete $responses->{inventory};

	# Calling a local method to get the contents of the file_names retrieved previuosly and add running-conf and boot-conf
	my $files = get_configurations( $responses, $cli_protocol, $connection_path, $prompt_regex );

	# Calling the parser to print the configRepository element.
	create_config( $responses, $printer, $files );
	$responses->{"running-config"} = $files->{"running-config"}->{text};
	parse_filters( $responses, $printer );
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	parse_local_accounts( $responses, $printer );
	parse_snmp( $responses, $printer );
	delete $responses->{config};

	# Calling local method to get all vlans info.
	my $vlans = get_vlan_stp( $responses, $cli_protocol, $prompt_regex );
	parse_stp( $responses, $printer, $vlans );
	delete $responses->{chassis};
	parse_static_routes( $responses, $printer );
	delete $responses->{routes};
	parse_vlans( $responses, $printer );
	delete $responses->{circuits};
	delete $responses->{"running-config"};
	disconnect($cli_protocol);
	$printer->close_model();
	close_model_filehandle($filehandle);
}

sub commands
{
	my $package_name = shift;
	my $command_doc  = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect($connection_path);
	my $termLen = $cli_protocol->send_and_wait_for( "no terminal more", $prompt_regex );
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'ArrowPoint', $cli_protocol, $commands, $prompt_regex.'|(#|\$|>)\s*$' );
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

	if ( $restoreFile->get_path() =~ /startup-config/i )
	{
		if ( defined($tftp_protocol) )
		{
			my ( $cli_protocol, $prompt_regex ) = _connect($connection_path);
			ZipTie::Adapters::Cisco::ArrowPoint::RestoreStartupConfig::restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $prompt_regex );
			disconnect($cli_protocol);
		}
		else
		{
			$LOGGER->fatal("Unable to restore startup config.  Protocol TFTP is not available.");
		}
	}
	else
	{
		$LOGGER->fatal( "Unable to promote this type of configuration '" . $restoreFile->get_path() . "'." );
	}
}


sub get_configurations
{
	my ( $responses, $cli_protocol, $connection_path, $regex ) = @_;
	my $files = {};
	$files->{"startup-config"}->{"text"}       = $responses->{config};
	$files->{"startup-config"}->{"promotable"} = 'true';
	$files->{"running-config"}->{"text"}       = get_running_config( $cli_protocol, $connection_path, $regex );
	$files->{"running-config"}->{"promotable"} = 'false';
	$files->{"boot-config"}->{"text"}       = get_boot_config( $cli_protocol, $regex );
	$files->{"boot-config"}->{"promotable"} = 'false';
	return $files;

}

# Helping method to get the list of vlan information.
sub get_vlan_stp
{
	my ( $in, $cli_protocol, $regex ) = @_;
	my $gotLine = 0;
	my $vlans   = {};
	while ( $in->{circuits} =~ /^(\S+)/mig )
	{
		if ( $1 =~ /-+/ )
		{
			$gotLine = 1;
		}
		if ( $gotLine == 1 )
		{
			my $vlan = $1;
			if ( $vlan =~ /\S+/ )
			{
				$vlans->{$vlan} = $cli_protocol->send_and_wait_for( "show bridge status $vlan", $regex );
			}
		}
	}
	return $vlans;
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
	my $device_prompt_regex = ZipTie::Adapters::Cisco::ArrowPoint::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );

	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;

__END__

sub get_configurations
{
	my ( $files, $cli_protocol,$connection_path, $regex ) = @_;
	while ((my $key,my $value) = each %{$files})
	{
		$files->{$key} = get_file($cli_protocol,$connection_path, $regex,$key);
	}	
	$files->{"boot-config"} = get_boot_config($cli_protocol,$regex);
	$files->{"running-config"} = get_running_config($cli_protocol,$regex);
	return $files;
	
}

=head1 NAME

ZipTie::Adapters::Cisco::ArrowPoint - Example adapter for performing various operations against a particular family of devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::ArrowPoint;
	ZipTie::Adapters::Cisco::ArrowPoint::backup( $backup_document );

=head1 DESCRIPTION

This module represents an example of an adapter that can be used to perform various operations against a particular
family of devices.

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

Contributor(s): Ashuin Sharma (asharma@isthmusit.com), rkruse, Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut
