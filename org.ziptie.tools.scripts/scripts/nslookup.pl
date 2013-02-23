
use strict;
use Socket;

# Get the device
my $device = shift(@ARGV);
my ($name,$status);
$name =gethostbyaddr(inet_aton($device),AF_INET);

if (length($name)>0) {
	$status = "OK";
}else {
	$status = "WARN";
}

print "$status,$device,$name\n\n";