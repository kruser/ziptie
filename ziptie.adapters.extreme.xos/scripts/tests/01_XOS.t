#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_XOS.t,v 1.3 2008/03/21 21:42:02 rkruse Exp $
#
# tests for the XOS backup Parser
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
use Test::More tests => 60;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Extreme::XOS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataXOS qw($responsesXOS);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "XOSTest.xml";

xos_tests();

sub xos_tests
{
	my $responses = $responsesXOS;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "XOS Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",                                                           "SummitX450-24t" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                  "11.2.3.3" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:fileName",                                                 "primary.cfg" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",                                                     "ExtremeWare XOS" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",                                                          "1.0.0.9" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                           "Router" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                              'support@extremenetworks.com' );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='primary.cfg']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='primary.cfg']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number='1']/name",            "Default" );
	$tester->xpath_test( "/vlans/vlan[number='1']/enabled",         "true" );
	$tester->xpath_test( "/vlans/vlan[number='1']/interfaceMember", "3" );
	$tester->xpath_test( "/vlans/vlan[number='4095']/name",         "Mgmt" );
	$tester->xpath_test( "/vlans/vlan[number='4095']/enabled",      "true" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/maxAge",                  "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/helloTime",               "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/forwardDelay",            "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/priority",                "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/systemMacAddress",        "00049620ACD4" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/designatedRootMaxAge",    "0" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='Default']/designatedRootHelloTime", "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                     'support@extremenetworks.com' );
	$tester->xpath_test( "/snmp/sysName",                                        "SummitX450-24t" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Extreme" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "4.0" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "800143-00-04 0532G-00169" );
	$tester->xpath_test( "/chassis/cpu/core:description",                          "SiByte SB1 V0.3  FPU V0.3" );

	#$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",         "268435456" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                  "268435456" );
	$tester->xpath_test( "/chassis/powersupply[number='1']/core:description", "Internal Power Supply" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceType",                         "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1']/adminStatus",                           "down" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/autoSpeed",           "true" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/autoDuplex",          "true" );
	$tester->xpath_test( "/interfaces/interface[name='3']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='3']/interfaceType",                         "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='3']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='3']/speed",                                 "100000000" );
	$tester->xpath_test( "/interfaces/interface[name='3']/interfaceEthernet/operationalDuplex",   "full" );
	$tester->xpath_test( "/interfaces/interface[name='3']/interfaceIp/ipConfiguration/ipAddress", "10.100.26.5" );
	$tester->xpath_test( "/interfaces/interface[name='3']/interfaceIp/ipConfiguration/mask",      "24" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.1']/destinationMask",    "0.0.0.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "XOS Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessGroup", "admin" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/password",    'uZSl9I$vR7ekrMugwuY8doNHjUWG1' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='user']/accessGroup",    "user" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='user']/password",       'o4H3WS$LGpsiUiHdZRDl15sDE7vf.' );
}

unlink($doc);
1;
