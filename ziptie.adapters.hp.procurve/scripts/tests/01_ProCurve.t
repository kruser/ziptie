use strict;
use warnings;
use Test::More tests => 71;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::HP::ProCurve::Parsers qw(parse_chassis create_config parse_system parse_interfaces parse_stp parse_snmp parse_vlan_info);
use ZipTie::TestElf;
use DataProCurveStack qw($responsesHP2500);

my $schema = "../../../org.ziptie.adapters/schema/model/ziptie-common.xsd";

my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
  xmlns:core="http://www.ziptie.org/model/core/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.ziptie.org/model/common/1.0 ' . $schema . '"';

my $doc = "ProCurveTest.xml";

my $tester = ZipTie::TestElf->new( $responsesHP2500, $doc );

$tester->core_model_test( "ProCurve Core Test", ( \&parse_system, \&create_config ) );
$tester->xpath_test( "/ZiptieElementDocument/core:systemName",          "hp2524" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:version", "F.05.17" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:osType",  "ProCurve" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:make",    "HP" );
$tester->xpath_test( "/ZiptieElementDocument/core:osInfo/core:name",    "/sw/code/build/info(s02)" );
$tester->xpath_test( "/ZiptieElementDocument/core:biosVersion",         "F.01.01" );
$tester->xpath_test( "/ZiptieElementDocument/core:deviceType",          "Switch" );
$tester->xpath_test( "/ZiptieElementDocument/core:contact",             "Changed1" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:context",    "active" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:mediaType",  "text/plain" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='running-config']/core:promotable", "false" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:context",    "boot" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:mediaType",  "text/plain" );
$tester->xpath_test( "/ZiptieElementDocument/core:configRepository/core:config[core:name='startup-config']/core:promotable", "true" );

$tester = ZipTie::TestElf->new( $responsesHP2500, $doc, $ns, $schema );
$tester->sub_model_test( "HP ProCurveM Chassis Test", ( \&parse_chassis ) );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",         "HP" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber",         "2524" );
$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:serialNumber", "TW10302565" );       
$tester->xpath_test( "/chassis/memory[kind='RAM']/size",                       "10497436" );
$tester->xpath_test( "/chassis/macAddress",                                    "0001e77c99c0" );

$tester = ZipTie::TestElf->new( $responsesHP2500, $doc, $ns, $schema );
$tester->sub_model_test( "ProCurve Interfaces Test", ( \&parse_interfaces ) );
$tester->xpath_test( "/interfaces/interface[name='1']/physical",                            "true" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceType",                       "unknown" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/autoDuplex",        "true" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/macAddress",        "0001E77C99C0" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/mediaType",         "10/100TX" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceEthernet/operationalDuplex", "full" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/cost",          "200000" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/priority",      "128" );
$tester->xpath_test( "/interfaces/interface[name='1']/interfaceSpanningTree/state",         "forwarding" );
$tester->xpath_test( "/interfaces/interface[name='1']/physical",                            "true" );
$tester->xpath_test( "/interfaces/interface[name='1']/adminStatus",                         "up" );

$tester->xpath_test( "/interfaces/interface[name='2']/physical",                            "true" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceType",                       "unknown" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceEthernet/autoDuplex",        "true" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceEthernet/macAddress",        "0001E77C99C0" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceEthernet/mediaType",         "10/100TX" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceEthernet/operationalDuplex", "full" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceSpanningTree/cost",          "200000" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceSpanningTree/priority",      "128" );
$tester->xpath_test( "/interfaces/interface[name='2']/interfaceSpanningTree/state",         "disabled" );
$tester->xpath_test( "/interfaces/interface[name='2']/physical",                            "true" );
$tester->xpath_test( "/interfaces/interface[name='2']/adminStatus",                         "down" );

$tester = ZipTie::TestElf->new( $responsesHP2500, $doc, $ns, $schema );
$tester->sub_model_test( "ProCurve SNMP Test", ( \&parse_snmp ) );
$tester->xpath_test( "/snmp/community[communityString='public']/accessType",     "RW" );
$tester->xpath_test( "/snmp/community[communityString='public']/mibView",        "Manager" );
$tester->xpath_test( "/snmp/community[communityString='testenv']/accessType",    "RW" );
$tester->xpath_test( "/snmp/community[communityString='testenv']/mibView",       "Manager" );
$tester->xpath_test( "/snmp/community[communityString='testing123']/accessType", "RO" );
$tester->xpath_test( "/snmp/community[communityString='testing123']/mibView",    "Operator" );
$tester->xpath_test( "/snmp/community[communityString='testing321']/accessType", "RO" );
$tester->xpath_test( "/snmp/community[communityString='testing321']/mibView",    "Manager" );
$tester->xpath_test( "/snmp/community[communityString='operator']/accessType",   "RO" );
$tester->xpath_test( "/snmp/community[communityString='operator']/mibView",      "Operator" );
$tester->xpath_test( "/snmp/sysContact",                                         "Changed1" );
$tester->xpath_test( "/snmp/sysLocation",                                        "CostaRica" );
$tester->xpath_test( "/snmp/sysName",                                            "hp2524" );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.10.1.89']/communityString",  "traps" );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='1.1.1.1']/communityString",     "public" );
$tester->xpath_test( "/snmp/trapHosts[ipAddress='10.10.1.119']/communityString", "testenv" );

$tester = ZipTie::TestElf->new( $responsesHP2500, $doc, $ns, $schema );
$tester->sub_model_test( "ProCurve Spanning Tree Test", ( \&parse_stp ) );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/maxAge",                   "20" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/priority",                 "32768" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/systemMacAddress",         "0001E77C99C0" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootMacAddress", "00179445EE80" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootPort",       "1" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootCost",       "200023" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/designatedRootPriority",   "24778" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/helloTime",                "2" );
$tester->xpath_test( "/spanningTree/spanningTreeInstance/forwardDelay",             "15" );


