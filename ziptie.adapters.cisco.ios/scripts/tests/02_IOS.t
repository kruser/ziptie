#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 02_IOS.t,v 1.1 2007/11/15 00:05:40 rkruse Exp $
#
# tests for the IOS backup Parser against a catalyst WS-C6506
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
use Test::More tests => 14;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use Data6506 qw($responses);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::IOS::Parsers qw(parse_chassis);
use ZipTie::TestElf;

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "iosTests.xml";

my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
$tester->sub_model_test( "IOS Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                               "Cisco" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                        "WS-C6506" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                       "SAL08290JNU" );
$tester->xpath_test( "/chassis/cpu/cpuType",                                                         "R7000" );
$tester->xpath_test( "/chassis/memory[kind='PacketMemory']/size",                                    "67108864" );
$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                             "536870912" );
$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:hardwareVersion", "5.1" );
$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:partNumber",      "WS-X6K-S2U-MSFC2" );
$tester->xpath_test( "/chassis/card[slotNumber=1]/core:asset/core:factoryinfo/core:serialNumber",    "SAL08445F8B" );
$tester->xpath_test( "/chassis/card[slotNumber=1]/portCount",                                        "2" );
$tester->xpath_test( "/chassis/card[slotNumber=1]/softwareVersion",                                  "12.2(17d)SXB" );
$tester->xpath_test( "/chassis/card[slotNumber=1]/status",                                           "Ok" );
$tester->xpath_test( "/chassis/powersupply[number=2]/core:asset/core:factoryinfo/core:partNumber",   "WS-CAC-1300W" );       

unlink($doc);
1;
