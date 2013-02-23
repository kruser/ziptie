#!/bin/perl

use strict;

# Action is either "gen" or "rm"
#
my $action = shift;

my @utf8_files;
@utf8_files = get_utf8_files(".", @utf8_files);

foreach my $file (@utf8_files)
{
   $file =~ s/\.utf8$//;
   if ($action eq "gen")
   {
      print "Executing native2ascii for file $file.utf8\n";
   `  native2ascii -encoding utf8 "$file.utf8" "$file.properties"`;
   }
   elsif ($action eq "clean" && $file !~ /dist/)
   {
      print "Cleaning file $file.properties\n";
      unlink "$file.properties";
   }
}

sub get_utf8_files
{
   my ($dir, @files) = @_;

   opendir(DIR, $dir) || die "can't opendir $dir: $!";
   my @entries = readdir(DIR);
   closedir DIR;

   my @local_files = ();
   foreach my $entry (@entries)
   {
      if (-d "$dir/$entry" && $entry =~ /^[^\.]/)
      {
         # print "$dir/$entry\n";
         push @local_files, get_utf8_files("$dir/$entry", @files);
      }
      elsif (-f "$dir/$entry" && $entry =~ /\.utf8$/)
      {
         push @local_files, "$dir/$entry";
      }
   }

   push @files, @local_files;
   return @files;
}
