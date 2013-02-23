use strict;
use warnings;
use Test::More tests => 21;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use DataSecurePlatform qw($responses);
use ZipTie::Adapters::CheckPoint::SecurePlatform::Parsers qw(parse_local_accounts parse_interfaces parse_snmp parse_static_routes);
use ZipTie::TestElf;

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "secureplatform.xml";
_test_interfaces();
_test_snmp();
_test_static_routes();
_test_local_accounts();

sub _test_interfaces
{
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Interfaces Test", ( \&parse_interfaces ) );
	$tester->xpath_test( "/interfaces/interface[name='lo']/interfaceIp/ipConfiguration/ipAddress",   "127.0.0.1" );
	$tester->xpath_test( "/interfaces/interface[name='lo']/interfaceIp/ipConfiguration/mask",        "8" );
	$tester->xpath_test( "/interfaces/interface[name='lo']/physical",                                "false" );
	$tester->xpath_test( "/interfaces/interface[name='eth0']/interfaceIp/ipConfiguration/ipAddress", "10.100.4.10" );
	$tester->xpath_test( "/interfaces/interface[name='eth0']/interfaceIp/ipConfiguration/mask",      "24" );
	$tester->xpath_test( "/interfaces/interface[name='eth0']/physical",                              "true" );
	$tester->xpath_test( "/interfaces/interface[name='eth0']/adminStatus",                           "up" );
	$tester->xpath_test( "/interfaces/interface[name='eth0']/interfaceEthernet/macAddress",          "0002B3B40D87" );
	$tester->xpath_test( "/interfaces/interface[name='eth2']/adminStatus",                           "down" );
}

sub _test_snmp
{
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "SNMP Test", ( \&parse_snmp ) );
	$tester->xpath_test( "/snmp/sysContact",  "Unknown" );
	$tester->xpath_test( "/snmp/sysLocation", "Unknown" );
}

sub _test_static_routes
{
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Static Routes Test", ( \&parse_static_routes ) );
	$tester->xpath_test( "/staticRoutes/staticRoute[destinationAddress='224.0.0.2']/defaultGateway",  "false" );
	$tester->xpath_test( "/staticRoutes/staticRoute[destinationAddress='224.0.0.2']/destinationMask", "32" );
	$tester->xpath_test( "/staticRoutes/staticRoute[destinationAddress='0.0.0.0']/defaultGateway",    "true" );
	$tester->xpath_test( "/staticRoutes/staticRoute[destinationAddress='0.0.0.0']/interface", "eth0" );
}

sub _test_local_accounts
{
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Local Accounts Test", ( \&parse_local_accounts ) );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='admin']/accessGroup",  "admin" );
	$tester->xpath_test( "/localAccounts/localAccount[accountName='rkruse']/accessGroup",  "admin" );
}

unlink($doc);
