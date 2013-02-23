package ZipTie::Adapters::Cisco::WAAS::AutoLogin;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();


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


sub _initial_connection
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'maximum number of telnet',      undef, $TOO_MANY_USERS ) );
	push( @responses, ZipTie::Response->new( 'assword required, but none se', undef, $PASSWORD_REQUIRED_BUT_NOT_SET ) );
	push( @responses, ZipTie::Response->new( 'sername:',  \&_send_username ) );
	push( @responses, ZipTie::Response->new( 'ogin:',  \&_send_username ) );
	push( @responses, ZipTie::Response->new( 'assword:',  \&_send_password ) );
	push( @responses, ZipTie::Response->new( 'PASSCODE:', \&_send_password ) );
	push( @responses, ZipTie::Response->new( '>\s*$',                                             \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^>^(\n|\r)]+>\s*$',                       \&_send_enable ) );
	push( @responses, ZipTie::Response->new( '(^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$', \&_send_enable ) );
	push( @responses, ZipTie::Response->new( 'any key',                                           \&_send_press_any_key ) );
	push( @responses, ZipTie::Response->new( 'User Interface Menu',                               \&_select_command_line ) );


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
	push( @responses, ZipTie::Response->new( 'invalid',               undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'assword:|PASSCODE:',     \&_send_password ) );

	# Send username credential
	my $username = $credentials->{username};
	if (!$username)
	{
		$LOGGER->fatal_error_code($INVALID_CREDENTIALS, $cli_protocol->get_ip_address(), "This device requires a username.");
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

	return $device_prompt_regex;
}

1;

__END__
