package ZipTie::Adapters::Adtran::NetVanta::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask strip_mac get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw( create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_static_routes parse_stp);

# Common ip/mask regular expression
our $CIPM_RE = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
our $MAC     = '[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}';

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };

	# get model/serial part
	if ( $in->{version} =~ /Serial\s+number\s+([^\s\,]+)\s*$/mig )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Adtran";
	if ( $in->{version} =~ /\bPlatform:\s+([^,]+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	$out->print_element( "core:asset", $chassisAsset );
	if ( $in->{version} =~ /^(OS version.+\nChecksum.+\nUpgrade[^\n]+)/mis )
	{
		$out->print_element( 'core:description', $1 );
	}

	_parse_file_storage( $in, $out );

	$out->close_element("chassis");
}

sub _parse_file_storage
{

	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;
	return if ( !defined $in->{files} );

	if ( $in->{files} !~ /^% Unrecognized/mi )
	{
		my $storage = {};
		$storage->{name}        = 'unknown';
		$storage->{storageType} = 'flash';

		$storage->{rootDir} = { name => "root", };

		while ( $in->{files} =~ /^\s*(\d+)\s+(\S+)\s*$/mig )
		{
			my $file = {
				size => $1,
				name => $2,
			};
			push( @{ $storage->{rootDir}->{file} }, $file );
		}

		if ( $in->{files} =~ /^\s*\d+\s+bytes\s+used,\s+(\d+)\s+available,\s+(\d+)\s+total\s*$/migc )
		{
			$storage->{size}      = $2;
			$storage->{freeSpace} = $1;
		}
		$out->print_element( "deviceStorage", $storage );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{config} =~ /^hostname\s*\"(\S+)\"/mi;
	$out->print_element( 'core:systemName', "$systemName" );

	$out->open_element('core:osInfo');
	if ( $in->{version} =~ /system image file is "([^"]+)/m )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Adtran' );
	if ( $in->{version} =~ /OS version\s+(\S+)\s*$/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'AOS' );
	$out->close_element('core:osInfo');

	if ( $in->{version} =~ /Boot ROM\s+Version\s+([^\s,]+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Router' );

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
	elsif ( $in->{version} =~ /uptime is\s+(.+)/i )
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
	$out->print_element( 'core:configRepository', $repository );
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;

	$out->open_element("localAccounts");

	if ( $in->{config} =~ /^\s*enable password\s+(.*)$/mi )
	{
		$out->print_element( "localAccount", { accountName => 'enable', password => $1 } );
	}
	else
	{
		$out->print_element( "localAccount", { accountName => 'enable', password => "unknown" } );
	}

	my ($acc_blob) = $in->{config} =~ /^!\s*(username[^!]+)/mis;

	#print "local accounts:\n $acc_blob\n";

	while ( $acc_blob =~ /^username\s+\"(\w+)\"(?:\s+password\s+\"([^\"]+)\")?$/migc )
	{
		$out->print_element( "localAccount", { accountName => $1, password => $2 } );
	}

	$out->close_element("localAccounts");
}

sub parse_snmp
{
	my ( $in, $out ) = @_;

	#print "config: \n$in->{config}\n";
	my ($snmp_blob) = $in->{config} =~ /^\s*(snmp-server.+)\nline/migs;
	my $name        = undef;
	my $location    = undef;
	my $domain      = undef;

	$out->open_element("snmp");

	#print "snmp blob:\n $snmp_blob\n";
	if ( $snmp_blob =~ /^snmp-server\s+location\s+\"(\S+)\"/migc )
	{
		$location = $1;
	}

	while ( $snmp_blob =~ /^snmp-server community\s+(\w+)\s+(RO|RW)\s*$/migc )
	{
		$out->print_element( "community", { communityString => $1, accessType => uc($2) } );
	}

	if ( $in->{config} =~ /^hostname \"(\S+)\"/migc )
	{
		$name = $1;
	}

	if ( $in->{config} =~ /^ip domain-name (\S+)/migc )
	{
		$domain = $1;
	}

	if ($location)
	{
		$out->print_element( "sysLocation", $location );
	}
	if ($name)
	{
		if ($domain)
		{
			$out->print_element( "sysName", "$name.$domain" );
		}
		else
		{
			$out->print_element( "sysName", $name );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	#my $primaryGateway;
	#if ($static_routes_pieces[1] =~ /\bprimary\s+gateway:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/)
	#{
	#	$primaryGateway = $1;
	#}

	while ( $in->{static_routes} =~ /^\S+\s+($CIPM_RE)\/(\d+)\s+\[\d+\/(\d+)\]\s+via\s+($CIPM_RE),\s+(.+)$/mig )
	{

		#set ip route destination[/netmask] gateway metric
		my $route = {
			destinationAddress => $1,
			#destinationMask    => get_mask($2),
			destinationMask    => $2,
			gatewayAddress     => $4,
			routeMetric        => $3,             
			interface          => $5
		};
		if ( !defined $route->{destinationMask} )
		{
			#$route->{destinationMask} = '255.255.255.255';
			$route->{destinationMask} = '32';
		}

		if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0' ) )
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

sub parse_interfaces
{
	my ( $in, $out ) = @_;

	my $name;
	my $macAddr;
	my $ip;
	my $mtu;
	my $mask;
	my $status;

	$out->open_element("interfaces");

	while ( $in->{interfaces} =~ /^(\S.+?)(?=\n\S)/misgc )
	{
		my $blob = $1;

		#we will only parse ethernet interfaces, the other types do no have all necessary info
		if ( $blob =~
			/^\s*(eth\s*\S+)\s+is\s+(\w+), .*Hardware address is ($MAC).*Ip address is ($CIPM_RE), netmask is ($CIPM_RE).*MTU\s+is\s+(\d+)\sbytes,.*$/migocs )
		{
			my $interface = {
				name          => $1,
				adminStatus   => lc($2),
				interfaceType => "unknown",
				physical      => "true",
				mtu           => $6
			};

			$interface->{interfaceEthernet}->{macAddress}             = strip_mac($3);
			$interface->{interfaceIp}->{ipConfiguration}->{ipAddress} = $4;
			$interface->{interfaceIp}->{ipConfiguration}->{mask}      = mask_to_bits($5);
			$out->print_element( "interface", $interface );
		}
	}

	$out->close_element("interfaces");

}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

1;
