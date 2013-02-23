package ZipTie::Adapters::Unix::ParsingUtils;

use strict;
use warnings;

sub parse_last_reboot
{
	my ( $uptime, $out ) = @_;
	if ( $uptime =~ /\bup\s+(.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;

		if ( !defined $hours )
		{
			my $temp = $_;
			if ( $temp =~ /(\d+)\:(\d+)/ )
			{
				$hours   = $1;
				$minutes = $2;
			}
		}

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$out->print_element( "core:lastReboot", $lastReboot );
	}
}

1;

__END__

=head1 NAME

ZipTie::Adapters::Unix::ParsingUtils

=head1 SYNOPSIS

    use ZipTie::Adapters::Unix::ParsingUtils qw(parse_ifconfig);
	parse_ifconfig($responses->{ifconfig}, $printer);

=head1 DESCRIPTION

Offers parsing mechanisms to turn common Unix/Linux command output into the ZED XML format.

Results of each method are printed using the $printer arguement.

=head1 METHODS

=over 12

=item C<parse_last_reboot($uptime, $printer)>

Takes the output of an 'uptime' command and prints the core:lastReboot element
of the ZED.

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
  Date: Sep 17, 2008

=cut
