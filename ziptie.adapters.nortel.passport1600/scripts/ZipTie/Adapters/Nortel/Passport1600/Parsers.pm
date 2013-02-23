package ZipTie::Adapters::Nortel::Passport1600::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep getUnitFreeNumber parseCIDR strip_mac);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;

	$chassis->{'core:asset'}->{'core:assetType'} = 'Chassis';
	$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}			= 'Nortel';
	$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'}	= 'Unknown';
	if ( $in->{switch} =~ /\bFirmware Version\s+:\s+(?:Build )?(\S+)/mi )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:firmwareVersion'} = $1;
	}
	if ( $in->{switch} =~ /\bHardware Version\s+:\s+(\S+)/mi )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	if ( $in->{switch} =~ /\bDevice S\/N\s+:\s+(\S+)/mi )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}

	$out->print_element( "chassis", $chassis );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ( $sysName ) = $in->{switch} =~ /\bSystem Name\s+:\s+(\S+)/mi;
	$out->print_element( 'core:systemName', $sysName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make',    'Nortel' );
	if ( $in->{switch} =~ /\bDevice Type\s+:\s+(\S+)\s+(\S+)/mi )
	{
		$out->print_element( 'core:name', $1 );
		$_ = $2;
		s/\(//;
		s/\)//;
		$out->print_element( 'core:version', $_ );
	}
	$out->print_element( 'core:osType',  'Passport' );
	$out->close_element('core:osInfo');

	if ( ( $in->{switch} =~ /\bBoot PROM Version\s+:\s+(?:Build)?\s+(\S+)/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	if ( $in->{switch} =~ /\bSystem Contact\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:contact', $1 );
	}

	# System restarted at 18:00:01 CST Sun Feb 28 1993
	if ( $in->{switch} =~ /\bSystem Boot Time\s+:\s+(\d{4})\/(\d{2})\/(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/mi )
	{
		my $year	= $1;
		my $month	= $2;
		my $day		= $3;
		my $hour	= $4;
		my $min		= $5;
		my $sec		= $6;
		my $timezone = 'CST';

		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
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
	$config->{'core:textBlob'}   = encode_base64( _apply_masks($in->{'config'}) );
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

	my ( $accounts ) = $in->{accounts} =~ /Access\s+Level\s+Log(.+)Total\s+Entries/mis;
	$accounts =~ s/-+\s+-+\s+-+\s*//ms;
	$accounts = trim ( $accounts );
	while ( $accounts =~ /\b(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
	{
		my $account =
		{
			accountName => $1,
			accessGroup	=> $2,
		};
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

	my ( $communities ) = $in->{snmp} =~ /Community\s+String\s+Rights(.+)Total\s+Entries/mis;
	$communities =~ s/-+\s+-+\s*//ms;
	$communities = trim ( $communities );
	while ( $communities =~ /\b(\S+)\s+(\S+)\s*$/mig )
	{
		my $commString	= $1;
		my $accessType	= ( $2 ne 'Read/Write' ) ? 'RO' : 'RW';
		$out->print_element("community", { "communityString" => $commString, "accessType" => $accessType } );
	}

	if ( $in->{snmp} =~ /\bSystem Contact\s+:(.+)$/mi )
	{
		$_ = $1;
		$_ = trim ( $_ );
		if ( $_ )
		{
			$out->print_element( "sysContact", $_ );
		}
	}
	if ( $in->{snmp} =~ /\bSystem Location\s+:(.+)$/mi )
	{
		$_ = $1;
		$_ = trim ( $_ );
		if ( $_ )
		{
			$out->print_element( "sysLocation", $_ );
		}
	}
	if ( $in->{snmp} =~ /\bSystem Name\s+:(.+)$/mi )
	{
		$_ = $1;
		$_ = trim ( $_ );
		if ( $_ )
		{
			$out->print_element( "sysName", $_ );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;

	my $staticRoutes;
	my $ecipm		= get_crep('ecipm');
	my $cidr		= get_crep('cidr');
	my ($routes)	= $in->{routes} =~ /PREF(.+?)Total Entries/mis;
	while ( $routes =~ /\b($ecipm|$cidr)\s+($ecipm)\s+(\S+)\s+(\d+)\s+\S+\s+(\d+)\s*$/mig )
	{
		my $gw			= $2;
		my $if			= $3;
		my $cost		= $4;
		my $pref		= $5;
		$_				= $1;
		$_ .= '/0' if ( $_ !~ /\// );
		my $address		= parseCIDR( $_ );
		my $route = 
		{
			destinationAddress	=> $address->{host},
			destinationMask		=> mask_to_bits ( $address->{network} ),
			defaultGateway		=> ( $address->{host} ne '0.0.0.0' ) ? 'false' : 'true',
			gatewayAddress		=> $gw,
			routePreference		=> $pref,
			interface			=> $if,
		};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;

	$out->open_element("interfaces");

	$_			= get_crep('cipm');
	my ($ip)	= $in->{ipif} =~ /\s+IP Address\s+:\s+($_)/mi;
	my ($mask)	= $in->{ipif} =~ /\s+Subnet Mask\s+:\s+($_)/mi;
	my $ip_ports;
	if ( $in->{ipif} =~ /\s+Member Ports\s+:\s+(\S+)/mi )
	{
		$_ = $1;
		my @pieces = split ( /\,/ );
		foreach (@pieces)
		{
			if ( /(\d+)-(\d+)/ )
			{
				for ($1..$2)
				{
					$ip_ports->{$_} = 1;
				}
			}
			else
			{
				$ip_ports->{$_} = 1;
			}
		}
	}
	while ( $in->{ports} =~ /\b(\d+)\s+(\S+)\s+(\S+)\s+(\S+|(?:Link Down))\s+(\S+)\s*$/mig )
	{
		my $name	= $1;
		my $conn	= $4;
		my $astatus	= uc( $conn ) eq 'LINK DOWN' ? 'down' : 'up';
		my $interface	= 
		{
			adminStatus		=> $astatus,
			name			=> $name,
			interfaceType	=> 'ethernet',
			physical		=> 'true',
		};
		if ( $ip_ports->{$name} )
		{
			push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $ip, mask => mask_to_bits($mask) };
		}
		if ( $conn =~ /(\d+)([KMG])\/(\w+)/i )
		{
			my $duplex = lc ( $3 );
			$interface->{speed} = getUnitFreeNumber ($1, $2, 'bit');
			if ( $duplex =~ /(full|half)/ )
			{
				$interface->{interfaceEthernet}->{operationalDuplex} = $duplex;
			}
			elsif ( $duplex =~ /auto/ )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = 'true';
			}
		}
		if ( $in->{stp_ports} =~ /\b$name\s+$conn\s+(\S+)\s+[^\d\s](\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s*/mi )
		{
			$interface->{interfaceSpanningTree}->{cost}					= $2;
			$interface->{interfaceSpanningTree}->{priority}				= $3;
			$interface->{interfaceSpanningTree}->{spanningTreeInstance}	= $5;
			$_ = $4;
			if ( /Disabled/ )
			{
				$interface->{interfaceSpanningTree}->{state} = 'disabled';
			}
			elsif ( /Forw/ )
			{
				$interface->{interfaceSpanningTree}->{state} = 'forwarding';
			}
			elsif ( /Block/ )
			{
				$interface->{interfaceSpanningTree}->{state} = 'blocking';
			}
			elsif ( /Learn/ )
			{
				$interface->{interfaceSpanningTree}->{state} = 'learning';
			}
			elsif ( /Listen/ )
			{
				$interface->{interfaceSpanningTree}->{state} = 'listening';
			}
		}
		$out->print_element( "interface", $interface );
	}
	$_ = $in->{port_mgmt};
	if ( /\b(Enabled|Disabled)\s+(\S+)\s+(\S+|(?:Link Down))\s*$/mig )
	{
		my $name	= "mgmt_port";
		my $conn	= $3;
		my $astatus	= uc( $conn ) eq 'LINK DOWN' ? 'down' : 'up';
		my $interface	= 
		{
			adminStatus		=> $astatus,
			name			=> 'mgmt_port',
			interfaceType	=> 'ethernet',
			physical		=> 'true',
		};
		if ( $ip_ports->{$name} )
		{
			push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $ip, mask => mask_to_bits($mask) };
		}
		if ( $conn =~ /(\d+)([KMG])\/(\w+)/i )
		{
			my $duplex = lc ( $3 );
			$interface->{speed} = getUnitFreeNumber ($1, $2, 'bit');
			if ( $duplex =~ /(full|half)/ )
			{
				$interface->{interfaceEthernet}->{operationalDuplex} = $duplex;
			}
			elsif ( $duplex =~ /auto/ )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = 'true';
			}
		}
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

	my $spanningTree;
	if ( $in->{stp} =~ /STP Status\s+:\s+Enabled/mi )
	{
		$_ = $in->{stp};
		my $instance;
		$instance->{'forwardDelay'}				= $1 if ( /\bForward Delay\s+:\s+(\d+)/mi );
		$instance->{'helloTime'}				= $1 if ( /\bHello Time\s+:\s+(\d+)/mi );
		$instance->{'maxAge'}					= $1 if ( /\bMax Age\s+:\s+(\d+)/mi );
		$instance->{'priority'}					= $1 if ( /\bPriority\s+:\s+(\d+)/mi );
		$instance->{'designatedRootMacAddress'}	= strip_mac ( $1 ) if ( /\bDesignated Root Bridge\s+:\s+([a-f0-9\-]{17})/mi );
		$instance->{'designatedRootPriority'}	= $1 if ( /\bRoot Priority\s+:\s+(\d+)/mi );
		$instance->{'designatedRootCost'}		= $1 if ( /\bCost to Root\s+:\s+(\d+)/mi );
		if ( /\bRoot Port\s+:\s+(\S+)/mi )
		{
			$instance->{'designatedRootPort'} = $1 if ( lc ( $1 ) ne 'none' );
		}
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

sub _apply_masks
{
	# remove any trivial pieces of the configuration that
	# may cause improper diffs.

	my $text = shift;
	$text =~ s/#\d+\/\d+\/\d+\s*\d{1,2}:\d{1,2}:\d{1,2}\s*.*$//m;                  # remove the timestamp
	return $text;
}

1;
