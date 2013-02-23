package ZipTie::Telnet;

use strict;
use ZipTie::CLIProtocol;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::Logger;
use Net::Telnet;
use MIME::Base64 'decode_base64';
use XML::Simple;
use Net::IP qw(ip_compress_address);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

# Specifies that ZipTie::Telnet is a subclass of ZipTie::CLIProtocol
our @ISA = qw(ZipTie::CLIProtocol);

sub new
{
	my $className = shift;
	my $ioHandle  = shift;

	# Initialize this instance of the class
	my $this = ZipTie::CLIProtocol->new();

	# Turn $this into a ZipTie::Telnet object
	bless( $this, $className );

	# Set the protocol name
	$this->{protocol_name} = "Telnet";

	# Make sure to set the protocol implementation to be a new Net::Telnet object
	$this->{protocol_impl} = new Net::Telnet();
	if ($ioHandle)
	{
		$this->{protocol_impl}->fhopen($ioHandle);
	}

	# Set the error mode to call our _log_and_die($error_message) method
	$this->{protocol_impl}->errmode( \&_log_and_die );

	# Increase the default maximum buffer length to 5MB
	$this->{protocol_impl}->max_buffer_length(5_242_880);

	# Default the timeout to 30 seconds
	$this->set_timeout(30);

	# Return the object
	return $this;
}

sub connect
{
	my $this       = shift;
	my $ip_address = shift;
	my $port       = shift;

	# Telnet has no need for the username/password credentials
	my $username = shift;
	my $password = shift;

	$this->_set_ip_address($ip_address);

	my $netIp = new Net::IP($ip_address);
	
	if (!defined($netIp))
	{
		&_log_and_die("Unable to create a valid Net::IP object from the IP address: $ip_address!");
	}

	# Make sure that if the port is not defined or less than 1, to default it to 23
	if ( !defined($port) || $port <= 0 )
	{
		$LOGGER->debug("Invalid port '$port' defined. Defaulting to port '23'.");
		$port = 23;
	}
	$this->_set_port($port);

	# Log all input and output that has occurred during this session
	my $telnet = $this->{protocol_impl};

	if ( !*$telnet->{net_telnet}->{opened} )
	{
		$LOGGER->debug("About to connect to $ip_address over port $port ...");
		if ( $netIp->version() == 6 )
		{
			# use IO::Socket::INET6 to directly open a socket
			require IO::Socket::INET6;
			
			# Make sure to use the compressed format of the IPv6 address.
			# IO::Socket::INET6 doesn't seem to like fully expanded IPv6 addresses.
			my $compressed_v6_address = ip_compress_address($ip_address, 6);
			
			my $socket = IO::Socket::INET6->new(
				PeerAddr => $compressed_v6_address,
				PeerPort => $this->get_port(),
				Proto    => "tcp",
			);
			
			# Ensure that the INET6 socket was created before trying to pass it to Net::Telnet
			if (!defined($socket))
			{
				&_log_and_die("Unable to create an IPv6 socket to $ip_address over port $port!");
			}
			
			# Make Net::Telnet use our INET6 socket for all communication
			$telnet->fhopen($socket);
		}
		else
		{
			$telnet->open(
				Host    => $this->get_ip_address(),
				Port    => $this->get_port(),
				Timeout => $this->get_timeout(),
			);
		}
		$LOGGER->debug("Connected successfully to $ip_address over port $port.");

		if ( $this->sim_handshake )
		{
			$LOGGER->debug("Performing Telnet handshake with remote simulator.");
			my $handshakeXml = XMLout( $this->sim_handshake, RootName => 'sim-config', SuppressEmpty => 0 );
			$telnet->print($handshakeXml);
		}
	}
}

sub output_record_separator
{
	my $this = shift;
	my $newEol = shift;
	return $this->{protocol_impl}->output_record_separator($newEol);
}

sub disconnect
{
	my $this   = shift;
	my $telnet = $this->{protocol_impl};
	$telnet->close() if ( defined($telnet) );
}

sub send
{
	my $this  = shift;
	my $input = shift;

	my $telnet = $this->{protocol_impl};

	# Clear out the buffer so that no previous messages pollute it
	$telnet->buffer_empty();
	if( ref $this->{vt} ) 
	{
		$this->{vt}->reset();
	}

    # Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
	# See if we have a valid current interaction already.
	# If so, it needs to be closed out.  Mark that we have finished the current interaction.
	my $current_interaction = $RECORDING->get_current_interaction();
	if ( defined($current_interaction) )
	{
		$RECORDING->finish_current_interaction();
	}

	# Start the current interaction.  Right now, all it knows about it the command being executed,
	# what protocol is being used, whether or not the command is being sent as bytes, and
	# when the command was sent.
	my $interaction = ZipTie::Recording::Interaction->new(
		cliCommand  => $input,
		cliProtocol => $this->get_protocol_name(),
		asBytes     => 0
	);
	$RECORDING->start_current_interaction($interaction);
    }
    
    # Store the current input on the object.  This will make the current input be registered as the last
    # input that was sent
    $this->{input} = $input;

	# Send the input to the device and append any necessary CRLF data to the end of the input.
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[SENDING]");
	$LOGGER->debug($input);
	$LOGGER->debug("-----------------------------------------------------------------------------");
	if ( $this->{send_chars_separately} )
	{
		my @chars = split( '', $input );
		foreach my $char (@chars)
		{
			$telnet->put($char);
		}
		$telnet->print('');
	}
	else
	{
		$telnet->print($input);
	}
}

sub put
{
	my $this  = shift;
	my $input = shift;

	my $telnet = $this->{protocol_impl};

	# Clear out the buffer so that no previous messages pollute it
	$telnet->buffer_empty();
	if( ref $this->{vt} ) 
	{
		$this->{vt}->reset();
	}

    # Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
	# See if we have a valid current interaction already.
	# If so, it needs to be closed out.  Mark that we have finished the current interaction.
	my $current_interaction = $RECORDING->get_current_interaction();
	if ( defined($current_interaction) )
	{
		$RECORDING->finish_current_interaction();
	}

	# Start the current interaction.  Right now, all it knows about it the command being executed,
	# what protocol is being used, whether or not the command is being sent as bytes, and
	# when the command was sent.
	my $interaction = ZipTie::Recording::Interaction->new(
		cliCommand  => $input,
		cliProtocol => $this->get_protocol_name(),
		asBytes     => 0
	);
	$RECORDING->start_current_interaction($interaction);
    }
    
    # Store the current input on the object.  This will make the current input be registered as the last
    # input that was sent
    $this->{input} = $input;

	# Send the input to the device through a put, i.e. without CRLF
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[PUTTING]");
	$LOGGER->debug($input);
	$LOGGER->debug("-----------------------------------------------------------------------------");
	if ( $this->{send_chars_separately} )
	{
		my @chars = split( '', $input );
		foreach my $char (@chars)
		{
			$telnet->put($char);
		}
	}
	else
	{
		$telnet->put($input);
	}
}

sub send_as_bytes
{
	my $this  = shift;
	my $input = shift;

	my $telnet = $this->{protocol_impl};

	# Clear out the buffer so that no previous messages pollute it
	$telnet->buffer_empty();
	if( ref $this->{vt} ) 
	{
		$this->{vt}->reset();
	}

	# Find the length of the input and construct a valid argument for Perl's pack() function.
	# This will convert our ASCII input into hexadecimal.
	my $length     = length($input);
	my $pack_arg   = "H" . $length;
	my $byte_input = pack( $pack_arg, $input );

    # Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
	# See if we have a valid current interaction already.
	# If so, it needs to be closed out.  Mark that we have finished the current interaction.
	my $current_interaction = $RECORDING->get_current_interaction();
	if ( defined($current_interaction) )
	{
		$RECORDING->finish_current_interaction();
	}

	# Start the current interaction.  Right now, all it knows about it the command being executed,
	# what protocol is being used, whether or not the command is being sent as bytes, and
	# when the command was sent.
	my $interaction = ZipTie::Recording::Interaction->new(
		cliCommand  => $input,
		cliProtocol => $this->get_protocol_name(),
		asBytes     => 1
	);
	$RECORDING->start_current_interaction($interaction);
    }
    
    # Store the current input on the object.  This will make the current input be registered as the last
    # input that was sent
    $this->{input} = $input;

	# Send the input to the device without appending any special CRLF information.  The command
	# interpreter on the device should automatically know what to do with the sequence of bytes
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[SENDING BYTE(S) (showing hexadecimal value)]");
	$LOGGER->debug($input);
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$telnet->put($byte_input);
}

sub wait_for
{
	my $this  = shift;
	my $regex = shift;

	# If no timeout is explicitly set for this wait_for, use the global timeout
	my $timeout = defined( @_[0] ) ? shift: $this->get_timeout();

	# Grab our instance to Net::Telnet
	my $telnet = $this->{protocol_impl};

	# Make sure to append Perl matching metacharcters for the regular expression if they don't already
	# exist on there
	unless ( $regex =~ m(^\s*/) or $regex =~ m(^\s*m\s*\W) )
	{
		$regex = "/" . $regex;
		$regex .= "|" . $this->{more_prompt}->{prompt} if ( defined $this->{more_prompt} );
		$regex .= "/";
	}

	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug( "[WAITING " . $timeout . " SECOND(S) FOR]" );
	$LOGGER->debug($regex);
	$LOGGER->debug("-----------------------------------------------------------------------------");

	# Turn off the error mode that calls our _log_and_die($error_message) methodfor our Net::Telnet object.
	# Let's allow the waitfor method to return an error.  If so, let's die with a more detailed error message.
	$telnet->errmode("return");

	# Wait for the response from the device
	my ( $pre, $match ) = $telnet->waitfor( Match => $regex, Timeout => $timeout );

	# Handle any potential timeout
	if ( $telnet->timed_out() )
	{
		my $ip_address          = $this->get_ip_address();
		my $actual_command      = $this->last_input();
		my $actual_response     = ${ $telnet->buffer() };
		my $error_message       = "[$UNEXPECTED_RESPONSE]\n";
		$error_message .= "'$ip_address' timed-out while waiting to match the regular expression '$regex'.\n";
		$error_message .= "[INPUT]\n$actual_command\n" unless (!defined($actual_command) || !$actual_command);
		$error_message .= "[ACTUAL RESPONSE]\n$actual_response";
		$LOGGER->fatal($error_message);
	}
	elsif ( $telnet->errmsg() )
	{
		# We didn't get a match, yet we didn't time out, so some other error must have occurred
		
		# If "eof" is in the error message, construct a more verbose error message
		if ( $telnet->errmsg() =~ /eof/mi )
		{
			$LOGGER->fatal( "[$TELNET_ERROR]\nCould not match '$regex' because connection to device no longer exists!" );
		}
		else
		{
		  $LOGGER->fatal( "[$TELNET_ERROR]\n" . $telnet->errmsg() );
		}
	}
	else
	{

		# Restore the error mode handling for this Net::Telnet object to our _log_and_die($error_message) method
		$telnet->errmode( \&_log_and_die );
	}

	# We want to know the entire response from the device for a given input, not just what was matched
	my $response = $pre . $match;
	
	# Check to see if we should wait for chatter also
	if ( defined $this->{wait_for_chatter} )
	{
		$LOGGER->debug("Start waiting for device chatter after successful wait for ...");
		
		# Use the get_response mechanism to attempt to get an additional device chatter
	    my $additionalChatter = $this->get_response($this->{wait_for_chatter});
	    
	    # Append the additional chatter to the response
        $response .= $additionalChatter;
        
        $LOGGER->debug("Finished waiting for device chatter after successful wait for.");
	}

	# if the more prompt was matched, send the more action and waitfor again
	if ( defined $this->{more_prompt} )
	{
		if ( $response =~ /$this->{more_prompt}->{prompt}/ )
		{
			###########################################################################################################
			#
			#    End this interaction, both for debugging and recording purposes since we are about to short-circuit
			#    the wait-for logic to send a new command.
			#
			###########################################################################################################

			$LOGGER->debug("-----------------------------------------------------------------------------");
			$LOGGER->debug("[RESPONSE]");
			$LOGGER->debug($response);
			$LOGGER->debug("-----------------------------------------------------------------------------");

            # Check to see if recording is enabled
		    if ( $ENV{ENABLE_RECORDING} )
		    {
			# See if we have a valid current interaction or not.  If not, a new one needs to be created.
			my $current_interaction = $RECORDING->get_current_interaction();
			if ( !defined($current_interaction) )
			{

				# Start a new interaction.  Right now, all it knows about it the command being executed,
				# what protocol is being used, whether or not the command is being sent as bytes, and
				# when the command was sent.
				$current_interaction = ZipTie::Recording::Interaction->new(
					cliCommand  => "",
					cliProtocol => $this->get_protocol_name(),
					asBytes     => 0
				);
				$RECORDING->start_current_interaction($current_interaction);
			}

			# The current interaction needs to be closed out.
			# Mark the wait for prompt, the timeout value, and the response.
			$current_interaction->waitFor($regex);
			$current_interaction->timeout($timeout);
			$current_interaction->cliResponse($response);

			# Mark that we have finished the current interaction.
			$RECORDING->finish_current_interaction();
		    }

			###########################################################################################################

			# Send the byte info to progress past the more prompt
			$this->send_as_bytes( $this->{more_prompt}->{action} );

			# Append the next wait for to this response
			$response .= $this->wait_for($regex);
			$this->{match} = $response;

			# Return the result
			return $this->{match};
		}
	}

	# if vt102 term is on, process as that
	if ( defined $this->{vt} )
	{
		my $vt = $this->{vt};
		$vt->process($response);
		$this->{match} = "";
		for ( my $row = 1 ; $row <= $vt->rows() ; $row++ )
		{
			$this->{match} .= $vt->row_plaintext($row) . "\n";
		}
	}
	else
	{
		$this->{match} = $response;
	}

	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[RESPONSE]");
	$LOGGER->debug( $this->{match} );
	$LOGGER->debug("-----------------------------------------------------------------------------");

    # Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
	# See if we have a valid current interaction or not.  If not, a new one needs to be created.
	my $current_interaction = $RECORDING->get_current_interaction();
	if ( !defined($current_interaction) )
	{

		# Start a new interaction.  Right now, all it knows about it the command being executed,
		# what protocol is being used, whether or not the command is being sent as bytes, and
		# when the command was sent.
		$current_interaction = ZipTie::Recording::Interaction->new(
			cliCommand  => "",
			cliProtocol => $this->get_protocol_name(),
			asBytes     => 0
		);
		$RECORDING->start_current_interaction($current_interaction);
	}

	# The current interaction needs to be closed out.
	# Mark the wait for prompt, the timeout value, and the response.
	$current_interaction->waitFor($regex);
	$current_interaction->timeout($timeout);
	$current_interaction->cliResponse($response);

	# Mark that we have finished the current interaction.
	$RECORDING->finish_current_interaction();
    }

	# Return the result
	return $this->{match};
}

sub get_response
{
	my $this = shift;

	# If no timeout is explicitly set for this wait_for, set it to 5 seconds
	my $timeout = defined( @_[0] ) ? shift: 5;
	
	# Grab our instance to Net::Telnet
	my $telnet = $this->{protocol_impl};

	# Store the overall response from the device that is made up from all the chatter captured from the device
	my $response = "";
	my $chatter  = "";

	# Wait for the specified timeout window for any chatter to be received from the device.
	# Continue to do this as long as chatter is received.
	do
	{
		$LOGGER->debug("-----------------------------------------------------------------------------");
		$LOGGER->debug( "[WAITING " . $timeout . " SECOND(S) FOR CHATTER]" );

		# Attempt to capture chatter from the device
		$chatter = $telnet->get( Errmode => "return", Timeout => $timeout );

		# If chatter was received, then append it our response that makes up the overall response
		# of the device.
		if ( defined($chatter) )
		{
			$LOGGER->debug("[CHATTER RECEIVED]");
			$LOGGER->debug($chatter);
			$LOGGER->debug("-----------------------------------------------------------------------------");

			$response .= $chatter;
		}
	} while ( defined($chatter) );

	# Now the the chatter has stopped and no errors occurred, return the overall response
	$LOGGER->debug( "[NO CHATTER RECEIVED WITHIN " . $timeout . " SECOND(S)]" );

	# if vt102 term is on, process as that
	if ( defined $this->{vt} )
	{
		my $vt = $this->{vt};
		$vt->process($response);
		my $processedResponse = "";
		for ( my $row = 1 ; $row <= $vt->rows() ; $row++ )
		{
			$processedResponse .= $vt->row_plaintext($row) . "\n";
		}
		$response = $processedResponse;
		$LOGGER->debug($response);
	}
	$LOGGER->debug("-----------------------------------------------------------------------------");
	
	return $response;
}

sub set_timeout
{
	my $this    = shift;
	my $timeout = shift;

	$this->{timeout} = $timeout;

	my $telnet = $this->{protocol_impl};
	$telnet->timeout($timeout);
}

sub _log_and_die
{
	my $error_message = shift;
	
	# If "eof" is in the error message, construct a more verbose error message
    if ( $error_message =~ /eof/mi )
    {
        $LOGGER->fatal( "[$TELNET_ERROR]\nCould not match regular expression because connection to device no longer exists!" );
    }
    else
    {
        $LOGGER->fatal( "[$TELNET_ERROR]\n" . $error_message );
    }
}

sub DESTROY
{
	my $this = shift;
	$this->disconnect();
}

1;

__END__

=head1 NAME

ZipTie::Telnet - Telnet implementation of the ZipTie::CLIProtocol interface/abstract class.

=head1 SYNOPSIS

	use ZipTie::CLIProtocol;
	use ZipTie::CLIProtocolFactory;

	my $telnet = ZipTie::CLIProtocolFactory->create("Telnet", "10.10.10.10", 22);
	$telnet->connect($telnet->get_ip_address(), $ssh->get_port());

=head1 DESCRIPTION

C<ZipTie::Telnet> provides an Telnet implementation of the C<ZipTie::CLIProtocol> interface/abstract class.
It leverages the implemented methods from C<ZipTie::CLIProtocol> and utilizes the C<Net::Telnet>
module to provide Telnet-specifc support to the interface methods.

=head1 METHODS

Please refer to the "METHOD" section of the C<ZipTie::CLIProtocol> documentation to know what methods
there are and how they are used.  Any additional documentation to methods that have their own unique
implementation for Telnet purposes will be documented below.

=over 12

=item C<new($ioHandle)>

Creates a new instance of the C<ZipTie::Telnet> class with a default timeout value of 30 seconds.
While this constructor method can be called on its own, it is recommend that the C<ZipTie::CLIProtocolFactory>
and its C<create> method be used for creating objects based off of the C<ZipTie::CLIProtocol> class.

$ioHandle - an optional argument.  If an already open IO handle is provided, then the connect method will
			do nothing and all send and receive methods will read and write from the provided filehandle.

=item C<connect($ip_address, $port)>

Connects to a device at a specified IP address and port.  Although the interface specified by the 
C<ZipTie::CLIProtocol> class specifies that C<connect()> also takes in a a username and password, these
are not need and not used by the C<ZipTie::Telnet> implementation.

$ip_address -	The administrative IP address of the device.

$port -			The port to connect to on the device.

=item C<disconnect()>

Disconnects from the device this C<ZipTie::Telnet> object is already connected to.

=item C<send($input)>

Sends an input string to the device.  In order to retrieve the output, it is expected that the user
will call C<wait_for()> method with a valid regular expression after the call to C<send()>.

=item C<put($input)>

Same as C<send> except that no line separator, e.g. a CRLF, is appended to the $input.

=item C<send_as_bytes($input)>

Converts an input string into a hexadecimal byte representation and sends it to the device.
Unlike C<send()>, C<send_as_bytes()> will not append any special CRLF character/bytes to the end of the input.
The input will simply be converted into hexadecimal and will be sent as is.  It is expected that the
command interpreter on the device should know how to handle the byte information coming in.

In order to retrieve the output, it is expected that the user will call C<wait_for()> with a valid regular 
expression after the call to C<send_as_bytes()>.

=item C<set_timeout($timeout)>

Set the length (in seconds) for how long the C<wait_for()> method should wait on a response from a
device before timing out.  This time out value will only be used if the the C<wait_for()> method is used
with the matching regular expression as its only parameter.

=item C<wait_for($regex, $timeout)>

Waits for the response from a device and checks to see if the response matches a specified regular expression.
If a match is found, all of the response preceeding AND including the match will be returned.  It is assumed
that this function will be called directly after a call to send().

$regex -	A valid regular expression to match the response from the device.

$timeout -	Optional.  Specifies the amount of time (in seconds) to wait for a response from the device.
			If this parameter is specified, the timeout specified by a call to C<set_timeout()> will be ignored
			for this function call only.

=item C<get_response($timeout)>

Waits a specified window of time for a response to come back from the device.  Given a window of time, if any data
is sent from the device, it will be collected and stored as part of the overall response from the device.  If the window
of time goes by without any response from the device, it is then assumed that the device is done responding and the
overall response will be returned.

The use of C<get_response($timeout)> might be desireable over C<wait_for($regex, $timeout)> if there is not a particular
part of the response from a device you are waiting for, or if the response from a device comes back in an unexpected
format/flow.

$timeout -	Optional; 5 seconds by default.  Specifies the a window of time (in seconds) to wait for a response
			from the device.
			
=item C<output_record_separator($charSequence)>

Set or get the output record separator.  The $charSequence argument is optional.  If no argument is given, this method
simply returns the current value of the output record separator, such as a CR or CRLF.

=item C<_log_and_die($error_message)>

B<NOTE:> This method is only used as a callback when C<Net::Telnet> encounters a fatal situation, instead of die-ing.

Invokes the the C<ZipTie::Logger> singleton's C<fatal($message)> method with a specified error message.  This
method is used as a callback whenever C<Net::Telnet> encounters a fatal situation.  This is done by calling the
C<errmode($code_reference)> method on the C<Net::Telnet> instance; once registered, C<Net::Telnet> will call this method
with the error message it generated.

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
Date: May 8, 2007

=cut
