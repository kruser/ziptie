package ZipTie::CLIProtocol;

use strict;
use ZipTie::Logger;
use ZipTie::Response;
use Term::VT102;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

#######################################################################
#
#	IMPLEMENTED METHODS
#
#######################################################################

sub new
{
	my $className = shift;

	# Initialize this instance of the class
	my $this = {
		protocol_impl => undef,
		protocol_name => undef,
		ip_address    => undef,
		port          => undef,
		match         => undef,
		input         => undef,
		timeout       => 30,
		prompts       => undef,
	};

	# Turn $this into a ZipTie::CLIProtocol object
	bless( $this, $className );

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
		$this->{ip_address} = shift;
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
		$this->{port} = shift;
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

sub send_and_wait_for
{
	my $this    = shift;
	my $command = shift;
	my $regex   = shift;
	my $timeout = defined( @_[0] ) ? shift: $this->get_timeout();

	# Send the command
	$this->send($command);

	# Wait for the response
	my $response = $this->wait_for( $regex, $timeout );

	# Return the found response
	return $response;
}

sub send_as_bytes_and_wait
{
	my $this    = shift;
	my $command = shift;
	my $regex   = shift;
	my $timeout = defined( @_[0] ) ? shift: $this->get_timeout();

	# Send the command
	$this->send_as_bytes($command);

	# Wait for the response
	my $response = $this->wait_for( $regex, $timeout );

	return $response;
}

sub wait_for_responses
{
	my $this      = shift;
	my $responses = shift;

	# If no timeout is explicitly set for this wait_for, use the global timeout
	my $timeout = defined( @_[0] ) ? shift: $this->get_timeout();

	# Combine all of the regular expressions from the responses into one massive regular expression
	my $regex = "";
	foreach my $response (@$responses)
	{
		$regex .= '(' . $response->get_regex() . ')|';
	}
	$regex =~ s/\|$//;

	# Wait for using the new found regular expression
	my $device_text_response = $this->wait_for( $regex, $timeout );

	# Check each ZipTie::Response object in the array to see if it was matched
	my $matched_response_obj = undef;
	foreach my $response (@$responses)
	{
		my $regex_to_match = $response->get_regex();
		my $trimmed_text = $device_text_response;
		$trimmed_text =~s/\s+/ /gism;
		$LOGGER->debug("Matching '$regex_to_match' in '$trimmed_text'\n");
		if ( $device_text_response =~ /$regex_to_match/mi )
		{

			# Found a valid response
			$matched_response_obj = $response;

			# See if any error occurred
			my $error_message = $matched_response_obj->get_error_message();
			if ( $error_message && $error_message =~ /.+/ )
			{
				my $ip = $this->get_ip_address();
				$LOGGER->fatal_error_code( $error_message, $ip, $device_text_response );
			}
			#It all went fine, we found the pattern, time to get out
			else
			{
				$LOGGER->debug("Matched '$regex_to_match'\n");
				last;
			}
		}
	}

	# If no ZipTie::Response object was able to handle the response from the device, then an unexpected
	# response has occurred.
	if ( !defined($matched_response_obj) )
	{
		my $ip_address    = $this->get_ip_address();
		my $actual_command = $this->last_input();
		my $error_message = "[$UNEXPECTED_RESPONSE]\n";
		$error_message .= "'$ip_address' timed-out after $timeout seconds while waiting to match the regular expression '$regex'.\n";
		$error_message .= "[INPUT]\n$actual_command\n" unless (!defined($actual_command) || !$actual_command);
		$error_message .= "[ACTUAL RESPONSE]\n$device_text_response";
		$LOGGER->fatal($error_message);
	}

	# Return the ZipTie::Response object that was matched
	return $matched_response_obj;
}

sub last_match()
{
	my $this       = shift;
	my $last_match = $this->{match};
	return $this->{match};
}

sub last_input()
{
	my $this = shift;
	my $last_input = $this->{input};
	return $this->{input};
}

sub get_prompt_by_name
{
	my $this        = shift;
	my $prompt_name = shift;

	my $prompt_regex = undef;

	if ($prompt_name)
	{
		$prompt_regex = $this->{prompts}->{$prompt_name};
	}

	return $prompt_regex;
}

sub set_prompt_by_name
{
	my $this         = shift;
	my $prompt_name  = shift;
	my $prompt_regex = shift;

	if ($prompt_name)
	{
		$this->{prompts}->{$prompt_name} = $prompt_regex;
	}
}

sub turn_vt102_on
{
	my $this = shift;
	my ( $columns, $rows ) = @_;
	if ( $columns, $rows )
	{
		$this->{vt} = Term::VT102->new( 'cols' => $columns, 'rows' => $rows );
	}
}

sub turn_vt102_off
{
	my $this = shift;
	delete $this->{vt};
}

sub turn_wait_for_chatter_on
{
	my $this    = shift;
	my $seconds = shift;
	if ($seconds)
	{
		$this->{wait_for_chatter} = $seconds;
	}
	else
	{
		$this->{wait_for_chatter} = 0.25;
	}
}

sub turn_wait_for_chatter_off
{
    my $this = shift;
    delete( $this->{wait_for_chatter} ) if ( defined $this->{wait_for_chatter} );
}

sub enable_send_chars_separately
{
	my $this = shift;
	$this->{send_chars_separately} = 1;
}

sub disable_send_chars_separately
{
	my $this = shift;
	delete( $this->{send_chars_separately} ) if ( defined $this->{send_chars_separately} );
}

sub set_more_prompt    
{
	my $this = shift;
	my ( $morePrompt, $action ) = @_;
	$this->{more_prompt} = { 'prompt' => $morePrompt, 'action' => $action, };
}

sub disable_more_prompt
{
	my $this = shift;
	delete $this->{more_prompt};
}

sub sim_handshake
{
	my $this      = shift;
	my $handshake = shift;

	if ($handshake)
	{
		$handshake->{content}  = undef;        # to play nice with the simulator
		$this->{sim_handshake} = $handshake;
	}
	return $this->{sim_handshake};
}

##########################################################################
#
#	INTERFACE METHODS
#
##########################################################################

sub connect
{

	# Send an error since this method should be abstract
	$LOGGER->fatal(
		"ERROR: ZipTie::CLIProtocol->connect() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement connect() if it is to be used!");
}

sub disconnect
{

	# Send an error since this method should be abstract
	$LOGGER->fatal(
		"ERROR: ZipTie::CLIProtocol->disconnect() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement disconnect() if it is to be used!");
}

sub send
{

	# Send an error since this method should be abstract
	$LOGGER->fatal("ERROR: ZipTie::CLIProtocol->send() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement send() if it is to be used!");
}

sub put
{

	# Send an error since this method should be abstract
	$LOGGER->fatal("ERROR: ZipTie::CLIProtocol->put() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement put() if it is to be used!");
}

sub send_as_bytes
{

	# Send an error since this method should be abstract
	$LOGGER->fatal(
"ERROR: ZipTie::CLIProtocol->send_as_bytes() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement send_as_bytes() if it is to be used!"
	);
}

sub wait_for
{

	# Send an error since this method should be abstract
	$LOGGER->fatal(
		"ERROR: ZipTie::CLIProtocol->wait_for() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement wait_for() if it is to be used!");
}

sub get_response
{

	# Send an error since this method should be abstract
	$LOGGER->fatal(
		"ERROR: ZipTie::CLIProtocol->get_lines() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement get_response() if it is to be used!");
}

sub output_record_separator
{
	# Send an error since this method should be abstract
	$LOGGER->fatal(
		"ERROR: ZipTie::CLIProtocol->get_lines() is an abstract method!\nA subclass of ZipTie::CLIProtocol must implement output_record_separator() if it is to be used!");
}

1;

__END__

=head1 NAME

ZipTie::CLIProtocol - Abstract base class / interface for CLI (command line interface) protocol agents/clients.

=head1 SYNOPSIS

	use ZipTie::CLIProtocol;
	use ZipTie::CLIProtocolFactory;

	my $telnet = ZipTie::CLIProtocolFactory->create("Telnet", "10.10.10.10", 23);
	$telnet->connect($telnet->get_ip_address(), $telnet->get_port());

	my $ssh = ZipTie::CLIProtocolFactory->create("SSH", "10.10.10.10", 22);
	$ssh->connect($ssh->get_ip_address(), $ssh->get_port(), "joebob", "thisismypassword");

=head1 DESCRIPTION

C<ZipTie::CLIProtocol> serves as an abstract base class / interface for CLI (command line interface) protocol
agents/clients.  It provides the template for defining what functionality should be implemented by any class
that is derived from this one.  This is important as a C<ZipTie::CLIProtocol> object should I<NEVER> be created
explicitly; only sub-classes/implementations of the C<ZipTie::CLIProtocol> interface should be created.

The functionality that should be supported by any derived CLI protocol agents/clients are defined within
the methods of this class.

=head1 IMPLEMENTED METHODS

=over 12

=item C<new()>

B<WARNING> - This should be I<ONLY> be called with in the constructor/new methods of classes that implement
the C<ZipTie::CLIProtocol> class!

Creates a new instance of the C<ZipTie::CLIProtocol> class.
This is simply a place to define the members of this base class/interface.

=item C<get_ip_address>

Retrieves the hostname/IP address of the server that this implementation of the C<ZipTie::CLIProtocol>
class is connected to.

=item C<_set_ip_address($ip_address)>

B<NOTE:> This should only be used by implementations of the C<ZipTie::CLIProtocol> class to store
this information.

Sets the hostname/IP address of the server that this implementation of the C<ZipTie::CLIProtocol>
class is connected to.

=item C<get_protocol_name()>

Retrieves the name of the CLI protocol that this implementation of the C<ZipTie::CLIProtocol>
class represents.  For example: "Telnet" or "SSH".

=item C<get_port()>

Retrieves the port value that this implementation of the C<ZipTie::CLIProtocol> class has connected to.

=item C<_set_port($port)>

B<NOTE:> This should only be used by implementations of the C<ZipTie::CLIProtocol> class to store
this information.

Sets the port value that this implementation of the C<ZipTie::CLIProtocol> class is connected to.

=item C<get_timeout()>

Retrieves the length (in seconds) of how long the C<wait_for()> method should wait on a response from a
device before timing out.  This time out value will only be used if the the C<wait_for()> method is used
with the matching regular expression as its only parameter.

=item C<set_timeout($timeout)>

Set the length (in seconds) for how long the C<wait_for()> method should wait on a response from a
device before timing out.  This time out value will only be used if the the C<wait_for()> method is used
with the matching regular expression as its only parameter.

=item C<send_and_wait_for($input, $regex, $timeout)>

A helper method that combines the functionality of the C<send($input)> and C<wait_for($regex, $timeout)>
methods.  It sends an input string to the device and waits for a match from the device that with match against
a specified regular expression.

$input -	An input or command to send to the device.

$regex -	A valid regular expression to match the response from the device.

$timeout -	Optional.  Specifies the amount of time (in seconds) to wait for a response from the device.
			If this parameter is specified, the timeout specified by a call to C<set_timeout()> will be ignored
			for this function call only.

=item C<send_as_bytes_and_wait($input, $regex, $timeout)>

A helper method that combines the functionality of the C<send_as_bytes($input)> and C<wait_for($regex, $timeout)>
methods.  It sends an input bytes to the device and waits for a match from the device that with match against
a specified regular expression.

$input -	An byte value to send to the device.

$regex -	A valid regular expression to match the response from the device.

$timeout -	Optional.  Specifies the amount of time (in seconds) to wait for a response from the device.
			If this parameter is specified, the timeout specified by a call to C<set_timeout()> will be ignored

=item C<wait_for_responses($responses, $timeout)>

Waits for the response from a device and checks to see if the response matches one of many possible regular
expressions/patterns from an array of C<ZipTie::Response> objects.

A C<ZipTie::Response> object stores a regular expression/pattern, a point to a sub routine to call if the match is successful
and an error message if the response that is match represents an error being encountered.

If a match is found, a reference to the matched Response object will be returned.  It is assumed that the
next interaction on the Response will be executed if an error did not occur.

It is also assumed that this function will be called directly after a call to send().

$responses -	A reference to an array of C<ZipTie::Response> objects to potentially match against.

$timeout -		Optional.  Specifies the amount of time (in seconds) to wait for a response from the device.
				If this parameter is specified, the timeout specified by a call to C<set_timeout()> will be
				ignored for this function call only.

=item C<last_match()>

Retrieves the last successful match that was found by the C<wait_for()> method.

=item C<last_input()>

Retrieves the last successful input that was sent by either the C<send($input)>, C<put($input)>, or C<send_as_bytes($input)>

=item C<get_prompt_by_name($prompt_name)>

Retrieves the regular expression prompt that was mapped to a certain name/key by a call to the
C<set_prompt_by_name()> method.  If there is no prompt/regular expression mapped to specified name/key,
then C<undef> is returned.

=item C<set_prompt_by_name($prompt_name, $prompt_regex)>

Maps a name/key to a regular expression that would match a particular prompt from a device.
The prompt regular expression can be retrieved by a call to the C<get_prompt_by_name()> method
with the name/key.

$prompt_name -	The name/key that will be mapped to the specified prompt.
$prompt_regex -	The prompt/regular expression to be stored.

=item C<turn_vt102_on($columns, $rows)>

Turns on VT102 mode processing for the responses.

$columns - the number of columns for the expected terminal output
$rows - the number of rows for the expected terminal output

example usage:
	$cli_protocol->turn_vt102_on(100, 24);

=item C<turn_vt102_off>

Turns off VT102 response processing

=item C<turn_wait_for_chatter_on($seconds)>

Allows every call to the C<wait_for($regex, $timeout)> method to also call the C<get_response($timeout)> method with a 0.25
second timeout window after a successful match has been found.  This allows a user to use the regular expression power provided
by the wait_for method, while at the same time ensuring that a regular expression has not matched something just because the
device didn't fully respond.

	$seconds - an optional argument.  If not set, the default chatter timeout of 0.25 seconds will be used.

=item C<turn_vt102_off>

Disables the functionality that is enabled by the C<turn_wait_for_chatter_on()> method.

=item C<enable_send_chars_separately()>

Some devices may require that commands sent to them be sent one character
at a time, rather than the entire command in a single packet.  When
this is the case, call this method in the adapter and all subsequent
commands will be split by into single characters to be sent one at a time.

=item C<disable_send_chars_separately()>

Disables sending chars separately. See C<enable_send_chars_separately()>.

=item C<sim_handshake($handshake)>

For connecting to a remote device simulator, this method allows you to get or set
the handshake value.  The handshake tells the client (this) to negotiate the connection
with the remote device, as it is assumed to be a simulator that is hosting more than
one recording.

$handshake - an optional argument, allows the caller to set the handshake

If no args are given, this method simply returns the current set handshake.

=item C<set_more_prompt($prompt, $action)>

Tells the CLI protocol to perform the action specified if it ever
matches the prompt.  This is to be used as an automatic pager
when a device doesn't let the user set the length of the terminal.

Inputs:
	$prompt - the more prompt regex
	$action - if the more prompt is matched, this action will be sent as bytes. 

=item C<disable_more_prompt($prompt, $action)>

Deletes the more prompt action.  See C<set_more_prompt> for
more details.

=item C<output_record_separator($charSequence)>

Set or get the output record separator.  The $charSequence argument is optional.  If no argument is given, this method
simply returns the current value of the output record separator, such as a CR or CRLF.

=back

=head1 INTERFACE METHODS

All of the following methods B<MUST> have their own implementations provided by any sub-class of the
C<ZipTie::CLIProtocol> class.  If not, the Perl process calling the method will die with an error message
saying that the method was not implemented.

=over 12

=item C<connect($ip_address, $port, $username, $password)>

Connects to a device at a specified IP address and port.  A username and password may also
be specified since some CLI protocols, particularly SSH implementations, may have a need for it
when connecting to a device.

$ip_address -	The administrative IP address of the device.

$port -			The port to connect to on the device.

$username -		The username credential to authenticate with the device.

$password -		The password credential to authenticate with the device.

=item C<disconnect()>

Disconnects from the device this C<ZipTie::CLIProtocol> object is already connected to.

=item C<send($input)>

Sends an input string to the device.  In order to retrieve the output, it is expected that the user
will call C<wait_for()> method with a valid regular expression after the call to C<send()>.

=item C<put($input)>

Like C<send> but doesn't append a newline to the output.

=item C<send_as_bytes($input)>

Converts an input string into a hexadecimal byte representation and sends it to the device.
Unlike C<send()>, C<send_as_bytes()> will not append any special CRLF character/bytes to the end of the input.
The input will simply be converted into hexadecimal and will be sent as is.  It is expected that the
command interpreter on the device should know how to handle the byte information coming in.

In order to retrieve the output, it is expected that the user will call C<wait_for()> with a valid regular 
expression after the call to C<send_as_bytes()>.

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
Date: May 3, 2007

=cut
