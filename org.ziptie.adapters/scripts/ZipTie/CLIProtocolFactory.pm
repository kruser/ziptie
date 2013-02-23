package ZipTie::CLIProtocolFactory;

use strict;
use ZipTie::Telnet;
use ZipTie::SSH;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub create
{
	my ( $cli_protocol, $protocol_name, $ip_address, $port ) = undef;
	
	# If only one argument was specified, check to see if it is a ZipTie::ConnectionPath instance or not
	if (@_ == 1)
	{
		my $arg = shift;
		my $arg_ref_name = ref($arg);
		if ($arg_ref_name eq "ZipTie::ConnectionPath")
		{
			# Identify the ZipTie::NewConnection path object
			my $connection_path = $arg;
			
			# Use the "create_from_connection_path" sub-routine to create a ZipTie::CLIProtocol object
			$cli_protocol = &create_from_connection_path($connection_path);
			
			# Set the protocol name that has been found
			$protocol_name = $cli_protocol->get_protocol_name();
		}
		# If the argument is not a ZipTie::ConnectionPath, then assume it is a protocol name
		else
		{
			$protocol_name = $arg;
		}
	}
	
	# If there is more than 1 argument, then assume that the protocol name, IP address of the device,
	# and the port to connect over the device with
	else
	{
		$protocol_name = shift;
		$ip_address    = shift;
		$port          = shift;
	}
	
	# Determine which implementation of the CLIProtocol interface should be created.
	if ($protocol_name && !defined($cli_protocol))
	{
		if ( $protocol_name =~ /^Telnet$/i )
		{
			$cli_protocol = ZipTie::Telnet->new();
			$cli_protocol->_set_ip_address($ip_address);
			$cli_protocol->_set_port($port);
		}
		elsif ( $protocol_name =~ /^SSH$/i )
		{
			$cli_protocol = ZipTie::SSH->new();
			$cli_protocol->_set_ip_address($ip_address);
			$cli_protocol->_set_port($port);
		}
	}

	# Check to see if any CLIProtocol object was created
	if ( !$cli_protocol )
	{
		$LOGGER->fatal("ERROR: The CLI protocol \"$protocol_name\" is NOT supported and/or implemented!");
	}
	else
	{
		$LOGGER->debug("Using '" . ref($cli_protocol) . "' as the implementation of the specified CLI protocol \"$protocol_name\".");
	}

	# Return the newly created CLIProtocol object
	return $cli_protocol;
}

sub create_from_connection_path
{
	my $connection_path = shift;
	
	# Create an undef reference to a ZipTie::CLIProtocol object which will hopefully be set
	my $cli_protocol = undef;
	
	if ( defined($connection_path) )
	{
		# Check to see if Telnet or SSH is a specified protocol on the ZipTie::ConnectionPath object
		my $telnet_protocol = $connection_path->get_protocol_by_name("Telnet");
		my $ssh_protocol = $connection_path->get_protocol_by_name("SSH");
		
		# in the case Telnet and SSH are options, pick the one that has been previously validated
		my $useSsh = 0;
		if (!defined $telnet_protocol)
		{
			$useSsh = 1;
		}
		elsif (defined $ssh_protocol && $ssh_protocol->{validatedOnDevice} eq 'true')
		{
			$useSsh = 1;
		}
		
		# Set up the respective client
		if ( defined($ssh_protocol) && $useSsh )
		{
			$cli_protocol = ZipTie::SSH->new();
			$cli_protocol->_set_ip_address($connection_path->get_ip_address());
			$cli_protocol->_set_port($ssh_protocol->get_port);
			$cli_protocol->version($ssh_protocol->get_property('Version'));
			$cli_protocol->sim_handshake($ssh_protocol->get_sim_handshake);
		}
		elsif ( defined($telnet_protocol) )
		{
			$cli_protocol = ZipTie::Telnet->new();
			$cli_protocol->_set_ip_address($connection_path->get_ip_address());
			$cli_protocol->_set_port($telnet_protocol->get_port);
			$cli_protocol->sim_handshake($telnet_protocol->get_sim_handshake);
		}
	}
	
	# Return the hopefully populated ZipTie::CLIProtocol object
	return $cli_protocol;
}

1;

__END__

=head1 NAME

ZipTie::CLIProtocolFactory - Factory for creating ZipTie::CLIProtocol objects.

=head1 SYNOPSIS

	use ZipTie::CLIProtocolFactory;

	my $cli_protocol = ZipTie::CLIProtocolFactory::create("Telnet");

	my $cli_protocol = ZipTie::CLIProtocolFactory::create("SSH", 10.10.10.10, 22);

	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

=head1 DESCRIPTION

C<ZipTie::CLIProtocolFactory> is a simple factory to ease the creation of instances of C<ZipTie::CLIProtocol>
subclasses that are based on the protocol that is specified for use.  This is done in hopes to abstract
away protocol-specific implementations and to provide a common interface to the user.  This is important
as a C<ZipTie::CLIProtocol> object should I<NEVER> be created explicitly; only sub-classes/implementations
of the C<ZipTie::CLIProtocol> interface should be created.

The CLI protocols that are currently support are: B<Telnet> and B<SSH>.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<create>

Creates an instance of the subclass of C<ZipTie::CLIProtocol> that is the implementation of the specified
CLI protocol.  If the specified CLI protocol is not support or implemented, an error will be thrown.

There are two ways to create a C<ZipTie::CLIProtocol> object using this factory:

1) Specify the CLI protocol name, the IP address of the device to connect to, and the port to connect over.
Only the CLI protocol name must be specified; if an IP address and/or port is specified, then they will simply be
stored on the newly created C<ZipTie::CLIProtocol> object for potential later use, such as using them when invoking
the C<ZipTie::CLIProtocol::connect($ip_address, $port, $username, $password)> method.

2) Specify a C<ZipTie::ConnectionPath> object that represents a connection to a device using a CLI protocol.

The following are some examples of calling this method:

	create("Telnet");
	create("SSH", 10.10.10.10, 22);
	create($connection_path);

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
Date: Apr 26, 2007

=cut
