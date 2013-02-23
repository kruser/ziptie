# SSH to a device and issue some commands
use strict;
use ZipTie::Logger;
use ZipTie::SSH;

my $device = $ARGV[0];
my $logger = ZipTie::Logger->get_logger();
if (!$device)
{
	$device = '10.100.20.212';
	$logger->set_logging_level('0');
}
my $prompt = '\w\S+[#>]\s*$';
my $ssh = ZipTie::SSH->new();
$ssh->set_more_prompt( '--More--\s*$', '20' );
$ssh->connect( $device, '22', 'testlab', 'hobbit' );
$ssh->wait_for($prompt);
$ssh->send('enable');
my $response = $ssh->wait_for('assword:\s*|'.$prompt);
if ($response =~ /assword/)
{
	$ssh->send('bigtex');
	$ssh->wait_for($prompt);
}
$ssh->send('term len 0');
$ssh->wait_for($prompt);
$ssh->send('show running-config');
$ssh->wait_for($prompt);
$ssh->send('show startup-config');
$ssh->wait_for($prompt);
$ssh->send('show interfaces');
$ssh->wait_for($prompt);
$ssh->send('show version');
$ssh->wait_for($prompt);
$ssh->send('exit');