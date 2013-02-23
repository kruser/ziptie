package ZipTie::Adapters::Extreme::XOS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac getUnitFreeNumber get_crep parseCIDR mask_to_bits);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{version} =~ /\b(?:Switch|Chassis)\s+:\s+\S+\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Extreme";
	if ( $in->{version} =~ /\bRev\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	if ( $in->{platform} =~ /\bCPU Core:\s+(\S+)(.+)$/mi )
	{
		my $cpu;
		$cpu->{"core:description"}	= $1.$2;
		$cpu->{cpuType}				= $1;
		$out->print_element( "cpu", $cpu );
	}

	#if ( $in->{platform} =~ /\bCPU Memory Size:\s+(\d+)\s+(\S+)/mi )
	#{
	#	$out->print_element( "memory", {kind => 'ConfigurationMemory', size => getUnitFreeNumber($1, $2, 'byte')} );
	#}
	if ( $in->{memory} =~ /\bTotal DRAM \((\S+)\):\s+(\d+)/mi )
	{
		$out->print_element( "memory", {kind => 'RAM', size => getUnitFreeNumber($2, $1, 'byte')} );
	}

	_parse_power_supply( $in, $out );

	$out->close_element("chassis");
}

sub _parse_cards
{
	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	if ( $in->{slots} !~ /Invalid input detected/mi )
	{
		while ( $in->{slots} =~ /\b(\S+) information:(.+?)^\s+^/migs )
		{
			my $slotName	= $1;
			my $slotBlob	= $2;
			next if ( $slotBlob =~ /State:\s+Empty/mi); # skip empty slots

			my $no;
			my $portCount;
			if ( $slotName =~ /Slot-(\d+)/i )
			{
				$no = $1;
			}
			if ( $slotBlob =~ /Ports available:\s+(\d+)/mi )
			{
				$portCount = $1;
			}
			my $card;
			$card->{slotNumber}			= $no if ( $no );
			$card->{portCount}			= $portCount if ( $portCount );
			$card->{"core:description"}	= trim ( $1 ) if ( $slotBlob =~ /Hw Module Type:\s+(\S.+)$/mi );

			$card->{"core:asset"}->{"core:assetType"}							= "Card";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}			= 'Extreme';
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}	= trim ( $1 ) if ( $slotBlob =~ /Serial number:\s+(\S.+)$/mi );

			$card->{softwareVersion} = $1 if ( $slotBlob =~ /SW Version:\s+(\S+)/mi );

			$out->print_element( "card", $card );
		}
	}
}

sub _parse_power_supply
{
	my ( $in, $out ) = @_;

	my $foundPowerSupply = 0;
	my $power_supply;
	while ( $in->{power} =~ /^(.+)$/mig )
	{
		$_ = $1;
		if ( /^PowerSupply (\d+) information/i )
		{
			if ( $power_supply->{number} )
			{
				$out->print_element( "powersupply", $power_supply );
			}
			$power_supply			= undef;
			$power_supply->{number}	= $1;
		}
		elsif ( /^\s*State:\s+(\S.+)$/i && $power_supply->{number} )
		{
			$power_supply->{status} = trim($1);
		}
		elsif ( /^\s*PartInfo:\s+(\S.+)$/i && $power_supply->{number} )
		{
			$power_supply->{'core:description'} = trim($1);
		}
	}
	if ( $power_supply->{number} )
	{
		$out->print_element( "powersupply", $power_supply );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{switch} =~ /^SysName:\s+(\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	if ( $in->{switch} =~ /^Config Booted:\s+(\S+)/mi )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Extreme' );
	if ( $in->{version} =~ /^Image\s+:\s+(\S.+)(?=\s+version)/mi )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{switch} =~ /^Primary ver:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'XOS' );
	$out->close_element('core:osInfo');

	if ( ( $in->{version} =~ /^BootROM\s+:\s+(\S+)/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	if ( $in->{configuration} =~ /^create virtual-router \S+/mi )
	{
		$out->print_element( 'core:deviceType', 'Router' );
	}
	else
	{
		$out->print_element( 'core:deviceType', 'Switch' );
	}

	my ($contact) = $in->{switch} =~ /^SysContact:\s+([^\s\,]+)/mi;
	$out->print_element( 'core:contact', $contact );

	# Boot Time:        Tue Jan 15 00:28:38 2008
	if ( $in->{switch} =~ /^Boot Time:\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+:\d+:\d+)\s+(\d+)/mi )
	{
		my $year     = $5;
		my $month    = $2;
		my $day      = $3;
		my $wday     = $1;
		my $time     = $4;
		my $timezone = 'CST';

		my ( $hour, $min, $sec ) = $time =~ /(\d+):(\d+):(\d+)/;
		
		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;
	my $filename;

	if ( $in->{switch} =~ /^Config Booted:\s+(\S+)/mi )
	{
		$filename = $1;
	}

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	# build the simple text configuration
	my $config;
	$config->{'core:name'}       = $filename;
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

	my $ospf;

	$_ = get_crep('cipm');
	if ( $in->{ospf} =~ /^RouterId\s+:\s+($_)/mi )
	{
		$ospf->{routerId} = $1;
	}

	while ( $in->{ospf_area} =~ /^(\S+)\s+(\S+)\s+(\S+)\s+\S+\s+\d+\s+\d+\s+\d+\s+\d+\s+\S+\s*$/mig )
	{
		my $area;
		$area->{areaId}	= $1;
		$_				= uc ( $2 );
		my $summ		= $3;
		if ( /NORM/i )
		{
			$area->{areaType} = 'normal';
		}
		elsif ( /(?:BACK|BONE)/i )
		{
			$area->{areaType} = 'backbone';
		}
		elsif ( /TNSSA/i )
		{
			$area->{areaType} = 'TNSSA';
		}
		elsif ( /NSSA/i )
		{
			$area->{areaType} = 'NSSA';
		}
		elsif ( /TSA/i )
		{
			$area->{areaType} = 'TSA';
		}
		elsif ( /SA/i )
		{
			$area->{areaType} = 'SA';
		}
		$area->{summarization} = ( $summ !~ /^-+$/ ) ? 'true' : 'false';
		push @{$ospf->{area}}, $area;
	}

	$_ = get_crep('cipm');
	while ( $in->{ospf_interfaces} =~ /^(\S+)\s+$_\s.+$/mig )
	{
		push @{$ospf->{enabledInterface}}, $1;
	}

	my ( $redist ) = $in->{ospf} =~ /Redistribute:(.+)/mis;
	while ( $redist =~ /^(\S+)\s+\S+\s+\S+\s+\d+\s+\d+\s+\d+\s*$/mig )
	{
		$_ = get_redist_protocol($1);
		if ( $_ )
		{
			push @{$ospf->{redistribution}}, { protocol => $_ };
		}
	}

	my $bgp;

	$_ = get_crep('cipm');
	if ( $in->{bgp} =~ /^RouterId\s+:\s+($_)/mi )
	{
		$bgp->{routerId} = $1;
	}

	if ( $in->{bgp} =~ /^As\s+:\s+(\d+)/mi )
	{
		$bgp->{autoSummarization} = trim($1) eq '0' ? 'false' : 'true';
	}

	( $redist ) = $in->{bgp} =~ /Redistribute:(.+)/mis;
	while ( $redist =~ /^(\S+)\s+\S+\s+\S+\s+\d+\s+\S+\s*$/mig )
	{
		
		$_ = get_redist_protocol($1);
		if ( $_ )
		{
			push @{$bgp->{redistribution}}, { targetProtocol => $_ };
		}
	}

	if ( $ospf || $bgp )
	{
		$out->open_element("routing");
		$out->print_element( "ospf", $ospf ) if ( $ospf );
		$out->print_element( "ospf", $bgp ) if ( $bgp );
		$out->close_element("routing");
	}
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;

	my $accountsOpened;
	while ( ( $in->{configuration} =~ /^(?:create|configure) account(\s+\S+)? (\S+) encrypted (\S+)/mig ) )
	{
		my $username	= $2;
		my $password	= $3;
		my $groupname	= trim ( $1 );
		if ( !$accountsOpened )
		{
			$out->open_element("localAccounts");
			$accountsOpened = 1;
		}
		if ( $groupname )
		{
			my $account =
			{
				accountName => $username,
				accessGroup => $groupname,
				password    => $password
			};
			$out->print_element( "localAccount", $account );
		}
		else
		{
			my $account =
			{
				accountName => $username,
				password    => $password
			};
			$out->print_element( "localAccount", $account );
		}
	}

	if ( $accountsOpened )
	{
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

	while ( $in->{configuration} =~ /^configure snmpv3 add community (\S+) name (\S+) user (\S+)/mig )
	{
		my $name	= $2;
		my $acctype	= $3;
		if ( $acctype !~ /_rw$/i )
		{
			$out->print_element( "community", { accessType => 'RO', communityString => $name } );
		}
		else
		{
			$out->print_element( "community", { accessType => 'RW', communityString => $name } );
		}
	}

	if ( $in->{configuration} =~ /^configure snmp sysContact "([^",\s]+)/mi )
	{
		$out->print_element( "sysContact", $1 );
	}
	if ( $in->{configuration} =~ /^configure snmp sysLocation "([^",\s]+)/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}
	if ( $in->{configuration} =~ /^configure snmp sysName "([^",\s]+)/mi )
	{
		$out->print_element( "sysName", $1 );
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;

	my $cidr = get_crep('cidr');
	my $cipm = get_crep('cipm');
	my $staticRoutes;
	while ( $in->{route} =~ /^\S+\s+(Default Route|$cidr)\s+($cipm)\s+(\d+)\s+(\S+)\s+(\S+)/mig )
	{
		my $dest_address	= $1;
		my $dest_mask		= $1;
		my $gateway			= $2;
		my $metric			= $3;
		$_					= uc( $4 );
		my $if				= $5;
		my $defaultGateway;
		if ( /S/i )
		{
			if ( $dest_address =~ /Default Route/i )
			{
				$dest_address	= $dest_mask = '0.0.0.0';
				$defaultGateway	= 'true';
			}
			else
			{
				my $temp		= parseCIDR( $dest_address );
				$dest_address	= $temp->{host};
				$dest_mask		= $temp->{network};
				$defaultGateway	= 'false';
			}
			my $route =
			{
				destinationAddress	=> $dest_address,
				destinationMask		=> mask_to_bits ( $dest_mask ),
				gatewayAddress		=> $gateway,
				routeMetric			=> $metric,
				defaultGateway		=> $defaultGateway,
				interface			=> $if
			};
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");
	my ( $ptable )	= $in->{interfaces} =~ /=+\s+(\S[^=]+)=+/mis;
	$ptable			= trim($ptable);

	while ( $ptable =~ /^(\S+)\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+(?:\s+\d+)?)\s+(\S+(?:\s+(?:FULL|HALF))?)\s+/mig )
	{
		my $port_number = $1;
		my $port_state	= uc( $2 );
		my $link_state	= uc( $3 );
		my $auto_neg	= $4;
		my $speed		= uc( $5 );
		my $duplex		= uc( $6 );
		my $interface	=
		{
			adminStatus	 	  => $link_state eq 'A' ? 'up' : 'down',
			name          	  => $port_number,
			interfaceType 	  => 'ethernet',
			physical     	  => 'true',
		};
		if ( $speed =~ /^AUTO\s*$/i )
		{
			$interface->{interfaceEthernet}->{autoSpeed} = 'true';
		}
		elsif ( $speed =~ /^AUTO\s*(\d+)/i )
		{
			$interface->{speed} = $1 * 1000 * 1000;
		}
		if ( $duplex =~ /^AUTO\s*$/i )
		{
			$interface->{interfaceEthernet}->{autoDuplex} = 'true';
		}
		elsif ( $duplex =~ /^AUTO\s*(\S+)/i )
		{
			$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
			$interface->{interfaceEthernet}->{operationalDuplex}	= lc($1);
		}
		# check for IP within vlans
		while ( (my $key, my $value) = each(%{$in}) )
		{
			if ( $key =~ /^vlan/ )
			{
				if ( $value =~ /Untag:(.+)Flags:/mis )
				{
					$_ = $1;
					if ( /\*$port_number\W/ )
					{
						if ( $value =~ /\bPrimary IP\s+:\s+(\d+\.\d+\.\d+\.\d+)\/(\d+)/mi )
						{
							push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $1, mask => $2 };
						}
					}
				}
			}
		}
		$out->print_element( "interface", $interface );
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	my $vlansOpened;

	while ( (my $key, my $value) = each(%{$in}) )
	{
		if ( $key =~ /^vlan/ )
		{
			my $this_vlan_id	= $key;
			$this_vlan_id		=~ s/^vlan_//i;
			my $this_vlan_dump	= $value;
			my $vlan =
			{
				name	=> $this_vlan_id,
				enabled	=> 'true',
			};
			if ( $this_vlan_dump =~ /\bTag\s+(\d+)/mi )
			{
				$vlan->{number} = $1;
			}
			if ( $this_vlan_dump =~ /Untag:\s+(\S.+)\s+Flags:/mis )
			{
				my @ports = split( /\,\s+/mi, $1 );
				foreach ( @ports )
				{
					push @{$vlan->{interfaceMember}}, $1 if ( /(\d+)/ );
				}
			}
			if ( !$vlansOpened )
			{
				$out->open_element("vlans");
				$vlansOpened = 1;
			}
			$out->print_element( "vlan", $vlan );
		}
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

	while ( (my $key, my $value) = each(%{$in}) )
	{
		if ( $key =~ /^stp/ )
		{
			my $this_stp_id		= $key;
			$this_stp_id		=~ s/^stp_//i;
			my $this_stp_dump	= $value;
			my $mac2			= get_crep('mac2');
			my $instance;
			if ( $this_stp_dump =~ /^BridgeID:\s+(?:80:00:|00:00:)?($mac2)/mi )
			{
				$instance->{systemMacAddress} = strip_mac($1);
			}
			if ( $this_stp_dump =~ /^Designated root:\s+(?:80:00:|00:00:)?($mac2)/mi )
			{
				$instance->{designatedRootMacAddress} = strip_mac($1);
			}
			if ( $this_stp_dump =~ /^MaxAge:\s+(\d+)s\s+HelloTime:\s+(\d+)s\s+ForwardDelay:\s+(\d+)s/mi )
			{
				$instance->{designatedRootForwardDelay}	= $3;
				$instance->{designatedRootHelloTime}	= $2;
				$instance->{designatedRootMaxAge}		= $1;
			}
			if ( $this_stp_dump =~ /^CfgBrMaxAge:\s+(\d+)s\s+CfgBrHelloTime:\s+(\d+)s\s+CfgBrForwardDelay:\s+(\d+)s/mi )
			{
				$instance->{forwardDelay}	= $3;
				$instance->{helloTime}		= $2;
				$instance->{maxAge}			= $1;
			}
			if ( $this_stp_dump =~ /\bHold time:\s+(\d+)s/mi )
			{
				$instance->{holdTime} = $1;
			}
			if ( $this_stp_dump =~ /^Bridge Priority:\s+(\d+)/mi )
			{
				$instance->{priority} = $1;
			}
			if ( $this_stp_dump =~ /^Participating Vlans:\s+(\S+)/mi )
			{
				$instance->{vlan} = $1;
			}
			push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
		}
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);

}

sub get_redist_protocol
{
	$_ = shift;

	if ( /static/i )
	{
		return 'static';
	}
	#elsif ( /direct/i )
	#{
	#	return 'connected';
	#}
	elsif ( /rip2/i )
	{
		return 'rip2';
	}
	elsif ( /rip/i )
	{
		return 'rip';
	}
	elsif ( /eigrp/i )
	{
		return 'eigrp';
	}
	elsif ( /igrp/i )
	{
		return 'igrp';
	}
	elsif ( /isis/i )
	{
		return 'isis';
	}
	elsif ( /ospf/i )
	{
		return 'ospf';
	}
	elsif ( /bgp/i )
	{
		return 'bgp';
	}

	return 0;
}

1;
