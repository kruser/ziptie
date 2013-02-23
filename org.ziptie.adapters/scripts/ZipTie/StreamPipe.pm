package ZipTie::StreamPipe;

use strict;

use ZipTie::CLIProtocol;
use Net::Telnet;
use Time::HiRes qw{time};

# This module is yet another implementation of the CLIProtocol.
# However unlike e.g. telnet, it does not 'talk' to a device but exposes its I/O streams to whatever wants to communicate 
# to the perl process. For example some software proxy talking to a device may use this module to execute a perl script 
# on the device.

# Specifies that ZipTie::StreamPipe is a subclass of ZipTie::CLIProtocol
our @ISA = qw(ZipTie::CLIProtocol);

sub new
{
    my $className = shift;
    my $inputPipe = shift;
    my $outputPipe = shift;

    # Initialize this instance of the class
    my $this = ZipTie::CLIProtocol->new();

    # Turn $this into a ZipTie::StreamPipe object
    bless( $this, $className );
    
    # Set the protocol name
    $this->{protocol_name} = "StreamPipe";
    
    # Specify input pipe member
    $this->{inputPipe} = $inputPipe;

    # Specify output pipe member
    $this->{outputPipe} = $outputPipe;
    
    # Default the timeout to 30 seconds
    $this->set_timeout(30);

    # Return the object
    return $this;
}

sub connect
{
    # No-op since no connection needs to happen since we already have a handle to our pipes
}

sub disconnect
{
    # No-op since no connection needs to happen since we already have a handle to our pipes
}

sub send
{
    my $this  = shift;
    my $input = shift;

    # Append a newline to the input
    $input .= "\n";
    
    # Actually send the input to the input pipe
    print($input);
}

sub send_as_bytes
{
    my $this  = shift;
    my $input = shift;
    
    # Find the length of the input and construct a valid argument for Perl's pack() function.
    # This will convert our ASCII input into hexadecimal.
    my $length = length($input);
    my $pack_arg = "H" . $length;
    my $byte_input = pack($pack_arg, $input);
    
    # Send the byte information over the pipe
    print("NO_EOL" . $byte_input);
}


sub put
{
	my $this  = shift;
    my $input = shift;
    
    # Actually send the input to the input pipe
    print("NO_EOL" . $input);
}

sub wait_for
{
    my $this  = shift;
    my $regex = shift;
    
    # If no timeout is explicitly set for this wait_for, use the 30 seconds
    my $timeout = defined(@_[0]) ? shift : 30;

    my $response = "";
    
    # Keep reading until we match the specified regular expression
    while ($response !~ /$regex/)
    {
        my $chunk = "";
        my $bytes = $this->{inputPipe}->sysread($chunk, 1024);
        if (defined($bytes))
        {
            # If forced chatter was read, remove it from the chunk that was read
            if ($chunk =~ /FORCED_CHATTER/mi)
            {
                $chunk =~ s/FORCED_CHATTER//gi;
            }
            
            # Append the chunk of data that was read to the overall response
            $response .= $chunk;
        }
    }
    
    # Check to see if we should wait for chatter also
    if ( defined $this->{wait_for_chatter} )
    {
        # Use the get_response mechanism to attempt to get an additional device chatter
        my $additionalChatter = $this->get_response(0.25);
        
        # Append the additional chatter to the response
        $response .= $additionalChatter;
    }
    
    # Return the full response that was found
    return $response;
}

sub get_response
{
    my $this  = shift;
    
    # If no timeout is explicitly set for this wait_for, set it to 5 seconds
    my $timeout = defined(@_[0]) ? shift : 5;
    
    # Store the overall response from the device that is made up from all the chatter captured from the device
    my $response = "";
    my $chatter  = "";
    
    # Wait for the specified timeout window for any chatter to be received from the device.
    # Continue to do this as long as chatter is received.
    do
    {
        # Attempt to capture chatter from the device
        $chatter = $this->_get_chatter( $timeout );

        # If chatter was received, then append it our response that makes up the overall response
        # of the device.
        if ( defined($chatter) )
        {
            $response .= $chatter;
        }
        
    } while ( defined($chatter) );
    
    # If vt102 term is on, process as that
    if (defined $this->{vt})        
    {
        my $vt = $this->{vt};
        $vt->process( $response );
        my $processedResponse = "";
        for (my $row = 1 ; $row <= $vt->rows() ; $row++ )
        {
            $processedResponse .= $vt->row_plaintext($row)."\n";
        }    
        $response = $processedResponse;
    }
    
    # Return the full response of chatter from the device
    return $response;
}

sub _get_chatter
{
    my $this  = shift;
    
    # If no timeout is explicitly set for this wait_for, set it to 5 seconds
    my $timeout = defined(@_[0]) ? shift : 5;
    
    # Store the overall response from the device that is made up from all the chatter captured from the device
    my $chatter = "";
    
    # Get the current time. This will be used to see how much time has elapsed
    my $startTime = time();
    
    # Keep reading the input pipe until we have surpassed our timeout window
    while((time() - $startTime) < $timeout)
    {
        my $chunk = "";
        
        my $bytes = $this->{inputPipe}->sysread($chunk, 1024);
        if (defined($bytes))
        {
            # If forced chatter was read, remove it from the chunk that was read
            if ($chunk =~ /FORCED_CHATTER/mi)
            {
                $chunk =~ s/FORCED_CHATTER//gi;
            }
            
            # Append the chunk to the chatter. If the chunk is empty, nothing will be appended to the chatter.
            $chatter .= $chunk;
        }
    }
    
    # If there was any chatter captured, return it; otherwise, return undef
    return ( length($chatter) > 0 ) ? $chatter : undef;
}

sub set_timeout
{
    my $this    = shift;
    my $timeout = shift;

    $this->{timeout} = $timeout;
}

sub DESTROY
{
    my $this = shift;
    $this->disconnect();
}

1;
