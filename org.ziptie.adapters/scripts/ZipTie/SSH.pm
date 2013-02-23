package ZipTie::SSH;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::Logger;

use MIME::Base64 'decode_base64';
use IPC::Run qw( start pump finish timeout );
use Time::HiRes qw(sleep);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

# Specifies that ZipTie::SSH is a subclass of ZipTie::CLIProtocol
our @ISA = qw(ZipTie::CLIProtocol);

sub new
{
	my $className = shift;

	# Initialize this instance of the class
	my $this = ZipTie::CLIProtocol->new();

	# Turn $this into a ZipTie::SSH object
	bless( $this, $className );

	# Set the protocol defaults
	$this->{protocol_name}            = "SSH";
	$this->{version}                  = undef;
	$this->{opened}                   = 0;
	$this->{handle}                   = undef;
	$this->{timeout}                  = 60;
	$this->{compression}              = 0;
	$this->{continue_with_connection} = 1;
	$this->{cache_key}                = 0;
	$this->{update_cached_key}        = 0;
	$this->{ors}	        		  = "\n";

	# Return the object
	return $this;
}

sub output_record_separator
{
	my $this = shift;
	my $newEol = shift;
	if (defined $newEol)
	{
		$this->{ors} = $newEol;
	}
	return $this->{ors};
}

sub connect
{
	my $this       = shift;
	my $ip_address = shift;
	my $port       = shift;
	my $username   = shift;
	my $password   = shift;

	$this->_set_ip_address($ip_address);

	# Make sure that if the port is not defined or less than 1, to default it to 22
	if ( !defined($port) || $port <= 0 )
	{
		$LOGGER->debug("Invalid port '$port' defined. Defaulting to port '22'.");
		$port = 22;
	}
	$this->_set_port($port);

	if ( !$this->{opened} )
	{
		if ( $username eq "" )
		{
			$LOGGER->debug("Found empty user name");
			$LOGGER->fatal_error_code( $INVALID_CREDENTIALS, $ip_address, "Authentication refused with an empty username\nAborting login..." );
		}

		my @cmd = ();
		push( @cmd, 'plink' );
		push( @cmd, '-v', '-a', '-x' );    # Verbose output, disable agent forwarding, and disable X11 forwarding
		push( @cmd, ( '-l',  $username ) ) if $username;
		push( @cmd, ( '-pw', $password ) ) if $password;
		push( @cmd, '-' . $this->{version} ) if $this->{version} =~ /^[12]$/;
		push( @cmd, '-C' ) if $this->{compression};
		push( @cmd, ( '-P', $this->{port} ) );
		push( @cmd, $ip_address );

		# Connect to the device
		$LOGGER->debug("About to connect to $ip_address over port $port ...");
		eval { $this->{handle} = start \@cmd, \$this->{in}, \$this->{out}, \$this->{err}, ( $this->{timer} = timeout( $this->{timeout} ) ); };
        if ($@)
        {
        	$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Could not make connection to device because plink process couldn't be started!\n[DETAILED ERROR MESSAGE]\n$@" );
        }
        
		my ( $have_version, $started, $store_key_prompt, $update_cached_key_prompt, $continue_with_connection_prompt ) = ( 0, 0, 0, 0, 0 );
		my $errorBuffer = '';
		while ( !$have_version || !$started )
		{
			if (length($this->{err}) <= 0)
			{
				eval { $this->{handle}->pump until length($this->{err}) > 0; };
				if ($@)
				{
					$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Could not make connection to device because plink produced an unexpected response!\n[DETAILED ERROR MESSAGE]\n$@" );
				}
			}
			$errorBuffer .= $this->{err};
			$LOGGER->debug( $this->{err} );
			$this->{err} = '';

			if ( !$have_version && $errorBuffer =~ /Using SSH protocol version (\d+)/ )
			{
				$have_version = 1;
				$this->{version} = $1;
			}
			if ( !$store_key_prompt && $errorBuffer =~ /Store key in cache/ )
			{
				$store_key_prompt = 1;
				$this->send( $this->{cache_key} ? "y" : "n" );
			}
			if ( !$update_cached_key_prompt && $errorBuffer =~ /Update cached key/ )
			{
				$update_cached_key_prompt = 1;
				$this->send( $this->{update_cached_key} ? "y" : "n" );
			}
			if ( !$continue_with_connection_prompt && $errorBuffer =~ /Continue with connection/ )
			{
				$continue_with_connection_prompt = 1;
				$this->send( $this->{continue_with_connection} ? "y" : "n" );
			}
			if ( !$started && $errorBuffer =~ /Started session|Started a shell/i )
			{
				$started = 1;
				$this->{err} = '';
			}
			elsif ( !$started && $errorBuffer =~ /Authentication refused/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Authentication refused";
				$LOGGER->fatal_error_code( $INVALID_CREDENTIALS, $ip_address, "Authentication refused" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /Connection refused/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Connection refused";
				$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Connection refused" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /'plink' is not recognized|plink:\s+command not found/ )
			{
				$this->{opened} = 0;
				$! =
				    "[ZipTie::SSH::connect] plink executable was not found in the system path!\n"
				  . "The system path contains the following locations: '"
				  . $ENV{PATH} . "'";
				$LOGGER->fatal(
					"plink executable was not found in the system path!\n" . "The system path contains the following locations: '" . $ENV{PATH} . "'" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /Connection timed out/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Connection timed out";
				$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Connection timed out" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /Unable to authenticate|password:\s*$/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Unable to authenticate";
				$LOGGER->fatal_error_code( $INVALID_CREDENTIALS, $ip_address, "Unable to authenticate" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /Fatal:|Fatal error:/i )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Fatal error encountered in plink!";
				$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Fatal error encounted!\n" . $errorBuffer );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /Host does not exist/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Host does not exist";
				$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Host does not exist" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /Disconnected/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Disconnected!";
				$LOGGER->fatal_error_code( $SSH_ERROR, $ip_address, "Disconnected prematurely" );
				last;
			}
			elsif ( !$started && $errorBuffer =~ /unknown option/ )
			{
				$this->{opened} = 0;
				$! = "[ZipTie::SSH::connect] Unknown option passed into plink!";
				$LOGGER->fatal( "Unknown option passed into plink!\n" . $errorBuffer );
				last;
			}
		}

		# For debugging purposes, display the version of SSH that is being used to connect to the device
		$LOGGER->debug( "Connected successfully to $ip_address over port $port using the SSH version " . $this->{version} );
		$this->{opened} = 1;
	}
}

sub disconnect
{
    my $this = shift;

    # Tear down the IPC::Run harness
    if ( $this->{handle} )
    {
        $LOGGER->debug("Tearing down IPC::Run harness used to communicate with plink.");

        # Pump out all of the output that may be waiting around for 1 second
        eval {
            $this->{timer}->start(1);
            $this->{handle}->pump until $this->{out} =~ /.*/;
        };
        if ($@)
        {
            $LOGGER->debug("Unable to read the rest of the output from plink.  Ignoring ...");
        }
        
        eval {
            $LOGGER->debug("Finishing the IPC::Run harness ...");
            $this->{handle}->finish;
            $LOGGER->debug("Killing off any child processes associated with the IPC::Run harness ...");
            $this->{handle}->kill_kill;
        };
        if ($@)
        {
            $LOGGER->debug("Error on finishing off the IPC::Run harness, so killing everything instead ...");

            # Kill this process with only a 1 second grace period
            $this->{handle}->kill_kill( grace => 1 );
        }

        # Mark that the IPC::Run harness has been shutdown and the connection to the device closed
        $this->{opened} = 0;
    }
}

sub send
{
	my $this  = shift;
	my $input = shift;

	# Clear out the buffer so that no previous messages pollute it
	$this->_empty_buffers;
	if ( ref $this->{vt} )
	{
		$this->{vt}->reset();
	}

	# Check to see if recording is enabled
	if ( $ENV{ENABLE_RECORDING} )
	{

		# See if we have a valid current interaction already.
		# If so, it needs to be closed out.  Mark that we have finished the current interaction.
		my $current_interaction = $RECORDING->get_current_interaction();
		if ( defined($current_interaction) )
		{
			$RECORDING->finish_current_interaction();
		}

		# Start the current interaction.  Right now, all it knows about it the command being executed,
		# what protocol is being used, whether or not the command is being sent as bytes, and
		# when the command was sent.
		my $interaction = ZipTie::Recording::Interaction->new(
			cliCommand  => $input,
			cliProtocol => $this->get_protocol_name(),
			asBytes     => 0
		);
		$RECORDING->start_current_interaction($interaction);
	}

	# Store the current input on the object.  This will make the current input be registered as the last
	# input that was sent
	$this->{input} = $input;

	# Send the input to the device and append any necessary CRLF data to the end of the input.
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[SENDING]");
	$LOGGER->debug($input);
	$LOGGER->debug("-----------------------------------------------------------------------------");
	if ( $this->{send_chars_separately} )
	{
		my @chars = split( '', $input );
		foreach my $char (@chars)
		{
			$this->put($char);
		}
		$this->put($this->{ors});
	}
	else
	{
		$this->{in} .= $input . $this->{ors};
		eval {
			while ( $this->{in} )
			{
				$this->{handle}->pump;
			}
		};
	}
}

sub put
{
	my $this  = shift;
	my $input = shift;

	# Clear out the buffer so that no previous messages pollute it
	$this->_empty_buffers();
	if ( ref $this->{vt} )
	{
		$this->{vt}->reset();
	}

	# Check to see if recording is enabled
	if ( $ENV{ENABLE_RECORDING} )
	{

		# See if we have a valid current interaction already.
		# If so, it needs to be closed out.  Mark that we have finished the current interaction.
		my $current_interaction = $RECORDING->get_current_interaction();
		if ( defined($current_interaction) )
		{
			$RECORDING->finish_current_interaction();
		}

		# Start the current interaction.  Right now, all it knows about it the command being executed,
		# what protocol is being used, whether or not the command is being sent as bytes, and
		# when the command was sent.
		my $interaction = ZipTie::Recording::Interaction->new(
			cliCommand  => $input,
			cliProtocol => $this->get_protocol_name(),
			asBytes     => 0
		);
		$RECORDING->start_current_interaction($interaction);
	}

	# Store the current input on the object.  This will make the current input be registered as the last
	# input that was sent
	$this->{input} = $input;

	# Send the input to the device through a put, i.e. without CRLF
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[PUTTING]");
	$LOGGER->debug($input);
	$LOGGER->debug("-----------------------------------------------------------------------------");
	if ( $this->{send_chars_separately} )
	{
		my @chars = split( '', $input );
		foreach my $char (@chars)
		{
			$this->{in} .= $char;
			eval { $this->{handle}->pump until !length( $this->{in} ) };
		}
	}
	else
	{
		$this->{in} .= $input;
		while ( $this->{in} )
		{
			$this->{handle}->pump_nb;
		}
	}
}

sub send_as_bytes
{
	my $this  = shift;
	my $input = shift;

	# Clear out the buffer so that no previous messages pollute it
	if ( ref $this->{vt} )
	{
		$this->{vt}->reset();
	}

	# Find the length of the input and construct a valid argument for Perl's pack() function.
	# This will convert our ASCII input into hexadecimal.
	my $length     = length($input);
	my $pack_arg   = "H" . $length;
	my $byte_input = pack( $pack_arg, $input );

	# Check to see if recording is enabled
	if ( $ENV{ENABLE_RECORDING} )
	{

		# See if we have a valid current interaction already.
		# If so, it needs to be closed out.  Mark that we have finished the current interaction.
		my $current_interaction = $RECORDING->get_current_interaction();
		if ( defined($current_interaction) )
		{
			$RECORDING->finish_current_interaction();
		}

		# Start the current interaction.  Right now, all it knows about it the command being executed,
		# what protocol is being used, whether or not the command is being sent as bytes, and
		# when the command was sent.
		my $interaction = ZipTie::Recording::Interaction->new(
			cliCommand  => $input,
			cliProtocol => $this->get_protocol_name(),
			asBytes     => 1
		);
		$RECORDING->start_current_interaction($interaction);
	}

	# Store the current input on the object.  This will make the current input be registered as the last
	# input that was sent
	$this->{input} = $input;

	# Send the input to the device without appending any special CRLF information.  The command
	# interpreter on the device should automatically know what to do with the sequence of bytes
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[SENDING BYTE(S) (showing hexadecimal value)]");
	$LOGGER->debug($input);
	$LOGGER->debug("-----------------------------------------------------------------------------");
	$this->put($byte_input);
}

sub wait_for
{
	my $this  = shift;
	my $regex = shift;

	# If no timeout is explicitly set for this wait_for, use the global timeout
	my $timeout = defined( @_[0] ) ? shift: $this->get_timeout();

	# Make sure to append Perl matching metacharcters for the regular expression if they don't already
	# exist on there
	unless ( $regex =~ m(^\s*/) or $regex =~ m(^\s*m\s*\W) )
	{
		$regex .= "|" . $this->{more_prompt}->{prompt} if ( defined $this->{more_prompt} );
	}

	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug( "[WAITING " . $timeout . " SECOND(S) FOR]" );
	$LOGGER->debug($regex);
	$LOGGER->debug("-----------------------------------------------------------------------------");

	my $startTime = time();
	my $start     = "Started waiting at: " . scalar localtime($startTime);

	# Wait for the response from the device
	$this->{timer}->start($timeout);
	eval { $this->{handle}->pump until $this->{out} =~ /$regex/; };

	# Handle any potential timeout
	if ($@)
	{
		$this->disconnect();
		$start .= " -- Ended waiting at: " . scalar localtime( time() ) . " -- ";
		my $ip_address      = $this->get_ip_address();
		my $actual_command  = $this->last_input();
		my $actual_response = $this->{out};
		my $error_message .= "timed-out after $timeout seconds ($start) while waiting to match the regular expression '$regex'.\n";
		$error_message .= "[INPUT]\n$actual_command\n" unless ( !defined($actual_command) || !$actual_command );
		$error_message .= "[ACTUAL RESPONSE]\n$actual_response";
		$LOGGER->fatal_error_code( $UNEXPECTED_RESPONSE, $ip_address, $error_message );
	}

	# We want to know the entire response from the device for a given input, not just what was matched
	my $response = $this->{out};

	# Check to see if we should wait for chatter also
	if ( defined $this->{wait_for_chatter} )
	{
		$LOGGER->debug("Start waiting for device chatter after successful wait for ...");

		# Use the get_response mechanism to attempt to get an additional device chatter
		my $additionalChatter = $this->get_response($this->{wait_for_chatter});

		# Append the additional chatter to the response
		$response .= $additionalChatter;

		$LOGGER->debug("Finished waiting for device chatter after successful wait for.");
	}

	# if the more prompt was matched, send the more action and waitfor again
	if ( defined $this->{more_prompt} )
	{
		if ( $response =~ /$this->{more_prompt}->{prompt}/ )
		{
			###########################################################################################################
			#
			#    End this interaction, both for debugging and recording purposes since we are about to short-circuit
			#    the wait-for logic to send a new command.
			#
			###########################################################################################################

			$LOGGER->debug("-----------------------------------------------------------------------------");
			$LOGGER->debug("[RESPONSE]");
			$LOGGER->debug($response);
			$LOGGER->debug("-----------------------------------------------------------------------------");

			# Check to see if recording is enabled
			if ( $ENV{ENABLE_RECORDING} )
			{

				# See if we have a valid current interaction or not.  If not, a new one needs to be created.
				my $current_interaction = $RECORDING->get_current_interaction();
				if ( !defined($current_interaction) )
				{

					# Start a new interaction.  Right now, all it knows about it the command being executed,
					# what protocol is being used, whether or not the command is being sent as bytes, and
					# when the command was sent.
					$current_interaction = ZipTie::Recording::Interaction->new(
						cliCommand  => "",
						cliProtocol => $this->get_protocol_name(),
						asBytes     => 0
					);
					$RECORDING->start_current_interaction($current_interaction);
				}

				# The current interaction needs to be closed out.
				# Mark the wait for prompt, the timeout value, and the response.
				$current_interaction->waitFor($regex);
				$current_interaction->timeout($timeout);
				$current_interaction->cliResponse($response);

				# Mark that we have finished the current interaction.
				$RECORDING->finish_current_interaction();
			}

			###########################################################################################################

			# Send the byte info to progress past the more prompt
			$this->send_as_bytes( $this->{more_prompt}->{action} );

			# Append the next wait for to this response
			$response .= $this->wait_for($regex);
			$this->{match} = $response;

			# Return the result
			return $this->{match};
		}
	}

	# if vt102 term is on, process as that
	if ( defined $this->{vt} )
	{
		my $vt = $this->{vt};
		$vt->process($response);
		$this->{match} = "";
		for ( my $row = 1 ; $row <= $vt->rows() ; $row++ )
		{
			$this->{match} .= $vt->row_plaintext($row) . $this->{ors};
		}
	}
	else
	{
		$this->{match} = $response;
	}

	$LOGGER->debug("-----------------------------------------------------------------------------");
	$LOGGER->debug("[RESPONSE]");
	$LOGGER->debug( $this->{match} );
	$LOGGER->debug("-----------------------------------------------------------------------------");

	# Check to see if recording is enabled
	if ( $ENV{ENABLE_RECORDING} )
	{

		# See if we have a valid current interaction or not.  If not, a new one needs to be created.
		my $current_interaction = $RECORDING->get_current_interaction();
		if ( !defined($current_interaction) )
		{

			# Start a new interaction.  Right now, all it knows about it the command being executed,
			# what protocol is being used, whether or not the command is being sent as bytes, and
			# when the command was sent.
			$current_interaction = ZipTie::Recording::Interaction->new(
				cliCommand  => "",
				cliProtocol => $this->get_protocol_name(),
				asBytes     => 0
			);
			$RECORDING->start_current_interaction($current_interaction);
		}

		# The current interaction needs to be closed out.
		# Mark the wait for prompt, the timeout value, and the response.
		$current_interaction->waitFor($regex);
		$current_interaction->timeout($timeout);
		$current_interaction->cliResponse($response);

		# Mark that we have finished the current interaction.
		$RECORDING->finish_current_interaction();
	}

	# Return the result
	return $this->{match};
}

sub get_response
{
	my $this = shift;

	# If no timeout is explicitly set for this wait_for, set it to 5 seconds
	my $timeout = defined( @_[0] ) ? shift: 5;

	# Store the overall response from the device that is made up from all the chatter captured from the device
	my $response = "";
	my $chatter  = "";

	# Wait for the specified timeout window for any chatter to be received from the device.
	# Continue to do this as long as chatter is received.
	do
	{
		$LOGGER->debug("-----------------------------------------------------------------------------");
		$LOGGER->debug( "[WAITING " . $timeout . " SECOND(S) FOR CHATTER]" );

		# Attempt to capture chatter from the device
		$chatter = $this->_get_chatter($timeout);

		# If chatter was received, then append it our response that makes up the overall response
		# of the device.
		if ( defined($chatter) )
		{
			$LOGGER->debug("[CHATTER RECEIVED]");
			$LOGGER->debug($chatter);
			$LOGGER->debug("-----------------------------------------------------------------------------");

			$response .= $chatter;
		}
	} while ( defined($chatter) );

	# Now the the chatter has stopped and no errors occurred, return the overall response
	$LOGGER->debug( "[NO CHATTER RECEIVED WITHIN " . $timeout . " SECOND(S)]" );

	# if vt102 term is on, process as that
	if ( defined $this->{vt} )
	{
		my $vt = $this->{vt};
		$vt->process($response);
		my $processedResponse = "";
		for ( my $row = 1 ; $row <= $vt->rows() ; $row++ )
		{
			$processedResponse .= $vt->row_plaintext($row) . $this->{ors};
		}
		$response = $processedResponse;
		$LOGGER->debug($response);
	}
	$LOGGER->debug("-----------------------------------------------------------------------------");

	return $response;
}

sub version
{
	my $this    = shift;
	my $version = shift;

	if ( defined $version )
	{
		( $this->{version} ) = $version =~ /(\d+)/;
	}
	return $this->{version};
}

sub set_timeout
{
	my $this    = shift;
	my $timeout = shift;

	$this->{timeout} = $timeout;
}

sub _get_chatter
{
	my $this = shift;

	# If no timeout is explicitly set for this wait_for, set it to 5 seconds
	my $timeout = defined( @_[0] ) ? shift: 5;

	# Store the overall response from the device that is made up from all the chatter captured from the device
	my $chatter = "";

	# Get the current time. This will be used to see how much time has elapsed
	my $startTime = time();

	# Keep reading from the device until we have surpassed our timeout window
	$this->{timer}->start($timeout);
	eval {
		while (1)
		{
			$this->{handle}->pump;
		}
	};
	$chatter = $this->{out};
	$this->_empty_buffers;

	# If there was any chatter captured, return it; otherwise, return undef
	return ( length($chatter) > 0 ) ? $chatter : undef;
}

sub _empty_buffers
{
	my $this = shift;
	$this->{out} = '';
	$this->{err} = '';
}

sub DESTROY
{
	# Preserve any pre-existing error message stored in the $@ sign, since
	# disconnect might over-ride what's already stored in there
	my $err = $@;

	my $this = shift;

	# Disconnect from the device
	$this->disconnect();

	# Restore any pre-existing error message
	$@ = $err;
}

1;

__END__

=head1 NAME

ZipTie::SSH - SSH implementation of the ZipTie::CLIProtocol interface/abstract class.

=head1 SYNOPSIS

	use ZipTie::CLIProtocol;
	use ZipTie::CLIProtocolFactory;

	my $ssh = ZipTie::CLIProtocolFactory::create("SSH", "10.10.10.10", 22);
	$ssh->connect($ssh->get_ip_address(), $ssh->get_port(), "joebob", "thisismypassword");

=head1 DESCRIPTION

C<ZipTie::SSH> provides an SSH implementation of the C<ZipTie::CLIProtocol> interface/abstract class.
It leverages the implemented methods from C<ZipTie::CLIProtocol> and utilizes IPC::Run to interact with
PuTTy's plink program.

=head1 METHODS

Please refer to the "METHOD" section of the C<ZipTie::CLIProtocol> documentation to know what methods
there are and how they are used.  Any additional documentation to methods that have their own unique
implementation for SSH purposes will be documented below.

=over 12

=item C<new()>

Creates a new instance of the C<ZipTie::SSH> class with a default timeout value of 30 seconds.
While this constructor method can be called on its own, it is recommend that the C<ZipTie::CLIProtocolFactory>
and its C<create> method be used for creating objects based off of the C<ZipTie::CLIProtocol> class.

=item C<connect($ip_address, $port, $username, $password)>

Connects to a device at a specified IP address and port.  A username and password may also
be specified since some SSH implementations may have a need for it when connecting to a device.

$ip_address -	The administrative IP address of the device.

$port -			The port to connect to on the device.

$username -		The username credential to authenticate with the device.

$password -		The password credential to authenticate with the device.

=item C<disconnect()>

Disconnects from the device this C<ZipTie::SSH> object is already connected to.

=item C<send($input)>

Sends an input string to the device.  In order to retrieve the output, it is expected that the user
will call C<wait_for()> method with a valid regular expression after the call to C<send()>.

=item C<put($input)>

Same as C<send> except that no line separator, e.g. a CRLF, is appended to the $input.

=item C<send_as_bytes($input)>

Converts an input string into a hexadecimal byte representation and sends it to the device.
Unlike C<send()>, C<send_as_bytes()> will not append any special CRLF character/bytes to the end of the input.
The input will simply be converted into hexadecimal and will be sent as is.  It is expected that the
command interpreter on the device should know how to handle the byte information coming in.

In order to retrieve the output, it is expected that the user will call C<wait_for()> with a valid regular 
expression after the call to C<send_as_bytes()>.

=item C<set_timeout($timeout)>

Set the length (in seconds) for how long the C<wait_for()> method should wait on a response from a
device before timing out.  This time out value will only be used if the the C<wait_for()> method is used
with the matching regular expression as its only parameter.

=item C<wait_for($regex, $timeout)>

Waits for the response from a device and checks to see if the response matches a specified regular expression.
If a match is found, all of the response preceeding AND including the match will be returned.  It is assumed
that this function will be called directly after a call to send().

$regex -	A valid regular expression to match the response from the device.

$timeout -	Optional.  Specifies the amount of time (in seconds) to wait for a response from the device.
			If this parameter is specified, the timeout specified by a call to C<set_timeout()> will be ignored
			for this function call only.

=item C<get_response($timeout)>

Waits a specified window of time for a response to come back from the device.  Given a window of time, if any data
is sent from the device, it will be collected and stored as part of the overall response from the device.  If the window
of time goes by without any response from the device, it is then assumed that the device is done responding and the
overall response will be returned.

The use of C<get_response($timeout)> might be desireable over C<wait_for($regex, $timeout)> if there is not a particular
part of the response from a device you are waiting for, or if the response from a device comes back in an unexpected
format/flow.

$timeout -	Optional; 5 seconds by default.  Specifies the a window of time (in seconds) to wait for a response
			from the device.

=item C<version($version)>

Get or set the version for SSH to use.  If the $version arg is not provided, this method simply returns the current version.
Valid version values are 'auto', '1' or '2'.

Note that if you set the version after the SSH connection has been established, it obviously has no impact.

=item C<output_record_separator($charSequence)>

Set or get the output record separator.  The $charSequence argument is optional.  If no argument is given, this method
simply returns the current value of the output record separator, such as a CR or CRLF.

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

Contributor(s): dwhite
Date: May 8, 2007

=cut
