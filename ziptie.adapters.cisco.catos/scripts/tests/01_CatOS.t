#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_CatOS.t,v 1.2 2008/03/21 21:42:00 rkruse Exp $
#
# tests for the SecurityAppliance backup Parser
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
use Test::More tests => 134;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::CatOS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_vtp);
use ZipTie::TestElf;
use DataCatOS5000 qw($responsesCatOS5000);
use DataCatOS5500 qw($responsesCatOS5500);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "CatOSTest.xml";

catos_5000_tests();
catos_5500_tests();

sub catos_5000_tests
{
	my $responses = $responsesCatOS5000;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "CatOS5000 Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 															  "LON-C5000" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "6.4(10)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                               "pitest1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context", 		  "N/A" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1003]/name",             "trcrf-default" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/parent",           "1005" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/said",			  "101003" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/backupCRFEnabled", "false" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/configSource", 	  "learned" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/name",             "trbrf-default" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/said",             "101005" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/interfaceMember",  "1003" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/mtu", 			  "4472" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/configSource",	  "learned" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/bridgeNumber", 	  "15" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/maxAge",                   "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/systemMacAddress",         "0002BA62B400" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/designatedRootMacAddress", "0002BA62B400" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/helloTime",				  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/forwardDelay", 			  "15" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 VTP Test", ( \&parse_vtp ) );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:alarmNotificationEnabled", "true" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:configVersion",            "0" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:domainName",           	   "test12" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:localMode",                "Transparent" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:maxVlanCount",             "1023" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:v2Mode",                   "enabled" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:version",                  "2" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:vlanCount",                "8" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:vlanPruningEnabled",       "false" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                     "pitest1" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "ABC's London Office" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                                                      	"Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                                                   "WS-C5000" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                                                  "021230524" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion",                            "1.2" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:modelNumber",                                "WS-X5550" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",                               "00021230524" );
	$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",                                                        "524288" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                                                        "33554432" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/description",                           "slip" );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/description",         					"vlan" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/interfaceIp/ipConfiguration/ipAddress", "192.168.5.3" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/interfaceIp/ipConfiguration/mask", 		"24" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/adminStatus",                           "up" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.3']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.3']/destinationAddress", "192.168.5.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.3']/destinationMask",    "255.255.255.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.3']/interface", 		   "sc0" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5000 Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='password']/accessLevel",     "0" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='password']/password",     	'$2$fLsD$1XeXFWX8JfZKzOJ2rv8C90' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enablepass']/accessLevel",   "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enablepass']/password",     	'$2$rFnA$gyC9cbBFm6NleslBcJ//d1' );
}

sub catos_5500_tests
{
	my $responses = $responsesCatOS5500;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "CatOS5500 Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 															  "DAL-C5500" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "6.4(2)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context", 		  "N/A" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1003]/name",             "token-ring-default" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/said",			  "101003" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/mtu",			  "1500" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/backupCRFEnabled", "false" );
	$tester->xpath_test( "/vlans/vlan[number=1003]/areHops", 		  "7" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/name",             "trnet-default" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/said",             "101005" );
	$tester->xpath_test( "/vlans/vlan[number=1005]/mtu", 			  "1500" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/maxAge",                   "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/systemMacAddress",         "001011E82300" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/designatedRootMacAddress", "00179445EE80" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/helloTime",				  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='1']/forwardDelay", 			  "15" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 VTP Test", ( \&parse_vtp ) );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:alarmNotificationEnabled", "false" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:configVersion",            "0" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:localMode",                "Server" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:maxVlanCount",             "1023" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:v2Mode",                   "disabled" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:vlanCount",                "5" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:vlanPruningEnabled",       "false" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "PQR's Dallas Office" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                                                      	"Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                                                   "WS-C5500" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                                                  "069012487" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion",                            "1.9" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:modelNumber",                                "WS-X5530" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",                               "00009996959" );
	#$tester->xpath_test( "/chassis/card[slotNumber=1]/daughterCard[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion", "1.0" );
	#$tester->xpath_test( "/chassis/card[slotNumber=1]/daughterCard[slotNumber=1]/core:asset/core:factoryinfo/core:modelNumber",     "WS-F5521" );
	#$tester->xpath_test( "/chassis/card[slotNumber=1]/daughterCard[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",    "0010434283" );
	$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",                                                        "524288" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                                                        "67108864" );
	$tester->xpath_test( "/chassis/memory[kind='Flash']/size",                                                                      "8388608" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                                                                             "c5500 bootflash" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                                                                           	"7602176" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                                                                      "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='cat5000-sup3.4-5-11.bin']/size",                                "3473239" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/description",                           "slip" );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='sl0']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/description",         					"vlan" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/interfaceIp/ipConfiguration/ipAddress", "10.100.24.3" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/interfaceIp/ipConfiguration/mask", 		"24" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='sc0']/adminStatus",                           "up" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.24.3']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.24.3']/destinationAddress", "10.100.24.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.24.3']/destinationMask",    "255.255.255.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.24.3']/interface", 		   "sc0" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CatOS5500 Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='password']/accessLevel",     "0" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='password']/password",     	'$2$Za1a$aAGkOfRNKXGKNF29C7ToF/' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enablepass']/accessLevel",   "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enablepass']/password",     	'$2$Cq.J$HexO1pPflmmQWsFcx9CZ60' );
}

unlink($doc);
1;
