#!/bin/perl
#
# Output for this tool is of the form:
#   multiple lines of csv detail
#   followed by a blank line
#   followed by the raw output of the command
#
# For example:
#    OK,1,192.168.1.1,192.168.1.1,1.746,1.572,1.617
#    WARN,2,,,,,,
#    OK,3,ge-1-3-0-130.aggr01.austtx.grandecom.net,66.90.139.62,44.653,9.617,8.972
#
#    traceroute to www.l.google.com (216.239.51.104), 16 hops max, 40 byte packets
#     1  192.168.1.1 (192.168.1.1)  1.746 ms  1.572 ms  1.617 ms
#     2  * * *
#     3  ge-1-3-0-130.aggr01.austtx.grandecom.net (66.90.139.62)  44.653 ms  9.617 ms  8.972 ms
#

use strict;
use Config;

# Get the device
my $device = shift(@ARGV);

select(STDOUT);
$| = 1;

# Set up the regular expressions for each platform.
#    See: http://www.fileformat.info/tool/regex.htm
#
my ( $command, $detailRegexp, $ipRegexp, $windowsDetected );
$ipRegexp = '((\\d{1,3}\\.){3}\\d{1,3})';

my $OS = $Config::Config{'osname'};
if ( $OS =~ /darwin/ )    # OS evolved from Berkeley
{
	$command = "traceroute -q 3 -w 2 -m 16 $device 2>&1";

	# format: ttl hostname (ip) time1 time2 time3
	$detailRegexp =
"\\s*(\\d+)\\s+(.+) \\($ipRegexp\\)\\s+(\\d+\\.\\d+) ms\\s+(\\d+\\.\\d+) ms\\s+(\\d+\\.\\d+) ms";
	$windowsDetected = 0;
}
elsif ( $OS =~ /[W,w]in/
  ) # Windows #Changed the Regex to work with Windows XP as it is returning MSWin32
{
	$windowsDetected = 1;
	$command         = "tracert $device 2>&1";

	# format: ttl time1 time2 time3 hostname [ip]
	$detailRegexp =
"\\s*(\\d+)\\s+<*(\\d+) ms\\s+<*(\\d+) ms\\s+<*(\\d+) ms\\s+([a-zA-Z0-9\\.\\-]*)\\s+\\[*([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})\\]*";
}
else    # Some other Linux
{
	$windowsDetected = 0;
	my $traceroute = 0;
	my $tracepath  = 1;
	if ( -x 'traceroute' )
	{
		$command = 'traceroute';
		$traceroute = 1;
	}
	elsif ( -x '/usr/sbin/traceroute' )
	{
		$command = '/usr/sbin/traceroute';
		$traceroute = 1;
	}
	elsif ( -x 'tracepath' )
	{
		$command = 'tracepath';
		$tracepath = 1;
	}
	elsif ( -x '/usr/bin/tracepath' )
	{
		$command = '/usr/bin/tracepath';
		$tracepath = 1;
	}
	else
	{
		print(
			"WARN,,\"Error: 'traceroute' command not found.\",\"$device\",\n");
		return;
	}

	if ($traceroute)
	{
		$command .= " -q 3 -w 2 -m 16 $device 2>&1";

		# format: ttl hostname (ip) time1 time2 time3
		my $probe = '(?:(\d+\.\d+) ms(?: !<10>)?|\*)(?: \S+ \([\d\.]{7,15}\))?';
		$detailRegexp =
		  "\\s*(\\d+)\\s+(.+) \\($ipRegexp\\)\\s+$probe\\s+$probe\\s+$probe";
	}
	elsif ($tracepath)
	{
		$command .= " $device 2>&1";
		$detailRegexp = '\s*(\d+):\s+(\S+)\s+\((.+?)\)(\s+)([\d.]+)ms';
	}
}

# Run the command through a pipe, and read it line-by-line
#
unless ( open( FILE, "$command|" ) )
{
	print("WARN,,\"Error: $!\",\"$device\",\n");
	return;
}

my ( $line, $detail );
while ( $line = <FILE> )
{
	$detail .= $line;
	chomp($line);
	if ( $line =~ /$detailRegexp/ )
	{
		if ( $windowsDetected == 0 )
		{    #Output for Mac & Linux
			print "OK,$1,$2,$3,$5,$6,$7\n";
		}
		else
		{    #Output for Windows
			print "OK,$1,$5,$6,$2,$3,$4\n";
		}
	}
	elsif ( $line =~ /^\s*(\d+).*/ )
	{
		print "WARN,$1,,,,,\n";
	}
}
close(FILE);

print "\n";
print "$detail";

# Mac OS X output: Note the exceptional output at (2), (11), and (12)
#
# brett-wooldridges-computer:~/Documents/dev/test brettw$ traceroute -q 3 -w 2 -m 16 www.google.com
# traceroute: Warning: www.google.com has multiple addresses; using 216.239.51.99
# traceroute to www.l.google.com (216.239.51.99), 16 hops max, 40 byte packets
#  1  192.168.1.1 (192.168.1.1)  1.604 ms  1.144 ms  1.092 ms
#  2  * * *
#  3  ge-1-3-0-130.aggr01.austtx.grandecom.net (66.90.139.62)  23.276 ms  25.650 ms  29.359 ms
#  4  64-129-157-1.static.twtelecom.net (64.129.157.1)  26.433 ms  27.372 ms  18.319 ms
#  5  dist-02-ge-1-2-0-538.ausu.twtelecom.net (66.192.246.189)  14.048 ms  29.342 ms  24.862 ms
#  6  core-01-so-0-0-0-0.chcg.twtelecom.net (66.192.255.93)  56.889 ms  58.022 ms  49.951 ms
#  7  peer-02-so-0-0-0-0.chcg.twtelecom.net (66.192.244.20)  60.212 ms  38.289 ms  53.072 ms
#  8  66.192.252.90 (66.192.252.90)  53.359 ms  42.357 ms  40.335 ms
#  9  66.249.95.253 (66.249.95.253)  43.960 ms  48.586 ms  47.997 ms
# 10  72.14.236.26 (72.14.236.26)  64.988 ms  57.168 ms  46.169 ms
# 11  72.14.238.153 (72.14.238.153)  52.052 ms 72.14.232.147 (72.14.232.147)  52.360 ms  66.071 ms
# 12  72.14.238.190 (72.14.238.190)  61.586 ms 64.233.175.14 (64.233.175.14)  52.055 ms 72.14.238.190 (72.14.238.190)  65.493 ms
# 13  216.239.51.99 (216.239.51.99)  51.702 ms  58.303 ms  60.232 ms
