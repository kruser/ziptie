package ZipTie::Adapters::Nortel::Accelar::GetConfig;

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
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(create_empty_file escape_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_config get_config_all);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol = shift;
	my $connection_path = shift;
	my $prompt_regex = shift;
	
	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;
	
	# Check to see if either TFTP or SCP are supported	
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );	
	
	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the configuration
	if ( defined($tftp_protocol) )
	{
		$response = _get_config_tftp($cli_protocol, $connection_path,$prompt_regex);
	}else
	{
		$response = _get_config_cli($cli_protocol, $prompt_regex);
	}
	return $response;
}

sub _get_config_cli
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $regex = shift;
			
	my $response = $cli_protocol->send_and_wait_for( 'show config' , $regex );
	
	return $response;
}

sub _get_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	my $regex = shift;
	# Grab TFTP data
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	my $tftp_ip_address = $tftp_file_server->get_ip_address();
	my $config_name = escape_filename($cli_protocol->get_ip_address() . ".config");
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";
	create_empty_file($config_file);
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new("fail\\s*$regex",undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new("success\\s*$regex", \&_finish));
		
	#copy config.xml with tftp to host <ipaddress>.config
	
	$cli_protocol->send_and_wait_for("copy config tftp", "Enter destination tftp server address");
	$cli_protocol->send_and_wait_for($tftp_ip_address, "Enter destination file");
	$cli_protocol->send($config_file);
	

	
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path, $regex);
	}
}

sub _finish
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	my $regex = shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Retrieve the configuration file from the TFTP server
	my $config_name = escape_filename($cli_protocol->get_ip_address() . ".config");
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";
	$LOGGER->debug("Opening file $config_file for reading");
	# Open up the configuration file and read it into memory
	open(CONFIG, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file': $!");
	my @entire_file = <CONFIG>;
	close(CONFIG);
	my $config_contents = join("", @entire_file);
	my $length = length($config_contents);
	$LOGGER->debug("Read from file $length chars");
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	# unlink ($config_file);
	
	# Record the file transfer of the config
    # Arguments: protocol name, file name, response/contents
    $RECORDING->create_xfer_interaction( $tftp_file_server->get_protocol(), $connection_path->get_ip_address(), $config_contents );
	
	# Return the contents of the configuration
	return $config_contents;
}

1;

__END__


sub _copy_config_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('flash', \&_write_command));
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Ss]ource [Ff]ilename', \&_specify_source_file));
	push(@responses, ZipTie::Response->new('[Rr]emote host', \&_specify_tftp_address));
	
	# Grab the enable prompt that was retrieved by the auto-login of the CatOS device.
	#my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Sending "copy config tftp" command
	my $command = "copy config tftp";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _write_command
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('y\/n', \&_confirm_tftp));
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Ss]ource [Ff]ilename', \&_specify_source_file));
	push(@responses, ZipTie::Response->new('[Rr]emote host', \&_specify_tftp_address));
	
	# Grab the enable prompt that was retrieved by the auto-login of the CatOS device.
	my $enable_prompt = $cli_protocol->get_prompt_by_name("enablePrompt");
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Grab the TFTP server IP address
	my $tftp_ip_address = $tftp_file_server->get_ip_address();
	
	# Compute the name of the file that we want to save the config as
	my $config_name = $cli_protocol->get_ip_address() . ".config";
	
	# Sending "write" command and append the IP address of the TFTP server as well as the name of the config
	my $command = "write $tftp_ip_address $config_name";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_source_file()
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('[Rr]emote host|ostname', \&_specify_tftp_address));
	
	# Sending "config" as the source file name for the configuration.
	my $command = "config";
	$cli_protocol->send( $command );
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_tftp_address
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Grab the ZipTie::Connection::FileServer object representing TFTP file server
	my $tftp_file_server = $connection_path->get_file_server_by_name("TFTP");
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('%Error', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('filename|file to write|file to copy', \&_specify_config_name));
	
	# Sending the TFTP server address
	$cli_protocol->send( $tftp_file_server->get_ip_address() );
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _specify_config_name
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error opening tftp|Error reading|timed out|cannot copy|%Error|Failed', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('y\/n', \&_confirm_tftp));
	push(@responses, ZipTie::Response->new('bytes copied|OK|copied successfully', \&_finish));
	
	# Store the current timeout value for the ZipTie::CLIProtocol object
	my $prev_cli_timeout = $cli_protocol->get_timeout();
	
	# Sending the name of the file that we want to save the config as
	my $config_name = $cli_protocol->get_ip_address() . ".config";
	$cli_protocol->set_timeout(30);
	$cli_protocol->send( $config_name );
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
	# Restore the previous timeout value for the ZipTie::CLIProtocol object
	$cli_protocol->set_timeout($prev_cli_timeout);
	
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
		# Return the configuration found
		return &$next_interaction($cli_protocol, $connection_path);
	}
}

sub _confirm_tftp
{
	# Grab our ZipTie::CLIProtocol and ZipTie::ConnectionPath objects
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Specify the responses to check for
	my @responses = ();
	push(@responses, ZipTie::Response->new('Error opening tftp|Error reading|timed out|cannot copy|%Error|Failed', undef, $TFTP_ERROR));
	push(@responses, ZipTie::Response->new('memory invalid', undef, $DEVICE_MEMORY_ERROR));
	push(@responses, ZipTie::Response->new('bytes copied|OK|copied successfully|inished network upload', \&_finish));
	
	# Store the current timeout value for the ZipTie::CLIProtocol object
	my $prev_cli_timeout = $cli_protocol->get_timeout();
	
	# Sending "yes" to confirm
	$cli_protocol->set_timeout(30);
	$cli_protocol->send( "yes" );
	my $response = $cli_protocol->wait_for_responses(\@responses);
	
	# Restore the previous timeout value for the ZipTie::CLIProtocol object
	$cli_protocol->set_timeout($prev_cli_timeout);
	
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
		# Return the configuration found
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
	
	# Retrieve the configuration file from the TFTP server
	my $config_name = $cli_protocol->get_ip_address() . ".config";
	my $config_file = $tftp_file_server->get_root_dir() . "/$config_name";
	
	# Open up the configuration file and read it into memory
	open(CONFIG, $config_file) || $LOGGER->fatal("[$TFTP_ERROR]\nCould not open the retrieved configuration file stored in '$config_file'!");
	my @entire_file = <CONFIG>;
	close(CONFIG);
	my $config_contents = join("", @entire_file);
	
	# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
	unlink ($config_file);
	
	# Add the contents of the configuration to the ZipTie::Recording object
	my $interaction = ZipTie::Recording::Interaction->new(
		xferProtocol    => $tftp_file_server->get_protocol(),
		xferResponse  	=> $config_contents,
	);
		
	$RECORDING->start_current_interaction($interaction);
	$RECORDING->finish_current_interaction();
	
	# Return the contents of the configuration
	return $config_contents;
}


=head1 NAME

ZipTie::Adapters::Cisco::CatOS::GetConfig - Retrieves the configuration from a CatOS-based device.

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::CatOS::GetConfig qw(get_config);
	my $config = get_config($cli_protocol);
	my $config = get_config($cli_protocol, $connection_path);

=head1 DESCRIPTION

C<ZipTie::Adapters::Cisco::CatOS::GetConfig> allows for the retrieve of the configuration from an CatOS-based device by
using either a C<ZipTie::CLIProtocol> object to retrieve the configuration via the command line using the "show config all"
command, or by using a C<ZipTie::ConnectionPath> object to retrieve the config via a file transfer protocol client/agent.
The file transfer protocols that are supported currently are: TFTP and SCP.

The only subroutine a user of C<ZipTie::Adapters::Cisco::CatOS::GetConfig> should be concerned with is 
C<get_config($cli_protocol, $connection_path)>; it provides an abstraction layer that hides the mechanism for
retrieving the configuration.

=head1 EXPORTED SUBROUTINES

=over 12

=item C<get_config($cli_protocol, $connection_path)>

Main entry point into the functionality for retrieveing a configuration from a CatOS-based device.
It provides an abstraction layer that hides the mechanism for retrieving the configuration file.

First, the specified C<ZipTie::ConnectionPath> object is examined to see if a file transfer protocol has been specified to
use as the transfer mechanism.  If this is the case, then the corresponding private subroutine that utilizes that type of file
transfer protocol will be called.  For example, if TFTP is the file transfer protocol specified, the
C<_get_config_tftp($cli_protocol, $connection_path)> private subroutine will be used.  If the SCP is the file transfer protocol
specified, the C<_get_config_scp($cli_protocol, $connection_path)> private subroutine will be used. 

If no file transfer protocol has been specified, then the specified C<ZipTie::CLIProtocol> object will be used to
retrieve the configuration via a command-line interface (CLI) through the C<get_config_cli($cli_protocol)> private
subroutine.

Regardless of the mechanism chosen, the contents of the configuration will be returned.

Input:		$cli_protocol -		A valid C<ZipTie::CLIProtocol> object that is already connected to a CatOS-based device.
			$connection_path -	Optional.  C<A valid ZipTie::ConnectionPath> object that contains all of the IP, credential,
								protocol, and file server information needed to correctly retrieve the configuration
								from the the CatOS-based device.

=back

=head1 PRIVATE SUBROUTINES

=over 12

=item C<_get_config_cli($cli_protocol)>

Retrieves the configuration for an CatOS-based device by executing the "show config all" command via a C<ZipTie::CLIProtocol>
object that has been previously connected to a CatOS-based device.

This subroutine will be called by C<get_config($cli_protocol, $connection_path)> if no valid C<ZipTie::ConnectionPath>
object was specified.

=item C<_get_config_scp($cli_protocol, $connection_path)>

Retrieves the configuration from the CatOS-based device using an SCP client to retrieve the "config" file that stores the
configuration file.  The contents of this file will the be parsed and returned.

This subroutine will be called by C<get_config($cli_protocol, $connection_path)> if a valid C<ZipTie::ConnectionPath>
object was specified that contains a valid C<ZipTie::ConnectionPath::Protocol> object representing the SCP protocol.

=item C<_get_config_tftp($cli_protocol, $connection_path)>

Starts the retrieval of the configuration for an CatOS-based device by caliing the "copy config tftp all" command via 
a C<ZipTie::CLIProtocol> object that has already been connected to a CatOS-based device.

=back

=head1 PRIVATE SUBROUTINES POSSIBLY INVOKED BY C<_get_config_tftp($cli_protocol, $connection_path)>

=over 12

=item C<_specify_source_file($cli_protocol, $connection_path)>

Continues the retrieval of the configuration for an CatOS-based device by specifying the name of the file on 
the device that contains the configuration.  This will be "config".  The command/input is sent via a C<ZipTie::CLIProtocol> object
that has already been connected to an CatOS-based device.

The file name for the configuration file might have to be specified for certain versions of CatIOS that require this input as
part of the follow-up information required by the "copy config tftp all" command.

=item C<_specify_tftp_address($cli_protocol, $connection_path)>

Continues the retrieval of the configuration for an CatOS-based device by specifying the IP address of the TFTP file server to backup
the configuration to via a C<ZipTie::CLIProtocol> object that has already been connected to an CatOS-based device. 

=item C<_specify_config_name($cli_protocol, $connection_path)>

Continues the retrieval of the configuration for an CatOS-based device by specify the name to save the configuration file under on
the TFTP server via a C<ZipTie::CLIProtocol> object that has already been connected to an CatOS-based device.

The name of the configuration file will always be determined using the following algorithm: the IP address of
the device we are interaction with the extension ".config" appended to it.  Example: "10.100.10.10.config".

=item C<_confirm_tftp($cli_protocol, $connection_path)>

Continues the retrieval of the configuration for an CatOS-based device by sending a "yes" confirmation via a
C<ZipTie::CLIProtocol> object that has already been connected to an CatOS-based device.

=item C<_finish($cli_protocol, $connection_path)>

Finishes the retrieval of the configuration for an CatOS-based device by reading the configuration file that was successfully
backed up to the specified TFTP server and retrieving the contents so that it can be parsed and returned.

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

Contributor(s): Ashuin Sharma(asharma@isthmusit.com), dwhite (dylamite@ziptie.org)
Date: Sep 29, 2007

=cut
