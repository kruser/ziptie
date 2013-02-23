#!/usr/bin/perl
use strict;
use Getopt::Long;
use ZipTie::Typer;
use ZipTie::Logger;
use ZipTie::Adapters::Invoker;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Pre-use the adapter module to allow the debugger to place break points.
BEGIN
{
    eval "use @ARGV[0];";
}

# Pull off the adapter ID/package name (for example: "ZipTie::Adapters::Cisco::IOS")
# as the first argument
my $adapter_package = shift or &usage();

# Pull off the operation name (for example: "backup") as the second argument
my $operation = shift or &usage();

# Make sure warnings get printed out the with appropriate lead
local $SIG{__WARN__} = sub { 
    my $warning = shift; 
    chomp $warning;
    $LOGGER->debug($warning);
};

# Grab the file path to the operation input XML file (if it has been specified),
# or grab the inline operation input XML if it has been specified on the command line
my $input_file;
my $contents;
GetOptions(
    'input:s' => \$input_file,
    'xml:s' => \$contents,
);

# If the operation input XML was not inline on the command-line, then either read the contents
# of the specified operation input XML file, or read from STDIN.
unless ($contents)
{
    if ($input_file)
    {
        my $open_status = open(INPUT, "<$input_file");
        if (!$open_status)
        {
            die("Unable to open file $input_file: $!");
        }
        foreach (<INPUT>)
        {
            $contents .= $_;
        }
        close(INPUT);
    }
    else
    {
        foreach (<STDIN>)
        {
            $contents .= $_;
        }
    }
}

ZipTie::Adapters::Invoker::invoke($adapter_package, $operation, $contents);

sub usage
{
    die("usage:\n" .
        "    invoke.pl <adapter_package> <operation_name> [-i <input-file>]|[-x <contents>]\n"
    );
}

1;

__END__

=head1 NAME

invoke.pl - Invokes an adapter operation using the ZipTie Perl Adapter SDK.

=head1 SYNOPSIS

    invoke.pl <adapter_package> <operation_name> [-i <input-file>]|[-x <contents>]
    invoke.pl ZipTie::Adapters::Cisco::IOS backup operationInput.xml

=head1 DESCRIPTION

The C<invoke.pl> Perl script invokes an operation for a specified adapter using the ZipTie Perl Adapter SDK.  This achieved
by specifying the package name of the adapter module to be used, the name of the operation that will be invoked, and either
file location string or the actual contents of an XML document that acts as the input for specified operation.

The C<invoke.pl> Perl script is considered to be the main entry point for any operation when invoked by ZipTie.  Once
the package name of the ZipTie adapter module is determined, the C<invoke.pl> Perl script will execute the subroutine that
implements the operation of the same name.  If the operation encounters any errors, the C<invoke.pl> Perl script will die
with a message containing the error that occurred.

=head2 Adapter Package Name/ID

The name/id of the ZipTie adapter that contains the operation that will be executed.  The name/id of a ZipTie adapter
is the full package name of the Perl module that implements the adapter.  For example, the ZipTie adapter that implements
support for the Cisco IOS device family has the adapter name/id of C<ZipTie::Adapters::Cisco::IOS>.  The reason the package
name is used as the name/id of a ZipTie adapter is to easily call any operations that are implemented on the adapter module
itself.  It is expected that the adapter ID/name match both the name of the ZipTie adapter module and that "adapterId" element defined within
the metadata XML used to define an adapter (the meta data file for an adapter I<ALWAYS> exists within the same directory as the
ZipTie adapter module itself).

=head2 Operation Name

The name of the operation that will be invoked.  This name refers to a subroutine that is implemented on the specified
adapter module that can be invoked; the specified operation B<MUST> be implemented on the ZipTie adapter module
that is referenced by the specified adapter name/id, otherwise an error will occur when attempting to invoke the operation.

An example of a valid operation name is C<backup> when used with the C<ZipTie::Adapters::Cisco::IOS> adapter module.  This
means that the C<backup> subroutine on the C<ZipTie::Adapters::Cisco::IOS> adapter module will be the operation that is
invoked.

=head2 Operation Input XML

INPUT XML INFO GOES HERE!

=item C<usage()>

Prints the usage message for using the C<invoke.pl> Perl script if invalid arguments are passed in.

=back

=head1 SEE ALSO

ZipTie::Logger

ZipTie::Recording

ZipTie::Typer

ZipTie::ConnectionPath

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

Contributor(s): Leo Bayer (lbayer@ziptie.org), Dylan White (dylamite@ziptie.org)
Date: Jul 2, 2007

=cut
