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
my $device = $connectionPath->get_ip_address();

select(STDOUT);
$| = 1;

unless ($session)
{
	print "ERROR,$device\n\n$error\n";
	return -1;
}

# OIDs for various system info...

my $key_desc    = '.1.3.6.1.2.1.1.1.0';
my $key_up      = '.1.3.6.1.2.1.1.3.0';
my $key_contact = '.1.3.6.1.2.1.1.4.0';
my $key_name    = '.1.3.6.1.2.1.1.5.0';
my $key_loc     = '.1.3.6.1.2.1.1.6.0';

my $result = $session->get_request( -varbindlist => [ $key_desc, $key_up, $key_contact, $key_name, $key_loc, ] );

$session->close();
if ( !$result )
{
	print("ERROR,$device\n\n");
	if ( $session->error )
	{
		print( $session->error );
	}
	else
	{
		print "SNMP information unavailable.\n";
	}
	print("\n");
}
else
{
	my $sysDescr    = $result->{$key_desc};
	my $sysUpTime   = $result->{$key_up};
	my $sysContact  = $result->{$key_contact};
	my $sysName     = $result->{$key_name};
	my $sysLocation = $result->{$key_loc};

	my $short_sys = $sysDescr;

	# only take the first line of the system description for the table output
	if ( $short_sys =~ /^([^\s*].+[^\s*])/ )
	{
		$short_sys = $1;
	}

	print "OK,$device,\"$short_sys\",\"$sysUpTime\",\"$sysContact\",\"$sysName\",\"$sysLocation\"\n";

	print("\n");
	print $sysDescr;
	print("\n");
}

1;
