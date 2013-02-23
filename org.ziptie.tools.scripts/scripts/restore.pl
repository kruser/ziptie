#!/usr/bin/perl
use strict;
use Getopt::Long;
use MIME::Base64 'encode_base64';

use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::Adapters::Invoker;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ( $connectionPathXml, $adapterId, $filestore, $file, $configFilename, );
GetOptions(
	"connectionPath=s" => \$connectionPathXml,
	"adapterId=s"      => \$adapterId,
	"filestore=s"      => \$filestore,
	"file=s"           => \$file,
	"configName=s"     => \$configFilename,
);

my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $device = $connectionPath->get_ip_address();

open( FILE, $filestore . '/' . $file );
my $terminator = $/;
undef $/;
my $wholeFile = <FILE>;
close(FILE);
$/ = $terminator;

my $restoreFile =
    '<restoreFileInfo fullPathOnDevice="'
  . $configFilename
  . '"><base64EncodedFileBlob>'
  . encode_base64($wholeFile)
  . '</base64EncodedFileBlob></restoreFileInfo>';
my $operation = 'restore';
$connectionPathXml =~ s/(<\/\w+>)$/$restoreFile$1/;

my $response;
eval { $response = ZipTie::Adapters::Invoker::invoke( $adapterId, $operation, $connectionPathXml ); };
if ($@)
{
	if ( $@ =~ /Can't locate.+\.pm|Can't locate object method/i )
	{
		print "WARN,$device,$configFilename\n";
		print "\n";
		print "The \"$operation\" operation is not yet implemented for the $adapterId adapter\n";
		print "\n";
		print "Visit http://www.ziptie.org/zde for information on how to extend the $adapterId adapter.";
	}
	else
	{
		print "ERROR,$device,$configFilename\n";
		print "\n";
		print "$@";
	}
}
else
{
	print "OK,$device,$configFilename\n\n$response";
}

__END__

=head1 DESCRIPTION

A script tool that is designed to run the restore operation on adapters

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
  Date: May 15, 2008

=cut
