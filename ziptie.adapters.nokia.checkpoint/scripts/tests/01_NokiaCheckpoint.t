#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_NokiaCheckpoint.t,v 1.3 2008/05/21 22:18:33 rkruse Exp $
#
# tests for the Nokia Checkpoint backup Parser
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
use Test::More tests => 48;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nokia::Checkpoint::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataNokiaCheckpoint qw($responsesNokiaCheckpoint);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "NokiaCheckpointTest.xml";

my $targz_config_file = "nokiachk_targz.tar.gz";

nokiacheckpoint_tests();

sub nokiacheckpoint_tests
{
	my $responses = $responsesNokiaCheckpoint;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	my $path2targz = $0;
	$path2targz =~ s/\/[^\/]+$//i;
	open(CONFIG, $path2targz.'/'.$targz_config_file);
	binmode CONFIG;
	$responses->{'config'} = join( '', <CONFIG> );
	close(CONFIG);

	$tester->core_model_test( "Nokia Checkpoint Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",                                                 "IP440Lab" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",                                           "Nokia" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",                                           "FCS6" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                        "3.6" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",                                         "Checkpoint" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                 "Firewall" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",                                                    "pitest" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",                                                "4S4EB2X0.86A.00" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config.tar.gz']/core:context",   "N/A" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config.tar.gz']/core:mediaType", "application/x-compressed" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Nokia" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "IP400" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "8A000905808" );
	$tester->xpath_test( "/chassis/cpu/cpuType",                                   "Celeron" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "201326592" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "WDC WD84AA" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "8865710080" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "disk" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",     "RO" );
	$tester->xpath_test( "/snmp/sysContact",                                         "pitest" );
	$tester->xpath_test( "/snmp/sysLocation",                                        "Austin-alterpoint" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.3.1']/destinationMask",    "0.0.0.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint ACL Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='Silliness']/filterEntry/primaryAction",        "permit" );
	$tester->xpath_test( "/filterLists/filterList[name='Silliness']/filterEntry/log",                  "false" );
	$tester->xpath_test( "/filterLists/filterList[name='Silliness']/filterEntry/sourceIpAddr/network/address", "0.0.0.0" );
	$tester->xpath_test( "/filterLists/filterList[name='Silliness']/filterEntry/sourceIpAddr/network/mask",    "0" );
	$tester->xpath_test( "/filterLists/filterList[name='Silliness']/filterEntry/sourceService/portRange/portStart",          "0" );
	$tester->xpath_test( "/filterLists/filterList[name='Silliness']/filterEntry/sourceService/portRange/portEnd",            "65535" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/mtu",                                   "1500" );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/speed",                                 "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/interfaceEthernet/macAddress",          "00c095e24ff3" );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/interfaceEthernet/autoDuplex",          "false" );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/interfaceIp/ipConfiguration/ipAddress", "10.100.3.6" );
	$tester->xpath_test( "/interfaces/interface[name='eth-s1p4c0']/interfaceIp/ipConfiguration/mask",      "255.255.255.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nokia Checkpoint Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/accessLevel","0" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/fullName",'Root' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='monitor']/accessLevel","10" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='monitor']/fullName",'Monitor' );
}

unlink($doc);
1;
