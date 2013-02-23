#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_NortelPassport.t,v 1.4 2008/03/21 21:42:01 rkruse Exp $
#
# tests for the Nortel Passport backup Parser
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
use Test::More tests => 63;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nortel::Passport::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::TestElf;
use DataNortelPassport qw($responsesNortelPassport);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "NortelPassportTest.xml";

my $config_file = "10.100.26.4.config.cfg";

nortelpassport_tests();

sub nortelpassport_tests
{
	my $responses = $responsesNortelPassport;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	my $path2config = $0;
	$path2config =~ s/\/[^\/]+$//i;
	open(CONFIG, $path2config.'/'.$config_file);
	binmode CONFIG;
	$responses->{'config'} = join( '', <CONFIG> );
	close(CONFIG);

	$tester->core_model_test( "Nortel Passport Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName",           "Passport-8606" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:fileName", "/pcmcia/p80a3500.img" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",     "Nortel" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",     "Passport-8006" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",  "3.5.0.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",   "Passport" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",           "Switch" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact",              "support\@nortelnetworks.com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config.cfg']/core:context",   "boot" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='config.cfg']/core:mediaType", "application/multipart" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "Nortel" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",  "8006" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "SSNM0642F9" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion", "A" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:partNumber",      "202572A28" );
	$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",    "SSLFA305DA" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "268435456" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                            "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                            "15793152" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                     "flash" );
	$tester->xpath_test( "/chassis/deviceStorage/rootDir/file[name='/flash/boot.cfg']/size", "342" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/community[communityString='public']/accessType",     "RO" );
	$tester->xpath_test( "/snmp/community[communityString='private']/accessType",    "RW" );
	$tester->xpath_test( "/snmp/sysContact",                                         "support\@nortelnetworks.com" );
	$tester->xpath_test( "/snmp/sysLocation",                                        "Costa" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/defaultGateway",     "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationAddress", "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.2']/destinationMask",    "0.0.0.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.4']/defaultGateway",     "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.4']/destinationAddress", "10.100.26.0" );
	$tester->xpath_test( "/staticRoutes/staticRoute[gatewayAddress='10.100.26.4']/destinationMask",    "255.255.255.0" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport Spanning Tree Test", ( \&parse_stp ) );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/maxAge",                   "2000" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/priority",                 "32768" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/systemMacAddress",         "00043869C801" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/designatedRootMacAddress", "000163BBC34A" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/helloTime",				  "200" );
	$tester->xpath_test( "/spanningTree/spanningTreeInstance[vlan='0']/forwardDelay", 			  "1500" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='Port5/1']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='Port5/1']/mtu",                                   "1500" );
	$tester->xpath_test( "/interfaces/interface[name='Port5/1']/interfaceIp/ipConfiguration/ipAddress", "192.168.1.1" );
	$tester->xpath_test( "/interfaces/interface[name='Port5/1']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface[name='Port5/1']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/mtu",                                   "1500" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceIp/ipConfiguration/ipAddress", "10.100.26.4" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='Vlan1']/interfaceEthernet/macAddress",          "00043869CA00" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='testlab']/accessGroup","rwa" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='l3']/accessGroup","l3" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='l4admin']/accessGroup","l4admin" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Nortel Passport VLAN Test", ( \&parse_vlans ) );
	$tester->xpath_test( "/vlans/vlan[number=1]/name",              "Default" );
	$tester->xpath_test( "/vlans/vlan[number=1]/enabled",           "true" );
	$tester->xpath_test( "/vlans/vlan[number=1]/interfaceMember",	"2049" );
	$tester->xpath_test( "/vlans/vlan[number=1]/mtu",               "1500" );
}

unlink($doc);
1;
