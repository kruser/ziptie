#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_NetVanta.t,v 1.4 2008/03/27 19:18:33 rkruse Exp $
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
# Date: Dec 18, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 50;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Adtran::NetVanta::Parsers
  qw(create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_stp parse_static_routes);
use ZipTie::TestElf;
use DataNetVanta qw($responsesNetVanta);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "NetVanta.xml";

netvanta_tests();

sub netvanta_tests
{
	my $responses = $responsesNetVanta;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Adtran NetVanta Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "NetVanta" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "05.03.00" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "Adtran" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "AOS" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:fileName", "9200860-2A0503.biz" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Router" );

	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context",    "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:mediaType",  "text/plain" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:promotable", "false" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context",    "boot" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:mediaType",  "text/plain" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:promotable", "true" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Adtran NetVanta SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",  "RO" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType", "RW" );
	$tester->xpath_test( "/snmp/community[communityString='Asit']/accessType",    "RO" );
	$tester->xpath_test( "/snmp/community[communityString='Clayton']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysName",                                         "NetVanta.alterpoint.com" );
	$tester->xpath_test( "/snmp/sysLocation",                                     "Austin" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Adtran NetVanta Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:assetType",                                  "Chassis" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                      "Adtran" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                                         "6702080" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                                  "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/freeSpace",                                    "3003560" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                                         "unknown" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='9200860-2A0503.biz']/size", "1948204" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='9200860-2A0402.biz']/size", "1741550" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='startup-config.bak']/size", "1216" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='startup-config']/size",     "1254" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Adtran NetVanta Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface/interfaceEthernet/macAddress",          "00A0C80D2D58" );
	$tester->xpath_test( "/interfaces/interface/interfaceType",                         "unknown" );
	$tester->xpath_test( "/interfaces/interface/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface/interfaceIp/ipConfiguration/ipAddress", "10.100.23.10" );
	$tester->xpath_test( "/interfaces/interface/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface/mtu",                                   "1500" );
	$tester->xpath_test( "/interfaces/interface/name",                                  "eth 0/1" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Adtran NetVanta Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute/interface",          "eth 0/1" );
	$tester->xpath_test( "/staticRoutes/staticRoute/routeMetric",        "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Adtran NetVanta Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='kermit']/password",  'thefrog' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/password", 'hobbit' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/password",  'bigtex' );
}

unlink($doc);
1;
