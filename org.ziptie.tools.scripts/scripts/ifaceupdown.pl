#!/usr/bin/perl
use strict;
use Getopt::Long;
use Text::CSV;

use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::Adapters::Invoker;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ( $connectionPathXml, $adapterId, $upDown, $interfaces );
GetOptions(
	"connectionPath=s" => \$connectionPathXml,
	"adapterId=s"      => \$adapterId,
	"updown=s"         => \$upDown,
	"interfaces=s"     => \$interfaces,
);

my $csv              = Text::CSV->new();
$csv->parse($interfaces);
my @interfacesArray = $csv->fields();

my $numberOfInterfaces = @interfacesArray;
if ( $numberOfInterfaces < 1 )
{
	print "ERROR,No interfaces selected\n";
}
else
{
	$upDown = lc($upDown);
	chomp($upDown);
	my $interfacesXml = '<interfaces>';
	my @onlyIntNames;
	foreach my $int (@interfacesArray)
	{
		my $singleIntCsv = Text::CSV->new();
		$singleIntCsv->parse($int);
		my @nameAndInt = $singleIntCsv->fields();
		push (@onlyIntNames, $nameAndInt[1]);
		$interfacesXml .= '<interface name="' . $nameAndInt[1] . '" setStatusTo="' . $upDown . '"/>';
	}
	$interfacesXml .= '</interfaces>';
	my $operation = 'interfacechange';

	$connectionPathXml =~ s/(<\/\w+>)$/$interfacesXml$1/;
	
	my $result;
	eval { $result = ZipTie::Adapters::Invoker::invoke( $adapterId, $operation, $connectionPathXml ); };
	if ($@)
	{
		if ( $@ =~ /Can't locate.+\.pm|Can't locate object method/i )
		{
			print "WARN,\n";
			print "\n";
			print "The \"$operation\" operation is not yet implemented for the $adapterId adapter\n";
			print "\n";
			print "Visit http://www.ziptie.org/zde for information on how to extend the $adapterId adapter.";
		}
		else
		{
			print "ERROR,Error\n";
			print "\n";
			print "$@";
		}
	}
	else
	{
		foreach my $int (@onlyIntNames)
		{
			print "$upDown,$int\n";
		}
		print "\n$result";
	}
}

__END__

=head1 DESCRIPTION

A script tool that is designed to set one or more interfaces (ports) to up 
or down status

=head1 ADAPTER IMPLEMENTATIONS

An adapter that wishing to use this tool must implement the Interfacechange operation.  That operation
should return a single SCALAR upon completion that can be printed out to represent the details of the change.

Proper implementation of the Interfacechange operation would be as follows inside of an Interfacechange.pm
for your adapter:

	sub invoke
	{
		my $pkg = shift;
		my $doc = shift;

		my ( $connectionPath, $interfaces ) = ZipTie::Typer::translate_document( $doc, 'connectionPath' );
		my $cliProtocol    = ZipTie::CLIProtocolFactory::create($connectionPath);
		# put adapter specific autologin code here	
		my $response;
		for my $intName ( sort keys %$interfacesHash )
		{
			$response .= $cliProtocol->send_and_wait_for( 'interface ' . $intName, $configPrompt );
			my $statusCommand = ( $interfacesHash->{$intName}->{setStatusTo} =~ /DOWN/i ) ? 'shutdown' : 'no shut';
			$response .= $cliProtocol->send_and_wait_for( $statusCommand, $configPrompt );
		}
		return $response;
	}

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
  Date: May 15, 2008

=cut
