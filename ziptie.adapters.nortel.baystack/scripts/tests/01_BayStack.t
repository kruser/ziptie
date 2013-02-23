#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_BayStack.t,v 1.2 2008/04/15 07:29:24 rkruse Exp $
#
# tests out the parsing module that create the BayStack adapter
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
use Test::More tests => 29;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use DataBayStack qw($ipconfig $rcStg $rcVlan $system $snmp $snmp_interfaces $ports $stp_ports);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Nortel::BayStack::Parsers
  qw(parse_static_routes parse_vlans parse_stp parse_interfaces parse_snmp parse_chassis parse_system create_config);
use ZipTie::TestElf;

my $in = {
	snmp            => $snmp,
	system          => $system,
	config          => 'binary-test-glob',
	snmp_interfaces => $snmp_interfaces,
	ports           => $ports,
	stp_ports       => $stp_ports,
	snmp_stp        => $rcStg,
	snmp_vlans      => $rcVlan,
	ip_config       => $ipconfig,
};

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "bayStackTests.xml";

my $tester = ZipTie::TestElf->new( $in, $doc );
$tester->core_model_test( "BayStack Core Test", ( \&parse_system, \&create_config ) );
$tester->xpath_test( "/ZiptieElementDocument/core:systemName",          "BS-450-12T" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "v4.5.4.06" );
$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",         "V1.48" );
$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "Switch" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "BayStack Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:description",                  "Nortel Switch" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",        "Nortel" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber", "450-12T" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "BayStack SNMP Test", ( \&parse_snmp ) );
$tester->xpath_test( "/snmp/community[communityString='public']/accessType",      "RO" );
$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType",     "RW" );
$tester->xpath_test( "/snmp/sysLocation",                                         "Alterpoint Lab" );
$tester->xpath_test( "/snmp/sysContact",                                          "how summary" );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.100.32.51']/communityString", "dude" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "BayStack Interfaces Test", ( \&parse_interfaces ) );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 20']/physical",                           "true" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 20']/interfaceEthernet/autoDuplex",       "true" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 20']/interfaceEthernet/autoSpeed",        "true" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 20']/interfaceSpanningTree/cost",         "100" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 20']/interfaceSpanningTree/priority",     "128" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 20']/interfaceSpanningTree/state",        "forwarding" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 8']/interfaceEthernet/operationalDuplex", "half" );
$tester->xpath_test( "/interfaces/interface[name='BayStack 410-24T - 8']/interfaceEthernet/autoSpeed",         "false" );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "BayStack Spanning Tree Test", ( \&parse_stp ) );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "BayStack VLANs Test", ( \&parse_vlans ) );

$tester = ZipTie::TestElf->new( $in, $doc, $ns, $schema );
$tester->sub_model_test( "BayStack Static Routes Test", ( \&parse_static_routes ) );
$tester->xpath_test( "/staticRoutes/staticRoute/defaultGateway", "true" );
$tester->xpath_test( "/staticRoutes/staticRoute/gatewayAddress", "10.100.2.1" );

unlink($doc);

1;


