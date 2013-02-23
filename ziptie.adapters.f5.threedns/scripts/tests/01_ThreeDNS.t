#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_ThreeDNS.t,v 1.4 2008/03/21 21:42:00 rkruse Exp $
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
# Contributor(s): rkruse, mkourbanov
# Date: Apr 12, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 33;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::F5::ThreeDNS::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Utils qw(parse_targz_data);
use ZipTie::TestElf;
use Data::Dumper;
use DataThreeDNS qw($responsesThreeDNS);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "ThreeDNSTest.xml";
my $ucs_config_file = "config_backup_3dns.ucs";

threedns_tests();

sub threedns_tests
{
	my $responses = $responsesThreeDNS;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	my $path2ucs = $0;
	$path2ucs =~ s/\/[^\/]+$//i;
	
	$responses->{ucsFileLocation} = $path2ucs.'/'.$ucs_config_file;
	$responses->{unzippedUcs} = parse_targz_data($responses->{ucsFileLocation});
	
	$tester->core_model_test( "ThreeDNS Core Test", ( \&parse_system, \&create_config ) );
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName", 															  "3dns1.inside.eclyptic.com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version",                                                   "4.5.10" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",                                                   	  "BIG-IP" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",                                                            "Load Balancer" );
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='backup.ucs']/core:context", 		 	  "N/A" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeDNS Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",                                                      	"F5 Networks" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",                                                   "F20" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber",                                                  "RIOUG" );
	$tester->xpath_test( "/chassis/cpu/cpuType",                                                                              		"Pentium" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                                                                        "1073725440" );
	$tester->xpath_test( "/chassis/deviceStorage/name",                                                                             "/dev/wd0h" );
	$tester->xpath_test( "/chassis/deviceStorage/size",                                                                             "240863" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType",                                                                      "disk" );
	
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeDNS Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='5.1']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='5.1']/description",                           "exp0" );
	$tester->xpath_test( "/interfaces/interface[name='5.1']/interfaceType",                         "other" );
	$tester->xpath_test( "/interfaces/interface[name='5.1']/adminStatus",                           "down" );
	$tester->xpath_test( "/interfaces/interface[name='5.1']/speed",                         	    "10000000" );
	$tester->xpath_test( "/interfaces/interface[name='5.1']/mtu",                         		    "1500" );
	$tester->xpath_test( "/interfaces/interface[name='external1']/physical",                              "false" );
	$tester->xpath_test( "/interfaces/interface[name='external1']/description",         				  "vlan0" );
	$tester->xpath_test( "/interfaces/interface[name='external1']/interfaceEthernet/macAddress",		  "009027a430f6" );
	$tester->xpath_test( "/interfaces/interface[name='external1']/interfaceIp/ipConfiguration/ipAddress", "10.100.3.13" );
	$tester->xpath_test( "/interfaces/interface[name='external1']/interfaceIp/ipConfiguration/mask", 	  "24" );
	$tester->xpath_test( "/interfaces/interface[name='external1']/adminStatus",                           "up" );

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "ThreeDNS Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/accessLevel",     "0" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/fullName",     	'System Administrator' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='sys']/accessLevel",      "2" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='sys']/fullName",     	'Operating System' );
}

unlink($doc);
1;
