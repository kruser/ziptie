#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_JuniperScreenOS.t,v 1.5 2008/05/21 22:15:46 rkruse Exp $
#
# tests for the Juniper ScreenOS backup Parser
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
use Test::More tests => 62;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Juniper::ScreenOS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataJuniperScreenOS qw($responsesJuniperScreenOS);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "JuniperScreenOSTest.xml";

juniperscreenos_tests();

sub juniperscreenos_tests
{
	my $responses = $responsesJuniperScreenOS;

	my $tester = ZipTie::TestElf->new( $responses, $doc );
	$tester->core_model_test( "Juniper ScreenOS Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "ns5xp" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:fileName", "ns5xp.5.0.0r11.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "Juniper" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",     "NS5XP" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "5.0.0r11.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "ScreenOS" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Firewall" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              "pitest22" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:context",   "boot" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config']/core:mediaType", "text/plain" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Juniper ScreenOS Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Juniper" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:partNumber",  "3010(0)-(00)" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "NS5XP" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "0018092002000730" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "flash:" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "31262720" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='flash:/crash.dmp']/size", "16384" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Juniper ScreenOS SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",     "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                         "pitest22" );
	$tester->xpath_test( "/snmp/sysLocation",                                        "Here" );
	$tester->xpath_test( "/snmp/sysName",                                     		 "ns5xp" );
	$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.0.0.0']/communityString", "public" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Juniper ScreenOS Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.2.1']/routePreference",    "20" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='0.0.0.0']/defaultGateway",    	  "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='0.0.0.0']/destinationAddress", 	  "10.100.2.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='0.0.0.0']/destinationMask",    	  "255.255.255.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='0.0.0.0']/routeMetric",    	      "0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Juniper ScreenOS ACL Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='none']/filterEntry/primaryAction",       		    "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='none']/filterEntry/log",                  			"true" );
	$tester->xpath_test( "/filterLists/filterList[name='none']/filterEntry/sourceIpAddr/network/address", 			"0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='none']/filterEntry/sourceIpAddr/network/mask",    			"0" );
	$tester->xpath_test( "/filterLists/filterList[name='none']/filterEntry/sourceService/portRange/portStart",        "0" );
	$tester->xpath_test( "/filterLists/filterList[name='none']/filterEntry/sourceService/portRange/portEnd",          "65535" );
	$tester->xpath_test( "/filterLists/filterList[name='acl-of-ryan']/filterEntry/primaryAction",        	"deny" );
	$tester->xpath_test( "/filterLists/filterList[name='acl-of-ryan']/filterEntry/log",                  	"true" );
	$tester->xpath_test( "/filterLists/filterList[name='acl-of-ryan']/filterEntry/sourceIpAddr/network/address", 	"0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='acl-of-ryan']/filterEntry/sourceIpAddr/network/mask",    	"0" );
	$tester->xpath_test( "/filterLists/filterList[name='acl-of-ryan']/filterEntry/sourceService/portExpression/port", "21" );
	$tester->xpath_test( "/filterLists/filterList[name='acl-of-ryan']/filterEntry/sourceService/portExpression/operator",  "eq" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Juniper ScreenOS Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='trust']/physical",                                "false" );
	$tester->xpath_test( "/interfaces/interface[name='trust']/speed",                                   "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='trust']/interfaceIp/ipConfiguration/ipAddress",   "10.100.2.10" );
	$tester->xpath_test( "/interfaces/interface[name='trust']/interfaceIp/ipConfiguration/mask",        "24" );
	$tester->xpath_test( "/interfaces/interface[name='trust']/interfaceEthernet/macAddress",            "0010DB281152" );
	$tester->xpath_test( "/interfaces/interface[name='trust']/interfaceEthernet/operationalDuplex",     "half" );
	$tester->xpath_test( "/interfaces/interface[name='untrust']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='untrust']/adminStatus",                           "down" );
	$tester->xpath_test( "/interfaces/interface[name='untrust']/interfaceIp/ipConfiguration/ipAddress", "0.0.0.0" );
	$tester->xpath_test( "/interfaces/interface[name='untrust']/interfaceIp/ipConfiguration/mask",      "0" );
	$tester->xpath_test( "/interfaces/interface[name='untrust']/interfaceEthernet/macAddress",          "0010DB281151" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Juniper ScreenOS Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/password","02ihMFpiS/ROXFYKkgMn+7TCTaEZwNgjssZiM=" );
}

unlink($doc);
1;
