#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_SSR.t,v 1.2 2008/03/21 21:41:56 rkruse Exp $
#
# tests for the SSR Switch backup Parser
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
use Test::More tests => 48;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Enterasys::SSR::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataSSR qw($responsesSSR);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "SSRTest.xml";

ssr_tests();

sub ssr_tests
{
	my $responses = $responsesSSR;

	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "SSR Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "IPM-2000" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "Motorola" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:fileName", "boot/xp9075/" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "E9.0.7.5" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "IPM" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",			 "prom-E3.0.0.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              "Change1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='active-config']/core:context",  "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context", "boot" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SSR Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",        					     "Motorola" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber", 				         "IPM 2000" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:hardwareVersion",					 "CPU-IPM2" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:make",			 "Motorola" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion", "1.0" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:modelNumber",     "Unknown" );
	$tester->xpath_test( "/chassis/cpu/cpuType",   														 "R5000" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                    						 "134217728" );
	$tester->xpath_test( "/chassis/memory[kind='Flash']/size",                       					 "8388608" );
	$tester->xpath_test( "/chassis/memory[kind='Other']/size",                       					 "8388608" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SSR Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/interface",          "manage" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.0']/defaultGateway",     "false" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.0']/destinationAddress", "10.100.2.0" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.0']/destinationMask",    "255.255.255.0" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.0']/interface",          "manage" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SSR Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/physical",                               "true" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/adminStatus",                            "up" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/interfaceType",                          "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/speed",			                        "100000000" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/mtu",   									"1500" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/interfaceIp/ipConfiguration/ipAddress",  "10.100.2.8" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/interfaceIp/ipConfiguration/mask",       "24" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/interfaceEthernet/operationalDuplex",   	"full" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.1']/interfaceEthernet/macAddress",    		"0004BD2A6580" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.2']/physical",                               "true" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.2']/adminStatus",                            "up" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.2']/interfaceType",                          "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.2']/speed",			                        "100000000" );
	$tester->xpath_test( "/interfaces/interface[name='et.1.2']/interfaceEthernet/operationalDuplex",   	"half" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SSR SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='Brandon']/accessType",   "RO" );
	$tester->xpath_test( "/snmp/community[communityString='Shopp']/accessType",     "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                        "Change1" );
	$tester->xpath_test( "/snmp/sysLocation",                                       "Test12345" );
	$tester->xpath_test( "/snmp/sysName",                                     		"IPM-2000" );

=head
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SSR Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                   "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",         "0002BA62B400" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress", "0002BA62B400" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",				  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay", 			  "15" );
=cut
}

unlink($doc);
1;
