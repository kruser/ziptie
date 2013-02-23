#!/usr/bin/perl
use strict;
use Getopt::Long;

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

my ( $connectionPathXml, $adapterId, $username );
GetOptions(
	"connectionPath=s" => \$connectionPathXml,
	"adapterId=s"      => \$adapterId,
	"username=s"       => \$username,
);

my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $device           = $connectionPath->get_ip_address();

my $localAccountSettings	= '<username>' . $username . '</username>';
my $operation         	= 'deleteLocalAccount';
$connectionPathXml =~ s/(<\/\w+>)$/$localAccountSettings$1/;

# Perform the logic in an eval statement to catch any errors
my $response;
eval { $response = ZipTie::Adapters::Invoker::invoke( $adapterId, $operation, $connectionPathXml ); };
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
		print "ERROR,$device\n";
		print "\n";
		print "$@";
	}
}
else
{
	print "OK,$device\n\n$response";
}