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
	$page = $client->telemetry()->getArpTable(pageData => $page, ipAddress => $ip, managedNetwork => "Default", );
	my $arpTable = $page->{arpEntries};
	foreach my $arpEntry (ref($arpTable) eq 'HASH' ? $arpTable : @$arpTable)
	{
		my $ip        = $arpEntry->{ipAddress};
		my $mac       = $arpEntry->{macAddress} || "";
		my $interface = $arpEntry->{interfaceName};

		print("$ip,$mac,$interface\n");
	}
	$offset += $page->{pageSize};
} while ( $page->{total} > $offset );
