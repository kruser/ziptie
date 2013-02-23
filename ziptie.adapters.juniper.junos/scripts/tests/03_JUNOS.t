use strict;
use warnings;
use Test::More tests => 1;
use Test::XML;
use FindBin;
use lib $FindBin::Bin;
use lib sprintf( '%s/../../../org.ziptie.adapters/scripts', $FindBin::Bin );
use ZipTie::Model::XmlPrint;
use lib sprintf( '%s/..', $FindBin::Bin );
use ZipTie::Adapters::Juniper::JUNOS::Parsers qw(parse_filters);
use ZipTie::TestElf;
use DataJUNOS3 qw($responses);
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
	my $tester = ZipTie::TestElf->new( $responses, $doc, $ns, $schema );
	$tester->sub_model_test( "JUNOS Filters Test", ( \&parse_filters ) );
}

unlink($doc);
1;
