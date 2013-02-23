package ZipTie::TransferProtocolFactory;

use strict;

use ZipTie::ConnectionPath;
use ZipTie::FTP;
use ZipTie::TFTP;
use ZipTie::SCP;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub create
{
	my ( $xfer_protocol, $protocol_name, $ip_address, $port ) = undef;
	
	# If only one argument was specified, check to see if it is a ZipTie::ConnectionPath instance or not
	if (@_ == 1)
	{
		my $arg = shift;
		my $arg_ref_name = ref($arg);
		if ($arg_ref_name eq "ZipTie::ConnectionPath")
		{
			my $connection_path = $arg;
	
			# Identify the ZipTie::NewConnection path object
			my $connection_path = $arg;
			
			# Use the "create_from_connection_path" sub-routine to create a ZipTie::TransferProtocol object
			$xfer_protocol = &create_from_connection_path($connection_path);
			
			# Set the protocol name that has been found
			$protocol_name = $xfer_protocol->get_protocol_name();
		}
		# If the argument is not ZipTie::ConnectionPath instance, then assume it is a protocol name
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

	# Determine which implementation of the TransferProtocol interface should be created.
	if ($protocol_name && !defined($xfer_protocol))
	{
		if ( $protocol_name =~ /^TFTP$/i )
		{
			$xfer_protocol = ZipTie::TFTP->new();
			$xfer_protocol->_set_ip_address($ip_address);
			$xfer_protocol->_set_port($port);
		}
		elsif ( $protocol_name =~ /^FTP$/i )
		{
			$xfer_protocol = ZipTie::FTP->new();
			$xfer_protocol->_set_ip_address($ip_address);
			$xfer_protocol->_set_port($port);
		}
		elsif ( $protocol_name =~ /^SCP$/i )
		{
			$xfer_protocol = ZipTie::SCP->new();
			$xfer_protocol->_set_ip_address($ip_address);
			$xfer_protocol->_set_port($port);
		}
	}

	# Check to see if any TransferProtocol object was created
	if ( !$xfer_protocol )
	{
		$LOGGER->fatal("ERROR: The file transfer protocol \"$protocol_name\" is NOT supported and/or implemented!");
	}
	else
	{
		$LOGGER->debug("Using '" . ref($xfer_protocol) . "' as the implementation of the specified file transfer protocol \"$protocol_name\".");
	}

	# Return the newly created ZipTie::TransferProtocol object
	return $xfer_protocol;
}

sub create_from_connection_path
{
	my $connection_path = shift;
	
	# Create an undef reference to a ZipTie::TransferProtocol object which will hopefully be set
	my $xfer_protocol = undef;
	
	if ( defined($connection_path) )
	{
		# Check to see if Telnet or SSH is a specified protocol on the ZipTie::ConnectionPath object
		my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP");
		my $scp_protocol = $connection_path->get_protocol_by_name("SCP");
		my $ftp_protocol = $connection_path->get_protocol_by_name("FTP");
		
		if ( defined($tftp_protocol) )
		{
			$xfer_protocol = ZipTie::TFTP->new();
			$xfer_protocol->_set_ip_address($connection_path->get_ip_address());
			$xfer_protocol->_set_port($tftp_protocol->get_port);
		}
		elsif ( defined($scp_protocol) )
		{
			$xfer_protocol = ZipTie::SCP->new();
			$xfer_protocol->_set_ip_address($connection_path->get_ip_address());
			$xfer_protocol->_set_port($scp_protocol->get_port);
		}
		elsif ( defined($ftp_protocol) )
		{
			$xfer_protocol = ZipTie::FTP->new();
			$xfer_protocol->_set_ip_address($connection_path->get_ip_address());
			$xfer_protocol->_set_port($ftp_protocol->get_port);
		}
	}
	
	# Return the hopefully populated ZipTie::CLIProtocol object
	return $xfer_protocol;
}

1;

__END__

=head1 NAME

ZipTie::TransferProtocolFactory - Factory for creating ZipTie::TransferProtocol objects.

=head1 SYNOPSIS

	use ZipTie::TransferProtocolFactory;

	my $xfer_protocol = ZipTie::TransferProtocolFactory::create("TFTP");
	my $xfer_protocol = ZipTie::TransferProtocolFactory::create("SCP", 10.10.10.10);
	my $xfer_protocol = ZipTie::TransferProtocolFactory::create("FTP", 10.10.10.10, 21);
	my $xfer_protocol = ZipTie::TransferProtocolFactory::create($connection_path);

=head1 DESCRIPTION

C<ZipTie::TransferProtocolFactory> is a simple factory to ease the creation of instances of C<ZipTie::TransferProtocol>
subclasses that are based on the protocol that is specified for use.  This is done in hopes to abstract
away protocol-specific implementations and to provide a common interface to the user.  This is important
as a C<ZipTie::TransferProtocol> object should I<NEVER> be created explicitly; only sub-classes/implementations
of the C<ZipTie::TransferProtocol> interface should be created.

The file transfer protocols that are currently support are: B<TFTP>, B<FTP>, and B<SCP>.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<create>

Creates an instance of the subclass of C<ZipTie::TransferProtocol> that is the implementation of the specified
file transfer protocol.  If the specified file transfer protocol is not support or implemented, an error will be thrown.

There are two ways to create a C<ZipTie::TransferProtocol> object using this factory:

1) Specify the file transfer protocol name, the IP address of the device to connect to, and the port to connect over.
Only the file transfer protocol name must be specified; if an IP address and/or port is specified, then they will simply be
stored on the newly created C<ZipTie::TransferProtocol> object for potential later use, such as using them when invoking
the C<connect($ip_address, $port, $username, $password)> method.

2) Specify a C<ZipTie::ConnectionPath> object that represents a connection to a device, as well as information needed for
using a file transfer protocol.

The following are some examples of calling this method:

	create("TFTP");
	create("SCP", 10.10.10.10);
	create("FTP", 10.10.10.10, 21);
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

Contributor(s): Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut