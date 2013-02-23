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
use DataCordex qw($system_info $version $factory_info $cards $config $snmp_users);
use lib '/Applications/AdapterTool_NA6.6/scripts';
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Argus::Cordex::Parsers qw(parse_filters parse_snmp parse_chassis parse_system create_config);
use ZipTie::TestElf;

my $in = {
	system_info  => $system_info,
	version      => $version,
	factory_info => $factory_info,
	cards        => $cards,
	config       => $config,
	snmp_users   => $snmp_users,
};

my $commonSchema    = "/Applications/AdapterTool_NA6.6/schema/model/ziptie-common.xsd";
my $commonNamespace = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $commonSchema . '"';

my $doc = "cordexTests.xml";

my $tester = ZipTie::TestElf->new( $in, $doc );
$tester->core_model_test( "Cordex Core Test", ( \&parse_system, \&create_config ) );
$tester->xpath_test( "/ZiptieElementDocument/core:systemName",          "CXC Supervisory" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "2.04" );
$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "Power Supply" );
$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",         "4" );

$tester = ZipTie::TestElf->new( $in, $doc, $commonNamespace, $commonSchema );
$tester->sub_model_test( "Cordex Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                    "Argus" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",             "Cordex" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",            "123450" );
$tester->xpath_test( "/chassis/macAddress",                                               "000032010206" );
$tester->xpath_test( "/chassis/card[1]/core:asset/core:factoryinfo/core:serialNumber",    "N507436/0509" );
$tester->xpath_test( "/chassis/card[1]/core:asset/core:factoryinfo/core:hardwareVersion", "1.03" );
$tester->xpath_test( "/chassis/card[1]/core:asset/core:factoryinfo/core:modelNumber",     "CXRC 48-650W" );

unlink($doc);

1;
