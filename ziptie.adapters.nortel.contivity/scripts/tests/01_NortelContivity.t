#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_NortelContivity.t,v 1.3 2008/05/21 22:26:47 rkruse Exp $
#
# tests for the Nortel Contivity backup Parser
#
# The contents of this file are subject to the Mozilla Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is Ziptie Client Framework.
#
# The Initial Developer of the Original Code is AlterPoint.
# Portions created by AlterPoint are Copyright (C) 2006,
# AlterPoint, Inc. All Rights Reserved.
#
# Contributor(s): rkruse, mkourbanov
# Date: Apr 12, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 49;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nortel::Contivity::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataNortelContivity qw($responsesContivity);
use Data::Dumper;

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "NortelContivityTest.xml";

nortel_contivity_tests();

sub nortel_contivity_tests
{
	my $responses = $responsesContivity;

	my $files_list;
	push @{$files_list}, '/ide0/system/config/CFG00482.DAT';
	push @{$files_list}, '/ide0/system/slapd/db/CFG00482.DAT';
	push @{$files_list}, '/ide0/system/slapd/db/ID2CHILD.DBM';
	push @{$files_list}, '/ide0/system/slapd/db/NEXTID';
	push @{$files_list}, '/ide0/system/slapd/db/UID.DBM';

	# the same algorithm as in GetConfig.pm of Contivity adapter
	# is implemented here to read and store files in the configRepository
	my $old_filepath = "";
	my $hash_sk		 = "";
	my $path2config	 = $0;
	$path2config	 =~ s/\/[^\/]+$//i;
	foreach (@{$files_list})
	{
		my ($filepath,$filename)	= /(.+\/)([^\s\/]+)$/i;
		if ( $filepath ne $old_filepath )
		{
			$old_filepath = $filepath;
			$hash_sk	  = "";
			foreach (split ( /\//, $filepath ))
			{
				$hash_sk .= '->{\''.$_.'\'}' if ( $_ !~ /^\s*$/ );
			}
		}
		open( CONFIG, "$path2config/$filename" );
		binmode(CONFIG);
		eval('$responses->{config}'.$hash_sk.'->{\''.$filename.'\'} = \'\';');
		while ( read( CONFIG, $b, 1 ) )
		{
			eval('$responses->{config}'.$hash_sk.'->{\''.$filename.'\'} .= $b;');
		}
		close(CONFIG);
	}

	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Nortel Contivity Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 			"NYC-Contivity" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "V06_00.310" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",         "PO3" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "VPN Concentrator" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",             "gfarris" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Contivity Filters Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='deny all/in']/filterEntry[processOrder=1]/primaryAction",            		  "deny" );
	$tester->xpath_test( "/filterLists/filterList[name='deny all/in']/filterEntry[processOrder=1]/sourceIpAddr/network/address",  			  "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='deny all/in']/filterEntry[processOrder=1]/sourceIpAddr/network/mask",       		  "32" );
	$tester->xpath_test( "/filterLists/filterList[name='deny all/in']/filterEntry[processOrder=1]/sourceService/portRange/portStart",  		  "0" );
	$tester->xpath_test( "/filterLists/filterList[name='deny all/in']/filterEntry[processOrder=1]/sourceService/portRange/protocol",     		  "TCP" );
	$tester->xpath_test( "/filterLists/filterList[name='deny all/in']/filterEntry[processOrder=1]/sourceService/portRange/portEnd", 			  "65535" );
	$tester->xpath_test( "/filterLists/filterList[name='permit Entrust CA/in']/filterEntry[processOrder=1]/primaryAction",            "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='permit Entrust CA/in']/filterEntry[processOrder=1]/sourceIpAddr/network/address",     "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='permit Entrust CA/in']/filterEntry[processOrder=1]/sourceIpAddr/network/mask",        "32" );
	$tester->xpath_test( "/filterLists/filterList[name='permit Entrust CA/in']/filterEntry[processOrder=1]/sourceService/portExpression/port",  "1023" );
	$tester->xpath_test( "/filterLists/filterList[name='permit Entrust CA/in']/filterEntry[processOrder=1]/sourceService/portExpression/protocol",   "TCP" );
	$tester->xpath_test( "/filterLists/filterList[name='permit Entrust CA/in']/filterEntry[processOrder=1]/sourceService/portExpression/operator",   "gt" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Contivity SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/sysContact",   "gfarris" );
	$tester->xpath_test( "/snmp/sysLocation",  "Planet Earth" );
	$tester->xpath_test( "/snmp/sysName",      "Contivity" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Contivity Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Nortel" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Nortel" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "CES0600D" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "10597" );
	$tester->xpath_test( "/chassis/core:description",                              "CES V06_00.310" );
	$tester->xpath_test( "/chassis/cpu/cpuType",                                   "Celeron" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "0" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "2250244096" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "disk" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "134217728" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Contivity Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='fei']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='fei']/interfaceType",                         "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='fei']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='fei']/interfaceEthernet/macAddress",			"000997757824" );
	$tester->xpath_test( "/interfaces/interface[name='fei']/interfaceIp/ipConfiguration/ipAddress", "10.100.27.5" );
	$tester->xpath_test( "/interfaces/interface[name='fei']/interfaceIp/ipConfiguration/mask", 		"8" );
	$tester->xpath_test( "/interfaces/interface[name='fei']/mtu", 									"1500" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Contivity Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.27.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.27.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.27.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.27.1']/routeMetric", 	   "10" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Contivity Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/password",     	'VtLZh7/Nups=' );
}

unlink($doc);
1;
