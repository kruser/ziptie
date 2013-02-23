#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_SecurityAppliance.t,v 1.2 2008/05/21 21:40:06 rkruse Exp $
#
# tests for the SecurityAppliance backup Parser
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
use Test::More tests => 101;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::SecurityAppliance::Parsers
  qw(parse_static_routes parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system);
use ZipTie::TestElf;
use DataSecurityAppliancePIX501 qw($responses501);
use DataSecurityApplianceFWSM qw($responsesFWSM);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "securityApplianceTest.xml";

pix_501_tests();
fwsm_tests();
unlink($doc);

sub pix_501_tests
{
	my $responses = $responses501;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "SecurityAppliance Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", "pix-501" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "6.1(1)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Firewall" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                               "xxxxxxxxxx" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context", "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context", "boot" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Filters Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=1]/primaryAction",                  "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=1]/protocol",                       "tcp" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=1]/sourceIpAddr/network/address",           "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=1]/sourceIpAddr/network/mask",              "0" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=2]/primaryAction",                  "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=2]/protocol",                       "udp" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=2]/sourceService/portExpression/port",        "22" );
	$tester->xpath_test( "/filterLists/filterList[name='101']/filterEntry[processOrder=2]/sourceService/portExpression/operator",         "eq" );
	$tester->xpath_test( "/filterLists/filterList[name='conduits']/filterEntry[processOrder=1]/protocol",                  "tcp" );
	$tester->xpath_test( "/filterLists/filterList[name='conduits']/filterEntry[processOrder=1]/sourceService/portExpression/port",   "80" );
	$tester->xpath_test( "/filterLists/filterList[name='conduits']/filterEntry[processOrder=1]/sourceService/portExpression/operator",    "eq" );
	$tester->xpath_test( "/filterLists/filterList[name='conduits']/filterEntry[processOrder=1]/sourceIpAddr/host",      "66.77.89.175" );
	$tester->xpath_test( "/filterLists/filterList[name='conduits']/filterEntry[processOrder=1]/destinationIpAddr/network/address", "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='conduits']/filterEntry[processOrder=1]/destinationIpAddr/network/mask",    "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                     "xxxxxxxxxx" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "austin" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "pix-501" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "806245458" );
	$tester->xpath_test( "/chassis/cpu/cpuType",                                   "Am5x86 133 MHz" );
	$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",       "131072" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "16777216" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "8388608" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "flash" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet1']/speed",                                 "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/description",                           "outside" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/mtu",                                   "1500" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/adminStatus",                           "down" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/interfaceEthernet/macAddress",          "0009E89CFD5C" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/interfaceEthernet/operationalDuplex",   "half" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet0']/interfaceIp/ipConfiguration/ipAddress", "10.10.42.1" );
	$tester->xpath_test( "/interfaces/interface[name='ethernet1']/physical",                              "true" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.1.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.1.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.1.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.10.15.1']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.10.15.1']/destinationAddress", "192.168.10.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.10.15.1']/destinationMask",    "255.255.255.0" );
}

sub fwsm_tests
{
	# TODO: mekhman to fill out this test method
	my $responses = $responsesFWSM;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "SecurityAppliance Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", "ceige" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "3.1(1)" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Firewall" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                               "BrentMills" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context", "active" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context", "boot" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Cisco" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "WS-SVC-FWM-1" );
	#$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "" );
	#$tester->xpath_test( "/chassis/cpu/cpuType",                                   "" );
	#$tester->xpath_test( "/chassis/memory[kind='ConfigurationMemory']/size",       "" );
	#$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "" );
	#$tester->xpath_test( "/chassis/deviceStorage/name",                            "" );
	#$tester->xpath_test( "/chassis/deviceStorage/size",                            "" );
	#$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='Vlan300']/physical",                             "false" );
	#$tester->xpath_test( "/interfaces/interface[name='Vlan50']/speed",                                 "" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan300']/description",                           "inside" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan300']/mtu",                                   "1500" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan300']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan300']/interfaceEthernet/macAddress",          "00141C706400" );
	#$tester->xpath_test( "/interfaces/interface[name='Vlan300']/interfaceEthernet/operationalDuplex",   "" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan300']/interfaceIp/ipConfiguration/ipAddress", "10.100.25.155" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan50']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan50']/description",                           "outside" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan50']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan50']/interfaceEthernet/macAddress",          "00141C706400" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Filters Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=1]/primaryAction",                  "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=1]/protocol",                       "icmp" );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=2]/primaryAction",                  "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=2]/protocol",                       "icmp" );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=2]/sourceIpAddr/host",       	 "222.222.222.222" );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=2]/destinationIpAddr/network/address",		 "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='blarg']/filterEntry[processOrder=2]/destinationIpAddr/network/mask",   		 "0" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=1]/primaryAction",               	 "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=1]/protocol",                 		 "tcp" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=1]/sourceIpAddr/network/address",			 "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=1]/sourceIpAddr/network/mask",   			 "0" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=2]/primaryAction",                 	 "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=2]/protocol",                     	 "tcp" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=2]/sourceIpAddr/network/address",       		 "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=2]/sourceIpAddr/network/mask",         	 	 "0" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=2]/destinationIpAddr/network/address",		 "168.11.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='110']/filterEntry[processOrder=2]/destinationIpAddr/network/mask",   		 "16" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='blahblah']/accessType", "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                     "BrentMills" );
	$tester->xpath_test( "/snmp/sysLocation",                                    "DallasTexas" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SecurityAppliance Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.25.1']/routeMetric",    	   "1" );
	
	
}

1;
