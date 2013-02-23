package ZipTie::SafeCopy;

use strict;
use warnings;

use File::Copy;
use Fcntl ':flock';

use ZipTie::Logger;

my $LOGGER = ZipTie::Logger->get_logger();

sub safe_copy
{
	my ( $original, $destination ) = @_;
	my $lockFile = $destination . ".lock";
	my $count    = 1;
	if ( -e $lockFile )
	{
		open( READER, "$lockFile" );
		flock( READER, LOCK_EX );
		my @contents = <READER>;
		$count = $contents[-1];
		chomp($count);
		$count++;
		open( WRITER, ">>$lockFile" );
		print WRITER $count . "\n";
		close WRITER;
		flock( READER, LOCK_UN);
		close READER;
		$LOGGER->debug("Lock file already exists for $lockFile.  User count is now $count");
	}
	else
	{
		open( WRITER, ">>$lockFile" );
		flock( WRITER, LOCK_EX );
		print WRITER "1\n";
		$LOGGER->debug("Copying file $original to $destination");
		copy( $original, $destination );
		flock( WRITER, LOCK_UN );
		close WRITER;
	}
}

sub safe_delete
{
	my ($fileToDelete) = @_;
	my $lockFile = $fileToDelete . ".lock";
	if ( -e $lockFile )
	{
		open( READER, "$lockFile" );
		flock( READER, LOCK_EX );
		my @contents = <READER>;
		my $count = $contents[-1];
		chomp($count);

		if ( $count > 1 )
		{
			open( WRITER, ">>$lockFile" );
			$count--;
			print WRITER $count. "\n";
			$LOGGER->debug("Not deleting $fileToDelete.  There are still $count users.");
			close(WRITER);
			flock( READER, LOCK_UN );
			close(READER);
			return;
		}
		else
		{
			unlink($fileToDelete);
			flock( READER, LOCK_UN );
			close(READER);
			unlink($lockFile);
			$LOGGER->debug("Deleting file $fileToDelete");
		}
	}
	else
	{
		unlink($fileToDelete);
	}
}

1;

__END__

=head1 NAME

ZipTie::SafeCopy

=head1 SYNOPSIS

    use ZipTie::SafeCopy;
	ZipTie::SafeCopy::safe_copy($originalFilename, $destinationFilename);
	ZipTie::SafeCopy::safe_delete($filename);

=head1 DESCRIPTION

This module is designed to be used by many processed that want to copy and later delete the same file.

Do not use this module unless you plan on copying and then deleting a file after you are finished with it.

=head2 METHODS

=over 12

=item C<safe_copy($originalFilename, $destinationFilename)>

Copies a file from $originalFilename to the $destinationFilename.  

If the file already exists in the $destinationFilename this method won't copy the 
file.  Instead it will update some metadata on the file letting other processes that
call C<safe_delete> know that the file is in use and not ready to be deleted.

=item C<safe_delete($filename)>

Deletes the file if there are no more users of it, i.e. everyone else that called
C<safe_copy> have also called C<safe_delete>.

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
  Date: Apr 17, 2008

=cut
