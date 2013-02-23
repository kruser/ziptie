#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 03_IOS.t,v 1.1 2008/01/21 21:23:32 rkruse Exp $
#
# tests interface parsing that includes TokenRing
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
# Date: Jan 21, 2008
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 2;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use Data3620 qw($responses);
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Cisco::IOS::Parsers qw(parse_interfaces);
use ZipTie::TestElf;

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "iosTests.xml";


my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
$tester->sub_model_test( "IOS Interfaces Test", ( \&parse_interfaces ) );
$tester->xpath_test( "/interfaces/cisco:interface[name='TokenRing0/0']/physical", "true" );

unlink($doc);
1;
