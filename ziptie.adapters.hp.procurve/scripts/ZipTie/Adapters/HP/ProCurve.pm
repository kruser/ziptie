package ZipTie::Adapters::HP::ProCurve;

use strict;
use warnings;

use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::Adapters::HP::ProCurve::AutoLogin;
use ZipTie::Adapters::HP::ProCurve::GetRunningConfig qw(get_running_config);
use ZipTie::Adapters::HP::ProCurve::GetStartupConfig qw(get_startup_config);
use ZipTie::Adapters::HP::ProCurve::Parsers qw(parse_chassis create_config parse_system parse_interfaces parse_stp parse_snmp parse_vlan_ids parse_vlan_info);
use ZipTie::Adapters::HP::ProCurve::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::ConnectionPath;
use ZipTie::Typer;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;
use Data::Dumper;

# Get the instance of the ZipTie::Logger module
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
	my $responses  = {};

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ($connection_path) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );

	# Connect to the device and capture the ZipTie::CLIProtocol that is created as a result of the connection.
	# Also be sure to capture the device prompt that is returned as a result of a successful connection.
	my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);

	$cli_protocol->turn_vt102_off(); # disable vt102

	my $ssh_protocol = $connection_path->get_protocol_by_name("SSH") if ( defined($connection_path) );

	# Grab an output filehandle for the model
	my $filehandle = get_model_filehandle( "ProCurve", $connection_path->get_ip_address() );

	# Get rid of the more prompt
	if ( defined($ssh_protocol) )
	{
		#in case paging is disabled by default
		# Set the terminal size
		my $termSize = $cli_protocol->send_and_wait_for( "terminal width 80 length 25", $enable_prompt_regex );
	}

	my $termLen = $cli_protocol->send_and_wait_for( "no page", $enable_prompt_regex );

	if ( $termLen =~ /Invalid input/i )
	{
		# set the --more-- prompt if the term length 0 didn't go through
		$cli_protocol->set_more_prompt( '[^-]*-- MORE --.*$', '20' );
	}
	$LOGGER->debug("Paging...");

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Gather inputs for the model
	$responses->{sysDescr} = $cli_protocol->send_and_wait_for( "getmib sysDescr.0", $enable_prompt_regex );    
	my $version = $cli_protocol->send_and_wait_for( "show version", $enable_prompt_regex );
	if ( $version =~ /show version(.*)$/msig )
	{
		$responses->{version} = $1;
	}
	else
	{
		$responses->{version} = $version;
	}
	$version = $cli_protocol->send_and_wait_for( "show system-information", $enable_prompt_regex );
	if ( $version =~ /show system-information(.*)$/msig )
	{
		$responses->{version} .= $1;
	}
	else
	{
		$responses->{version} .= $version;
	}
	$_ = $cli_protocol->send_and_wait_for( "getMIB sysDescr.0", $enable_prompt_regex );
	/^.+(sysDescr.0\s*=\s*.*)$/msig;
	$responses->{version} .= $1;
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );

	my @vlan_ids;

	$cli_protocol->send( 'show interfaces brief' );
	$responses->{interfaces} = $cli_protocol->get_response( 0.25 );
	$cli_protocol->send( 'show spanning-tree' );
	$responses->{stp}   = $cli_protocol->get_response( 0.25 );
	$cli_protocol->send( 'show snmp-server' );
	$responses->{snmp}  = $cli_protocol->get_response( 0.25 );
	$cli_protocol->send( 'show vlans' );
	$responses->{vlans} = $cli_protocol->get_response( 0.25 );
	
	@vlan_ids           = parse_vlan_ids( $responses,                             $printer );
	foreach (@vlan_ids)
	{
		my $id = $_;

		#print"\ngot:$id\n";
		$cli_protocol->send( "show vlan $id" );
		$responses->{"vlan_$id"} = $cli_protocol->get_response( 0.25 );
		#print "from cli:\n".$responses->{"vlan_$id"}."\n";
	}

	$responses->{interfaces} = ( $responses->{interfaces} =~ /show interfaces brief(.*)$/msig ) ? $1 : $responses->{interfaces};
	$responses->{stp}        = ( $responses->{stp}        =~ /show spanning-tree(.*)$/msig )    ? $1 : $responses->{stp};
	$responses->{snmp}       = ( $responses->{snmp}       =~ /show snmp-server(.*)$/msig )      ? $1 : $responses->{snmp};
	$responses->{vlans}      = ( $responses->{vlans}      =~ /show vlans(.*)$/msig )            ? $1 : $responses->{vlans};

	$cli_protocol->send_and_wait_for( "no page", $enable_prompt_regex );

	$responses->{running_config} = get_running_config( $cli_protocol, $connection_path );
	$responses->{startup_config} = get_startup_config( $cli_protocol, $connection_path );
	$responses->{running_config} =~ s/\s*(\S+) configuration:\s*(;)/$1/msg;
	$responses->{startup_config} =~ s/\s*Startup configuration:\s*(;)/$1/msg;
	create_config( $responses, $printer );
	delete $responses->{running_config};
	delete $responses->{startup_config};

	parse_interfaces( $responses, $printer );
	$LOGGER->debug("Interfaces Parsed...");
	delete $responses->{interfaces};

	parse_snmp( $responses, $printer );
	$LOGGER->debug("SNMP Parsed...");
	delete $responses->{snmp};

	parse_stp( $responses, $printer );
	$LOGGER->debug("STP Parsed...");
	delete $responses->{stp};

	parse_vlan_info( $responses, $printer );
	$LOGGER->debug("VLANS Parsed...");

	delete $responses->{vlans};
	delete $responses->{version};
	foreach (@vlan_ids)
	{
		delete $responses->{"vlan_$_"};
	}

	# Close the model output file handle
	$printer->close_model;
	$LOGGER->debug("Model closed");
	close_model_filehandle($filehandle);
	$LOGGER->debug("filehandle closed");

	# Disconnect from the specified device
	_disconnect($cli_protocol);
}

sub get_output
{
	my $cli_protocol        = shift;
	my $enable_prompt_regex = shift;
	my $more_prompt_regex   = shift;
	my $command             = shift;

	my $responses    = "";
	my $prompt_regex = $enable_prompt_regex;
	$prompt_regex =~ s/(\#)/$1|$more_prompt_regex/;
	while ()
	{
		if ( $command ne "20" )
		{
			$_ = $cli_protocol->send( $command );
		}
		else
		{
			$cli_protocol->send_as_bytes($command);
		}
		$_ = $cli_protocol->get_response(0.25);
		$command = "20";
		$responses .= $_;
		$responses =~ s/$enable_prompt_regex//mig;
		$responses =~ s/$more_prompt_regex.+$//mig;
		$responses =~ s/-- MORE --.+$//mig;
		last if ( $_ !~ /$more_prompt_regex/ );
	}

	return $responses;
}

# This function is not yet implemented
sub commands
{

	#my $package_name = shift;
	#my $command_doc  = shift;
	#my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	#my ( $cli_protocol, $enable_prompt_regex ) = _connect($connection_path);
	#my $termLen = $cli_protocol->send_and_wait_for( "no page", $enable_prompt_regex );
	#my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'ProCurve', $cli_protocol, $commands, '(#|\$|>)\s*$' );
	#disconnect($cli_protocol);
	#return $result;
}

sub _connect
{

	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the ProCurve device
	my $enable_prompt_regex = ZipTie::Adapters::HP::ProCurve::AutoLogin::execute( $cli_protocol, $connection_path );

	# Store the found prompt as "enablePrompt" on the specified CLI protocol.
	$cli_protocol->set_prompt_by_name( "enablePrompt", $enable_prompt_regex );

	# Return the created ZipTie::CLIProtocol object and the enable prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $enable_prompt_regex );
}

sub _disconnect
{

	# Grab the ZipTie::CLIProtocol object passed in
	my $cli_protocol = shift;

	# Close this session and exit
	$cli_protocol->send("exit");

	# Finally, disconnect from our CLIProtocol
	$cli_protocol->disconnect();
}

1;

__END__

=head1 NAME

ZipTie::Adapters::HP::ProCurve - Adapter for performing various operations against HP ProCurve devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::HP::ProCurve;
	ZipTie::Adapters::HP::ProCurve::backup( $backup_document );

=head1 DESCRIPTION

This module represents an adapter that can be used to perform various operations against against HP ProCurve devices.

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

Contributor(s): rkruse, Dylan White (dylamite@ziptie.org), Brent Gerig (brgerig@taylor.edu)
Date: November 20, 2007

=cut
