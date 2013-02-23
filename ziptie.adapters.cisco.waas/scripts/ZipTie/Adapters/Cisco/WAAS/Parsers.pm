package ZipTie::Adapters::Cisco::WAAS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_vtp parse_static_routes parse_vlans parse_stp parse_routing parse_access_ports create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces);

# Class constants.
# The reasonable memory sizes in MBs: 2 to the n-th power.
our @VALID_MEMSIZES = map { 2**$_ } qw(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16);

# The string which collects the sizes from 4 (2**2) MBs to 65536 (2**16) MBs.
# Format the array into a space-padded string.
our $SIZEPATTERNS_STRING = " @VALID_MEMSIZES ";

# The number of KBs in 80 percent of 1 MB.
our $KBS_80PERCENTMB = int( my $volatile = 1024 * 0.8 );

sub parse_vtp
{
	my ( $in, $out ) = @_;
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;
	while ( $in->{running_config} =~ /^ip route\s+(\d+\.\S+)\s+(\d+\.\S+)\s+(\S+)(.*)/mig )
	{
		my $route = {
			destinationAddress => $1,
			destinationMask    => $2,
		};
		my $gateway   = $3;
		my $remainder = $4;

		if ( $gateway =~ /\d+\.\d+\.\d+\.\d+/ )
		{
			$route->{gatewayAddress} = $gateway;
		}
		else
		{
			$route->{interface} = $gateway;
		}

		if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0.0.0.0' ) )
		{
			$route->{defaultGateway} = 'true';
		}
		else
		{
			$route->{defaultGateway} = 'false';
		}

		if (
			( defined $remainder )
			&& (   ( $remainder =~ /^\s*(\d+)\s*$/ )
				|| ( $remainder =~ /^\s*(\d+)\s+.*$/ )
				|| ( $remainder =~ /^\s*\S+\s+(\d+)\s+.*$/ ) )
		  )
		{
			$route->{routePreference} = $1;
		}

		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
	if ( $in->{running_config} =~ /^ip default-gateway\s+(\d+\.\d+\.\d+\.\d+)\s*$/im )
	{
		my $route = {
			destinationAddress => '0.0.0.0',
			destinationMask    => '0.0.0.0',
			gatewayAddress     => $1,
			defaultGateway     => 'true',
		};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}


sub parse_chassis
{
	my ( $in, $out ) = @_;

	my $cpuref;
	my $cpuid           = -1;
	my $description     = "";
	my $systemimagefile = "";
	my $activeslot      = "";
	my $ramMemory;
	my ( $ciscoModel, $serialNumber ) = ( 0, 0 );

	foreach my $line ( split( /\n/, $in->{version} ) )
	{
		if ( $line =~ /CPU\s(\d+)\sis\s(.+?)$/i )
		{
			$cpuid       = 0;
			$description = $2;
		}

		if ( $line =~ /(\d+)\sMbytes of Physical memory/i )
		{
			$ramMemory = $1 * 1000;
		}

		if ( $line =~ /^Manufactured As:\s+(\S+).*/i )
		{
			$ciscoModel = $1;
		}

	}

	# only use the SNMP Chassis ID if it is longer than 5 chars
	if ( $in->{snmp} =~ /^Chassis:\s*(\S{5,})/mi )
	{
		$serialNumber = $1;
	}
	
        if ( $serialNumber == 0 )
        {
                if ($in->{show_inventory} =~ /SN:\s+?(\S+)/mi)
                {
                        $serialNumber = $1;
                }
        }
	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $serialNumber if $serialNumber;
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";
	if ( $in->{version} =~ /^Manufactured As:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	$out->print_element( "core:asset", $chassisAsset );

	# chassis/core:description
	if ( $in->{version} =~ /(Cisco Wide Area .* Software.+Copyright.+?$)/msi )
	{
		$out->print_element( "core:description", $1 );
	}

	my $cpu;
	$cpu->{"core:description"} = $description if $cpuid != -1 and $description;
	$out->print_element( "cpu", $cpu );

	my @memories = ();
	push @memories, { 'core:description' => 'RAM', kind => 'RAM', size => $ramMemory * 1024 } if $ramMemory;


	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{running_config} =~ /^hostname (\S+)/ms;
	$out->print_element( 'core:systemName', $systemName );
	$out->print_element( 'core:deviceType', 'Switch' );
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Cisco' );
	if ( $in->{version} =~ /^(Cisco\sWide\sArea.+?),/m )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{version} =~ /^(?:Cisco )?Wide Area.+Release (\S[^\s,]+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}

	$out->print_element( 'core:osType', 'WAAS' );
	$out->close_element('core:osInfo');

	if ( $in->{version} =~ /Version\s+\:.+?BIOS\sVersion\s+(\d+\.\d+(?:\.\d+)?)/i )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	my ($contact) = $in->{running_config} =~ /^snmp-server contact (.+)/m;
	$out->print_element( 'core:contact', $contact );

	# System restarted at 18:00:01 CST Sun Feb 28 1993
	if ( $in->{version} =~ /system has been up for\s+(.+)/i )
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

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub create_config
{

	# Populates the configuration entity for the main IOS configs
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( _apply_masks( $in->{"running_config"} ) );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{"core:promotable"} = "false";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{"core:name"}       = "startup-config";
	$startup->{"core:textBlob"}   = encode_base64( _apply_masks( $in->{"startup_config"} ) );
	$startup->{"core:mediaType"}  = "text/plain";
	$startup->{"core:context"}    = "boot";
	$startup->{"core:promotable"} = "true";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
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
	while ( $c =~ /^enable\s+(\S+)\s+(level\s)?(\d*)\s?([^\s]+)/mig )
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

sub parse_filters
{
	my ( $in, $out ) = @_;
}


sub parse_access_ports
{
	my ( $in, $out ) = @_;
	my $headerPrinted = 0;
	while ( $in->{running_config} =~ /\bline\s+(vty|aux|con)?\s*(\d+)\s*(\d*)(.+?)(?=^\S)/msig )
	{
		$out->open_element("accessPorts") if ( !$headerPrinted );
		$headerPrinted++;

		my $endInstance = $3;
		my $blob        = $4;
		my $port        = {
			type => ( $1 or "unknown" ),
			startInstance => $2,
		};
		$port->{endInstance} = $endInstance if ($endInstance);

		if ( $blob =~ /^\s+exec-timeout\s+(\d+)\s+(\d+)/mi )
		{
			$port->{inactivityTimeout} = ( $1 * 60 ) + $2;
		}
		if ( $blob =~ /^\s+session-timeout\s+(\d+)\s+(\d+)/mi )
		{
			$port->{sessionTimeout} = ( $1 * 60 ) + $2;
		}
		if ( $blob =~ /^\s+absolute-timeout\s+(\d+)\s+(\d+)/mi )
		{
			$port->{absoluteTimeout} = ( $1 * 60 ) + $2;
		}
		if ( $blob =~ /^\s+transport\s+input\s+(.*\S)\s*$/mi )
		{
			$port->{inboundProtocol} = $1;
		}
		if ( $blob =~ /^\s+transport\s+output\s+(.*\S)\s*$/mi )
		{
			$port->{outboundProtocol} = $1;
		}
		if ( $blob =~ /^\s+access-class\s+(\S+)\s+(in|out)\s*$/mi )
		{
			my $aclname   = $1;
			my $direction = $2;
			if ( $direction =~ /out/i )
			{
				$port->{egressFilter} = $aclname;
			}
			else
			{
				$port->{ingressFilter} = $aclname;
			}
		}

		$out->print_element( "accessPort", $port );
	}
	$out->close_element("accessPorts") if ($headerPrinted);
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $c = $in->{running_config};
	$out->open_element("snmp");

	while ( $c =~ /^(snmp-server\s+community\s+([^\s]+).*)$/mig )
	{
		my $line = $1;
		my $community = { communityString => $2, };
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
	while ( $in->{"running_config"} =~ /^interface\s+(\S+)(.+?)^!/smig )
	{
		my $name      = $1;
		my $blob      = $2;
		my $interface = {
			name          => $name,
			interfaceType => get_interface_type($name),
			physical      => _is_physical($name),
		};

		if ( $blob =~ /^\s*description\s+(.+\b)/mi )
		{
			$interface->{description} = $1;
		}

		# get the ip addresses
		my $order = 1;
		if ( $blob =~ /^\s*ip address\s+(\S+)\s+(\S+)\s*$/mi )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => mask_to_bits($2),
				precedence => $order,
			};
			$order++;
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
		}
		while ( $blob =~ /^\s*ip address\s+(\S+)\s+(\S+)(\ssecondary)/mig )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => mask_to_bits($2),
				precedence => $order,
			};
			$order++;
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
		}
		while ( $blob =~ /^\s*ip helper-address\s+(\S+)/mig )
		{
			push( @{ $interface->{"interfaceIp"}->{"udpForwarder"} }, $1 );
		}
		while ( $blob =~ /^\s*ip access-group\s*\b(.+?)\b\s+(in|out)\s*$/mig )
		{
			my $acl       = $1;
			my $direction = $2;
			if ( $direction eq "out" )
			{
				$interface->{"egressFilter"} = $1;
			}
			elsif ( $direction eq "in" )
			{
				$interface->{"ingressFilter"} = $1;
			}
		}

		# process ethernet properties
		if ( $name =~ /eth/i )
		{
			if ( $blob =~ /^(\s+(half|full|auto).duplex|\s+duplex\s+(\S+))/mi )
			{
				my $duplex;
				$duplex = $2 if defined $2;    # left of the pipe
				$duplex = $3 if defined $3;    # right of the pipe
				if ( ( defined $duplex ) && ( $duplex =~ /auto/i ) )
				{
					$interface->{interfaceEthernet}->{autoDuplex} = "true";
				}
				elsif ( defined $duplex )
				{
					$interface->{interfaceEthernet}->{autoDuplex}        = "false";
					$interface->{interfaceEthernet}->{operationalDuplex} = $duplex;
				}
			}
			elsif ( $blob =~ /^\s+speed\s+\d+/mi )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = "false";
			}
			elsif ( $blob =~ /^\s+speed\s+auto/mi )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = "true";
			}
			elsif ( $blob =~ /^\s+no negotiation/mi )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = "false";
			}
		}

		while ( $blob =~ /^\s+(no\s+ip|ip)\s+(directed.broadcast|local.proxy.arp|redirects|route.cache|mroute.cache)\s*$/mig )
		{
			my $checkneg  = $1;
			my $ipsetting = $2;
			my $bool      = "true";
			$bool = "false" if ( $checkneg eq "no ip" );
			$interface->{interfaceIp}->{directedBroadcast} = $bool
			  if ( $ipsetting =~ /^directed.broadcast$/ );
			$interface->{interfaceIp}->{localProxyARP} = $bool
			  if ( $ipsetting =~ /^local.proxy.arp$/ );
			$interface->{interfaceIp}->{redirects} = $bool
			  if ( $ipsetting =~ /^redirects$/ );
			$interface->{interfaceIp}->{routeCache} = $bool
			  if ( $ipsetting =~ /^route.cache$/ );
			$interface->{interfaceIp}->{mRouteCache} = $bool
			  if ( $ipsetting =~ /^mroute.cache$/ );
		}

		# process this particular interface from "show interfaces"
		if ( $in->{interfaces} =~ /^($name\s.+?)(?=^\S)/msi )
		{
			my $intBlob = $1;
			if ( $intBlob =~ /$name\s+is\s+((up)|(\S+\s+(down))|(down)),/mi )
			{

				# Matching selection
				# $2: .*up
				# $4: .*administratively down
				# $5: .*down, which we will ignore.
				$interface->{adminStatus} = $2 || $4 || 'up';    # Defaults to 'up'.
			}
			if ( $intBlob =~ /address is ([a-f0-9A-F]{4}\.[a-f0-9A-F]{4}\.[a-f0-9A-F]{4})/mi )
			{
				my $macAddress = $1;
				next if ( $interface->{name} !~ /(ethernet|vlan)/i );
				$interface->{interfaceEthernet}->{macAddress} = strip_mac($macAddress);
			}
			if ( $intBlob =~ /MTU\s+(\d+)\s+bytes,\s+BW\s+(\d+)\s+(\S+),/mi )
			{
				my $mtu   = $1;
				my $speed = $2;
				my $units = $3;
				if ( $units =~ /Mb/i ) { $speed = $speed * 1000 * 1000; }
				if ( $units =~ /Kb/i ) { $speed = $speed * 1000; }
				$interface->{speed} = $speed;
				$interface->{mtu}   = $mtu;
			}
			if ( $intBlob =~ /MTU\s+(\d+)\s+bytes,\s+sub\s+MTU\s+\d+,\s+BW\s+(\d+)\s+(\S+),/ )
			{
				my $mtu   = $1;
				my $speed = $2;
				my $units = $3;
				if ( $units =~ /Mbit/i ) { $speed = $speed * 1000; }
				$interface->{speed} = $speed;
				$interface->{mtu}   = $mtu;
			}
			if ( $intBlob =~ /Encapsulation\s([^\s^,]+)/ )
			{
				my $encaps = $1;
				if (   ( defined $interface->{interfaceEthernet} )
					|| ( $interface->{interfaceType} eq "ethernet" ) )
				{
					$interface->{interfaceEthernet}->{encapsulation} = $encaps;
				}
			}
			if ( $intBlob =~ /(Half|Full|Auto)[- ]duplex,\s+(100Mb|10Mb|Auto).+,\s+(media type is |)(\S+)/i )
			{
				my $duplex    = $1;
				my $autospeed = $2;
				my $media     = $4;
				next if ( ( !defined $interface->{interfaceEthernet} )
					&& ( $interface->{interfaceType} ne "ethernet" ) );
				if ( $duplex =~ /half/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = "half";
				}
				elsif ( $duplex =~ /full/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = "full";
				}
				elsif ( $duplex =~ /auto/i )
				{
					$interface->{interfaceEthernet}->{autoDuplex} = "true";
				}
				if ( $autospeed =~ /auto/i )
				{
					$interface->{interfaceEthernet}->{autoSpeed} = "true";
				}
				$interface->{interfaceEthernet}->{mediaType} = $media;
			}
		}

		$out->print_element( "cisco:interface", $interface );
	}
	$out->close_element("interfaces");
}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub _full_int_name
{

	# given a short name like "Fa3/15" return "FastEthernet3/15"
	my $name = trim(shift);
	for ($name)
	{
		s/^Fa(?=\d)/FastEthernet/;
		s/^Eth(?=\d)/Ethernet/;
		s/^Gig(?=\d)/GigabitEthernet/;
	}
	return $name;
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

sub _apply_masks
{

	# remove any trivial pieces of the configuration that
	# may cause improper diffs.

	my $text = shift;
	$text =~ s/\n^ntp clock-period.+$//m;    # remove the variable ntp clock-period line
	return $text;
}

1;

__END__

