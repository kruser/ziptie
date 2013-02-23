#! /usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;
use FindBin;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Utils qw(choose_admin_ip seconds_since_epoch mask_to_bits);
use ZipTie::Adapters::EnterpriseNumbers;

# test for Jan 20th, 2007 @ 01:20:30 CST
ok( seconds_since_epoch( 30, 20, 1, 20, 'Jan', 2007, 'CST' ) eq '1169277630', 'test seconds_since_epoch' );

# Enterprise Numbers tests
my $returnValue1 = ZipTie::Adapters::EnterpriseNumbers::get_enterprise_name(".1.3.6.1.4.1.29343");
ok( $returnValue1 eq "Grundig SAT-Systems GmbH", "EnterpriseNumbers test 1" );

my $returnValue2 = ZipTie::Adapters::EnterpriseNumbers::get_enterprise_name(".1.3.6.1.4.1.352");
ok( $returnValue2 eq "Open Networks Engineering, Inc.", "EnterpriseNumbers test 2" );

ok( '24' eq mask_to_bits('255.255.255.0'), '24 bit mask test' );
ok( '16' eq mask_to_bits('255.255.0.0'),   '16 bit mask test' );
ok( '16' eq mask_to_bits('16'),            'Convert the unconvertable mask' );

# Test the choose_admin_ip function
my $interfaces = {
	'interface' => [
		{
			'operStatus' => 'Up',
			'name'       => 'Ethernet0/0',
			'type'       => 'ethernet',
			'ipEntry'    => [
				{
					'ipAddress' => '10.100.8.10',
					'mask'      => '29'
				}
			],
			'inputBytes' => '873995991'
		},
		{
			'operStatus' => 'Down',
			'name'       => 'Serial0/0',
			'type'       => 'serial',
			'inputBytes' => '0'
		},
		{
			'operStatus' => 'Up',
			'name'       => 'Ethernet0/1',
			'type'       => 'ethernet',
			'ipEntry'    => [
				{
					'ipAddress' => '10.100.8.25',
					'mask'      => '29'
				}
			],
			'inputBytes' => '1194740983'
		},
		{
			'operStatus' => 'Up',
			'name'       => 'Loopback0',
			'type'       => 'softwareLoopback',
			'ipEntry'    => [
				{
					'ipAddress' => '10.100.8.151',
					'mask'      => '32'
				}
			],
			'inputBytes' => '0'
		}
	]
};

ok( '10.100.8.151'  eq choose_admin_ip( '10.100.8.10',   $interfaces ), 'Choose admin IP' );
ok( '10.100.20.100' eq choose_admin_ip( '10.100.20.100', $interfaces ), 'Choose admin IP of a NAT device' );
