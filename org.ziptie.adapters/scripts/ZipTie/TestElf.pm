package ZipTie::TestElf;

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use File::Copy;
use Test::More;
use XML::XPath;
use Cwd;

our $xpathDoc;

sub new
{
	my $type = shift;
	my ( $responses, $doc, $namespace, $schema ) = @_;
	my $self = {
		_responses => $responses,
		_doc       => $doc,
		_namespace => $namespace,
		_schema    => $schema,
	};
	$xpathDoc = 0;
	bless $self, $type;
	return $self;
}

sub sub_model_test
{

	# responses, namespace, schema, @methods
	my ( $self, $testLabel, @methods ) = @_;
	my $xml    = $self->{_doc};
	my $in     = $self->{_responses};
	my $ns     = $self->{_namespace};
	my $schema = $self->{_schema};

	open( TMPFILE, ">$xml" ) || die;
	my $printer = ZipTie::Model::XmlPrint->new( \*TMPFILE );

	# call each parsing method
	foreach my $method (@methods)
	{
		$method->( $in, $printer );
	}
	close(TMPFILE);

	_inject_namespace( $xml, $ns );
	my $result = _validate_xml( $xml, $schema );
	ok( $result, $testLabel );
	return $result;
}

sub core_model_test
{

	# responses, namespace, schema, @methods
	my ( $self, $testLabel, @methods ) = @_;
	my $xml = $self->{_doc};
	my $in  = $self->{_responses};
	open( TMPFILE, ">$xml" ) || die;
	my $printer = ZipTie::Model::XmlPrint->new( \*TMPFILE, "core" );
	$printer->open_model();

	# call each parsing method
	foreach my $method (@methods)
	{
		$method->( $in, $printer );
	}
	$printer->close_model();
	close(TMPFILE);
	my $result = _validate_xml( $xml, "../../../org.ziptie.adapters/schema/model/ziptie-core.xsd" );
	ok( $result, $testLabel );
	return $result;
}

sub xpath_test
{
	my ( $self, $xpath, $value ) = @_;
	my $document = $self->{_doc};

	if ( !$xpathDoc )
	{

		# only read in the doc if it hasn't been done yet for this object
		$xpathDoc = XML::XPath->new( filename => $document );
	}

	my $infoString = $xpath . " eq '" . $value . "'";
	my $result     = $xpathDoc->find($xpath);

	if ($result)
	{
		ok( ( $result->string_value() eq $value ), $infoString );
	}
	else
	{

		# fail automatically if bad xpath
		ok( 0, $infoString );
	}
}

sub _validate_xml
{
	# Validate the output XML against the XSD
	my $xmlFile  = shift;
	my $shemaDoc = shift;
		
	# Since the validate.jar is in the directory with this module, we need 
	# to get this directory, not the calling script's directory.
	(my $pkgdir =  __PACKAGE__) =~ s!::!/!;
	my ($path) = $INC{"$pkgdir.pm"} =~ m!^(.+)/!;
	$path =~ s/Documents and Settings/DOCUME~1/;
	    
	return !system( sprintf( 'java -jar %s/validate.jar %s %s', $path, $xmlFile, $shemaDoc ) );
}

sub _inject_namespace
{

	# given an XML file, injects the provided namespace into the
	# first element.  This is used so that portions of the ZipTie
	# model can be validated against a schema.
	my ( $xml, $namespace ) = @_;

	open( TMP, ">tmp.xml" );
	open( XML, $xml );

	my $headerPrinted = 0;
	while ( my $line = <XML> )
	{
		if ( !$headerPrinted && $line =~ /(<.+?)>/ )
		{
			print TMP "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
			print TMP $1 . " " . $namespace . ">\n";
			$headerPrinted = 1;
		}
		else
		{
			print TMP $line;
		}
	}

	close(XML);
	close(TMP);

	move( "tmp.xml", $xml );
}

1;

__END__

=head1 NAME

TestElf - Used for testing adapter parsing code against the ZipTie model (ZED).

=head1 SYNOPSIS

	use Test::More tests => 3;
    use TestElf;
    
    my $schema = "../../../org.ziptie.adapters/schema/model/cisco.xsd";
	my $in = { version => $show_version, };
	my $doc = "tests.xml";

	my $ns = ' xmlns="http://www.ziptie.org/model/common/1.0"
	  xmlns:core="http://www.ziptie.org/model/core/1.0"
	  xmlns:cisco="http://www.ziptie.org/model/cisco/1.0"
	  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	  xsi:schemaLocation="http://www.ziptie.org/model/cisco/1.0 ' . $schema . '"';
  

	my $tester = TestElf->new( $in, $doc, $ns, $schema );
	$tester->sub_model_test( "Chassis Test", ( \&parse_chassis ) );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:make",        "Vyatta" );
	$tester->xpath_test( "/chassis/core:asset/core:factoryinfo/core:modelNumber", "Open Flexible Router" );
	
	unlink ($doc);  # be sure to clean up!!

=head1 DESCRIPTION

This module will aid in the validation of parsing output.  Create a new TestElf object and then first do
either the C<sub_model_test> or C<core_model_test> by providing an array of method references
from your parsing module.

After the initial test you will have a populated document to run xpath tests against to validate
exact pieces of your adapter's model output.

=head2 METHODS

=over 12

=item C<new>

Create an instance of this object.

Sample Usage:
	my $tester = TestElf->new( $in, $doc);  # all that is needed for the core test
	my $tester = TestElf->new( $in, $doc, $ns, $schema );  # required for the sub_model_test
	
=item C<sub_model_test>

Uses the provided methods and data input to parse out an element in the ZED model.  Returns
1 if the model validated against the provided schema location, 0 otherwise.

Sample Usage:
	$tester->sub_model_test( "Chassis Test", ( \&parse_chassis ) );

=item C<core_model_test>

Much the same as C<sub_model_test> except that it assumes to be getting all of the methods necessary to 
complete the ziptie-core model.

Sample Usage:
	$tester->core_model_test( "OFR Core Test", ( \&parse_system, \&create_config ), );
	
=item C<xpath_test>

Given an XPath and a value, retrieves the text value of the node at the XPath and matches it against
the value.

=back

=head1 LICENSE

 The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS"
 basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 License for the specific language governing rights and limitations
 under the License.

=head1 AUTHOR

  Contributor(s): rkruse
  Date: May 15, 2007

=cut
