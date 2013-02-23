package ZipTie::Recording::Interaction;

use strict;
use MIME::Base64 'encode_base64';
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub new
{
	my $class_name = shift;

	# Create the members of this class
	my $this = {
		cliProtocol  => undef,
		cliCommand   => undef,
		asBytes      => 0,
		waitFor      => undef,
		timeout      => undef,
		startTime    => undef,
		cliResponse  => undef,
		endTime      => undef,
		xferProtocol => undef,
		xferResponse => undef,
		xferFilename => undef,
		xferAsServer => 0,
	};

	# Turn $this into a ZipTie::Recording::Interaction object
	bless( $this, $class_name );
	
	# Initialize the cliResponse and xferResponse to be empty instead of undefined
	$this->cliResponse( "" );
	$this->xferResponse( "" );

	# Parse the arguments to see what attributes are going to be set
	my %args = @_;

	# For each argument, see if it is on of the possible attributes to be set.  If not, die.
	foreach ( keys %args )
	{
		if (/^cliProtocol/i)
		{
			$this->cliProtocol( $args{$_} );
		}
		elsif (/^cliCommand/i)
		{
			$this->cliCommand( $args{$_} );
		}
		elsif (/^asBytes/i)
		{
			$this->asBytes( $args{$_} );
		}
		elsif (/^waitFor/i)
		{
			$this->waitFor( $args{$_} );
		}
		elsif (/^timeout/i)
		{
			$this->timeout( $args{$_} );
		}
		elsif (/^startTime/i)
		{
			$this->startTime( $args{$_} );
		}
		elsif (/^cliResponse/i)
		{
			$this->cliResponse( $args{$_} );
		}
		elsif (/^endTime/i)
		{
			$this->endTime( $args{$_} );
		}
		elsif (/^xferProtocol/i)
		{
			$this->xferProtocol( $args{$_} );
		}
		elsif (/^xferResponse/i)
		{
			$this->xferResponse( $args{$_} );
		}
		elsif (/^xferAsServer/i)
        {
            $this->xferAsServer( $args{$_} );
        }
		elsif (/^xferFilename/i)
        {
            $this->xferFilename( $args{$_} );
        }
		else
		{
			$LOGGER->fatal( "Bad named parameter \"$_\" given " . "to "
				  . ref($this)
				  . "::new()" );
		}
	}

	# Return the new ZipTie::Recording::Interaction object
	return $this;
}

sub cliProtocol
{
	my $this = shift;
	if (@_)
	{
		$this->{cliProtocol} = shift;
	}
	return $this->{cliProtocol};
}

sub cliCommand
{
	my $this = shift;
	if (@_)
	{
		my $cli_command = shift;
		$this->{cliCommand} = encode_base64($cli_command);
	}
	return $this->{cliCommand};
}

sub asBytes
{
	my $this = shift;
	if (@_)
	{
		$this->{asBytes} = shift;
	}
	return $this->{asBytes};
}

sub waitFor
{
	my $this = shift;
	if (@_)
	{
		my $wait_for_regex = shift;
		$this->{waitFor} = encode_base64($wait_for_regex);
	}
	return $this->{waitFor};
}

sub timeout
{
	my $this = shift;
	if (@_)
	{
		$this->{timeout} = shift;
	}
	return $this->{timeout};
}

sub startTime
{
	my $this = shift;
	if (@_)
	{
		$this->{startTime} = shift;
	}
	return $this->{startTime};
}

sub cliResponse
{
	my $this = shift;
	if (@_)
	{
		my $cli_response_data = shift;
		$this->{cliResponse}[0] = encode_base64($cli_response_data);
	}
	return $this->{cliResponse}[0];
}

sub endTime
{
	my $this = shift;
	if (@_)
	{
		$this->{endTime} = shift;
	}
	return $this->{endTime};
}

sub xferProtocol
{
	my $this = shift;
	if (@_)
	{
		$this->{xferProtocol} = shift;
	}
	return $this->{xferProtocol};
}

sub xferResponse
{
	my $this = shift;
	if (@_)
	{
		my $xferResponseData = shift;
		$this->{xferResponse}[0] = encode_base64($xferResponseData);
	}
	return $this->{xferResponse}[0];
}

sub xferAsServer
{
	my $this = shift;
	if (@_)
	{
		$this->{xferAsServer} = shift;
	}
	return $this->{xferAsServer};
}

sub xferFilename
{
    my $this = shift;
    if (@_)
    {
        $this->{xferFilename} = shift;
    }
    return $this->{xferFilename};
}

1;

__END__

=head1 NAME

ZipTie::Recording::Interaction - Encapsulates an interaction with a device for use with the C<ZipTie::Recording>
module format.

=head1 SYNOPSIS

	use ZipTie::Recording;
	use ZipTie::Recording::Interaction;

	# Retrieves the singleton instance of the ZipTie::Recording module
	my $recording = ZipTie::Recording::get_recording();

	# Create a new ZipTie::Recording::Interaction instance
	my $cli_interaction = ZipTie::Recording::Interaction->new(
		cliCommand  => "some command"
		cliProtocol => "Telnet"
		asBytes => 0
	);
	
	# Starts a new interaction on the ZipTie::Recording singleton, saving the previous interaction
	# if it had not been saved already
	$recording->start_current_interaction($cli_interaction);
	
	# Update our current interaction
	$cli_interaction->waitFor($regex);
	$cli_interaction->timeout($timeout);
	$cli_interaction->cliResponse($response);
	
	# Mark that we have finished the current CLI interaction.
	$recording->finish_current_interaction();
	
	# Create a new ZipTie::Recording::Interaction instance
	my $xfer_interaction = ZipTie::Recording::Interaction->new(
		xferProtocol => "TFTP",
		xferResponse => "someSortOfResponse",
		xferAsServer => 0,
		xferFilename => "10.10.10.10_config",
	);
	
	# Starts a new interaction on the ZipTie::Recording singleton, saving the previous interaction
	# if it had not been saved already
	$recording->start_current_interaction($xfer_interaction);
	
	# Saves the current interaction and makes way for a new interaction to be added
	$recording->finish_current_interaction();

=head1 DESCRIPTION

The C<ZipTie::Recording::Interaction> module encapsulates an interaction with a device for use with the C<ZipTie::Recording>
module format.  An interaction from a device is a single sequence of sending some information to a device and receiving the
response.

In terms of using a command line interface (CLI) protocol to communicate with a device through ZipTie, this typically means
that an interaction encapsulates the act of sending a command to the device, waiting for the response, and capturing the
response.  This amounts to ZipTie acting as the client, and the device acting as the server/host.

When using a file transfer protocol to communicate with a device, there are a couple of caveats.  The simplest way to
define an interaction with a file transfer protocol is similar to how CLI is, with ZipTie acting as the client, and the
device acting as the server/host.  However, with the file transfer protocol, it's possible that the device itself may act
as a client and communicate with ZipTie with it being the server.  This is typically achieved by communicating with the
device using a CLI command that instructs the device to perform an action that uses a file transfer protocol; an easy example
of this is using the "copy tftp" command on a Cisco IOS device that instructs the device to communicate with a TFTP server
to transfer the IOS's configuration file to.  In this case, the interaction has two components: the CLI part and the file
transfer protocol part.  The C<ZipTie::Recording::Interaction> module has support for encapsulating all of this information
into a single interaction instance.

The C<ZipTie::Recording::Interaction> module is designed to work exclusively with the C<ZipTie::Recording> module.  Please
refer to the C<ZipTie::Recording> documentation to, especially for the following methods which work directly with instances
of the C<ZipTie::Recording::Interaction> module: C<start_current_interaction($new_interaction)>, C<get_current_interaction()>,
C<get_interactions()>, C<finish_current_interaction()>, and C<create_xfer_interaction($protocol, $filename, $response, $as_server)>.

=head1 METHODS

=over 12

=item C<new(@args)>

Creates a new C<ZipTie::Recording::Interaction> object and stores a variety of possible attributes/elements used to 
describe the interaction.  The attributes/elements that are supported are: C<cliProtocol>, C<cliCommand>, C<asBytes>,
C<waitFor>, C<timeout>, C<startTime>, C<cliResponse>, C<endTime>, C<xferProtocol>, C<xferResponse>, and C<xferAsServer>.

The C<new()> method can take an array of any number of hashes that map one of the attribute names specified above to a value.
The name/key for each hash is case-insensitive.

=item C<cliProtocol($cli_protocol_name)>

Sets and/or retrieves the C<cliProtocol> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<cliProtocol> attribute represents the name of the CLI protocol that was used to execute any CLI command for
this interaction.

If no argument is passed into this method, the current value of the C<cliProtocol> attribute will be returned; otherwise,
the C<cliProtocol> attribute will be set to the specified value.

=item C<cliCommand($cli_command)>

Sets and/or retrieves the C<cliCommand> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<cliCommand> attribute represents the CLI command/input that was executed during this interaction.

If no argument is passed into this method, the current value of the C<cliCommand> attribute will be returned; otherwise,
the C<cliCommand> attribute will be set to the specified value and it will be encoded using the Base64 algorithim.  This is
done to ensure that the contents of the CLI command don't cause any issues when being used by other modules.

=item C<asBytes($as_bytes_flag)>

Sets and/or retrieves the C<asBytes> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<asBytes> attribute represents whether or not the CLI command/input being sent was sent as bytes; this value defaults
to false if not set.

If no argument is passed into this method, the current value of the C<asBytes> attribute will be returned; otherwise,
the C<asBytes> attribute will be set to the specified value.

=item C<waitFor($wait_for_regex)>

Sets and/or retrieves the C<waitFor> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<waitFor> attribute represents the regular expression used to match a response from a device after a CLI command/input
has been sent to and executed against a device.

If no argument is passed into this method, the current value of the C<waitFor> attribute will be returned; otherwise,
the C<waitFor> attribute will be set to the specified value and it will be encoded using the Base64 algorithim.  This is
done to ensure that the contents of the wait for regular expression don't cause any issues when being used by other modules.

=item C<timeout($timeout)>

Sets and/or retrieves the C<timeout> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<timeout> attribute represents the amount of time, in seconds, to wait for a response from the device during the
interaction.  This can be used in either a CLI or file transfer context.

If no argument is passed into this method, the current value of the C<timeout> attribute will be returned; otherwise,
the C<timeout> attribute will be set to the specified value.

=item C<startTime($start_time)>

Sets and/or retrieves the C<startTime> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<startTime> attribute represents the time, as milliseconds from the epoch, that the this interaction started.
This can be used in either a CLI or file transfer context.

If no argument is passed into this method, the current value of the C<startTime> attribute will be returned; otherwise,
the C<startTime> attribute will be set to the specified value.

=item C<cliResponse($cli_response_data)>

Sets and/or retrieves the C<cliResponse> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<cliResponse> attribute represents the response from a device as the result of a command that has been sent to a device.

If no argument is passed into this method, the current value of the C<cliResponse> attribute will be returned; otherwise,
the C<cliResponse> attribute will be set to the specified value and it will be encoded using the Base64 algorithim.  This is
done to ensure that the contents of the response don't cause any issues when being used by other modules.

=item C<endTime($end_time)>

Sets and/or retrieves the C<endTime> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<endTime> attribute represents the time, as milliseconds from the epoch, that the this interaction finished.
This can be used in either a CLI or file transfer context.

If no argument is passed into this method, the current value of the C<endTime> attribute will be returned; otherwise,
the C<endTime> attribute will be set to the specified value.

=item C<xferProtocol($xfer_protocol_name)>

Sets and/or retrieves the C<xferProtocol> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<xferProtocol> attribute represents the name of the file transfer protocol that was used to interact with the device
for this interaction.

If no argument is passed into this method, the current value of the C<xferProtocol> attribute will be returned; otherwise,
the C<xferProtocol> attribute will be set to the specified value.

=item C<xferResponse($xfer_response_data)>

Sets and/or retrieves the C<xferResponse> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<xferResponse> attribute represents the response from a device as the result of an interaction that is specific
to a file transfer protocol client.

If no argument is passed into this method, the current value of the C<xferResponse> attribute will be returned; otherwise,
the C<xferResponse> attribute will be set to the specified value and it will be encoded using the Base64 algorithim.  This is
done to ensure that the contents of the response don't cause any issues when being used by other modules.

=item C<xferAsServer($xfer_as_server)>

Sets and/or retrieves the C<xferAsServer> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<xferAsServer> attribute represents whether or not ZipTie acted as the server and the device acted as the client
during a file transfer protocol interaction.

If no argument is passed into this method, the current value of the C<xferAsServer> attribute will be returned; otherwise,
the C<xferAsServer> attribute will be set to the specified value.

=item C<xferFilename($xfer_filename)>

Sets and/or retrieves the C<xferFilename> attribute specified for this C<ZipTie::Recording::Interaction> object.
The C<xferFilename> attribute represents the name of the file that was retrieved as a result of the file transfer.

If no argument is passed into this method, the current value of the C<xferFilename> attribute will be returned; otherwise,
the C<xferFilename> attribute will be set to the specified value.

=back

=head1 SEE ALSO

ZipTie::Recording

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
Date: Jul 2, 2007

=cut
