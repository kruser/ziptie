#!/usr/bin/perl
use strict;

use ZipTie::ConnectionPath;
use ZipTie::SnmpSessionFactory;
use ZipTie::Typer;
use ZipTie::Logger;
use ZipTie::SNMP;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my $connectionPathXml = shift(@ARGV);

# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $snmpSession = ZipTie::SnmpSessionFactory->create($connectionPath);

#------------------------------------------------------------
# See http://dev.ziptie.org/docs/perldoc/ZipTie/SNMP.htm for more examples
#  
#   my $resultsHash = ZipTie::SNMP::walk( $session, $oid );  
#------------------------------------------------------------

print "OK\n";