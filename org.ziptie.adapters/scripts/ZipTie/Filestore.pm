package ZipTie::Filestore;

use strict;

use ZipTie::Logger;

my $LOGGER = ZipTie::Logger::get_logger();

sub new
{
	my ( $class, $path ) = @_;
	my $package = ref($class) || $class;
	my $self = {
		path => $path,
	};
	bless( $self, $package );
	return $self;
}

sub from_xml
{
	my $inValue = shift or $LOGGER->fatal("ERROR - No XML specified to convert into a ZipTie::RestoreFile object!");
	my ($path) = $inValue =~ /path=['"](.+?)['"]\/?>/; 
	return new ZipTie::Filestore->new($path);
}

sub get_path
{
	my $this = shift;
	return $this->{path};
}

1;

__END__

=head1 NAME

ZipTie::Filestore - A location where image files shouldl be saved to.  For use in the ospull operation.

=head1 SYNOPSIS

	This module is only created by the C<ZipTie::Typer> module.

=head1 DESCRIPTION

This module simply allows easy conversion from an XML element into metadata about a directory
which is to be used to store files, specifically operating system images from networked devices.

=head2 Methods

=over 12

=item C<get_path()>

Get the path to the filestore directory.

=item C<from_xml($xml)>

Create an instance of this module from an XML document.

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
  Date: April 12, 2008

=cut