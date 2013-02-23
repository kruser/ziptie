package ZipTie::Adapters::Nortel::Tiara::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number get_crep trim get_interface_type getUnitFreeNumber);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;

	$chassis->{'core:asset'}->{'core:assetType'} = 'Chassis';
	
	my ($ram_size, $ram_units) = $in->{system} =~ /^\s*DRAM quantity:\s*(\d+)(\w+).*$/migc;
	my ($ram_type) = $in->{system} =~ /^\s*DRAM type:\s+(\w+).*$/migc;
	my ($flash_size, $flash_units) = $in->{system} =~ /^\s*Flash:\s*(\d+)(\w+).*$/migc;
	my ($model) = $in->{system} =~ /^\s*Model Number:\s+(\d+).*$/migc;
	my ($serial) = $in->{system} =~ /^\s*Serial Number:\s*(\S+).*?$/migc;
	
	$ram_size = getUnitFreeNumber($ram_size, $ram_units);
	$flash_size = getUnitFreeNumber($flash_size, $flash_units);
	
	$out->open_element("chassis");
	$out->open_element("core:asset");
	$out->print_element('core:assetType','Chassis');
	
	$out->open_element('core:factoryinfo');
	$out->print_element('core:make','Tasman');
	$out->print_element('core:modelNumber', $model);
	$out->print_element('core:serialNumber', $serial);
	$out->close_element('core:factoryinfo');
	$out->close_element("core:asset");
	
	#Parse device storage
	my ($name) = $in->{files} =~ /CONTENTS OF\s*(\S+):/migc;
	my ($size) = $in->{files} =~ /Total bytes:\s*(\d+).*$/migc;
	my ($free) = $in->{files} =~ /Bytes Free on\s+\S+:\s*(\d+).*$/migc;
	$out->open_element("deviceStorage");
	$out->print_element("name", $name);
	$out->print_element("storageType", "flash");
	$out->print_element("size", $size);
	$out->print_element("freeSpace", $free);
	
	#We need this hash, the one in Utils.pm doesn't work for this date.
	my %months = (
		JAN => '01',
		FEB => '02',
		MAR => '03',
		APR => '04',
		MAY => '05',
		JUN => '06',
		JUL => '07',
		AUG => '08',
		SEP => '09',
		OCT => '10',
		NOV => '11',
		DEC => '12',
	);
	
	$out->open_element("rootDir");
	pos ($in->{files}) = 0; #Reset \G to 0, we need to start over!
	while ($in->{files}=~ /^\s*(\d+)\s+(\w{3})-(\d{2})-(\d{4})\s+([\d:]+)\s+(\S+).*$/mig)
	{
		my ($fsize, $month, $day, $year, $time, $fname) = ($1,$2,$3,$4,$5,$6);
		#The month is supposed to be uppercase, but we force it just in case.
		my $date = "$year-".$months{uc($month)}."-$day"."T$time";
		$out->open_element("file");
		$out->print_element("mtime", $date);
		$out->print_element("name", $fname);
		$out->print_element("size", $fsize);
		$out->close_element("file");
	}
	$out->print_element("name", "root");
	$out->close_element("rootDir");
	$out->close_element("deviceStorage");
	
	#Print our the previously parsed memories
	$out->print_element( "memory", { kind => "RAM", size => $ram_size });
	$out->print_element( "memory", { kind => 'Flash', size => $flash_size });
		
	$out->close_element( "chassis");
	
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($version) =$in->{version} =~ /NCM SW VERSION\s+:\s+(r\d+\.\d+\.\d+)/mig;
	
	$out->print_element( 'core:systemName', $in->{snmp}->{sysName} );
	
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make',    'Tasman' );
	$out->print_element( 'core:version', $version );
	$out->print_element( 'core:osType',  'TiOS' );
	$out->close_element('core:osInfo');
		
	$out->print_element( 'core:deviceType', 'Router' );
	$out->print_element( 'core:contact',    $in->{snmp}->{sysContact} );
	
	if (defined $in->{uptime})
	{
		my $now = time();
		my $lastReboot = $now - ($in->{uptime} / 100);
		$out->print_element('core:lastReboot', int($lastReboot));
	}
	else
	{
		$out->print_element('core:lastReboot', 0);
	}
}

sub create_config
{

	# Populates the configuration entity for the main ProCurve configs
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( $in->{"runningConfig"} );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{"core:promotable"} = "false";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{"core:name"}       = "startup-config";
	$startup->{"core:textBlob"}   = encode_base64( $in->{"startupConfig"} );
	$startup->{"core:mediaType"}  = "text/plain";
	$startup->{"core:context"}    = "boot";
	$startup->{"core:promotable"} = "true";                                                     

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
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
	
	#Move \G
	$in->{runningConfig} =~ /snmp-server/mig;
	while ($in->{runningConfig} =~ /^\s*community\s+(\w+)\s+(\w+).*$/migc)
	{
		$out->print_element( "community", { communityString => $1, accessType => uc($2) } );
	}
	
	foreach (sort(keys %{$in->{snmp}}))
	{
		$out->print_element( $_, $in->{snmp}->{$_});
	}
	
	$out->close_element('snmp');
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	
	my $ip_re = get_crep('cipm');
	my $staticRoutes;
	
	while ($in->{routes} =~ /^\s*S\s+($ip_re)\/(\d+)\s+($ip_re)\s+(\S+)\s+(\d+)\s+(\d+).*$/mig)
	{
		#my $mask = get_mask($2);
		my $route = {
			destinationAddress => $1,
			destinationMask    => $2,
			gatewayAddress     => $3,
			routeMetric 			 => $6,
			interface          => $4,
			routePreference 	 => $5
		};

		if ( !defined $route->{destinationMask} )
		{
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
	$out->print_element('interfaces', $in->{interfaces});
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

1;
