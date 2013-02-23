#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_PowerConnect.t,v 1.1 2008/02/08 23:16:29 rkruse Exp $
#
# tests for the Dell PowerConnect backup Parser
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
use Test::More tests => 63;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Dell::PowerConnect::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataPowerConnect qw($responsesDPC);

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "DPCTest.xml";
dpc_tests();

sub dpc_tests
{
	my $responses = $responsesDPC;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Dell PowerConnect Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",              "Dellswitch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",        "Dell" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",     "1.2.0.6" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",             "1.0.0.13" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",              "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                 "hoops" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context",    "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context",    "boot" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:promotable", "true" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Dell PowerConnect Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",			   "Dell" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:hardwareVersion",  "00.00.01" );
	$tester->xpath_test( "/chassis/core:description", 								   "Management port with autocrossover" );
	$tester->xpath_test( "/chassis/powersupply/description",                   		   "Internal PowerSupply unit1" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Dell PowerConnect Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/physical",                            "false" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceType",                       "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/adminStatus",                         "up" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceEthernet/autoDuplex",        "false" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceEthernet/operationalDuplex", "full" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceEthernet/mediaType",         "100M-Copper" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceSpanningTree/cost",          "19" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceSpanningTree/state",         "forwarding" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/interfaceSpanningTree/priority",      "128" );
	$tester->xpath_test( "/interfaces/interface[name='1/e1']/speed",    						   "100" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/physical",                            "false" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceType",                       "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/adminStatus",                         "up" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceEthernet/autoDuplex",        "false" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceEthernet/operationalDuplex", "full" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceEthernet/mediaType",         "1G-Combo-C" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/speed",    						   "1000" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceSpanningTree/cost",          "100" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceSpanningTree/state",         "disabled" );
	$tester->xpath_test( "/interfaces/interface[name='1/g1']/interfaceSpanningTree/priority",      "128" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Dell PowerConnect SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",	 "RO" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType",	 "RW" );
	$tester->xpath_test( "/snmp/community[communityString='testing321']/accessType", "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                     	 "hoops" );
	$tester->xpath_test( "/snmp/sysLocation",                                    	 "Testing12345" );
	$tester->xpath_test( "/snmp/sysName",                                        	 "Dellswitch" );
	$tester->xpath_test( "/snmp/trapHosts[communityString='public']/ipAddress",		 "10.10.1.95" );
	$tester->xpath_test( "/snmp/trapHosts[communityString='testenv']/ipAddress",	 "10.10.1.119" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Dell PowerConnect Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='brandon']/accessLevel", "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='brandon']/password",    '7baa6d93380e30bd4a30d83c977d505b' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='bshopp']/accessLevel",   "7" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='bshopp']/password",     '7baa6d93380e30bd4a30d83c977d505b' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/accessLevel",   "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/password",     	'c7c54e3f90b1bc36934a6a68202d1b6d' );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Dell PowerConnect Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",   "000BDBF48514" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime", 	"2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",	    "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootPriority",     "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                     "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",                  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",               "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                   "24779" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",           "00179445EE80" );
	
}

unlink($doc);
1;
