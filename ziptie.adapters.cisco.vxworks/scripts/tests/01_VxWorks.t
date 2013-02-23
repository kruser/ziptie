#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_VxWorks.t,v 1.2 2008/03/21 21:41:57 rkruse Exp $
#
# tests for the VxWorks backup Parser
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
use Test::More tests => 22;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::VxWorks::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataVxWorks qw($responsesVxWorks);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "VxWorksTest.xml";

vxworks_tests();

sub vxworks_tests
{
	my $responses = $responsesVxWorks;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "VxWorks Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 														"Aironet_340" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make", 												"Cisco" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",                                            	"AP340" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                             "11.21" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                      "Wireless Access Point" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                         "Brent Mills" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",	"active" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "VxWorks SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/sysContact",	"Brent Mills" );
	$tester->xpath_test( "/snmp/sysLocation",	"Austin, Texas" );
	$tester->xpath_test( "/snmp/sysName",		"Aironet_340" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "VxWorks Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/physical",                           		"true" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/description",                         		"Ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/interfaceType",                     		"ethernet" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/adminStatus",                       		"up" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/interfaceIp/ipConfiguration/ipAddress",	"10.100.1.2" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/interfaceIp/ipConfiguration/mask", 		"24" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/interfaceEthernet/macAddress", 			"00409637e8d0" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/interfaceEthernet/operationalDuplex", 		"full" );
	$tester->xpath_test( "/interfaces/interface[name='fec0']/mtu", 										"1500" );
}

unlink($doc);
1;
