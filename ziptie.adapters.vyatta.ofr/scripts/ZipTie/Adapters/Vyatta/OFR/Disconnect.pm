package ZipTie::Adapters::Vyatta::OFR::Disconnect;    

use strict;
use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Logger;

use Exporter 'import';
our @EXPORT_OK = qw(disconnect);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub disconnect
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Send the Control-C command which is 0x03 in hexidecimal
	$cliProtocol->send_as_bytes("03");
	
	# Keep sending the "exit" command until we have successfully exited the device
	_send_exit($cliProtocol);
	
	# Disconnect from the CLI protocol
	$cliProtocol->disconnect();
}

sub _send_exit
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Specify the responses to handle
	my @responses = ();
	push(@responses, ZipTie::Response->new("#|>", \&_send_exit));
	push(@responses, ZipTie::Response->new(".*"));
	
	# Send the "exit" command
	$cliProtocol->send("exit");
	my $response = $cliProtocol->wait_for_responses(\@responses);
	
	# Based on the response of the device, determine the next interaction that should be executed.
	my $nextInteraction = undef;
	if ($response)
	{
		$nextInteraction = $response->get_next_interaction();
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
	
	# Call the next interaction if there is one to call
	if ($nextInteraction)
	{
		return &$nextInteraction($cliProtocol);
	}
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Vyatta::OFR::Disconnect

=head1 SYNOPSIS

    use ZipTie::Adapters::Vyatta::OFR::Disconnect
	ZipTie::Adapters::Vyatta::OFR::Disconnect::execute($cliProtocol);

=head1 DESCRIPTION

Disconnect method for the CLI of a Vyatta OFR router

=head2 Methods

=over 12

=item C<disconnect>

Attempts to disconnect from a Vyatta OFR-based device that a CLIProtocol object is currently connected to.
If all is well, the device will be successfully disconnected from and no error will occur.

Input:	$cliProtocol -	A valid ZipTie::CLIProtocol object that is already connected to a device.

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

  Contributor(s): rkruse
  Date: Apr 23, 2007

=cut
