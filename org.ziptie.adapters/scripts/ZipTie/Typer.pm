package ZipTie::Typer;

use XML::Parser;
use XML::Simple;

use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

my %types;

&_load_types();

sub translate_document
{
    my $document = shift or $LOGGER->fatal("ERROR - No XML document specified to translate!");

    my @result;

    if ($document =~ /<([^>\/\s]+)[\s]?(.*?)>(.+?)<\/\1>/s)
    {
        my $body = $3;
        while ($body =~ /(<(([^>\s\/]+?:)?)([^>\s\/]+)((.*?>.+?<\/\2\4>)|(.+?\/>)))/s)
        {
            my $type = shift;
            my $xml = $1;
            my $value = &translate($xml, $type);
            push(@result, $value);
            $body = $';#'
        }
    }

    return @result;
}

######################################################################
# translates an input xml into a perl object as defined by the
# type mappings.  If no mapping is defined the plain xml is returned.
#
sub translate
{
    my $in_value = shift or $LOGGER->fatal("ERROR - No XML string specified to translate into a Perl object!");
    my $type = shift;
    
    unless ($type)
    {
        if ($in_value =~ /<[^\s\/]+[^\/]+\sxmltype\s*=\s*(['"])(.+?)\1/)
        {
            $type = $2;
        }
        elsif ($in_value =~ /<(\S+\b)/)
        {
            $type = $1;
        }
        else
        {
            $LOGGER->fatal("ERROR - No target type defined: " + $in_value);
        }
    }

    if (ref($type) eq 'METHOD')
    {
        return &$ref($in_value);
    }

    my $method = %types->{$type};
    unless ($method)
    {
        $LOGGER->debug("No translator for type: $type");
        return XMLin($in_value, forcearray => 1);
    }

    #$LOGGER->debug("Using translator for type: $type => $method");

    my $code = '';
    if ($method =~ /(.+)(::|->)/) # extract the package name
    {
        $code = "use $1;\n";
    }

    $code .= $method . '($in_value, $type);';

    my $ret = eval($code);

    $LOGGER->fatal($@) if ($@);

    return $ret;
}

##########################################################
# Loads all the type mappings by looking through all the 
# INC_PATH entries for a file called 'ziptie-types.xml'
#
sub _load_types
{
    my $parser = new XML::Parser();
    $parser->setHandlers(Start => \&_handler);

    foreach my $path (@INC)
    {
        my $file = "$path/ziptie-types.xml";

        next unless (-f $file);

        #$LOGGER->debug("Loading ziptie types from file '$file'");

        $parser->parsefile($file);
        foreach my $key (keys %types)
        {
            my $val = %types->{$key};
            #$LOGGER->debug("$key => $val");
        }
    }
}

#############################################
# SAX Handler for parsing the types xmls
#
sub _handler
{
    my $expat = shift;
    my $elem = shift;

    return unless ($elem eq 'type');

    my %attrs;
    while (1)
    {
    	my $attr = shift;
    	last unless ($attr);

    	my $val = shift;
    	%attrs->{$attr} = $val;
    }

    %types->{%attrs->{'name'}} = %attrs->{'method'};
}

1;
