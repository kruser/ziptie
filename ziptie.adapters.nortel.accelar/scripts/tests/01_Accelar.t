#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Accelar.t,v 1.4 2008/03/27 19:25:46 rkruse Exp $
#
# tests for the Nortel Accelar backup Parser
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
# Contributor(s): dbadilla
# Date: Jan 08, 2008
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 100;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nortel::Accelar::Parsers
  qw( create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataAccelar qw($responsesAccelar);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "AccelarTest.xml";

accelar_tests();

sub accelar_tests
{
	my $responses = $responsesAccelar;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Accelar Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",          "Accelar-1100" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",    "Nortel" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "2.0.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",         "v2.0.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "Router" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",             "satish" );

	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",    "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType",  "text/plain" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:name",       "config" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:promotable", "false" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",               "Default" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled",            "true" );
	$tester->xpath_test( "/vlans/vlan[number=1]/implementationType", "byPort" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootCost",         "33" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "49" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime",    "200" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",   "00179445EE80" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",       "2000" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootPort",         "3/1" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",               "1500" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",                  "200" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/holdTime",                   "1500" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                     "2000" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                   "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",           "00E016811E01" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/vlan",                       "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='austintestcommunity2']/accessType", "RW" );
	$tester->xpath_test( "/snmp/community[communityString='austintestcommunity']/accessType",  "RW" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType",              "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                                   "satish" );
	$tester->xpath_test( "/snmp/sysLocation",                                                  "Downtown" );
	$tester->xpath_test( "/snmp/sysName",                                                      "Accelar-1100" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:assetType",                                           "Chassis" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                               "Nortel" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:revisionNumber",                     "v3.0" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                       "601SZ" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:assetType",                        "Card" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion", "v1.0" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:partNumber",      "875A06" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",    "DA08P" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:description",                                 "1000BaseLXWG" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/portCount",                                        "1" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/status",                                           "up" );

	$tester->xpath_test( "/chassis/card[slotNumber=2]/core:asset/core:assetType",                        "Card" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/core:asset/core:factoryinfo/core:hardwareVersion", "v1.0" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/core:asset/core:factoryinfo/core:partNumber",      "593F00" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/core:asset/core:factoryinfo/core:serialNumber",    "B0110" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/core:description",                                 "1000BaseSXWG" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/portCount",                                        "2" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/status",                                           "up" );

	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:assetType",                        "Card" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:hardwareVersion", "v3.0" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:partNumber",      "615d00" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:asset/core:factoryinfo/core:serialNumber",    "601SZ" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/core:description",                                 "100BaseTXWG" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/portCount",                                        "16" );
	$tester->xpath_test( "/chassis/card[slotNumber=3]/status",                                           "up" );

	$tester->xpath_test( "/chassis/deviceStorage/size",                               "4194128" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                        "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/freeSpace",                          "982864" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                               "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='acc2.0.0']/size", "1805432" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='acc1.1.1']/size", "994730" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='syslog']/size",   "131072" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='config']/size",   "5688" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='old.cfg']/size",  "5788" );

	$tester->xpath_test( "/chassis/powersupply/core:asset/core:assetType", "PowerSupply" );
	$tester->xpath_test( "/chassis/powersupply/core:description",          " 110V AC Power Supply" );
	$tester->xpath_test( "/chassis/powersupply/number",                    "1" );
	$tester->xpath_test( "/chassis/powersupply/status",                    "up" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='Port3/16']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='Port3/16']/interfaceIp/ipConfiguration/ipAddress", "11.1.1.1" );
	$tester->xpath_test( "/interfaces/interface[name='Port3/16']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface[name='Port3/16']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceIp/ipConfiguration/ipAddress",    "10.100.31.17" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceIp/ipConfiguration/mask",         "24" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/physical",                                 "false" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceType",                            "other" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.1']/defaultGateway",      "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.1']/destinationAddress",  "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.1']/destinationMask",     "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.1']/interface",           "3/1" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.1']/routeMetric",         "1" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.17']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.17']/destinationAddress", "10.100.31.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.17']/destinationMask",    "255.255.255.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.17']/interface",          "-/-" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.31.17']/routeMetric",        "1" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Accelar Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='rw']/accessGroup",    "rw" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='rw']/password",       'rw' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='franz']/accessGroup", "ro" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='franz']/password",    'kafka' );
}

unlink($doc);
1;
