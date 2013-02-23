#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Passport1600.t,v 1.2 2008/03/21 21:41:59 rkruse Exp $
#
# tests for the Nortel Passport16xx backup Parser
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
use Test::More tests => 54;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nortel::Passport1600::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataPassport1600 qw($responsesNP1600);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "Passport16xxTest.xml";

passport1600_tests();

sub passport1600_tests
{
	my $responses = $responsesNP1600;

	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Passport16xx Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "passport1612g" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "Nortel" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",     "Passport-1612G" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "1.2.1.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "Passport" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",			 "0.00.003" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              "pablo" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Passport16xx Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",				"Nortel" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",		"Unknown" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:firmwareVersion",	"KKKKKKKK" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:hardwareVersion",	"5A1" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",		"SDLI2G004M" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Passport16xx Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/defaultGateway",      "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationAddress",  "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationMask",     "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/routePreference",     "60" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/interface",           "System" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.25']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.25']/destinationAddress", "10.100.2.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.25']/destinationMask",    "255.255.255.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.25']/interface",          "System" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.25']/routePreference",    "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Passport16xx Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1']/physical",									"true" );
	$tester->xpath_test( "/interfaces/interface[name='1']/adminStatus",									"down" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceType",								"ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceIp/ipConfiguration/ipAddress",		"10.100.2.25" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceIp/ipConfiguration/mask",			"24" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/cost",					"4" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/priority",				"128" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/spanningTreeInstance",	"s0" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/state",					"disabled" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/physical",									"true" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/adminStatus",									"up" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/interfaceType",								"ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/interfaceIp/ipConfiguration/ipAddress",		"10.100.2.25" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/interfaceIp/ipConfiguration/mask",			"24" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/interfaceEthernet/operationalDuplex",			"full" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt_port']/speed",										"100000000" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Passport16xx Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessGroup","Admin" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Passport16xx Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                   "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",      		    "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",      		"15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress", "000CF70DD000" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootCost", 		"0" );
}

unlink($doc);
1;
