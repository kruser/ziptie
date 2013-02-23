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

select(STDOUT);
$| = 1;

unless ($session)
{
	print "ERROR\n\n$error\n";
	exit(1);
}

my $key_index   = ".1.3.6.1.2.1.2.2.1.1";
my $key_desc    = ".1.3.6.1.2.1.2.2.1.2";
my $key_speed   = ".1.3.6.1.2.1.2.2.1.5";
my $key_h_speed = ".1.3.6.1.2.1.31.1.1.1.15";
my $key_mac     = ".1.3.6.1.2.1.2.2.1.6";
my $key_status  = ".1.3.6.1.2.1.2.2.1.7";
my $key_oper    = ".1.3.6.1.2.1.2.2.1.8";
my $key_out_err = ".1.3.6.1.2.1.2.2.1.20";
my $key_in_err  = ".1.3.6.1.2.1.2.2.1.14";
my $key_duplex  = ".1.3.6.1.2.1.10.7.2.1.19";
my $key_link    = ".1.3.6.1.2.1.31.1.1.1.17";

my @keys = ( $key_desc, $key_speed, $key_mac, $key_status, $key_oper, $key_out_err, $key_in_err, $key_link, $key_duplex, $key_h_speed);

my $table_index = &get($key_index);

my %interfaces;
foreach my $index ( keys %$table_index )
{
	my %record;
	$interfaces{ $$table_index{$index} } = \%record;
}

foreach my $key (@keys)
{
	my $table = &get($key);

	next unless ($table);

	foreach my $oid ( keys %$table )
	{
		if ( $oid =~ /^$key\.(\d+)/ )
		{
			my $record = $interfaces{$1};
			$record->{$key} = $$table{$oid};
		}
	}
}

my $key_ip = '.1.3.6.1.2.1.4.20.1.2';

my $table_ips = &get($key_ip);

foreach my $oid (keys %$table_ips)
{
	my $record = $interfaces{$$table_ips{$oid}};
	if ($record)
	{
		if ($oid =~ /$key_ip\.(.+)/)
		{
            $record->{$key_ip} = $1;
		}
	}
}

#print("Description, Speed, Mac, Status, Oper,\n");
foreach my $record ( values %interfaces )
{
    my $desc = $record->{$key_desc};
    my $speed = $record->{$key_speed};
    my $mac = $record->{$key_mac};
    my $status = $record->{$key_status};
    my $oper = $record->{$key_oper};
    my $ip = $record->{$key_ip} || "";
    my $in_errs = $record->{$key_in_err};
    my $out_errs = $record->{$key_out_err};
    my $link = $record->{$key_link};
    my $duplex = $record->{$key_duplex};
    my $high_speed = $record->{$key_h_speed} || "";

    unless ($in_errs)
    {
    	$in_errs = 0;
    }

    unless ($out_errs)
    {
    	$out_errs = 0;
    }

    $mac =~ s/\c@/00/g;
    $mac =~ s/^0x//;
    $mac = uc($mac);

    print('"');
    print($status);
    print('","');
    print($oper);
    print('","');
    print($desc);
    print('","');
    print($ip);
    print('","');
    print($mac);
    print('","');
    print($speed);
    print('","');
    print($high_speed);
    print('"');
	print("\n")
}

$session->close();

sub get
{
	my $key = shift or die;
	my $table = $session->get_table( -baseoid => $key );

    # Will return undef if there are no objects for the given key.

	return $table;
}
