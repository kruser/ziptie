use strict;
use threads;
use threads::shared;

my $count : shared = 0;
my $home = '/dev/ziptie/head/org.ziptie.adapters/scripts';
my @devices = ( '10.100.20.212', '10.100.25.50', '10.100.20.58', '10.100.20.213', '10.100.20.222', '10.100.20.210', '10.100.20.221', );
my @threads;
for ( my $i = 0 ; $i < 3 ; $i++ )
{
	foreach my $ip (@devices)
	{
		push( @threads, threads->create( \&ssh, $ip, \$count ) );
	}
}

foreach my $thread (@threads)
{
	$thread->join;
}

sub ssh
{
	my $device = shift;
	my $count  = shift;
	system( 'perl', '-I' . $home, $home . '/tests/singleSsh.pl', $device );
	$$count++;
	print "===========  Finished SSH #$$count\n";
}
