package ZipTie::ConnectionPath::FileServer;

use strict;
use warnings;
use ZipTie::Logger;
use XML::Simple;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

##############################################################################
#
#	METHODS
#
##############################################################################

sub new
{
	# Grab the package name and the paramaters that are passed in
	my ( $proto, $params ) = @_;
	my $package_name = ref($proto) || $proto;

	# Initialize the members of the class
	my $this = {
		ip       => '',
		port     => '',
		protocol => '',
		rootDir  => '',
	};

	# Populate the memebers of the class according to the parameters specified
	foreach my $key ( keys %$params )
	{
		$this->{$key} = $params->{$key};
	}

	# Turn $this into a ZipTie::ConnectionPath::FileServer object
	bless( $this, $package_name );

	# Return the object
	return $this;
}

sub get_protocol
{
	my $this = shift;
	return $this->{protocol};
}

sub set_protocol
{
	my $this = shift;

	if (@_)
	{
		$this->{protocol};
	}
}

sub get_ip
{
	my $this = shift;
	return $this->{ip};
}

sub set_ip
{
	my $this = shift;
	if (@_)
	{
		$this->{ip} = shift;
	}
}

sub get_ip_address
{
	my $this = shift;
	return $this->get_ip();
}

sub set_ip_address
{
	my $this = shift;
	if (@_)
	{
		$this->set_ip(@_);
	}
}

sub get_port
{
	my $this = shift;
	return $this->{ip};
}

sub set_port
{
	my $this = shift;

	if (@_)
	{
		$this->{ip};
	}
}

sub get_root_dir
{
	my $this = shift;
	return $this->{rootDir};
}

sub set_root_dir
{
	my $this = shift;

	if (@_)
	{
		$this->{rootDir};
	}
}

##############################################################################
#
#	SUB-ROUTINES
#
##############################################################################

sub from_xml
{
	my $in_value = shift or $LOGGER->fatal( "ERROR - No XML specified to convert into a ZipTie::ConnectionPath::FileServer object!" );

	# Grab the entire Connection Path XML element as a hash, making sure that any "fileServer" elements are represented as
	# an array, even if only one element is specified.
	my $xml_hash_ref = XMLin( $in_value, ForceArray => ["fileServer"] );

	# Retrieve all of the file server information
	my $file_servers_xml_hash_ref = $xml_hash_ref->{fileServers};

	# Create an array that can store all of the created ZipTie::ConnectionPath::FileServer objects
	my @file_servers_array = ();

	# Convert all of the "fileServer" instances into ZipTie::ConnectionPath::FileServer objects
	my $file_server_elem_array_ref = $file_servers_xml_hash_ref->{fileServer};

	foreach my $curr_file_server_xml_hash_ref (@$file_server_elem_array_ref)
	{
		my $file_server_obj = ZipTie::ConnectionPath::FileServer->new( $curr_file_server_xml_hash_ref);
		push( @file_servers_array, $file_server_obj );
	}

	# Return a reference to the array of ZipTie::ConnectionPath::FileServer objects
	return \@file_servers_array;
}

1;

__END__

=head1 NAME

ZipTie::ConnectionPath::FileServer - Stores information regarding an external file server.

=head1 SYNOPSIS

    use ZipTie::ConnectionPath::FileServer;
	my $tftp_file_server = ZipTie::ConnectionPath::FileServer->new(-protocol => "TFTP", -ip => "10.10.10.10", -port => "69", -rootDir => "/home/someuser/tfp");
	my $ip_address = $tftp_file_server->get_ip_address();

=head1 DESCRIPTION

The C<ZipTie::ConnectionPath::FileServer> module provides a simple way to store and retreive metadata/information about an
external file server.  A file server could be any TFTP, FTP, etc. server that may be located on the same machine running ZipTie
or on some other machine.

The only information that can be stored is the IP address or hostname of the machine running the external file server, the
port that the external file server is bound to on the machine, and the absolute file path to the root directory of the
file server.

The only caveat of this all is that it is assumed that the root directory specified can be accessible by the machine running
ZipTie.  This means that either the file server must be running on the same machine, or there must be a mapping to the directory
located on the local file system.  If the latter is the case, then the root directory should be this mapped directory.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<from_xml($input_xml_element)>

Creates an array of new instances of the C<ZipTie::ConnectionPath::FileServer> module by parsing an input XML string that represents
a C<connectionPath> XML element.  This C<connectionPath> element will contain a C<fileServers> element that contains a set of
C<fileServer> sub-elements.  Each of these C<fileServer> sub-elements contain a protocol name, IP address, port value, and absolute
file path that represents the root directory of the file server.

An example of a C<fileServers> element:

	<fileServers>
		<fileServer protocol="TFTP" ip="10.100.10.10" port="11069" rootDir="/home/someuser/sometftpserver"/>
		<fileServer protocol="FTP" ip="10.100.10.10" port="11021" rootDir="/home/someuser/someftpserver"/>
	</fileServers>

=back

=head1 METHODS

=over 12

=item C<new(%args)>

Creates a new C<ZipTie::ConnectionPath::FileServer> instance.  If no arguments are specified, then all of the internal
members of the instance will be undefined.  However, a hash can be specified to set these internal members.
The following are valid keys that can be specified in the hash: C<ip>, C<port>, C<protocol>, and C<rootDir>.

=item C<get_ip()>

Retrieves the IP address for the file server.

=item C<set_ip($ip)>

Stores the specified string as the IP address for the file server.

=item C<get_ip_address()>

Alias for the C<get_ip()> method.

=item C<set_ip_address($ip_address)>

Alias for the C<set_ip($ip)> method.

=item C<get_port()>

Retrieves the port value for the file server.

=item C<set_port($port)>

Stores the specified string as the port value for the file server.

=item C<get_protocol()>

Retrieves the name of the protocol that the file server implements.

=item C<set_protocol($protocol)>

Stores the specified string as the name of the protocol that the file server implements.

=item C<get_root_dir()>

Retrieves the absolute file path to the root directory of the file server.

The only caveat of this all is that it is assumed that the root directory specified can be accessible by the machine running
ZipTie.  This means that either the file server must be running on the same machine, or there must be a mapping to the directory
located on the local file system.  If the latter is the case, then the root directory should be this mapped directory.

=item C<set_root_dir($root_dir)>

Stores the specified string as the absolute file path to the root directory of the file server.

The only caveat of this all is that it is assumed that the root directory specified can be accessible by the machine running
ZipTie.  This means that either the file server must be running on the same machine, or there must be a mapping to the directory
located on the local file system.  If the latter is the case, then the root directory should be this mapped directory.

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

Contributor(s): Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut
