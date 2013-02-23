use strict;
use Config;
use Net::IP;

# Get the device
my $device = shift(@ARGV);

# Create an Net::IP object based on the device IP to determine if it is IPv4 or IPv6
my $netIp = new Net::IP($device);
my $isVersion6 = ( defined($netIp) && $netIp->version() == 6 ) ? 1 : 0;

select(STDOUT);
$| = 1;

# Execute the ping command
#
my $OS = $Config::Config{'osname'};
 
my ($command, $lossRegexp, $unreachableRegexp, $bytesAndTTLRegexp, $roundTripRegexp, $windowsDetected);
if ($OS =~ /darwin/) #OS evolved from Berkeley
{
   $command = "ping -Q -c 3 $device 2>&1";
   $lossRegexp = "(\\d+\\%) packet loss";
   $unreachableRegexp = "unreachable";
   $bytesAndTTLRegexp = "(\\d+) bytes.*ttl=(\\d+).*";
   $roundTripRegexp = "(round-trip).+=\\s*(\\d+\\.\\d+)\\/(\\d+\\.\\d+)\\/(\\d+\\.\\d+)\\/(\\d+\\.\\d+).*";
   $windowsDetected = 0;
}
elsif ($OS =~ /win/i) # Windows #Changed the Regex to work with Windows XP as it is returning MSWin32
{
   if ( $isVersion6 == 1 )
   {
      # The 'ping' command on Windows do not give us any TTL information when the IP address is version 6
      $bytesAndTTLRegexp = "(\\d+)\\s*bytes";
   }
   else
   {
      # Pinging an IPv4 address on Windows does gives us TTL information
      $bytesAndTTLRegexp = "bytes=(\\d+).*TTL=(\\d+)";
   }
   $command = "ping -n 3 $device 2>&1";
   $lossRegexp = "(\\d+\\%) loss";
   $unreachableRegexp = "100% loss";
   $roundTripRegexp = "Minimum\\s*=\\s*(\\d+)ms,\\s*Maximum\\s*=\\s*(\\d+)ms,\\s*Average\\s*=\\s*(\\d+)ms";
   $windowsDetected = 1;
}
else # Some other Linux
{
   if ( $isVersion6 == 1 )
   {
      # Use the 'ping6' command if the IP address is v6
      $command = "ping6 -c 3 $device 2>&1";
   }
   else
   {
      $command = "ping -c 3 $device 2>&1";
   }
   $lossRegexp = "(\\d+)%\\s*loss|(\\d+)%\\s*packet\\s*loss"; #Fixed the regex and checked under Fedora core 3 and Ubuntu Linux 6
   $unreachableRegexp = "unreachable";
   $bytesAndTTLRegexp = "(\\d+) bytes.*ttl=(\\d+).*";
   $roundTripRegexp = "(rtt).*=\\s*(\\d+\\.\\d+)\\/(\\d+\\.\\d+)\\/(\\d+\\.\\d+)\\/(\\d+\\.\\d+).*";
   $windowsDetected = 0;
}
my $pingOutput = `$command`;


my ($bytes, $ttl, $min, $avg, $max, $stddev, $pktloss);
my $error = 3;

# Parse the output
if ($pingOutput =~ /$unreachableRegexp/)
{
   $error += 1;
}

if ($pingOutput =~ /$bytesAndTTLRegexp/)
{
   $bytes = $1;
   # On Windows, a ping of an IPv6 address will not give us any TTL information
   if (($windowsDetected == 1) && ($isVersion6 == 1))
   {
      $ttl = "N/A";
   }
   else
   {
      $ttl = $2;
   }
   $error -= 1;
}

if ($pingOutput =~ /$lossRegexp/)
{
   $pktloss = $1;
   $error -= 1;
}

if (($windowsDetected == 0) && ($pingOutput =~ /$roundTripRegexp/))
{
   $min = $2;
   $avg = $3;
   $max = $4;
   $stddev = $5;
   $error -= 1;
}
elsif (($windowsDetected == 1) && ($pingOutput =~ /$roundTripRegexp/))
{
   $min = $1;
   $avg = $3;#Changed the avg to hold the third match for windows regex
   $max = $2;#Changed the max to hold the third match for windows regex
   $stddev = "N/A";
   $error -= 1;
}
my $status = ($pktloss > 0 ? "WARN" : "OK");
$status = ($error || $pktloss == 100 ? "ERROR" : $status);
print "$status,$device,$bytes,$ttl,$min,$avg,$max,$stddev,$pktloss\n";
print "\n";
print "$pingOutput\n";
