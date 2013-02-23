package ZipTie::Adapters::Extreme::Switch;
use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Extreme::Switch::AutoLogin;
use ZipTie::Adapters::Extreme::Switch::RestoreStartupConfig;
use ZipTie::Adapters::Extreme::Switch::Disconnect qw(disconnect);
use ZipTie::Adapters::Extreme::Switch::GetConfig qw(get_config);
use ZipTie::Adapters::Extreme::Switch::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
use ZipTie::SnmpSessionFactory;
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Logger;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	# Getting Params
	my $package_name = shift;
	my $backup_doc   = shift;
	
	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );
   
	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Switch', $connection_path->get_ip_address() );
	
	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common');
	$printer->open_model();
	
	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

    # Executting necesary commands to get the device's configuration data
	$responses->{switch} = $cli_protocol->send_and_wait_for( 'show switch', $prompt_regex );
	$responses->{version} = $cli_protocol->send_and_wait_for( 'show version', $prompt_regex );
	$responses->{accounts} = $cli_protocol->send_and_wait_for( 'show accounts', $prompt_regex );
	$responses->{routes} = $cli_protocol->send_and_wait_for( 'show iproute detail', $prompt_regex, 120 );
	$responses->{stp} = $cli_protocol->send_and_wait_for( 'show stpd detail', $prompt_regex );
	$responses->{vlans} = $cli_protocol->send_and_wait_for( 'show vlan detail', $prompt_regex );
	$responses->{memory} = $cli_protocol->send_and_wait_for( 'show memory', $prompt_regex );
	
	# Create a Net::SNMP session
	my $snmp_session = ZipTie::SnmpSessionFactory->create( $connection_path );

	# Use SNMP to gather the interfaces model
	$responses->{interfaces} = ZipTie::Adapters::GenericAdapter::get_interfaces($snmp_session);

	$responses->{config} = get_config( $cli_protocol, $connection_path, $prompt_regex);

	# Parsing data
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{version};
	delete $responses->{memory};
	create_config( $responses, $printer );
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};
	parse_local_accounts( $responses, $printer );
	delete $responses->{accounts};
	parse_snmp( $responses, $printer );
	delete $responses->{switch};
	delete $responses->{config};
	parse_stp( $responses, $printer );
	delete $responses->{stp};
	parse_static_routes( $responses, $printer );
	delete $responses->{routes};
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};
	
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
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Switch', $cli_protocol, $commands, $prompt_regex.'|(#|\$|>)\s*$');
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
			#This is the first time we will attempt to restore the 
			#configuration, so we send a 1 to the following subroutine
			ZipTie::Adapters::Extreme::Switch::RestoreStartupConfig::restore_via_tftp( $connection_path, $cli_protocol, $restoreFile, $prompt_regex, 1 );
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

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);
	
	
	# Make a connection to and successfully authenticate with the device
	my $device_prompt_regex =ZipTie::Adapters::Extreme::Switch::AutoLogin::execute( $cli_protocol, $connection_path );
	
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}


1;

__END__

=head1 NAME

ZipTie::Adapters::Extreme::Switch - Example adapter for performing various operations against a particular family of devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::Extreme::Switch;
	ZipTie::Adapters::Extreme::Switch::backup( $backup_document );

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
Date: August 29, 2007

=cut
