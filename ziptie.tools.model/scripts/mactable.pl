#!/usr/bin/perl
use strict;

use ZipTie::Client;
use ZipTie::Logger;

my $ip = $ARGV[0];

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my $client = ZipTie::Client->new();
my $page = { pageSize => 100 };

my $offset = 0;
do
{
	$page->{offset} = $offset;
	$page = $client->telemetry()->getMacTable(pageData => $page, ipAddress => $ip, managedNetwork => "Default", );
	my $macTable = $page->{macEntries};
	foreach my $macEntry (ref($macTable) eq 'HASH' ? $macTable : @$macTable)
	{
		my $mac       = $macEntry->{macAddress};
		my $port = $macEntry->{port};
		my $vlan = $macEntry->{vlan} || "";

		print("$mac,$port,$vlan\n");
	}
	$offset += $page->{pageSize};
} while ( $page->{total} > $offset );
