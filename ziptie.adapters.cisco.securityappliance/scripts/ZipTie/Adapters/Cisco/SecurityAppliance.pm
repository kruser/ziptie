package ZipTie::Adapters::Cisco::SecurityAppliance;

use strict;

use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin;
use ZipTie::Adapters::Cisco::SecurityAppliance::GetConfig qw(get_config);
use ZipTie::Adapters::Cisco::SecurityAppliance::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_object_groups parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Cisco::SecurityAppliance::Disconnect
	qw(disconnect);
use ZipTie::Adapters::Cisco::SecurityAppliance::Restore;
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
	# Also be sure to capture the enable prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $enable_prompt_regex ) = _connect( $connection_path );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'SecurityAppliance', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	# Store pager settings
	my $pager = 0;
	$_ = $cli_protocol->send_and_wait_for( "show pager", $enable_prompt_regex );
	if ( /pager lines (\d+)/mi )
	{
		$pager = $1;
	}

	# Configure the terminal page to be 24 in length
	$cli_protocol->send_and_wait_for( "terminal pager 0", $enable_prompt_regex );
	
	# Set the more prompt
    $cli_protocol->set_more_prompt( '<--- More --->\s*$', '20');

	# now output the configuration
	$responses->{running_config} = get_config( $cli_protocol, $connection_path, 'running-config' );
	if ($responses->{running_config} =~ /% Invalid input detected|for a list of available commands/)
	{
		$LOGGER->fatal_error_code($INSUFFICIENT_PRIVILEGE, $cli_protocol->get_ip_address(), "Unable to issue \"show running-config\"");
	}
	$responses->{running_config} =~ s/$enable_prompt_regex$//;
	$responses->{running_config} =~ s/^.*?(?=^(?:!|\S+\s+Version\s+\d))//mis;
	$responses->{running_config} =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt
	$responses->{version}		 = $cli_protocol->send_and_wait_for( 'show version', $enable_prompt_regex );
	$responses->{version}        =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );

	# change to system context where available (FWSMs)
	my $changeSystem = $cli_protocol->send_and_wait_for( 'change system', $enable_prompt_regex.'|[#>]\s*$' );
	if ($changeSystem !~ /$enable_prompt_regex/)
	{
		my $systemPrompt = ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin::_get_prompt( $cli_protocol );
		$responses->{na_running_config} = get_config( $cli_protocol, $connection_path, 'running-config' );
		$responses->{na_running_config} =~ s/$systemPrompt//;
		$responses->{na_running_config} =~ s/^.*?(?=^(?:!|\S+\s+Version\s+\d))//mis;
		$responses->{na_running_config} =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt
		$responses->{na_startup_config} = get_config( $cli_protocol, $connection_path, 'startup-config' );
		$responses->{na_startup_config} =~ s/$systemPrompt//;
		$responses->{na_startup_config} =~ s/^.*?(?=^(?:!|\S+\s+Version\s+\d))//mis;
		$responses->{na_startup_config} =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt
		
		my ($adminContext) = $responses->{na_running_config} =~ /^admin-context\s+(\S+)/mi;		
		$cli_protocol->send_and_wait_for( 'change context '.$adminContext, $enable_prompt_regex );
	}

	$responses->{startup_config} = get_config( $cli_protocol, $connection_path, 'startup-config' );
	$responses->{startup_config} =~ s/$enable_prompt_regex$//;
	$responses->{startup_config} =~ s/^.*?(?=^(?:!|\S+\s+Version\s+\d))//mis;
	$responses->{startup_config} =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt
	create_config( $responses, $printer );
	delete $responses->{version};
	delete $responses->{startup_config};
	delete $responses->{na_running_config};
	delete $responses->{na_startup_config};

	$responses->{names}	= $cli_protocol->send_and_wait_for( 'show names', $enable_prompt_regex );
	$responses->{names} =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt

	# output large lists
	#$responses->{network_object_group}	= $cli_protocol->send_and_wait_for( 'show object-group network', $enable_prompt_regex );
	#$responses->{service_object_group}	= $cli_protocol->send_and_wait_for( 'show object-group service', $enable_prompt_regex );
	#$responses->{protocol_object_group}	= $cli_protocol->send_and_wait_for( 'show object-group protocol', $enable_prompt_regex );

	# remove more prompt
	#$responses->{network_object_group}	=~ s/<---\s+More\s+--->\s*//mig;
	#$responses->{service_object_group}	=~ s/<---\s+More\s+--->\s*//mig;
	#$responses->{protocol_object_group}	=~ s/<---\s+More\s+--->\s*//mig;

	parse_object_groups( $responses, $printer );

	parse_filters( $responses, $printer );

	#delete $responses->{network_object_group};
	#delete $responses->{service_object_group};
	#delete $responses->{protocol_object_group};
	delete $responses->{names};

	$responses->{interfaces} = $cli_protocol->send_and_wait_for( "show interface detail", $enable_prompt_regex );
	$responses->{interfaces} =~ s/<---\s+More\s+--->\s*//mig; # Strip more prompt
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};

	parse_local_accounts( $responses, $printer );

	parse_snmp( $responses, $printer );

	parse_static_routes( $responses, $printer );
	delete $responses->{running_config};

	# Restore pager settings
	$cli_protocol->send_and_wait_for( "terminal pager $pager", $enable_prompt_regex );

	# close out the ZiptieElementDocument
	$printer->close_model();
	
	# Make sure to close the model file handle
	close_model_filehandle($filehandle);
	
	# Disconnect from the specified device
	disconnect($cli_protocol);
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $enable_prompt_regex ) = _connect( $connection_path );
	my $termLen = $cli_protocol->send_and_wait_for( "terminal length 0", $enable_prompt_regex );
	
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('SecurityAppliance', $cli_protocol, $commands, $enable_prompt_regex.'|(#|\$|>)\s*$');
	disconnect($cli_protocol);
	return $result;
}

# Invockes the restore module
sub restore
{
	my $package_name = shift;
	my $command_doc  = shift;

	# Get the connection path and the restore file
	my ( $connection_path, $restoreFile ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the enable prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $enable_prompt_regex ) = _connect( $connection_path );

	# Restore the configuration
	ZipTie::Adapters::Cisco::SecurityAppliance::Restore::execute( $connection_path, $cli_protocol, $enable_prompt_regex, $restoreFile );

	# Disconnect from the specified device
	disconnect($cli_protocol);
}

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);
	$cli_protocol->set_more_prompt( '<--- More --->\s*$', '20');

	# Make a connection to and successfully authenticate with the Security Appliance device
	my $enable_prompt_regex = ZipTie::Adapters::Cisco::SecurityAppliance::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the found prompt as "enablePrompt" on the specified CLI protocol.
	$cli_protocol->set_prompt_by_name( "enablePrompt", $enable_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the enable prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $enable_prompt_regex );
}

sub _get_file_systems
{
	# give the output of "show file systems", this method returns
	# and array of the file systems
	my $show_file_systems_response = shift;
	my @fs;
	while ( $show_file_systems_response =~ /^\*?\s+\d+\s+\d+\s+\b(\S+)\b\s+[A-Za-z]+\s+(\S+):/mg )
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

ZipTie::Adapters::Cisco::SecurityAppliance - Adapter for performing various operations against Cisco Security Appliance devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::SecurityAppliance;
	ZipTie::Adapters::Cisco::SecurityAppliance::backup( $backup_document );

=head1 DESCRIPTION

This module represents an adapter that can be used to perform various operations against against Cisco Security Appliance devices.

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

=item C<_disconnect($cli_protocol)>

Disconnects from the CLI of the device.

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
