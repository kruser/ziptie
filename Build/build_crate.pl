#!/usr/bin/perl

use strict;
use warnings;

use POSIX qw(strftime);

bundles(@ARGV);

sub bundles
{
    my @dirs = @_;

    my @bundles;
    foreach my $dir (@_)
    {
        die("Invalid directory: $dir\n") unless (-d $dir);

        my %bundle = read_bundle($dir);
        push(@bundles, \%bundle);
    }

    print("Enter the metadata for the crate that will be created.\n");
    my $id = prompt("Crate ID: ", '^([a-z0-9]+\.)+[a-z0-9]+$');
    my $name = prompt("Friendly Name: ");
    my $version = prompt("Version: ", '^\d+\.\d+\.\d+$');

    my $crate = "<crate\n     id=\"$id\"\n     name=\"$name\"\n     version=\"$version\">\n";

    foreach (@bundles)
    {
        my %b = %$_;
        $crate .= "   <bundle id=\"$b{id}\" version=\"\" location=\"$b{location}\" />\n";
    }

    $crate .= "</crate>\n";

    my $crate_dir = '../dist/crate-tmp';
    unless (-d $crate_dir)
    {
        mkdir($crate_dir) or die("Unable to create file: $!");
    }

    open(CRATE, ">$crate_dir/$id.crate") or die;
    print(CRATE $crate);
    close(CRATE);

    my $vq = strftime("%Y%m%d%H%M", localtime());

    system('ant',
           'crate.dist',
           '-Dcrate.out=../dist/content',
           "-Dcrate.dir=$crate_dir",
           "-Dcrate.id=$id",
           "-Dcrate.ver=$version",
           "-Dversion.qualifier=$vq",);
}

sub prompt
{
    my ($prompt, $regex) = @_;

    my $result;

    while (1)
    {
        print($prompt);

        my $result = <STDIN>;
        chomp($result);

        return $result if (!defined($regex) || $result =~ /$regex/);

        print("Invalid input!\n");
    }
}

sub read_bundle
{
    my $dir = shift or die;

    my $mf = "$dir/META-INF/MANIFEST.MF";

    my %bundle = (location => 'core/');

    open(FILE, "<$mf") or die("Unable to open $mf. ");
    while (<FILE>)
    {
        if (/Bundle-SymbolicName:\s*([^;]+)/)
        {
            my $id = $1;
            chomp($id);
            $bundle{id} = $id;
            last;
        }
    }
    close(FILE);

    die("No id found for $dir\n") unless ($bundle{id});

    %bundle;
}
