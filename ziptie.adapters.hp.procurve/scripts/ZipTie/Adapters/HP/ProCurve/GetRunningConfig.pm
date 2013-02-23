package ZipTie::Adapters::HP::ProCurve::GetRunningConfig;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::TransferProtocolFactory;
use ZipTie::TransferProtocol;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::ConnectionPath::FileServer;
use ZipTie::Adapters::Utils qw(create_empty_file escape_filename);
use ZipTie::Logger;

use Exporter 'import';
our @EXPORT_OK = qw(get_running_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_running_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Create an undef reference that can eventually hold the running configuration contents that are found
	my $response = undef;

	# Check to see if TFTP is supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );
	
	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the running configuration
	if ( defined($tftp_protocol) )
	{
		$response = _get_running_config_tftp($cli_protocol, $connection_path);
	}
	# Otherwise, fall back to CLI protocol only
	else
	{
		$response = _get_running_config_cli($cli_protocol);
	}
	
	# Return the running configuration found
	return $response;
}

sub _get_running_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol = shift;
	
	# Sending "show running-config" command
	my $command = "show running-config";
	$cli_protocol->send( $command );
	
	# Grab the enable prompt that was retrieved by the auto-login of the ProCurve device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Check to see if the enable prompt was set on the device.  If not, fall back to matching '>|#'
	my $regex = defined($enable_prompt) ? $enable_prompt : '>|#';
	my $response = $cli_protocol->wait_for($regex);

	# remove any header and/or footer
	if ( $response =~ /Running configuration:(.+?)$regex/mis )
	{
		$response = $1;
	}

	# remove any --More-- prompt lines from older (1900) devices
	$response =~ s/^--More--.*$//mg;

	# remove hex chars
	$response =~ s/.+?1H//mg; # not the best way of doing this

	# Return the running configuration found
	return $response;
}

sub _get_running_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	
	# Grab the enable prompt that was retrieved by the auto-login of the ProCurve device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	my $bad_command_regex = '%\s*[Ii]nvalid input.*[\n\r]+' . $enable_prompt;
	
	push(@responses, ZipTie::Response->new($bad_command_regex, undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('Incomplete input: -EOI-', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('Peer unreachable.', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new($enable_prompt, \&_finish));
		
	# Sending "copy running-config tftp <IP> <FILE>" command
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $tftp_ip_address = $tftp_file_server->get_ip_address();
	my $runningConfigName = escape_filename($cli_protocol->get_ip_address() . ".running-config");
	create_empty_file($tftp_file_server->get_root_dir() . "/$runningConfigName");
	my $command = "copy running-config tftp " . $tftp_ip_address . " " . $runningConfigName;
	$cli_protocol->send( $command );
	
	#wait 180 seconds, 3 minutes is more than enough, default 30 secs is not though!
	my $response = $cli_protocol->wait_for_responses(\@responses, 180);
	
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
		# Return the running configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _finish
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Retrieve the running configuration file from the TFTP server
	my $running_config_name = escape_filename($cli_protocol->get_ip_address() . ".running-config");
	my $running_config_file = $tftp_file_server->get_root_dir() . "/$running_config_name";
	
	# Open up the running configuration file and read it into memory
	open(RUNNING_CONFIG, $running_config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved running configuration file stored in '$running_config_file'!");
	my @entire_file = <RUNNING_CONFIG>;
	close(RUNNING_CONFIG);
	my $running_config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($running_config_file);
	
	# Record the file transfer of the running config
    # Arguments: protocol name, file name, response/contents
    $RECORDING->create_xfer_interaction($tftp_file_server->get_protocol(), $running_config_name, $running_config_contents);
	
	# Return the contents of the running configuration
	return $running_config_contents;
}

1;

__END__

=head1 NAME

ZipTie::Adapters::HP::ProCurve::GetRunningConfig - Retrieves the running configuration from a ProCurve device.

=head1 SYNOPSIS

    use ZipTie::Adapters::HP::ProCurve::GetRunningConfig qw(get_running_config);
	my $running_config = get_running_config($cli_protocol);
	my $running_config = get_running_config($cli_protocol, $connection_path);

=head1 DESCRIPTION

C<ZipTie::Adapters::HP::ProCurve::GetRunningConfig> allows for the retrieval of the running configuration
from a ProCurve device by using either a C<ZipTie::CLIProtocol> object to retrieve the running configuration
via the command line using the "show running-config" command, or by using a C<ZipTie::ConnectionPath> to retrieve
the running config via a file transfer protocol client/agent. The file transfer protocols that is supported
currently is TFTP.

The only subroutine a user of C<ZipTie::Adapters::HP::ProCurve::GetRunningConfig> should be concerned with is 
C<get_running_config($cli_protocol, $connection_path)>; it provides an abstraction layer that hides the mechanism
for retrieving the running configuration.

=head1 EXPORTED SUBROUTINES

=over 12

=item C<get_running_config($cli_protocol, $connection_path)>

Main entry point into the functionality for retrieving a running configuration from a ProCurve device.
It provides an abstraction layer that hides the mechanism for retrieving the configuration file.

First, it is examined to see if a file transfer protocol has been specified to use as the transfer mechanism.  If this is
the case, then the corresponding private subroutine that utilizes that type of file transfer protocol will be called.
The only file transfer protocol that is supported is currently is tftp and this is accomplished through the 
C<_get_running_config_tftp($cli_protocol, $connection_path)> private subroutine.

If no file transfer protocol has been specified, then the specified C<ZipTie::CLIProtocol> object will be used to
retrieve the running configuration via CLI through the C<get_running_config_cli($cli_protocol)> private
subroutine.

Regardless of the mechanism chosen, the contents of the running configuration will be returned.

Input:		$cli_protocol -	A valid C<ZipTie::CLIProtocol> object that is already connected to a ProCurve device.
			$connection_path -	Optional.  C<A valid ZipTie::ConnectionPath> object that contains all of the IP, credential,
								protocol, and file server information needed to correctly retrieve the configuration
								from the the ProCurve device.

=back

=head1 PRIVATE SUBROUTINES

=over 12

=item C<_get_running_config_cli($cli_protocol)>

Retrieves the running configuration for an ProCurve device by executing the "show running-config"
command via a C<ZipTie::CLIProtocol> object that has been previously connected to a ProCurve device.

This subroutine will be called by C<get_running_config($cli_protocol, $connection_path)> if no valid
C<ZipTie::ConnectionPath> object was specified.

=item C<_get_running_config_tftp($cli_protocol, $connection_path)>

Starts the retrieval of the running configuration for an ProCurve device by caliing the "copy running-config tftp"
command via a C<ZipTie::CLIProtocol> object that has already been connected to a ProCurve device.  This method
utilizes an array C<ZipTie::Response> objects to handle different responses from the device.

This subroutine will be called by C<get_running_config($cli_protocol, $connection_path)> if a
valid C<ZipTie::ConnectionPath> object containing information representing TFTP was specified.

=back

=head1 PRIVATE SUBROUTINES POSSIBLY INVOKED BY C<_get_running_config_tftp($cli_protocol, $connection_path)>

=over 12

=item C<_finish($cli_protocol, $connection_path)>

Finishes the retrieval of the running configuration for an ProCurve device by reading the running configuration
file that was successfully backed up to the specified TFTP server and retrieving the contents in order to add
it to the recording of the C<ZipTie::CLIProtocol> object as a new interaction with the "cliCommand" element named
"show running-config".

After it has been added to the recording, the contents of the recording are returned and no more methods will be
called.

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

Contributor(s): dwhite (dylamite@ziptie.org), Daniel Badilla (dbadilla@isthmusit.com)
Date: December 10, 2007

=cut
