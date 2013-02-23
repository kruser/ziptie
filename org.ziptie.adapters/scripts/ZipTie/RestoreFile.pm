package ZipTie::RestoreFile;

use strict;

use ZipTie::Logger;
use MIME::Base64 'decode_base64';

my $LOGGER = ZipTie::Logger::get_logger();

sub new
{
	my ( $class, $fullPath, $blob ) = @_;
	my $package = ref($class) || $class;
	my $self = {
		fullPathOnDevice => $fullPath,
		textBlob         => $blob,
	};
	bless( $self, $package );
	return $self;
}

sub from_xml
{
	my $in_value = shift or $LOGGER->fatal("ERROR - No XML specified to convert into a ZipTie::RestoreFile object!");
	my ($fullPath) = $in_value =~ /fullPathOnDevice=['"](.+?)['"]>/; 
	my ($blob) = $in_value =~ /base64EncodedFileBlob>(.*)<\/base64EncodedFileBlob/s; 
	return new ZipTie::RestoreFile->new($fullPath, decode_base64($blob));
}

sub get_path
{
	my $this = shift;
	return $this->{fullPathOnDevice};
}

sub get_blob
{
	my $this = shift;
	return $this->{textBlob};
}

1;

__END__

=head1 NAME

ZipTie::RestoreFile - A configuration file to restore to a device

=head1 SYNOPSIS

	This module is only created by the C<ZipTie::Typer> module.

=head1 DESCRIPTION

RestoreFile contains information about a configuration file including
the path that the configuration lives in as well as the configuration blob
itself.

=head2 Methods

=over 12

=item C<get_blob()>

Retrieve the text blob of this configuration.

=item C<get_path()>

Get the path that this configuration lives in on the device.

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
  Date: Oct 7, 2007

=cut