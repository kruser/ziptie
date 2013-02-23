package ZipTie::Adapters::ThreeCom::Switch4400::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_port_ip_by_vlan);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{'system'} =~ /^Hardware Version\s+:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "3Com";
	if ($in->{'system'} =~ /^Product Number\s+:\s+(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ($in->{'system'} =~ /^Serial Number\s+:\s+(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;		
	} 

	$out->print_element( "core:asset", $chassisAsset );

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{'system'} =~ /^System Name\s+:\s+(\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element('core:make', '3Com');
	if ( $in->{'system'} =~ /summary\s+(\S.+)System Name/mis )
	{
		$out->print_element( 'core:name', trim($1) );
	}
	if ( $in->{'system'} =~ /^Operational Version\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'SuperStack III' );
	$out->close_element('core:osInfo');

	if ( $in->{'system'} =~ /^Boot Version\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{'system'} =~ /^Contact\s+:\s+(\S.+)$/mi;
	$out->print_element( 'core:contact', trim($contact) );

	# Time Since Reset        : 5947 Hrs 3 Mins 20 Seconds
	if ( $in->{'system'} =~ /^Time Since Reset\s+:\s+(\S.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*Years?/;
		my ($weeks)   = /(\d+)\s*Weeks?/;
		my ($days)    = /(\d+)\s*Days?/;
		my ($hours)   = /(\d+)\s*Hrs?/;
		my ($minutes) = /(\d+)\s*Mins?/;
		my ($seconds) = /(\d+)\s*Seconds?/;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$lastReboot -= $seconds						  if ($seconds);
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
	$out->open_element("localAccounts");

	my $users = $in->{users};
	$users =~ s/[^-]+-+//mis;
	while ( $users =~ /^(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
	{
		my $account = { accountName => $1 };
		$account->{accessGroup} = $2;
		$out->print_element( "localAccount", $account );
	} 

	$out->close_element("localAccounts");
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	$out->open_element("snmp");

	my $anyCommPrinted = 0;
	while ( $in->{'config'} =~ /^system management snmp community (.+)$/mig )
	{
		my $comms	= $1;
		$comms		= trim($comms);
		$comms		=~ s/"//g;
		foreach ( split ( / /, $comms ) )
		{
			$out->print_element( "community", {"communityString" => $_, "accessType" => "RO"});
			$anyCommPrinted = 1;
		}
	}

	if ( $in->{'config'} =~ /^system management contact "([^"]+)"/mi )
	{
		$out->print_element( "sysContact", $1 );
	}
	if ( $in->{'config'} =~ /^system management location "([^"]+)"/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}
	if ( $in->{'config'} =~ /^system management name "([^"]+)"/mi )
	{
		$out->print_element( "sysName", $1 );
		$anyCommPrinted ++;
	}

	if ( $anyCommPrinted > 1 )
	{
		my $cipm = get_crep('cipm');
		while ( $in->{'config'} =~ /^system management snmp trap create (\S+) ($cipm)/mig )
		{
			$out->print_element( "trapHosts", { ipAddress => $2, communityString => $1 } );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	my $staticRoutes;

	my $cipm = get_crep('cipm');
	while ( $in->{routes} =~ /^\s*($cipm|Default Route)\s+($cipm|-+)\s+(\d+|-+)\s+($cipm|-+)\s+(\S+)\s*$/mig )
	{
		my $destAddr	= $1;
		my $destMask	= $2;
		my $metric		= $3;
		my $gwAddr		= $4;
		my $status		= $5;
		if ( $status =~ /Static/i )
		{
			my $route =
			{
				destinationAddress => ( $destAddr !~ /$cipm/ ? '0.0.0.0' : $destAddr ),
				destinationMask    => ( $destAddr !~ /$cipm/ ? '0' : mask_to_bits ( $destMask ) ),
				gatewayAddress     => ( $gwAddr =~ /$cipm/ ? $gwAddr : '0.0.0.0' ),
			};
			$route->{interface} = _pick_subnet( $route->{gatewayAddress}, $subnets );
			if ( $metric =~ /^\d+$/ )
			{
				$route->{routeMetric} = $metric;
			}
			if ( $destAddr =~ /Default/i )
			{
				$route->{defaultGateway} = 'true';
			}
			else
			{
				$route->{defaultGateway} = 'false';
			}

			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
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

sub parse_port_ip_by_vlan
{
	my ( $in ) = @_;
	my $ports_ips;

	while ( $in->{vlans} =~ /VLAN---(.+?)---NEXT/migs )
	{
		$_				= $1;
		my ( $index )	= /VLAN ID:\s+(\d+)/mi;
		/^\s*\d+\s+(\d+)-(\d+)/mi;
		my $ports;
		foreach ( $1..$2 )
		{
			push @{$ports}, $_;
		}
		if ( $ports =~ /ARRAY/i )
		{
			if ( $in->{vlan_ips} =~ /^\s*\d+\s+\S+\s+(\S+)\s+(\S+)\s+\S+\s+($index)\s*$/mi )
			{
				my $ip		= $1;
				my $mask	= mask_to_bits ( $2 );
				foreach (@{$ports})
				{
					$ports_ips->{$_} = { ipAddress => $ip, mask => $mask };
				}
			}
		}
	}

	return $ports_ips;
}

sub parse_interfaces
{
	my ( $in, $out, $ports_ips ) = @_;
	my $subnets			= {};    # will be returned to the caller
	$out->open_element("interfaces");

	my $done_ifs;
	while ( $in->{eth_summary} =~ /^(\d+:\d+)\s+\S+\s+(\S[^\)]+\))\s+/mig )
	{
		my $if_number		= $1;
		my $mode			= $2;
		my ( $sub_index )	= $if_number =~ /:(\d+)/;
		if ( !$done_ifs->{$if_number} )
		{
			$done_ifs->{$if_number} = 1;
			my $adminStatus	= ( $mode =~ /Link Down/i ? 'down' : 'up' );
			my ( $speed, $duplex, $mediaType );
			if ( $mode =~ /(\d+)(full|half|auto) (\(Auto\))?/ )
			{
				$duplex	= lc($2);
				#$duplex = 'auto' if ( $3 );
			}
			elsif ( $mode =~ /Link Down \(Auto\)/ )
			{
				$duplex = 'auto';
			}
			my $interface =
			{
				adminStatus		=> $adminStatus,
				name          	=> $if_number,
				interfaceType 	=> 'ethernet',
				physical      	=> 'true',
			};
			if ( $in->{"eth_$if_number"} )
			{
				if ( $in->{"eth_$if_number"} =~ /Media Type:\s+(\S.+)$/mi )
				{
					$mediaType = trim($1);
				}
			}
			if ( $mediaType =~ /\d+\S+\/(\d+)\S+/ )
			{
				$speed = $1 * 1000 * 1000;
			}
			$interface->{speed} = $speed if ( $speed );
			if ( $duplex eq 'auto' )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = 'true';
			}
			else
			{
				$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
				$interface->{interfaceEthernet}->{operationalDuplex}	= $duplex;
			}
			$interface->{interfaceEthernet}->{mediaType} = $mediaType if ( $mediaType );
			if ( $ports_ips->{$sub_index} )
			{
				push @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ports_ips->{$sub_index} ;
				my $subnet = new ZipTie::Addressing::Subnet( $ports_ips->{$sub_index}->{ipAddress}, $ports_ips->{$sub_index}->{mask} );
				push( @{ $subnets->{$interface->{name}} }, $subnet );
			}
			$out->print_element( "interface", $interface );
		}
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
	my $spanningTree;
	my $instance;

	my $mac1 = get_crep('mac1');
	if  ( $in->{stp}  =~ /^Designated Root:\s+[a-f0-9]{4} ($mac1)/mi )
	{
		$instance->{designatedRootMacAddress} = $1;
	}
	if  ( $in->{stp}  =~ /\brootCost:\s+(\d+)/mi )
	{
		$instance->{designatedRootCost} = $1;
	}
	if  ( $in->{stp}  =~ /\bbridgeMaxAge:\s+(\d+)/mi )
	{
		$instance->{designatedRootMaxAge} = $1;
	}
	if  ( $in->{stp}  =~ /\bbridgeHelloTime:\s+(\d+)/mi )
	{
		$instance->{designatedRootHelloTime} = $1;
	}
	if  ( $in->{stp}  =~ /\bbridgeFwdDelay:\s+(\d+)/mi )
	{
		$instance->{designatedRootForwardDelay} = $1;
	}
	if  ( $in->{stp}  =~ /\bmaxAge:\s+(\d+)/mi )
	{
		$instance->{maxAge} = $1;
	}
	if  ( $in->{stp}  =~ /\bhelloTime:\s+(\d+)/mi )
	{
		$instance->{helloTime} = $1;
	}
	if  ( $in->{stp}  =~ /\bforwardDelay:\s+(\d+)/mi )
	{
		$instance->{forwardDelay} = $1;
	}
	if  ( $in->{stp}  =~ /\bholdTime:\s+(\d+)/mi )
	{
		$instance->{holdTime} = $1;
	}
	if  ( $in->{stp}  =~ /^Bridge Identifier:\s+[a-f0-9]{4} ($mac1)/mi )
	{
		$instance->{systemMacAddress} = $1;
	}
	if  ( $in->{stp}  =~ /\bpriority:\s+(\d+)/mi )
	{
		$instance->{priority} = $1;
	}
	if ( $instance )
	{
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

1;
