#!/usr/bin/env perl

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
my $session = ZipTie::SnmpSessionFactory->create($connectionPath);

if (!defined($session))
{
   print "ERROR:\n\n";
   print "$error\n";
   exit 1;
}

my $result = $session->get_table(
   -baseoid => '.1.3.6.1.2.1.4.22.1.2'
);

foreach (keys %$result)
{
    # Capture IP Address in SNMP OID: (.*) = $2
    /(\.1\.3\.6\.1\.2\.1\.4\.22\.1\.2\.\d+\.)(.*)$/;
    print "$_" . " %$result->{$_} \n" if($debug);

    my $mac = %$result->{$_};
    my $ip = $2;

        if($mac =~ m/^0x/){
           print "OK,";
           print "$ip,"; # IP Address
               $mac =~ s/^0x//;
               $mac =~ s/([a-zA-Z0-9]{2})(?!$)/\1-/g;
           print "$mac" . "\n";    # MAC Address
        }else{
           print "ERROR,";
           print "$ip,"; # IP Address
           print "Bad MAC Returned." . "\n";
        }

}
$session->close();
