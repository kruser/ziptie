#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_FoundryFastIron.t,v 1.6 2008/07/23 16:46:42 rkruse Exp $
#
# tests for the Foundry FastIron backup Parser
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
use Test::More tests => 56;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Foundry::FastIron::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataFoundryFastIron qw($responsesFastIron);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "FoundryFastIronTest.xml";

foundryfastiron_tests();

sub foundryfastiron_tests
{
	my $responses = $responsesFastIron;

	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Foundry FastIron Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",                                                              "BigIron" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",                                                        "Foundry" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                     "07.6.02T53" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",                                                      "Iron Software" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",                                                             "07.06.02" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                              "Router" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                                 "gfarris" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Foundry FastIron Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                          "Foundry" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                   "BigIron 4000 Router" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                        "262144" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:partNumber", "B8GMR" );
	$tester->xpath_test( "/chassis/card[slotNumber=2]/core:asset/core:factoryinfo/core:partNumber", "B24E" );       
	$tester->xpath_test( "/chassis/deviceStorage/name",                                             "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                                      "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                                             "8388608" );
	$tester->xpath_test( "/chassis/powersupply/number",                                             "1" );
	$tester->xpath_test( "/chassis/powersupply/status",                                             "ok" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Foundry FastIron SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='.....']/accessType",     "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                        "gfarris" );
	$tester->xpath_test( "/snmp/sysLocation",                                       "Austin-Alterpoint" );
	$tester->xpath_test( "/snmp/sysName",                                           "BigIron" );
	$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.10.1.30']/communityString", "....." );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Foundry FastIron Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/routeMetric",        "1" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Foundry FastIron Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/speed",                                 "100000000" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/mtu",                                   "1518" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/interfaceIp/ipConfiguration/ipAddress", "10.100.21.3" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/interfaceEthernet/macAddress",          "00E052C15837" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/24']/interfaceEthernet/operationalDuplex",   "full" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/23']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/23']/adminStatus",                           "down" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/23']/mtu",                                   "1518" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/23']/interfaceEthernet/macAddress",          "00E052C15836" );
	$tester->xpath_test( "/interfaces/interface[name='FastEthernet2/23']/interfaceEthernet/operationalDuplex",   "full" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Foundry FastIron Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/password", "....." );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Foundry FastIron Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/maxAge",                   "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/systemMacAddress",         "00e05202fea4" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/designatedRootMacAddress", "00179445ee80" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/designatedRootPriority",   "128" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/helloTime",                "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/forwardDelay",             "15" );
}

unlink($doc);
1;
