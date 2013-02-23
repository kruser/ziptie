package ZipTie::Adapters::Nortel::Contivity::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	#if ( $in->{} =~ /^/)
	#{
	#	$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	#}
	if ( $in->{flash} =~ /\bserial number:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Nortel";
	if ( $in->{flash} =~ /\bmodel number:\s+(\S+)/mis )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );

	if ( $in->{snmp_identity} =~ /\bSysDescr\s+(\S.+)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element('core:description', $_);
	}

	my $cpu;
	if ( $in->{version} =~ /\bProcessor \d+:\s+(\S[^\,]+)/mi )
	{
		$cpu->{"core:description"} = $1;
		my $cputRE = createCPUTypesRE();
		if ( $cpu->{"core:description"} =~ /$cputRE/i )
		{
			$cpu->{cpuType} = $1;
		}
	}
	$out->print_element( "cpu", $cpu );

	_parse_file_storage( $in, $out );

	if ( $in->{version} =~ /\bMemory:\s+(\d+) (\S+) Free, (\d+) (\S+) Total/mi )
	{
		$out->print_element( "memory", { 'core:description' => 'RAM', kind => 'RAM', size => getUnitFreeNumber($3, $4, 'byte') } );
	}
	if ( $in->{version} =~ /\bHard Disk \d+:\s+\d+ MB Free, (\d+) (\S+) Total/mi )
	{
		$out->print_element( "memory", { 'core:description' => 'Flash', kind => 'Flash', size => getUnitFreeNumber($1, $2, 'byte') } );
	}

	$out->close_element("chassis");
}

sub _parse_file_storage
{
	my ( $in, $out )	= @_;
	my $storage			= undef;

	if ( $in->{version} =~ /\bHard Disk (\d+):\s+(\d+) (\S+) Free\, (\d+) (\S+) Total/mi )
	{
		$storage =
		{
			name        => $1,
			storageType => 'disk',
			size        => getUnitFreeNumber($4, $5, 'byte'),
			freeSpace	=> getUnitFreeNumber($2, $3, 'byte'),
		};
	}
	if ( defined $storage )
	{
		$out->print_element( "deviceStorage", $storage );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{hosts} =~ /\b\s*DNS Host Name: (\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Nortel' );
	$out->print_element( 'core:name', 'Contivity' );
	if ( $in->{version} =~ /\bSoftware Version:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'Contivity' );
	$out->close_element('core:osInfo');

	if ( $in->{version} =~ /\bBIOS Version:\s+(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'VPN Concentrator' );

	if ( $in->{snmp_identity} =~ /\bSysContact\s+(\S.*)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element( 'core:contact', $_ );
	}

	if ( $in->{version} =~ /\bUp Time:(?:\s+\d+)?\s+(\S+)/mi )
	{
		my $device_time     = $1;

		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
		( $hour, $min, $sec ) = $device_time =~ /(\d+):(\d+):(\d+)/;
		my $timezone = 'CST';

		# print restart time
		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, $mday, ($mon + 1), ($year + 1900), $timezone ) );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository = { 'core:name' => '/', };

	# now push all of the ucs contents as single files into the repository
	_push_configurations($repository, $in->{config});

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub _push_configurations
{
	my ($repository, $config_sk) = @_;
	for my $key ( keys %{$config_sk} )
	{
		if ( scalar $config_sk->{$key} =~ /^HASH/ )
		{	
			my $folder = { 'core:name' => $key, };
			push( @{ $repository->{'core:folder'} }, $folder );
			_push_configurations($folder, $config_sk->{$key});
		}
		else
		{
			my $file = {
				'core:name'       => $key,
				'core:textBlob'   => encode_base64($config_sk->{$key}),
				'core:mediaType'  => 'text/plain',
				'core:context'    => 'N/A',
				'core:promotable' => 'false',
			};
			push( @{ $repository->{'core:config'} }, $file );    
		}
	}
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;

	$out->open_element("localAccounts");
	while ( $in->{'running-config'} =~ /\badminname (\S+) epassword "([^\s"]+)"/mig )
	{
		my $account =
			{
				accountName => $1,
				password	=> $2,
			};
		$out->print_element( "localAccount", $account );
	}
	$out->close_element("localAccounts");
}

sub parse_filters
{
	my ( $in, $out )		= @_;
	my $openedFilterLists	= undef;
	my $filter_settings;

	while ( $in->{'running-config'} =~ /\bfilter tunnel rule "([^"]+)"(.+?)\bexit/migs )
	{
		my $filter_name	= $1;
		my $filter_blob = $2;
		if ( !$openedFilterLists )
		{
			$openedFilterLists	= 1;
			$out->open_element("filterLists");
			$filter_settings	= parse_filter_settings($filter_blob);
		}
		$out->open_element( "filterList" );
		$out->print_element( "filterEntry", parse_filter( $filter_blob, $filter_settings ) );
		$out->print_element( "mode", 'stateless');
		$out->print_element( "name", $filter_name );
		$out->close_element( "filterList" );
	}

	if ($openedFilterLists)
	{
		$out->close_element("filterLists");
	}
}

sub parse_filter_settings
{
	my $filter_blob	= shift;
	my $filter_ports;
	my $filter_addresses;

	my $cipm = get_crep('cipm');
	while ( $filter_blob =~ /^(.+)$/mig )
	{
		$_ = $1;
		if ( /\bport "([^"]+)" (\d+)/i )
		{
			$filter_ports->{$1} = $2;
		}
		elsif ( /\baddress "([^"]+)" ip ($cipm) mask ($cipm)/i )
		{
			$filter_addresses->{$1}->{ip}	= $2;
			$filter_addresses->{$1}->{mask}	= mask_to_bits($3);
		}
	}

	return my $filter_settings =
				{
					'ports'			=> $filter_ports
					, 'addresses'	=> $filter_addresses
				};
}

sub parse_filter
{
	my ( $filter_blob, $filter_settings ) = @_;
	my $filter_ports		= $filter_settings->{'ports'};
	my $filter_addresses	= $filter_settings->{'addresses'};

	my $cipm = get_crep('cipm');
	my $filter_entry;

	if ( $filter_blob =~ /\baction\s+(\S+)/mi )
	{
		$filter_entry->{primaryAction} = lc($1);
	}
	my ($protocol, $portStart, $portEnd, $operator);
	if ( $filter_blob =~ /\buse protocol "([^\s"]+)"/mi )
	{
		$protocol = uc($1);
		$protocol = 'TCP' if ( $protocol !~ /^(TCP|UPD|ICMP)$/i );
	}
	$operator = 'eq';
	if ( $filter_blob =~ /\buse dest-port (\S+) "([^"]+)"/mi )
	{
		$operator  = lc($1);
		if ( lc($2) ne 'any' )
		{
			$portStart = $filter_ports->{$2};
		}
		else
		{
			$portStart	= 0;
			$portEnd	= 65535;
		}
		$operator  = 'ne' if ( $operator eq 'neq' );
	}
	if ( defined $protocol && defined $portStart )
	{
		$protocol = lc ( $protocol );
		if ( !defined $portEnd )
		{
			push @{$filter_entry->{destinationService}}, { portExpression => {operator => $operator, port => $portStart, protocol => $protocol} };
		}
		else
		{
			push @{$filter_entry->{destinationService}}, { portRange => {portStart => $portStart, protocol => $protocol, portEnd => $portEnd} };
		}
	}
	my ($address, $mask);
	if ( $filter_blob =~ /\buse address "([^"]+)"/mi )
	{
		$address	= $filter_addresses->{$1}->{ip};
		$mask		= $filter_addresses->{$1}->{mask};
	}
	if ( defined $address )
	{
		$mask = '32' if ( !defined $mask );
		push @{$filter_entry->{destinationIpAddr}}, { network => {address => $address, mask => $mask} };
	}
	$operator = 'eq';
	if ( $filter_blob =~ /\buse src-port (\S+) "([^"]+)"/mi )
	{
		$operator  = lc($1);
		if ( lc($2) ne 'any' )
		{
			$portStart = $filter_ports->{$2};
		}
		else
		{
			$portStart	= 0;
			$portEnd	= 65535;
		}
		$operator  = 'ne' if ( $operator eq 'neq' );
	}
	if ( defined $protocol && defined $portStart )
	{
		$protocol = lc ( $protocol );
		if ( !defined $portEnd )
		{
			push @{$filter_entry->{sourceService}}, { portExpression => {operator => $operator, port=> $portStart, protocol => $protocol} };
		}
		else
		{
			push @{$filter_entry->{sourceService}}, { portRange => {portStart => $portStart, protocol => $protocol, portEnd => $portEnd} };
		}
	}
	if ( defined $address )
	{
		$mask = '32' if ( !defined $mask );
		push @{$filter_entry->{sourceIpAddr}}, { network => {address => $address, mask => $mask} };
	}
	$filter_entry->{'log'}			= 'false';
	$filter_entry->{'processOrder'}	= '1';

	return $filter_entry;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;

	$out->open_element("snmp");
	if ( $in->{snmp_identity} =~ /\bSysContact\s+(\S.*)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element( "sysContact", $_ );
	}
	if ( $in->{snmp_identity} =~ /\bSysLocation\s+(\S.*)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element( "sysLocation", $_ );
	}
	if ( $in->{snmp_identity} =~ /\bSysName\s+(\S.*)$/mi )
	{
		$_ = $1;
		$_ = trim($_);
		$out->print_element( "sysName", $_ );
	}
	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;

	my $staticRoutes;
	my $cipm = get_crep('cipm');
	while ( $in->{routes} =~ /^STATIC\s+($cipm)\s+($cipm)\s+\[(\d+)\]\s+($cipm)\s+($cipm)\s*$/mig )
	{
		my $route = {
			destinationAddress => $1,
			destinationMask    => mask_to_bits ( $2 ),
			gatewayAddress     => $4,
			defaultGateway     => ($1 ne '0.0.0.0' ? 'false' : 'true'),
			routeMetric		   => $3,
			interface	       => _pick_subnet ( $4, $subnets ),
		};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub _pick_subnet
{

	# choose from a hash of subnets and return the matching value
	my ( $gw, $subnets ) = @_;

	if ( defined $subnets )
	{
		foreach my $interfaceName ( sort ( keys(%$subnets) ) )
		{
			my @subnetsArray = @{ $subnets->{$interfaceName} };
			foreach my $subnet (@subnetsArray)
			{
				if ( $subnet->contains( $gw ) )
				{
					return $interfaceName;
				}
			}
		}
	}
	else
	{
		return "";
	}
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $subnets		 = {};    # will be returned to the caller
	my $interface    = {};
	my ($if_ipAddress, $if_mask, $if_broadcast);
	$out->open_element("interfaces");

	my $cipm = get_crep('cipm');
	my $mac2 = get_crep('mac2');
	while ( $in->{interfaces} =~ /^(.*)$/mig )
	{
		my $if_line = $1;
		if ( $if_line =~ /\b(\S+) \(unit number (\d+)(?:, index (\d+))?\):\s*$/i )
		{
			if ( defined $interface->{name} )
			{
				if ( defined $if_ipAddress && defined $if_mask && defined $if_broadcast )
				{
					push @{$interface->{interfaceIp}->{ipConfiguration}}, { broadcast => $if_broadcast, ipAddress => $if_ipAddress, mask => mask_to_bits($if_mask), precedence => 1 };
					$if_ipAddress = $if_mask = $if_broadcast = undef;
				}
				$out->print_element( "interface", $interface );
				$interface = {};
			}
			my $unit_num				= $2;
			$_							= $1;
			$interface->{name}          = $_;
			$interface->{physical}      = _is_physical($_);
			if ( /^lo/i )
			{
				$interface->{interfaceType} = get_interface_type('loopback');
			}
			elsif ( /^fe/i )
			{
				$interface->{interfaceType} = get_interface_type('eth');
			}
			else
			{
				$interface->{interfaceType} = get_interface_type($_);
			}
		}
		elsif ( $if_line =~ /\s*Flags:\s+\S+\s+(UP|DOWN)/i
				&& defined $interface->{name} )
		{
			$interface->{adminStatus} = lc($1);
			#if ($if_line =~ /\bARP /i)
			#{
			#	$interface->{interfaceIp}->{localProxyArp} = 'true';
			#}
			#if ($if_line =~ /\bBROADCAST /i)
			#{
			#	$interface->{interfaceIp}->{directedBroadcast} = 'true';
			#}
		}
		elsif ( $if_line =~ /\s*Internet address:\s+($cipm)/
				&& defined $interface->{name} )
		{
			$if_ipAddress = $1;
		}
		elsif ( $if_line =~ /\s*Netmask\s+(?:0x)?(\S{2})(\S{2})(\S{2})(\S{2})/
				&& defined $interface->{name} )
		{
			$if_mask = hex($1).'.'.hex($2).'.'.hex($3).'.'.hex($4);
		}
		elsif ( $if_line =~ /\s*Broadcast address:\s+($cipm)/
				&& defined $interface->{name} )
		{
			$if_broadcast = $1;
		}
		elsif ( $if_line =~ /\s*Maximum Transfer Unit size is (\d+)/
				&& defined $interface->{name} )
		{
			$interface->{mtu} = $1;
		}
		elsif ( $if_line =~ /\s*Ethernet address is ($mac2)/
				&& defined $interface->{name} )
		{
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($1);
		}
	}

	if ( defined $interface->{name} )
	{
		if ( defined $if_ipAddress && defined $if_mask && defined $if_broadcast )
		{
			push @{$interface->{interfaceIp}->{ipConfiguration}}, { broadcast => $if_broadcast, ipAddress => $if_ipAddress, mask => mask_to_bits($if_mask), precedence => 1 };
			$if_ipAddress = $if_mask = $if_broadcast = undef;
			my $subnet = new ZipTie::Addressing::Subnet( $if_ipAddress, mask_to_bits($if_mask) );
			push( @{ $subnets->{$interface->{name}} }, $subnet );
		}
		$out->print_element( "interface", $interface );
		$interface = {};
	}

	$out->close_element("interfaces");

	return $subnets;
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_stp
{
	my ( $in, $out ) = @_;
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

sub createCPUTypesRE
{
	my @cpuTypes = qw(Pentium Celeron Xeon XeonMP Itanium
	  Athlon AthlonFX Opteron OpteronMP Duron Sempron);
	'\b(' . join( '|', @cpuTypes ) . ')';
}

sub getUnitFreeNumber
{
	my $number	= shift;
	my $unit	= shift;
	my $base	= shift;

	my $m = 1024;
	if (defined $base)
	{
		if ($base =~ /byte/i) # memory size is measured in bytes
		{
			$m = 1024;
		}
		elsif ($base =~ /bit/i) # network speed is measured in bits
		{
			$m = 1000;
		}
	}

	if ($unit =~ /K/i)
	{$number * $m;}

	elsif ($unit =~ /M/i)
	{$number * $m * $m;}

	elsif ($unit =~ /G/i)
	{$number * $m * $m * $m;}
}

1;
