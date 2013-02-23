package ZipTie::Adapters::CheckPoint::SecurePlatform::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch mask_to_bits get_port_number trim get_interface_type);
use ZipTie::Adapters::Unix::ParsingUtils;
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_static_routes);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{dmidecode} =~ /(Chassis Information.+?)(?=^\S)/ms )
	{
		my $blob = $1;

		my ($make)     = $blob =~ /Manufacturer:\s*(\b.+\b)/;
		my ($model)    = $blob =~ /Version:\s*(\b.+\b)/;
		my ($serialNo) = $blob =~ /Serial Number:\s*(\b.+\b)/;
		my ($type)     = $blob =~ /Type:\s*(\b.+\b)/;

		$chassisAsset->{'core:factoryinfo'}->{'core:make'}         = $make;
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'}  = $model;
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $serialNo;
	}
	$out->print_element( "core:asset", $chassisAsset );

	while ( $in->{dmesg} =~ /^hd(\S+):\s*\d+\s+sectors\s+\((\d+)\s+([MGK])B\)/mig )
	{
		my $storage = {
			name        => 'hd' . $1,
			storageType => 'disk',
			size        => $2,
		};
		if ( uc($3) eq 'K' )
		{
			$storage->{size} *= 1024;
		}
		elsif ( uc($3) eq 'M' )
		{
			$storage->{size} *= 1024 * 1024;
		}
		if ( uc($3) eq 'G' )
		{
			$storage->{size} *= 1024 * 1024 * 1024;
		}

		# we won't populate FileDirectory node
		$out->print_element( "deviceStorage", $storage );
	}

	if ( $in->{dmesg} =~ /^Memory:\s+\d+k\/(\d+)k/mi )
	{
		my $memory = { 'core:description' => 'RAM', kind => 'RAM', size => ( $1 * 1024 ), };
		$out->print_element( 'memory', $memory );
	}
	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	$in->{hostname} =~ s/hostname\s*//g;
	my ($hostname) = $in->{hostname} =~ /(\S+)/;
	$out->print_element( 'core:systemName', $hostname );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Check Point' );
	my ($version) = $in->{version} =~ /SecurePlatform\s*(\b.+\b)/;
	$out->print_element( 'core:version', $version );
	$out->print_element( 'core:osType',  'SecurePlatform' );
	$out->close_element('core:osInfo');

	if ( $in->{dmidecode} =~ /(BIOS Information.+?)(?=^\S)/ms )
	{
		my $blob = $1;
		my ($biosVersion) = $blob =~ /Version:\s*(\S+)/;
		$out->print_element( 'core:biosVersion', $biosVersion );
	}

	$out->print_element( 'core:deviceType', 'Firewall' );

	my ($contact) = $in->{snmp} =~ /^syscontact\s*(\b.+\b)/m;
	$out->print_element( 'core:contact', $contact );

	ZipTie::Adapters::Unix::ParsingUtils::parse_last_reboot( $in->{uptime}, $out );
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository = { 'core:name' => '/', };
	my $currentFolder = $repository;
	foreach my $dirName ( split /\//, $in->{fwdir} . '/database' )
	{
		if ( length($dirName) )
		{
			my $folder = { 'core:name' => $dirName, };
			push( @{ $currentFolder->{'core:folder'} }, $folder );
			$currentFolder = $folder;
		}
	}

	# for slurping the entire file at once
	my $lineEnding = $/;
	undef $/;   
	my $wholeFile;
	
	open (FILE, $in->{rulesFile});
	$wholeFile = <FILE>;
	close (FILE);
	my $rules = {
		'core:name'       => 'rules.C',
		'core:textBlob'   => encode_base64($wholeFile),
		'core:mediaType'  => 'text/plain',
		'core:context'    => 'active',
		'core:promotable' => 'true',
	};
	
	open (FILE, $in->{objectsFile});
	$wholeFile = <FILE>;
	close (FILE);
	my $objects = {
		'core:name'       => 'objects.C',
		'core:textBlob'   => encode_base64($wholeFile),
		'core:mediaType'  => 'text/plain',
		'core:context'    => 'active',
		'core:promotable' => 'true',
	};
	undef $wholeFile;
	$/ = $lineEnding;

	# push the configuration into the repository
	push( @{ $currentFolder->{'core:config'} }, $rules );
	push( @{ $currentFolder->{'core:config'} }, $objects );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");
	while ($in->{users} =~ /^(\S+)/mg)
	{
		my $name = $1;
		if ($name !~ /showusers|#|@/)
		{
			my $account = { accountName=>$name, accessGroup=>'admin', };
			$out->print_element('localAccount', $account);
		}
	}
	$out->close_element("localAccounts");
	
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	$out->open_element("snmp");
	my @communities = ();
	my @traps       = ();

	# parse communities and trap hosts
	while ( $in->{snmp} =~ /^(.+)$/mig )
	{
		my $commline = $1;
		if ( $commline =~ /^(r[ow])community\S*\s+(\S+)\s+\S+\s*(\S*)$/i )
		{
			push( @communities, { accessType => uc($1), communityString => $2, mibView => $4 } );
		}
		elsif ( $commline =~ /^trapsess.+\-c\s+(\S+)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).+$/i )
		{
			push( @traps, { ipAddress => $2, communityString => $1 } );
		}
	}

	# parse other snmp data and store the configuration
	foreach (@communities)
	{
		$out->print_element( "community", $_ );
	}

	my $someSysPrinted = 0;
	if ( $in->{snmp} =~ /^syscontact\s+"?(\b.+\b)/mi )
	{
		$out->print_element( "sysContact", $1 );
		$someSysPrinted = 1;
	}

	if ( $in->{snmp} =~ /^syslocation\s+"?(\b.+\b)/mi )
	{
		$out->print_element( "sysLocation", $1 );
		$someSysPrinted = 1;
	}

	$in->{hostname} =~ s/hostname\s*//g;
	if ( $in->{hostname} =~ /(\S+)/ )
	{
		$out->print_element( "sysName", $1 );
		$someSysPrinted = 1;
	}

	if ($someSysPrinted)
	{
		foreach (@traps)
		{
			$out->print_element( "trapHosts", $_ );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	# grab all data about static route
	while ( $in->{routes} =~ /([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)/g )
	{
		if (   $1 ne '127.0.0.0'
			&& $1 ne '127.0.0.1' )
		{
			my $route = {
				destinationAddress => $1,
				destinationMask    => mask_to_bits($3),
			};
			$route->{gatewayAddress} = $2;
			$route->{interface}      = $8;
			if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0' ) )
			{
				$route->{defaultGateway} = 'true';
			}
			else
			{
				$route->{defaultGateway} = 'false';
			}
			$route->{routeMetric} = $5;
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element('interfaces');
	while ( $in->{interfaces} =~ /^(\S+)\s+Link(.+?)(?=^\s*$)/msg )
	{
		my $blob      = $2;
		my $interface = {
			name          => $1,
			adminStatus   => 'down',
			interfaceType => get_interface_type($1),
		};
		if ( $blob =~ /^\s*UP/m )
		{
			$interface->{adminStatus} = 'up';
		}
		$interface->{physical} = ( $interface->{interfaceType} eq 'softwareLoopback' ) ? 'false' : 'true';
		( $interface->{mtu} ) = $blob =~ /MTU:(\d+)/;
		if ( $blob =~ /HWaddr\s+([a-z\d:]+)/i )
		{
			my $mac = $1;
			$mac =~ s/://g;
			$interface->{interfaceEthernet}->{macAddress} = $mac;
		}

		while ( $blob =~ /^\s+inet\saddr:(\S+)\s+(.+)/mg )
		{
			my $ipLine = $2;
			my $ipConfiguration = { ipAddress => $1, };
			if ( $ipLine =~ /Mask:(\S+)/i )
			{
				$ipConfiguration->{mask} = mask_to_bits($1);
			}
			if ( $ipLine =~ /Bcast:(\S+)/i )
			{
				$ipConfiguration->{broadcast} = mask_to_bits($1);
			}
			push( @{ $interface->{interfaceIp}->{ipConfiguration} }, $ipConfiguration );
		}
		$out->print_element( 'interface', $interface );
	}
	$out->close_element('interfaces');
}

1;
