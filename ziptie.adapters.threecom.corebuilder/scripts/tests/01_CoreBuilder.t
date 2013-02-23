#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_CoreBuilder.t,v 1.2 2008/02/20 23:33:57 dbadilla Exp $
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
# Contributor(s): dbadilla
# Date: Jan 23rd, 2008
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 32;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::ThreeCom::CoreBuilder::Parsers
  qw(create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_stp parse_static_routes);
use ZipTie::TestElf;
use DataCoreBuilder qw($responsesCoreBuilder);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "CoreBuilder.xml";

corebuilder_tests();


sub corebuilder_tests
{
	my $responses = $responsesCoreBuilder;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "ThreeCom CoreBuilder Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 					"SuperStack II Switch-9ECE61" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",	"1.0.1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",		"3Com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType", 					"Switch" );
	
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config/core:context", 	"active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config/core:mediaType", "text/plain");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config/core:promotable","false");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config/core:name", "config");

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeCom CoreBuilder SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", 	"RO" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType", "RW" );
	$tester->xpath_test( "/snmp/sysName",          "SuperStack II Switch-9ECE61" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeCom CoreBuilder Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:assetType",      	"Chassis" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",      	"3Com" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  	"9300" );
	$tester->xpath_test( "/chassis/memory[kind='Other']/size",                   "8388608" );
	$tester->xpath_test( "/chassis/memory[kind='Flash']/size",                 "2097152" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeCom CoreBuilder Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1']/physical",  "true");
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/autoDuplex", "true");
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/macAddress", '00803E9ECE62');
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/operationalDuplex", "full" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceType", "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1']/adminStatus", "down" );
	$tester->xpath_test( "/interfaces/interface[name='1']/speed", "10000000" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeCom CoreBuilder Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute/gatewayAddress", 		 "10.100.21.1" );
	
	
}

unlink($doc);
1;
