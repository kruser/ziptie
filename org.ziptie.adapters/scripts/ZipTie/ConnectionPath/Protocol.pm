package ZipTie::ConnectionPath::Protocol;

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
		name       => '',
		port       => '',
		properties => {},
	};

	# Populate the memebers of the class according to the parameters specified
	foreach my $key ( keys %$params )
	{
		$this->{$key} = $params->{$key};
	}

	# Turn $this into a ZipTie::ConnectionPath::Protocol object
	bless( $this, $package_name );

	# Return the object
	return $this;
}

sub get_name
{
	my $this = shift;
	return $this->{name};
}

sub set_name
{
	my $this = shift;

	if (@_)
	{
		$this->{name} = shift;
	}
}

sub get_port
{
	my $this = shift;
	return $this->{port};
}

sub set_port
{
	my $this = shift;

	if (@_)
	{
		$this->{port} = shift;
	}
}

sub get_properties
{
	my $this = shift;
	return $this->{properties};
}

sub set_properties
{
	my $this = shift;

	if (@_)
	{
		$this->{properties} = shift;
	}
}

sub get_property
{
	my $this = shift;
	my $key  = shift;

	return $this->{properties}->{property}->{$key};
}

sub get_sim_handshake
{
	my $this = shift;
	my $key  = shift;
	
	if (defined $this->{'sim-config'})
	{
		return $this->{'sim-config'};
	}
	else
	{
		return;
	}
}

sub set_property
{
	my $this = shift;

	if ( @_ == 2 )
	{
		my $key   = shift;
		my $value = shift;

		$this->{properties}->{$key} = $value;
	}
}

##############################################################################
#
#	SUB-ROUTINES
#
##############################################################################

sub from_xml
{
	my $in_value = shift or $LOGGER->fatal( "ERROR - No XML specified to convert into a ZipTie::ConnectionPath::Protocol object!" );

	# Grab the entire Connection Path XML element as a hash, making sure that any "protocol" elements are represented as
	# an array, even if only one element is specified.
	my $xml_hash_ref = XMLin( $in_value, ForceArray => ["protocol", "property"], ContentKey => '-value' );

	# Retrieve all of the "protocol" elements
	#
	# The hash looks like:
	#
	#	{
	#		'protocols' =>	{
	#							'protocol'	=>	{
	#												'Telnet' =>	{
	#																'port' => '23',
	#																'properties' => {},
	#															},
	#												'TFTP' =>	{
	#																'port' => '69',
	#																'properties' => {},
	#															},
	#											}
	#						}
	#	}
	my $protocols_xml_hash_ref = $xml_hash_ref->{protocols}->{protocol};

	# Create an array that can store all of the created ZipTie::ConnectionPath::Protocol objects
	my @protocols_array = ();

	# Convert all of the "protocol" instances into ZipTie::ConnectionPath::Protocol objects
	foreach my $curr_protocol_name ( keys(%$protocols_xml_hash_ref) )
	{
		# Grab the hash that the current protocol name is a key for.
		# This resulting hash contains the "port" scalar and "properties" value
		my $current_protocol_hash = $protocols_xml_hash_ref->{$curr_protocol_name};

		# Make sure to add the "name" key to the protocol hash, and set the current protocol name as the value
		$current_protocol_hash->{name} = $curr_protocol_name;

		# Use the updated hash as a parameter to create a new ZipTie::ConnectionPath::Protocol object
		my $protocol_obj = ZipTie::ConnectionPath::Protocol->new($current_protocol_hash);

		# Add the newly created ZipTie::ConnectionPath::Protocol object to our array of ZipTie::ConnectionPath::Protocol objects.
		push( @protocols_array, $protocol_obj );
	}

	# Return a reference to the array of ZipTie::ConnectionPath::Protocol objects
	return \@protocols_array;
}

1;

__END__

=head1 NAME

ZipTie::ConnectionPath::Protocol - Stores information regarding a network protocol

=head1 SYNOPSIS

    use ZipTie::ConnectionPath::Protocol;
    my $protocols_array_ref = ZipTie::ConnectionPath::Protocol->new($input_xml_doc);
	my $telnet_protocol = ZipTie::ConnectionPath::Protocol->new(-name => "Telnet", -port => "23", -properties => { timeout => "30"});
	my $name = $telnet_protocol->get_name();
	my $properties_ref = $telnet_protocol->get_properties();
	my $timeout_prop = $telnet_protocol->get_property("timeout");

=head1 DESCRIPTION

The C<ZipTie::ConnectionPath::Protocol> module provides a simple way to store and retreive metadata/information about a
network protocol.  The only information that can be stored is the name of the protocol, the port that the protocol uses, and
a hash of property values.  These property values can be set to anything and users of a C<ZipTie::ConnectionPath::Protocol>
object are expected to search for properties that matter to them.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<from_xml($input_xml_element)>

Creates an array of new instances of the C<ZipTie::ConnectionPath::Protocol> module by parsing an input XML string that represents
a C<connectionPath> XML element.  This C<connectionPath> element will contain a C<protocols> element that contains a set of
C<protocol> sub-elements.  Each of these C<protocol> sub-elements contain the name of the protocol, a port value, and a
set of properties that are simple key/value pairs.

An example of a C<protocols> element:

	<protocols>
		<protocol name="Telnet" port="23"/>
		<protocol name="SNMP" port="161">
			<property name="version" value="2c"/>
		</protocol>
		<protocol name="TFTP" port="69"/>
	</protocols>

=back

=head1 METHODS

=over 12

=item C<new(%args)>

Creates a new C<ZipTie::ConnectionPath::Protocol> instance.  If no arguments are specified, then all of the internal
members of the instance will be undefined.  However, a hash can be specified to set these internal members.
The following are valid keys that can be specified in the hash: C<name>, C<port>, and C<properties>.

=item C<get_name()>

Retrieves the name of the protocol.

=item C<set_name($name)>

Stores the specified string as the name for the protocol.

=item C<get_port()>

Retrieves the port value for the protocol.

=item C<set_port($port)>

Stores the specified string as the port value for the protocol.

=item C<get_properties()>

Retrieves a reference to the hash containing all of the properties specified for the protocol.

=item C<set_properties($properties_hash_ref)>

Stores the specified hash reference as the hash containing all of the properties specified for the protocol.

=item C<get_property($key)>

Retrieves the property from the protocol that uses the specified key.

=item C<set_property($key, $value)>

Adds a property to the internal hash of properties for the protocol.

=item C<get_sim_handshake>

This method will usually return nothing unless there is a sim-config set on the protocol.  If there
is, then the given protocol will use this config for doing a handshake with a remote device simulator.

This is currently used for Telnet on a simulator.  The simulator server will house several recordings that
it can playback over Telnet.  It can keep track of many incoming connections and branch each one out
to a different pseudo-device based on this handshake.  An example handshake is.....

                 'sim-config' => {
                                   'deviceIp' => '127.8.1.4',
                                   'daIp' => '10.10.1.157',
                                   'name' => 'handshake'
                                 },
                                 
	- deviceIp is the pseudo-IP address that the simulator will track for this connection.
	- daIP is the IP address of the server performing the device operation and is used by
	  the simulator to track incoming connection sources.
	  
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
