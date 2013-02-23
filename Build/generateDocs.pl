#----------------------------------------------------------
# Recursively generate HTML documentation using the ZipTie
# modules' POD.
#----------------------------------------------------------
use strict;
use Pod::Find qw(pod_find);
use Pod::Html;
use Getopt::Long;
use File::Path;
use Data::Dumper;

my $baseDir;
my $outputDir;
my $docs;    # the doc name and relative path

get_options();

# run pod2html on each pod file
my %pods = pod_find( {}, ($baseDir) );
foreach ( keys %pods )
{
	my $filename    = $_;
	my $packageName = $pods{$_};
	my @frags       = split( /::/, $packageName );

	# create the output folder if it doesn't already exist
	my $tmpOutputDir = $outputDir;
	my $relativePath;
	my $size = @frags;
	for ( my $i = 0 ; $i < $size - 1 ; $i++ )
	{
		$relativePath .= "/" if $relativePath;
		$relativePath .= @frags[$i];
	}
	$tmpOutputDir .= "/" . $relativePath;

	if ( !-e $tmpOutputDir )
	{
		mkpath($tmpOutputDir);
	}

	my $shortFilename = @frags[ $size - 1 ] . ".htm";
	$relativePath .= "/" . $shortFilename;
	my $outputFile = $tmpOutputDir . "/" . $shortFilename;
	my @args = ( "--infile=$filename", "--css=style.css", "--outfile=$outputFile" );
	pod2html(@args);
	$docs->{$packageName} = $relativePath;
}

# now create an index.htm for all of the pods
open (INDEX, ">$outputDir/index.htm") || die "unable to create the index.htm file in $outputDir";
print INDEX "<html><head><title>Perldoc Index</title></head><body>\n";
print INDEX "<table border='0'>\n";
print INDEX "<tr><td><font size=5><b>Perl Modules</b></font></td></tr>\n";
foreach my $key (sort keys %$docs)
{
	print INDEX "<tr><td><a href='$docs->{$key}'>$key</a></td></tr>";
}
print INDEX "</table></body></html>\n";
close (INDEX);


sub get_options
{
	GetOptions(
		"baseDir=s"   => \$baseDir,
		"outputDir=s" => \$outputDir,
	);

	if ( !$baseDir && !$outputDir )
	{
		usage();
	}
}

sub usage
{
	print STDERR << "EOF";

    usage: $0 <-baseDir> <-outputDir>

     -baseDir	: the program will recursively search this directory for pod files 
     -outputDir	: where to place the output html files
     
    using no options will print this message

    example: $0 -baseDir=/home/rkruse/scripts/ -outputDir=/opt/apache/http/htdocs/perldoc/
EOF
	exit;
}
