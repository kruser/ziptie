package ZipTie::Adapters::Cisco::SecurityAppliance::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_arp parse_cdp parse_telemetry_interfaces parse_mac_table parse_routing_neighbors parse_routing create_config parse_local_accounts parse_chassis parse_object_groups parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Class constants.
# The reasonable memory sizes in MBs: 2 to the n-th power.
our @VALID_MEMSIZES = map { 2**$_ } qw(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16);

# The string which collects the sizes from 4 (2**2) MBs to 65536 (2**16) MBs.
# Format the array into a space-padded string.
our $SIZEPATTERNS_STRING = " @VALID_MEMSIZES ";

# The number of KBs in 80 percent of 1 MB.
our $KBS_80PERCENTMB = int( my $volatile = 1024 * 0.8 );

sub parse_routing_neighbors
{
	my ( $in, $out ) = @_;
	my $opened = 0;

	while ( $in->{ospf} =~ /^\s*([\da-f.:]+)\s+\d+\s+\S+(?:\s+\S+)?\s+\S+\s+([\da-f.:]+)\s+(\S+)\s*$/gm )
	{
		$out->open_element('routingNeighbors') if (!$opened);
		$opened = 1;
		my $neighbor =
		{
			protocol => 'OSPF',	
			routerId => $1,	
			ipAddress => $2,	
			interface => $3,
		};
		$out->print_element('routingNeighbor', $neighbor);
	}
	my $route_neighbors;
	while ( $in->{routes} =~ /^(I|R|B|D|i)\*?\s+([\da-f:.]+)\s+(?:[\da-f:.]+)\s+\S+\s+via\s+([\da-f:.]+),\s+(\S+)/gm )
	{
		if ( $1 eq 'I' )
		{
			push @{$route_neighbors->{igrp}}, { protocol => 'IGRP', ipAddress => $2, routerId => $3, interface => $4 };
		}
		elsif ( $1 eq 'I' )
		{
			push @{$route_neighbors->{rip}}, { protocol => 'RIP', ipAddress => $2, routerId => $3, interface => $4 };
		}
		elsif ( $1 eq 'B' )
		{
			push @{$route_neighbors->{bgp}}, { protocol => 'BGP', ipAddress => $2, routerId => $3, interface => $4 };
		}
		elsif ( $1 eq 'D' )
		{
			push @{$route_neighbors->{eigrp}}, { protocol => 'EIGRP', ipAddress => $2, routerId => $3, interface => $4 };
		}
		elsif ( $1 eq 'i' )
		{
			push @{$route_neighbors->{isis}}, { protocol => 'ISIS', ipAddress => $2, routerId => $3, interface => $4 };
		}
	}
	while ( ( my $key, my $value ) = each( %{$route_neighbors} ) )
	{
		if ( ref( $route_neighbors->{$key} ) eq 'ARRAY' )
		{
			$out->open_element('routingNeighbors') if (!$opened);
			$opened = 1;
			foreach my $neighbor ( @{$route_neighbors->{$key}} )
			{
				$out->print_element( 'routingNeighbor', $neighbor );
			}
		}
	}

	$out->close_element('routingNeighbors') if ($opened);
}

sub parse_arp
{
	my ( $in, $out ) = @_;
	$out->open_element('arpTable');
	while ( $in->{arp} =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s*$/mg )
	{
		my $arp = {
			ipAddress  => $2,
			macAddress => strip_mac($3),
			interface  => $1,
		};
		$out->print_element( 'arpEntry', $arp );
	}
	$out->close_element('arpTable');
}

sub parse_cdp
{
	my ( $in, $out ) = @_;
	my $opened = 0;
	while ( $in->{ndp} =~ /^([A-F:\d]+)\s+\d+\s+([a-f\.\d]+)\s+\S+\s+(\S+)/mig )
	{
		$out->open_element('discoveryProtocolNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol       => 'NDP',
			ipAddress      => $1,
			macAddress     => strip_mac($2),
			localInterface => $3,
		};
		$out->print_element( 'discoveryProtocolNeighbor', $neighbor );
	}
	$out->close_element('discoveryProtocolNeighbors') if ($opened);
}

sub parse_telemetry_interfaces
{
	my ( $in, $out ) = @_;
	my $interfaces;

	while ( $in->{interfaces} =~ /(\S+)\s+"([^"]+)",\s+(is.+?)(?=^\S)/msg )
	{
		my $blob = $3;
		my $interface =
		{ 
			name => $2,
			type => get_interface_type($1),
			inputBytes => 0,
		};
		if ( $blob =~ /line protocol is (down|up)/mi )
		{
			$interface->{operStatus}= ucfirst($1);
		}
		if ( $blob =~ /(\d+) packets input,\s+(\d+)\s*bytes/mi )
		{
			$interface->{inputBytes}= $1;
		}
		while ( $blob =~ /IP\s+address\s+([\d.:a-fA-F]+),\s+subnet\s+mask\s+([\d.:a-fA-F]+)/mgi )
		{
			my $ipEntry =
			{
				ipAddress => $1,	
				mask => mask_to_bits ( $2 ),
			};
			push (@{$interface->{ipEntry}}, $ipEntry);
		}
		push( @{ $interfaces->{interface} }, $interface );
	}
	$out->print_element( 'interfaces', $interfaces );
	return $interfaces;
}

sub parse_mac_table
{
	my ( $in, $out ) = @_;

}
##################################################

sub parse_chassis
{
	my ( $in, $out, $connPtr, $connType ) = @_;
	my $serialNumber;
	my $modelNumber;
	my $hwNumber;
	my $processorBoard;
	my $cpuid         = 0;
	my @memories      = ();
	my @deviceStorage = ();

	foreach my $line ( split( /\n/, $in->{version} ) )
	{
		if ( $line =~ /^Hardware:\s+([^\s,]+)/i )
		{
			$hwNumber = $1;
		}
		if ( $line =~ /^Serial\s+Number:\s+(\S+)/i )
		{
			$serialNumber = $1;
		}
		if ( $line =~ /\bCPU\s+(\S{1}.+)$/i )
		{
			$processorBoard = $1;
		}

		#if ( $line =~ /^Hardware:\s+([^\,\s]+)/i )
		#{
		#	$modelNumber = $1;
		#}
		if ( $line =~ /\b(\d+)\s+(\S+)\s+RAM/i )
		{
			my $ramsize    = $1;
			my $sizeprefix = $2;
			if ( $sizeprefix =~ /MB/i )
			{
				$ramsize = $ramsize * 1024 * 1024;
			}
			elsif ( $sizeprefix =~ /KB/i )
			{
				$ramsize = $ramsize * 1024;
			}
			push @memories, { kind => 'RAM', size => $ramsize };
		}
		if ( $line =~ /^Flash([^\,]+),\s+(\d+)(\S+)/ )
		{
			my $flashsize  = $2;
			my $sizeprefix = $3;
			if ( $sizeprefix =~ /MB/i )
			{
				$flashsize = $flashsize * 1024 * 1024;
			}
			elsif ( $sizeprefix =~ /KB/i )
			{
				$flashsize = $flashsize * 1024;
			}
			push @memories, { kind => 'Flash', size => $flashsize };
			push @deviceStorage, { name => 'flash', storageType => 'flash', size => $flashsize };
		}
		if ( $line =~ /^BIOS\s+Flash([^\,]+),\s+(\d+)(\S+)/ )
		{
			my $configmemsize = $2;
			my $sizeprefix    = $3;
			if ( $sizeprefix =~ /MB/i )
			{
				$configmemsize = $configmemsize * 1024 * 1024;
			}
			elsif ( $sizeprefix =~ /KB/i )
			{
				$configmemsize = $configmemsize * 1024;
			}
			push @memories, { kind => 'ConfigurationMemory', size => $configmemsize };
		}
	}

	if ( $in->{version} =~ /(?<!:\/)\b(PIX[^\s,]+)/mi )
	{
		$modelNumber = $1;
	}
	elsif ( $in->{version} =~ /(?<!:\/)\b(ASA\d+)/mi )
	{
		$modelNumber = $1;
	}
	elsif ( $in->{version} =~ /(?<!:\/)\b(WS[^\s,]+)/mi )
	{
		$modelNumber = $1;
	}
	elsif ( $in->{version} =~ /(FWSM)/ )
	{
		$modelNumber = $1;
	}
	else
	{
		$modelNumber = 'PIX-520';
	}

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $hwNumber     if ( defined $hwNumber );
	$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'}    = $serialNumber if ( defined $serialNumber );
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}            = "Cisco";
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'}     = $modelNumber  if ( defined $modelNumber );

	$out->print_element( "core:asset", $chassisAsset );

	my $cpu;
	$cpu->{cpuType} = $processorBoard if $cpuid != -1 and $processorBoard;
	$out->print_element( "cpu", $cpu );

	foreach my $ds (@deviceStorage)
	{
		$out->print_element( "deviceStorage", $ds );
	}

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;
	my ($hostname) = $in->{running_config} =~ /^hostname\s+(\S+)/im;
	$out->print_element( 'core:systemName', $hostname );

	$out->open_element('core:osInfo');
	if ( $in->{version} =~ /^System image file is "([^"]+)/m )
	{
		$out->print_element( 'core:fileName', $1 );
	}

	# Try to grab OS name, OS type and Version using 1 pattern
	$out->print_element( 'core:make', 'Cisco' );
	if ( $in->{version} =~ /^Cisco (\S+)\s.*(?=Version)Version\s+(\S+)/mi )
	{
		$out->print_element( 'core:name',    $1 );
		$out->print_element( 'core:version', $2 );
	}
	elsif ( $in->{version} =~ /Adaptive Security Appliance Software Version\s+(\d+\.\d+\(\d+\))/mi )
	{
		$out->print_element( 'core:name',    "ASDM" );
		$out->print_element( 'core:version', $1 );
	}
	else
	{
		my $osType = "";
		if ( $in->{version} =~ /^(?:Cisco )?(\S+)\s+(\S+)/mi )
		{
			$out->print_element( 'core:name', $1 );
			$osType = $1;
		}
		if ( $in->{version} =~ /^(?:Cisco )?\S+\s+[\S]+\s+Version (\S[^\s,]+)/mi )
		{
			$out->print_element( 'core:version', $1 );
		}
		elsif ( $in->{version} =~ /^Software Version (\S+)/mi )
		{
			$_ = $1;
			s/^[Vv]//;
			$out->print_element( 'core:version', $_ );
		}
		elsif ( $in->{version} =~ /^Version\s+(\S+)/mi )
		{
			$_ = $1;
			s/^[Vv]//;
			$out->print_element( 'core:version', $_ );
		}
	}
	$out->print_element( 'core:osType', 'PIX' );
	$out->close_element('core:osInfo');

	if (   ( $in->{version} =~ /ROM:\s+System\s+Bootstrap[,]\s+Version\s+([^\s,]+)/i )
		or ( $in->{version} =~ /ROM:\s+Bootstrap\s+program\s+is\s+(.*)/i )
		or ( $in->{version} =~ /BOOTLDR:\s+\S+\s+Boot\s+Loader.*Version\s+([^\s,]+)/i )
		or ( $in->{version} =~ /^ROM:\s+TinyROM\s+version\s+([^\s]+)/mi )
		or ( $in->{version} =~ /^ROM:\s+([^\s]+)/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	if ( $in->{version} =~ /\bWS-C\d{4}|catalyst/i )
	{
		$out->print_element( 'core:deviceType', 'Switch' );
	}
	else
	{
		$out->print_element( 'core:deviceType', 'Firewall' );
	}

	my ($contact) = $in->{running_config} =~ /^snmp-server contact (.+)/m;
	$out->print_element( 'core:contact', $contact );

	# System restarted at 18:00:01 CST Sun Feb 28 1993
	if ( $in->{version} =~ /^System restarted (?:by \S+\s)?at\s+(\d{1,2}:\d{1,2}:\d{1,2})\s+(\S+)\s+\S+\s+(\S+)\s+(\d{1,2})\s+(\d{4})/mi )
	{
		my $year     = $5;
		my $month    = $3;
		my $day      = $4;
		my $time     = $1;
		my $timezone = $2;

		my ( $hour, $min, $sec ) = $time =~ /(\d+):(\d+):(\d+)/;

		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
	}
	elsif (( $in->{version} =~ /uptime is\s+(.+)/i )
		or ( $in->{version} =~ /\bup\s+([\w\s]+)$/mi ) )
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
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	while ( $in->{running_config} =~
		/^route\s+(\S+)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?:\s+(\d+))?/mig )
	{
		my $route = {
			interface          => $1,
			destinationAddress => $2,
			destinationMask    => mask_to_bits ( $3 ),
			gatewayAddress     => $4,
		};
		
		$route->{routeMetric} = $5 if ($5);

		if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0.0.0.0' ) )
		{
			$route->{defaultGateway} = 'true';
		}
		else
		{
			$route->{defaultGateway} = 'false';
		}
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_network_object_groups
{
	my ( $in, $out ) = @_;

	my $groupId;
	my $cipm = get_crep('cipm');
	my $nested_groups;
	while ( $in->{network_object_group} =~ /group network (\S+)\s(.+?)(?=^object-)/migs )
	{
		$groupId	= $1;
		$_			= $2;
		if ( /network-object/mi )
		{
			$out->open_element("networkGroup");
			if ( /description: (.+)$/mi )
			{
				$out->print_element( "description", $1 );
			}
			$out->print_element( "id", $groupId );
			while ( /network-object(?: host)? ($cipm)( $cipm)?\s*$/mig )
			{
				$out->print_element( "host", $1 ) if ( !$2 );
				if ( $2 )
				{
					my $sn =
					{
						address	=> $1,
						mask	=> mask_to_bits(trim($2)),
					};
					$out->print_element( "subnet", $sn );
				}
			}
			$out->close_element("networkGroup");
		}
		elsif ( /group-object (\S+)/i )
		{
			while ( /group-object (\S+)\s+$/mig )
			{
				push @{$nested_groups->{$groupId}}, $1;
			}
		}
	}

	return $nested_groups;
}

sub parse_service_object_groups
{
	my ( $in, $out ) = @_;

	my $groupId;
	my $cipm = get_crep('cipm');
	my $groupOpened;
	my $protocol;
	my $nested_groups;
	my $idPrinted;
	while ( $in->{service_object_group} =~ /group service (\S+) (\S+)\s(.+?)(?=^object-)/migs )
	{
		$groupId	= $1;
		$protocol	= $2;
		$_			= $3;
		if ( /port-object/mi )
		{
			$out->open_element("serviceGroup");
			if ( /description: (.+)$/mi )
			{
				$out->print_element( "description", $1 );
			}
			$out->print_element( "id", $groupId );
			while ( /port-object (\S+) (\S+)( \S+)?\s*$/mig )
			{
				if ( $1 eq 'range' )
				{
					my $portRange;
					$portRange->{portStart}	= _int_port( $2 );
					$portRange->{portEnd}	= _int_port( trim ($3) );
					$out->print_element( "portRange", $portRange);
				}
				else
				{
					my $portExpression;
					$portExpression->{operator}	= $1;
					$portExpression->{port}		= _int_port( $2 );
					$out->print_element( "portExpression", $portExpression );
				}
			}
			$out->close_element("serviceGroup");
		}
		elsif ( /group-object (\S+)/i )
		{
			while ( /group-object (\S+)\s+$/mig )
			{
				push @{$nested_groups->{$groupId}}, $1;
			}
		}
	}

	return $nested_groups;
}

sub parse_protocol_object_groups
{
	my ( $in, $out ) = @_;

	my $groupId;
	my $nested_groups;
	while ( $in->{protocol_object_group} =~ /group protocol (\S+)\s(.+?)(?=^object-)/migs )
	{
		$groupId	= $1;
		$_			= $2;
		if ( /protocol-object/mi )
		{
			$out->open_element("protocolGroup");
			if ( /description: (.+)$/mi )
			{
				$out->print_element( "description", $1 );
			}
			$out->print_element( "id", $groupId );
			while ( /protocol-object (\S+)\s*$/mig )
			{
				$out->print_element( "protocol", uc( $1 ) );
			}
			$out->close_element("protocolGroup");
		}
		elsif ( /group-object (\S+)\s+$/i )
		{
			while ( /group-object (\S+)\s+$/mig )
			{
				push @{$nested_groups->{$groupId}}, $1;
			}
		}
	}

	return $nested_groups;
}

sub parse_object_groups
{
	my ( $in, $out ) = @_;

	parse_object_groups_from_rc($in, $out);
=head
	$out->open_element("objectGroups");

	my $nested_groups1;
	my $nested_groups2;
	my $nested_groups3;
	$nested_groups1 = parse_network_object_groups($in, $out);
	$nested_groups3 = parse_protocol_object_groups($in, $out);
	$nested_groups2 = parse_service_object_groups($in, $out);

	$out->close_element("objectGroups");
=cut
}

sub parse_object_groups_from_rc
{
	my ( $in, $out ) = @_;

	my ($og_blob)		= $in->{running_config} =~ /^(object-group.+)access-list/mis;
	my $cipm			= get_crep('cipm');
	my $group_opened	= 0;
	my $og_type			= "";
	my $og_name			= "";
	my $og_proto		= "";

	my $network_groups;
	my $protocol_groups;
	my $service_groups;
	my $icmp_groups;
	my $group_params;

	if ( $og_blob )
	{
		while ( $og_blob =~ /^(.+)$/mig )
		{
			$_ = $1;
			if ( /^object-group (\S+) (\S+)(?: (\S+))?\s*$/i )
			{
				if ( lc ($og_type) eq 'network' )
				{
					push @{$network_groups}, $group_params;
				}
				elsif ( lc ($og_type) eq 'service' )
				{
					push @{$service_groups}, $group_params;
				}
				elsif ( lc ($og_type) eq 'protocol' )
				{
					push @{$protocol_groups}, $group_params;
				}
				elsif ( lc ($og_type) eq 'icmp-type' )
				{
					push @{$icmp_groups}, $group_params;
				}
				$group_params	= undef;
				$og_type		= $1;
				$og_name		= $2;
				$og_proto		= $3 if ( $3 );
				$group_params->{id} = $og_name;
				if ( lc ($og_type) eq 'network' )
				{
					$group_opened = 1;
				}
				elsif ( lc ($og_type) eq 'service' )
				{
					$group_opened = 1;
				}
				elsif ( lc ($og_type) eq 'protocol' )
				{
					$group_opened = 1;
				}
				elsif ( lc ($og_type) eq 'icmp-type' )
				{
					$group_opened = 1;
				}
				else
				{
					$group_opened = 0;
				}
			}
			else
			{
				if ( /^\s*description (\S.+)$/i && $group_opened )
				{
					$group_params->{description} = $1;
				}
				elsif ( /^\s*group-object (\S+)\s*$/i && $group_opened )
				{
					push @{$group_params->{objectGroupReference}}, $1;
				}
				elsif ( /^\s*network-object(?: host)? ($cipm)( $cipm)?\s*$/i && $group_opened )
				{
					push @{$group_params->{host}}, $1 if ( !$2 );
					if ( $2 )
					{
						my $sn =
						{
							address	=> $1,
							mask	=> mask_to_bits(trim($2)),
						};
						push @{$group_params->{subnet}}, $sn;
					}
				}
				elsif ( /^\s*protocol-object (\S+)\s*$/i && $group_opened )
				{
					push @{$group_params->{protocol}}, lc( $1 );
				}
				elsif ( /^\s*port-object (\S+) (\S+)( \S+)?\s*$/i && $group_opened )
				{
					if ( $1 eq 'range' )
					{
						my $portRange;
						$portRange->{portStart}	= _int_port( $2 );
						$portRange->{portEnd}	= _int_port( trim ($3) );
						push @{$group_params->{portRange}}, $portRange;
					}
					else
					{
						my $portExpression;
						$portExpression->{operator}	= $1;
						$portExpression->{port}		= _int_port( $2 );
						push @{$group_params->{portExpression}}, $portExpression;
					}
				}
				elsif ( /^\s*icmp-object (\S+)\s*$/i && $group_opened )
				{
					push @{$group_params->{icmpObject}}, $1;
				}
			}
		}
	}
	if ( lc ($og_type) eq 'network' )
	{
		push @{$network_groups}, $group_params;
	}
	elsif ( lc ($og_type) eq 'service' )
	{
		push @{$service_groups}, $group_params;
	}
	elsif ( lc ($og_type) eq 'protocol' )
	{
		push @{$protocol_groups}, $group_params;
	}
	elsif ( lc ($og_type) eq 'icmp-type' )
	{
		push @{$icmp_groups}, $group_params;
	}
	
	if ( $network_groups || $protocol_groups || $service_groups )
	{
		$out->open_element("objectGroups");

		if ( $icmp_groups )
		{
			$group_params = undef;
			foreach $group_params ( @{$icmp_groups} )
			{
				$out->open_element("icmpGroup");
				$out->print_element( "description", $group_params->{description} ) if ($group_params->{description});
				$out->print_element( "id", $group_params->{id} );
				if ( $group_params->{icmpObject} )
				{
					foreach my $icmpObject ( @{$group_params->{icmpObject}} )
					{
						$out->print_element( "icmpObject", $icmpObject ) ;
					}
				}
				if ( $group_params->{objectGroupReference} )
				{
					foreach my $objectGroupReference ( @{$group_params->{objectGroupReference}} )
					{
						$out->print_element( "objectGroupReference", $objectGroupReference ) ;
					}
				}
				$out->close_element("icmpGroup");
			}
		}
		if ( $network_groups )
		{
			$group_params = undef;
			foreach $group_params ( @{$network_groups} )
			{
				$out->open_element("networkGroup");
				$out->print_element( "description", $group_params->{description} ) if ($group_params->{description});
				$out->print_element( "id", $group_params->{id} );
				if ( $group_params->{objectGroupReference} )
				{
					foreach my $objectGroupReference ( @{$group_params->{objectGroupReference}} )
					{
						$out->print_element( "objectGroupReference", $objectGroupReference ) ;
					}
				}
				if ( $group_params->{host} )
				{
					foreach my $host ( @{$group_params->{host}} )
					{
						$out->print_element( "host", $host ) ;
					}
				}
				if ( $group_params->{subnet} )
				{
					foreach my $subnet ( @{$group_params->{subnet}} )
					{
						$out->print_element( "subnet", $subnet ) ;
					}
				}
				$out->close_element("networkGroup");
			}
		}
		if ( $protocol_groups )
		{
			$group_params = undef;
			foreach $group_params ( @{$protocol_groups} )
			{
				$out->open_element("protocolGroup");
				$out->print_element( "description", $group_params->{description} ) if ($group_params->{description});
				$out->print_element( "id", $group_params->{id} );
				if ( $group_params->{objectGroupReference} )
				{
					foreach my $objectGroupReference ( @{$group_params->{objectGroupReference}} )
					{
						$out->print_element( "objectGroupReference", $objectGroupReference ) ;
					}
				}
				if ( $group_params->{protocol} )
				{
					foreach my $protocol ( @{$group_params->{protocol}} )
					{
						$out->print_element( "protocol", $protocol ) ;
					}
				}
				$out->close_element("protocolGroup");
			}
		}
		if ( $service_groups )
		{
			$group_params = undef;
			foreach $group_params ( @{$service_groups} )
			{
				$out->open_element("serviceGroup");
				$out->print_element( "description", $group_params->{description} ) if ($group_params->{description});
				$out->print_element( "id", $group_params->{id} );
				if ( $group_params->{objectGroupReference} )
				{
					foreach my $objectGroupReference ( @{$group_params->{objectGroupReference}} )
					{
						$out->print_element( "objectGroupReference", $objectGroupReference ) ;
					}
				}
				if ( $group_params->{portExpression} )
				{
					foreach my $portExpression ( @{$group_params->{portExpression}} )
					{
						$out->print_element( "portExpression", $portExpression ) ;
					}
				}
				if ( $group_params->{portRange} )
				{
					foreach my $portRange ( @{$group_params->{portRange}} )
					{
						$out->print_element( "portRange", $portRange ) ;
					}
				}
				$out->close_element("serviceGroup");
			}
		}

		$out->close_element("objectGroups")
	}
}

sub parse_filters
{
	my ( $in, $out ) = @_;
	my $openedFilterLists;
	my $term_process_order = 1;
	my $name		= " ";
	my $old_name	= " ";

	my $time_range = parse_time_range( $in );
	while ( $in->{running_config} =~ /^access-list\s+(\S+)(?:\s+line\s+(\d+))?(?:\s+extended)?\s+(\S.+)$/mig )
	{
		if ( $name eq $1 )
		{
			$term_process_order ++;
		}
		else
		{
			$term_process_order = 1;
		}
		$name		= $1;
		my $line	= $2 if ( $2 );
		my $details	= trim ( $3 );
		my $thisterm;

		$_ = $details;
		if (																					# this regex parses the important part of the acl
			/
			^(permit|deny|no permit)															# grab the action
			\s+(\S+|object-group\s+\S+)															# grab the protocol
			\s+(any|host\s+\S+|object-group\s+\S+|[\d\.\/]+(?:\s+[\d\.]+)?)						# grab the source address
			(\s+(?:neq|eq|gt|lt)\s+\S+|\s+range\s+[^\s\-]+[-\s][^\s\-]+|\s+object-group\s+\S+)?	# grab the source service
			\s+(any|host\s+\S+|object-group\s+\S+|[\d\.\/]+(?:\s+[\d\.\/]+)?)					# grab the destination address
			(\s+(?:neq|eq|gt|lt)\s+\S+|\s+range\s+[^\s\-]+[-\s][^\s\-]+|\s+object-group\s+\S+)?	# grab the destination service
			/ix
			)
		{
			my $action		= $1;
			my $protocol	= $2;
			my $src_address = $3;
			my $src_service = $4 if ( $4 );
			my $dst_address = $5;
			my $dst_service	= $6 if ( $6 );

			$action = "deny" if ( $action eq 'no permit' );
			$thisterm->{"primaryAction"} = $action;

			if ( $protocol =~ /object-group\s+(\S+)/i )
			{
				$thisterm->{"protocolObjectGroupReference"} = $1;
			}
			else
			{
				$thisterm->{"protocol"} = $protocol;
			}

			print_filter_address ( trim ( $src_address ), \%{$thisterm->{"sourceIpAddr"}}, 4 );

			print_filter_service ( trim ( $src_service ), \%{$thisterm->{"sourceService"}} ) if ( $src_service );

			print_filter_address ( trim ( $dst_address ), \%{$thisterm->{"destinationIpAddr"}}, 4 );

			print_filter_service ( trim ( $dst_service ), \%{$thisterm->{"destinationService"}} ) if ( $dst_service );

			# look for the log instruction
			if ( /\slog(?:\s|$)/i )
			{
				$thisterm->{log} = "true";
			}
			else
			{
				$thisterm->{log} = "false";
			}

			# look for the time-range instruction
			if ( /\btime-range\s+(\S+)/i )
			{
				$thisterm->{timeAllowed} = $time_range->{$1};
			}

			# store process order ( line number )
			$thisterm->{processOrder} = $term_process_order;

			$out->open_element("filterLists") if ( !$openedFilterLists );
			$openedFilterLists	= 1;

			if ( $old_name ne $name && $old_name ne " ")
			{
				$out->print_element( "mode", 'stateful');
				$out->print_element( "name", $old_name );
				$out->close_element("filterList");
			}
			if ( $old_name ne $name)
			{
				$old_name = $name;
				$out->open_element("filterList");
			}
			$out->print_element( "filterEntry", $thisterm );
		}
	}
	if ( $old_name ne " ")
	{
		$out->print_element( "mode", 'stateful');
		$out->print_element( "name", $old_name );
		$out->close_element("filterList");
	}

	parse_ipv6_filters ( $in, $out, \$openedFilterLists, $time_range );

	$out->close_element("filterLists") if ( $openedFilterLists );
}

# convert shun to acl
sub convert_shun2acl
{
	my $shunTerms    = shift;
	my $aclShunTerms = "";

	while ( $shunTerms =~ /^Shun\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})([\s+\d\.]+)?$/mig )
	{
		my $srcIp       = $1;
		my $extShunTerm = $2;
		my $protocol    = "tcp";    # for now tcp is the default protocol
		if ( defined $extShunTerm )
		{
			if ( $extShunTerm =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)\s+(\S+)(\s+(\S+))?/ )
			{
				my $dstIp = $1;
				my $sport = $2;
				my $dport = $3;
				if ( defined $4 )
				{
					$protocol = $4;
					$protocol =~ s/ //;
				}
				if ( !defined $protocol )
				{
					$protocol = "tcp";
				}
				if ( $srcIp eq '0.0.0.0' && $dstIp eq '0.0.0.0' )
				{
					$aclShunTerms .= "access-list shuns deny $protocol any any";
				}
				elsif ( $srcIp eq '0.0.0.0' && $dstIp ne '0.0.0.0' )
				{
					$aclShunTerms .= "access-list shuns deny $protocol any host $dstIp";
				}
				elsif ( $srcIp ne '0.0.0.0' && $dstIp eq '0.0.0.0' )
				{
					$aclShunTerms .= "access-list shuns deny $protocol host $srcIp any";
				}
				elsif ( $srcIp ne '0.0.0.0' && $dstIp ne '0.0.0.0' )
				{
					$aclShunTerms .= "access-list shuns deny $protocol host $srcIp host $dstIp";
				}
				if ( $sport =~ /\d/ && $sport !~ /\s*0\s*/ )
				{
					$aclShunTerms .= " eq $sport\n";
				}
				else
				{
					$aclShunTerms .= "\n";
				}
			}
		}
		else
		{
			if ( $srcIp eq '0.0.0.0' )
			{
				$aclShunTerms .= "access-list shuns deny $protocol host any any\n";
			}
			else
			{
				$aclShunTerms .= "access-list shuns deny $protocol host $srcIp any\n";
			}
		}
	}

	return $aclShunTerms;
}

sub parse_ipv6_filters
{
	my ( $in, $out, $openedFilterLists, $time_range ) = @_;
	my $term_process_order = 1;
	my $name		= " ";
	my $old_name	= " ";

	while ( $in->{running_config} =~ /^ipv6\s+access-list\s+(\S+)(?:\s+line\s+(\d+))?\s+(\S.+)$/mig )
	{
		if ( $name eq $1 )
		{
			$term_process_order ++;
		}
		else
		{
			$term_process_order = 1;
		}
		$name		= $1;
		my $line	= $2 if ( $2 );
		my $details	= trim ( $3 );
		my $thisterm;

		$_ = $details;
		if (																					# this regex parses the important part of the acl
			/
			^(permit|deny|no permit)															# grab the action
			\s+(\S+|object-group\s+\S+)															# grab the protocol
			\s+(any|host\s+\S+|object-group\s+\S+|[\da-f\.\:\/]+(?:\s+[\da-f\.\:\/]+)?)			# grab the source address
			(\s+(?:neq|eq|gt|lt)\s+\S+|\s+range\s+[^\s\-]+[-\s][^\s\-]+|\s+object-group\s+\S+)?	# grab the source service
			\s+(any|host\s+\S+|object-group\s+\S+|[\da-f\.\:\/]+(?:\s+[\da-f\.\:\/]+)?)			# grab the destination address
			(\s+(?:neq|eq|gt|lt)\s+\S+|\s+range\s+[^\s\-]+[-\s][^\s\-]+|\s+object-group\s+\S+)?	# grab the destination service
			/ix
			)
		{
			my $action		= $1;
			my $protocol	= $2;
			my $src_address = $3;
			my $src_service = $4 if ( $4 );
			my $dst_address = $5;
			my $dst_service	= $6 if ( $6 );

			$action = "deny" if ( $action eq 'no permit' );
			$thisterm->{"primaryAction"} = $action;

			if ( $protocol =~ /object-group\s+(\S+)/i )
			{
				$thisterm->{"protocolObjectGroupReference"} = $1;
			}
			else
			{
				$thisterm->{"protocol"} = $protocol;
			}

			print_filter_address ( trim ( $src_address ), \%{$thisterm->{"sourceIpAddr"}} );

			print_filter_service ( trim ( $src_service ), \%{$thisterm->{"sourceService"}} ) if ( $src_service );

			print_filter_address ( trim ( $dst_address ), \%{$thisterm->{"destinationIpAddr"}} );

			print_filter_service ( trim ( $dst_service ), \%{$thisterm->{"destinationService"}} ) if ( $dst_service );

			# look for the log instruction
			if ( /\slog(?:\s|$)/i )
			{
				$thisterm->{log} = "true";
			}
			else
			{
				$thisterm->{log} = "false";
			}

			# look for the time-range instruction
			if ( /\btime-range\s+(\S+)/i )
			{
				$thisterm->{timeAllowed} = $time_range->{$1};
			}

			# store process order ( line number )
			$thisterm->{processOrder} = $term_process_order;

			$out->open_element("filterLists") if ( !$openedFilterLists );
			$openedFilterLists	= 1;

			if ( $old_name ne $name && $old_name ne " ")
			{
				$out->print_element( "mode", 'stateful');
				$out->print_element( "name", $old_name );
				$out->close_element("filterList");
			}
			if ( $old_name ne $name)
			{
				$old_name = $name;
				$out->open_element("filterList");
			}
			$out->print_element( "filterEntry", $thisterm );
		}
	}
	if ( $old_name ne " ")
	{
		$out->print_element( "mode", 'stateful');
		$out->print_element( "name", $old_name );
		$out->close_element("filterList");
	}
}

sub parse_time_range
{
	my ( $in ) = @_;

	my $months = 
	{
		JAN => '01',
		FEB => '02',
		MAR => '03',
		APR => '04',
		MAY => '05',
		JUN => '06',
		JUL => '07',
		AUG => '08',
		SEP => '09',
		OCT => '10',
		NOV => '12',
		DEC => '12',
	};
	my $time_range;
	while ( $in->{running_config} =~ /^time-range\s+(\S+)(.+?)(?:!|: end)/migs )
	{
		my $name	= $1;
		$_			= $2;
		if ( /absolute\s+start\s+(\d+:\d+)\s+(\d+)\s+(\S+)\s+(\d+)\s+end\s+(\d+:\d+)\s+(\d+)\s+(\S+)\s+(\d+)/mi )
		{
			$time_range->{$name}->{startTime}	= $1.':00';
			$time_range->{$name}->{startDate}	= $4.'-'.$months->{uc( substr ($3,0,4) )}.'-'.$2;
			$time_range->{$name}->{endTime}		= $5.':00';
			$time_range->{$name}->{endDate}		= $8.'-'.$months->{uc( substr ($7,0,4) )}.'-'.$6;
			$time_range->{$name}->{startTime}	= '0'.$time_range->{$name}->{startTime} if ( $time_range->{$name}->{startTime} =~ /^\d:/ );
			$time_range->{$name}->{endTime}		= '0'.$time_range->{$name}->{endTime} if ( $time_range->{$name}->{endTime} =~ /^\d:/ );
		}
		elsif ( /periodic\s+(\D+)(\d+:\d+)\s+to\s+(\d+:\d+)/mi )
		{
			my $days							= $1;
			$time_range->{$name}->{startTime}	= $2.':00';
			$time_range->{$name}->{endTime}		= $3.':00';
			$time_range->{$name}->{startTime}	= '0'.$time_range->{$name}->{startTime} if ( $time_range->{$name}->{startTime} =~ /^\d:/ );
			$time_range->{$name}->{endTime}		= '0'.$time_range->{$name}->{endTime} if ( $time_range->{$name}->{endTime} =~ /^\d:/ );
			$days =~ s{ (\w+) }{ ( lc ( $1 ) ne 'thursday' ? substr ( $1, 0, 3 ) : substr ( $1, 0, 4 ) ) }gex;
			push @{$time_range->{$name}->{days}}, split ( /\s+/, $days );
		}
	}

	return $time_range;
}

sub print_filter_address
{
	my ( $in, $out, $v ) = @_;

	$v ||= 6;

	my $any_network = $v == 6 ? { "address" => "::", "mask" => "0" } : { "address" => "0.0.0.0", "mask" => "0" };
	if ( $in =~ /^any$/i )
	{
		push @{ $out->{network} }, $any_network;
	}
	elsif ( $in =~ /^[\da-f\.\:\/]+$/i )
	{
		my ( $address, $mask ) = split ( /\//, $in );
		push @{ $out->{network} }, { "address" => $address, "mask" => ( $v == 6 ? $mask : mask_to_bits ( $mask ) ) };
	}
	elsif ( $in =~ /^([\da-f\.\:]+)\s+([\da-f\.\:]+)$/i )
	{
		push @{ $out->{network} }, { "address" => $1, "mask" => ( $v == 6 ? $2 : mask_to_bits ( $2 ) ) };
	}
	elsif ( $in =~ /^host\s+(\S+)$/i )
	{
		push @{ $out->{host} }, $1;
	}
	elsif ( $in =~ /^object-group\s+(\S+)$/i )
	{
		push @{ $out->{objectGroupReference} }, $1;
	}
}

sub print_filter_service
{
	my ( $in, $out ) = @_;

	if ( $in =~ /^(lt|gt|eq|neq)\s+(\S+)$/i )
	{
		push @{ $out->{portExpression} }, { "port" => _int_port( $2 ), "operator" => ( $1 ne 'neq' ? $1 : 'ne' ) };
	}
	elsif ( $in =~ /^range\s+([^\s\-]+)[-\s]([^\s\-]+)$/i )
	{
		push @{ $out->{portRange} }, { "portStart" => _int_port( $1 ), "portEnd"   => _int_port( $2 ) };
	}
	elsif ( $in =~ /^object-group\s+(\S+)$/i )
	{
		push @{ $out->{objectGroupReference} }, $1;
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( $in->{"running_config"} );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{"core:name"}      = "startup-config";
	$startup->{"core:textBlob"}  = encode_base64( $in->{"startup_config"} );
	$startup->{"core:mediaType"} = "text/plain";
	$startup->{"core:context"}   = "boot";
	
	if ($in->{version} =~ /(Adaptive\s+Security\s+Appliance|ASA)/)
	{
		$startup->{'core:promotable'} = 'true';
	}
	else
	{
		$startup->{'core:promotable'} = 'false';
	}

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

	if (   ( defined $in->{"na_running_config"} )
		|| ( defined $in->{"na_startup_config"} ) )
	{
		$repository->{'core:folder'}->{'core:name'} = 'system space';

		my $na_running;
		$na_running->{"core:name"}       = "running-config";
		$na_running->{"core:textBlob"}   = encode_base64( $in->{"na_running_config"} );
		$na_running->{"core:mediaType"}  = "text/plain";
		$na_running->{"core:context"}    = "active";
		$na_running->{'core:promotable'} = 'false';

		# push the configuration into the repository
		push( @{ $repository->{'core:folder'}->{'core:config'} }, $na_running );

		my $na_startup;
		$na_startup->{"core:name"}       = "startup-config";
		$na_startup->{"core:textBlob"}   = encode_base64( $in->{"na_startup_config"} );
		$na_startup->{"core:mediaType"}  = "text/plain";
		$na_startup->{"core:context"}    = "boot";
		$na_startup->{'core:promotable'} = 'true';

		# push the configuration into the repository
		push( @{ $repository->{'core:folder'}->{'core:config'} }, $na_startup );
	}

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub create_nadmin_config
{
	my ( $in, $out ) = @_;

	#$modelNumber
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_local_accounts
{

	# local accounts - local usernames
	my ( $in, $out ) = @_;
	my $c = $in->{running_config};
	$out->open_element("localAccounts");

	while ( $c =~ /^username\s+([^\s]+)\s+(.+)/mig )
	{
		my $account = { accountName => $1, };
		my $userconfig = $2;
		if ( $userconfig =~ /privilege\s+([^\s]+)/ )
		{
			$account->{accessLevel} = $1;
		}
		if ( $userconfig =~ /password\s+([^\s]+)\s+([^\s]+)/ )
		{
			$account->{password} = $2;
		}
		$out->print_element( "localAccount", $account );
	}

	# local accounts - enable and enable secret
	while ( $c =~ /^enable\s+([^\s]+)\s+(level\s)?(\d*)\s?([^\s]+)/mig )
	{
		my $enabletype = $1;
		my $username   = "enable";
		my $encryption = $3;
		if ( $encryption eq "" )
		{
			$encryption = "0";
		}

		if ( $enabletype eq "secret" ) { $username = "enablesecret"; }
		my $account = {
			accountName => $username,
			password    => $4,
			accessLevel => 15,
		};
		$out->print_element( "localAccount", $account );
	}
	$out->close_element("localAccounts");

}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $c = $in->{running_config};
	$out->open_element("snmp");

	while ( $c =~ /^(snmp-server\s+community\s+([^\s]+).*)$/mig )
	{
		my $line      = $1;
		my $community = {
			communityString => $2,
			accessType      => 'RO',
		};
		if ( $line =~ /\s+(RO|RW)/i )
		{
			$community->{accessType} = uc($1);
		}
		if ( $line =~ /\s+view\s+([^\s]+)/ )
		{
			$community->{mibView} = $1;
		}
		if ( $line =~ /\s+(RO|RW)\s+(\d+)/i )
		{
			$community->{filter} = $2;
		}
		$out->print_element( "community", $community );
	}

	if ( $c =~ /^snmp-server\s+contact\s+(.*[^\s])\s*$/mi )
	{
		$out->print_element( "sysContact", $1 );
	}
	if ( $c =~ /^snmp-server\s+location\s+(.*[^\s])\s*$/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}
	if ( $c =~ /^hostname\s+(\S+)/mi )
	{
		$out->print_element( "sysName", $1 );
	}
	if ( $c =~ /^snmp-server\s+system-shutdown\s*$/mi )
	{
		$out->print_element( "systemShutdownViaSNMP", "true" );
	}

	while ( $c =~ /^(snmp-server\s+host\s+\"?(\d+\.\d+\.\d+\.\d+)\"?.*$)/mig )
	{
		my $trapHost = { ipAddress => $2, };
		my $line     = $1;

		if ( $line =~ /\"?\d+\.\d+\.\d+\.\d+\"?\s+([^\s]+.*)$/ )
		{
			my $extraInformation = $1;
			my $communityString;

			if ( $extraInformation =~ /^trap\s+version\s+\S+\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^trap\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^inform\s+version\s+\S+\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^inform\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^(\S+)/ )
			{
				$communityString = $1;
			}

			if ($communityString)
			{
				$trapHost->{communityString} = $communityString;
			}
		}
		$out->print_element( "trapHosts", $trapHost );
	}
	if ( $c =~ /^snmp-server\s+trap-source\s+(.*[^\s])\s*$/mi )
	{
		$out->print_element( "trapSource", $1 );
	}
	if ( $c =~ /^snmp-server\s+trap-timeout\s+(\d+)/mi )
	{
		$out->print_element( "trapTimeout", $1 );
	}
	$out->close_element("snmp");
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");
	my $interface         = {};
	my $interfaceEthernet = ();

	while ( $in->{"interfaces"} =~ /^(.+)$/mg )
	{
		my $iline = $1;
		if ( $iline =~ /^interface\s+([\S]+)(?:\s+\"?([^\"]*)\"?)?(\s+|\W+)/i )
		{
			
			if ( defined $interface->{name} )
			{
				if ( defined $interfaceEthernet->{macAddress} )
				{
					$interface->{interfaceEthernet}->{macAddress} = $interfaceEthernet->{macAddress};
				}
				if ( defined $interfaceEthernet->{operationalDuplex} )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = $interfaceEthernet->{operationalDuplex};
					$interface->{interfaceEthernet}->{autoDuplex}        = $interfaceEthernet->{autoDuplex};
				}
				if ( defined $interfaceEthernet->{autoSpeed} )
				{
					$interface->{interfaceEthernet}->{autoSpeed} = $interfaceEthernet->{autoSpeed};
				}
				$out->print_element( "interface", $interface );
				$interface         = {};
				$interfaceEthernet = {};
			}
			if ( $2 )
			{
				$interface->{name} = $2;
			}
			else
			{
				$interface->{name} = $1;
			}
			$interface->{physical}      = _is_physical($1);
			$interface->{interfaceType} = get_interface_type($1);
			$interface->{description}   = $3;
		}
		if ( defined $interface->{name} )
		{
			if ( $iline =~ /\bis(\s+\S+)?\s+(up|down)/i )
			{
				$interface->{adminStatus} = $2;
			}
			if ( $iline =~ /\bIP\s+address\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*\,\s+subnet\s+mask\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(\W+|$)/i )
			{
				my $order           = 1;
				my $ipConfiguration = {
					ipAddress  => $1,
					mask       => mask_to_bits($2),
					precedence => $order,
				};
				$order++;
				push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
			}
			if ( $iline =~ /\bMTU\s+(\d+)(\s+bytes)?(\W+|$)/i )
			{
				$interface->{mtu} = $1;
			}
			if ( $iline =~ /\bBW\s+(\d+)\s+(\S+)(\s+(half|full|auto)\s+duplex)?(\W+|$)/i )
			{
				my $speed = $1;
				my $units = $2;
				$interfaceEthernet->{operationalDuplex} = lc($4) if ( defined $4 );
				if ( lc($1) eq 'auto' )
				{
					$interfaceEthernet->{autoDuplex} = 'true';
				}
				else
				{
					$interfaceEthernet->{autoDuplex} = 'false';
				}

				if ( $units =~ /Mb/i ) { $speed = $speed * 1000 * 1000; }
				if ( $units =~ /Kb/i ) { $speed = $speed * 1000; }
				$interface->{speed} = $speed;
			}
			if ( $iline =~ /\b(Auto-Duplex)?\((Auto|Half|Full)-duplex\)/i
				&& !defined $interfaceEthernet->{operationalDuplex} )
			{
				$interfaceEthernet->{operationalDuplex} = lc($2) if ( defined $2 );
				if ( defined $1 && lc($1) eq 'auto-duplex' )
				{
					$interfaceEthernet->{autoDuplex} = 'true';
				}
				else
				{
					$interfaceEthernet->{autoDuplex} = 'false';
				}
			}
			if ( $iline =~ /\bAuto-Speed/i )
			{
				$interfaceEthernet->{autoSpeed} = 'true';
			}
			if ( $iline =~ /\bHardware\s+is(.+)$/i )
			{
				my $hwtext = $1;
				if ( $hwtext =~ /\baddress\s+is\s+([a-f0-9]{4})\.([a-f0-9]{4})\.([a-f0-9]{4})/i )
				{
					my $macaddress = uc( $1 . $2 . $3 );
					$interfaceEthernet->{macAddress} = $macaddress;
				}
			}
			if ( $iline =~ /\bMAC\s+address\s+([a-f0-9]{4})\.([a-f0-9]{4})\.([a-f0-9]{4})/i )
			{
				my $macaddress = uc( $1 . $2 . $3 );
				$interfaceEthernet->{macAddress} = $macaddress;
			}
			if ( $iline =~ /\bInterface number is (\d+)/i )
			{
				$interface->{ifIndex} = $1;
			}
		}
	}
	if ( defined $interface->{name} )
	{
		if ( defined $interfaceEthernet->{macAddress} )
		{
			$interface->{interfaceEthernet}->{macAddress} = $interfaceEthernet->{macAddress};
		}
		if ( defined $interfaceEthernet->{operationalDuplex} )
		{
			$interface->{interfaceEthernet}->{operationalDuplex} = $interfaceEthernet->{operationalDuplex};
		}
		$out->print_element( "interface", $interface );
		$interface         = {};
		$interfaceEthernet = {};
	}
	$out->close_element("interfaces");
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

sub parse_vlans
{

	# "show vlan" output parsing into the ZED Vlan model
	my ( $in, $out ) = @_;

}

sub parse_stp
{

	# parses Spanning Tree information
	my ( $in, $out ) = @_;
}

# checks to see if the incoming port is an integer.  If not
# it will do a lookup of the service name to convert it to an integer
sub _int_port
{
	my ($port) = @_;
	if ( $port =~ /^\d+$/ )
	{
		return $port;
	}
	else
	{
		return get_port_number($port);
	}
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Cisco::SecurityAppliance::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Cisco::SecurityAppliance::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
	parse_filters( $cliResponses, $xmlPrinter);	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
device responses and print out ZipTie model elements.

=head2 Methods

=over 12

=item C<create_config( $in, $out )>

Uses the device configs to put together a ZipTie configurationRepository element.

=item C<parse_local_accounts( $in, $out )>

Parse the local accounts.

=item C<parse_chassis( $in, $out )>

Parse out the chassis level elements.

=item C<parse_filters( $in, $out )>

Parse out firewall rules.

=item C<parse_routing( $in, $out )>

Parse out BGP and OSPF configuration

=item C<parse_snmp( $in, $out )>

Parse out the SNMP elements.

=item C<parse_system( $in, $out )>

Parses out some top level core attributes of the ZipTie model ZiptieElementDocument

=item C<parse_vlan( $in, $out )>

Parses out the VLAN elements.

=item C<parse_stp( $in, $out )>

Parses out the spannint tree elements.

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

  Contributor(s): rkruse
  Date: Apr 23, 2007

=cut
