package ZipTie::Adapters::Nortel::BayStack::AutoLogin;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();
my $PROMPT = '\w[^\n\r]+?#\s*$';

sub execute
{
	my $cli_protocol    = shift;
	my $connection_path = shift;

	$LOGGER->debug("About to execute autologin");

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

	# If all goes well during the login process, the last method to be called will be "_finish"
	# and its return value will be returned all the way to here
	my $prompt_regex = _initial_connection( $cli_protocol, $credentials );

	# Print that the login process has been completed
	$LOGGER->debug("Login has successfully completed!\n");

	return $prompt_regex;
}

sub _initial_connection
{
    my $cli_protocol = shift;
    my $credentials  = shift;

    # Specify the responses to check for
    my @responses = ();
    push( @responses, ZipTie::Response->new( 'Ctrl-Y',                \&_send_ctrl_y ) );
    push( @responses, ZipTie::Response->new( 'ommand Line Interface', \&_enter_cli ) );
    push( @responses, ZipTie::Response->new( 'ogout',                 \&_finish ) );
    push( @responses, ZipTie::Response->new( 'ogin|sername',          \&_enter_user ) );
    push( @responses, ZipTie::Response->new( 'assword',               \&_enter_pass ) );
    
    # Allow all wait_for operations to wait for device chatter to stop before returning
    $cli_protocol->turn_wait_for_chatter_on();
    
    my $response = $cli_protocol->wait_for_responses( \@responses );
    
    # Disable all wait_for operations to wait for device chatter to stop before returning
    $cli_protocol->turn_wait_for_chatter_off();

    # Based on the response of the device, determine the next interaction that should be executed.
    my $next_interaction = undef;
    if ($response)
    {
        $next_interaction = $response->get_next_interaction();
    }
    else
    {
        $LOGGER->fatal($UNEXPECTED_RESPONSE);
    }

    # Call the next interaction if there is one to call
    if ($next_interaction)
    {

        # Return the enable mode prompt found
        return &$next_interaction( $cli_protocol, $credentials );
    }
}

sub _send_ctrl_y
{
	my $cli_protocol = shift;
	my $credentials  = shift;
	my $hitDownArrow = 0;

	$LOGGER->debug("Sending ctrl+y");
	$cli_protocol->send_as_bytes("19");

	my $response = $cli_protocol->get_response(1);

	if ($response =~ /(?:Ethernet(?:\sRouting)?\sSwitch|BayStack)\s+(\d+)/msi)
	{
		if ($1=~ /350|450|470/) # This will exclude the 5500 series BayStacks from hitting the _down_arrow sub, which spins them into oblivion during login. -Z
		{
			$hitDownArrow = 1;
		}
	}
	
	if ($response =~ /ogin|sername/)
	{
		return &_enter_user($cli_protocol, $credentials, $hitDownArrow);
	}
	
	elsif ($response =~ /assword/)
	{
		return &_enter_pass($cli_protocol, $credentials);
	}	
	
	elsif ($response =~ /ommand Line Interface/)
	{
		return &_enter_cli($cli_protocol, $credentials);
	}	
	
	elsif ($response =~ /ogout/)
	{
		return &_finish($cli_protocol, $credentials);
	}	
	
	elsif ($response =~ /$PROMPT/)
	{
		return &_capture_prompt($cli_protocol, $credentials, $response);
	}	

	else
	{
		$LOGGER->fatal("[$UNEXPECTED_RESPONSE] No regular expression matched the device response after sending Ctrl-Y!\nResponse captured: $response");
	}
}

sub _enter_user
{
	my $cli_protocol 	= shift;
	my $credentials 	= shift;
	my $hitDownArrow	= shift;

	# Specify the responses to check for
	my @responses = ();
	
	if ($hitDownArrow == 1)
	{
		push( @responses, ZipTie::Response->new( 'sername', \&_down_arrow ) );
	}
	elsif ($hitDownArrow == 0)
	{
		push( @responses, ZipTie::Response->new( 'sername', \&_enter_pass ) );
	}
	push( @responses, ZipTie::Response->new( 'assword', \&_enter_pass ) );

	# Send username credential
	my $username = $credentials->{username};
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
		$LOGGER->fatal($UNEXPECTED_RESPONSE);
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _down_arrow
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Enter', \&_enter_pass ) );

	$LOGGER->debug("Sending down arrow");
	$cli_protocol->send_as_bytes('1b5b42');
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal($UNEXPECTED_RESPONSE);
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _enter_pass
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Access Denied from RADIUS|Incorrect', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'ommand Line Interface', \&_enter_cli ) );
	push( @responses, ZipTie::Response->new( $PROMPT,              \&_capture_prompt ) );
	push( @responses, ZipTie::Response->new( 'ogout',                 \&_finish ) );

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
		$LOGGER->fatal($UNEXPECTED_RESPONSE);
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _enter_cli
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( $PROMPT, \&_capture_prompt ) );
	push( @responses, ZipTie::Response->new( '(?m)^\w.+?>\s*$', \&_enable ) );

	# Send password credential
	$cli_protocol->send_as_bytes('63');
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal($UNEXPECTED_RESPONSE);
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _enable
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( $PROMPT, \&_capture_prompt ) );

	# Send password credential
	$cli_protocol->send('enable');    
	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	my $next_interaction = undef;
	if ($response)
	{
		$next_interaction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal($UNEXPECTED_RESPONSE);
	}

	# Call the next interaction if there is one to call
	if ($next_interaction)
	{

		# Return the enable mode prompt found
		return &$next_interaction( $cli_protocol, $credentials );
	}
}

sub _capture_prompt
{
	my $cli_protocol = shift;
	my $credentials = shift;
	my $last_match  = shift;

	# Grab the last match that the CLIProtocol implementation captured unless it was provided explicitly
	$last_match = $cli_protocol->last_match() if (!$last_match);
	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[LAST MATCH CAPTURED]");
	$LOGGER->debug($last_match);

	# Use a regular expression to strip the prompt from the match
	$last_match =~ /([^\s][^\r\n]*)$/;

	# Grab the extracted device prompt and clean it up for regular expression use
	my $device_prompt = $1;
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
	
	$cli_protocol->set_prompt_by_name( "prompt", $device_prompt_regex );

	return $device_prompt_regex;
}

sub _finish
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# there is no prompt on the menu system
	return 0;
}

1;
