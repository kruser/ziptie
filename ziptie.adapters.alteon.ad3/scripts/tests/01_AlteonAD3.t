#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_AlteonAD3.t,v 1.2 2008/03/21 21:41:57 rkruse Exp $
#
# tests for the Alteon AD3 backup Parser
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
use Test::More tests => 37;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Alteon::AD3::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataAlteonAD3 qw($responsesAlteonAD3);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "AlteonAD3Test.xml";

my $config_file1 = "boot";
my $config_file2 = "image1";

alteon_ad3_tests();

sub alteon_ad3_tests
{
	my $responses = $responsesAlteonAD3;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	my $path2config = $0;
	$path2config =~ s/\/[^\/]+$//i;

	open(CONFIG, $path2config.'/'.$config_file1);
	binmode CONFIG;
	$responses->{'config'}->{boot} = join( '', <CONFIG> );
	close(CONFIG);

	open(CONFIG, $path2config.'/'.$config_file2);
	binmode CONFIG;
	$responses->{'config'}->{image1} = join( '', <CONFIG> );
	close(CONFIG);

	$responses->{'config'}->{image2} = '';

	$tester->core_model_test( "Alteon Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",                                           		"Alteon" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",                                           		"AD3" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                        		"10.0.33-SSH" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",                                         		"Alteon" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                		"Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='boot']/core:context",     "boot" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='image1']/core:mediaType", "application/x-compressed" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Alteon Checkpoint Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",        "Alteon" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:partNumber",  "E08_5B-B_7B-A" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber", "A" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Alteon Checkpoint Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.21.1']/destinationMask",    "0.0.0.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Alteon Checkpoint Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='1']/speed",                                 "100" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/operationalDuplex",   "full" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/macAddress",          "0060CF481EC0" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceIp/ipConfiguration/ipAddress", "10.100.21.222" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceIp/ipConfiguration/mask",      "24" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Alteon Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime",    "1" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",       "14" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",   "0060CF481EC0" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "6" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",				  "9" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",      			  "1" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",   				  "14" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority", 				  "420" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Alteon VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",    "Default VLAN" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled", "true" );
	$tester->xpath_test( "/vlans/vlan[number=3]/name",    "VLAN 3" );
	$tester->xpath_test( "/vlans/vlan[number=3]/enabled", "false" );
}

unlink($doc);
1;
