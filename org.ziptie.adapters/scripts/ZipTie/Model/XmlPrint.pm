package ZipTie::Model::XmlPrint;

use strict;
use warnings;
use XML::Simple qw(XMLout);
use MIME::Base64 qw(encode_base64);

# Create the object
sub new
{
	my ( $class, $filehandle, $modeltype, $otherXsd ) = @_;
	my $self = {
		_filehandle => $filehandle,
		_modeltype  => $modeltype,
		_attributes => 0,
		_otherXsd   => ( $otherXsd or '' ),
	};
	bless $self, $class;
	return $self;
}

#------------------------ Subroutines -------------------------

sub attributes
{
	my $self     = shift;
	my $newValue = shift;
	if ( defined $newValue )
	{
		$self->{_attributes} = $newValue;
	}
	return $self->{_attributes};
}

sub open_discovery_event
{
	my ($self) = @_;
	my $FILEHANDLE = $self->{_filehandle};
	print $FILEHANDLE <<'END';
<?xml version="1.0" encoding="UTF-8"?>
<DiscoveryEvent xmlns="http://www.ziptie.org/model/telemetry/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:telemetry="http://www.ziptie.org/model/telemetry/1.0"
    xsi:schemaLocation="http://www.ziptie.org/model/telemetry/1.0 telemetry.xsd">
END
}

# Starts the XML document with the appropriate tags
sub open_model
{
	my ($self)     = @_;
	my $FILEHANDLE = $self->{_filehandle};
	my $modeltype  = $self->{_modeltype};
	my $otherXsd   = $self->{_otherXsd};
	print $FILEHANDLE '<?xml version="1.0" encoding="UTF-8"?>';

	if ( $modeltype eq 'core' )
	{
		print $FILEHANDLE '<ZiptieElementDocument xmlns="http://www.ziptie.org/model/core/1.0"';
	}
	elsif ( $modeltype ne 'common' )
	{
		print $FILEHANDLE '<' . $modeltype . ':ZiptieElementDocument xmlns="http://www.ziptie.org/model/common/1.0"';
	}
	else
	{
		print $FILEHANDLE '<ZiptieElementDocument xmlns="http://www.ziptie.org/model/common/1.0"';
	}

	print $FILEHANDLE ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';

	if ( $otherXsd =~ /^(\S+)\s+(\S+)\.xsd$/ )
	{
		print $FILEHANDLE ' xmlns:' . $2 . '="' . $1 . '"';
	}

	print $FILEHANDLE ' xmlns:core="http://www.ziptie.org/model/core/1.0"';
	print $FILEHANDLE ' xmlns:common="http://www.ziptie.org/model/common/1.0"' if ( $modeltype ne "core" );
	print $FILEHANDLE ' xsi:schemaLocation="http://www.ziptie.org/model/core/1.0 ziptie-core.xsd';
	print $FILEHANDLE ' http://www.ziptie.org/model/common/1.0 ziptie-common.xsd' if ( $modeltype ne "core" );
	printf $FILEHANDLE ( ' %s', $otherXsd ) if ($otherXsd);
	print $FILEHANDLE '">';
	print $FILEHANDLE "\n";
}

# Closes the XML document tags
sub close_model
{
	my ($self)     = @_;
	my $FILEHANDLE = $self->{_filehandle};
	my $modeltype  = $self->{_modeltype};
	if ( $modeltype eq 'core' || $modeltype eq 'common' )
	{
		print $FILEHANDLE "</ZiptieElementDocument>\n";
	}
	else
	{
		print $FILEHANDLE "</$modeltype:ZiptieElementDocument>\n";
	}
}

# prints out just the opening tag of an element
sub open_element
{
	my ( $self, $tag ) = @_;
	my $FILEHANDLE = $self->{_filehandle};
	print $FILEHANDLE "<$tag>\n";
}

# prints out just the closing tag of an element
sub close_element
{
	my ( $self, $tag ) = @_;
	my $FILEHANDLE = $self->{_filehandle};
	print $FILEHANDLE "</$tag>\n";
}

# Print out a generic element.  This should only be used when there isn't a
# specific method to print out the element.  E.g. ->printChassis()
sub print_element
{
	my ( $self, $tag, $element ) = @_;
	my $type = scalar($element);
	if ( $tag eq "cisco:interface" )
	{
		$self->_print_cisco_interface( $element, $tag );
	}
	elsif ($type =~ /HASH/ && !$self->{_attributes})
	{
		if ($tag eq 'core:configRepository' || $tag eq 'core:folder')
		{
			my $repoName = $element->{'core:name'};
			if ($repoName)
			{
				$element->{'-attributes'} = { 'name'=>$repoName, };
				delete $element->{'core:name'};
			}
		}
		
		my $openElement = $tag;
		if ($element->{'-attributes'})
		{
			foreach my $attribute (keys %{$element->{'-attributes'}})	
			{
				$openElement .= ' '.$attribute.'="'.$element->{'-attributes'}->{$attribute}.'"';
			}
		}
		$self->open_element($openElement);
		foreach my $key (sort keys %$element)		
		{
			if ($key !~ /^-/)
			{
				$self->print_element($key, $element->{$key});
			}
		}
		$self->close_element($tag);
	}
	elsif ($type =~ /ARRAY/ && !$self->{_attributes})
	{
		my $openElement = $tag;
		my @array = @{ $element };
		foreach my $subElement (@array)		
		{
			$self->print_element($tag, $subElement);
		}
	}
	else
	{
		$self->_print_xml_element( $element, $tag );
	}
}

sub _print_cisco_interface
{

	# prints out a cisco interface, which may have an eigrp property
	# that needs to come last to match the XSD
	my ( $self, $element, $tag ) = @_;
	my $FILEHANDLE = $self->{_filehandle};

	if ( defined $element->{"cisco:eigrp"} )
	{
		print $FILEHANDLE "<" . $tag . ">";
		foreach my $key ( sort keys %{$element} )
		{
			if ( $key ne "cisco:eigrp" )
			{
				_print_xml_element( $self, $element->{$key}, $key );
			}
		}
		_print_xml_element( $self, $element->{"cisco:eigrp"}, "cisco:eigrp" );
		print $FILEHANDLE "</" . $tag . ">";
	}
	else
	{
		_print_xml_element( $self, $element, $tag );
	}
}

# Inputs:
#	1 - the filehandle reference
#	2 - the hash element
#   3 - the root name
#
# Uses XMLout to print out pretty XML will fully escaped special characters.
sub _print_xml_element
{
	my ( $self, $element, $rootName, $keyattr ) = @_;
	my $filehandle = $self->{_filehandle};
	if ( !defined $keyattr )
	{
		$keyattr = { 'core:configRepository' => '+core:name', 'core:folder' => '+core:name', };
	}
	print $filehandle XMLout( $element, RootName => $rootName, keyattr => $keyattr, noattr => ($self->{_attributes}) ? 0 : 1,);
}

1;

__END__

=head1 NAME

ZipTie::Model::XmlPrint - Utility Module to Print XML Elements from Perl Scalars

=head1 SYNOPSIS

	use ZipTie::Model::XmlPrint;
	my $printer = ZipTie::Model::XmlPrint::new(\*STDOUT, "common");
	$printer->open_model();
	$printer->print_element( "snmp", $snmpHash );
	$printer->close_model();

=head1 DESCRIPTION

Create the XmlPrint class with a given FILEHANDLE.  Then use the class to help
print elements from the ZipTie model.  Your elements should be small but well formed
hashtables that match the ZipTie model schema.

This modules uses XML::Simple for printing elements so the values all will have any
special XML characters escaped properly.

If you want to mix attributes with elements, you can do one of two things.

1) Any element should be pushed onto an array and any attribute should be simply set.
   You must also set $printer->attributes(1) for this to work.
   
2) Put a hash onto a hash element at '-attributes' and those elements will be
   printed out as attributes instead of elements.  For example:
   
   my $xml = {};
   $xml->{log} = 'true';
   $xml->{'-attributes'} = {name=>'entry1', state=>'active',};
   $printer->print_element('entry', $xml);
   
   will yeild....
   
   <entry name="entry1" state="active">
   		<log>true</log>
   </entry>


=head2 Methods

=over 12

=item C<new($filehandle, $targetNamespace, $extraSchema)>

Create an instance of this object with a provided filehandle.  This filehandle can be
an open filehandle for a real file, or simply \*STDERR or \*STDOUT.

INPUTS:
	$filehandle - an open filehandle reference, such as \*STDOUT
	$targetNamespace - this is usually 'commom'
	$extraSchema - optional argument if you are writing to an extended schema
			
EXAMPLES:
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common', "http://www.ziptie.org/model/cisco/1.0 cisco.xsd" );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, "common" );

=item C<attributes($bool)>

If no arguments are given, this method simply returns the current value of 'attributes'.  By passing a '1' to this method
you will turn on printing of elements with attributes for values instead of nested children, which is the default.

=item C<open_model()>

Prints out the root XML element of the ZipTie model.  After all printing is done you
should also call the C<close_model> method;

=item C<open_discovery_event()>

Prints out the root XML element of the DiscoveryEvent (telemetry.xsd) model.  Be sure to manually close the element
for the </DiscoveryEvent>.

=item C<open_element($name)>

Print out just the beginning of an element.
e.g. $printer->open_element("chassis");

which will print out "<chassis>"

=item C<print_element($name, $elementHash)>

Prints out an XML element, deep or shallow, given a hashtable.
$printer->print_element($filterEntry);

=item C<close_element($name)>

Print out just the end of an element.
e.g. $printer->close_element("chassis");

which will print out "</chassis>"

=item C<close_model()>

Prints out just the closing tag of the ZipTie model.
e.g. "</ZiptieElementDocument>"

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
 
  The Original Code is Ziptie Client Framework.
  
  The Initial Developer of the Original Code is AlterPoint.
  Portions created by AlterPoint are Copyright (C) 2006,
  AlterPoint, Inc. All Rights Reserved.

=head1 AUTHOR

  Contributor(s): rkruse
  Date: Apr 23, 2007

=cut
