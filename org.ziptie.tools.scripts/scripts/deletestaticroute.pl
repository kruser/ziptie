#!/usr/bin/perl
use strict;
use Getopt::Long;
use Text::CSV;
use ZipTie::Adapters::Utils qw(get_mask);

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

my ( $connectionPathXml, $adapterId, $staticRoutes );
GetOptions(
	"connectionPath=s" => \$connectionPathXml,
	"adapterId=s"      => \$adapterId,
	"staticRoutes=s"   => \$staticRoutes,
);
my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $device = $connectionPath->get_ip_address();

my $csv              = Text::CSV->new();
$csv->parse($staticRoutes);
my @staticRoutesArray = $csv->fields();

my $numberOfStaticRoutes = @staticRoutesArray;
if ( $numberOfStaticRoutes < 1 )
{
	print "ERROR,No static routes selected\n";
}
else
{
	my $staticRoutesXml = '<staticRoutes>';
	foreach my $staticRoute (@staticRoutesArray)
	{
		my $singleRouteCSV = Text::CSV->new();
		$singleRouteCSV->parse($staticRoute);
		my ( $gwAddress, $destMask, $destAddress ) = $singleRouteCSV->fields();
		$staticRoutesXml .= '<staticRoute gwAddress="' . $gwAddress . '" destAddress="' . $destAddress . '" destMask="' . get_mask($destMask) . '"/>';
	}
	$staticRoutesXml .= '</staticRoutes>';
	my $operation = 'deleteStaticRoute';

	$connectionPathXml =~ s/(<\/\w+>)$/$staticRoutesXml$1/;
	
	my $result;
	eval { $result = ZipTie::Adapters::Invoker::invoke( $adapterId, $operation, $connectionPathXml ); };
	if ($@)
	{
		if ( $@ =~ /Can't locate.+\.pm|Can't locate object method/i )
		{
			print "WARN,$device\n";
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
		print "OK,$device\n\n$result";
	}
}
