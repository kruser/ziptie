#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Switch4400.t,v 1.1 2008/01/25 01:10:28 mkourbanov Exp $
#
# tests for the Switch4400 (3Com) backup Parser
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
use ZipTie::Adapters::ThreeCom::Switch4400::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataSwitch4400 qw($responsesThreeCom);
my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";
my $ns     = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';
my $doc = "3ComTest.xml";
three_com_tests();

sub three_com_tests
{
	my $responses = $responsesThreeCom;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Aruba Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",              "3Com4400" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",        "3Com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",     "3.21" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",      "3Com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",             "2.21" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",              "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                 "chg5" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",	 "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:promotable", "true" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                     "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                   "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",           "000a04dea6c0" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",                  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",               "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",   "00179445ee80" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime",    "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",       "20" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/sysContact",	"chg5" );
	$tester->xpath_test( "/snmp/sysLocation",	"testing" );
	$tester->xpath_test( "/snmp/sysName",		"3Com4400" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:hardwareVersion",	"05.02.00" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",				"3Com" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",		"3C17203" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",		"7PVV1Q7DEA6C0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1:1']/physical",                            	"true" );
	$tester->xpath_test( "/interfaces/interface[name='1:1']/interfaceType",                       	"ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1:1']/adminStatus",                         	"up" );
	$tester->xpath_test( "/interfaces/interface[name='1:1']/interfaceEthernet/operationalDuplex", 	"full" );
	$tester->xpath_test( "/interfaces/interface[name='1:1']/interfaceEthernet/mediaType",         	"10BASE-T/100BASE-TX" );
	$tester->xpath_test( "/interfaces/interface[name='1:1']/speed",      						  	"100000000" );
	$tester->xpath_test( "/interfaces/interface[name='1:2']/physical",                            	"true" );
	$tester->xpath_test( "/interfaces/interface[name='1:2']/interfaceType",                       	"ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1:2']/adminStatus",                           "down" );
	$tester->xpath_test( "/interfaces/interface[name='1:2']/interfaceEthernet/autoDuplex",         	"true" );
	$tester->xpath_test( "/interfaces/interface[name='1:2']/interfaceEthernet/mediaType",         	"10BASE-T/100BASE-TX" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationMask",    "0.0.0.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Aruba Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='admin']/accessGroup",   'security' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='brandon']/accessGroup", 'manager' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessGroup", 'security' );
}

unlink($doc);
1;
