#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_VerticalHorizon.t,v 1.2 2008/02/18 17:47:53 mkourbanov Exp $
#
# tests for the VerticalHorizon backup Parser
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
use Test::More tests => 51;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Enterasys::VerticalHorizon::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataVH qw($responsesVH);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "VHTest.xml";

my $config_file = "10.100.3.3.config";

vh_tests();

sub vh_tests
{
	my $responses = $responsesVH;
	my $tester = ZipTie::TestElf->new( $responses, $doc );

	my $path2config = $0;
	#print $path2config."\n";
	$path2config =~ s/\/[^\/]+$//i;
	#open(CONFIG, $path2config.'/'.$config_file);
	open(CONFIG, $config_file);
	#print $path2config."\n";
	binmode CONFIG;
	$responses->{'config'} = join( '', <CONFIG> );
	close(CONFIG);

	$tester->core_model_test( "VerticalHorizon Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 			 "Enterasys Vertical Horizon" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",  	 "VerticalHorizon" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              'java.lang.Thread.sleep(50);' );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType", "application/x-compressed" );
                              
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "VerticalHorizon Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",             	 	  "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",		     	  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay", 		 	  "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",             	  "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMaxAge",  	  "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootHelloTime", 	  "2" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootForwardDelay", "15" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootCost",		  "42" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress",	  "00179445EE80" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootPort",		  "33" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootPriority",	  "32768" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "VerticalHorizon SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType", "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                     'java.lang.Thread.sleep(50);' );
	$tester->xpath_test( "/snmp/sysLocation",                                    'Alterpoint.progress(\'Within Loop\' + i);' );
	$tester->xpath_test( "/snmp/sysName",  		                                 "Enterasys Vertical Horizon" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "VerticalHorizon Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:description",      												   "Vertical Horizon Stack" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion",   "V3.0" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:firmwareVersion",   "V1.11" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:make",  			   "Enterasys" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:location/core:description",  		   "Main Board" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:description",  								   "VH-2402S" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "VerticalHorizon Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='1']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceType",                         "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='1']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/autoSpeed",           "true" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/autoDuplex",          "true" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/mediaType",           "10/100TX" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/priority",        "128" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/cost",            "19" );
	$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/state",           "disabled" );
	$tester->xpath_test( "/interfaces/interface[name='2']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='2']/interfaceType",                         "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='2']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='2']/speed",		                          "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='2']/interfaceEthernet/operationalDuplex",   "half" );
	$tester->xpath_test( "/interfaces/interface[name='2']/interfaceEthernet/mediaType",           "10/100TX" );
	$tester->xpath_test( "/interfaces/interface[name='2']/interfaceSpanningTree/priority",        "128" );
	$tester->xpath_test( "/interfaces/interface[name='2']/interfaceSpanningTree/cost",            "100" );
	$tester->xpath_test( "/interfaces/interface[name='2']/interfaceSpanningTree/state",           "disabled" );

	#$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	#$tester->sub_model_test( "XOS Static Routes Test", ( \&parse_static_routes ) );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/defaultGateway",     "true" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationAddress", "0.0.0.0" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationMask",    "0.0.0.0" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.1']/defaultGateway",     "true" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.1']/destinationAddress", "0.0.0.0" );
	#$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='192.168.5.1']/destinationMask",    "0.0.0.0" );
}

unlink($doc);
1;
