package ZipTie::Adapters::Nokia::Checkpoint::GetConfig;

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
use ZipTie::Adapters::Utils qw(create_unique_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_config
{
	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol = shift;
	my $connection_path = shift;
	my $filename = shift;
	
	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;

	# Check to see if either TFTP or SCP are supported	
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP") if ( defined($connection_path) );

	# Check to see if SCP is supported.  If so, a SCP client will be used to retrieve the configuration
	if ( defined($scp_protocol) )
	{
		$response = _get_config_scp($connection_path, $filename);
	}
	else
	{
		$LOGGER->fatal("Unable to backup the Nokia Checkpoint device without SCP.");
	}
	
	# Return the configuration found
	return $response;
}

sub _get_config_scp
{
	# Grab our ZipTie::ConnectionPath object
	my $connection_path = shift;
	my $filename = shift;

	# Grab the ZipTie::ConnectionPath::Protocol object representing SCP from the ZipTie::ConnectionPath object
	my $scp_protocol = $connection_path->get_protocol_by_name("SCP");

	# Retrieve the running configuration file from the device
	my $xfer_client = ZipTie::TransferProtocolFactory::create( $scp_protocol->get_name() );
	$xfer_client->connect(	$connection_path->get_ip_address(),
							$scp_protocol->get_port(),
							$connection_path->get_credential_by_name("username"),
							$connection_path->get_credential_by_name("password") );

	# Used create_unique_filename to get a randomly generated name for a temp file to use for the SCP process
    my $temp_filename = create_unique_filename();
	$xfer_client->set_timeout(60);
	$xfer_client->get( "./$filename.tar.gz", $temp_filename );

	# Open up the configuration file and read it into memory
    open(CONFIG, $temp_filename) || $LOGGER->fatal("[$SCP_ERROR]\nCould not open the retrieved configuration file stored in '$temp_filename'");
    my @entire_file = <CONFIG>;
    close(CONFIG);
    my $config_contents = join( "", @entire_file );

    # Record the file transfer of the config
    # Arguments: protocol name, file name, response/contents, whether or not ZipTie acted as the file transfer server
    $RECORDING->create_xfer_interaction($scp_protocol->get_name(), $temp_filename, $config_contents, 0);

	# Return the filename.  The caller must delete the config file.
	return $temp_filename;
}

1;

__END__

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

Contributor(s): dwhite (dylamite@ziptie.org)
Date: August 9, 2007

=cut
