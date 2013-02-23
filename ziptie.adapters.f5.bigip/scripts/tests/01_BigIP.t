#! /usr/bin/env perl
# ------------------------------------------------------------------------------
#
# $Id: 01_BigIP.t,v 1.5 2008/03/21 21:41:59 rkruse Exp $
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
# Contributor(s): rkruse, asharma
# Date: Apr 12, 2007
#
# ------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More tests => 35;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::F5::BigIP::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Utils qw(parse_targz_data);
use ZipTie::TestElf;
use DataBigIP qw($responsesBigIP);

my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';

my $doc = "BigIPTest.xml";
my $ucs_config_file = "bigip_zipconf.ucs";

bigip_tests();

sub bigip_tests
{
	my $responses = $responsesBigIP;
	my $tester = ZipTie::TestElf->new( $responses, $doc );
	my $path2ucs = $0;
	$path2ucs =~ s/\/[^\/]+$//i;
	
	$responses->{ucsFileLocation} = $path2ucs.'/'.$ucs_config_file;
	$responses->{unzippedUcs} = parse_targz_data($responses->{ucsFileLocation});
	
	# System Info (9)
	$tester->core_model_test( "BigIp Core Test", ( \&parse_system, \&create_config ));
	$tester->xpath_test( "/ZiptieElementDocument/core:systemName","bigip9.inside.eclyptic.com" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make","F5" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name","BIG-IP" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version","9.1.0" );
	$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType","BIG-IP" );
	$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion","REV. I" );
	$tester->xpath_test( "/ZiptieElementDocument/core:deviceType","Load Balancer" );
	$tester->xpath_test( "/ZiptieElementDocument/core:contact","SailajaGandra");
	$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='backup.ucs']/core:context", 		 	  "N/A" );

	# Chassis (6)
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "BigIp Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make","F5 Networks" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber","BIG-IP C36" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber","bip078818s" );
	$tester->xpath_test( "/chassis/cpu/core:description","Intel(R) Celeron(R) CPU 2.50GHz" );
	$tester->xpath_test( "/chassis/cpu/cpuType","Celeron" );
	
	#Device Storage and Memory (4)
	$tester->xpath_test( "/chassis/deviceStorage/name","hda" );
	$tester->xpath_test( "/chassis/deviceStorage/size","86348136448" );
	$tester->xpath_test( "/chassis/deviceStorage/storageType","disk" );
	$tester->xpath_test( "/chassis/memory[kind='RAM']/size","805306368" );
	
	#Interfaces (11)
	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "BigIP Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='mgmt']/adminStatus","up" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt']/description","mgmt" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt']/interfaceEthernet/autoSpeed","true" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt']/interfaceEthernet/macAddress","0001D7368309" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt']/interfaceIp/ipConfiguration/ipAddress","10.100.4.7" );
	$tester->xpath_test( "/interfaces/interface[name='mgmt']/interfaceIp/ipConfiguration/mask","24" );
	$tester->xpath_test( "/interfaces/interface[name='1.1']/interfaceType","other" );
	$tester->xpath_test( "/interfaces/interface[name='1.1']/mtu","1500" );
	$tester->xpath_test( "/interfaces/interface[name='1.1']/physical","false" );
	#Local Accounts

	$tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "BigIP Local Accounts", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/accessLevel","0" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='root']/fullName",'root' );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='bin']/accessLevel","1" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='bin']/fullName",'bin' );

	
}

unlink($doc);
1;
