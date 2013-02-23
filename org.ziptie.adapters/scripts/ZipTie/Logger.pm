package ZipTie::Logger;

use strict;
use warnings;
use MIME::Base64 qw(encode_base64);

use Carp qw(confess croak);

# Define all of the error codes that can be used
our $UNEXPECTED_RESPONSE = "UNEXPECTED_RESPONSE";
our $INVALID_CREDENTIALS = "INVALID_CREDENTIALS";
our $SSH_ERROR = "SSH_ERROR";
our $TELNET_ERROR = "TELNET_ERROR";
our $SNMP_ERROR = "SNMP_ERROR";
our $FTP_ERROR = "FTP_ERROR";
our $HTTP_ERROR = "HTTP_ERROR";
our $SCP_ERROR = "SCP_ERROR";
our $TFTP_ERROR = "TFTP_ERROR";
our $TOO_MANY_USERS = "TOO_MANY_USERS";
our $PASSWORD_REQUIRED_BUT_NOT_SET = "PASSWORD_REQUIRED_BUT_NOT_SET";
our $DEVICE_MEMORY_ERROR = "DEVICE_MEMORY_ERROR";
our $NVRAM_CORRUPTION_ERROR = "NVRAM_CORRUPTION_ERROR";
our $INSUFFICIENT_PRIVILEGE = "INSUFFICIENT_PRIVILEGE";

# Export all of the error codes that could be used
use Exporter qw(import);
our @EXPORT = qw($UNEXPECTED_RESPONSE $INVALID_CREDENTIALS $SSH_ERROR $TELNET_ERROR $SNMP_ERROR $FTP_ERROR $HTTP_ERROR $SCP_ERROR $TFTP_ERROR $TOO_MANY_USERS $PASSWORD_REQUIRED_BUT_NOT_SET $DEVICE_MEMORY_ERROR $NVRAM_CORRUPTION_ERROR $INSUFFICIENT_PRIVILEGE);

# Set a logging level for displaying debug messages.  If the logging level set on the logger is higher than this debug log level,
# then do not log debug messages.
use constant DEBUG_LOGGING_LEVEL => 0;
use constant FATAL_LOGGING_LEVEL => 1;

# Create our singleton object
my $_singleton;

sub get_logger
{
	# Unless the singleton object already exists, create a new one
	unless (defined $_singleton)
	{
		# Initialize the singleton instance of the class
		$_singleton = {
			_file_name   => undef,
			_file_handle => undef,
			_logging_level => undef,
		};
	
		# Turn our singleton into a ZipTie::Logger object
		bless( $_singleton, "ZipTie::Logger" );
		
		# By default, let's log to STDERR
		$_singleton->{_file_handle} = \*STDERR;
		
        # Enable auto-flushing so that messages are immediately written to the log file
        my $prev_file_handle = select STDERR;
        $| = 1;
        select $prev_file_handle;
		
		# Check the "ADAPTER_LOGGING_LEVEL".  If the logging level is not set through the ADAPTER_LOGGING_LEVEL
		# environment variable then default to logging on FATAL messages.
		$_singleton->{_logging_level} = defined($ENV{ADAPTER_LOGGING_LEVEL}) ? $ENV{ADAPTER_LOGGING_LEVEL} : FATAL_LOGGING_LEVEL;
	}

	# Return our singleton instance
	return $_singleton;
}

sub enable_logging_to_file
{
	my $this = shift;
	
	# Check to see if an adapter ID, adapter operation name, and IP address are specified
	my $adapter_id = shift;
	my $operation_name = shift;
	my $ip_address = shift;
	
	# Check to see if we should log to a file at all
	if ($ENV{ADAPTER_LOG_TO_FILE})
	{
		# In order to log to a file, a directory must be specified in the "ADAPTER_LOG_DIR" environment variable.
		#
		# Also, there must be an adapter ID, operation name, and IP address specified to use for the name
		# of the file.
		if (defined($ENV{ADAPTER_LOG_DIR}) && defined($adapter_id) && defined($operation_name) && defined($ip_address))
		{
			# Modify the adapter ID to extract only a substring from the last occurence of any colons.  If the adapter ID contains
			# no colons, then the adapter ID will not be modified
			my $modified_adapter_id = $adapter_id;
			my $last_colon_index = rindex($modified_adapter_id, "::");
			if ($last_colon_index != -1)
			{
				$modified_adapter_id = substr($modified_adapter_id, $last_colon_index + length($last_colon_index));
			}
			
			# Make sure to trim the operation name
			_trim($operation_name);
			
			# Make sure to trim the IP address
			_trim($ip_address);
			
			# Modify the IP address to take out any colons that would exist in an IPv6 address
			my $modified_ip = $ip_address;
			$modified_ip =~ s/:+/-/g;
			
			# Construct the file name
			$this->{_file_name} = $ENV{ADAPTER_LOG_DIR} . "/" . $modified_adapter_id . "_" . $operation_name . "_" . $modified_ip . ".log";
			
			# Open the log file if it already exists for appending,
			# or create a new file if it doesn't exist
			$this->{_file_handle} = \*LOG_FILE;
			my $open_status = open( $this->{_file_handle}, ">>$this->{_file_name}" );
			if ( !$open_status )
			{
				confess("Unable open/create '$this->{_file_name}' for logging purposes!");
			}
		
		 	# Enable auto-flushing so that messages are immediately written to the log file
			my $prev_file_handle = select LOG_FILE;
			$| = 1;
			select $prev_file_handle;
		}
		
		# Else, enabling logging to a file was attempted, but could not happen because not all of the parameters
		# were specified
		else
		{
			$this->debug("Attempted to log to a file, but either the 'ADAPTER_LOG_DIR' environment variable "
			. "was not set or an adapter ID, adapter operation name, and IP address was not specified.  "
			. "All of these conditions MUST be met in order to log to a file.  Defaulting to STDERR.");
		}
	}
	
	# If we have reached here, then the 'ADAPTER_LOG_TO_FILE' environment variable has not been set so there is
	# no way to log to a file.
	else
	{
		$this->debug("Attempted to log to a file, but the 'ADAPTER_LOG_TO_FILE' environment variable "
			. "is NOT set to a true value.  It MUST be set to true, and the 'ADAPTER_LOG_DIR' environment variable "
			. "MUST also define an exisiting directory to write the log file to.");
	}
}

sub debug
{
	my $this = shift;
	my $message = shift;
	my $context = shift;
	
	# If our logging level is at or below the debug level, then enable debug logging
	if ($this->{_logging_level} <= DEBUG_LOGGING_LEVEL)
	{
		# Grab the package name of the module calling this method if the context was not explicity specified
		if ( !defined($context) )
		{
			$context = caller();
		}
	
		# Log the message
		$this->_log( $message, $context );
	}
}

sub fatal_error_code
{
	my ($this, $errorCode, $ip, $actualResponse) = @_;
	my $fatal_message = "ERROR: $errorCode encountered on the device '$ip'\n";
	$fatal_message .= "[RESPONSE FROM THE DEVICE]\n$actualResponse";
	$this->fatal($fatal_message);
}

sub fatal
{
	my $this    = shift;
	my $message = shift;
	my $context = shift;
	
	# Grab the package name of the module calling this method if the context was not explicity specified
	if ( !defined($context) )
	{
		$context = caller();
	}

	# Log the message and stack trace by using the stellar Carp module
	$this->_log( Carp::shortmess($message), $context );
		
	# Croak with the error message that (may have been) logged
	croak($message);
}

sub set_logging_level
{
	my $this = shift;
	if (@_)
	{
		$this->{_logging_level} = shift;
	}
}

sub _log()
{
	my $this = shift;
	my $message = shift;
	my $context = shift;
	
	# Calculate the current time
	my ( $sec, $min, $hour, $day, $month, $year ) = localtime();
	my $current_time = sprintf(
		'%s-%02s-%02s %02s:%02s:%02s',
		( $year + 1900 ),
		( $month + 1 ),
		$day,
		$hour,
		$min,
		$sec
	);

	# Generate debug prefix
	my $prefix = $current_time . " [" . $context . "] ";

	# Append the prefix to any new line in the message
	my $constructed_message = $prefix . $message;
	$constructed_message =~ s/\n/\n$prefix/g;
	$constructed_message =~ s/\r//g;
	
	# Special case: To interact with the ZipTie PerlServer.pl, all log messages must have the identifier
	# "=== ps log" prepended to them in order to be handled correctly.  The "__GUID" environment variable
	# can be examined to determine if this prepending needs to occur.
	if (!defined($_singleton->{_file_name}))
	{
		# As to not have any bogus characters fed into PerlServer.pl, use Base64 to encode our log message
		my $encoded_message = encode_base64($constructed_message);
		
		# Ensure that our Base64 encoded message gets represented as one long string, and is not split up
		# across multiple lines since ZipTie's PerlServer can only read a line at a time.
		$encoded_message =~ s/\n//g;
		
		# Prepend our "=== ps log" identifier to our nicely encoded message and store it as our constructed string
		$constructed_message = "=== ps log " . $encoded_message;
	}

	# Print out to the log file
	my $log_file_handle = $this->{_file_handle};
	print $log_file_handle $constructed_message, "\n";
}

sub DESTROY
{
	my $this = shift;

	# Close the file handle
	close( $this->{_file_handle} ) if defined($this->{_file_handle});
	undef $this->{_file_handle};
	
	# Undefine the singleton
	undef $_singleton;
}

sub _trim
{
	# Remove leading and trailing whitespace
	my $string = shift;
	
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	
	return $string;
}

1;

__END__

=head1 NAME

ZipTie::Logger - Logging utility used exclusively by the ZipTie Perl Adapter SDK to log debug and fatal messages.

=head1 SYNOPSIS

	use ZipTie::Logger;

	my $logger = ZipTie::Logger::get_logger();
	$logger->enable_logging_to_file($adapter_id, $operation_name, $ip_address);
	$logger->debug("Test debug message");
	$logger->set_logging_level(1);
	$logger->fatal("Something extremely bad happened, so we are dying.");

=head1 DESCRIPTION

C<ZipTie::Logger> is a simple logging utility that is used exclusively by the ZipTie Perl Adapter SDK to log debug or fatal
messages or events to C<STDERR> or to a file on the local file system.  Implementing a singleton pattern, a call to the
C<get_logger()> method will either create or return the existing singleton of the C<ZipTie::Logger> module.  By default,
all logging will happen to C<STDERR>, but logging to a file can be enabled via the
C<enable_logging_to_file($adapter_id, $operation_name, $ip_address)> method.  This method will attempt to set up logging to
a file by checking to see if C<ADAPTER_LOG_TO_FILE> environment variable exists and is set to a true value.  If this is the
case, then the C<ADAPTER_LOG_DIR> environment variable will be checked for a directory to write the file to.
If the C<ADAPTER_LOG_TO_FILE> environment variable does not exist or does not contain anything, then all logged messages will
be sent to C<STDERR>.  If everything is satisfied, then a file with the syntax of $adapter_id_$operation_name_$ip_address.log
will be use as the log file and will be written to the directory specified.

There are two ways to use the logger: Either you can simply log messages a file using the C<debug($message, $context)> 
method, or you can log an fatal message to the log and have the Perl process exited by using the C<fatal($message, $context)>.

You can also determine whether or not to display debug log messages by setting a logging level.  If the logging level is
less than or equal to zero (0), then both DEBUG and FATAL messages will be logged; otherwise, only FATAL messages will be
logged.  The logging level can be set in two ways: either programatically using the C<set_logging_level($logging_level)>
method, or through the "ADAPTER_LOGGING_LEVEL" environment variable.  If set programatically, the value will override the one
that may be specified through the "ADAPTER_LOGGING_LEVEL" environment variable.

=head1 SUBROUTINES

=over 12

=item C<get_logger()>

If a singleton instance of the C<ZipTie::Logger> class has not been created, then it will be.  Otherwise,
the existing singleton object will be returned.  When created for the first time, the singleton will default to logging
to C<STDERR>.  Logging to a file can be enabled via the C<enable_logging_to_file($adapter_id, $operation_name, $ip_address)>
method.  Also, the "ADAPTER_LOGGING_LEVEL" environment variable will be examined to see if it exists and if it contains anything
valid; if so, this will be the logging level used - otherwise, the logging level will default to zero (0), enabling both
DEBUG and FATAL messages.

=item C<_trim($string)>

Trims any white space that is at the start and end of a specified string.

=back

=head1 PUBLIC METHODS

=over 12

=item C<enable_logging_to_file($adapter_id, $operation_name, $ip_address)>

Attempts to set up logging to a file by checking to see if C<ADAPTER_LOG_TO_FILE> environment variable exists and is set to a true value.  If this is the
case, then the C<ADAPTER_LOG_DIR> environment variable will be checked for a directory to write the file to.
If the C<ADAPTER_LOG_TO_FILE> environment variable does not exist or does not contain anything, then all logged messages will
be sent to C<STDERR>.  If everything is satisfied, then a file with the syntax of $adapter_id_$operation_name_$ip_address.log
will be use as the log file and will be written to the directory specified.

There are a few caveats associated with the directory:

=over

=item *

The directory can either be absolute or relative.

=over

=item *

If the directory is absolute, then all of the directories that are encountered within the directory path B<must> exist.

=item *

If the directory is relative, then it will be assumed to be relative to the current working directory of Perl, which is 
typically the same directory of the main Perl script that is being executed.

=back

=back

If the log file that is being written already exists, then new logging messages will be appended to the end of the existing
log file.  Otherwise, a new file will be created for logging.

=item C<set_logging_level($logging_level)>

Sets the logging level for this singleton instance of the C<ZipTie::Logger> module.  Currently, any logging level less than
or equal to zero (0) means that both DEBUG and FATAL messages will be logged.  Any logging level greater than 0 will disable
DEBUG logging so that only FATAL messages are logged.  The specified value will override the one that may be specified
through the "ADAPTER_LOGGING_LEVEL" environment variable.

=item C<debug($message, $context)>

Logs a message to the file handle that this C<ZipTie::Logger> singleton instance knows of.  You can also determine whether or
not to display debug log messages by setting a logging level.  If the logging level is less than or equal to zero (0), then
both DEBUG and FATAL messages will be logged; otherwise, only FATAL messages will be logged.  The logging level can be set in
two ways: either programatically using the C<set_logging_level($logging_level)> method, or through the
"ADAPTER_LOGGING_LEVEL" environment variable.  If set programatically, the value will override the one that may be specified
through the "ADAPTER_LOGGING_LEVEL" environment variable.

The syntax of a logged message is as follows:  1) A time stamp for when the message was received, 2) A context for the
logged message, and 3) The actual message to be logged.

The C<$context> parameter is optional and if it is not specified, than the the package name of the module that
called C<debug($message, $context)> will be used.  Providing an explicit context can be useful if you are trying to 
group and/or filter log messages from various modules that are performing actions for the same purpose/context.

B<NOTE:> If the C<ZipTie::Logger> object calling C<debug($message, $context)> does not have a valid file handle to a log file,
then all logged messages will be sent to C<STDERR>.

B<SPECIAL NOTE:> If the ZipTie PerlServer for BSF has been used to invoke the perl process that is using C<ZipTie::Logger>, 
then we must prepend the special identifier "=== ps log" to any messages that are considered logging messages.
We can check to see if this is the case by examining the "__GUID" environment variable. If it exist, we will assume that
PerlServer is being used. Also, the log message will be Base64 encoded using C<MIME::Base64::encode_base64>.
The purpose of this encoding is to not interfere with any parsing done in PerlServer.  The Base64 encoded text will also
be joined by replacing the newlines to represent one long string and not be split up across multiple lines since
ZipTie's PerlServer can only read a line at a time.

=item C<fatal($message, $context)>

Similar to C<debug($message)> but will end the Perl process with a call to C<Carp::croak> with the error message specified.
This is useful if a situation has occurred in your program and you want to log what happens before you quit out.

To help figure out why the error occurred, output similar to C<Carp::croak> with the error message along with a
stacktrace will be logged.

The C<$context> parameter is optional and if it is not specified, than the the package name of the module that
called C<fatal> will be used.  Providing an explicit context can be useful if you are trying to to group and/or
filter log messages from various modules that are performing actions for the same purpose/context.

NOTE: If the C<ZipTie::Logger> object calling C<fatal> does not have a valid file handle to a log file,
then the message will be logged to C<STDERR> and a call to C<Carp::croak> with the message will still occur.

=item C<fatal_error_code($errorCode, $ip, $actualResponse, $context)>

This method is simply a wrapper around the C<fatal($message, $context)> method.  It formats a readable error message that
can be consistent across all ZipTie Perl operations.

The C<$errorCode> parameter should be a well known error code taken from this modules 'our' variables.  For example
'$TFTP_ERROR'.

The C<$ip> parameter is an IP address of a device.  This makes its way into the fatal log message.

The C<$actualResponse> parameter is the actual response from the device, assuming the adapter failed and has some response
that would help the user solve the issue.

The C<$context> parameter is optional.  See C<fatal($message, $context)> for information on this variable.

=back

=head1 PRIVATE METHODS

=over 12

=item C<_log($message, $context)>

Provides the logging functionality that is common between the C<debug($message, $context)> and C<fatal($message, $context)>
methods.

=back

=head1 SEE ALSO

Carp - L<http://search.cpan.org/perldoc?Carp>

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
Date: Apr 30, 2007

=cut
