package ZipTie::Adapters::Cisco::LocalDirector::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac get_crep getUnitFreeNumber mask_to_bits);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";
	if ( $in->{version} =~ /^(.+?)\s+Version/m )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ( $in->{hw} =~ /^([^\s,]+),/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = 'Unknown';
	$out->print_element( "core:asset", $chassisAsset );

	if ( $in->{hw} =~ /CPU\s+(\S.+)$/mi )
	{
		my $cpu;
		$cpu->{"core:description"}	= trim($1);
		$_							= createCPUTypesRE();
		$cpu->{cpuType}				= $1 if ( $cpu->{"core:description"} =~ /$_/i );
		$out->print_element( "cpu", $cpu );
	}

	if ( $in->{hw} =~ /(\d+) (\S+) RAM/mi )
	{
		$_ = getUnitFreeNumber($1,$2,'byte');
		my $memory = {
			'core:description' => 'RAM',
			kind => 'RAM',
			size => $_,
		};
		$out->print_element( "memory", $memory );
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{config} =~ /\bhostname\s+(\S+)$/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Cisco' );
	$out->print_element( 'core:name', 'LocalDirector' );
	if ( $in->{config} =~ /: LocalDirector (\d+) Version (\S+)/mi )
	{
		$out->print_element( 'core:version', $2 );
	}
	$out->print_element( 'core:osType', 'LocalDirector' );
	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Load Balancer' );

	my ($contact) = $in->{config} =~ /^snmp-server contact\s+(\S+)/mi;
	$out->print_element( 'core:contact', $contact );

	# Uptime is 59 days, 6 hours, 52 minutes
	if ( $in->{version} =~ /Uptime is\s+(.+)/i )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$out->print_element( "core:lastReboot", $lastReboot );
	}
	# set uptime to now
	else
	{
		my ($years,$weeks,$days,$hours,$minutes);

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$out->print_element( "core:lastReboot", $lastReboot );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	# build the simple text configuration
	my $config;
	$config->{'core:name'}       = 'config';
	$config->{'core:textBlob'}   = encode_base64( $in->{'config'} );
	$config->{'core:mediaType'}  = 'text/plain';
	$config->{'core:context'}    = 'active';
	$config->{'core:promotable'} = 'false';                             

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;

	# local account - enable
	if ( $in->{config} =~ /^enable password (\S+) encrypted/mi )
	{
		$out->open_element("localAccounts");

		my $username   = "enable";
		my $account = {
			accountName => $username,
			password    => $1,
			accessLevel => 15,
		};
		$out->print_element( "localAccount", $account );

		$out->close_element("localAccounts");
	}
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	$out->open_element("snmp");

	while ( $in->{config} =~ /^snmp-server community (.+)$/mig )
	{
		$_ = $1;
		$_ = trim($_);
		my $community =
		{
			communityString => $_,
			accessType		=> 'RO'
		};
		$out->print_element( "community", $community );
	}

	if ( $in->{config} =~ /^snmp-server contact (.+)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element( "sysContact", $_ );
	}
	if ( $in->{config} =~ /^snmp-server location (.+)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element( "sysLocation", $_ );
	}
	if ( $in->{config} =~ /\bhostname (\S+)$/mi )
	{
		$out->print_element( "sysName", $1 );
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	my $cipm = get_crep('cipm');
	while ( $in->{routes} =~ /^\s*($cipm) ($cipm) ($cipm) (\d+) \S+ static$/mig )
	{
		my $route =
		{
			defaultGateway		=> ( $1 eq '0.0.0.0' ? 'true' : 'false' ),
			destinationAddress	=> $1,
			destinationMask     => mask_to_bits ( $2 ),
			gatewayAddress      => $3,
			routeMetric         => $4,
			interface          	=> 'Unknown',
		};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;

	my $interface	= {};
	my $mac3		= get_crep('mac3');
	$out->open_element("interfaces");
	while ( $in->{interfaces} =~ /^(.+)$/mig )
	{
		my $if_line = $1;
		if ( $if_line =~ /^ethernet (\d+) is ([^\s,]+),? line protocol is (\S+)\s*$/ )
		{
			if ( $interface->{adminStatus} )
			{
				$out->print_element( "interface", $interface );
				$interface = {};
			}
			$interface =
			{
				name			=> $1,
				adminStatus		=> lc($2),
				interfaceType	=> 'ethernet',
				physical     	=> _is_physical($1),
			};
		}
		elsif ( $if_line =~ /^\s*Hardware is \S+ rev \S+ ethernet,? address is ($mac3)\s*$/i
					&& $interface->{adminStatus} )
		{
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($1); 
		}
		elsif ( $if_line =~ /^\s*MTU (\d+) bytes, BW (\d+) (\S+) (half|full|auto) duplex\s*$/i
					&& $interface->{adminStatus} )
		{
			$interface->{mtu}	= $1;
			$_					= lc($4);
			$interface->{speed}	= getUnitFreeNumber( $2, $3, 'bit' );
			if ( /auto/i )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = 'true';
			}
			else
			{
				$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
				$interface->{interfaceEthernet}->{operationalDuplex}	= $_;
			}
		}
	}

	if ( $interface->{adminStatus} )
	{
		$out->print_element( "interface", $interface );
		$interface = {};
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

sub createCPUTypesRE
{
	my @cpuTypes = qw(Pentium Celeron Xeon XeonMP Itanium
	  Athlon AthlonFX Opteron OpteronMP Duron Sempron);
	'\b(' . join( '|', @cpuTypes ) . ')';
}

sub _is_physical
{
	my $name = shift;
	if ( $name =~ /\.\d+$/ )
	{
		return "false";
	}
	elsif ( $name =~ /seri|eth|gig|^fe|^fa|token|[bp]ri/i )
	{
		return "true";
	}
	else
	{
		return "false";
	}
}

1;
