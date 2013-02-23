package ZipTie::Adapters::Cisco::Linksys;

use strict;
use warnings;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::Typer;
use ZipTie::HTTP;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle trim);
use ZipTie::SnmpSessionFactory;
use ZipTie::Model::XmlPrint;
use ZipTie::Adapters::Cisco::Linksys::Parsers qw(parse_filters parse_snmp create_config parse_chassis parse_system parse_interfaces);
use ZipTie::Logger;
use ZipTie::Adapters::GenericAdapter;

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

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	
	# Grab the ZipTie::Credentials object from the connection path
	my $credentials = $connection_path->get_credentials();

	# Grab the ZipTie::ConnectionPath::Protocol object that represents an HTTP/HTTPS protocol.
	# If the "HTTPS" is not specified, look for "HTTP"
	my $http_protocol = $connection_path->get_protocol_by_name("HTTPS");
	$http_protocol = $connection_path->get_protocol_by_name("HTTP") if (!defined($http_protocol));
	
	# If neither a HTTP or HTTPS protocol could be found, then that is fatal
	if ( !defined($http_protocol) )
	{
		$LOGGER->fatal("No 'HTTP' or 'HTTPS' protocol defined within the specified connection path!  Please make sure that either is 'HTTP' or 'HTTPS' protocol defined!");
	}
	
	# Create a new ZipTie::HTTP agent and connect to it using the information from the ZipTie::ConnectionPath
	# and ZipTie::Credentials objects.
	my $http_agent = ZipTie::HTTP->new();
	$http_agent->connect(
		$http_protocol->get_name(),
		$connection_path->get_ip_address(),
		$http_protocol->get_port(),
		$credentials->{username},
		$credentials->{password},
	);

	# being creating the model output
	#
	# Grab an output filehandle for the model
	my $filehandle = get_model_filehandle( "Linksys", $connection_path->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, "common" );
	$printer->open_model();

	my $responses = {};
	$responses->{home} = $http_agent->get("home.htm");
	$responses->{snmp} = $http_agent->get("sys_snmp.htm");
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete( $responses->{home} );

	# The necessary POST args for saving the configuration file
	my $post_args = {
		"header:Referer"      => "http://" . $connection_path->get_ip_address() . "/sys_setting.htm",    
		"header:Content-type" => "application/x-www-form-urlencoded",
		"page"                => "sys_setting2.htm",
		"typeSubmit"          => "2",
		"Submit2"             => "Export",
	};
	$responses->{config} = $http_agent->post( "RV042.exp", $post_args );
	create_config( $responses, $printer );

	$responses->{services} = $http_agent->get("service0.htm");
	my $fw_args = {
		"header:Referer"      => "http://" . $connection_path->get_ip_address() . "/access_rules.htm",
		"header:Content-type" => "application/x-www-form-urlencoded",
		"page"                => "access_rules.htm",
	};
	$responses->{filters} = $http_agent->post( "access_rules.htm", $fw_args );
	parse_filters( $responses, $printer );
	delete( $responses->{services} );
	delete( $responses->{filters} );

	# Create a Net::SNMP session
	my $snmp_session = ZipTie::SnmpSessionFactory->create( $connection_path, $credentials );

	my $port = 0;
	while ()
	{
		$port ++;
		$responses->{"port_$port"} = trim ( $http_agent->get("port$port\_information.htm") );
		if ( $responses->{"port_$port"} =~ /^$/ || $responses->{"port_$port"} =~/<BODY>\s*<\/BODY>/mi )
		{
			delete $responses->{"port_$port"};
			last;
		}
	}
	$responses->{"port_wan"}	= trim ( $http_agent->get("wan_port_information.htm") );
	$responses->{"port_dmz"}	= trim ( $http_agent->get("dmz_port_information.htm") );
	$responses->{"network"}		= trim ( $http_agent->get("network.htm") );

	parse_interfaces( $responses, $printer );
	delete $responses->{"network"};
	while ( (my $key, my $value) = each(%{$responses}) )
	{
		if ( $key =~ /^port_(\S+)$/i )
		{
			delete $responses->{$key};
		}
	}

	# Use SNMP to gather the interfaces model
	my $snmp_interfaces  = ZipTie::Adapters::GenericAdapter::get_interfaces($snmp_session);
	#$printer->print_element( "interfaces", $snmp_interfaces );

	parse_snmp( $responses, $printer );

	$printer->close_model();
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Cisco::Linksys - Adapter for performing various operations against Cisco Linksys VPN Routers.

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::Linksys;
	ZipTie::Adapters::Cisco::Linksys::backup( $backup_document );

=head1 DESCRIPTION

This module represents an adapter that can be used to perform various operations against against Cisco Cisco Linksys devices,
specifically their VPN routers

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

Contributor(s): dwhite (dylamite@ziptie.org)
Date: August 10, 2007

=cut
