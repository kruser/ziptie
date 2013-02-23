package ZipTie::ConnectionPath;

use strict;
use warnings;
use ZipTie::Logger;
use ZipTie::Credentials;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::ConnectionPath::FileServer;
use XML::Simple;
use MIME::Base64 qw(encode_base64);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

##############################################################################
#
#	METHODS
#
##############################################################################

sub new
{
	my $package_name = shift;

	# Initialize this instance of the class
	my $this = {
		host              => undef,
		protocols_hash    => undef,
		credentials       => undef,
		file_servers_hash => undef,
		connection_paths  => undef,
		xml_hash_ref      => undef,
	};

	# Turn $this into a ZipTie::ConnectionPath object
	bless( $this, $package_name );

	# Return the object
	return $this;
}

sub get_host
{
	my $this = shift;
	return $this->{host};
}

sub set_host
{
	my $this = shift;
	if (@_)
	{
		$this->{host} = shift;
	}
}

sub get_ip_address
{
	my $this = shift;
	return $this->get_host();
}

sub set_ip_address
{
	my $this = shift;

	$this->set_host(@_);
}

sub get_protocols
{
	my $this = shift;
	return $this->{protocols};
}

sub get_protocol_by_name
{
	my $this          = shift;
	my $protocol_name = shift;

	# Create an undef reference to the ZipTie::ConnectionPath::Protocol object found
	my $protocol_obj = undef;

	# Only attempt to find the ZipTie::ConnectionPath::Protocol object if a vaild protocol name was defined
	if ( defined($protocol_name) )
	{

		# Get a reference to our file servers hash
		my $protocols_hash = $this->{protocols_hash};

		foreach my $key ( keys %{$protocols_hash} )
		{

			# If the specified protocol name is equal to the current key (regardless of case-sensitivity), then the value
			# associated with the key is the correctly found ZipTie::ConnectionPath::Protocol object
			if ( $protocol_name =~ /^$key$/i )
			{
				$protocol_obj = $protocols_hash->{$key};
				last;
			}
		}
	}

	# Return the found ZipTie::ConnectionPath::Protocol object
	return $protocol_obj;
}

sub set_protocols
{
	my $this = shift;

	# If an array of ZipTie::ConnectionPath::Protocol objects is specified, create a hash from each element,
	# using the protocol name as the key and the actual ZipTie::ConnectionPath::Protocol object as the value.
	if (@_)
	{

		# Grab a reference to the array containing all of the ZipTie::ConnectionPath::Protocol objects
		my $protocol_array_ref = shift;

		foreach my $protocol_obj (@$protocol_array_ref)
		{

			# Create an entry in the internal "protocols_hash" hash object mapping the protocol name to
			# the ZipTie::ConnectionPath::Protocol object.
			my $name = $protocol_obj->get_name();
			$this->{protocols_hash}->{$name} = $protocol_obj;
		}
	}
}

sub get_credentials
{
	my $this = shift;
	return $this->{credentials};
}

sub get_credential_by_name
{
	my $this            = shift;
	my $credential_name = shift;

	# Create an undef string that will potentially store the credential value found
	my $credential_value = undef;

	if ( defined($credential_name) )
	{

		# Get a reference to our file servers hash
		my $credentials_obj = $this->{credentials};

		foreach my $key ( keys %{$credentials_obj} )
		{

			# If the specified credential name is equal to the current key (regardless of case-sensitivity), then the value
			# associated with the key is the correctly found credential value
			if ( $credential_name =~ /^$key$/i )
			{
				$credential_value = $credentials_obj->{$key};
				last;
			}
		}
	}

	return $credential_value;
}

sub set_credentials
{
	my $this = shift;
	if (@_)
	{
		$this->{credentials} = shift;
	}
}

sub get_file_servers
{
	my $this = shift;

	# Get a reference to our file servers hash
	my $file_servers_hash = $this->{file_servers_hash};

	# Grab all of the values from the file servers hash
	my $file_servers_array_ref = values( %{$file_servers_hash} );

	# Return the array reference to all of the ZipTie::ConnectionPath::FileServer objects
	return $file_servers_array_ref;
}

sub get_file_server_by_name
{
	my $this          = shift;
	my $protocol_name = shift;

	# Create an undef reference to the ZipTie::ConnectionPath::FileServer object found
	my $file_server_obj = undef;

	# Only attempt to find the ZipTie::ConnectionPath::FileServer object if a vaild protocol name was defined
	if ( defined($protocol_name) )
	{

		# Get a reference to our file servers hash
		my $file_servers_hash = $this->{file_servers_hash};

		foreach my $key ( keys %{$file_servers_hash} )
		{

			# If the specified protocol name is equal to the current key (regardless of case-sensitivity), then the value
			# associated with the key is the correctly found ZipTie::ConnectionPath::FileServer object
			if ( $protocol_name =~ /^$key$/i )
			{
				$file_server_obj = $file_servers_hash->{$key};
				last;
			}
		}
	}

	# Return the found ZipTie::ConnectionPath::FileServer object
	return $file_server_obj;
}

sub set_file_servers
{
	my $this = shift;

	# If an array of ZipTie::ConnectionPath::FileServer objects is specified, create a hash from each element,
	# using the protocol name as the key and the actual ZipTie::ConnectionPath::FileServer object as the value.
	if (@_)
	{

		# Grab a reference to the array containing all of the ZipTie::ConnectionPath::FileServer objects
		my $file_server_array_ref = shift;

		foreach my $file_server_obj (@$file_server_array_ref)
		{

			# Create an entry in the internal "file_server_hash" hash object mapping the protocol name to
			# the ZipTie::ConnectionPath::FileServer object.
			my $protocol_name = $file_server_obj->get_protocol();
			$this->{file_servers_hash}->{$protocol_name} = $file_server_obj;
		}
	}
}

sub get_connection_paths
{
	my $this = shift;
	return $this->{connection_paths};
}

sub set_connection_paths
{
	my $this = shift;
	if (@_)
	{
		$this->{connection_paths} = shift;
	}
}

sub get_xml_hash_ref
{
	my $this = shift;
	return $this->{xml_hash_ref};
}

sub set_xml_hash_ref
{
	my $this = shift;
	if (@_)
	{
		$this->{xml_hash_ref} = shift;
	}
}

##############################################################################
#
#	SUBROUTINES
#
##############################################################################

sub from_xml
{
	my $in_value = shift or $LOGGER->fatal("ERROR - No XML specified to convert into a ZipTie::ConnectionPath object!");

	# Grab the entire Connection Path XML element as a hash
	my $xml_hash_ref = XMLin($in_value);

	# Create an undef ZipTie::ConnectionPath object
	my $connection_path_obj = undef;

	# If the Connection Path element was found, attempt to create the ZipTie::ConnectionPath object
	if ( defined($xml_hash_ref) )
	{

		# Retrieve the host information which may be a hostname or IP address
		my $host = $xml_hash_ref->{host};

		# Convert credential information in a ZipTie::Credential object
		my $credentials = ZipTie::Credentials::from_xml($in_value);

		# Convert protocol information into an array of ZipTie::ConnectionPath::Protocol objects
		my $protocols = ZipTie::ConnectionPath::Protocol::from_xml($in_value);

		# Convert file server information into an array of ZipTie::ConnectionPath::FileServer objects
		my $file_servers = ZipTie::ConnectionPath::FileServer::from_xml($in_value);

		# Create a new ZipTie::ConnectionPath object and populate all of its goodness
		$connection_path_obj = ZipTie::ConnectionPath->new();
		$connection_path_obj->set_host($host);
		$connection_path_obj->set_credentials($credentials);
		$connection_path_obj->set_protocols($protocols);
		$connection_path_obj->set_file_servers($file_servers);
		$connection_path_obj->set_xml_hash_ref($xml_hash_ref);
	}

	# Return the hopefully populated ZipTie::ConnectionPath object
	return $connection_path_obj;
}

sub to_xml_string
{
	my $this = shift;
	my $encodeCredentials = shift;

	# print out an XML version of this object
	my $xmlString = "<connectionPath host=\"" . $this->get_ip_address() . "\">\n";
	$xmlString .= "<protocols>\n";
	my $protocols = $this->{protocols_hash};
	foreach my $key ( keys %{$protocols} )
	{
		my $p         = $protocols->{$key};
		my $validated = 'false';
		if ( $p->{validatedOnDevice} )
		{
			$validated = $p->{validatedOnDevice};
		}
		$xmlString .= "<protocol name=\"" . $p->get_name() . "\" port=\"" . $p->get_port . "\" validatedOnDevice=\"" . $validated . "\">\n";
		$xmlString .= "<properties>\n";
		my $propsHash = $p->get_properties()->{property};
		foreach my $pKey ( keys %{$propsHash} )
		{
			$xmlString .= "<property name=\"".$pKey."\" value=\"".$propsHash->{$pKey}."\"/>\n";
		}    
		$xmlString .= "</properties>\n";
		$xmlString .= "</protocol>\n";
	}
	$xmlString .= "</protocols>\n";

	$xmlString .= "<credentials>\n";
	my $creds = $this->{credentials};
	foreach my $key ( keys %{$creds} )
	{
		my $credValue = $creds->{$key};
		if ($encodeCredentials)
		{
			$credValue = encode_base64($credValue);
		}
		$xmlString .= "<credential name=\"" . $key . "\" value=\"" . $credValue . "\"/>\n";
	}
	$xmlString .= "</credentials>\n";

	if ( defined $this->{xml_hash_ref}->{fileServers} )
	{
		$xmlString .= XMLout( $this->{xml_hash_ref}->{fileServers}, RootName => 'fileServers' );
	}

	$xmlString .= "</connectionPath>\n";
	return $xmlString;
}

1;

__END__

=head1 NAME

ZipTie::ConnectionPath - Stores information regarding an a connection to a device.

=head1 SYNOPSIS

    use ZipTie::ConnectionPath;
	my $connection_path = ZipTie::ConnectionPath::from_xml($connection_path_xml_doc);
	my $host = $connection_path->get_host();
	my $credentials_obj_ref = $connection_path->get_credentials();
	my $username = $connection_path->get_credential_by_name("username");
	my $protocols_array_ref = $connection_path->get_protocols();
	my $telnet_protocol = $connection_path->get_protocol_by_name("Telnet");
	my $file_servers_array_ref = $connection_path->get_file_servers();
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $xml_hash_ref = $connection_path_obj->get_xml_hash_ref();

=head1 DESCRIPTION

The C<ZipTie::ConnectionPath> module provides a simple way to store and retreive metadata/information about a connection to a device.

A Connection Path is a way of defining all of the information required for connecting to a device; it is called a Connection Path
because a path of nodes are used to make a connection to a desired device. Each node on the Connection Path represents a connection
and authentication with a device before continuing on. A single node on a Connection Path can hold the following information:

    * A hostname or IP address for a device.
    * A set of device credentials for the device.
    * A set of network protocols to use to connect to the device and that may be used by that device to connect to other devices.
    * A set of metadata containers to provide information about external file servers, such as TFTP or FTP server.
    * Any number of other Connection path nodes that should be traveled to after this Connection Path node. 

Sometimes when connecting to a device, there may be multiple nodes to navigate before connecting with the desired device. These nodes
are other network devices that usually require their own connection and authentication data. This ultimately means that a Connection
Path represents all of the data for each node in a path to get the the desired device. In practice, most connection paths will only
have to deal with one device, so there is no need for this multiple node concept. However, a Connection Path can contain one or more
Connection Paths itself. This means that for each node in the Connection Path, you can have any number of other possible Connection
Path nodes to travel to, depending on which nodes on the Connection Path need to be connected and authenticated with before continuing
on. This is most likely to be the case when dealing with Jumphost technology.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<to_xml_string()>

Returns a string which is the XML representation of the ConnectionPath.  You can optionally pass
an argument to this method to have the credential values be base64 encoded.

	$connectionPath->to_xml_string(1);	# encodes credentials in the ConnectionPath 
	$connectionPath->to_xml_string();	# plain text credentials in the ConnectionPath 

=item C<from_xml($input_xml_element)>

Creates a new instance of the C<ZipTie::ConnectionPath> module by parsing an input XML string that represents
a C<connectionPath> XML element that contains a C<host> attribute, a C<protocols> element that contains a set of C<protocol> elements,
a C<credentials> element that contains a set of C<credential> elements, a C<fileServers> element that contains a set of C<fileServer>
elements, and any nested C<connectionPath> elements.

An example of a C<connectionPath> XML element:

	<connectionPath host="10.100.1.1">
          <protocols>
               <protocol name="Telnet" port="23"/>
               <protocol name="SNMP" port="161">
                    <property name="version" value="2c"/>
               </protocol>
               <protocol name="TFTP" port="69"/>
          </protocols>

          <credentials>
               <credential name="username" value="myUsername"/>
               <credential name="password" value="myPassword"/>
               <credential name="enableUsername" value="myEnableUsername"/>
               <credential name="enablePassword" value="myEnablePassword"/>
               <credential name="roCommunityString" value="public"/>
               <credential name="rwCommunityString" value="private"/>
          </credentials>

          <fileServers>
               <fileServer protocol="TFTP" ip="10.100.10.10" port="11069" rootDir="/home/someuser/sometftpserver"/>
               <fileServer protocol="FTP" ip="10.100.10.10" port="11021" rootDir="/home/someuser/someftpserver"/>
          </fileServers>
     </connectionPath>

=back

=head1 METHODS

=over 12

=item C<new()>

Creates a new instance of the C<ZipTie::ConnectionPath> class.  This instance will not have anything set on it and is just an empty
container.  It is expected that the user of this method will use the approperiate setters to fill this instance in with all the
correct information that an instance of the C<ZipTie::ConnectionPath> class should call.

The C<from_xml($input_xml_element)> subroutine can be used to create an instance of the C<ZipTie::ConnectionPath> class by parsing
the contents of a C<connectionPath> XML element.

=item C<get_host()>

Retrieves the hostname/IP address of this connection path

=item C<set_host($host)>

Stores the specified string as the hostname/IP address of this connection path.

=item C<get_ip_address()>

Alias for the C<get_host()> method.

=item C<set_ip_address($ip_address)>

Alias for the C<set_host($host)> method.

=item C<get_credentials()>

Retrieves a reference to a C<ZipTie::Credentials> object that represents a hash of all the credential names and their values that
will be used by this connection path.

=item C<get_credential_by_name($name)>

Retrieves the value of the specified credential name.  This is done by referencing the internal C<ZipTie::Credentials> object that
represents a hash of all the credential names and their values that will be used by this connection path.

=item C<set_credentials($credentials_obj_ref)>

Stores a reference to a C<ZipTie::Credentials> instance that represents a hash of all the credential names and their values that
will be used by this connection path.

=item C<get_protocols()>

Retrieves a reference to an array of C<ZipTie::ConnectionPath::Protocol> objects that represents all of the network protocols that
can be used to communicate to/from the device that this connection path is representing.

=item C<get_protocol_by_name($name)>

Retrieves a reference to a C<ZipTie::ConnectionPath::Protocol> object that is mapped to the specified name.  The name that is specified
is assumed to be the name of a protocol that is stored on this connection path.  For instance: "Telnet".

=item C<set_protocols($protocols_array_ref)>

Stores a reference to an array of C<ZipTie::ConnectionPath::Protocol> instances that represents all of the network protocols that can
be used to communicate to/from the device that this connection path is representing. 

All of the elements of the specified array will be parsed and put into an eternal hash that maps the name of the protocol to the
actual instance of a C<ZipTie::ConnectionPath::Protocol> object.  This functionality provides the support that allows the
C<get_protocol_by_name($name)> method to work.

=item C<get_commands()>

returns a C<ZipTie::CliCommands> object if extra commands have been defined for this operations.  Generally
when there are commands set directly on a ConnectionPath, they are for performing user defined configuration
changes on devices.

=item C<set_commands($cliCommands)>

Put a C<ZipTie::CliCommands> object on the ConnectionPath.  See C<get_commands()> for more infomation.  Generally
this method should not be called outside of the ConnectionPath object itself.

=item C<get_file_servers()>

Retrieves a reference to an array of C<ZipTie::ConnectionPath::FileServer> objects that represents all of the file servers that
can be used communicated with by the device that this connection path is representing.

=item C<get_file_server_by_name($name)>

Retrieves a reference to a C<ZipTie::ConnectionPath::FileServer> object that is mapped to the specified name.  The name that is
specified is assumed to be the protocol of a file server that this connection path is aware of.  For instance: "TFTP".

=item C<set_file_servers($file_servers_array_ref)>

Stores a reference to an array of C<ZipTie::ConnectionPath::FileServer> instances that represents all of the file servers that
can be used communicated with by the device that this connection path is representing.

All of the elements of the specified array will be parsed and put into an eternal hash that maps the name of the protocol to the
actual instance of a C<ZipTie::ConnectionPath::FileServer> object.  This functionality provides the support that allows the
C<get_file_server_by_name($name)> method to work.

=item C<get_connection_paths()>

Retrieves a reference to an array of C<ZipTie::ConnectionPath> objects that represents any additional connection paths that can
be accessed by this connection path.

=item C<set_connection_paths($connection_paths_array_ref)>

Stores a reference to an array of C<ZipTie::ConnectionPath> instances that represents any additional connection paths
that can be accessed by this connection path.

=item C<get_xml_hash_ref()>

Retrieves a reference to the hash that was populated by using the C<XML::Simple::XMLin()> subroutine to read in the XML that represent the
connection path.  This ideally can be used if a user would like to use the connection path XML in a pure hash structure, possibly to be included
with some other hash or Perl object to be outputted to an XML. 

=item C<set_xml_hash_ref($xml_hash_ref)>

Stores a reference to the hash that was populated by using the C<XML::Simple::XMLin()> subroutine to read in the XML that represent the
connection path.  This ideally can be used if a user would like to use the connection path XML in a pure hash structure, possibly to be included
with some other hash or Perl object to be outputted to an XML. 

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
Date: Aug 14, 2007

=cut
