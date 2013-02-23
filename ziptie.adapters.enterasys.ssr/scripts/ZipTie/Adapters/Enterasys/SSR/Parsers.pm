package ZipTie::Adapters::Enterasys::SSR::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep strip_mac getUnitFreeNumber parseCIDR mask_to_bits);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}        = 'Motorola';
	if ( $in->{hardware} =~ /\bSystem type\s+:\s+(\S[^\,]+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ( $in->{hardware} =~ /\bCPU Module type\s+:\s+(\S[^\,]+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}

	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	if ( $in->{hardware} =~ /\bProcessor\s+:\s+(\S.+)$/mi )
	{
		$_ = $1;
		my $cpu;
		$cpu->{"core:description"}	= $1;
		$cpu->{cpuType}				= $1 if ( /^([^\s\,]+)/ );
		$out->print_element( "cpu", $cpu );
	}

	if ( $in->{hardware} =~ /Flash Memory\s*:\s+(\d+)\s*(\S+)/mi )
	{
		$out->print_element( "memory", { kind => 'Flash', size => getUnitFreeNumber ( $1, $2 ) } );
	}
	if ( $in->{hardware} =~ /System Memory size\s*:\s+(\d+)\s*(\S+)/mi )
	{
		$out->print_element( "memory", { kind => 'RAM', size => getUnitFreeNumber ( $1, $2 ) } );
	}
	if ( $in->{hardware} =~ /Network Memory size\s*:\s+(\d+)\s*(\S+)/mi )
	{
		$out->print_element( "memory", { kind => 'Other', size => getUnitFreeNumber ( $1, $2 ), 'core:description' => 'Network Memory' } );
	}

	$out->close_element("chassis");
}

sub _parse_cards
{
	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;
  
	my ( $slotBlob ) = $in->{hardware} =~ /Slot Information(.+)$/mis;
	if ( $slotBlob )
	{
		my $no;
		my $description;
		my $portCount = 0;
		my $hw;
		while ( $slotBlob =~ /^(.+)$/mig )
		{
			$_ = trim ( $1 );
			next if ( !$_ );

			if ( /\bSlot\s+(?:\S\D+)?(\d+)\,\s+Module:\s+(\S+)\s+Rev\.\s+(\S+)\s*$/i )
			{
				if ( $no )
				{
					my $card;
					$card->{slotNumber}			= $no;
					$card->{portCount}			= $portCount;
					$card->{"core:description"}	= $description;

					$card->{"core:asset"}->{"core:assetType"}								= "Card";
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}				= 'Motorola';
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"}	= $hw;
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}		= 'Unknown';

					$out->print_element( "card", $card );
				}
				$no				= $1;
				$description	= $2;
				$hw				= $3;
				$description	= trim ( $description );
				$portCount		= 0;
			}
			elsif ( /\bPort:\s+\S+/i )
			{
				$portCount++;
			}
		}
		if ( $no )
		{
			my $card;
			$card->{slotNumber}			= $no;
			$card->{portCount}			= $portCount;
			$card->{"core:description"}	= $description;

			$card->{"core:asset"}->{"core:assetType"}								= "Card";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}				= 'Motorola';
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"}	= $hw;
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}		= 'Unknown';

			$out->print_element( "card", $card );
		}
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	( $_ ) = $in->{sys_name} =~ /\bSystem name:\s+(\S.*)$/mi;
	$out->print_element( 'core:systemName', trim ( $_ ) );

	$out->open_element('core:osInfo');
	if ( $in->{version} =~ /\bImage Boot Location\s*:\s+slot\d+:(\S+)/mi )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Motorola' );
	#$out->print_element( 'core:name', 'IPM' );
	if ( $in->{version} =~ /\bSoftware Version\s+:\s+(\S.+)$/mi )
	{
		$out->print_element( 'core:version', trim ( $1 ) );
	}
	$out->print_element( 'core:osType', 'IPM' );
	$out->close_element('core:osInfo');

	if ( ( $in->{version} =~ /\bBoot Prom Version\s+:\s+(\S.+)$/mi ) )
	{
		$out->print_element( 'core:biosVersion', trim ( $1 ) );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	( $_ ) = $in->{sys_contact} =~ /\bAdministrative contact:\s+(\S.*)$/mi;
	$out->print_element( 'core:contact', trim ( $_ ) );

	# System up 11 days, 23 hours, 14 minutes, 13 seconds
	if ( $in->{uptime} =~ /System up\s+(\S.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;
		my ($seconds) = /(\d+)\s*seconds?/;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$lastReboot -= $seconds		                  if ($seconds);
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
	my $active;
	$active->{'core:name'}       = 'active-config';
	$active->{'core:textBlob'}   = encode_base64( $in->{'active-config'} );
	$active->{'core:mediaType'}  = 'text/plain';
	$active->{'core:context'}    = 'active';
	$active->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $active );

	# build the simple text configuration
	my $startup;
	$startup->{'core:name'}       = 'startup-config';
	$startup->{'core:textBlob'}   = encode_base64( $in->{'startup-config'} );
	$startup->{'core:mediaType'}  = 'text/plain';
	$startup->{'core:context'}    = 'boot';
	$startup->{'core:promotable'} = 'true';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

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
	$out->open_element("snmp");

	while ( $in->{snmp_community} =~ /^\s+\d+\.\s+(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
	{
		my $comm_string	= $1;
		my $access_type	= $2;
		if ( $access_type =~ /WRITE/i )
		{
			$access_type = 'RW';
		}
		else
		{
			$access_type = 'RO';
		}
		$out->print_element( "community", { accessType => $access_type, communityString => $comm_string } );
	}

	if ( $in->{sys_contact} =~ /\bAdministrative contact:\s+(\S.*)$/mi )
	{
		$out->print_element( "sysContact", trim ( $1 ) );
	}
	if ( $in->{sys_location} =~ /\bSystem location:\s+(\S.*)$/mi )
	{
		$out->print_element( "sysLocation", trim ( $1 ) );
	}
	( $_ ) = $in->{sys_name} =~ /\bSystem name:\s+(\S.*)$/mi;
	$out->print_element( "sysName", trim ( $_ ) );

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;

	my $cidr = get_crep('cidr');
	my $cipm = get_crep('cipm');
	my $staticRoutes;
	while ( $in->{route} =~ /^(default|$cidr)\s+($cipm|directly connected)\s+Static\s+(\S+)\s*$/mig )
	{
		$_			= lc ( $1 );
		my $gateway	= $2;
		my $if		= $3;
		my $defaultGateway;
		my ( $dest_address, $dest_mask );
		if ( $_ eq 'default' )
		{
			$dest_address	= $dest_mask = '0.0.0.0';
			$defaultGateway	= 'true';
		}
		else
		{
			my $temp		= parseCIDR( $_ );
			$dest_address	= $temp->{host};
			$dest_mask		= $temp->{network};
			$defaultGateway	= 'false';
		}
		if ( $gateway eq 'directly connected' )
		{
			$gateway = $dest_address;
		}
		my $route =
		{
			destinationAddress	=> $dest_address,
			destinationMask		=> mask_to_bits ( $dest_mask ),
			gatewayAddress		=> $gateway,
			interface			=> $if,
			defaultGateway		=> $defaultGateway
		};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;

	$out->open_element("interfaces");

	# first parse the ips, mac and mtu
	my $if_ports;
	my $cipm = get_crep('cipm');
	my ( $if_name, $if_port );
	while ( $in->{interfaces} =~ /^(.+)$/mig )
	{
		$_ = trim ( $1 );
		next if ( !$_ );
		if ( /^Interface\s+([^:\s]+):/i )
		{
			$if_name = $1;
		}
		elsif ( /\bPorts:\s+(\S+)/i && $if_name )
		{
			$if_port = $1;
		}
		elsif ( /\bIP Address:\s+(\d+\.\d+\.\d+\.\d+)\/(\d+)(?:\s+\(broadcast:\s+($cipm)\))?/i && $if_port )
		{
			$if_ports->{$if_port}->{ip}		= $1;
			$if_ports->{$if_port}->{mask}	= $2;
			$if_ports->{$if_port}->{bc}		= $3;
		}
		elsif ( /\bMTU:\s+(\d+)/i && $if_port )
		{
			$if_ports->{$if_port}->{mtu} = $1;
		}
		elsif ( /\bMAC Address:\s+(\S+)/i && $if_port )
		{
			$if_ports->{$if_port}->{mac} = strip_mac( $1 );
		}
	}
	while ( $in->{mau} =~ /^(\S+)\s+(\d+\s+\S+\s+\S+)\s+(\d+\s+\S+\s+\S+)\s+\S+\s+\S+\s+(\S+)\s*$/mig )
	{
		my $name		= $1;
		my $media_type	= $2;
		my $more_data;
		if ( $in->{ports} =~ /^$name\s+(\S.+)$/mi )
		{
			$more_data = $1;
		}
		my ( $adminStatus ) = $more_data =~ /(?:Down|Up)\s+(Down|Up)(?:\s+(\S+))?\s+/i;
		if ( lc( $adminStatus ) ne 'up' && lc( $adminStatus ) ne 'down')
		{
			$adminStatus = 'down';
		}
		$adminStatus		= lc ( $adminStatus );
		my $interfaceType	= 'other';
		$interfaceType		= 'ethernet' if ( $more_data =~ /Ethernet/i );
		my ( $speed, $duplex ) = $media_type =~ /^(\d+)\s+\S+\s+(\S+)$/i;
		$speed *= 1000 * 1000;
		my $interface	=
		{
			adminStatus			=> $adminStatus,
			name				=> $name,
			interfaceType		=> $interfaceType,
			physical			=> 'true',
			speed				=> $speed,
		};
		if ( uc ($duplex) eq 'HD' )
		{
			$duplex = 'half';
		}
		elsif ( uc ($duplex) eq 'FD' )
		{
			$duplex = 'full';
		}
		else
		{
			$duplex = 'auto';
		}
		if ( $duplex ne 'auto' )
		{
			$interface->{interfaceEthernet}->{operationalDuplex} = $duplex;
		}
		else
		{
			$interface->{interfaceEthernet}->{autoDuplex} = 'true';
		}
		$interface->{interfaceEthernet}->{macAddress}	= $if_ports->{$name}->{mac} if ( $if_ports->{$name}->{mac} );
		$interface->{mtu}								= $if_ports->{$name}->{mtu} if ( $if_ports->{$name}->{mtu} );
		push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $if_ports->{$name}->{ip}, mask => $if_ports->{$name}->{mask}, broadcast => $if_ports->{$name}->{bc} } if ( $if_ports->{$name}->{ip} );
		$out->print_element( "interface", $interface );
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

	my $mac1 = get_crep('mac1');
	my $instance;
	if ( $in->{stp} =~ /\bBridge ID\s+:\s+[0-9a-f]+:($mac1)/mi )
	{
		$instance->{systemMacAddress} = $1;
	}
	if ( $in->{stp} =~ /\bRoot bridge\s+:\s+[0-9a-f]+:($mac1)/mi )
	{
		$instance->{designatedRootMacAddress} = $1;
	}
	if ( $in->{stp} =~ /\bMax age\s+:\s(\d+)\s+secs/mi )
	{
		$instance->{maxAge} = $1;
	}
	if ( $in->{stp} =~ /\bHello time\s+:\s(\d+)\s+secs/mi )
	{
		$instance->{helloTime} = $1;
	}
	if ( $in->{stp} =~ /\bForward delay\s+:\s(\d+)\s+secs/mi )
	{
		$instance->{forwardDelay} = $1;
	}

	my $spanningTree;
	push( @{ $spanningTree->{spanningTreeInstance} }, $instance ) if ( $instance->{systemMacAddress} );

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

1;
