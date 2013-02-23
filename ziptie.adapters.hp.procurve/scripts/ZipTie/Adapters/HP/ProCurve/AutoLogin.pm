package ZipTie::Adapters::HP::ProCurve::AutoLogin;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

###########################################
#
# PUBLIC METHODS
#
###########################################

# Connects to and authenticates with a ProCurve device that is being connected to by a specified CLIProtocol implementation.
# Attempt to handle all of the edge cases that are encountered and successfully put the ProCurve device into
# enable mode.  If all is successful, the device prompt is parsed out and is returned to be used as the primary
# regular expression to wait for when sending commands.
#
# Input:	$cli_protocol -	The CLIProtocol object that is being used to communicate with the device.
#			$connection_path -	Reference to a ZipTie::ConnectionPath object that contains the IP address
#								and any credentials that would need to be used for the current connection.
#
# Returns:	The regular expression that will match the device's enable mode prompt that was found.
sub execute
{
	my $cli_protocol    = shift;
	my $connection_path = shift;

	# Pull off the ZipTie::Credentials instance from the ZipTie::ConnectionPath object
	my $credentials = $connection_path->get_credentials();

	# Store all the information needed to connect to the device
	my $ip_address = $connection_path->get_ip_address();
	my $port       = $cli_protocol->get_port();
	my $username   = $credentials->{username};
	my $password   = $credentials->{password};
	

	my $protocol_name = $cli_protocol->get_protocol_name();
	$LOGGER->debug("Protocol in use: $protocol_name");
	my $cred_str = $credentials->to_string();
	$LOGGER->debug("Credentials in use: $cred_str");

	# Attempt to connect to the device
	$cli_protocol->connect( $ip_address, $port, $username, $password );
	$LOGGER->debug("Verifying the initial connection ...");

	# If all goes well during the login process, the last method to be called will be "_calculate_prompt_regex"
	# and its return value will be returned all the way to here
	
	my $enable_prompt_regex;
	
	#We have to make a distinction in the login process
	#depending on the protocol being used.  Using VT102 emulation
	#it's preferable to get responses via get_response, but
	#that's not working with SSH
	
	my $ssh_protocol = $connection_path->get_protocol_by_name("SSH") if ( defined($connection_path) );

	if ( defined($ssh_protocol) )
	{
		# change terminal type
		$cli_protocol->turn_vt102_on(80,250); # set terminal size
		$LOGGER->debug("Enabling vt102 emulation for SSH ...");
		$enable_prompt_regex = _initial_connection_ssh( $cli_protocol, $credentials );
	}
	# Otherwise, fall back to normal behavior
	else
	{
		# change terminal type
		$cli_protocol->turn_vt102_on(150,25); # set terminal size
		$LOGGER->debug("Enabling vt102 emulation for Telnet...");
		$enable_prompt_regex = _initial_connection( $cli_protocol, $credentials );
	}

	# Print that the login process has been completed
	$LOGGER->debug("Login has successfully completed!\n");

	# Return the prompt regular expression that was found
	return $enable_prompt_regex;
}

###########################################
#
# PRIVATE SUB-ROUTINE
#
###########################################

sub _initial_connection
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	my $response = trim( $cli_protocol->get_response(0.25) );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ( $response =~ /sername:/mi )
	{
		return _send_username($cli_protocol, $credentials);
	}
	elsif ( $response =~ /ogin as:/mi )
	{
		return _send_username($cli_protocol, $credentials);
	}
	elsif ( $response =~ /assword:/mi )
	{
		return _send_password($cli_protocol, $credentials);
	}
	elsif ( $response =~ /any key to continue/mi )
	{
		return _send_press_any_key($cli_protocol, $credentials);
	}
	else
	{
		$LOGGER->debug("Received: $response");
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_username
{
	my $cli_protocol = shift;
	my $credentials = shift;

	# Send username credential
	my $username = $credentials->{username};
	$LOGGER->debug("Sending username credential ...");
	$cli_protocol->send($username);
	my $response = trim ( $cli_protocol->get_response(0.25) );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ( $response =~ /assword:/mi )
	{
		return _send_password($cli_protocol, $credentials);
	}
	elsif ( $response =~ /any key to continue/mi )
	{
		return _send_press_any_key($cli_protocol, $credentials);
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_password
{
	my $cli_protocol = shift;
	my $credentials = shift;
	
	# Send username credential
	my $password = $credentials->{password};
	$LOGGER->debug("Sending password credential ...");
	$cli_protocol->send($password);
	my $response = trim ( $cli_protocol->get_response(0.25) );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ( $response =~ /[^\s>]+>\s*$/mi )
	{
		return _send_enable($cli_protocol, $credentials);
	}
	elsif ( $response =~ /any key to continue/mi )
	{
		return _send_press_any_key($cli_protocol, $credentials);
	}
	else
	{
		$LOGGER->fatal("Invalid response or credentials from device encountered!");
	}
}

sub _send_enable
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	if ( $credentials->{enablePassword} )
	{
		# Send enable credential
		$LOGGER->debug("Sending the 'enable' command");
		$cli_protocol->send("enable");
		my $response = trim ( $cli_protocol->get_response(0.25) );

		# Based on the response of the device, determine the next interaction that should be executed.
		if ( $response =~ /sername:/mi )
		{
			return _send_enable_username($cli_protocol,$credentials);
		}
		elsif ( $response =~ /assword:/mi )
		{
			return _send_enable_password($cli_protocol,$credentials);
		}
		else
		{
			$LOGGER->fatal("Invalid response or credentials from device encountered!");
		}
	}
	else
	{
		return _calculate_prompt_regex($cli_protocol);
	}    
}

sub _send_enable_username
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Send enable username credential
	my $enableUsername = $credentials->{enableUsername};

	if ( $enableUsername eq "" )
	{
		$LOGGER->fatal("[$INVALID_CREDENTIALS]\nAuthentication refused with an empty enable username credential.");
	}

	$LOGGER->debug("Entering the enable username credential for enable mode authentication ....");
	$cli_protocol->send($enableUsername);
	my $response = trim ( $cli_protocol->get_response(0.25) );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ( $response =~ /assword:/mi )
	{
		return _send_enable_password($cli_protocol, $credentials);
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_enable_password
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Send username credential
	my $enable_password = $credentials->{enablePassword};
	$LOGGER->debug("Sending the enable password credential '$enable_password'\n");
	$cli_protocol->send($enable_password);
	my $response = trim ( $cli_protocol->get_response(0.25) );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ( $response =~ /[^\s#]+#\s*$/mi )
	{
		return _calculate_prompt_regex($cli_protocol,$credentials);
	}
	else
	{
		$LOGGER->fatal("Invalid response or credentials from device encountered!");
	}
}

sub _initial_connection_ssh
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'any key to continue',  \&_send_press_any_key_ssh ) );
	push( @responses, ZipTie::Response->new( '\S+>',  		\&_send_enable_ssh ) );
	
	
	# Since we just want to see what the initial prompt of the device is, there is no reason
	# to send anything, so let's just wait for a match
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		my $regex = $response->get_regex();
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}



sub _send_enable_ssh
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	if ( $credentials->{enablePassword} )
	{
		my @responses = ();
		push( @responses, ZipTie::Response->new( 'sername:',  	\&_send_enable_username_ssh ) );
		push( @responses, ZipTie::Response->new( 'assword:',  	\&_send_enable_password_ssh ) );
		push( @responses, ZipTie::Response->new( '\S+#', 	\&_calculate_prompt_regex_ssh ) );
		push( @responses, ZipTie::Response->new( 'any key to continue',  \&_send_press_any_key_ssh ) );

		# Send enable command
		$LOGGER->debug("Sending the 'enable' command");
		$cli_protocol->send("enable");
		my $response = $cli_protocol->wait_for_responses( \@responses );

		# Based on the response of the device, determine the next interaction that should be executed.
		my $next_interaction = undef;
		if ($response)
		{
			my $regex = $response->get_regex();
			$next_interaction = $response->get_next_interaction();
		}
		else
		{
			$LOGGER->fatal("Invalid response from device encountered!");
		}

		# Call the next interaction if there is one to call
		if ($next_interaction)
		{

			# Return the enable mode prompt found
			return &$next_interaction( $cli_protocol, $credentials );
		}
	}
	else
	{
		return _calculate_prompt_regex($cli_protocol);
	}    
}

sub _send_enable_username_ssh
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'assword:',  \&_send_enable_password_ssh ) );
	push( @responses, ZipTie::Response->new( 'any key to continue',  \&_send_press_any_key_ssh ) );

	# Send username
	my $username = $credentials->{enableUsername};
	
	if ( $username eq "" )
	{
		$LOGGER->fatal("[$INVALID_CREDENTIALS]\nAuthentication refused with an empty username");
	}
	
	$LOGGER->debug("Entering the enable username credential for enable mode authentication ....");
	$cli_protocol->send($username);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		my $regex = $response->get_regex();
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _send_enable_password_ssh
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Access denied',		undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'nvalid password',                    	undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Authentication failed',      	undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( '\S+#\s*', 			\&_calculate_prompt_regex_ssh ) );

	# Send the enablePassword
	my $enable_password = $credentials->{enablePassword};
	$LOGGER->debug("Sending the enable password credential '$enable_password'\n");
	$cli_protocol->send($enable_password);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		my $regex = $response->get_regex();
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _calculate_prompt_regex
{
	my $cli_protocol = shift;

	# Grab the last match that the CLIProtocol implementation captured
	my $last_match = trim ( $cli_protocol->get_response(0.25) );#$cli_protocol->last_match();
	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[LAST MATCH CAPTURED]");
	$LOGGER->debug($last_match);

	# Use a regular expression to strip the prompt from the match
	$last_match =~ /^([^#]+#)\s*$/mi;

	# Grab the extracted device prompt
    my $device_prompt = $1;

    # Register the device prompt with the ZipTie::Recording singleton instance module
    use ZipTie::Recording;
    my $recording = ZipTie::Recording::get_recording();
    $recording->set_device_prompt($device_prompt);
    
    # Clean up the device prompt for regular expression use
    $device_prompt = quotemeta($device_prompt);

	# Construct the regular expression for the prompt so that it will only match the prompt that is displayed
	# as the very last thing.  This will get around the issue of a device possibly echoing back it's prompt when
	# a command is sent.
	my $device_prompt_regex = $device_prompt;

	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[REGULAR EXPRESSION TO MATCH DEVICE PROMPT]");
	$LOGGER->debug($device_prompt_regex);
	$LOGGER->debug("---------------------------------------------------------");

	return $device_prompt_regex;
}


sub _calculate_prompt_regex_ssh
{
	my $cli_protocol = shift;

	# Grab the last match that the CLIProtocol implementation captured
	my $last_match = $cli_protocol->last_match();
	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[LAST MATCH CAPTURED]");
	$LOGGER->debug($last_match);

	# Use a regular expression to strip the prompt from the match
	$last_match =~ /(\S+#)\s*$/;

	# Grab the extracted device prompt
    my $device_prompt = $1;
    
    # Register the device prompt with the ZipTie::Recording singleton instance module
    use ZipTie::Recording;
    my $recording = ZipTie::Recording::get_recording();
    $recording->set_device_prompt($device_prompt);
    
    # Clean up the device prompt for regular expression use
    $device_prompt = quotemeta($device_prompt);

	# Construct the regular expression for the prompt so that it will only match the prompt that is displayed
	# as the very last thing.  This will get around the issue of a device possibly echoing back it's prompt when
	# a command is sent.
	my $device_prompt_regex = $device_prompt;

	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[REGULAR EXPRESSION TO MATCH DEVICE PROMPT]");
	$LOGGER->debug($device_prompt_regex);
	$LOGGER->debug("---------------------------------------------------------");

	return $device_prompt_regex;
}

sub _send_press_any_key
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Send a CRLF to the device
	$LOGGER->debug("Sending a newline to respond to Any Key ...");
	$cli_protocol->send("");

	my $response = trim ( $cli_protocol->get_response(0.25) );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ( $response =~ /sername:|ogin as:/mi )
	{
		return _send_username($cli_protocol,$credentials);
	}
	elsif ( $response =~ /assword:/mi )
	{
		return _send_password($cli_protocol,$credentials);
	}
	elsif ( $response =~ /[^\s>]+>\s*$/mi )
	{
		return _send_enable($cli_protocol,$credentials);
	}
	elsif ( $response =~ /[^\s#]+#\s*$/mi )
	{
		return _calculate_prompt_regex($cli_protocol,$credentials);
	}	
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_press_any_key_ssh
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	
	# Send a CRLF to the device
	$LOGGER->debug("Sending a newline to respond to Any Key ...");
	$cli_protocol->send("");

	push( @responses, ZipTie::Response->new( 'sername:',	\&_send_username_ssh ) );
	push( @responses, ZipTie::Response->new( 'ogin as:',	\&_send_username_ssh ) );
	push( @responses, ZipTie::Response->new( 'assword:',  	\&_send_password_ssh ) );
	push( @responses, ZipTie::Response->new( '\S+>',  		\&_send_enable_ssh ) );
	push( @responses, ZipTie::Response->new( '\S+#',  		\&_send_enable_ssh ) );

	# Since we just want to see what the initial prompt of the device is, there is no reason
	# to send anything, so let's just wait for a match
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		my $regex = $response->get_regex();
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub trim
{
	$_[0] =~ s/^\s+//;
	$_[0] =~ s/\s+$//;

	$_[0];
}



1;

__END__

=head1 NAME

ZipTie::Adapters::HP::ProCurve::AutoLogin - Automates the connection and authentication with an HP ProCurve device.

=head1 SYNOPSIS

    use ZipTie::Adapters::HP::ProCurve::AutoLogin;
	my $cli_protocol = ZipTie::CLIProtocolFactory::create( $connection_path );
	my $prompt_regex = ZipTie::Adapters::HP::ProCurve::AutoLogin::execute( $cli_protocol, $connection_path );

=head1 DESCRIPTION

The autologin module for an adapter provides an abstract sequence of commands and responses
that allow the user to login to the device.  Usually this is via a CLI protocol such as Telnet
or SSH.  Once fully connected and authenticated with the device, the autologin module must be able
to calculate and return the a regular expression that will be leveraged by users of the module
to match the primary prompt for the device.  This is crucial in being able to send commands and wait
for their responses where leveraging the command line interface (CLI) clients provided by the ZipTie
Perl framework, such as C<ZipTie::Telnet> and C<ZipTie::SSH>.

This module should be able to handle all the possible scenarios that might be encountered when
connecting to and authenticating with a device.

The autologin module should be abstract enough that scripts outside of the adapters can use it
as well.  For example, a script to make mass changes to a device should be able to leverage
the autologin sequence just like an adapter does during backup.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<execute($cli_protocol, $connection_path)>

The main entry point for connecting to and authenticating with a network device.  This sub-routine
will connect to the device using the specified C<ZipTie::CLIProtocol> object as the command line interface (CLI)
client and using the hostname or IP address specified within the C<ZipTie::ConnectionPath> object.

This method must return a regular expression that can be used to match the primary prompt of the device that
has been connected to.  This is required so that users of the autologin module can have a way to match the
prompt after sending a command to a device and waiting for the response.

=back

=head1 PRIVATE SUB-ROUTINES

=over 12

=item C<_inital_connection($cli_protocol, $connection_path)>

Once an inital connection has been established with the network device, the first text response over the CLI is
examined.  Depending on the response, various sub-routines may be called.

=item C<_send_press_any_key($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that any input should be sent to the
device.  This will cause newline to be sent to the device.

=item C<_send_username($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "username" credential should be sent to the
device.

=item C<_send_username_again($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "username" credential should be sent again to the
device.

=item C<_send_enable_username($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "username" credential after the "enable" command
has been sent to the device.

=item C<_send_password($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "password" credential should be sent to the
device.

=item C<_send_enable($cli_protocol, $connection_path)>

This sub-routine is called if we have reached the normal device prompt.  Since the ProCurve adapter relies on commands to be
called that can only be called from enabled mode, the "enable" command will be sent to the device so that we may attempt to
enter the enabled mode.

=item C<_send_enable_password($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "enablePassword" credential should be sent to the
device so that we may attempt to enter the enabled mode.  This most likely to happen after the "enable" command has been
sent to the device.

=item C<_calculate_prompt_regex($cli_protocol, $connection_path)>

This sub-routine is called once the device has been connected to and authentication has completed successfully.  The
last match from the device will be examined the primary prompt will be parsed from it and converted into a regular
expression that can be used to match the prompt of the device.  This regular expression will be returned so that it can
be used by it's caller.

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

Contributor(s): rkruse, Dylan White (dylamite@ziptie.org), Brent Gerig (brgerig@taylor.edu), Daniel Badilla (dbadilla@isthmusit.com)
Date: December 10, 2007

=cut
