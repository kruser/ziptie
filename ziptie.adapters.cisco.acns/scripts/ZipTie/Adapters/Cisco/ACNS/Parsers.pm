package ZipTie::Adapters::Cisco::ACNS::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(parse_system parse_chassis create_config parse_access_ports parse_filters parse_interfaces parse_local_accounts parse_routing parse_snmp parse_stp parse_static_routes parse_vlans parse_vlan_trunking);

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{running_config} =~ /^hostname (\S+)/ms;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Cisco' );
	if ( $in->{hardware} =~ /^Application\sand\sContent\sNetworking\sSystem\sSoftware/m )
	{
		$out->print_element( 'core:name', "Application and Content Networking System Software (ACNS)" );
	}
	if ( $in->{hardware} =~ /^Application\sand\sContent\sNetworking\sSystem\sSoftware\sRelease\s(\d+\.\d+\.\d+)\s\(build\sb(\d+)\s/mi )
	{
		$out->print_element( 'core:version', "$1.$2" );
	}
	$out->print_element( 'core:osType', 'ACNS' );
	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Content Engine' );

	if ( $in->{hardware} =~ /Version\s+\:.+?BIOS\sVersion\s+(\d+\.\d+(?:\.\d+)?)/i )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	my ($contact) = $in->{running_config} =~ /^snmp-server contact (.+)/m;
	$out->print_element( 'core:contact', $contact );

	# System restarted at 18:00:01 CST Sun Feb 28 1993
	if ( $in->{hardware} =~ /system has been up for\s+(.+)/i )
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

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	#firmware version
	#fruPartNumber
	if ( $in->{hardware} =~ /HWVersion:\s(\d+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";
	if ( $in->{hardware} =~ /^Manufactured As:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{hardware} =~ /ModelNum \(text\):\s+(\S+)/)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	#partNumber
	#rmaNumber
	if ($in->{hardware} =~ /SerialNumber:\s(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	#revisionNumber
	$out->print_element( "core:asset", $chassisAsset );

	#description
	if ( $in->{hardware} =~ /(Application and Content Networking .*(\n)?Copyright.+?$)/msi )
	{
		my $desc = $1;
		$desc =~ s/\n/ /ig;

		$out->print_element( "core:description", $desc );
	}

	#cards

	#cpus
	while ( $in->{hardware} =~ /CPU\s(\d+)\sis\s(.+?)$/mig )
	{
		my $cpu;

		$cpu->{"core:description"} = $2;

		$out->print_element( "cpu", $cpu );
	}

	#flash and disks
	my @storage = ();
	if ( $in->{flash} =~ /(\d+) sectors total, (\d+) sectors free./mi )
	{
		my $asset;

		$asset->{name}        = "flash";
		$asset->{storageType} = "flash";
		$asset->{size}        = $1 * 128 * 1024; #128k per sector
		$asset->{freeSpace}   = $2 * 128 * 1024;

		$out->print_element( "deviceStorage", $asset );
	}
	while ( $in->{disk} =~ /(disk\d\d): .+ (\d+)MB.+\n(\s+.+\n)*/mig )
	{
		my $name = $1;
		my $size = $2 * 1024 * 1024;
		my $blob = $3;
		my $free = -1;

		if ( $blob =~ /FREE:\s+(\d+)MB/mi )
		{
			$free = $1 * 1024 * 1024;
		}

		my $asset;
		$asset->{name}        = $name;
		$asset->{storageType} = "disk";
		$asset->{size}        = $size;
		$asset->{freeSpace}   = $free if ( $free != -1 );

		$out->print_element( "deviceStorage", $asset );
	}

	#memories
	if ( $in->{hardware} =~ /(\d+)\sMbytes of Physical memory/mi )
	{
		my $memValue = $1 * 1024 * 1024;

		my $memory;
		$memory->{'core:description'} = "RAM";
		$memory->{kind} = "RAM";
		$memory->{size} = $memValue;

		$out->print_element( "memory", $memory );
	}

	#power supplies

	$out->close_element("chassis");
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( $in->{"running_config"} );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{"core:promotable"} = "false";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{"core:name"}       = "startup-config";
	$startup->{"core:textBlob"}   = encode_base64( $in->{"startup_config"} );
	$startup->{"core:mediaType"}  = "text/plain";
	$startup->{"core:context"}    = "boot";
	$startup->{"core:promotable"} = "true";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
}

sub parse_access_ports
{
	my ( $in, $out ) = @_;
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $subnets = {};    # will be returned to the caller

	$out->open_element("interfaces");
	while ( $in->{"running_config"} =~ /^interface\s+(\S+)\s(\S+)\n((?:\s+.+\n)*)/mig )
	{
		my $name      = $1;
		my $number    = $2;
		my $blob      = $3;

		my $interface = {
			name          => "$name$number",
			interfaceType => get_interface_type($name),
			physical      => _is_physical($name),
		};

		if ( $blob =~ /^\s*description\s+(.+\b)/mi )
		{
			$interface->{description} = $1;
		}

		# get the ip address
		if ( $blob =~ /^\s*ip address\s+(\S+)\s+(\S+)\s*$/mi )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => mask_to_bits($2),
			};
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
			my $subnet = new ZipTie::Addressing::Subnet( $ipConfiguration->{ipAddress}, $ipConfiguration->{mask} );
			push( @{ $subnets->{$name.$number} }, $subnet );
		}

		# process ethernet properties
		if ( $blob =~ /no autosense/mi )
		{
			$interface->{interfaceEthernet}->{autoDuplex} = "false";
			$interface->{interfaceEthernet}->{autoSpeed}  = "false";

			if ( $blob =~ /bandwidth\s(\d+)/mi )
			{
				$interface->{speed} = $1 * 1024 * 1024;
			}
			if ( $blob =~ /(half|full)-duplex/mi )
			{
				#$interface->{interfaceEthernet}->{operationalDuplex} = $1;
			}
		}
		else
		{
			$interface->{interfaceEthernet}->{autoDuplex} = "true";
			$interface->{interfaceEthernet}->{autoSpeed}  = "true";
		}

		my $state = 'up';
		$state = 'down' if ($blob =~ /shutdown/);
		$interface->{adminStatus} = $state;			

		my $showBlob = $in->{interfaces}->{"$name$number"};

		if ( $showBlob =~ /Ethernet address:\s*(\S+)/mi )
		{
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($1);
		}

		if ( $showBlob =~ /Maximum Transfer Unit Size:(\d+)/mi )
		{
			$interface->{mtu}   = $1;
		}

		if ( $showBlob =~ /Mode:autoselect,(?: (full|half)-duplex,)?(?: (\d+)baseTX)?/mi )
		{
			my $first = $1;
			my $second = $2;

			if ( $first =~ /full|half/mi )
			{
				$interface->{interfaceEthernet}->{operationalDuplex} = $first;

				if ( $second =~ /\d+/mi )
				{
					$interface->{speed} = $second * 1024 * 1024;
				}
			}
			elsif ( $first =~ /\d+/mi )
			{
				$interface->{speed} = $first * 1024 * 1024;
			}
		}

		$out->print_element( "cisco:interface", $interface );

	}
	$out->close_element("interfaces");

	return $subnets;
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;

	$out->open_element("localAccounts");

	while ( $in->{running_config} =~ /^username\s+(\S+)\s+password\s+\d\s+(\S+)/mig )
	{
		my $name = $1;
		my $password = $2;

		my $account = { accountName => $name, password => $password, };

		if ( $in->{running_config} =~ /username\s+$name\s+privilege\s+(\d+)/mi )
		{
			$account->{accessLevel} = $1;
		}

		$out->print_element( "localAccount", $account );
	}

	$out->close_element("localAccounts");
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;

	$out->open_element("snmp");

	while ( $in->{running_config} =~ /^snmp-server\s+community\s+(\S+)(?:\s+(rw))?$/mig )
	{
		my $community;
		$community->{communityString} = $1;
		$community->{accessType} = 'RO';

		$community->{accessType} = 'RW' if ( $2 eq 'rw' );

		$out->print_element( "community", $community );
	}

	if ( $in->{running_config} =~ /^snmp-server\s+contact\s+(\S+)\s*$/mi )
	{
		$out->print_element( "sysContact", $1 );
	}

	if ( $in->{running_config} =~ /^snmp-server\s+location\s+(\S+)\s*$/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}

	if ( $in->{running_config} =~ /^hostname\s+(\S+)/mi )
	{
		$out->print_element( "sysName", $1 );
	}

	$out->close_element("snmp");
}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;

	my $routes;

	while ( $in->{running_config} =~ /ip\sroute\s(\d+\.\d+\.\d+\.\d+)\s(\d+\.\d+\.\d+\.\d+)\s(\d+\.\d+\.\d+\.\d+)/mig )
	{
		my $dest = $1;
		my $mask = $2;
		my $gate = $3;

		my $route = {
			destinationAddress	=> $dest,
			destinationMask		=> mask_to_bits ( $mask ),
			gatewayAddress		=> $3,
			defaultGateway		=> 'false',
			interface		    => _pick_subnet( $3, $subnets ),
		};

		if ( ( $dest eq '0.0.0.0' ) && ( $mask eq '0.0.0.0' ) )
		{
			$route->{defaultGateway} = 'true';
		}

		push( @{ $routes->{staticRoute} }, $route );
	}

	if ( $in->{running_config} =~ /ip\sdefault-gateway\s(\d+\.\d+\.\d+\.\d+)/mi )
	{
		my $route = {
			destinationAddress => '0.0.0.0',
			destinationMask    => '0',
			gatewayAddress     => $1,
			defaultGateway     => 'true',
			interface		   => _pick_subnet( $1, $subnets ),
		};

		push( @{ $routes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $routes ) if ( defined $routes );
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

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_vlan_trunking
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

1;
