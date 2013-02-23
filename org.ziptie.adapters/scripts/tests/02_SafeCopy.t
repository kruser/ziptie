use strict;
use warnings;
use Test::More tests => 3;
use Time::HiRes;

use ZipTie::SafeCopy;

use threads;

my $originalFile    = 'safecopy.test';
if (!-e $originalFile)
{
	open (SEED, ">$originalFile");
	print SEED "STUFF FOR THIS TEST";
	close (SEED);
}

my $destinationFile =  $originalFile.'.copy';
my @threads;

for ( my $i = 0 ; $i < 50 ; $i++ )
{
	push( @threads, threads->create( \&_copy_thread ) );
}
foreach my $thread (@threads)
{
	$thread->join;
}    

ok(!-e $destinationFile, "Validating that $originalFile has been deleted");
ok(!-e $destinationFile.'.lock', "Validating that $originalFile.lock has been deleted");
ok(-e $originalFile, "Validating that the original file still exists.");
unlink($originalFile);

sub _copy_thread
{
	ZipTie::SafeCopy::safe_copy( $originalFile, $destinationFile );
	sleep(5);
	ZipTie::SafeCopy::safe_delete( $destinationFile );
}
