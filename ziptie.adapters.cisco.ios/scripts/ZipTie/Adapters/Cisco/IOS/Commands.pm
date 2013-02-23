package ZipTie::Adapters::Cisco::IOS::Commands;

use strict;

use ZipTie::Adapters::Cisco::IOS;
use ZipTie::Adapters::Cisco::IOS::Disconnect qw(disconnect);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::Typer;

sub invoke
{
    my $package_name = shift;
    my $command_doc  = shift;
    my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
    my ( $cli_protocol, $enable_prompt_regex ) = ZipTie::Adapters::Cisco::IOS::_connect($connection_path);
    # Turn off paging
    #my $termLen = $cli_protocol->send_and_wait_for( "terminal length 0", $enable_prompt_regex );
    # Instead of turning off paging, handle it instead
    $cli_protocol->set_more_prompt( '(?:<--- More --->|--More--)\s*$', '20');
    my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'IOS', $cli_protocol, $commands, $enable_prompt_regex.'|(#|\$|>)\s*$' );
    disconnect($cli_protocol);
    return $result;
}

1;

__END__


=head1 NAME

ZipTie::Adapters::Cisco::IOS::Commands - Adapter for performing the 'commands' operation against Cisco IOS devices.

=item C<invoke($command_doc)>

Implements the commands adapter operation.

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
