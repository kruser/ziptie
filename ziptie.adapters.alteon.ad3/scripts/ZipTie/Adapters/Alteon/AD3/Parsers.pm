package ZipTie::Adapters::Alteon::AD3::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	my $chassisAsset = { "core:assetType" => "Chassis", };
	my $partNumber   = undef;
	my $modelNumber  = undef;

	if ( $in->{info_dump} =~ /^Hardware Part No:\s+(\S+)/mi )
	{
		$partNumber = $1;
		$partNumber = trim($partNumber);
	}
	if ( $in->{info_dump} =~ /^Hardware Revision:\s+([\w\.\-]+)/mi )
	{
		$modelNumber = $1;
		$modelNumber = trim($modelNumber);
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:partNumber'}  = $partNumber if $partNumber;
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}        = "Alteon";
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $modelNumber if $modelNumber;

	$out->open_element("chassis");

	$out->print_element( "core:asset", $chassisAsset );

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{info_dump} =~ /^sysName:\s+(\S.+)$/mi;
	$systemName = trim($systemName);
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Nortel' );
	$out->print_element( 'core:name', 'AD3' );
	if ( $in->{info_dump} =~ /^Software Version\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'Alteon' );
	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Switch' );

	if ( $in->{info_dump} =~ /^Switch is up (.+)$/mi )
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
		$lastReboot -= $seconds                       if ($seconds);
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
	my $any_config;
	$any_config->{'core:name'}       = 'boot';
	$any_config->{'core:textBlob'}   = encode_base64( $in->{'config'} );
	$any_config->{'core:mediaType'}  = 'text/plain';
	$any_config->{'core:context'}    = 'N/A';
	$any_config->{'core:promotable'} = 'true';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $any_config );

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
	while ( $in->{info_dump} =~ /^\s*($_)\s+($_)\s+($_)\s+(\S+)\s+(\S+)(?:\s+(\d+))?(.+)$/mig )
	{
		my $address = $1;
		my $mask    = $2;
		my $gw      = $3;
		my $type    = $4;
		my $tag     = lc($5);
		my $metric  = $6;
		my $if_num  = trim ( $7 );
		$if_num		= 'Unknown' if ( !$if_num );
		if ( $tag eq 'static' )
		{
			my $route =
			{
				defaultGateway      => ( $address eq '0.0.0.0' ? 'true' : 'false' ),
				destinationAddress  => $address,
				destinationMask     => mask_to_bits( $mask ),
				gatewayAddress      => $gw,
				interface			=> $if_num
			};
			if ($metric)
			{
				$route->{routeMetric} = trim($metric) if ( $metric =~ /\d+/ );
			}

			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");

	my ($portsBasic) = $in->{info_dump} =~ /(^-+\s+Port.+?^-+\s+^)/mis;
	my ($ifInfo)     = $in->{info_dump} =~ /^Interface information:(.+)^Default gateway information:/mis;
	my ($stps)       = $in->{info_dump} =~ /^Spanning Tree Group(.+)^VLAN\s+Name\s+Status\s+/mis;
	my ($arpCache)   = $in->{info_dump} =~ /^ARP cache information:(.+)^ARP address information:\s+/mis;
	my $mac2         = get_crep('mac2');
	while ( $portsBasic =~ /^\s*(\d+)\s+(\d+(?:\/\d+)?)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
	{
		my $port   = $1;
		my $speed  = $2;
		my $duplex = lc($3);
		my $status = lc($6);
		$speed = $1 if ( $speed =~ /\/(\d+)$/ );
		$duplex = 'auto' if ( $duplex eq 'any' );
		$status = 'down' if ( $status ne 'up' );
		my $interface = {
			name          => $port,
			adminStatus   => lc($status),
			interfaceType => get_interface_type($port),
			physical      => _is_physical($port),
			speed         => $speed,
		};

		if ( $duplex eq 'auto' )
		{
			$interface->{interfaceEthernet}->{autoDuplex} = 'true';
		}
		else
		{
			$interface->{interfaceEthernet}->{autoDuplex}        = 'false';
			$interface->{interfaceEthernet}->{operationalDuplex} = $duplex;
		}
		$_ = get_crep('cipm');
		if ( $ifInfo =~ /^\s*$port:\s+($_)\s+($_)\s+($_)\,.+$/mi )
		{
			push @{ $interface->{interfaceIp}->{ipConfiguration} }, { broadcast => $3, ipAddress => $1, mask => mask_to_bits($2), precedence => 1 };
			$_ = $1;
			if ( $arpCache =~ /^\s*$_(?:\s+\S+)?\s+($mac2)\s+.+$/mi )
			{
				$interface->{interfaceEthernet}->{macAddress} = strip_mac($1);
			}
		}
		while ( ( my $key, my $value ) = each( %{$in} ) )
		{
			if ( $key =~ /^stp-(\d+)$/i )
			{
				my $sti = $1;
				$_ = get_crep('mac2');
				if ( $value =~ /^\s*$port\s+(\d+)\s+(\d+)\s+(\S+)\s+(?:[a-f0-9]*-($_))?(?:\s+(\d+))?/mi )
				{
					$interface->{interfaceSpanningTree}->{cost}                 = $2;
					$interface->{interfaceSpanningTree}->{priority}             = $1;
					$interface->{interfaceSpanningTree}->{spanningTreeInstance} = $sti;
					$interface->{interfaceSpanningTree}->{state}                = lc($3);
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

	my ($vlan_blob) = $in->{info_dump} =~ /^VLAN\s+Name\s+Status\s+Jumbo\s+Ports(.+)Forwarding database information:/mis;
	my $vlansOpened;
	while ( $vlan_blob =~ /^(\d+)\s+(\S.+?)\s+(ena|dis)\s+(n|y)\s+(\S.*)$/mig )
	{
		my $number = $1;
		my $name   = $2;
		my $status = lc($3);
		my $ports  = $5;
		$name  = trim($name);
		$ports = trim($ports);
		if ( $status eq 'ena' )
		{
			$status = 'true';
		}
		elsif ( $status eq 'dis' )
		{
			$status = 'false';
		}
		my $vlan = {
			name    => $name,
			number  => $number,
			enabled => $status,
		};
		foreach ( split( / /, $ports ) )
		{
			push @{ $vlan->{interfaceMember} }, $_ if (/^\d+$/);
		}
		if ( !$vlansOpened )
		{
			$vlansOpened = 1;
			$out->open_element("vlans");
		}
		$out->print_element( "vlan", $vlan );
	}
	if ($vlansOpened)
	{
		$out->close_element("vlans");
	}
}

sub parse_stp
{
	my ( $in, $out ) = @_;

	my ($stps) = $in->{info_dump} =~ /^(Spanning Tree Group.+)^VLAN\s+Name\s+Status\s+/mis;
	my $mac2 = get_crep('mac2');
	my $stp_group_id;
	my $stp_group_status;
	my $instance;
	my $spanningTree;
	while ( $stps =~ /^(.+)$/mig )
	{
		my $stp_line = $1;
		if ( $stp_line =~ /^Spanning Tree Group (\d+):\s+(\S+)/i )
		{
			$stp_group_id     = $1;
			$stp_group_status = $2;
			if ($instance)
			{
				push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
			}
			$instance = undef;
		}
		elsif ($stp_line =~ /^\s*[a-f0-9]+\s+($mac2)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/i
			&& $stp_group_id )
		{
			my $current_root = $1;
			my $path_cost    = $2;
			my $port         = $3;
			my $hello        = $4;
			my $maxage       = $5;
			my $fwddel       = $6;
			my $aging        = $7;
			$instance->{designatedRootHelloTime}    = $hello;
			$instance->{designatedRootMaxAge}       = $maxage;
			$instance->{designatedRootForwardDelay} = $fwddel;
			$instance->{designatedRootCost}         = $path_cost;
			$instance->{designatedRootMacAddress}   = strip_mac($current_root);
			$instance->{designatedRootPort}         = $port;
		}
		elsif ($stp_line =~ /^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/i
			&& $stp_group_id )
		{
			my $priority = $1;
			my $hello    = $2;
			my $maxage   = $3;
			my $fwddel   = $4;
			my $aging    = $5;
			$instance->{forwardDelay} = $fwddel;
			$instance->{helloTime}    = $hello;
			$instance->{maxAge}       = $maxage;
			$instance->{priority}     = $priority;
			$instance->{holdTime}     = $aging;
		}
	}
	if ($instance)
	{
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}
	$instance = undef;

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
