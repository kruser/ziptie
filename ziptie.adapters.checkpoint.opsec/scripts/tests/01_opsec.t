use strict;
use warnings;
use Test::More tests => 22;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::CheckPoint::OPSEC::Parsers qw(parse_object_groups parse_rules);
use ZipTie::TestElf;

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc       = "opsec.xml";
my $responses = { rulesFile => 'rules.C', objectsFile => 'objects.C', };

_test_object_groups();
_test_rules();

sub _test_object_groups
{
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Object Groups Test", ( \&parse_object_groups ) );
	$tester->xpath_test( "/objectGroups/networkGroup[id='DAG_range']/range/startAddress",    "0.0.0.1" );
	$tester->xpath_test( "/objectGroups/networkGroup[id='DAG_range']/range/endAddress",      "0.0.254.254" );
	$tester->xpath_test( "/objectGroups/networkGroup[id='net-zurich']/subnet/address",       "10.3.5.0" );
	$tester->xpath_test( "/objectGroups/networkGroup[id='net-zurich']/subnet/mask",          "24" );
	$tester->xpath_test( "/objectGroups/networkGroup[id='webzurich']/host",                  "10.3.5.105" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='FW1_cvp']/portExpression/operator", "eq" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='FW1_cvp']/portExpression/port",     "18181" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='FW1_cvp']/portExpression/protocol", "tcp" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='X11']/portRange/portEnd",           "6063" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='X11']/portRange/portStart",         "6000" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='X11']/portRange/protocol",          "tcp" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='sqlnet2']/objectGroupReference[position()=1]",
		"sqlnet2-1521" );
	$tester->xpath_test( "/objectGroups/serviceGroup[id='sqlnet2']/objectGroupReference[position()=2]",
		"sqlnet2-1525" );
}

sub _test_rules
{
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "Rules Test", ( \&parse_rules ) );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-1']/log",           "false" );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-1']/primaryAction", "permit" );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-1']/sourceIpAddr/objectGroupReference", "net-oslo" );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-4']/sourceIpAddr/network[address='0.0.0.0']/mask", "0" );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-4']/sourceIpAddr/network[address='::']/mask", "0" );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-3']/destinationService[objectGroupReference='http']/objectGroupReference", "http" );
	$tester->xpath_test( "/filterLists/filterList/filterEntry[name='rule-3']/destinationService[objectGroupReference='ftp']/objectGroupReference", "ftp" );
}

unlink($doc);
