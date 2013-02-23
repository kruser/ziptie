#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_ExtremeSwitch.t,v 1.2 2007/11/15 02:30:32 rkruse Exp $
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
use Test::More tests => 30;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Extreme::Switch::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataExtremeSwitch qw($responsesExtremeSwitch);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "ExtremeSwitchTest.xml";

extremeswitch_tests();

sub extremeswitch_tests
{
	my $responses = $responsesExtremeSwitch;
	my $tester = ZipTie::TestElf->new( $responses, $doc );

	$tester->core_model_test( "Extreme Switch Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 															  "MIA-Extreme300" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "7.4e.3.5" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion", 														  "5.1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact", 														  	  "Pitest3" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Switch" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Extreme Switch Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                                                      	"Extreme" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                                                   "Summit300-24" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                                                  "800138-00-03" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                                                        "134217728" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Extreme Switch SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='jude']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                   "Pitest3" );
	$tester->xpath_test( "/snmp/sysLocation",                                  "Alterpoint Lab1" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Extreme Switch Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.5.4']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.5.4']/destinationAddress", "10.100.5.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.5.4']/destinationMask",    "255.255.255.0" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Extreme Switch VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",             "Default" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled",          "true" );
	$tester->xpath_test( "/vlans/vlan[number=12]/name",            "vlan12" );
	$tester->xpath_test( "/vlans/vlan[number=12]/enabled",         "true" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Extreme Switch Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='vlan12 Default']/designatedRootCost",                   "0" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='vlan12 Default']/designatedRootForwardDelay",           "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='vlan12 Default']/designatedRootMaxAge",                 "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='vlan12 Default']/forwardDelay",        				  "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='vlan12 Default']/helloTime",				 			  "2" );
}

unlink($doc);
1;
