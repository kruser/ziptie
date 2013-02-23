#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Switch3300.t,v 1.2 2008/02/15 19:58:01 dbadilla Exp $
#
# tests for the Switch3300 (3Com) backup Parser
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
use Test::More tests => 57;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::ThreeCom::Switch3300::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataSwitch3300 qw($responsesThreeCom);
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
	$tester->core_model_test( "3300 Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",              "3Com 3300" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",        "3Com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",     "2.66" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",      "3Com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",             "1.00" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",              "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                 "Eric Basham" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",	 "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:promotable", "true" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "3300 Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                     "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                   "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",           "00301e3447b8" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",                  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",               "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",   "00179445ee80" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime",    "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",       "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootCost",       	"41" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "3300 SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/sysContact",	"Eric Basham" );
	$tester->xpath_test( "/snmp/sysLocation",	"Lab" );
	$tester->xpath_test( "/snmp/sysName",		"3Com 3300" );
	$tester->xpath_test( "/snmp/sysObjectId", ".1.3.6.1.4.1.43.10.27.4.1.2.2" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "3300 Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:hardwareVersion",	"2" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",				"3Com" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",		"3C16980" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",		"KZNS43447B8" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "3300 Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='Local Workgroup Encapsulation Tag 9']/physical",                            	"true" );
	$tester->xpath_test( "/interfaces/interface[name='Local Workgroup Encapsulation Tag 9']/interfaceType",                       	"other" );
	$tester->xpath_test( "/interfaces/interface[name='Local Workgroup Encapsulation Tag 9']/adminStatus",                         	"up" );
	$tester->xpath_test( "/interfaces/interface[name='Local Workgroup Encapsulation Tag 9']/mtu", 																	"1500" );
	$tester->xpath_test( "/interfaces/interface[name='Local Workgroup Encapsulation Tag 9']/speed",      						  	"0" );
	
	$tester->xpath_test( "/interfaces/interface[name='802.1Q Encapsulation Tag 3001']/physical",                            	"true" );
	$tester->xpath_test( "/interfaces/interface[name='802.1Q Encapsulation Tag 3001']/interfaceType",                       	"other" );
	$tester->xpath_test( "/interfaces/interface[name='802.1Q Encapsulation Tag 3001']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='802.1Q Encapsulation Tag 3001']/mtu",         	"1500" );
	$tester->xpath_test( "/interfaces/interface[name='802.1Q Encapsulation Tag 3001']/speed",         	"0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "3300 Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='admin']/accessGroup",   'security' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='manager']/accessGroup", 'manager' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessGroup", 'security' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='monitor']/accessGroup", 'monitor' );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "3300 VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number = '2']/enabled" ,  'true');
	$tester->xpath_test( "/vlans/vlan[number = '2']/name" ,  '.15');
	$tester->xpath_test( "/vlans/vlan[number = '2']/interfaceMember" ,  '6');
	$tester->xpath_test( "/vlans/vlan[number = '5']/enabled" ,  'true');
	$tester->xpath_test( "/vlans/vlan[number = '5']/name" ,  'protocol');
	$tester->xpath_test( "/vlans/vlan[number = '5']/interfaceMember" ,  '6');
	$tester->xpath_test( "/vlans/vlan[number = '7']/enabled" ,  'true');
	$tester->xpath_test( "/vlans/vlan[number = '7']/name" ,  'VLAN 7');
	$tester->xpath_test( "/vlans/vlan[number = '7']/interfaceMember" ,  '6');
}

unlink($doc);
1;
