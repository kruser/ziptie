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

use constant RouteDest  => '1.3.6.1.2.1.4.21.1.1 ';
use constant RouteIface => '1.3.6.1.2.1.4.21.1.2';
use constant RouteNext  => '1.3.6.1.2.1.4.21.1.7';
use constant RouteMask  => '1.3.6.1.2.1.4.21.1.11';

unless ($session)
{
    print "ERROR\n\n$error\n";
    exit(1);
}

my %interfaces = interfaces();

my %results;

my @keys = ( RouteDest, RouteIface, RouteNext, RouteMask );
foreach my $key (@keys)
{
    my %table = snmp_table($key) or next;

    foreach my $oid ( keys %table )
    {
        if ( $oid =~ /^$key\.(.+)/ )
        {
            my $record = $results{$1};
            if ($record)
            {
                $record->{$key} = $table{$oid};
            }
            else
            {
                my %r = ( $key => $table{$oid});
                $results{$1} = \%r;
            }
        }
    }
}

foreach my $index ( keys %results)
{
    my %route = %{$results{$index}};

    my $dest  = $index;
    my $iface = $route{+RouteIface};
    my $ifdsc = $iface ? $interfaces{$iface} : '';
    my $next  = $route{+RouteNext};
    my $mask  = $route{+RouteMask};

    print("\"$dest\",\"$mask\",\"$next\",\"$ifdsc\"\n");
}

$session->close();

sub interfaces
{
    my %table_desc = snmp_table('.1.3.6.1.2.1.2.2.1.2');

    my %interfaces;
    foreach my $index ( keys %table_desc )
    {
        if ( $index =~ /(\d+)$/ )
        {
           $interfaces{ $1 } = $table_desc{$index};
        }
    }

    %interfaces;
}

sub snmp_table
{
    my $key = shift or die;
    my $table = $session->get_table( -baseoid => $key );

    # Will return undef if there are no objects for the given key.

    %$table;
}
