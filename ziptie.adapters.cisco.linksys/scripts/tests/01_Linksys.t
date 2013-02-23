#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_Linksys.t,v 1.2 2008/05/21 20:44:14 rkruse Exp $
#
# tests out the parsing module that create the Linksys adapter
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
# Contributor(s): rkruse
# Date: Apr 12, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 27;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use DataLinksys qw($services $filters $firewall $home $dhcp $gateway_to_gateway $snmp $network);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::Linksys::Parsers qw(parse_filters parse_snmp parse_chassis parse_system create_config);
use ZipTie::TestElf;

my $in = {
	gateway_to_gateway => $gateway_to_gateway,
	home               => $home,
	dhcp               => $dhcp,
	firewall           => $firewall,
	snmp               => $snmp,
	network            => $network,
	config             => "some binary data",
	filters            => $filters,
	services           => $services,
};

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "linksysTests.xml";

my $tester = ZipTie::TestElf->new( $in, $doc );
$tester->core_model_test( "Linksys Core Test", ( \&parse_system, \&create_config ) );
$tester->xpath_test( "/ZiptieElementDocument/core:systemName",                                    "linksys-vpn" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                           "1.3.7.10" );
$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                    "Router" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config/core:name", "RV042.exp" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "Linksys Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",            "Linksys" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",     "RV042" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",    "DHY005B00300" );
$tester->xpath_test( "/chassis/cpu/core:asset/core:factoryinfo/core:make",        "Intel" );
$tester->xpath_test( "/chassis/cpu/core:asset/core:factoryinfo/core:modelNumber", "IXP425/422" );
$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                          "33554432" );       

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "Linksys SNMP Test", ( \&parse_snmp ) );
$tester->xpath_test( "/snmp/community[communityString='public']/accessType",      "RO" );
$tester->xpath_test( "/snmp/community[communityString='private']/accessType",     "RW" );
$tester->xpath_test( "/snmp/sysContact",                                          "Dylan Is Testing This" );
$tester->xpath_test( "/snmp/sysLocation",                                         "Somewhere in Austin ..." );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.100.32.50']/communityString", "public" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "Linksys Filters Test", ( \&parse_filters ) );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/name",                    "DMZ" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/primaryAction",           "permit" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/sourceService/portRange/portStart", "53" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/sourceService/portRange/portEnd", "53" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/sourceService/portRange/protocol",  "UDP" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/timeAllowed/days",        "All" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/timeAllowed/startTime",   "09:55:00" );
$tester->xpath_test( "/filterLists/filterList/filterEntry[processOrder=1]/timeAllowed/endTime",     "09:59:00" );

unlink($doc);

1;
