#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Aruba.t,v 1.5 2008/05/21 19:07:05 rkruse Exp $
#
# tests for the ArubaOS backup Parser
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
use Test::More tests => 72;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Aruba::ArubaOS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataAruba qw($responsesAruba);
my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";
my $ns     = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';
my $doc = "ArubaTest.xml";
aruba_tests();

sub aruba_tests
{
	my $responses = $responsesAruba;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Aruba Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",              "Aruba800" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:fileName",    "1158273822234.da.cfg" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",        "Aruba" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",     "2.5.3.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",             "1.1.3" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",              "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                 "microsoft" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context", "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context", "boot" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",            "Default" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled",         "true" );
	$tester->xpath_test( "/vlans/vlan[number=1]/interfaceMember", "Fa1/0" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                     "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                   "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",           "000B86503890" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",                  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",               "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",   "000163BBC34A" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime",    "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",       "20" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Filters Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='vocera-acl']/filterEntry[processOrder=1]/log",                     "false" );
	$tester->xpath_test( "/filterLists/filterList[name='vocera-acl']/filterEntry[processOrder=1]/primaryAction",           "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='vocera-acl']/filterEntry[processOrder=1]/sourceService/portExpression/protocol",  "UDP" );
	$tester->xpath_test( "/filterLists/filterList[name='vocera-acl']/filterEntry[processOrder=1]/sourceService/portExpression/port", "5002" );
	$tester->xpath_test( "/filterLists/filterList[name='vocera-acl']/filterEntry[processOrder=1]/sourceIpAddr/network/address",    "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='vocera-acl']/filterEntry[processOrder=1]/sourceIpAddr/network/mask",       "0" );
	$tester->xpath_test( "/filterLists/filterList[name='svp-acl']/filterEntry[processOrder=2]/sourceService/portExpression/protocol",     "TCP" );
	$tester->xpath_test( "/filterLists/filterList[name='svp-acl']/filterEntry[processOrder=2]/sourceService/portExpression/port",    "0" );
	$tester->xpath_test( "/filterLists/filterList[name='svp-acl']/filterEntry[processOrder=2]/sourceService/portExpression/operator",     "eq" );
	$tester->xpath_test( "/filterLists/filterList[name='svp-acl']/filterEntry[processOrder=2]/destinationIpAddr/network/address",  "224.0.1.116" );
	$tester->xpath_test( "/filterLists/filterList[name='svp-acl']/filterEntry[processOrder=2]/destinationIpAddr/network/mask", "32" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                     "microsoft" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "Building1.floor1" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make", "Aruba" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber", "800" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "A10000910" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                                           "PARTITION 0" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                                           "162738995" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                                    "disk" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='1158273822234.da.cfg']/size", "15610" );
	$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",                      "32768" );
	$tester->xpath_test( "/chassis/memory[kind='Flash']/size",                                    "134217728" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/physical",                            "false" );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/description",                         "gig1/8" );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/interfaceType",                       "other" );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/adminStatus",                         "up" );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/interfaceEthernet/autoSpeed",         "true" );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/interfaceEthernet/autoDuplex",        "true" );
	$tester->xpath_test( "/interfaces/interface[name='1/8']/interfaceEthernet/macAddress",        "000B86503899" );
	$tester->xpath_test( "/interfaces/interface[name='1']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='1']/description",                           "802.1Q VLAN" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='1']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/macAddress",          "000B86503890" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceIp/ipConfiguration/ipAddress", "10.100.26.3" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationMask",    "0.0.0.0" );
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='admin']/accessLevel",   '1' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessLevel", '1' );
}
unlink($doc);
1;
