package ZipTie::Adapters::Juniper::JUNOS::GetActiveConfig;

use strict;

use ZipTie::TransferProtocolFactory;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::ConnectionPath::FileServer;
use ZipTie::Credentials;
use ZipTie::Logger;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::Adapters::Utils qw(create_unique_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_active_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_active_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol = shift;
	my $connection_path = shift;
	
	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;

	# Check to see if SCP is supported.  If so, a SCP client will be used to connect to the JUNOS-based device to
	# retrieve it's active configuration.
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP") if ( defined($connection_path) );
	
	if ( defined($scp_protocol) )
	{
		$response = _get_active_config_scp( $connection_path );
	}

	# Otherwise, fall back to CLI protocol only
	else
	{
		$response = _get_active_config_cli($cli_protocol);
	}

	# Return the active configuration found
	return $response;
}

sub _get_active_config_cli
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol = shift;

	# Sending "show configuration" command
	my $command = "show configuration";
	$cli_protocol->send( $command, "configuration" );

	# Grab the prompt that was retrieved by the auto-login of the JUNOS device.
	my $prompt = $cli_protocol->get_prompt_by_name("prompt");

	# Check to see if the prompt was set on the device.  If not, fall back to matching '>|#'
	my $regex    = defined($prompt) ? $prompt : '>|#';
	my $response = $cli_protocol->wait_for($regex);
	$response =~ s/^show configuration\s*$//ms;
	$response =~ s/^$prompt\s*$//ms;
	$response =~ s/^\s*$//msg;

	# Return the active configuration found
	return $response;
}

sub _get_active_config_scp
{
	# Grab our ZipTie::ConnectionPath object
	my $connection_path = shift;

	# Grab the ZipTie::ConnectionPath::Protocol object representing SCP from the ZipTie::ConnectionPath object
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP");
	
	# For JUNOS-based devices, the active configuration is stored with in the "/config/juniper.conf.gz" file
	my $active_config_name = "/config/juniper.conf.gz";

	# Retrieve the active configuration file from the device
	my $xfer_client = ZipTie::TransferProtocolFactory::create( $scp_protocol->get_name() );
	$xfer_client->connect(	$connection_path->get_ip_address(),
							$scp_protocol->get_port(),
							$connection_path->get_credential_by_name("username"),
							$connection_path->get_credential_by_name("password") );

	# Used create_unique_filename to get a randomly generated name for a temp file to use for the SCP process
    my $temp_filename = create_unique_filename();
	$xfer_client->get( $active_config_name, $temp_filename );
	
	# Open up the GZipped configuration file and read it into memory
    open(GZIP_ACTIVE_CONFIG, $temp_filename) || $LOGGER->fatal("[$SCP_ERROR]\nCould not open the retrieved configuration file stored in '$temp_filename'");
    my @entire_file = <GZIP_ACTIVE_CONFIG>;
    close(GZIP_ACTIVE_CONFIG);
    my $gzip_active_config = join( "", @entire_file );

    # Record the file transfer of the config
    # Arguments: protocol name, file name, response/contents, whether or not ZipTie acted as the file transfer server
    $RECORDING->create_xfer_interaction($scp_protocol->get_name(), $temp_filename, $gzip_active_config, 0);
	

	# Open up the active configuration file and unzip it
	use IO::Zlib;

	$LOGGER->debug("Using Compress::Zlib to unzip configuration file");
	tie *ACTIVE_CONFIG, 'IO::Zlib', $temp_filename, "rb";

	# Read the decompressed contents into memory
	my @entire_file = <ACTIVE_CONFIG>;
	close(ACTIVE_CONFIG);
	my $active_config_contents = join( "", @entire_file );
	
	unlink ($temp_filename) if (-e $temp_filename);	# delete the temp file 
	# Return the contents of the active configuration
	return $active_config_contents;
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Juniper::JUNOS::GetActiveConfig - Retrieves the active configuration from an JUNOS-based device.

=head1 SYNOPSIS

    use ZipTie::Adapters::Juniper::JUNOS::GetActiveConfig qw(get_active_config);
	my $active_config = get_active_config($cli_protocol_obj);
	my $active_config = get_active_config($cli_protocol_obj, $connection_path);

=head1 DESCRIPTION

C<ZipTie::Adapters::Juniper::JUNOS::GetActiveConfig> allows for the retrieve of the active configuration
from an JUNOS-based device by using either a C<ZipTie::CLIProtocol> object to retrieve the active configuration
via the command line using the "file show /config/juniper.conf.gz" command, or by using a C<ZipTie::ConnectionPath>
object to retrieve the active config via a file transfer protocol client/agent. The only file transfer protocol currently
supported is SCP.

The only subroutine a user of C<ZipTie::Adapters::Juniper::JUNOS::GetActiveConfig> should be concerned with is 
C<get_active_config($cli_protocol_obj, $connection_path)>; it provides an abstraction layer that hides the mechanism
for retrieving the active configuration.

=head1 EXPORTED SUBROUTINES

=over 12

=item C<get_active_config($cli_protocol_obj, $connection_path)>

Main entry point into the functionality for retrieveing a active configuration from a JUNOS-based device.
It provides an abstraction layer that hides the mechanism for retrieving the configuration file.

First, it is examined to see if a file transfer protocol has been specified to use as the transfer mechanism.  If this is
the case, then the corresponding private subroutine that utilizes that type of file transfer protocol will be called.
The only file transfer protocol that is supported is currently is SCP and this is accomplished through the 
C<_get_active_config_scp($cli_protocol_obj, $connection_path)> private subroutine.

If no file transfer protocol has been specified, then the specified C<ZipTie::CLIProtocol> object will be used to
retrieve the active configuration via CLI through the C<_get_active_config_cli($cli_protocol_obj)> private
subroutine.

Regardless of the mechanism chosen, the contents of the active configuration will be returned.

Input:		$cli_protocol_obj -	A valid C<ZipTie::CLIProtocol> object that is already connected to a JUNOS-based device.
			$connection_path -	Optional.  C<A valid ZipTie::ConnectionPath> object that contains all of the IP, credential,
								protocol, and file server information needed to correctly retrieve the configuration
								from the the JUNOS-based device.

=back

=head1 PRIVATE SUBROUTINES

=over 12

=item C<_get_active_config_cli($cli_protocol_obj)>

Retrieves the active configuration for an JUNOS-based device by executing the "file show /config/juniper.conf.gz"
command via a C<ZipTie::CLIProtocol> object that has been previously connected to a JUNOS-based device.

This subroutine will be called by C<get_active_config($cli_protocol_obj, $connection_path)> if no valid
C<ZipTie::ConnectionPath> object was specified.

=item C<_get_active_config_scp($cli_protocol_obj, $connection_path)>

Retrieves the active configuration from the JUNOS-based device using an SCP client to retrieve the
"/config/juniper.conf.gz" gzip file that stores the configuration file.  The contents of this gzip file is then decompressed
using C<IO::Zlib> and the active configuration is parsed from it and returned.

This subroutine will be called by C<get_active_config($cli_protocol_obj, $connection_path)> if a
valid C<ZipTie::ConnectionPath> object containing protocol information representing SCP was specified.

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

Contributor(s): dwhite (dylamite@ziptie.org)
Date: May 23, 2007

=cut
