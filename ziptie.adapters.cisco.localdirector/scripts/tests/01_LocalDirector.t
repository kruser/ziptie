#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_LocalDirector.t,v 1.1 2007/12/04 22:01:19 mkourbanov Exp $
#
# tests for the Cisco LocalDirector backup Parser
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
use Test::More tests => 32;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::LocalDirector::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataLocalDirector qw($responsesLD);
my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";
my $ns     = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';
my $doc = "LDTest.xml";
ld_tests();

sub ld_tests
{
	my $responses = $responsesLD;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "LocalDirector Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",              "LocalDir416" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",        "Cisco" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",     "3.2.3" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",              "Load Balancer" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                 "PITester1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context", "active" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "LocalDirector Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",			   "Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:hardwareVersion",  "SE440BX" );
	$tester->xpath_test( "/chassis/cpu/cpuType",                   					   "Pentium" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                   		   "33554432" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "LocalDirector Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='0']/physical",                            "false" );
	$tester->xpath_test( "/interfaces/interface[name='0']/interfaceType",                       "ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='0']/adminStatus",                         "up" );
	$tester->xpath_test( "/interfaces/interface[name='0']/interfaceEthernet/autoDuplex",        "false" );
	$tester->xpath_test( "/interfaces/interface[name='0']/interfaceEthernet/operationalDuplex", "half" );
	$tester->xpath_test( "/interfaces/interface[name='0']/interfaceEthernet/macAddress",        "00D0B7091F38" );
	$tester->xpath_test( "/interfaces/interface[name='0']/mtu",    							    "1500" );
	$tester->xpath_test( "/interfaces/interface[name='0']/speed",    						    "10000000" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "LocalDirector Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/destinationMask",    "0.0.0.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "LocalDirector SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                     "PITester1" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "DallasTexas" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "LocalDirector Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/accessLevel",   "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/password",     	'c7c54e3f90b1bc36934a6a68202d1b' );

}

unlink($doc);
1;
