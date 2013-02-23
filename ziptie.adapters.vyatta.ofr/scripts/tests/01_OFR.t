#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_OFR.t,v 1.2 2008/05/21 22:56:32 rkruse Exp $
#
# tests out the modules that create the vyatta core model
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
# Contributor(s): rkruse
# Date: Apr 12, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 44;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use DataVyatta qw($interfaces $showVersion $showHostname $showHostOS $showMemory $config);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Vyatta::OFR::Parsers
  qw(parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_routing parse_snmp parse_system);
use ZipTie::TestElf;

my $in = {
	showVer    => $showVersion,
	showName   => $showHostname,
	showOs     => $showHostOS,
	showMem    => $showMemory,
	config     => $config,
	interfaces => $interfaces,
};

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "ofrTests.xml";

my $tester = ZipTie::TestElf->new( $in, $doc );
$tester->core_model_test( "OFR Core Test", ( \&parse_system, \&create_config ), );
$tester->xpath_test( "/ZiptieElementDocument/core:systemName",          "vyatta" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "VC2" );
$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "Router" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "OFR Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",        "Vyatta" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber", "Open Flexible Router" );
$tester->xpath_test( "/chassis/cpu/core:description",                         "i686" );
$tester->xpath_test( "/chassis/memory[core:description='RAM']/size",          "2075420" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "OFR SNMP Test", ( \&parse_snmp ) );
$tester->xpath_test( "/snmp/community[communityString='public']/accessType",                                        "RO" );
$tester->xpath_test( "/snmp/community[communityString='secret']/accessType",                                        "RW" );
$tester->xpath_test( "/snmp/community[communityString='secret']/embeddedAccessFilter/host", "10.100.32.53" );
$tester->xpath_test( "/snmp/sysContact",                                                                            "Eric Bashaminator" );
$tester->xpath_test( "/snmp/sysLocation",                                                                           "Austin Lab" );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.100.32.53']/ipAddress",                                         "10.100.32.53" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "OFR Routing Test", ( \&parse_routing ) );
$tester->xpath_test( "/routing/ospf[routerId='99.1.1.219']/area/areaId",    "0.0.0.0" );
$tester->xpath_test( "/routing/ospf[routerId='99.1.1.219']/area/areaType",    "normal" );
$tester->xpath_test( "/routing/bgp/asNumber", "100" );
$tester->xpath_test( "/routing/bgp/routerId", "10.100.19.218" );
$tester->xpath_test( "/routing/bgp/neighbor[address='10.100.19.220']/asNumber", "100" );
$tester->xpath_test( "/routing/bgp/neighbor[address='10.100.19.219']/asNumber", "100" );
$tester->xpath_test( "/routing/bgp/neighbor[address='10.100.19.217']/asNumber", "100" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "OFR LocalAccounts Test", ( \&parse_local_accounts ) );
$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/accountName",    "root" );
$tester->xpath_test( "/localAccounts/localAccount[accountName='vyatta']/accountName",  "vyatta" );
$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accountName", "testlab" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "OFR Filters Test", ( \&parse_filters ) );
$tester->xpath_test( "/filterLists/filterList[name='FWTEST1']/filterEntry[name='10']/sourceIpAddr/network/address",    "192.168.2.0" );
$tester->xpath_test( "/filterLists/filterList[name='FWTEST1']/filterEntry[name='10']/sourceService/portRange/portStart", "4000" );
$tester->xpath_test( "/filterLists/filterList[name='FWTEST1']/filterEntry[name='10']/sourceService/portRange/portEnd",   "4005" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "OFR Interfaces Test", ( \&parse_interfaces ) );
$tester->xpath_test( "/interfaces/interface[name='lo']/physical",                              "false" );
$tester->xpath_test( "/interfaces/interface[name='lo']/adminStatus",                           "up" );
$tester->xpath_test( "/interfaces/interface[name='lo']/interfaceType",                         "softwareLoopback" );
$tester->xpath_test( "/interfaces/interface[name='lo']/interfaceIp/ipConfiguration/ipAddress", "10.100.19.218" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/physical",                            "true" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/adminStatus",                         "up" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/egressFilter",                        "NOTHERE" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/ingressFilter",                       "FWTEST1" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/interfaceEthernet/autoDuplex",        "true" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/interfaceEthernet/autoSpeed",         "true" );
$tester->xpath_test( "/interfaces/interface[name='eth2']/interfaceEthernet/macAddress",        "000CF1C73C47" );       

unlink($doc);

1;
