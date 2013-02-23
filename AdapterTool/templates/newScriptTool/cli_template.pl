#!/usr/bin/perl
use strict;

use ZipTie::CLIProtocolFactory;
use DEPENDENT_ADAPTER::AutoLogin;
use ZipTie::ConnectionPath;
use ZipTie::Logger;
use ZipTie::Typer;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my $connectionPathXml = shift(@ARGV);
my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $device = $connectionPath->get_ip_address();

# Perform the logic in an eval statement to catch any errors
eval 
{

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my $cliProtocol      = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $prompt           = DEPENDENT_ADAPTER::AutoLogin::execute( $cliProtocol,   $connectionPath );
	
	#------------------------------------------------------------
	# INSERT NEW COMMANDS HERE
	#------------------------------------------------------------
	
	print "OK,$device\n";
}; # end eval block 

# If an error occurred, exit with an error
if ($@)
{
	print "ERROR,$device\n";
	print "\n";
	print "$@";
}