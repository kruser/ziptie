package ZipTie::SCP;

use strict;
use warnings;

use ZipTie::TransferProtocol;
use ZipTie::Logger;

use File::Basename qw(fileparse);
use IPC::Run qw( start pump finish timeout );
use Net::IP;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that ZipTie::SCP is a subclass of ZipTie::TransferProtocol
our @ISA = qw(ZipTie::TransferProtocol);

sub new
{
	my $class_name = shift;

	# Initialize this instance of the class as a ZipTie::TransferProtocol
	# since at its core, that is what it is.
	my $this = ZipTie::TransferProtocol->new();
	
	# Add any additional members
	$this->{handle} = undef;
	$this->{cache_key} = 1;
	$this->{update_cached_key} = 1;
	$this->{continue_with_connection} = 1;

	# Turn $this into a ZipTie::SCP object
	bless( $this, $class_name );

	# Set the protocol name
	$this->{protocol_name} = "SCP";

	# Default the timeout to 30 seconds
	$this->set_timeout(30);

	# Return the object
	return $this;
}

sub connect
{
	# Grab a reference to our self/this instance
	my $this = shift;

	# Store the parameters specified
	my $ip_address = shift;
	my $port       = shift;
	my $username   = shift;
	my $password   = shift;
	
	$this->_set_ip_address($ip_address);
	$this->_set_port($port);
	$this->{username} = $username;
	$this->{password} = $password;
}

sub disconnect
{
	my $this = shift;

	eval
	{
        $LOGGER->debug("Finishing the IPC::Run harness used for PSCP...");
        $this->{handle}->finish;
        $LOGGER->debug("Killing off PSCP ...");
        $this->{handle}->kill_kill;
    };
    if ($@)
    {
        $LOGGER->debug("Error on finishing off the IPC::Run used for PSCP harness, so killing everything instead ...");

        # Kill this process with only a 1 second grace period
        $this->{handle}->kill_kill( grace => 1 );
    }
}

sub get
{
	my $this             = shift;
	my $remote_file_path = shift;
	my $local_file_path  = shift;
	my $waitTime  = shift;

    # Construct the source part of the SCP request
    # Make sure that IPv6 address are properly bracketed.
	my $netIp = new Net::IP($this->get_ip_address());
	my $source;
	if ( $netIp->version() == 6 )
	{
		$source = '[' . $this->get_ip_address() . "]:$remote_file_path";
	}
	else
	{
		$source = $this->get_ip_address() . ":$remote_file_path";
	}

	# Set the target to be the local file path specified.  If a local file path was not specified, use the
	# file name from the absolute remote file path.
	my $target = $local_file_path;
	if ( !defined($target) )
	{
		my ( $filename, $directories, $suffix ) = fileparse($remote_file_path);
		$target = $filename;
	}

	# Call PSCP through Perl
	$LOGGER->debug("About to perform a SCP get action");
	$LOGGER->debug( "IP/Host: " . $this->get_ip_address() );
	$LOGGER->debug( "Port: " . $this->get_port() );
	$LOGGER->debug("Source: $source");
	$LOGGER->debug("Target: $target");
	my $pscp_status = $this->pscp( $source, $target);
	
	return $pscp_status;
}

sub put
{
	my $this             = shift;
	my $local_file_path  = shift;
	my $remote_file_path = shift;

	# Set the source to be the local file path specified
	my $source = $local_file_path;

	# If no remote path was specified, use the file name from the local file path
	if ( !defined($remote_file_path) )
	{
		my ( $filename, $directories, $suffix ) = fileparse($local_file_path);
		$remote_file_path = $filename;
	}
	
	# Construct the target part of the SCP request
	# Make sure that IPv6 address are properly bracketed.
	my $target;
	my $netIp = new Net::IP($this->get_ip_address());
    if ( $netIp->version() == 6 )
    {
        $target = '[' . $this->get_ip_address() . "]:$remote_file_path";
    }
    else
    {
        $target = $this->get_ip_address() . ":$remote_file_path";
    }

	# Call PSCP through Perl
	$LOGGER->debug("About to perform a SCP put action");
	$LOGGER->debug( "IP/Host: " . $this->get_ip_address() );
	$LOGGER->debug( "Port: " . $this->get_port() );
	$LOGGER->debug("Source: $source");
	$LOGGER->debug("Target: $target");
	my $pscp_status = $this->pscp( $source, $target);
	
	return $pscp_status;
}

sub pscp
{
	my $this   = shift;
	my $source = shift;
	my $target = shift;

	# Define the PSCP options
	my @pscp_options = ();
	push( @pscp_options, '-v' );
	push( @pscp_options, '-scp' );
	push( @pscp_options, ( '-l',  $this->{username} ) ) if $this->{username};
	push( @pscp_options, ( '-pw', $this->{password} ) ) if $this->{password};
	push( @pscp_options, ( '-P',  $this->{port} ) );

	# Store all of the info needed to execute the PSCP command in an array
	my @pscp_info = ( "pscp", @pscp_options, $source, $target );

	# Execute our PSCP command and have it use all of the handles we have set up
	my $pscp_command_debug = "";
	my $is_password        = 0;
	foreach (@pscp_info)
	{
		my $value = $_;

		# Hide the password arg
		if ($is_password)
		{
			$value       = "<password_is_hidden>";
			$is_password = 0;
		}
		elsif ( $value eq "-pw" )
		{
			$is_password = 1;
		}

		$pscp_command_debug .= " $value";
	}
	
	# Attempt to kick off the PSCP process
	$LOGGER->debug("Executing the following command: $pscp_command_debug");
	
	eval { $this->{handle} = start \@pscp_info, \$this->{in}, \$this->{out}, \$this->{err}, ( $this->{timer} = timeout( $this->{timeout} ) ); };
    if ($@)
    {
        $LOGGER->fatal_error_code( $SCP_ERROR, $this->get_ip_address(), "Could not make connection to device because pscp process couldn't be started!\n[DETAILED ERROR MESSAGE]\n$@" );
    }

	# Until we have reached the "Connected to" message, we must parse the output of PSCP's connection process to
	# handle any errors we might encounter and to also interact with either the store key in cache prompt or the update
	# cached key prompt so that a device's public key can be added to PSCP's list of known hosts.
	my $error_stream_buffer = "";
	my $store_key_prompt    = 0;
	my $update_cached_key_prompt = 0;
	my $continue_with_connection_prompt = 0;
	
	# Create a regex to parse the exit status
	my $exit_status_regex = 'exit\s*status\s+(\d+)';
	my $exit_status_encountered = 0;
	my $exit_status = 1;

	while ( !$exit_status_encountered )
	{
		if (length($this->{err}) <= 0 && $this->{handle}->pumpable())
        {
            eval { $this->{handle}->pump until length($this->{err}) > 0; };
            if ($@)
            {
                $LOGGER->fatal_error_code( $SCP_ERROR, $this->get_ip_address(), "Error reading PSCP's error stream!\n[DETAILED ERROR MESSAGE]\n$@" );
            }
        }
        
        # Add the chunk read in to our total error stream buffer
        $error_stream_buffer .= $this->{err};

        # Clear out the internal error buffer of IPC::Run
        $this->{err} = '';
		
		# If we have encountered the "Store key in cache" prompt, then signal
		# to PSCP that we would like to store it.
		if ( !$store_key_prompt && $error_stream_buffer =~ /Store key in cache/ )
		{
			$LOGGER->debug( "Encountered a 'Store key in cache' prompt from " . $this->get_ip_address() );
			if ($this->{cache_key})
			{
				$LOGGER->debug("Accepting and storing the key into the local machine's cache.");
			}
			else
			{
				$LOGGER->debug("Not accepting and not storing the key into the local machine's cache.");
			}
			
			$store_key_prompt = 1;
			$this->_send( $this->{cache_key} ? "y" : "n" );
		}
		
		# If we have encountered the "Update cached key" prompt, then signal
		# to PSCP that we would like to update the key already cached on the local machine it.
		if ( !$update_cached_key_prompt && $error_stream_buffer =~ /Update cached key/ )
		{
			$LOGGER->debug( "Encountered a 'Update cached key' prompt from " . $this->get_ip_address() );
			if ($this->{update_cached_key})
			{
				$LOGGER->debug("Accepting and updating the key in the local machine's cache.");
			}
			else
			{
				$LOGGER->debug("Not accepting and not updating the key in the local machine's cache.");
			}
			
			$update_cached_key_prompt = 1;
			$this->_send( $this->{update_cached_key} ? "y" : "n" );
		}
		
		# If we have encountered the "Continue with connection" prompt, then signal
		# to PSCP that we would like to continue with the connection, despite using an undesireable cipher.
		if ( !$continue_with_connection_prompt && $error_stream_buffer =~ /Continue with connection/ )
		{
			$LOGGER->debug( "Encountered a 'Continue with connection' prompt from " . $this->get_ip_address() );
			if ($this->{continue_with_connection})
			{
				$LOGGER->debug("Continuing with the connection.");
			}
			else
			{
				$LOGGER->debug("Not continuing with the connection.");
			}
			
			$continue_with_connection_prompt = 1;
			$this->_send( $this->{continue_with_connection} ? "y" : "n" );
		}
		
		# Check to see if we have encountered the exit status
		if ( !$exit_status_encountered && $error_stream_buffer =~ /$exit_status_regex/)
		{
			$exit_status_encountered = 1;
			$exit_status = $1;
		}

		# Handle errors during the connection process
		if ( !$exit_status_encountered && $error_stream_buffer =~ /'pscp' is not recognized|pscp:\s+command not found/ )
		{
			$this->_log_and_kill_pscp(
				"PSCP executable was not found in the system path!\nThe system path contains the following locations: '" . $ENV{PATH} . "'",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /No such file or directory/)
		{
			$this->_log_and_kill_pscp("No such file or directory found!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Connection timed out/ )
		{
			$this->_log_and_kill_pscp( "Connection timed out!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Authentication refused/ )
		{
			$this->_log_and_kill_pscp( "Authentication refused!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Unable to authenticate|password:\s*$/ )
		{
			$this->_log_and_kill_pscp( "Unable to authenticate!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Connection refused/ )
		{
			$this->_log_and_kill_pscp( "Connection refused!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Sent EOF message/i )
		{
			$exit_status_encountered = 1;
            $exit_status = 0;
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Fatal:|Fatal error:/i )
		{
			$this->_log_and_kill_pscp( "Fatal error encountered in PSCP!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Host does not exist/ )
		{
			$this->_log_and_kill_pscp(
				"'" . $this->get_ip_address() . "' is not a valid host!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /Disconnected/ )
		{
			$this->_log_and_kill_pscp( "Disconnected prematurely!",
				$error_stream_buffer );
		}
		elsif ( !$exit_status_encountered && $error_stream_buffer =~ /unknown option/ )
		{
			$this->_log_and_kill_pscp( "Unknown option passed into PSCP!", $error_stream_buffer );
		}
	}
	
	# Since we got this far, we can shut down the IPC::Run harness
    $this->{handle}->finish;
    
    # Examine the exit status
    if ( $exit_status == 0 )
    {
        $LOGGER->debug("SCP file transfer successful!");
        $LOGGER->debug("=====START PSCP OUTPUT=====");
        $LOGGER->debug($error_stream_buffer);
        $LOGGER->debug("=====END PSCP OUTPUT=====");
    }
    else
    {
        $this->_log_and_kill_pscp("Non-Zero exit status returned by PSCP, error occurred during SCP file transfer!", $error_stream_buffer);
    }
    
	# Return true if we got this far
	return $exit_status;
}

sub _log_and_kill_pscp
{
	my $this              = shift;
	my $error_message     = shift;
	my $pscp_error_stream = shift;

	my $compiled_error_message = "[$SCP_ERROR]\n$error_message";
	$compiled_error_message .= "\n=====START PSCP OUTPUT=====\n";
	$compiled_error_message .= $pscp_error_stream;
	$compiled_error_message .= "=====END PSCP OUTPUT=====\n";

	$LOGGER->fatal($compiled_error_message);
}

sub DESTROY
{
	# Preserve any pre-existing error message stored in the $@ sign, since
    # disconnect might over-ride what's already stored in there
    my $err = $@;

    my $this = shift;

    # Disconnect from the device
    $this->disconnect();

    # Restore any pre-existing error message
    $@ = $err;
}

sub _send
{
	my $this = shift;
	my $input = shift;
	
	# Prep the input to be sent through the IPC::Run harness
	$this->{in} = $input . "\n";
	
	# Send the input
    eval
    {
        while ( $this->{in} )
        {
            $this->{handle}->pump;
        }
    };
}

1;

__END__

=head1 NAME

ZipTie::SCP - SCP client implementation of the ZipTie::TransferProtocol interface/abstract base class.

=head1 SYNOPSIS

	use ZipTie::TransferProtocol;
	use ZipTie::TransferProtocolFactory;

	my $xfer_client = ZipTie::TransferProtocolFactory::create("SCP");
	$xfer_client->connect("10.10.10.10", 22, somename, somepassword);
	$xfer_client->put("test.txt", "test.txt");
	$xfer_client->disconnect();

=head1 DESCRIPTION

ZipTie::SCP represents a client implementing the SCP protocol that adheres to the interface specified by the
ZipTie::TransferProtocol class.  The core backing of this implementation is provided by the PSCP executable.
PSCP is PuTTY's secure copy client and was chosen for the fact that it can be compiled to work on all of the operating
systems supported by the ZipTie framework.

It is assumed that the PSCP executable is located within the system path and is accessible to any Perl code that may
utilize the C<ZipTie::SCP> module.  If PSCP is not located within the system path, then an error will occur when any file
transfer is attempted using C<ZipTie::SCP> module.

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

Stores various information needed by the PSCP program to authenticate and connect to a device when performing a file transfer
action.  No explicit connection takes place: that only happens with calls to C<get($remote_file, $local_file)> and
C<put($local_file, $remote_file)>.

$ip_address -	The hostname/IP address of the server.

$port -			The port to connect to on the server.

$username -		The username credential to use against the server.

$password -		Optional.  The password credential to use against the server.  If the local machine has a key to automate
				authentication to the device, that will be used.

=item C<disconnect()>

Since the SCP protocol does necessitate a need to disconnect to the server, the C<disconnect()> method serves simply as a
clean up method for any lingering PSCP process.  If a PSCP process still exists that was spawned by this C<ZipTie::SCP> object,
it will be killed.

=item C<get($remote_file, $local_file)>

Retrieves a remote file from the host/IP address that this this C<ZipTie::SCP> object is aware of.

$remote_file -	A relative or absolute filepath on the host/server defining the file to be retrieved.
				If the filepath is relative, it is then relative to the default directory of the host/server.

$local_file -	Optional.  A filepath where the remote file should be transfer to on the local machine.
				This file path can either absolute or relative.  If the filepath is not specified, then the file
				name of the remote file being retrieved will be used and placed within the current working directory
				on the local machine.  The current working directory will also be used as the relative directory if
				the local file name is not absolute.

Returns I<true> if the file transfer was successful; I<false> otherwise.

=item C<put($local_file, $remote_file)>

Sends a local file to the host/IP address that this C<ZipTie::SCP> object is aware of.

$local_file -	A filepath defining of the local file to put on the host/server.  This file path can either absolute or
				relative.  If the filepath is relative, then it is relative to the current working directory.

$remote_file -	Optional.  A filepath defining where the local file should be transfer to on the host/server.
				This file path can either absolute or relative.  If the filepath is not specified, then the file
				name of the local file being sent will be used and placed within the default directory of the host/server.

Returns I<true> if the file transfer was successful; I<false> otherwise.

=item C<pscp($source, $target)>

Invokes a PSCP process to perform a file transfer between a specifed source and target.  Both the C<get($remote_file, $local_file)>
and C<put($local_file, $remote_file)> methods call this method after constructing the necessary source and target arguments.

It is assumed that the PSCP executable is located within the system path and is accesible to the Perl script
utilizing this C<ZipTie::SCP> object.  If PSCP is not located within the system path, then an error will occur.

If the PSCP process successfully performs the file transfer, I<true> will be returned; I<false> otherwise.

The PSCP process is invoked with the following flags: 

	-V        print version information and exit
	-pgpfp    print PGP key fingerprints and exit
	-p        preserve file attributes
	-q        quiet, don't show statistics
	-r        copy directories recursively
	-v        show verbose messages
	-load sessname  Load settings from saved session
	-P port   connect to specified port
	-l user   connect with specified username
	-pw passw login with specified password
	-1 -2     force use of particular SSH protocol version
	-4 -6     force use of IPv4 or IPv6
	-C        enable compression
	-i key    private key file for authentication
	-noagent  disable use of Pageant
	-agent    enable use of Pageant
	-batch    disable all interactive prompts
	-unsafe   allow server-side wildcards (DANGEROUS)
	-sftp     force use of SFTP protocol
	-scp      force use of SCP protocol

Here is an example of the the PSCP command that is executed:

pscp -v -scp -l someUser -pw somePassword -P 22 10.10.10.1:remotefile.txt localfile.txt

pscp -v -scp -l someUser -pw somePassword -P 22 localfile.txt 10.10.10.1:remotefile.txt

=item C<_log_and_kill_pscp($error_message, $pscp_error_stream)>

Logs a specified error message and the assumed PSCP error stream using the C<ZipTie::Logger> singleton and kills
the currently running PSCP process.  This method should only be used if an error was encountered and that error
should be logged before the Perl and PSCP processes are killed.

=back

=head1 INHERITED METHODS

The following methods are all methods that have been inherited from the C<ZipTie::TransferProtocol> module.

=over 12

=item C<get_ip_address()>

Retrieves the hostname/IP address of the server that the implementation of the ZipTie::TransferProtocol
class is connected to.

=item C<get_protocol_name()>

Retrieves the name of the transfer protocol that this implementation of the ZipTie::TransferProtocol
class represents.  For example: "SCP".

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

=head1 SEE ALSO

=over

=item *

PSCP Documentation - L<http://www.tartarus.org/~simon/puttydoc/Chapter5.html>

=item *

PuTTY Homepage - L<http://www.chiark.greenend.org.uk/~sgtatham/putty/>

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

Contributor(s): dwhite
Date: May 14, 2007

=cut
