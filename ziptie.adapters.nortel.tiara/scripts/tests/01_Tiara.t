#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Tiara.t,v 1.1 2008/02/05 17:53:33 dbadilla Exp $
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
# Date: Feb 1st, 2008
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
use ZipTie::Adapters::Nortel::Tiara::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp );
use ZipTie::TestElf;
use DataTiara qw($responsesTiara);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "TiaraTest.xml";

tiara_tests();

sub tiara_tests
{
	my $responses = $responsesTiara;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Tiara Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 															  "Tasman-1200" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                          "r8.2.1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",                          "TiOS" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",                          "Tasman" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                               "Router" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                              "change2" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context", "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:mediaType", "text/plain");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:promotable", "false");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context","boot");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:mediaType","text/plain");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:promotable","true");


	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Tiara SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType", "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                     "change2" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "costarica" );
	$tester->xpath_test( "/snmp/sysDescr",                                    "Tasman Networks Inc. Snmp Agent" );
	$tester->xpath_test( "/snmp/sysName",                                    "Tasman-1200" );
	$tester->xpath_test( "/snmp/sysObjectId",                                    ".1.3.6.1.4.1.3174.1.7" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Tiara Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:assetType",                                    	"Chassis" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                                    	"Tasman" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                               "1200" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                            "12000ATAD5750002" );
	$tester->xpath_test( "/chassis/deviceStorage/name",       "/flash1" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType", "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/size", "8028933" );
	$tester->xpath_test( "/chassis/deviceStorage/freeSpace", "7602176" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='NCM.Z']/size", "7234981" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='NCM.Z']/mtime", "2005-07-28T12:25:22" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='IC.Z']/size", "790444" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='IC.Z']/mtime", "2005-07-28T12:25:48" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='SYSTEM.CFG']/size", "1111" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='SYSTEM.CFG']/mtime", "2008-02-01T14:29:08" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/name", "root" );
	$tester->xpath_test( "/chassis/memory[kind='Flash']/size",                  "16777216" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                 "268435456" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Tiara Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='null']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='null']/speed",                           "0" );
	$tester->xpath_test( "/interfaces/interface[name='null']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='null']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='null']/mtu",                           "0" );
	$tester->xpath_test( "/interfaces/interface[name='T1 4']/speed",         					"1544000" );
	$tester->xpath_test( "/interfaces/interface[name='T1 4']/interfaceType", "other" );
	$tester->xpath_test( "/interfaces/interface[name='T1 4']/mtu", "0" );
	$tester->xpath_test( "/interfaces/interface[name='T1 4']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='T1 4']/adminStatus",                           "up" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Tiara Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/interface", 		   "ethernet1" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/routeMetric", 		   "0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/routePreference", 		   "1" );
	
	
}

unlink($doc);
1;
