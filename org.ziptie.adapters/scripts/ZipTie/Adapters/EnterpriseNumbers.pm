package ZipTie::Adapters::EnterpriseNumbers;

use strict;
use Cwd;

sub get_enterprise_name
{
	my $sysObjectId = shift;
	my $eid         = 0;
	if ( $sysObjectId =~ /^\.1\.3\.6\.1\.4\.1\.(\d+)/ )
	{
		$eid = $1;
	}
	else
	{
		return "Unknown";
	}

	my $lineSize = 120;

	# Get the path where this module lives, since the enterprises text file
	# also lives in the same path.
	( my $pkgdir = __PACKAGE__ ) =~ s!::!/!g;
	my ($path) = $INC{"$pkgdir.pm"} =~ m!^(.+)/!;

	my $enterpriseName;
	my $file = "$path/enterprises";
	open( FILE, $file ) || die "Unable to open $file";
	binmode(FILE);
	seek( FILE, $eid * $lineSize, 0 );
	read( FILE, $enterpriseName, 120 );
	close FILE;

	$enterpriseName =~ s/^\d+==//;    # remove leading
	$enterpriseName =~ s/-+$//;       # remove trailing filler
	chomp $enterpriseName;
	return $enterpriseName;
}

1;

__END__

=head1 NAME

ZipTie::Adapters::EnterpriseNumbers

=head1 SYNOPSIS

    use ZipTie::Adapters::EnterpriseNumbers;
	my $enterpriseName = ZipTie::Adapters::EnterpriseNumbers::get_enterprise_name(".1.3.6.1.4.1.352");

=head1 DESCRIPTION

Scans a nicely formatted enterprises file to get the enterprise name using a sysOid provided to it.  See C<SYNOPSIS>.

=head2 METHODS

=over 12

=item C<get_enterprise_name($sysOid)>

$sysOid - must be a full sysOid, starting with ".1.3.6.1.4.1".

Returns the enterprise name.

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
  Date: Feb 4, 2008

=cut
1;
