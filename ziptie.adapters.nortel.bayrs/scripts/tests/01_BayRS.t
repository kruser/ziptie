#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_BayRS.t,v 1.2 2008/03/21 21:41:55 rkruse Exp $
#
# tests for the Nortel BayRS backup Parser
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
use Test::More tests => 36;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nortel::BayRS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataBayRS qw($responsesBayRS);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "NokiaCheckpointTest.xml";

my $config_file = "bayrs_config";

nortel_bayrs_tests();

sub nortel_bayrs_tests
{
	my $responses = $responsesBayRS;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	my $path2config = $0;
	$path2config =~ s/\/[^\/]+$//i;
	open(CONFIG, $path2config.'/'.$config_file);
	binmode CONFIG;
	$responses->{'config'} = join( '', <CONFIG> );
	close(CONFIG);

	$tester->core_model_test( "BayRS Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",                                           "Nortel" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",                                           "BayRS" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                        "14.20" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",                                         "asn" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                 "Router" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                    "KrissyKrissyGolicGolic" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "BayRS Checkpoint Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Nortel" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "asn" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",                              "128857" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "16384" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "1:" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "20971520" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "disk" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='asn.exe']/size", "7327300" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",     "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                         "KrissyKrissyGolicGolic" );
	$tester->xpath_test( "/snmp/sysLocation",                                        "rack4-austin-tx" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.23.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.23.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.23.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.23.3']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.23.3']/destinationAddress", "10.100.23.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.23.3']/destinationMask",    "255.255.255.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='E121']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='E121']/mtu",                                   "1518" );
	$tester->xpath_test( "/interfaces/interface[name='E121']/speed",                                 "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='E121']/interfaceEthernet/macAddress",          "0000A2FDDC91" );
	$tester->xpath_test( "/interfaces/interface[name='E121']/interfaceIp/ipConfiguration/ipAddress", "10.100.23.3" );
	$tester->xpath_test( "/interfaces/interface[name='E121']/interfaceIp/ipConfiguration/mask",      "24" );
}

unlink($doc);
1;
