#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_JUNOS.t,v 1.5 2008/09/02 14:53:02 rkruse Exp $
#
# tests out the modules that create the Juniper JUNOS adapter
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
use Test::More tests => 51;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use DataJUNOS
  qw($showRen $snmp $showOspf $showBgp $showFirewall $showVersion $showHardware $showUptime $showFeb $active $candidate $showInterfaces $showOspfInterface $showOspfOverview);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Juniper::JUNOS::Parsers
  qw(parse_routing parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system);
use ZipTie::TestElf;

my $in = {
	showVer           => $showVersion,
	showRen           => $showRen,
	showHardware      => $showHardware,
	showUptime        => $showUptime,
	showFeb           => $showFeb,
	candidate         => $candidate,
	active            => $active,
	interfaces        => $showInterfaces,
	showOspfInterface => $showOspfInterface,
	showFirewall      => $showFirewall,
	showBgp           => $showBgp,
	showOspf          => $showOspf,
	snmp              => $snmp,
};

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "junosTests.xml";

my $tester = ZipTie::TestElf->new( $in, $doc );

$tester->core_model_test( "JUNOS Core Test", ( \&parse_system, \&create_config ) );
$tester->xpath_test( "/ZiptieElementDocument/core:systemName",          "DAL-M5" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "7.0R2.7" );
$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",         "7.0R2.7" );
$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "Router" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "JUNOS Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                                    "Juniper" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                             "m5" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                            "50412" );
$tester->xpath_test( "/chassis/cpu/core:description",                                                     "Internet Processor IIv1" );    
$tester->xpath_test( "/chassis/memory[core:description='RAM']/size",                                      "805306368" );
$tester->xpath_test( "/chassis/powersupply[number='1']/core:asset/core:factoryinfo/core:hardwareVersion", "Rev 04" );
$tester->xpath_test( "/chassis/powersupply[number='1']/core:asset/core:factoryinfo/core:partNumber",      "740-002497" );
$tester->xpath_test( "/chassis/powersupply[number='1']/core:asset/core:factoryinfo/core:serialNumber",    "MB10851" );
$tester->xpath_test( "/chassis/powersupply[number='1']/core:description",                                 "AC Power Supply" );
$tester->xpath_test( "/chassis/card/core:description",                                                    "FPC" );
$tester->xpath_test( "/chassis/card/daughterCard/core:asset/core:factoryinfo/core:hardwareVersion",       "REV 04" );
$tester->xpath_test( "/chassis/card/daughterCard/core:asset/core:factoryinfo/core:partNumber",            "750-002992" );
$tester->xpath_test( "/chassis/card/daughterCard/core:asset/core:factoryinfo/core:serialNumber",          "HD0010" );
$tester->xpath_test( "/chassis/card/daughterCard/core:description",                                       "4x F/E, 100 BASE-TX" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "JUNOS SNMP Test", ( \&parse_snmp ) );
$tester->xpath_test( "/snmp/community[communityString='public']/accessType",                                         "RO" );
$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType",                                        "RW" );
$tester->xpath_test( "/snmp/community[communityString='testenv']/embeddedAccessFilter/network[address='10.100.32.53']/mask", "32" );
$tester->xpath_test( "/snmp/sysContact",                                                                             "testcontact8" );
$tester->xpath_test( "/snmp/sysLocation",                                                                            "testloc8" );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='7.7.7.7']/ipAddress",                                               "7.7.7.7" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "JUNOS LocalAccounts Test", ( \&parse_local_accounts ) );
$tester->xpath_test( "/localAccounts/localAccount[accountName='ebasham']/accessGroup", "super-user" );
$tester->xpath_test( "/localAccounts/localAccount[accountName='jerome']/accessGroup",  "superuser" );
$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accountName", "testlab" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "JUNOS Interfaces Test", ( \&parse_interfaces ) );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0']/physical",                                "true" );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0']/speed",                                   "100000000" );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0.0']/physical",                              "false" );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0.0']/interfaceOspf/area",                    "0.0.0.0" );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0.0']/interfaceOspf/helloInterval",           "10" );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0.0']/interfaceOspf/routerPriority",          "128" );
$tester->xpath_test( "/interfaces/interface[name='fe-0/3/0.0']/interfaceIp/ipConfiguration/ipAddress", "10.100.20.45" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "JUNOS Filters Test", ( \&parse_filters ) );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='3']/sourceService/portExpression/port",      "79" );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='3']/sourceService/portExpression/operator",      "eq" );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='3']/sourceIpAddr/network/address",         "192.55.12.0" );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='3']/log",                          "false" );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='3']/destinationService/portExpression/port", "389" );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='2']/primaryAction",                "permit" );
$tester->xpath_test( "/filterLists/filterList[name='trial']/filterEntry[name='3']/log",                          "false" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "JUNOS Routing Test", ( \&parse_routing ) );
$tester->xpath_test( "/routing/bgp/asNumber",                                   "200" );
$tester->xpath_test( "/routing/bgp/neighbor[address='10.100.20.210']/asNumber", "200" );
$tester->xpath_test( "/routing/bgp/neighbor[address='10.100.20.221']/asNumber", "200" );

unlink($doc);

1;
