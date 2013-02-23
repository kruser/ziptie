package ZipTie::Adapters::Marconi::ATMSwitch::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type getUnitFreeNumber strip_mac get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{fabric} =~ /^\s*\d+\s+(\S+)\s+\S+\s+(\S+)\s+\d+\s+\d+\s+\S+\s*$/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $2;
		$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Marconi";
	}
	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	my @memories;
	my $mac1 = get_crep('mac1');
	if ( $in->{scp} =~ /\b(\S+)\s+(\S+)\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+\s+(\S+)\s+$mac1\s+(\S+)\s*$/mi )
	{
		my $cpu;
		$cpu->{"core:asset"}->{"core:assetType"} = "CPU";
		$cpu->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}				= 'Marconi';
		$cpu->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}		= $6 if ( $6 ne 'N/A' );
		$cpu->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}		= $7 if ( $7 ne 'N/A' );
		$cpu->{"core:description"}	= $1;
		$cpu->{cpuType}				= $2;
		$out->print_element( "cpu", $cpu );

		my $dram	= $3;
		my $flash	= $4;
		my $ide		= $5;
		if ( uc ($3) ne 'N/A' )
		{
			my ( $s, $m ) = $dram =~ /([\d\.]+)(K|M|G)/i;
			push @memories, { kind => 'RAM', size => getUnitFreeNumber( $s, $m ) };
		}
		if ( uc ($4) ne 'N/A' )
		{
			my ( $s, $m ) = $dram =~ /([\d\.]+)(K|M|G)/i;
			push @memories, { kind => 'Flash', size => getUnitFreeNumber( $s, $m ) };
		}
		if ( uc ($5) ne 'N/A' )
		{
			my ( $s, $m ) = $dram =~ /([\d\.]+)(K|M|G)/i;
			push @memories, { kind => 'Other', size => getUnitFreeNumber( $s, $m ) };
		}
	}

	_parse_file_storage( $in, $out );

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	_parse_power_supply( $in, $out );

	$out->close_element("chassis");
}

sub _parse_cards
{
	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	while ( $in->{portcard} =~ /\b(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S.+)$/mig )
	{
		my $no			= $1;
		my $hwVersion	= $2;
		my $serialNo	= $4;
		my $description	= $5;
		my $modelNo;
		my $portCount;
		if ( $in->{netmod} =~ /\b\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s+\S+\s+\S+\s+$serialNo\s+(\S+)\s*$/mi )
		{
			$portCount	= $1;
			$modelNo	= $2;
		}
		my $card      =
		{
			slotNumber         => $no,
			portCount          => $portCount,
			"core:description" => $description,
		};
		$card->{"core:asset"}->{"core:assetType"} = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}				= 'Marconi';
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}		= $modelNo;
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}		= $serialNo;
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"}	= $hwVersion;

		$out->print_element( "card", $card );
	}
}

sub _parse_file_storage
{
	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;

	my $storage;
	if ( $in->{free} =~ /\bAvailable space on flash \(in bytes\):\s+(\d+)/mi )
	{
		$storage->{name}        = 'flash';
		$storage->{storageType} = 'flash';
		$storage->{freeSpace}	= $1;
		#$storage->{rootDir} = { name => "root", };
		my $size;
		while ( $in->{dir} =~ /\b\s*(\d+)\s+\S{1,3}-\d{1,2}-\d{1,4}\s+\d{1,2}:\d{1,2}:\d{1,2}\s+(\S+)$/mig )
		{
			# we won't store the files because there are directories with sub elements on the flash device
			#my $file =
			#{
			#	size => $1,
			#	name => $2,
			#};
			#push( @{ $storage->{rootDir}->{file} }, $file );
			$size += $1;
		}
		$storage->{size} = $storage->{freeSpace} + $size;
		$out->print_element( "deviceStorage", $storage );
	}
}

sub _parse_power_supply
{
	my ( $in, $out ) = @_;

	while ( $in->{power} =~ /\b(\d+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)/mig )
	{
		my $power_supply;
		$power_supply->{number}				= $1;
		$power_supply->{'core:description'} = $2 if ( uc( $2 ) ne 'N/A' );
		$power_supply->{status}				= $3 if ( uc( $3 ) ne 'N/A' );
		if ( uc( $5 ) ne 'N/A' || uc( $4 ) ne 'N/A' )
		{
			$power_supply->{"core:asset"}->{"core:assetType"}							= "PowerSupply";
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= $5 if ( uc( $5 ) ne 'N/A' );
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}	= $4 if ( uc( $4 ) ne 'N/A' );
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}			= 'Marconi';
		}
		$out->print_element( "powersupply", $power_supply );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{'system'} =~ /\bSystem Name:\s+(\S.+)$/mi;
	$out->print_element( 'core:systemName', trim ( $systemName ) );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Marconi' );
	
	#Software Version:             S_ForeThought_7.1.0 FCS-Patch (1.118147)
	if ( $in->{'system'} =~ /\bSoftware Version:\s+((?:[a-zA-Z]+_)((?:[^\d\s_]*_?)+)_(\d+(?:\.\d+)*).*$)/mi )
	{
		$out->print_element( 'core:name', $2 );
		$out->open_element( 'core:softwareImage');
		$out->print_element( 'core:description', $1 );
		$out->close_element( 'core:softwareImage');
		$out->print_element( 'core:version', $3 );
		$_ = $1;
		if ( /ForeThought/ )
		{
			$out->print_element( 'core:osType', 'FT' );
		}
	}
	$out->close_element('core:osInfo');

	if ( ( $in->{version} =~ /\bCurrent Flash-Boot Version:\s+(\S.+)$/mi ) )
	{
		$out->print_element( 'core:biosVersion', trim ( $1 ) );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{'system'} =~ /\bSystem Contact:\s+(\S.+)$/mi;
	$out->print_element( 'core:contact', trim ( $contact ) );

	# Switch Uptime:                13 days 00:05
	
	if ( $in->{'system'} =~ /\bSwitch Uptime:\s+(?:(\d+) days?)? (\d+):(\d+)/mi )
	{
		my $days		= $1 if ( $1 ) ;
		my ($hours)		= $2;
		my ($minutes)	= $3;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$out->print_element( "core:lastReboot", $lastReboot );
	}
	elsif (defined $in->{uptime})
	{
		my $now = time();
		my $lastReboot = $now - ($in->{uptime} / 100);
		$out->print_element('core:lastReboot', int($lastReboot));
	}
	else
	{
		$out->print_element('core:lastReboot', 0);
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
	$config->{'core:promotable'} = 'true';

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
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	$_ = get_crep('cipm');
	while ( $in->{routes} =~ /\b($_|default)\s+($_)\s+(\d+)\s+(\S+)/mig )
	{
		my $route = 
		{
			destinationAddress	=> ( lc($1) ne 'default' ) ? $1 : '0.0.0.0',
			destinationMask		=> ( lc($1) ne 'default' ) ? '32' : '0',
			defaultGateway		=> ( lc($1) ne 'default' ) ? 'false' : 'true',
			gatewayAddress		=> $2,
			routeMetric			=> $3,
			interface			=> $4,
		};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");

	while ( $in->{if_show} =~ /\b(\d+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(up|down)\s+(up|down)\s+(\S.+)\s*$/mig )
	{
		my $index		= $1;
		my $name		= $2;
		my $type		= $3;
		my $speed		= $4;
		my $astatus		= $5;
		my $ostatus		= $6;
		my $desc		= $7;
		my $interface	= 
		{
			adminStatus		=> $astatus,
			description		=> $desc,
			name			=> $name,
			interfaceType	=> get_interface_type($type),
			physical		=> _is_physical($name),
		};
		$_ = get_crep('cipm');
		if ( $in->{ip_show} =~ /\b$name\s+\S+\s+($_)\s+($_)\s+($_)\s+(?:\d+|N\/A)\s+(\d+|N\/A)\s*$/mi )
		{
			my $ip		= $1;
			my $mask	= $2;
			my $bcast	= $3;
			my $mtu		= $4;
			push @{$interface->{interfaceIp}->{ipConfiguration}}, { broadcast => $bcast, ipAddress => $ip, mask => mask_to_bits($mask) };
			if ( $mtu =~ /^\d+$/ )
			{
				$interface->{mtu} = $mtu;
			}
		}
		if ( $in->{auto_neg} =~ /\b$name\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\d+\s*$/mi )
		{
			$_	= $1;
			if ( /^(\d+)\/(\S+)$/i )
			{
				my $speed	= $1;
				my $duplex	= lc ( $2 );
				if ( $duplex eq 'half' || $duplex eq 'full' )
				{
					$interface->{interfaceEthernet}->{operationalDuplex}	= $duplex;
					$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
				}
				elsif ( $duplex eq 'auto' )
				{
					$interface->{interfaceEthernet}->{autoDuplex} = 'true';
				}
				$interface->{speed} = $speed * 1000 * 1000;
			}
		}
		$out->print_element( "interface", $interface );
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	my $vlansOpened = 0;
	my ($vlans)		= $in->{vlans} =~ /Ports(.+)/mis;
	$vlans			= trim ( $vlans );

	my $vlan;
	while ( $vlans =~ /^(\S+)?\s+(\S.+)$/mig )
	{
		if ( $1 )
		{
			if ( $vlan->{name} )
			{
				if ( !$vlansOpened )
				{
					$vlansOpened = 1;
					$out->open_element("vlans");
				}
				$out->print_element( "vlan", $vlan );
			}
			$vlan				= undef;
			$vlan->{name}		= $1;
			$vlan->{enabled}	= 'true';
		}
		if ( $vlan->{name} )
		{
			$_			= $2;
			last if ( /[:->]/ );
			my $ports	= $_;
			foreach ( split ( /\s+/, $ports ) )
			{
				push @{$vlan->{interfaceMember}}, $_;
			}
		}
	}
	if ( $vlan->{name} )
	{
		if ( !$vlansOpened )
		{
			$vlansOpened = 1;
			$out->open_element("vlans");
		}
		$out->print_element( "vlan", $vlan );
	}

	if ( $vlansOpened )
	{
		$out->close_element("vlans");
	}
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;

	while ( $in->{stp} =~ /\b(\S+)\s+(\d+|N\/A)\s+(\d+|N\/A)\s+(\d+|N\/A)\s+(\d+|N\/A)\s+(\d+|N\/A)/mig )
	{
		if ( uc ( $2 ) ne 'N/A' )
		{
			my $instance		=
			{
				forwardDelay	=> $6,
				helloTime		=> $4,
				holdTime		=> $5,
				maxAge			=> $3,
				priority		=> $2,
				vlan			=> $1,
			};
			if ( $in->{bridge} =~ /\b$1\s+\S+\s+([a-fA-F\d]{2}:[a-fA-F\d]{2}:[a-fA-F\d]{2}:)\s+\d+\s+\S+\s+\d+\S+\s+([a-fA-F\d]{2}:[a-fA-F\d]{2}:[a-fA-F\d]{2})/mi )
			{
				$instance->{systemMacAddress} = strip_mac ( $1 . $2 );
			}
			#designatedRootCost
			#designatedRootForwardDelay
			#designatedRootHelloTime
			#designatedRootMacAddress
			#designatedRootMaxAge
			#designatedRootPort
			#designatedRootPriority
			push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
		}
	}
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
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
