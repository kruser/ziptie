package ZipTie::Adapters::Utils;

use strict;
use warnings;

use Exporter 'import';
use Archive::Tar;
use Compress::Zlib;
use File::Temp qw(tmpnam);
use File::Temp;
use Net::Ping;
use Time::Local;

use ZipTie::Logger;

our @EXPORT_OK =
  qw(choose_admin_ip mask_to_bits seconds_since_epoch strip_mac get_interface_type get_mask get_port_number trim get_model_filehandle close_model_filehandle get_cli_commands_filehandle parseCIDR bin2dec parse_targz_data get_crep create_empty_file getUnitFreeNumber merge_hashes escape_filename create_unique_filename);

our %SeenMerged = ();    # this hash is used in merge_hashes sub and doesn't have to be exported

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

our $OS = $Config::Config{'osname'};

our %months = (
	JAN => 0,
	FEB => 1,
	MAR => 2,
	APR => 3,
	MAY => 4,
	JUN => 5,
	JUL => 6,
	AUG => 7,
	SEP => 8,
	OCT => 9,
	NOV => 10,
	DEC => 11,
);

our %timezones = (
	AEST     => +10,
	UTC      => 0,
	UTZ      => 0,
	EDT      => -4,
	EST      => -5,
	MICHIGAN => -5,
	CDT      => -5,
	CENTRAL  => -6,
	CST      => -6,
	MDT      => -6,
	MST      => -7,
	MOUNTAIN => -7,
	ARIZONA  => -7,
	PDT      => -7,
	PST      => -8,
	PACIFIC  => -8,
	AKDT     => -8,
	AKST     => -9,
	ALASKA   => -9,
	HAST     => -10,
	HAWAII   => -10,
	SAMOA    => -11,
);

my $portNumbers = {
	"aol"         => 5190,
	"aol1"        => 5191,
	"aol2"        => 5192,
	"aol3"        => 5193,
	"bgp"         => 179,
	"biff"        => 512,
	"bootpc"      => 68,
	"bootps"      => 67,
	"dhcp"        => 547,
	"dhcp-relay"  => 547,
	"chargen"     => 19,
	"cmd"         => 514,
	"daytime"     => 13,
	"discard"     => 9,
	"dnsix"       => 195,
	"domain"      => 53,
	"dns"         => 53,
	"echo"        => 7,
	"exec"        => 512,
	"finger"      => 79,
	"ftp-data"    => 20,
	"ftp"         => 21,
	"gopher"      => 70,
	"hostname"    => 101,
	"ident"       => 113,
	"irc"         => 194,
	"isakmp"      => 500,
	"non500-isakmp"      => 4500,
	"klogin"      => 543,
	"kshell"      => 544,
	"ldap"        => 389,
	"ldp"         => 646,
	"login"       => 513,
	"lpd"         => 515,
	"lotusnotes"  => 1352,
	"lotus notes" => 1352,
	"mobile-ip"   => 434,
	"msdp"        => 639,
	"nameserver"  => 42,
	"netbios-dgm" => 138,
	"netbios-ns"  => 137,
	"netbios-ss"  => 139,
	"netbios-ssn" => 139,
	"nntp"        => 119,
	"ntp"         => 123,
	"pim-auto-rp" => 496,
	"pop2"        => 109,
	"pop3"        => 110,
	"radius"      => 1645,
	"radius-acct" => 1646,
	"rip"         => 520,
	"smtp"        => 25,
	"snmp"        => 161,
	"snmptrap"    => 162,
	"ssh"         => 22,
	"ssl"         => 443,
	"sunrpc"      => 111,
	"sunrpc"      => 111,
	"syslog"      => 514,
	"tacacs"      => 49,
	"talk"        => 517,
	"telnet"      => 23,
	"tftp"        => 69,
	"time"        => 37,
	"uucp"        => 540,
	"who"         => 513,
	"whois"       => 43,
	"www"         => 80,
	"http"        => 80,
	"https"       => 443,
	"xdmcp"       => 177,
	"voip"		  => 5060,
};

my $masks = {
	0  => "0.0.0.0",
	1  => "128.0.0.0",
	2  => "192.0.0.0",
	3  => "224.0.0.0",
	4  => "240.0.0.0",
	5  => "248.0.0.0",
	6  => "252.0.0.0",
	7  => "254.0.0.0",
	8  => "255.0.0.0",
	9  => "255.128.0.0",
	10 => "255.192.0.0",
	11 => "255.224.0.0",
	12 => "255.240.0.0",
	13 => "255.248.0.0",
	14 => "255.252.0.0",
	15 => "255.254.0.0",
	16 => "255.255.0.0",
	17 => "255.255.128.0",
	18 => "255.255.192.0",
	19 => "255.255.224.0",
	20 => "255.255.240.0",
	21 => "255.255.248.0",
	22 => "255.255.252.0",
	23 => "255.255.254.0",
	24 => "255.255.255.0",
	25 => "255.255.255.128",
	26 => "255.255.255.192",
	27 => "255.255.255.224",
	28 => "255.255.255.240",
	29 => "255.255.255.248",
	30 => "255.255.255.252",
	31 => "255.255.255.254",
	32 => "255.255.255.255",
};

# common regex patterns
our $creps = {
	'cipm'  => '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}',         # common ip/mask regular expression
	'ecipm' => '\d{1,3}(?:\.\d{1,3}){0,3}',                  # extended ip/mask regular expression
	'cidr'  => '\d{1,3}(?:\.\d{1,3}){0,3}\/\d+',             # classless interdomain routing address regular expression
	'mac1'  => '[0-9a-f]{12}',                               # mac address format 1
	'mac2'  => '[0-9a-f]{1,2}(?:[-:\.][0-9a-f]{1,2}){5}',    # mac address format 2
	'mac3'  => '[0-9a-f]{4}\.[0-9a-f]{4}\.[0-9a-f]{4}',      # mac address format 3
	'mac4'  => '[0-9a-f]{6}\-[0-9a-f]{6}',                   # mac address format 4
	'time'  => '\d{1,2}:\d{1,2}(?::\d{1,2})?',               # time
	'hex'   => '[a-fA-F0-9]',                                #hexadecimal digit
	'date1' => '\d{1,2}[-\/]\d{1,2}[-\/]\d{1,4}',            # numerical date 1
	'date2' => '\d{1,4}[-\/]\d{1,2}[-\/]\d{1,2}',            # numerical date 2
};

sub get_crep
{
	my $key = shift;
	if ( defined $creps->{$key} )
	{
		return $creps->{$key};
	}

	return 0;
}

sub escape_regex_metas
{
	$_[0] =~ s/([\(\)\[\]\\\/\+\*\?\.\^\$]{1})/\\$1/mg;
	$_[0];
}

sub unescape_regex_metas
{
	$_[0] =~ s/\\{1}([\(\)\[\]\\\/\+\*\?\.\^\$])/$1/mg;
	$_[0];
}

sub seconds_since_epoch
{
	my ( $sec, $min, $hour, $mday, $mon, $year, $timezone ) = @_;

	if ( $mon =~ /\d+/ )
	{

		# month array starts at 0
		$mon -= 1;
	}
	else
	{
		$mon = $months{ uc($mon) };
	}

	my $tz = $timezones{ uc($timezone) };
	if ( !defined $tz )
	{
		$tz = $timezones{'UTC'};    # default timezone if undefined
	}

	my $time = timegm( $sec, $min, $hour, $mday, $mon, $year );

	# handle the timezone difference if one was listed
	$time -= ( $tz * 60 * 60 );
	return $time;
}

sub get_mask
{

	# translates '24' into '255.255.255.0'
	my $cidr = shift;
	return $masks->{$cidr};
}

sub mask_to_bits
{

	# translates 255.255.255.0 into 24
	my @bytes = split( /\./, $_[0] );
	return $_[0] unless @bytes == 4 && !grep { !( /\d+$/ && $_ < 256 ) } @bytes;
	my $ipInt = unpack( "N", pack( "C4", @bytes ) );

	my $mask    = 1;
	my $counter = 0;
	for ( my $i = 0 ; $i < 32 ; $i++ )
	{
		if ( ( $ipInt & $mask ) != 0 )
		{
			$counter++;
		}
		$mask <<= 1;
	}
	return $counter;
}

sub parseCIDR
{
	my ( $host_address, $first_seted_bits ) = split( /\//, $_[0] );
	if ( $host_address =~ /^\d{1,3}$/ )
	{
		$host_address .= ".0.0.0";
	}
	elsif ( $host_address =~ /^\d{1,3}\.\d{1,3}$/ )
	{
		$host_address .= ".0.0";
	}
	elsif ( $host_address =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}$/ )
	{
		$host_address .= ".0";
	}
	my $network_address;
	my $octet;
	for ( my $x = 1 ; $x <= 32 ; $x++ )
	{
		$octet .= ( $x <= $first_seted_bits ) ? '1' : '0';
		if ( $x % 8 == 0 )
		{
			$network_address .= ( defined $network_address ) ? '.' . bin2dec($octet) : bin2dec($octet);
			$octet = '';
		}
	}

	return {
		host    => $host_address,
		network => $network_address
	};
}

sub getUnitFreeNumber
{
	my $number = shift;
	my $unit   = shift;
	my $base   = shift;

	my $m = 1024;
	if ( defined $base )
	{
		if ( $base =~ /byte/i )    # memory size is measured in bytes
		{
			$m = 1024;
		}
		elsif ( $base =~ /bit/i )    # network speed is measured in bits
		{
			$m = 1000;
		}
	}

	if ( $unit =~ /K/i ) { $number * $m; }

	elsif ( $unit =~ /M/i ) { $number * $m * $m; }

	elsif ( $unit =~ /G/i ) { $number * $m * $m * $m; }
}

sub bin2dec
{
	return unpack( "N", pack( "B32", substr( "0" x 32 . shift, -32 ) ) );
}

# this function gunzips and untars a file
sub parse_targz_data
{
	my $tarFilename    = shift;
	my $filenameFilter = shift;

	if ( !$filenameFilter )
	{
		$filenameFilter = ".*";
	}

	# uncompress the using Zlib interface functions
	my $buffer;
	my $gz = undef;

	my $temp_file     = new File::Temp();
	my $temp_filename = $temp_file->filename();
	binmode $temp_file;

	if ( $gz = gzopen( $tarFilename, "rb" ) )
	{
		while ( $gz->gzread($buffer) > 0 )
		{
			print $temp_file $buffer;
		}
		
		# Z_BUF_ERROR can be omitted
		if ( $gzerrno != Z_STREAM_END && $gzerrno != Z_BUF_ERROR )
		{
			die "Couldn't retrieve uncompressed data\n";
		}
		$gz->gzclose;
	}
	else
	{
		die "Couldn't open temporary gz file for reading\n";
	}

	# create file pointer for tar file
	my $tar = Archive::Tar->new($temp_filename);

	# get file list from temp tar file and sort them
	my @filenames = sort { lc($a) cmp lc($b) } $tar->list_files;

	# this variable will store the configuration of each file in tar archive
	my $configRepository = {};

	# run through the file list
	for my $filename (@filenames)
	{
		if ( $filename =~ /$filenameFilter/ )
		{
			my $fileContents = $tar->get_content($filename);    # get the content of this file
			if ($fileContents)                                  # directories don't need to be specifically created
			{
				my @pieces        = split( /\//, $filename );
				my $size          = @pieces;
				my $lastFolder    = $configRepository;
				my $hashStatement = "\$configRepository";
				for ( my $i = 0 ; $i < $size ; $i++ )
				{
					my $name = $pieces[$i];
					$hashStatement .= "->{\'$name\'}";
				}
				eval( $hashStatement .= " = \$fileContents;" );
			}
		}
	}

	# close temp tar file
	$temp_file->close();
	return $configRepository;
}

sub get_port_number
{

	# translates 'telnet' into '23'
	my $port = shift;
	return $portNumbers->{$port};
}

sub trim
{

	# remove leading and trailing whitespace
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub get_interface_type
{

	# given an interface type, figures out a valid ZipTie type that will
	# pass the zds:interface schema.  If there isn't a valid match, returns "unknown"
	my $type = shift;

	if ( !$type )
	{
		return "unknown";
	}
	if ( $type =~ /^lo|softwareLoopback/i )
	{
		return "softwareLoopback";
	}
	elsif ( $type =~ /frame/i )
	{
		return "frameRelay";
	}
	elsif ( $type =~ /eth/i )
	{
		return "ethernet";
	}
	elsif ( $type =~ /token/i )
	{
		return "tokenRing";
	}
	elsif ( $type =~ /BRI|PRI/i )
	{
		return "isdn";
	}
	elsif ( $type =~ /(gre|isdn|other|modem|ppp|serial|atm|sonet)/i )
	{
		return lc($1);
	}
	else
	{
		return "other";
	}
}

sub strip_mac
{

	# strips out everything but hex chars
	my $mac = shift;
	$mac =~ s/[^0-9a-f]//ig;
	return uc($mac);
}

sub get_model_filehandle
{
	my $adapter_name   = shift;
	my $ip_address     = shift;
	my $file_extension = "_model.xml";
	return _get_output_filehandle( $adapter_name, $ip_address, $file_extension );
}

sub get_cli_commands_filehandle
{
	my $adapter_name   = shift;
	my $ip_address     = shift;
	my $file_extension = "_cli_cmds.xml";
	return _get_output_filehandle( $adapter_name, $ip_address, $file_extension );
}

sub _get_output_filehandle
{
	my $adapter_name   = shift;
	my $ip_address     = shift;
	my $file_extension = shift;

	# Create a file handle to STDOUT unless it has been specified to output to a file
	my $filehandle = \*STDOUT;

	# Check to see if the "OUTPUT_MODEL_TO_FILE" exists
	my $output_model_to_file_flag = $ENV{OUTPUT_MODEL_TO_FILE};
	if ($output_model_to_file_flag)
	{

		# Cleanup the adapter name for any characters that are illegal to a file name
		$adapter_name =~ s/:://g;

		# Create the file name of the model output file
		my $output_model_file = escape_filename( $adapter_name . "_" . $ip_address . $file_extension );

		# Check to see if a directory has been specified
		my $output_model_dir = $ENV{OUTPUT_MODEL_DIR};
		if ($output_model_dir)
		{
			$output_model_file = $output_model_dir . "/" . $output_model_file;
		}

		# Open the output model file for writing to
		open( MODEL_OUTPUT_FH, ">$output_model_file" ) || $LOGGER->fatal("Unable to open '$output_model_file' for printing adapter output!");
		$filehandle = \*MODEL_OUTPUT_FH;
		$LOGGER->debug("Logging adapter output to '$output_model_file'");
	}
	else
	{
		$LOGGER->debug("Logging adapter output to STDOUT");
	}
	return $filehandle;
}

sub close_model_filehandle
{
	my $filehandle = shift;

	# Check to see if the "OUTPUT_MODEL_TO_FILE" exists.
	my $output_model_to_file_flag = $ENV{OUTPUT_MODEL_TO_FILE};

	# If it does exist, then the filehandle is expect to be a file, so we should close it.
	# If not, then do nothing since STDOUT should not be closed.
	if ($output_model_to_file_flag)
	{
		close($filehandle);
	}
}

sub create_empty_file
{
	my $filename = shift;
	open( FH, ">$filename" );
	close(FH);
}

sub escape_filename
{

	# Attempt to get any specified filename
	my $filename = shift;

	# If no file name was specified, leverage the File::Temp module to give us a unique filename
	if ( defined($filename) )
	{

		# Replace any non-compliant characters for filenames with a hyphen
		$filename =~ s/[\\\/:*\?"<>\|]/-/g;
		return $filename;
	}
	else
	{
		return "";
	}
}

sub create_unique_filename
{
	return tmpnam();
}

sub _td
{

	# given a one or two digit number, return a two digit padded number.
	# e.g. given '1' return '01'.  This is usefull for dates and times.
	my $int = shift;
	if ( $int =~ /^\d$/ )
	{
		return "0" . $int;
	}
	else
	{
		return $int;
	}
}

# taken from perlmonks.org
sub merge_hashes    # returns 0 on circular references
{

	# function merges 2 or more hashes
	# circular/duplicate links make function return 0
	my @hashrefs = @_;

	return 0 if grep { ref $_ ne 'HASH' } @hashrefs;    # original function died here

	my %merged = ();

	my @seen = grep { ref $_ eq 'HASH' } @SeenMerged{@hashrefs};    # Break circular links..

	if (@seen)
	{
		return 0;                                                   # original function died here
	}

	@SeenMerged{@hashrefs} = @hashrefs;

	foreach my $h (@hashrefs)
	{
		while ( my ( $k, $v ) = each %$h )
		{
			push @{ $merged{$k} }, $v;
		}
	}

	while ( my ( $k, $v ) = each %merged )
	{
		my @hashes = grep { ref $_ eq 'HASH' } @$v;
		$merged{$k} = $v->[0] if ( @$v == 1 && !ref $v->[0] );
		$merged{$k} = merge_hashes(@hashes) if @hashes;
	}

	delete @SeenMerged{@hashrefs};
	return \%merged;
}

sub choose_admin_ip
{

	# select the best IP for management
	my ( $originalIp, $interfaces ) = @_;
	my @ifArray = @{ $interfaces->{interface} };

	# check if this is a NAT'd device.  If so, don't pick an IP off of an interface
	my $natted = 1;
	foreach my $interface (@ifArray)
	{
		if ( defined $interface->{ipEntry} )
		{
			my @ips = @{ $interface->{ipEntry} };
			foreach my $ip (@ips)
			{
				if ( $ip->{ipAddress} eq $originalIp )
				{
					$natted = 0;
					$LOGGER->debug( "Orignal IP address $originalIp found on interface " . $interface->{name} );
					next;
				}
			}
		}
	}
	if ($natted)
	{
		$LOGGER->debug("Original IP address $originalIp was not found on an interface, assuming a NAT.");
		return $originalIp;
	}

	# now analyze any loopbacks
	foreach my $interface (@ifArray)
	{
		if ( $interface->{operStatus} !~ /Down/i && $interface->{type} =~ /softwareLoopback/i )
		{
			$LOGGER->debug("Testing interface ".$interface->{name}." for an admin IP.");
			my $passingIp = _test_interface_ips($interface);
			if ($passingIp)
			{
				return $passingIp;
			}
		}
	}

	# now look at the rest if there hasn't been a match yet
	foreach my $interface (@ifArray)
	{
		if ( $interface->{operStatus} !~ /Down/i && $interface->{type} !~ /softwareLoopback/i )
		{
			$LOGGER->debug("Testing interface ".$interface->{name}." for an admin IP.");
			my $passingIp = _test_interface_ips( $interface );
			if ($passingIp)
			{
				return $passingIp;
			}
		}
	}

	return $originalIp;    # fall back choice
}

sub _test_interface_ips
{
	my $interface = shift;
	if ( defined $interface->{ipEntry} )
	{
		my @ips = @{ $interface->{ipEntry} };
		foreach my $ip (@ips)
		{
			if ( $ip->{ipAddress} !~ /^127\./ )
			{
				my $pinger;
				if ( $OS =~ /(?<!dar)win|sun|solaris/i )
				{
					$pinger = Net::Ping->new('icmp');
				}
				else
				{
					$pinger = Net::Ping->new();
				}
				
				if ( $pinger->ping( $ip->{ipAddress} ) )
				{
					$LOGGER->debug( "Administrative IP address chosen: " . $ip->{ipAddress} );
					return $ip->{ipAddress};
				}
				else
				{
					$LOGGER->debug('Candidate admin IP '.$ip->{ipAddress}.' is not responding to ping.');
				}
			}
		}
	}
	return 0;
}

1;
__END__

=head1 NAME

ZipTie::Adapters::Utils - General Utility Methods for Adapters

=head1 SYNOPSIS

    use ZipTie::Adapters::Utils;
	my $port = get_port_number('ssh');
	my $mask = get_mask(16);
	my $date = w3c_datetime($commonDate);

=head1 Description

Utils provides several static utility methods to make it easier for
adapter parsing modules to produce output that will pass the ZipTie
model schema.

=head2 Methods

=over 12

=item C<get_mask>

Given a CIDR mask, returns the matching bit mask.  For example
C<get_mask('24')> will return "255.255.255.0".

=item C<mask_to_bits($ipMask)>

Given an IPv4 address mask such as 255.255.255.0, converts to its
bit mask (24).

=item C<get_port_number>

Given a service name, returns the matching port number.  For example
C<get_port_number('telnet')> will return "23".

=item C<seconds_since_epoch($sec, $min, $hour, $mday, $month, $year, $timezone)>

Converts dates into the ZED required long format in seconds since Unix epoch.

Inputs:		$sec - seconds
			$min - minutes
			$hour - hour in 24 hour format
			$mday - day of the month
			$month - the month integer (1-12) or the shorthand name, e.g. 'Jan'
			$year - the 4 digit year
			$timezone - the timezone name, e.g. CST.  This is optional, UTC is assumed if it is not provided.

=item C<trim>

removes leading and trailing whitespace from the input string.

=item C<get_interface_type>

given the type or name of an interface, it tries to make a best 
guess as the proper ZipTie interface type.

=item C<strip_mac>

Returns just the hex chars from the provided string

=item C<choose_admin_ip($originalIp, $interfaceHash)>

Chooses an IP address using criteria from the list of interfaces provided in the 
$interfacesHash.  

The $originalIp must also be passed through as it is used to determine if the device
is behind a NAT or not.  For example, if you found this device via an IP address
that it wasn't configured for locally, then it is likely that the device is behind some
sort or translation (NAT).  When that is the case, the $originalIp is returned as the preferred
administrative IP address.

This method will choose available loopback IP addresses first.
It will return a single scalar string that represents the IP address.

The incoming $interfacesHash should match the telemetry.xsd XML schema. Here 
is an example of the data structure of the incoming hash table.

$VAR1 = {
          'interface' => [
                           {
                             'operStatus' => 'Up',
                             'name' => 'Ethernet0/0',
                             'type' => 'ethernet',
                             'ipEntry' => [
                                            {
                                              'ipAddress' => '10.100.8.10',
                                              'mask' => '29'
                                            }
                                          ],
                             'inputBytes' => '873995991'
                           },
                           {
                             'operStatus' => 'Down',
                             'name' => 'Serial0/0',
                             'type' => 'serial',
                             'inputBytes' => '0'
                           },
                           {
                             'operStatus' => 'Up',
                             'name' => 'Ethernet0/1',
                             'type' => 'ethernet',
                             'ipEntry' => [
                                            {
                                              'ipAddress' => '10.100.8.25',
                                              'mask' => '29'
                                            }
                                          ],
                             'inputBytes' => '1194740983'
                           },
                           {
                             'operStatus' => 'Up',
                             'name' => 'Loopback0',
                             'type' => 'softwareLoopback',
                             'ipEntry' => [
                                            {
                                              'ipAddress' => '10.100.8.151',
                                              'mask' => '32'
                                            }
                                          ],
                             'inputBytes' => '0'
                           }
                         ]
        };


=item C<parse_targz_data($tgzFilename, $filenameFilter)>

$tgzFilename - the full path to the tar file to inspect
$filenameFilter - an optional setting, this is a regex that allows you to only untar
				  files that match this regular expression.  The regex is applied to the entire path.

Given a full path to a tar'd and zipped file (.tgz), unzip and untar the file
and place the contents of the file in a hash structure.

For example, if the tar contained these files.....
	/home/rkruse/filea
	/home/rkruse/fileb
	/etc/named.conf

The returned hash from this call would look like.....

	$VAR1 = {
          'home' => {
                      'rkruse' => {
                                    'fileb' => 'fileb contents',
                                    'filea' => 'filea contents'
                                  }
                    },
          'etc' => {
                     'namedconf' => 'named.conf contents'
                   }
	};


=item C<get_model_filehandle($adapter_name, $ip_address)>

Returns a file handle that an adapter can use to output model data to.  By default, I<STDOUT> will be used as the file handle;
however, the output can also be written to a file that uses the specified adapter name/ID and IP address to have a file name
that follows the syntax of: C<adapterName_ipAddress_model.xml>.

Output of the model to a file can be configured via two environment varaibles: B<OUTPUT_MODEL_TO_FILE> and B<OUTPUT_MODEL_DIR>.

B<OUTPUT_MODEL_TO_FILE> is a boolean environment variable to determine whether or not output of the model should be done to
a file at all.  If the value of it is false of empty, then the filehandle to use will be I<STDOUT>.  Otherwise, the model will
be written to a file with the syntax of: C<adapterName_ipAddress_model.xml>.

B<OUTPUT_MODEL_DIR> is only important if the B<OUTPUT_MODEL_TO_FILE> environment variable has been set.  If it has been
determined that the model should be output to a file, then B<OUTPUT_MODEL_DIR> will be checked to see which directory
the output model file will be written to.  If the environment variable exists, it will be prepended to the file name
generated from the adapter ID and IP address specified.  Otherwise, the output model file will be within the current
working directory of Perl.

=item C<get_cli_commands_filehandle($adapter_name, $ip_address)>

Very similar to the C<get_model_filehandle($adapter_name, $ip_address)> method, but delivers
an XML document name that is specific to an adapter that is running CLI commands only and
not performing a backup.

=item C<close_model_filehandle($filehandle)>

Closes the filehandle that has been used for output model information.  It is assumed that the filehandle specified is the
one retrieved from C<get_model_filehandle($adapter_name, $ip_address)>.  If the filehandle that is being used is STDOUT,
then it will B<NOT> be closed; otherwise it will be closed.

=item C<create_empty_file($filename)>

Creats an empty file using the 'open' command against the provided filename.
A filehandle is created but immediately closed.

=item C<get_crep('cipm')>

Returns the regex. pattern referenced by the key. All the (c)ommon (r)egular (e)xpression
(p)atterns are stored in the creps hash.

=item C<sub escape_regex_metas('(don't capture nor cluster this)')>

Escapes regex. metacharacters which are used in regular expressions. 

=item C<unescape_regex_metas('\(don't capture nor cluster this\)')>

Unescapes the regex. pattern escaped with escape_regex_metas.

=item C<parseCIDR('10.100/16')>

Convert Classless InterDomain Routing address to ip address and subnet mask.

=item C<bin2dec('1000')>

Converts binary number to decimal number.

=item C<merge_hashes($ref_hash1,$ref_hash2)>

Merges two or more hashes.

=item C<escape_filename($filename)>

Replaces any characters that are not suitable for use in a filename with a hyphen.  It is assumed that the filename
specified is a relative filename, and thus forward slashes and back slashes are not allowed.

=item C<create_unique_filename>

Simple wrapper for C<File::Name::tmpnam()> to grab fully-qualified name of an available temp file.

=back

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

  Contributor(s): rkruse, bedwards, mkourbanov
  Date: Apr 25, 2007

=cut
