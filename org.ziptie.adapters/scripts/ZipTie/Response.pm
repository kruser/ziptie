package ZipTie::Response;

use strict;

sub new
{
	my $class_name = shift;

	# Initialize this instance of the class with the arguments passed in.
	my $this = {
		regex            => shift,
		next_interaction => shift,
		error_message    => shift
	};

	# Turn $this into a ZipTie::Response object
	bless( $this, $class_name );

	# Return the object
	return $this;
}

sub get_regex
{
	my ($self) = @_;
	return $self->{regex};
}

sub get_next_interaction
{
	my ($self) = @_;
	return $self->{next_interaction};
}

sub get_error_message
{
	my ($self) = @_;
	return $self->{error_message};
}

1;

__END__

=head1 NAME

ZipTie::Response - Attempts to match a possible CLI response from a device and allows for code execution if the device
response is matched.

=head1 SYNOPSIS

	use ZipTie::Response;
	use ZipTie::CLIProtocol;
	use ZipTie::CLIProtocolFactory;

	my $telnet = ZipTie::CLIProtocolFactory->create("Telnet", "10.10.10.10", 23);
	$telnet->connect($telnet->get_ip_address(), $telnet->get_port());

	my @responses = ();
	push(@responses, ZipTie::Response->new('[Pp]assword:', \&_send_password));
	push(@responses, ZipTie::Response->new('incorrect', undef, "INVALID CREDENTIALS"));

	my $response = $cliProtocol->wait_for_responses(\@responses);

	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		&$next_interaction($some_arg, $some_other_arg);
	}

=head1 DESCRIPTION

The C<ZipTie::Response> module is designed to represent a possible CLI response from a device that can then be handled be
the C<ZipTie::CLIProtocol> module using its C<wait_for_response($response_obj_array_ref)> method. The C<ZipTie::Response>
module was specifically designed to work with this method and you should refer to the documentation for the
C<ZipTie::CLIProtocol> module for more context; a link is provided in the "SEE ALSO" section of this module's documentation.

The logic that is used by the C<ZipTie::Response> module is that when a CLI response from a device is encountered,
the contents of the response can be evaluated against a regular expression in order to handle it correctly.  Depending on 
what the regular expression is designed to match, it can either match a response that requires another action to be
taken, or it can match an error response that means the current interaction with the device should not continue.

This divides an instance of C<ZipTie::Response> into three separate parts:

=over

=item *

A regular expression that will be used against a CLI device response.  This regular expression will be engineered to match
the response in a certain way that gives context and meaning to the response and the reason that it was matched.

=item *

A C<CODE> reference that references a method, subroutine, or block of code that should be executed if the CLI device response
matches the specified regular expression.  This C<CODE> reference will be executed if the regular expression specified
matches the response.

=item *

An error message that will be used as the error message to cause the Perl process to exit if the CLI device response
matches the specified regular expression.  This should only be used if the regular expression defined is meant to match
a response indicating that the interaction with the device should not continue.

=back

=head1 CAVEATS

When using an instance of C<ZipTie::Response>, you should B<NEVER> specify both a C<CODE> reference and an error message on
the instance itself.  This is because when the C<ZipTie::CLIProtocol::wait_for_responses($response_obj_array_ref)> method
evaluates an array of C<ZipTie::Response> objects, it checks to see if an error message exists on the specific
C<ZipTie::Response> instance that matched a CLI response from a device.  If an error message does exist, then the
Perl process will end using that error message before the specified C<CODE> reference can ever be executed.  This
logic assumes that if an error condition is encountered and the creator of the C<ZipTie::Response> instance crafted it in
such a way to use an error message, then that is the preferred method of handling the error.  If the creator of the
C<ZipTie::Response> instance wants to handle the error in a different fashion, then have a method that uses a 
C<CODE> reference to handle the error and let the Perl process continue on.

=head1 METHODS

=over 12

=item C<new($regex, $next_interaction, $error_message)>

Creates a new C<ZipTie::Response> instance by specifying a valid regular expression, a C<CODE> reference to a method to
call if the regular expression matches, and an error message if the regular expression matches and no method should be
called.

$regex -			A valid expression that can be used to match a response from a device.

$next_interaction -	Optional.  A reference to the method to be executed if the regular expression successfully matched the
					response of a device.

$error_message -	Optional.  An error message describing what error occurred if a regular expression successfully matched
					the response of a device.  This is primarily used if the regular expression is meant to be used to
					match an error response from a device.

=item C<get_regex()>

Retrieves the regular expression specified for this C<ZipTie::Response> instance.  This is the regular expression that
will be used by the C<ZipTie::CLIProtocol::wait_for_responses($response_obj_array_ref)> method when evaluating a CLI
response from a device.  If this regular expression is matched and an error message is specified, the current Perl process
will end using the error message as the reason for the Perl process ending.  Otherwise, this C<ZipTie::Response> instance
will be evaluated as the match for the CLI response from the device.

=item C<get_next_interaction()>

Example:

	my $response = $cliProtocol->wait_for_responses(\@responses);

	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		&$next_interaction($some_arg, $some_other_arg);
	}

Retrieves the C<CODE> reference specified for this C<ZipTie::Response> instance.  This C<CODE> reference can refer to
a method, subroutine, or block of code that should be executed if a CLI device response matches the regular expression
retrieved by C<get_regex()>.

When utilizing the C<ZipTie::CLIProtocol::wait_for_responses($response_obj_array_ref)> method, it is usually assumed that
the single C<ZipTie::Response> instance that is returned by it will have it's C<get_next_interaction()> method called in
order to retrieve the C<CODE> reference so that it can be executed.

=item C<get_error_message()>

Retrieves the error message describing what error occurred if a regular expression successfully matched the CLI response from
a device. This method is primarily used if the regular expression is meant to be used to match an error response from a
device.

When utilizing the C<ZipTie::CLIProtocol::wait_for_responses($response_obj_array_ref)> method, if an error message is
specified on this C<ZipTie::Response> instance, the current Perl process will end using it as the reason for the Perl Process ending.  Otherwise, this C<ZipTie::Response> instance
will be evaluated as the match for the CLI response from the device.

Refer to the "DESCRIPTION" and "CAVEATS" section of this module's documentation for more information.

=back

=head1 SEE ALSO

ZipTie::CLIProtocol

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
Date: Jun 29, 2007

=cut
