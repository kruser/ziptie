#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_IOS.t,v 1.5 2008/10/01 23:14:54 rkruse Exp $
#
# tests for the IOS backup Parser
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
use Test::More tests => 112;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use DataIOSRouter qw($show_diag $show_fs $show_flash $bgp $ospf_ints $ospf $protocols $eigrp $running_config $startup_config $version $acls $interfaces);
use DataIOSSwitch qw($vtp_status $stp $cat_vlans);
use DataIOSRSM qw($rsm_vlans);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::IOS::Parsers
  qw(parse_vtp parse_static_routes parse_vlans parse_stp parse_routing parse_access_ports parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system);
use ZipTie::TestElf;

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "iosTests.xml";
ios_tests();
catios_tests();
msfc_tests();
unlink($doc);

sub ios_tests
{
	my $in = {
		running_config => $running_config,
		startup_config => $startup_config,
		interfaces     => $interfaces,
		version        => $version,
		access_lists   => $acls,
		bgp            => $bgp,
		ospf_ints      => $ospf_ints,
		ospf           => $ospf,
		protocols      => $protocols,
		eigrp          => $eigrp,
		show_fs        => $show_fs,
		show_diag      => $show_diag,
	};
	$in->{file_systems}->{flash} = $show_flash;    

	# first do some IOS router tests
	my $tester = ZipTie::TestElf->new( $in, $doc );
	$tester->core_model_test( "IOS Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",                                                            "cisco2610-LAB" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "12.2(12e)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Router" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                               "pitest1" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context", "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context", "boot" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",                                                           "11.3(2)XA4" );
	$tester->xpath_test( "/ZiptieElementDocument/core:lastReboot",                                                            "730944003" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.4.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.4.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.4.1']/destinationMask",    "0" );

	my $tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS ACL Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='18']/filterEntry/primaryAction",                            "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='18']/filterEntry/log",                                      "false" );
	$tester->xpath_test( "/filterLists/filterList[name='18']/filterEntry/sourceIpAddr/network/address",                     "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='18']/filterEntry/sourceIpAddr/network/mask",                        "0" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=3]/sourceService/portExpression/port", "1024" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=3]/sourceService/portExpression/operator",  "gt" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist']/filterEntry[processOrder=0]/sourceIpAddr/network/address",  "2001::" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist']/filterEntry[processOrder=0]/sourceIpAddr/network/mask",  "54" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist']/filterEntry[processOrder=0]/destinationIpAddr/network/address",  "::" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist']/filterEntry[processOrder=0]/destinationIpAddr/network/mask",  "0" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist1']/filterEntry[processOrder=2]/sourceService/portExpression/operator",  "eq" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist1']/filterEntry[processOrder=2]/sourceService/portExpression/port",  "21" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist1']/filterEntry[processOrder=2]/destinationService/portExpression/operator",  "lt" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist1']/filterEntry[processOrder=2]/destinationService/portExpression/port",  "11" );
	$tester->xpath_test( "/filterLists/filterList[name='ipv6accesslist1']/filterEntry[processOrder=2]/log",  "true" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='test1']/accessType",      "RO" );
	$tester->xpath_test( "/snmp/community[communityString='test98']/accessType",     "RO" );
	$tester->xpath_test( "/snmp/community[communityString='yetagain']/mibView",      "system" );
	$tester->xpath_test( "/snmp/community[communityString='something']/filter",      "55" );
	$tester->xpath_test( "/snmp/sysContact",                                         "pitest1" );
	$tester->xpath_test( "/snmp/sysLocation",                                        "301 Congress" );
	$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.10.1.111']/communityString", "public" );
	$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.10.1.237']/communityString", "testenv" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS LocalAccounts Test", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessLevel",      "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enable']/accessLevel",       "15" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='enablesecret']/accessLevel", "15" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS VTY Lines Test", ( \&parse_access_ports ) );
	$tester->xpath_test( "/accessPorts/accessPort[type='con']/startInstance",     "0" );
	$tester->xpath_test( "/accessPorts/accessPort[type='aux']/startInstance",     "0" );
	$tester->xpath_test( "/accessPorts/accessPort[type='vty']/startInstance",     "0" );
	$tester->xpath_test( "/accessPorts/accessPort[type='vty']/endInstance",       "4" );
	$tester->xpath_test( "/accessPorts/accessPort[type='unknown']/startInstance", "5" );
	$tester->xpath_test( "/accessPorts/accessPort[type='unknown']/endInstance",   "15" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                               "Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                        "2610" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                       "JAB030904LB (3695644768)" );
	$tester->xpath_test( "/chassis/cpu/cpuType",                                                         "MPC860" );
	$tester->xpath_test( "/chassis/card[slotNumber=0]/core:asset/core:factoryinfo/core:hardwareVersion", "2.3" );
	$tester->xpath_test( "/chassis/card[slotNumber=0]/core:asset/core:factoryinfo/core:partNumber",      "73-2840-13" );
	$tester->xpath_test( "/chassis/card[slotNumber=0]/core:asset/core:factoryinfo/core:serialNumber",    "JAD041806IG" );
	$tester->xpath_test( "/chassis/card[slotNumber=0]/daughterCard[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion", "4.0" );
	$tester->xpath_test( "/chassis/card[slotNumber=0]/daughterCard[slotNumber=1]/core:asset/core:factoryinfo/core:partNumber",      "800-01834-03" );
	$tester->xpath_test( "/chassis/card[slotNumber=0]/daughterCard[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",    "20082623" );
	$tester->xpath_test( "/chassis/memory[kind='PacketMemory']/size",                                                               "9437184" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                                                        "67108864" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                                                                             "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                                                                             "16777216" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                                                                      "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='c2600-i-mz.122-12e.bin']/size",                                 "5427700" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Loopback0']/physical",                                "false" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/speed",                                 "5544000" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/egressFilter",                          "B1-to" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/interfaceEthernet/autoDuplex",          "false" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/interfaceIp/ipConfiguration/ipAddress", "10.100.4.8" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/interfaceIp/udpForwarder[1]",           "2.2.2.2" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/interfaceIp/udpForwarder[2]",           "5.2.2.2" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/cisco:eigrp/cisco:asNumber",            "100" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/cisco:eigrp/cisco:helloInterval",       "57" );
	$tester->xpath_test( "/interfaces/cisco:interface[name='Ethernet0/0']/cisco:eigrp/cisco:holdTime",            "57" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "IOS Routing Test", ( \&parse_routing ) );
	$tester->xpath_test( "/cisco:routing/bgp/autoSummarization",                                                                   "false" );
	$tester->xpath_test( "/cisco:routing/bgp/neighbor[address='10.98.96.10']/asNumber",                                            "65221" );
	$tester->xpath_test( "/cisco:routing/bgp/synchronization",                                                                     "false" );
	$tester->xpath_test( "/cisco:routing/bgp/asNumber",                                                                            "100" );
	$tester->xpath_test( "/cisco:routing/ospf[processId='65272']/area[areaId='3602']/areaType",                                    "NSSA" );
	$tester->xpath_test( "/cisco:routing/ospf[processId='65272']/routerId",                                                        "10.153.239.254" );
	$tester->xpath_test( "/cisco:routing/ospf[processId='65234']/area/network[address='10.151.255.240']/mask",                     "0" );
	$tester->xpath_test( "/cisco:routing/cisco:eigrp[cisco:asNumber='422']/cisco:autoSummarization",                               "false" );
	$tester->xpath_test( "/cisco:routing/cisco:eigrp[cisco:asNumber='422']/cisco:passiveInterfaceDefault",                         "false" );
	$tester->xpath_test( "/cisco:routing/cisco:eigrp[cisco:asNumber='422']/cisco:redistribution[targetProtocol='ospf']/processId", "64767" );
	$tester->xpath_test( "/cisco:routing/cisco:eigrp[cisco:asNumber='422']/cisco:network[address='10.0.0.0']/address",             "10.0.0.0" );
}

sub catios_tests
{

	# now for some Catalyst IOS switches
	my $in = {
		vlans      => $cat_vlans,
		stp        => $stp,
		vtp_status => $vtp_status,
	};

	my $tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "CatIOS VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=50]/name",            "ceige2" );
	$tester->xpath_test( "/vlans/vlan[number=50]/said",            "100050" );
	$tester->xpath_test( "/vlans/vlan[number=50]/interfaceMember", "FastEthernet3/37" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "CatIOS Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='25']/maxAge",                   "20" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='25']/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='25']/systemMacAddress",         "00115DB27AD9" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='25']/designatedRootMacAddress", "00115DB27AD9" );

	$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "CatIOS VTP Test", ( \&parse_vtp ) );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:alarmNotificationEnabled", "false" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:configVersion",            "0" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:localMode",                "Transparent" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:maxVlanCount",             "1005" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:v2Mode",                   "Disabled" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:version",                  "2" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:vlanCount",                "13" );
	$tester->xpath_test( "/cisco:vlanTrunking/cisco:vlanPruningEnabled",       "false" );
}

sub msfc_tests
{

	# now for some MSFC IOS switches
	my $in = { vlans => $rsm_vlans, };
	my $tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "MSFC VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",            "vlan1" );
	$tester->xpath_test( "/vlans/vlan[number=1]/interfaceMember", "Port-channel1" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled",         "true" );
}

1;
