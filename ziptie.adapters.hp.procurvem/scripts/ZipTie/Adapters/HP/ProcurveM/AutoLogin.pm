package ZipTie::Adapters::HP::ProcurveM::AutoLogin;

use strict;
use ZipTie::CLIProtocol;
use ZipTie::Response;

use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub execute
{
	# login to a device via the CLI (SSH or Telnet)
	my $cli_protocol    = shift;
	my $connection_path = shift;

	# Pull off the ZipTie::Credentials instance from the ZipTie::ConnectionPath object
	my $credentials = $connection_path->get_credentials();

	# Store all the information needed to connect to the device
	my $ip_address = $connection_path->get_ip_address();
	my $port       = $cli_protocol->get_port();
	my $username   = $credentials->{username};
	my $password   = $credentials->{password};

	my $protocolName = $cli_protocol->get_protocol_name();
	$LOGGER->debug("Protocol in use: $protocolName");

	# Attempt to connect to the device
	$cli_protocol->connect( $ip_address, $port, $username, $password );
	$LOGGER->debug("Verifying the initial connection ...");

         $cli_protocol->turn_vt102_on(80,250);
         $LOGGER->debug("Enabling vt102 emulation ...");

	# If all goes well during the login process, the last method to be called will be "get_prompt"
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
	push( @responses, ZipTie::Response->new( 'sername:|ogin:',         \&_send_username ) );
	push( @responses, ZipTie::Response->new( '[Pp]assword:',           \&_send_password ) );
	push( @responses, ZipTie::Response->new( 'TELNET - OPERATOR MODE', \&_go_enable ) );
	push( @responses, ZipTie::Response->new( 'TELNET - MANAGER MODE', \&_go_cli_mode ) );

	#push(@responses, ZipTie::Response->new( 'TELNET - OPERATOR MODE', \&_send_enable ) );
	#push(@responses, ZipTie::Response->new('item and press <Enter>\.\s*$', \&_get_prompt));

	my $response = $cli_protocol->wait_for_responses( \@responses );

	# Based on the response of the device, determine the next interaction that should be executed.
	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		return &$next_interaction( $cli_protocol, $credentials );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_username
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Pp]assword:',      \&_send_password ) );
	push( @responses, ZipTie::Response->new( 'incorrect|invalid', undef, $INVALID_CREDENTIALS ) );

	# Send username credential
	my $username = $credentials->{username};
	
	if ( $username eq "" )
	{
		$LOGGER->fatal("[$INVALID_CREDENTIALS]\nAuthentication refused with an empty username");
	}
	
	$LOGGER->debug("Sending username credential ...");
	$cli_protocol->send($username);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		return &$next_interaction( $cli_protocol, $credentials );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_password
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Ii]ncorrect|[Ii]nvalid', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'TELNET - OPERATOR MODE', \&_go_enable ) );
	push( @responses, ZipTie::Response->new( 'TELNET - MANAGER MODE', \&_go_cli_mode) );

	#push(@responses, ZipTie::Response->new('item and press <Enter>\.\s*$', \&_get_prompt));

	# Send username credential
	my $password = $credentials->{password};
	$LOGGER->debug("Sending password credential ...");
	$cli_protocol->send($password);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		return &$next_interaction( $cli_protocol, $credentials );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _go_cli_mode 
{

	my $cli_protocol = shift;
	my $credentials  = shift;
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Select VLAN',        	       \&_send_enter) );
	push( @responses, ZipTie::Response->new( 'Diagnostics Menu',         	\&_send_4) );
	push( @responses, ZipTie::Response->new( 'Main Menu',         		\&_send_5) );
	push( @responses, ZipTie::Response->new( '\S*:',         		\&_calculate_prompt_regex) );
	my $response = $cli_protocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		return &$next_interaction( $cli_protocol, $credentials );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}

}

sub _send_5
{
	my $cli_protocol = shift;
	my $credentials  = shift;
	$cli_protocol->send_as_bytes( '35' );

	return _go_cli_mode( $cli_protocol, $credentials );
}

sub _send_4
{
	my $cli_protocol = shift;
	my $credentials  = shift;
	$cli_protocol->send_as_bytes( '34' );

	return _go_cli_mode( $cli_protocol, $credentials );
}

sub _send_enter
{
	my $cli_protocol = shift;
	my $credentials  = shift;
	$cli_protocol->send_as_bytes( '0D' );

	return _go_cli_mode( $cli_protocol, $credentials );
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
	$last_match =~ /\s*(\S+[#>:])\s*$/;

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

	$cli_protocol->set_prompt_by_name( "enablePrompt", $device_prompt_regex);
	return $device_prompt_regex;
}

sub _get_prompt
{
	my $cli_protocol = shift;

	# Grab the last match that the CLIProtocol implementation captured
	my $last_match = $cli_protocol->last_match();
	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[LAST MATCH CAPTURED]");
	$LOGGER->debug($last_match);

	# Use a regular expression to strip the prompt from the match
	$last_match =~ /([^\s][^\r\n]*)$/;

	# Grab the extracted device prompt and clean it up for regular expression use
	#my $device_prompt	= $1;
	# Use static predefined prompt regex
	my $device_prompt = '(item and press <Enter>\.)';
    
    # Register the device prompt with the ZipTie::Recording singleton instance module
    use ZipTie::Recording;
    my $recording = ZipTie::Recording::get_recording();
    $recording->set_device_prompt($device_prompt);

	#$device_prompt		=~ s/^\s+//;
	#$device_prompt		=~ s/\s+$//;
	#$device_prompt		= quotemeta($device_prompt);

	# Construct the regular expression for the prompt so that it will only match the prompt that is displayed
	# as the very last thing.  This will get around the issue of a device possibly echoing back it's prompt when
	# a command is sent.
	#my $device_prompt_regex = $device_prompt . "\\s*\$";
	my $device_prompt_regex = $device_prompt;

	$LOGGER->debug("---------------------------------------------------------");
	$LOGGER->debug("[REGULAR EXPRESSION TO MATCH DEVICE PROMPT]");
	$LOGGER->debug($device_prompt_regex);
	$LOGGER->debug("---------------------------------------------------------");

	return $device_prompt_regex;
}

sub _go_enable
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	if ( $credentials->{enablePassword} )
	{
		# Specify the responses to check for
		my @responses = ();
		push( @responses, ZipTie::Response->new( 'sername:|ogin:', \&_send_enable ) );
		push( @responses, ZipTie::Response->new( '[Pp]assword:',   \&_send_enable_password ) );

		# Send menu number to start enable mode
		$cli_protocol->send_as_bytes_and_wait( '34', '.*' );
		my $response = $cli_protocol->wait_for_responses( \@responses );

		if ($response)
		{
			my $next_interaction = $response->get_next_interaction();
			return &$next_interaction( $cli_protocol, $credentials );
		}
		else
		{
			$LOGGER->fatal("Invalid response from device encountered!");
		}
	}
	else
	{
		return _get_prompt($cli_protocol);
	}
}

sub _send_enable
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	if ( $credentials->{enablePassword} )
	{

		# Specify the responses to check for
		my @responses = ();
		push( @responses, ZipTie::Response->new( 'incorrect|invalid', undef, $INVALID_CREDENTIALS ) );
		push( @responses, ZipTie::Response->new( '[Pp]assword:', \&_send_enable_password ) );

		#push( @responses, ZipTie::Response->new( 'item and press <Enter>\.\s*$', \&_get_prompt ) );

		# Send enable
		my $username = $credentials->{enableUsername};
		
		if ( $username eq "" )
		{
			$LOGGER->fatal("[$INVALID_CREDENTIALS]\nAuthentication refused with an empty username");
		}
		
		$cli_protocol->send($username);
		my $response = $cli_protocol->wait_for_responses( \@responses );

		if ($response)
		{
			my $next_interaction = $response->get_next_interaction();
			return &$next_interaction( $cli_protocol, $credentials );
		}
		else
		{
			$LOGGER->fatal("Invalid response from device encountered!");
		}
	}
	else
	{
		return _get_prompt($cli_protocol);
	}
}

sub _send_enable_password
{
	my $cli_protocol = shift;
	my $credentials  = shift;

	# Specify the responses to check for
	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Ii]ncorrect|[Ii]nvalid', undef, $INVALID_CREDENTIALS ) );
	push( @responses, ZipTie::Response->new( 'TELNET - MANAGER MODE', \&_get_prompt ) );
	

	# Send password credential
	my $password = $credentials->{enablePassword};
	$LOGGER->debug("Sending enable password credential ...");
	$cli_protocol->send($password);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		return &$next_interaction( $cli_protocol, $credentials );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

1;

__END__

=head1 NAME

ZipTie::Adapters::HP::ProcurveM::AutoLogin - An example autologin module

=head1 SYNOPSIS

    use ZipTie::Adapters::HP::ProcurveM;
	my $cli_protocol = ZipTie::CLIProtocolFactory::create( $connection_path );
	my $prompt_regex = ZipTie::Adapters::HP::ProcurveM::execute( $cli_protocol, $connection_path );

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

=item C<_send_username($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "username" credential should be sent to the
device.

=item C<_send_password($cli_protocol, $connection_path)>

This sub-routine is called if a response from the device indicates that the "password" credential should be sent to the
device.

=item C<_get_prompt($cli_protocol, $connection_path)>

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
