############################
#
#
############################

use MIME::Base64;

use subs qw(exit);
sub exit
{
   my $ret = shift(@_);
   die "=== ps intercepted exit $ret";
}

my $package_count = 0;

my $debug = $ENV{'__DEBUG'};

my $script = '';

if ($debug)
{
   open(DUMP, ">>dump.txt");
   my $old_fh = select(DUMP);
   $| = 1;
   select($old_fh);
}

# autoflush streams
my $old_fh = select(STDOUT);
$| = 1;
select(STDERR);
$| = 1;
select($old_fh);

print STDOUT "=== pong\n";
logDebug("Sent pong back to Java process") if $debug;

my $_arg = 0;

while ($_ = <STDIN>)
{
   chomp($_);

   # print STDERR "$_\n";

   if (/^=== env\s/)
   {
      my ($name, $value) = split('=', $');
      $ENV{$name} = $value;
      logDebug("Set environment varaible: $name=$value") if $debug;
   }
   elsif (/^=== arg\s/)
   {
   	  $ARGV[$_arg++] = decode_base64($');
   	  logDebug("Set argument: " . decode_base64($')) if $debug;
   }
   elsif (!/^===/)
   {
      $script .= "$_\n";
   }
   elsif (/^=== exec$/)
   {
   	  # my $thread = threads->new( \&execScript );
   	  # $thread->join;
   	  &execScript($script);
   	  $script = '';
   }
}

close(STDIN);
close(STDERR);
close(STDOUT);

sub execScript
{
   my $script = shift(@_);
   my $ret, $err;

   $package_count++;

   eval
   {
       # Place each script in it's own package to prevent redefinition.
      $ret = eval("package PerlServer::Pack$package_count;\n$script");
      $err = $@;
   };

   $_arg = 0;
   @ARGV = ();
   $script = '';

   if ($err =~ /^=== ps intercepted exit\s/)
   {
      $err = $';
      logDebug("Handling exit: $err") if $debug;
      print STDOUT "\n=== ps exit " . chomp($err) . "\n";
   }
   elsif ($err)
   {
      logDebug("Handling error: $err") if $debug;
      print STDOUT "\n=== ps error\n$err\n=== ps end\n";
   }
   else
   {
      logDebug("Handling OK: $ret") if $debug;
      print STDOUT "\n=== ps end\n";
   }
}

sub logDebug
{
   my $msg = shift(@_);
   
   if ($debug)
   {
      print DUMP "$msg\n";
   }
}
