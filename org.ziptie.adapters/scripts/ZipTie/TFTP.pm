package ZipTie::TFTP;

use strict;
use warnings;
use Net::TFTP;
use File::Basename qw(fileparse);

use ZipTie::TransferProtocol;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that ZipTie::TFTP is a subclass of ZipTie::TransferProtocol
our @ISA = qw(ZipTie::TransferProtocol);

sub new
{
	my $class_name = shift;

	# Initialize this instance of the class as a ZipTie::TransferProtocol
	# since at its core, that is what it is.
	my $this = ZipTie::TransferProtocol->new();

	# Turn $this into a ZipTie::TFTP object
	bless( $this, $class_name );

	# Set the protocol name
	$this->{protocol_name} = "TFTP";

	# Default the timeout to 30 seconds
	$this->set_timeout(30);

	# Return the object
	return $this;
}

sub connect
{
	# Grab a reference to our self/this instance
	my $this = shift;

	# Store the parameters
	my $ip_address = shift;
	my $port       = shift;

	# Set the IP address and port for this client
	$this->_set_ip_address($ip_address);
	$this->_set_port($port);

	# Create a Net::TFTP object and connect to it
	my $tftp_client = Net::TFTP->new(
		$this->get_ip_address(),
		Port    => $this->get_port(),
		Timeout => $this->get_timeout(),
		Mode => 'octet',
	);

	# Check to see if we were able to create the Net::TFTP object or not.
	if ( !$tftp_client )
	{
		$LOGGER->fatal("[$TFTP_ERROR]\nCould not connect to tftp://$ip_address:$port\n[ERROR MESSAGE]\n" . $tftp_client->error());
	}

	# Store the newly create Net::TFTP as our protocol implementation
	$this->{protocol_impl} = $tftp_client;
}

sub disconnect
{
	# Does nothing, so just return true
	return 1;
}

sub get
{
	# Grab a reference to our self/this instance
	my $this = shift;
	
	# Grab the parameters
	my $remote_file = shift;
	my $local_file = shift;
	
	# If no local file path was specified, use the file name from the remote file path
	if ( !defined($local_file) )
	{
		my ( $filename, $directories, $suffix ) = fileparse($remote_file);
		$local_file = $filename;
	}
	
	# Grab the Net::TFTP instance
	my $tftp_client = $this->{protocol_impl};
	
	# Get the remote file and store it in the local file
	my $ip_address = $this->get_ip_address();
	my $port       = $this->get_port();
	$LOGGER->debug("Retrieving '$remote_file' from tftp://$ip_address:$port/ and storing it as '$local_file'");
	my $get_status = $tftp_client->get($remote_file, $local_file);
	
	# If a failure occurred during the TFTP transfer, then log the failure as fatal
	if (!$get_status)
	{
		$LOGGER->fatal("[$TFTP_ERROR]\nRemote file '$remote_file' was not found on tftp://$ip_address:$port!\n[ERROR MESSAGE]\n" . $tftp_client->error());
	}
	# Otherwise, log that the TFTP file transfer was successful.
	else
	{
		$LOGGER->debug("Successfully retrieved '$remote_file' from tftp://$ip_address:$port/ and stored it as '$local_file'");
	}
	
	return 1;
}

sub put
{
	# Grab a reference to our self/this instance
	my $this = shift;
	
	# Grab the parameters
	my $local_file = shift;
	my $remote_file = shift;
	
	# If no remote path was specified, use the file name from the local file path
	if ( !defined($remote_file) )
	{
		my ( $filename, $directories, $suffix ) = fileparse($local_file);
		$remote_file = $filename;
	}
	
	# Grab the Net::TFTP instance
	my $tftp_client = $this->{protocol_impl};
	
	# Send the local file to the server
	my $ip_address = $this->get_ip_address();
	my $port       = $this->get_port();
	$LOGGER->debug("Sending '$local_file' to tftp://$ip_address:$port/ and storing it as '$remote_file'");
	my $put_status = $tftp_client->put($local_file, $remote_file);
	
	# If a failure occurred during the TFTP transfer, then log the failure as fatal
	if (!$put_status)
	{
		$LOGGER->fatal("[$TFTP_ERROR]\nError sending local file '$local_file' to tftp://$ip_address:$port!\n[ERROR MESSAGE]\n" . $tftp_client->error());
	}
	# Otherwise, log that the TFTP file transfer was successful.
	else
	{
		$LOGGER->debug("Successfully sent '$local_file' to tftp://$ip_address:$port/ and stored it as '$remote_file'");
	}
	
	return 1;
}

1;

__END__

=head1 NAME

ZipTie::TFTP - TFTP client implementation of the ZipTie::TransferProtocol interface/abstract base class.

=head1 SYNOPSIS

	use ZipTie::TransferProtocol;
	use ZipTie::TransferProtocolFactory;

	my $xfer_client = ZipTie::TransferProtocolFactory::create("TFTP");
	$xfer_client->connect("10.10.10.10", 21);
	$xfer_client->put("test.txt", "test.txt");
	$xfer_client->disconnect();

=head1 DESCRIPTION

ZipTie::TFTP represents a client implementing the TFTP protocol that adheres to the interface specified by the
ZipTie::TransferProtocol class.  The core backing of this implementation is the C<Net::TFTP> module.

In order to conform to the interface provided by ZipTie::TransferProtocol, the following functionality
had to be implemented:  connecting to a remote server (this is supported by the C<connect> method), disconnecting
from a remote server (this is supported by the C<disconnect> method), retrieve/get a file from the server and
store it locally (this is supported by the C<get> method), and send/put a local file to the server (this is
supported by the C<put> method).

=head1 IMPLEMENTED METHODS

The following methods are all methods that have been implemented according to the abstract/interface methods that have been
specified in the C<ZipTie::TransferProtocol> module.

=over 12

=item C<connect($ip_address, $port, $username, $password)>

Since the TFTP protocol does necessitate a need to connect to the server, the C<connect($ip_address, $port, $username, $password)>
method will simply create a new C<Net::TFTP> object with the IP address and port specified.  The username and password credentials
are ignored since there is no verification on a TFTP server.

$ip_address -	The hostname/IP address of the server.

$port -			The port to connect to on the server.

$username -		Ignored by this implementation.

$password -		Ignored by this implementation.
	
=item C<disconnect()>

Since the TFTP protocol does necessitate a need to disconnect to the server, the C<disconnect()> method has no functionality
in this case.  A true value will be returned.

=item C<get($remote_file, $local_file)>

Retrieves a file from the remote host/IP address that this ZipTie::TransferProtocol is connected to.

$remote_file -	A relative or absolute filepath on the host/server defining the file to be retrieved.
				If the filepath is relative, it is then relative to the default directory of the host/server.

$local_file -	Optional.  A filepath where the remote file should be transfer to on the local machine.
				This file path can either absolute or relative.  If the filepath is not specified, then the file
				name of the remote file being retrieved will be used and placed within the current working directory
				on the local machine.  The current working directory will also be used as the relative directory if
				the local file name is not absolute.

Returns I<true> if the file transfer was successful; I<false> otherwise.

=item C<put($local_file, $remote_file)>

Sends a file to the remote host/IP address that this ZipTie::TransferProtocol is connected to.

$local_file -	A filepath defining of the local file to put on the host/server.  This file path can either absolute or
				relative.  If the filepath is relative, then it is relative to the current working directory.

$remote_file -	Optional.  A filepath defining where the local file should be transfer to on the host/server.
				This file path can either absolute or relative.  If the filepath is not specified, then the file
				name of the local file being sent will be used and placed within the default directory of the host/server.

Returns I<true> if the file transfer was successful; I<false> otherwise.

=back

=head1 INHERITED METHODS

The following methods are all methods that have been inherited from the C<ZipTie::TransferProtocol> module.

=over 12

=item C<get_ip_address()>

Retrieves the hostname/IP address of the server that the implementation of the ZipTie::TransferProtocol
class is connected to.

=item C<get_protocol_name()>

Retrieves the name of the transfer protocol that this implementation of the ZipTie::TransferProtocol
class represents.  For example: "TFTP".

=item C<get_port()>

Retrieves the port that this implementation of the ZipTie::TransferProtocol
class has connected to on the server.

=item C<get_timeout()>

Retrieves the length (in seconds) that this implementation of the ZipTie::TransferProtocol class
should wait for the server during a transfer before a time-out error is declared.

=item C<set_timeout($timeout)>

Sets the length (in seconds) that this implementation of the ZipTie::TransferProtocol class
should wait for the server during a transfer before a time-out error is declared.

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
Date: Apr 25, 2007

=cut
