package ZipTie::Adapters::Thales::Radio::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type mask_to_bits);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_ntp);

my $LOGGER = ZipTie::Logger::get_logger();

sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}        = "Thales";
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = "ADS-B Radio";
	$out->print_element( "core:asset", $chassisAsset );

	while ( $in->{cpuinfo} =~ /^processor\s*:\s*\d+(.+?)(?=^\s*$)/msg )
	{
		my $body = $1;

		my $cpu = {};
		$cpu->{'core:asset'}->{'core:assetType'} = 'CPU';

		if ( $body =~ /model name\s*:\s*(.+)$/m )
		{
			$cpu->{"core:description"} = trim($1);
		}
		if ( $body =~ /vendor_id\s*:\s*(.+)$/m )
		{
			$cpu->{cpuType} = trim($1);
			$cpu->{'core:asset'}->{'core:factoryinfo'}->{'core:make'} = trim($1);
		}
		if ( $body =~ /model\s*:\s*(.+)$/m )
		{
			$cpu->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = trim($1);
		}
		$out->print_element( "cpu", $cpu );
	}

	if ( $in->{memory} =~ /Mem:\s*(\d+)/ )
	{
		my $mem = 
		{
			kind => 'RAM',
			size => $1 * 1024,
		};
		$out->print_element( "memory", $mem );
	}
	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{hostname} =~ /\bgethostname\(\)=[`"'](\w+)/mi )
	{
		$out->print_element( 'core:systemName', $1 );
	}

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Thales' );

	if ( $in->{version} =~ /(\d+\.\d+\.\d+\S+)/ )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'Linux' );
	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Switch' );
	$out->print_element( 'core:contact',    $in->{snmp}->{sysContact} );

	# 22:26:48  up 107 days,  1:55,  1 user,  load average: 1.00, 1.00, 1.00
	if ( $in->{uptime} =~ /\bup\s+(.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;

		if ( !defined $hours )
		{
			my $temp = $_;
			if ( $temp =~ /(\d+)\:(\d+)/ )
			{
				$hours   = $1;
				$minutes = $2;
			}
		}

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

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository = { 'core:name' => '/', };

	# now push all of the ucs contents as single files into the repository
	_push_configurations( $repository, $in->{unzippedBackup} );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub _push_configurations
{
	my ( $repository, $hashZip ) = @_;
	for my $key ( keys %{$hashZip} )
	{
		$LOGGER->debug("parsing configuration file $key");
		if ( scalar $hashZip->{$key} =~ /^HASH/ )
		{
			my $folder = { 'core:name' => $key, };
			push( @{ $repository->{'core:folder'} }, $folder );
			_push_configurations( $folder, $hashZip->{$key} );
		}
		else
		{
			my $file = {
				'core:name'       => $key,
				'core:textBlob'   => encode_base64( $hashZip->{$key} ),
				'core:mediaType'  => 'text/xml',
				'core:context'    => 'N/A',
				'core:promotable' => 'true',
			};
			push( @{ $repository->{'core:config'} }, $file );
		}
	}

}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");
	while ( ( $in->{passwd} =~ /^(\S+?:\S+?:\S+?:.+)$/mig ) )
	{
		my $line   = $1;
		my @pieces = split( /:/, $line );

		my $startupScript = $pieces[6];
		if ( $startupScript !~ /nologin/ )
		{
			my $account = {
				accountName => $pieces[0],
				accessLevel => $pieces[3],
				fullName    => $pieces[4]
			};
			$out->print_element( "localAccount", $account );
		}
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
	if ( $in->{unzippedBackup}->{etc}->{snmp}->{'snmpd.conf'} )
	{
		my $snmpConf    = $in->{unzippedBackup}->{etc}->{snmp}->{'snmpd.conf'};
		my @communities = ();
		my @traps       = ();

		# parse communities and trap hosts
		while ( $snmpConf =~ /^(.+)$/mig )
		{
			my $commline = $1;
			$LOGGER->debug($commline);
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
		if ( $snmpConf =~ /^syscontact\s+(.+)$/mi )
		{
			$out->print_element( "sysContact", $1 );
			$someSysPrinted = 1;
		}

		if ( $snmpConf =~ /^syslocation\s+(.+)$/mi )
		{
			$out->print_element( "sysLocation", $1 );
			$someSysPrinted = 1;
		}

		$LOGGER->debug( "GOT A HOSTNAME\n" . $in->{hostname} );
		if ( $in->{hostname} =~ /\bgethostname\(\)=[`"'](\w+)/mi )
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
	}
	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	while ( $in->{static_routes} =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|default)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).+(\b\S+\b)/mig )
	{
		my $defaultGw = 'false';
		my $destIP    = $1;
		my $destMask  = '32';
		my $gateway   = $2;
		my $iface     = $3;

		if ( lc($destIP) eq 'default' )
		{
			$defaultGw = 'true';
			$destIP    = '0.0.0.0';
		}

		my $route = {
			defaultGateway     => $defaultGw,
			destinationAddress => $destIP,
			destinationMask    => $destMask,
			gatewayAddress     => $gateway,
			interface          => $iface
		};

		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $interfaces = {};
	$interfaces->{interface} = ();
	while ( $in->{'ifconfig'} =~ /^(\S+)\s*(Link.*?)(?=^\S)/msg )
	{
		my $ifName = $1;
		my $body   = $2;

		my $interface = { name => $ifName, };

		if ( $body =~ /HWaddr\s+(\S+)/ )
		{
			my $mac = $1;
			$mac =~ s/://g;
			$interface->{interfaceEthernet}->{macAddress} = $mac;
		}

		$interface->{adminStatus}   = ( $body =~ /\bUP\b/i )              ? 'up'               : 'down';
		$interface->{physical}      = ( $body =~ /loopback/i )            ? 'false'            : 'true';
		$interface->{interfaceType} = ( $body =~ /link encap:\s*local/i ) ? 'softwareLoopback' : 'ethernet';

		my $ip4Configuration = {};
		if ( $body =~ /inet\s+addr:\s*([\d\.]+)/i )
		{
			$ip4Configuration->{ipAddress} = $1;
		}
		if ( $body =~ /Mask:\s*([\d\.]+)/i )
		{
			$ip4Configuration->{mask} = mask_to_bits($1);
		}
		push( @{ $interface->{interfaceIp}->{ipConfiguration} }, $ip4Configuration );

		if ( $body =~ /inet6 addr:\s*([a-f\d:]+)\/(\d+)/i )
		{
			my $ip6Configuration = {
				ipAddress => $1,
				mask      => $2,
			};
			push( @{ $interface->{interfaceIp}->{ipConfiguration} }, $ip6Configuration );
		}

		push( @{ $interfaces->{interface} }, $interface );
	}
	$out->print_element( 'interfaces', $interfaces );
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

sub parse_ntp
{
	my ( $in, $out ) = @_;
	my $ntp;
	while ( $in->{ntp} =~ /server\s+(\S+)/mig )
	{
		$ntp->{enabled} = 'true';

		my $server;
		$server->{mode}            = 'server';
		$server->{serverIPaddress} = $1;
		$server->{protocolVersion} = {
			protocol => 'NTP',
			version  => '4',
		};
		push( @{ $ntp->{'server'} }, $server );
	}

	my $services = { ntp => $ntp, };

	$out->print_element( 'services', $services ) if ($ntp);
}

1;
