package ZipTie::TransferProtocol;

use strict;
use warnings;

use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub new
{
	my $class_name = shift;

	# Initialize this instance of the class
	my $this = {
		protocol_impl => undef,
		protocol_name => undef,
		ip_address    => undef,
		port          => undef,
		timeout       => 30,
	};

	# Turn $this into a ZipTie::TransferProtocol object
	bless( $this, $class_name );

	# Return the object
	return $this;
}

sub get_ip_address
{
	my $this = shift;
	return $this->{ip_address};
}

sub _set_ip_address
{
	my $this = shift;
	if (@_)
	{
		$this->{ip_address} = shift
	}
}

sub get_protocol_name
{
	my $this = shift;
	return $this->{protocol_name};
}

sub get_port
{
	my $this = shift;
	return $this->{port};
}

sub _set_port
{
	my $this = shift;
	if (@_)
	{
		$this->{port} = shift
	}
}

sub get_timeout
{
	my $this = shift;
	return $this->{timeout};
}

sub set_timeout
{
	my $this = shift;
	if (@_)
	{
		$this->{timeout} = shift;
	}
}

sub connect
{

	# Send an error since this method should be abstract
	$LOGGER->fatal( "ERROR: ZipTie::TransferProtocol->connect() is an abstract method!\n",
		"A subclass of ZipTie::TransferProtocol must implement connect() if it is to be used!");
}

sub disconnect
{

	# Send an error since this method should be abstract
	$LOGGER->fatal( "ERROR: ZipTie::TransferProtocol->disconnect() is an abstract method!\n",
		"A subclass of ZipTie::TransferProtocol must implement disconnect() if it is to be used!");
}

sub get
{

	# Send an error since this method should be abstract
	$LOGGER->fatal( "ERROR: ZipTie::TransferProtocol->get() is an abstract method!\n",
		"A subclass of ZipTie::TransferProtocol must implement get() if it is to be used!");
}

sub put
{

	# Send an error since this method should be abstract
	$LOGGER->fatal( "ERROR: ZipTie::TransferProtocol->put() is an abstract method!\n",
		"A subclass of ZipTie::TransferProtocol must implement put() if it is to be used!");
}

1;

__END__

=head1 NAME

ZipTie::TransferProtocol - Interface/abstract base class for which any transfer protocol implementation
can be used.

=head1 SYNOPSIS

	use ZipTie::TransferProtocol;
	use ZipTie::TransferProtocolFactory;

	my $xfer_client = ZipTie::TransferProtocolFactory::create("FTP");
	$xfer_client->connect("10.10.10.10", 21, somename, somepassword);
	$xfer_client->put("test.txt", "test.txt");
	$xfer_client->disconnect();

=head1 DESCRIPTION

ZipTie::TransferProtocol represents an interface/abstract base class for which any client implementing a
transfer protocol can be based off of.  This is important as a ZipTie::TransferProtocol object should
I<NEVER> be created explicitly; only sub-classes/implementations of the ZipTie::TransferProtocol interface
should be created.

Some protocols that are considered transfer protocols are: B<FTP>, B<TFTP>,
B<SFTP>, and B<SCP>.

For the purposes of providing a common interface amongst any possible transfer protocol client, the following
is information assumed to be known by an implementation: hostname/IP address of a server to connect to, the
port that the server is running on, and the timeout (in seconds) for transfers to and/or from the server.

Along with information that all transfer protocols contain, there are two primary methods of functionality that
they I<MUST> support: connecting to a remote server (this is supported by the C<connect> method), disconnecting
from a remote server (this is supported by the C<disconnect> method), retrieve/get a file from the server and
store it locally (this is supported by the C<get> method), and send/put a local file to the server (this is
supported by the C<put> method).

If calls are made to either the C<connect>, C<disconnect>, C<get>, or C<put> methods on a sub-class/interface
that doesn't implement them, and the calling Perl process will die with an error message specifying the error.

=head1 INTERFACE METHODS

=over 12

=item C<connect($ip_address, $port, $username, $password)>

Connects to a server implementing the transfer protocol at a specified IP address and port.
In order to authenticate with the server, a username and password also needs to be specified.

$ip_address -	The hostname/IP address of the server.

$port -			The port to connect to on the server.

$username -		The username credential to authenticate with the server.

$password -		The password credential to authenticate with the server.

=item C<disconnect()>

Disconnects from the server implementing the transfer protocol.

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

=head1 IMPLEMENTED METHODS

=over 12

=item C<new()>

B<WARNING> - This should be I<ONLY> be called with in the constructor/new methods of classes that implement
the ZipTie::TransferProtocol class!

Creates a new instance of the ZipTie::TransferProtocol class.
This is simply a place to define the members of this base class/interface.

=item C<get_ip_address()>

Retrieves the hostname/IP address of the server that the implementation of the ZipTie::TransferProtocol
class is connected to.

=item C<_set_ip_address($ip_address)>

B<NOTE:> This should only be used by implementations of the C<ZipTie::TransferProtocol> class to store
this information.

Sets the hostname/IP address of the server that this implementation of the C<ZipTie::TransferProtocol>
class is connected to.

=item C<get_protocol_name()>

Retrieves the name of the transfer protocol that this implementation of the ZipTie::TransferProtocol
class represents.  For example: "FTP" or "SCP".

=item C<get_port()>

Retrieves the port that this implementation of the ZipTie::TransferProtocol
class has connected to on the server.

=item C<_set_port($port)>

B<NOTE:> This should only be used by implementations of the C<ZipTie::TransferProtocol> class to store
this information.

Sets the port value that this implementation of the C<ZipTie::TransferProtocol> class is connected to.

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
