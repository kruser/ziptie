package ZipTie::Adapters::Juniper::JUNOS;

use strict;

use ZipTie::Adapters::BaseAdapter;
use ZipTie::Adapters::Juniper::JUNOS::AutoLogin;
use ZipTie::Adapters::Juniper::JUNOS::Disconnect qw(disconnect);
use ZipTie::Adapters::Juniper::JUNOS::GetActiveConfig qw(get_active_config);
use ZipTie::Adapters::Juniper::JUNOS::Parsers qw(parse_routing parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Model::XmlPrint;
use ZipTie::Typer;
use ZipTie::Logger;
use ZipTie::Adapters::GenericAdapter;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;
	my $responses   = {};

	# Retrieve the operation XML document that contains all of the IP, protocol, credential, and file server information
	# that is needed to successfully backup a device.
	my $backup_doc = shift;

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the device prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $device_prompt_regex ) = _connect( $connection_path );

	my $configure_prompt_regex = $device_prompt_regex;
	$configure_prompt_regex =~ s/\\>\\/\\#\\/;

	# Store the found prompt as "prompt" on the CLI protocol.
	$cli_protocol->set_prompt_by_name( "prompt", $device_prompt_regex );

	# being creating the model output
	#
	# Grab an output filehandle for the model
	my $filehandle = get_model_filehandle( "JUNOS", $connection_path->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, "common" );
	$printer->open_model();

	# Gather inputs for the model
	$cli_protocol->send_and_wait_for( "set cli screen-length 0", $device_prompt_regex );
	$responses->{showVer}      = $cli_protocol->send_and_wait_for( "show version", $device_prompt_regex );
	$responses->{showUptime}   = $cli_protocol->send_and_wait_for( "show system uptime", $device_prompt_regex );
	$responses->{showHardware} = $cli_protocol->send_and_wait_for( "show chassis hardware | display xml", $device_prompt_regex );
	$responses->{showFirmware} = $cli_protocol->send_and_wait_for( "show chassis firmware", $device_prompt_regex );
	$responses->{showMAC}      = $cli_protocol->send_and_wait_for( "show chassis mac-addresses", $device_prompt_regex );
	$responses->{showRen}      = $cli_protocol->send_and_wait_for( "show chassis routing-engine", $device_prompt_regex );
	$responses->{snmp}         = $cli_protocol->send_and_wait_for( "show configuration snmp | display xml", $device_prompt_regex );
	
	# needed for finding out the device type (tell us whether it is an ex-series, which is a switch)
	$responses->{showMibSystem} = $cli_protocol->send_and_wait_for( "show snmp mib walk system", $device_prompt_regex );
	
	parse_system( $responses, $printer );	
	parse_chassis( $responses, $printer );
	
	delete( $responses->{showVer} );
	delete( $responses->{showUptime} );
	delete( $responses->{showHardware} );
	delete( $responses->{showFirmware} );
	delete( $responses->{showMAC} );
	delete( $responses->{showRen} );
	delete( $responses->{showMibSystem} );
	
	# Enter config mode to grab the candidate config
	$cli_protocol->send_and_wait_for( "configure", $configure_prompt_regex );
	
	# Retrieve the candidate config
	$responses->{candidate} = $cli_protocol->send_and_wait_for( "show", $configure_prompt_regex, 60);
	$responses->{candidate} =~ s/^show//ms;
	$responses->{candidate} =~ s/^\[edit\]//ms;
	$responses->{candidate} =~ s/$configure_prompt_regex//;
	$responses->{candidate} =~ s/^\s*$//msg;

	$cli_protocol->send("quit");
	$responses->{exitConfig} = $cli_protocol->wait_for("\\((yes|no)\\)|$device_prompt_regex");

	if ($responses->{exitConfig} =~ /(yes|no)/)
	{
		$cli_protocol->send_and_wait_for( "", $device_prompt_regex);
	}
	
	# Retrieve the active config
	$responses->{active} = get_active_config($cli_protocol, $connection_path);
	
	# Create the config files
	create_config( $responses, $printer );

	$responses->{showFirewall} = $cli_protocol->send_and_wait_for( "show configuration firewall | display xml", $device_prompt_regex );
	parse_filters( $responses, $printer );
	delete( $responses->{showFirewall} );
	
	$responses->{interfaces}        = $cli_protocol->send_and_wait_for( "show interfaces | display xml",            $device_prompt_regex, 90 );
	$responses->{showOspfInterface} = $cli_protocol->send_and_wait_for( "show ospf interface detail | display xml", $device_prompt_regex );
	parse_interfaces( $responses, $printer );
	delete( $responses->{interfaces} );
	delete( $responses->{showOspfInterface} );

	$responses->{showBgp} = $cli_protocol->send_and_wait_for( "show bgp neighbor | display xml", $device_prompt_regex );
	parse_routing( $responses, $printer );
	delete( $responses->{showBgp} );
	delete( $responses->{active} );
	
	parse_snmp( $responses, $printer );
	
	delete( $responses->{candidate} );
	delete( $responses->{snmp} );
	
	
	disconnect($cli_protocol);
	
	$printer->close_model();

	# Close the model output file handle
	close_model_filehandle($filehandle)
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );
	my $termLen = $cli_protocol->send_and_wait_for( "set cli screen-length 0", $prompt_regex );
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('JUNOS', $cli_protocol, $commands, $prompt_regex.'|([^\s#]+#|\$|^[^\s>]+>)\s*$');
	disconnect($cli_protocol);
	return $result;
}

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the JUNOS device
	my $device_prompt_regex = ZipTie::Adapters::Juniper::JUNOS::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Juniper::JUNOS - Adapter for performing various operations against Juniper JUNOS devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::Juniper::JUNOS;
	ZipTie::Adapters::Juniper::JUNOS::backup( $backup_document );

=head1 DESCRIPTION

This module represents an adapter that can be used to perform various operations against against Juniper JUNOS devices.

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

Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut
