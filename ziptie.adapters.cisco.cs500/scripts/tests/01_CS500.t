#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_CS500.t,v 1.3 2008/03/21 21:41:57 rkruse Exp $
#
# tests for the Cisco CS500 backup Parser
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
# Date: Dec 03, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 41;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::CS500::Parsers
  qw(create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_access_ports);
use ZipTie::TestElf;
use DataCS500 qw($responsesCS500);


my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "CS500Test.xml";

cs_500_tests();


sub cs_500_tests
{
	my $responses = $responsesCS500;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "CS500 Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",								"CS-500" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",							"9.21(3)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",							"CS Software (CS500-KR)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",							"CS500-KR" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",							"Cisco" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",								"Terminal Server" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",								"tweety" );
	
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",	"active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:promotable",	"true" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType",	"text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CS500 SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",	"RO" );
	$tester->xpath_test( "/snmp/community[communityString='pablito']/accessType",	"RW" );
	$tester->xpath_test( "/snmp/community[communityString='wookie']/accessType",	"RW" );
	$tester->xpath_test( "/snmp/sysContact",					"tweety" );
	$tester->xpath_test( "/snmp/sysLocation",					"alterpoint" );
	$tester->xpath_test( "/snmp/sysName",						"CS-500.alterpoint.com" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CS500 Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",		"Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:assetType",			"Chassis" );
	$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",	"32768" );
	$tester->xpath_test( "/chassis/cpu/cpuType",					"68331" );
	
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CS500 Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface/physical",					"true" );
	$tester->xpath_test( "/interfaces/interface/name",					"Ethernet0" );
	$tester->xpath_test( "/interfaces/interface/interfaceType",				"unknown" );
	$tester->xpath_test( "/interfaces/interface/adminStatus",				"up" );
	$tester->xpath_test( "/interfaces/interface/interfaceIp/ipConfiguration/ipAddress",	"10.100.1.16" );
	$tester->xpath_test( "/interfaces/interface/interfaceIp/ipConfiguration/mask",		"24" );
	$tester->xpath_test( "/interfaces/interface/mtu",					"1500" );
	$tester->xpath_test( "/interfaces/interface/interfaceEthernet/macAddress",		"00000CFFEFC4" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CS500 Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/password",	'7 082345491D1C1D' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/password",	'7 0503090D23455A' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='superfly']/password",	'' );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "CS500 Access Ports", ( \&parse_access_ports ) );
	$tester->xpath_test( "/accessPorts/accessPort[startInstance=1]/type",	"TTY" );
	$tester->xpath_test( "/accessPorts/accessPort[startInstance=2]/type",	"TTY" );
	$tester->xpath_test( "/accessPorts/accessPort[startInstance=17]/type",	"VTY" );
	$tester->xpath_test( "/accessPorts/accessPort[startInstance=18]/type",	"VTY" );
}

unlink($doc);
1;
