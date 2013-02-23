# ZipTie::IOS::AutoLogin helps automate the login process for IOS-based devices.
# This includes IOS, CatIOS, and MSFC.
#
# Author:	Dylan White (dylamite@ziptie.org)
package ZipTie::Adapters::Cisco::IOS::AutoLogin;

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

# Connects to and authenticates with an IOS-based device that is being connected to by a specified CLIProtocol implementation.
# Attempt to handle all of the edge cases that are encountered and successfully put the IOS-based device into
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
	my $enable_prompt_regex = _initial_connection( $cli_protocol, $credentials );

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

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'maximum number of telnet',      undef, $TOO_MANY_USERS ) );
	push( @responses, ZipTie::Response->new( 'assword required, but none se', undef, $PASSWORD_REQUIRED_BUT_NOT_SET ) );
	push( @responses, ZipTie::Response->new( 'sername:',            \&_send_username ) );
	push( @responses, ZipTie::Response->new( 'assword:',            \&_send_password ) );
	push( @responses, ZipTie::Response->new( 'PASSCODE:',           \&_send_password ) );
	push( @responses, ZipTie::Response->new( '(?m)^\w\S*>\s*(?![\n\r])$',       \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(?m)^\w\S*#\s*(?![\n\r])$',       \&_send_enable ) );
	push( @responses, ZipTie::Response->new( 'any key',             \&_send_press_any_key ) );       
	push( @responses, ZipTie::Response->new( 'User Interface Menu', \&_select_command_line ) );

	# Since we just want to see what the initial prompt of the device is, there is no reason
	# to send anything, so let's just wait for a match
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _send_username
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'invalid', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'assword:|PASSCODE:', \&_send_password ) );

	# Send username credential
	my $username = $credentials->{username};
	if ( !$username )
	{
		$LOGGER->fatal_error_code( $INVALID_CREDENTIALS, $cli_protocol->get_ip_address(), "This device requires a username." );
	}

	$LOGGER->debug("Sending username credential ...");
	$cli_protocol->send($username);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _send_password
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'sername:',              undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'assword:',              undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'PASSCODE:',             undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'invalid',               undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Bad passwords',         undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Authentication failed', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( '(\d+)\s+[Ee][Xx][Ii][Tt]\s+.*[Mm][Ee][Nn][Uu]',     \&_handle_term_svr_menu ) );
	push( @responses, ZipTie::Response->new( '>\s*$',                                             \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '.*#.*#',                                            \&_send_enable ) );

	# Send password credential
	my $password = $credentials->{password};
	$LOGGER->debug("Sending password credential ...");
	$cli_protocol->send($password);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _handle_term_svr_menu
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Special case: Pass in the menu selection to handle
	my $menuSelection = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( '>\s*$',                                             \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '.*#.*#',                                            \&_send_enable ) );

	# Send menu selection
	$LOGGER->debug("Sending the menu selection '$menuSelection'");
	$cli_protocol->send($menuSelection);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _send_enable
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	if ( $credentials->{enablePassword} )
	{
		my @responses = ();
		push( @responses, ZipTie::Response->new( 'sername:',                                          \&_re_enter_username_during_enable ) );
		push( @responses, ZipTie::Response->new( 'assword:',                                          \&_send_enable_password ) );
		push( @responses, ZipTie::Response->new( 'PASSCODE:',                                         \&_send_enable_password ) );
		push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_calculate_prompt_regex ) );

		# Send enable command
		$LOGGER->debug("Sending the 'enable' command");
		$cli_protocol->send("enable");
		my $response = $cli_protocol->wait_for_responses( \@responses );

		# Based on the response of the device, determine the next interaction that should be executed.
		my $next_interaction = undef;
		if ($response)
		{
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

sub _re_enter_username_during_enable
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'sername:',              undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'invalid',               undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Bad passwords',         undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Authentication failed', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'assword:',                                          \&_send_enable_password ) );
	push( @responses, ZipTie::Response->new( 'PASSCODE:',                                         \&_send_enable_password ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_calculate_prompt_regex ) );

	# Send username
	my $username = $credentials->{username};
	$LOGGER->debug("Re-entering the username credential for enable mode authentication ....");
	$cli_protocol->send($username);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _send_enable_password
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Access denied',                  undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'assword:',                       undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'PASSCODE:',                      undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'invalid',                        undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Bad passwords',                  undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'Authentication failed',          undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( '%\s+[Ee]rror in authentication', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_calculate_prompt_regex ) );

	# Send the enablePassword
	my $enable_password = $credentials->{enablePassword};
	$LOGGER->debug("Sending the enable password credential '$enable_password'\n");
	$cli_protocol->send($enable_password);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _send_press_any_key
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'User Interface Menu', \&_select_command_line ) );

	# Send a CRLF to the device
	$LOGGER->debug("Sending a newline since to handle the User Interface Menu ...");
	$cli_protocol->send("");
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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

sub _select_command_line
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'sername',                                           \&_send_username ) );
	push( @responses, ZipTie::Response->new( 'CLI session',                                       \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^>^(\n|\r)]+>\s*$',                       \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_send_enable ) );
	push( @responses, ZipTie::Response->new( 'assword',                                           \&_send_enable_password ) );

	# Send a CRLF to the device
	$LOGGER->debug("Sending 'K' to select command-line mode\n");
	$cli_protocol->send("K");
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
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
	my $last_match = $cli_protocol->last_match();
	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[LAST MATCH CAPTURED]");
	$LOGGER->debug($last_match);

	# Use a regular expression to strip the prompt from the match
	$last_match =~ /([^\s][^\r\n]*)$/;

	# Grab the extracted device prompt
	my $device_prompt = $1;

	# Register the device prompt with the ZipTie::Recording singleton instance module
	use ZipTie::Recording;
	my $recording = ZipTie::Recording::get_recording();
	$recording->set_device_prompt($device_prompt);

	# Clean up the device prompt for regular expression use
	$device_prompt =~ s/^\s+//;
	$device_prompt =~ s/\s+$//;
	$device_prompt = quotemeta($device_prompt);

	# Construct the regular expression for the prompt so that it will only match the prompt that is displayed
	# as the very last thing.  This will get around the issue of a device possibly echoing back it's prompt when
	# a command is sent.
	my $device_prompt_regex = $device_prompt . "\\s*\$";

	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[REGULAR EXPRESSION TO MATCH DEVICE PROMPT]");
	$LOGGER->debug($device_prompt_regex);
	$LOGGER->debug("---------------------------------------------------------");
	
	
	# Store the found prompt as "enablePrompt" on the specified CLI protocol.
	$cli_protocol->set_prompt_by_name( "enablePrompt", $device_prompt_regex );
	
	# more prompt
	$cli_protocol->set_more_prompt( '--More--\s*$', '20' );

	return $device_prompt_regex;
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Cisco::IOS::AutoLogin - Automates the connection and authentication with a Cisco IOS device.

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::IOS::AutoLogin;
	my $cli_protocol = ZipTie::CLIProtocolFactory::create( $connection_path );
	my $prompt_regex = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cli_protocol, $connection_path );

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

=item C<_select_command_line($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that "K" be pressed to enter command-line mode.  This
will send "K" to the device and put the device into command-line mode.

=item C<_handle_term_svr_menu($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that a terminal server menu has been encountered.
The proper selection will be made to continue on with authenticating the device.

=item C<_send_username($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "username" credential should be sent to the
device.

=item C<_re_enter_username_during_enable($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "username" credential after the "enable" command
has been sent to the device.

=item C<_send_password($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "password" credential should be sent to the
device.

=item C<_send_enable($cli_protocol, $connection_path)>

This sub-routine is called if we have reached the normal device prompt.  Since the IOS adapter relies on commands to be
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

Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut
