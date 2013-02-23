package ZipTie::Adapters::Invoker;

use strict;
use vars qw($AUTOLOAD);

use Carp qw(confess);

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $adapter   = shift or confess("An adapter must be specified");
	my $operation = shift or confess("An operation must be specified.");
	my $input     = shift;

	my $invoker = ZipTie::Adapters::Invoker->new(
		adapter   => ($adapter) ? $adapter : 'ZipTie::Adapters::BaseAdapter',
		operation => $operation,
		input     => $input,
	);
	$invoker->execute();
}

sub new
{
	my ( $proto, %params ) = @_;
	my $package = ref($proto) || $proto;

	my $self = {};

	foreach my $key ( keys %params )
	{
		$self->{$key} = $params{$key};
	}

	bless( $self, $package );
}

sub execute
{
	my $self = shift;

	# Initialize anything before the operation gets executed
	$self->init_operation();

	my $adapter_package = $self->{adapter};
	my $operation       = $self->{operation};
	my $contents        = $self->{input};

	my $cmd;
	my $result;
	my $pkg = $adapter_package . '::' . ucfirst($operation);
	eval("use $pkg;");
	if ($@)
	{
		$cmd = "use $adapter_package;\n\$result = $adapter_package->$operation(\$contents);";
	}
	else
	{
		$cmd = "\$result = $pkg->invoke(\$contents);";
	}
	
	eval($cmd);
	if ($@)
	{

		# If an error occurred, die with the message that was generated
		die($@);
	}

	# Shutdown anything after the operation is executed sucessfully
	$self->shutdown_operation();
	return $result;
}

sub init_operation
{
	my $self = shift;

	# If the "ENABLE_RECORDING" and "RECORDING_DIR" environment variables are set properly,
	# then clear out any information that might be stored from a previous recording.
	if ( $ENV{ENABLE_RECORDING} && $ENV{RECORDING_DIR} )
	{

		# Get an instance of the ZipTie::Recording object
		use ZipTie::Recording;
		my $recording = ZipTie::Recording::get_recording();

		# Clear out the recording
		$recording->clear();
	}

	# If the "ADAPTER_LOG_TO_FILE" and "ADAPTER_LOG_DIR" environment variables are set properly,
	# attempt to enable logging to a file
	if ( $ENV{ADAPTER_LOG_TO_FILE} && $ENV{ADAPTER_LOG_DIR} )
	{

		# Grab the ZipTie::ConnectionPath object
		my ($connection_path) = ZipTie::Typer::translate_document( $self->{input}, 'connectionPath' );

		# Attempt to enable logging to a file
		$LOGGER->enable_logging_to_file( $self->{adapter}, $self->{operation}, $connection_path->get_ip_address() );
	}
}

sub shutdown_operation
{
	my $self = shift;

	# If the "ENABLE_RECORDING" and "RECORDING_DIR" environment variables are set properly,
	# then attempt to write the recording out to a file
	if ( $ENV{ENABLE_RECORDING} && $ENV{RECORDING_DIR} )
	{

		# Get an instance of the ZipTie::Recording object
		use ZipTie::Recording;
		my $recording = ZipTie::Recording::get_recording();

		# Grab the ZipTie::ConnectionPath object
		my ($connection_path) = ZipTie::Typer::translate_document( $self->{input}, 'connectionPath' );

		# Write the recording to a file, being sure to pass the connection path by reference
		$recording->to_file( $self->{adapter}, $self->{operation}, $connection_path );

		# Clear out the recording
		$recording->clear();
	}
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Invoker

=head1 SYNOPSIS;

use ZipTie::Adapters::Invoker;

ZipTie::Adapters::Invoker::invoke($adapter_package, $operation, $contents);

or

$invoker = ZipTie::Adapters::Invoker->new(adapter -> $adapter_package, operation => $operation, input => $contents);
$invoker->execute();

=head1 SUBROUTINES

=over 12

=item C<invoke($adapter_package, $operation, $input_xml)>

Convenience method for invoking an adapter operation.

This is the same as creating a new Invoker instance and then calling execute()

=item $invoker = ZipTie::Adapters::Invoker->new( %options )
Creates an invoker.

  adapter:   The adapter module name.
  operation: The adapter operation. (eg: 'backup' or 'commands')
  input:     The operation input document as an xml string.

=item C<execute()>

Executes the operation for the current instance of the invoker.

=item C<init_operation()>

Initializes modules or executes code before invoking an operation.

Currently, this method is only used to attempt to set up logging adapter operations to a file.  The environment variables
C<ADAPTER_LOG_TO_FILE> and C<ADAPTER_LOG_DIR> are checked to see if they are setup properly in order to actually enable
logging adapter operations to a file.  If they are, the C<enable_logging_to_file($adapter_id, $operation_name, $ip_address)>
will be called on the singleton instance of the C<ZipTie::Logger> module, which is the module that is used through out the
ZipTie Perl Adapter SDK for logging to a common file.  Please refer to the C<ZipTie::Logger> documentation for more
context around using the logging capabilities of the ZipTie Perl Adapter SDK.

=item C<shutdown_operation()>

Shutdowns modules or executes code after an operation has been completed.

Currently, this method is only used to write a C<ZipTie::Recording> object to file.  The environment variables
C<ENABLE_RECORDING> and C<RECORDING_DIR> are checked to see if they are setup properly in order to actually write a recording
to a file. If they are, the C<to_file($adapter_id, $operation_name, $connection_path_ref)> will be called on the singleton instance of
the C<ZipTie::Recording> module, which is the module that is used to record the interactions that occur during the execution
of an adapter operation.  Please refer to the C<ZipTie::Recording> documentation for more and context around using the
recording capabilities of the ZipTie Perl Adapter SDK.

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
Portions created by AlterPoint are Copyright (C) 2006-2008,
AlterPoint, Inc. All Rights Reserved.

=head1 AUTHOR

Contributor(s): Leo Bayer (lbayer@ziptie.org)
Date: April 8, 2008

=cut
