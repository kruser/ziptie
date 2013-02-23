package ZipTie::Recording;

use strict;
use XML::Simple;
use ZipTie::Logger;
use ZipTie::Credentials;
use Time::HiRes;
use ZipTie::Recording::Interaction;
use MIME::Base64 'encode_base64';
use ZipTie::Adapters::Utils qw(escape_filename);

# Grab the singleton instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Create our singleton object
my $_singleton;

#####################################################################
#
#	SUBROUTINES
#
#####################################################################

sub get_recording
{
	# Unless the singleton object already exists, create a new one
	unless ( defined $_singleton )
	{
		# Initialize the singleton instance of the class
		$_singleton = {
			interaction_array_ref => undef,
			current_interaction   => undef,
			device_prompt => undef,
			operation_name => undef,
			adapter_id => undef,
			connection_path_ref => undef,
		};

		# Turn our singleton into a ZipTie::Recording object
		bless( $_singleton, "ZipTie::Recording" );
	}

	# Return our singleton instance
	return $_singleton;
}

sub _trim
{
	# Remove leading and trailing whitespace
	my $string = shift;
	
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	
	return $string;
}

######################################################################
#
#	METHODS
#
######################################################################

sub get_adapter_id
{
	my $this = shift;
	return $this->{adapter_id};
}

sub set_adapter_id
{
	my $this = shift;
	if (@_)
	{
		my $adapter_id = shift;
		$adapter_id = &_trim($adapter_id);
		$this->{adapter_id} = $adapter_id;
	}
}

sub get_operation_name
{
	my $this = shift;
	return $this->{operation_name};
}

sub set_operation_name
{
	my $this = shift;
	if (@_)
	{
		my $operation_name = shift;
		$operation_name = &_trim($operation_name);
		$this->{operation_name} = $operation_name;
	}
}

sub get_connection_path
{
	my $this = shift;
	return $this->{connection_path_ref};
}

sub set_connection_path
{
	my $this = shift;
	if (@_)
	{
		my $connection_path_ref = shift;
		$this->{connection_path_ref} = $connection_path_ref;
	}
}

sub get_device_prompt
{
	my $this = shift;
	return $this->{device_prompt};
}

sub set_device_prompt
{
	my $this = shift;
	if (@_)
	{
		$this->{device_prompt} = shift;
	}
}

sub start_current_interaction
{
	my $this = shift;
	
	# Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
		$this->{current_interaction} = shift;
		
		# Get the current time in floating point seconds and convert it to milliseconds
		my $floating_seconds = Time::HiRes::time();
		my $milliseconds = int($floating_seconds * 1000);
		
		# Mark the start time for this interaction
		$this->{current_interaction}->startTime($milliseconds);
    }
}

sub get_current_interaction
{
	my $this = shift;
	return $this->{current_interaction};
}

sub finish_current_interaction
{
	my $this = shift;
	
	# Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
		# Get the current time in floating point seconds and convert it to milliseconds
		my $floating_seconds = Time::HiRes::time();
		my $milliseconds = int($floating_seconds * 1000);
		
		# Mark the end time for this interaction
		$this->{current_interaction}->endTime($milliseconds);
		
		push( @{ $this->{interaction_array_ref} }, $this->{current_interaction} );
		$this->{current_interaction} = undef;
    }
}

sub create_xfer_interaction
{
	my $this = shift;
	
	# Check to see if recording is enabled
    if ( $ENV{ENABLE_RECORDING} )
    {
		# Grab the arguments and specify defaults if they aren't all specified
	    my $protocol = defined( @_[0] ) ? shift: "";
	    my $filename = defined( @_[0] ) ? shift: "";
	    my $response = defined( @_[0] ) ? shift: "";
	    my $as_server = defined( @_[0] ) ? shift: 1;
	    
	    # Add the contents of the running configuration to the ZipTie::Recording object
	    my $interaction = ZipTie::Recording::Interaction->new(
	        xferProtocol    => $protocol,
	        xferFilename    => $filename,
	        xferResponse    => $response,
	        xferAsServer    => $as_server,
	    );
	    
	    # Immediately start and end the interaction to add it to the recording
	    $this->start_current_interaction($interaction);
	    $this->finish_current_interaction();
    }
}

sub get_interactions
{
	my $this = shift;
	return $this->{interaction_array_ref};
}

sub to_file()
{
	my $this = shift;
	
	# Check to see if an adapter ID, adapter operation name, and connection path reference are specified
	my $adapter_id     = shift;
	my $operation_name = shift;
	my $connection_path_ref = shift;
	
	# Set the adapter ID on this ZipTie::Recording instance if it has been specified as an argument
	if (defined($adapter_id))
	{
		$this->set_adapter_id($adapter_id);
	}
	else
	{
		$adapter_id = $this->get_adapter_id();
	}
	
	# Set the operation name on this ZipTie::Recording instance if it has been specified as an argument
	if (defined($operation_name))
	{
		$this->set_operation_name($operation_name);
	}
	else
	{
		$operation_name = $this->get_operation_name();
	}

	# Set the connection path reference on this ZipTie::Recording instance if it has been specified as an argument
	if (defined($connection_path_ref))
	{
		$this->set_connection_path($connection_path_ref);
	}
	else
	{
		$connection_path_ref = $this->get_connection_path();
	}

	# Check to see if recording is enabled
	if ( $ENV{ENABLE_RECORDING} )
	{
		# In order to enable device interaction recording, we must be able to record to a file so a directory must be
		# specified in the "RECORDING_DIR" environment variable.
		#
		# Also, there must be an adapter ID, operation name, and connection path reference specified to use for the name
		# of the file.
		if ( $ENV{RECORDING_DIR} && defined($adapter_id) && defined($operation_name) && defined($connection_path_ref) )
		{
			# Default device prompt to a pound sign if it has not been set
			if (!defined($this->get_device_prompt()))
			{
				$this->set_device_prompt("#");
			}
			
			# Modify the adapter ID to extract only a substring from the last occurence of any colons.  If the adapter ID contains
			# no colons, then the adapter ID will not be modified
			my $modified_adapter_id = $adapter_id;
			my $last_colon_index = rindex($modified_adapter_id, "::");
			if ($last_colon_index != -1)
			{
				$modified_adapter_id = substr($modified_adapter_id, $last_colon_index + length($last_colon_index));
			}
			
			# Calculate the time of the recording
			my ( $sec, $min, $hour, $day, $month, $year ) = localtime();
			my $current_time = sprintf(
				'%s-%02s-%02s_%02s-%02s-%02s',
				( $year + 1900 ),
				( $month + 1 ),
				$day,
				$hour,
				$min,
				$sec
			);
			
			# Generate the name of the recording file
			my $output_file_name = escape_filename($modified_adapter_id . "_" . $operation_name . "_" . $connection_path_ref->get_ip_address() . "_" . $current_time . ".record");
			my $abs_output_file_path = $ENV{RECORDING_DIR} . "/" . $output_file_name;
		
			open (RECORDING, ">$abs_output_file_path");
			print RECORDING "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			print RECORDING "<recording adapterId=\"".$this->get_adapter_id()."\" devicePrompt=\"".$this->get_device_prompt()."\" operationName=\"".$this->get_operation_name()."\">\n";
			print RECORDING $this->get_connection_path()->to_xml_string(1);
			
			my $interactions = { interaction => $this->get_interactions(), };
			print RECORDING XMLout($interactions, KeepRoot => 1);
			print RECORDING "</recording>\n";
			close (RECORDING);
			
			$LOGGER->debug("Successfully wrote the recording file for '" . $connection_path_ref->get_ip_address() . "' to '$abs_output_file_path'");
		}

		# Else, initializing recording was attempted, but could not happen because not all of the parameters
		# were specified
		else
		{
			$LOGGER->debug( "Attempted to write a device interaction recording to a file, but either the 'RECORDING_DIR' environment variable "
				  . "was not set or an adapter ID, adapter operation name, and connection path reference was not specified.  "
				  . "All of these conditions MUST be met in order enable device interaction recording." );
		}
	}

	# If we have reached here, then the 'ENABLE_RECORDING' has not been set properly so no recording will take place
	else
	{
		$LOGGER->debug( "Attempted to write a device interaction recording to a file, but the 'ENABLE RECORDING' environment variable "
			  . "is NOT set to a true value. It MUST be set to true, and the 'RECORDING_DIR' environment variable "
			  . "MUST also define an exisiting directory to write the device recording XML file to." );
	}
}

sub clear
{
    my $this = shift;
    
    $LOGGER->debug("Clearing out all information stored on the adapter operation recording");
    
    $this->{interaction_array_ref} = undef;
    $this->{current_interaction} = undef;
    $this->{device_prompt} = undef;
    $this->{operation_name} = undef;
    $this->{adapter_id} = undef;
    $this->{connection_path_ref} = undef;
}

1;

__END__

=head1 NAME

ZipTie::Recording - Encapsulates all of the information needed to reproduce an adapter operation that is performed against a device using
ZipTie, including essential metadata and all of the data regarding the interactions that were performed.

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
		xferFilename => "someFilename",
		xferResponse => "someSortOfResponse",
		xferAsServer => 1,
	);
	
	# Starts a new interaction on the ZipTie::Recording singleton, saving the previous interaction
	# if it had not been saved already
	$recording->start_current_interaction($xfer_interaction);
	
	# Saves the current interaction and makes way for a new interaction to be added
	$recording->finish_current_interaction();

=head1 DESCRIPTION

The C<ZipTie::Recording> module encapsulates the information needed to record an adapter operation that is performed against
a device using ZipTie.  A recording, in the context of ZipTie, contains all of the information to define the adapter
operation that took place.  Leveraging the metadata stored in a recording, one could recreate the actual adapter operation and all the device
interactions that happened, which is the purpose of the Device Simulator that is part of ZipTie.

=head1 Components Of A Recording

A recording is made up of a variety of metadata; each of these pieces of metadata, when viewed collectively,
help to define an adapter operation that was successfully executed.  A recording is not considered complete if all of these pieces
of metadata are not filled in.

=head2 Adapter ID/Name

The adapter ID/name for a recording refers to the ZipTie adapter that contains the definition/implementation of the operation that
was executed.  The ID/name of a ZipTie adapter is the full package name of the Perl module that implements the adapter.  For example,
the ZipTie adapter that implements support for the Cisco IOS device family has the adapter name/id of C<ZipTie::Adapters::Cisco::IOS>.
It is expected that the adapter ID/name match both the name of the ZipTie adapter module and that "adapterId" element defined within
the metadata XML used to define an adapter (the meta data file for an adapter I<ALWAYS> exists within the same directory as the
ZipTie adapter module itself).

Refer to the C<get_adapter_id()> and C<set_adapter_id($adapter_id)> methods for access to the adapter ID for the recording.

=head2 Operation Name

The operation name for a recording refers to the name of the operation that was execute.  The operation refers to a subroutine that is
implemented on the ZipTie adapter module that is specified by the adapter ID information.

An example of a valid operation name is C<backup> when used with the C<ZipTie::Adapters::Cisco::IOS> adapter module.  This
means that the C<backup> subroutine on the C<ZipTie::Adapters::Cisco::IOS> adapter module will be the operation that is
invoked.

Refer to the C<get_operation_name()> and C<set_operation_name($operation_name)> methods for access to the operation name for the
recording.

=head2 Connection Path

The connection path for a recording refers to all of the IP address, protocol, and credential information that was used during the recorded
adapter operation to successfully connect to and communicate with the device.

Refer to the C<get_connection_path()> and C<set_connection_path($connection_path_ref)> methods for access to the connection path for the recording.
For more information of connection paths and what they contain, please refer to the documentation for the C<ZipTie::ConnectionPath> module.

=head2 Device Prompt

The device prompt stored on a recording refers to the prompt that is on the device that the adapter operation is being performed
against.  The purpose of storing the device prompt is based on the assumption that most adapter operations that interact with a device
using a command line interface (CLI) leverage the existing device prompt to know when commands have been successfully executed.

Refer to the C<get_device_prompt()> and C<set_device_prompt($device_prompt)> methods for access to the device prompt for the
recording.

=head2 Interactions

The interactions portion of a recording refers to all of the interactions that occur between the ZipTie Perl Adapter SDK and the device
that has been specified.  The data for these interactions is encapsulated by various instances of the C<ZipTie::Recording::Interaction>
module.  The interactions take up the majority of the recording and without these interactions, the other metadata does not
mean much.  Internally, a recording keeps an array of all the interactions that have been recorded.

In order to start recording a new interaction, a user can call the C<start_current_interaction($interaction)> method, with a new
instance of the C<ZipTie::Interaction> module as the only argument.  This will mark the specified interaction as the "current"
interaction; a recording only ever cares about one interaction at a time.  This "current" interaction will B<NOT> be added to the
list of recorded interactions until it has explicitly been marked as "finished" by call the
C<finish_current_interaction()> method.

To retrieve the current interaction, a user can call the C<get_current_interaction()> method.  This will retrieve the current
that has not yet been added to the internal array of recorded interactions.

To close out the current interaction and mark it as being finished, a user can call the C<finish_current_interaction()> method.
This will add the current interaction to the internal list of recorded interactions and set the "current" interaction to be
non-existant.

B<NOTE:>  It is B<HIGHLY RECOMMENDED> that a user that is adding an interaction to the recording follows the "start, update, finish"
paradigim.  This is recommended because if you attempt to start a new interaction before finishing out the current interaction, the
current interaction will be over written.  By following the process of starting, updating, and finishing an interaction, you can
ensure that the interaction will be properly added.

Please refer to the documentation for the C<ZipTie::Recording::Interaction> module for more information and context
regarding recording and device interactions, and the "SYNPOSIS" section of this module for examples.

=head1 Singleton Instance of the C<ZipTie::Recording> Module

Through out the ZipTie Perl Adapter SDK, the C<ZipTie::Recording> module is referenced by it's singleton instance which can
be retrieved from the C<get_recording()> subroutine.  This is the chosen access mechanism because it is assumed that only one
operation will be executed through the ZipTie Perl Adapter SDK for any given Perl process.  This allows any module that is
part of the ZipTie Perl Adapter SDK to have access to the recording of the current operation.  In the future, if the ZipTie
Perl Adapter SDK is modified to run multiple operations within the same Perl process, the C<ZipTie::Recording> module
should move away from the singleton design pattern.

For examples of use of the C<ZipTie::Recording> module, refer to the "SYNOPSIS" section of this documentation, or the
C<send($input)> and C<wait_for($regex, $timeout)> methods of the C<ZipTie::CLIProtocol> module and it's implentation modules
C<ZipTie::Telnet> and C<ZipTie::SSH> can be referenced to see how the singleton instance of the C<ZipTie::Recording> module
is used to start, update, and finish an interaction everytime a CLI command is sent to a device.

=head1 Converting a Recording to XML

The contents of an instance of the C<ZipTie::Recording> module can be convert into an XML format that can be used to parse the
details of an adapter operation.  This is performed by using the C<to_file($adapter_id, $operation_name, $connection_path_ref)> method, which
convert the contents of the recording into an XML format.  Refer to its documentation to get more of a context around the internal
workings of converting a recording into XML.

=head2 C<ENABLE_RECORDING> Environment Variable

In order to actually enable recording to a file, the environment variable C<ENABLE_RECORDING> must be set.  This environment
variable represents a boolean value for deciding whether or not to enable recordings.  0 is false and 1 is true.  Currently,
this environment variable is only used in tandum with the C<RECORDING_DIR> environment variable and both do not do anything
without each other.  In the future, the C<ENABLE_RECORDING> environment variable will be used to enable or disable adapter
operation recording entirely.

=head2 C<RECORDING_DIR> Environment Variable

Once recordings have been enabled by properly setting the C<ENABLE_RECORDING> environment variable, there is one more piece
that must be set properly, and that is the C<RECORDING_DIR> environment variable.

The C<RECORDING_DIR> environment variable represents a directory path that recording XML files can be writtened to.  As
mentioned in the "C<ENABLE_RECORDING> Environment Variable" section, the C<RECORDING_DIR> environment variable is dependant
on the C<ENABLE_RECORDING> environment variable to be properly set to a true value; if it is not, then the recording file
will B<NOT> be written.

There are a few caveats associated with the directory path that is specified within the contents of the C<RECORDING_DIR>
environment variable:

=over

=item *

The directory can either be absolute or relative.

=item *

If the directory is absolute, then all of the directories that are encountered within the directory path B<must> exist.

=item *

If the directory is relative, then it will be assumed to berelative to the current working directory of Perl, which is 
typically the same directory of the main Perl script that is being executed.

=back

=head2 Name of a Recording XML File

When a recording is converted to XML to be written to file, it uses a pre-determined syntax to generate the name of the XML
file and will be placed in the directory that is specified by the C<RECORDING_DIR> environment variable.  The syntax for
the name is as follows:

	<adapterId>_<operationName>_<ipAddress>_<currentTime>.record

As outlined above, the syntax of a recording's name uses the follow information: the ID of adapter used, the name of the
operation that was performed on the adapter, the IP address of the device that the operation was performed against, the
time that recording was generated, and the extension ".record".

Here is an example of a valid recording name that would be generated:

	IOS_backup_10.100.10.10_2007-07-06_11-31-19.record

=head2 Example of a Recording XML

The following is an example of the XML document that is generated when converting a recording to XML by calling the
C<to_file($adapter_id, $operation_name, $connection_path_ref)> method:

	<?xml version="1.0" encoding="UTF-8"?>
	<recording adapterId="ZipTie::Adapters::Cisco::IOS" devicePrompt="#" operationName="backup">
	<connectionPath host="10.100.10.10" xmlns="">
        <credentials>
            <credential name="roCommunityString" value="public"/>
            <credential name="username" value="someUsername"/>
            <credential name="rwCommunityString" value="private"/>
            <credential name="enableUsername" value="someEnableUsername"/>
            <credential name="password" value="somePassword"/>
            <credential name="enablePassword" value="someEnablePassword"/>
        </credentials>
        <protocols>
            <protocol name="Telnet" port="23">
                <properties/>
            </protocol>
        </protocols>
    </connectionPath>
	<interaction asBytes="0" cliCommand="" cliProtocol="Telnet" endTime="1183499954"
		startTime="1183499954" timeout="30" waitFor="/(maximum number of telnet)|(.*)/" xferAsServer="0"
		xferProtocol="">
		<cliResponse/>
		<xferResponse/>
	</interaction>
	<interaction asBytes="0" cliCommand="" cliProtocol="Telnet" endTime="1183499954"
		startTime="1183499954" timeout="30"
		waitFor="/(maximum number of telnet)|(assword required, but none se)|(sername:)|(assword:)|(PASSCODE:)|(>\s*$)|((^|\n|\r)[^>^(\n|\r)]+>\s*$)|((^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$)|(any key)|(User Interface Menu)/"
		xferAsServer="0" xferProtocol="">
		<cliResponse>........</cliResponse>
		<xferResponse/>
	</interaction>
	<interaction asBytes="0" cliCommand="testlab" cliProtocol="Telnet" endTime="1183499954"
		startTime="1183499954" timeout="30" waitFor="/(assword:)|(PASSCODE:)|(sername:)|(invalid)/"
		xferAsServer="0" xferProtocol="" xferProtocol="">
		<cliResponse>........</cliResponse>
		<xferResponse/>
	</interaction>
	<interaction asBytes="0" cliCommand="hobbit" cliProtocol="Telnet" endTime="1183499954"
		startTime="1183499954" timeout="30"
		waitFor="/(sername:)|(assword:)|(PASSCODE:)|(invalid)|(Bad passwords)|(Authentication failed)|((\d+)\s+[Ee][Xx][Ii][Tt]\s+.*[Mm][Ee][Nn][Uu])|(>\s*$)|((^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$)|(.*#.*#)/"
		xferAsServer="0" xferProtocol="" xferProtocol="">
		<cliResponse>........</cliResponse>
		<xferResponse/>
	</interaction>
	<interaction asBytes="0" cliCommand="enable" cliProtocol="Telnet" endTime="1183499954"
		startTime="1183499954" timeout="30"
		waitFor="/(sername:)|(assword:)|(PASSCODE:)|((^|\n|\r)[^#^\n^\r]+#\s*$|[^#^\n^\r]+#\s*\S+#\s*$)/"
		xferAsServer="0" xferProtocol="" xferProtocol="">
		<cliResponse>........</cliResponse>
		<xferResponse/>
	</interaction>
	<interaction asBytes="0" cliCommand="terminal length 0" cliProtocol="Telnet" endTime="1183499954"
		startTime="1183499954" timeout="30" waitFor="/cisco2610\-LAB\#\s*$/" xferAsServer="0"
		xferProtocol="" xferProtocol="">
		<cliResponse>........</cliResponse>
		<xferResponse/>
	</interaction>

	...........................

=head1 SUBROUTINES

=over 12

=item C<get_recording()>

Retrieves the singleton instance of the C<ZipTie::Recording> module.  If the singleton instance does not yet exist, it will
be created.  This singleton instance should be the only instance C<ZipTie::Recording> module to exist within the use of
the ZipTie Perl Adapter SDK for any given Perl proccess. 

Please refer to the "Singleton Instance of the C<ZipTie::Recording> Module" section of this module's documentation for more
information regarding why the singleton design pattern was chosen for this module.

=item C<_trim($string)>

Trims any white space that is at the start and end of a specified string.  This primarily used by the
C<set_adapter_id($adapter_id)> and C<set_operation_name($operation_name)> methods to clean up any values before they are set.

=back

=head1 METHODS

=over 12

=item C<get_adapter_id()>

Retrieves the name/ID of the adapter that contains the operation that this C<ZipTie::Recording> instance is recording.
Refer to the "Adapter ID/Name" documentation of this module's documentation for more infortation regarding the adapter ID.

=item C<set_adapter_id($adapter_id)>

Sets the name/ID of the adapter that contains the operation that this C<ZipTie::Recording> instance is recording.  Any leading
or trailing whitespace will be trimmed out using the C<_trim($string)> subroutine.  Refer to the "Adapter ID/Name" documentation
of this module's documentation for more infortation regarding the adapter ID.

=item C<get_operation_name()>

Retrieves the name of the adapter operation that this C<ZipTie::Recording> instance is recording.  Refer to the "Operation Name"
documentation of this module's documentation for more infortation regarding the operation name.

=item C<set_operation_name($operation_name)>

Sets the name of the adapter operation that this C<ZipTie::Recording> instance is recording.  Any leading or trailing whitespace
will be trimmed out using the C<_trim($string)> subroutine.  Refer to the "Operation Name" documentation of this module's
documentation for more infortation regarding the operation name.

=item C<get_connection_path()>

Retrieves a reference to a C<ZipTie::ConnectionPath> object that stores all of the connection information used to connect to the device during
the adapter operation that this C<ZipTie::Recording> instance is recording.  Refer to the "Connection Path" documentation of this module's
documentation for more infortation regarding the connection path information.

=item C<set_connection_path($connection_path_ref)>

Specifies the reference to the C<ZipTie::ConnectionPath> object that stores all of the connection information used to connect to the device during
the adapter operation that this C<ZipTie::Recording> instance is recording.  Refer to the "Connection Path" documentation of this module's
documentation for more infortation regarding the connection path information.

=item C<get_device_prompt()>

Retrieves the prompt of the device that the adapter operation is performing against and that this C<ZipTie::Recording> instance is
recording.  Refer to the "Device Prompt" documentation of this module's documentation for more infortation regarding the device prompt.

=item C<set_device_prompt($device_prompt)>

Sets the the prompt of the device that the adapter operation is performing against and that this C<ZipTie::Recording> instance is
recording.  Any leading or trailing whitespace will be trimmed out using the C<_trim($string)> subroutine.  Refer to the
"Device Prompt" documentation of this module's documentation for more infortation regarding the device prompt.

=item C<start_current_interaction($new_interaction)>

Specify an instance of the C<ZipTie::Recording::Interaction> module to use as the "current" interaction on an instance of the
C<ZipTie::Recording> module.  This will also use the C<Time::HiRes::time> function to get the time in floating seconds for when
the interaction started, convert it to milliseconds and use the C<startTime($time_in_milliseconds)> method on the current interaction
to mark the starting time of the interaction. 

An instance of the C<ZipTie::Recording> module should only ever deal with one interaction at a time, and that is to be considered the
current interaction.  All previous interactions that have been recorded are stored within an internal array by closing out the current
interaction using the C<finish_current_interaction()>.  Refer to the "Interactions" section of this module's documentation for more
context around the use of interactions.

=item C<get_current_interaction()>

Retrieves the C<ZipTie::Recording::Interaction> instance that is being used as the "current" interaction.  This method is primarily
used when wanting to update the metadata around the "current" interaction.  The "current" interaction will reference the same
instance of the C<ZipTie::Recording> module until the C<finish_current_interaction()> method is called.  Refer to the "Interactions"
section of this module's documentation for more context around the use of interactions.

=item C<finish_current_interaction()>

Marks the "current" interaction that was specified by the C<start_current_interaction($new_interaction)> as being finished.
This will also use the C<Time::HiRes::time> function to get the time in floating seconds for when the interaction started, convert it
to milliseconds and use the C<endTime($time_in_milliseconds)> method on the current interaction to mark the ending time of the interaction.

This means that the "current" interaction is added to the internal array of interactions that have already been recorded and the "current"
interaction is now empty.  It is assumed that once C<finish_current_interaction()> is called that it is safe to start a new
interaction by calling the C<start_current_interaction($new_interaction)> method.  Refer to the "Interactions" section of this
module's documentation for more context around the use of interactions.

=item C<get_interactions()>

Retrieves the internal array of all the interactions that have been stored on an instance of the C<ZipTie::Recording> module.
Interactions are stored using instances of the C<ZipTie::Recording::Interaction> module.  Refer to the perl documentation for the
C<ZipTie::Recording::Interaction> module for more information about the type of information it stores.

=item C<create_xfer_interaction($protocol, $filename, $response, $as_server)>

Creats and adds a file transfer interaction to the current C<ZipTie::Recording::Interaction> singleton.  This is done
by taking the name of the transfer protocol name, the name of the file that was transfer, the contents of the file,
and whether or not ZipTie acted as the file transfer server.

This method is the equivelent of the following code:

    my $interaction = ZipTie::Recording::Interaction->new(
        xferProtocol    => $protocol,
        xferFilename    => $filename,
        xferResponse    => $response,
        xferAsServer    => $as_server,
    );
        
    $this->start_current_interaction($interaction);
    $this->finish_current_interaction();

=item C<to_file($adapter_id, $operation_name, $connection_path_ref)>

Converts the data stored on an instance of the C<ZipTie::Recording> module into an XML format and attempts to write it
to a file.  The name of the file will use the following that is outlined in detail in the "Name of a Recording XML File"
section of this module's documentation:

	<adapterId>_<operationName>_<ipAddress>_<currentTime>.record

The adapter ID, operation name, and connection path arguments only need to be specified if they have not been previously set
using the C<set_adapter_id($adapter_id)>, C<set_operation_name($operation_name)>, and C<set_connection_path($connection_path_ref> methods;
otherwise, they will need to be specified or a warning message will be logged using the C<ZipTie::Logger> module to let it
be known that they were not specified.

Arguments:

$adapter_id -		The ID of the adapter that was used.  This is optional if it has already been set by using the
					C<set_adapter_id($adapter_id)> method.

$operation_name - 	The name of the operation that was recording.  This is optional if it has already been set by using the
					C<set_operation_name($operation_name)> method.

$connection_path_ref -	The reference to the C<ZipTie::ConnectionPath> object that stores all of the connection information used to connect
						to the device during the adapter operation that this C<ZipTie::Recording> instance is recording.  This is optional if it has
						already been set by using the C<set_connection_path($connection_path_ref> method.

=item C<clear()>

Clears out any information that has been stored on the singleton instance of the C<ZipTie::Recording> object.  This includes
all of the interactions, device prompt, operation name, adapter ID, and connection path metadata.

=back

=head1 SEE ALSO

ZipTie::Recording::Interaction

ZipTie::CLIProtocol

ZipTie::Telnet

ZipTie::SSH

ZipTie::ConnectionPath

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

Contributor(s): Dylan White (dylamite@ziptie.org)
Date: Jul 3, 2007

=cut
