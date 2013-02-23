#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 02_JUNOS.t,v 1.2 2008/09/02 14:53:02 rkruse Exp $
#
# tests for the ArubaOS backup Parser
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
use Test::More tests => 3;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Juniper::JUNOS::Parsers qw(parse_filters);
use ZipTie::TestElf;
use DataJUNOS2 qw($responses2);
my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";
my $ns     = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';
my $doc = "JuniperJUNOS.xml";

filters();

sub filters
{
	my $tester = ZipTie::TestElf->new( $responses2, $doc, $ns, $schema );
	$tester->sub_model_test( "JUNOS Filters Test", ( \&parse_filters ) );
	$tester->xpath_test( "/filterLists/filterList[name='filter-policer']/filterEntry[name='term1']/primaryAction", "none" );
	$tester->xpath_test( "/filterLists/filterList[name='filter-policer']/filterEntry[name='term2']/primaryAction", "permit" );
}

unlink($doc);
1;
