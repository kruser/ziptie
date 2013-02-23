package ZipTie::Adapters::Cisco::Three005::MenuElf;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw( enter_menu );    

use ZipTie::Logger;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

sub enter_menu
{
	my ( $cliProtocol, $prompt, $menuItem ) = @_;
	my $currentMenu = $cliProtocol->send_and_wait_for( '', $prompt );
	if ($currentMenu =~ /(\d+)\)\s.*($menuItem).*$/mi)
	{
		return $cliProtocol->send_and_wait_for( $1, $prompt );
	}
	else
	{
		$LOGGER->fatal("The menu item for \'$menuItem\' is not available in the current screen.");
	}
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Cisco::Three005::MenuElf

=head1 SYNOPSIS

    use ZipTie::Adapters::Cisco::Three005::MenuElf;
	ZipTie::Adapters::Cisco::Three005::MenuElf::enter_menu($cliProtocol, $prompt, 'Administration');

=head1 DESCRIPTION

Enter a menu on a Cisco 3000 VPN by the name, rather than the number

=head2 METHODS

=over 12

=item C<enter_menu($cliProtocol, $prompt, 'choice')>

Enter a menu on a Cisco 3000 series VPN concentrator by using the menu name.  Returns
the results of the next screen.

$cliProtocol - an implementation of ZipTie::CLIProtocol
$prompt - a regular expression that is the prompt to wait for on each menu

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

=head1 AUTHOR

  Contributor(s): rkruse
  Date: May 5, 2008

=cut
