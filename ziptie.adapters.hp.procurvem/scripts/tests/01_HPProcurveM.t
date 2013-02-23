#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_HPProcurveM.t,v 1.2 2008/03/21 21:42:01 rkruse Exp $
#
# tests for the HP ProcurveM backup Parser
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
use ZipTie::Adapters::HP::ProcurveM::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataHPProcurveM qw($responsesHPProcurveM);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "HPProcurveMTest.xml";

hpprocurvem_tests();

sub hpprocurvem_tests
{
	my $responses = $responsesHPProcurveM;
	my $tester = ZipTie::TestElf->new( $responses, $doc );

	$tester->core_model_test( "HP ProCurveM Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "HP4000M" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "HP" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",     "HP ProCurveM" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "C.09.16" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "ProCurveM" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",  		 "C.06.01" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              "Change1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",   "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "HP ProCurveM Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "HP" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "SG91500503" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "7367520" );
	$tester->xpath_test( "/chassis/memory[kind='PacketMemory']/size",              "382" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "HP ProCurveM SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", 	 "RW" );
	$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType", 	 "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                    	 "Change1" );
	$tester->xpath_test( "/snmp/sysLocation",                                    	 "Austin" );
	$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.10.1.245']/communityString", "public" );

	#$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	#$tester->sub_model_test( "Nortel Passport Spanning Tree Test", ( \&parse_stp ) );
	#$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/maxAge",                   "2000" );
	#$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/priority",                 "32768" );
	#$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/systemMacAddress",         "00043869C801" );
	#$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/designatedRootMacAddress", "000163BBC34A" );
	#$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/helloTime",				  "200" );
	#$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/forwardDelay", 			  "1500" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "HP ProCurveM Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/speed",                                 "100000000" );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/interfaceIp/ipConfiguration/ipAddress", "10.100.2.7" );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/interfaceEthernet/autoDuplex",     		"true" );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='A3']/physical",                          "false" );
	$tester->xpath_test( "/interfaces/interface[name='A3']/speed",                             "100000000" );
	$tester->xpath_test( "/interfaces/interface[name='A5-Mesh']/interfaceEthernet/autoDuplex", "true" );
	$tester->xpath_test( "/interfaces/interface[name='A3']/interfaceType",                     "other" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "HP ProCurveM VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",              "DEFAULT_VLAN" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled",           "true" );
	$tester->xpath_test( "/vlans/vlan[number=1]/interfaceMember",	"Mesh" );
}

unlink($doc);
1;
