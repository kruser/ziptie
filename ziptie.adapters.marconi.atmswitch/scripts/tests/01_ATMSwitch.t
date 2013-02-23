#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_ATMSwitch.t,v 1.3 2008/03/21 21:42:01 rkruse Exp $
#
# tests for the ATM Switch backup Parser
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
use Test::More tests => 51;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Marconi::ATMSwitch::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataATMSwitch qw($responsesATM);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "ATMSwitchTest.xml";

atmswitch_tests();

sub atmswitch_tests
{
	my $responses = $responsesATM;

	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "ATMSwitch Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "ESX-3000-2 CONFIG-A" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "Marconi" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",     "ForeThought" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "7.1.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "FT" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",			 "FT7.1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              "Unknown" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ATMSwitch Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Marconi" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "esx3000" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "99440505" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:make",			 "Marconi" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:hardwareVersion", "8" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:modelNumber",     "12-155MMSC-PC-1" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:serialNumber",    "99500568" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "30260455" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "flash" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "134217728" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ATMSwitch Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.1']/routeMetric",   	   "1" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.1']/interface",          "ie0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.2']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.2']/destinationAddress", "10.100.17.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.2']/destinationMask",    "255.255.255.255" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.2']/interface",          "ie0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.17.2']/routeMetric",    	   "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ATMSwitch Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='ie0']/physical",                                "false" );
	$tester->xpath_test( "/interfaces/interface[name='ie0']/adminStatus",                             "up" );
	$tester->xpath_test( "/interfaces/interface[name='ie0']/interfaceType",                           "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='ie0']/interfaceIp/ipConfiguration/ipAddress",   "10.100.17.2" );
	$tester->xpath_test( "/interfaces/interface[name='ie0']/interfaceIp/ipConfiguration/mask",        "24" );
	$tester->xpath_test( "/interfaces/interface[name='ie0']/speed", 							      "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='lo0']/physical",                                "false" );
	$tester->xpath_test( "/interfaces/interface[name='lo0']/adminStatus",                             "up" );
	$tester->xpath_test( "/interfaces/interface[name='lo0']/interfaceType",                           "softwareLoopback" );
	$tester->xpath_test( "/interfaces/interface[name='lo0']/interfaceIp/ipConfiguration/ipAddress",   "127.0.0.1" );
	$tester->xpath_test( "/interfaces/interface[name='lo0']/interfaceIp/ipConfiguration/mask",        "8" );
	$tester->xpath_test( "/interfaces/interface[name='5A2']/physical",                                "false" );
	$tester->xpath_test( "/interfaces/interface[name='5A2']/adminStatus",                             "up" );
	$tester->xpath_test( "/interfaces/interface[name='5A2']/interfaceType",                           "other" );
	$tester->xpath_test( "/interfaces/interface[name='5A2']/speed",			                          "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='5A2']/interfaceEthernet/operationalDuplex",     "half" );
=head
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 Spanning Tree Test", ( \&parse_stp ) );
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
