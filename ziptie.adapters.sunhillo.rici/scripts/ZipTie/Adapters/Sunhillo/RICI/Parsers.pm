package ZipTie::Adapters::Sunhillo::RICI::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';
my $LOGGER = ZipTie::Logger::get_logger();

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_ntp parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	my $chassis;
	$chassis->{'core:asset'}->{'core:assetType'}                         = 'Chassis';
	$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = 'Sunhillo';
	$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = 'RICI';
	if ( $in->{'version'} =~ /Serial\s*\#:\s*(\S+)/mi )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassis->{'core:description'} = 'Real Time Interface and Conversion Item';

	if ( $in->{'version'} =~ /MAC\s*Address:\s*(\S+)/mi )
	{
		my $mac = $1;
		$mac =~ s/://g;
		$chassis->{'macAddress'} = $mac;
	}

	my $cpu;
	$cpu->{'core:asset'}->{'core:assetType'} = 'CPU';
	$cpu->{'core:asset'}->{'core:factoryinfo'}->{'core:make'} = $1 if ( $in->{cpuinfo} =~ /cpu\s*:\s*(\S+)/ );
	$cpu->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = $1
	  if ( $in->{cpuinfo} =~ /cpu\s+model\s*:\s*(\b.+\b)/ );
	$cpu->{'core:asset'}->{'core:factoryinfo'}->{'core:revisionNumber'} = $1
	  if ( $in->{cpuinfo} =~ /cpu\s+revision\s*:\s*(\S+)/ );
	$chassis->{'cpu'} = $cpu;

	my $mem;
	$mem->{'kind'}       = 'RAM';
	$mem->{'size'}       = $1 if ( $in->{dmesg} =~ /Memory:\s*\d+k\/(\d+)/ );
	$chassis->{'memory'} = $mem;

	$out->print_element( "chassis", $chassis );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	$out->print_element( 'core:systemName', $in->{snmp}->{sysName} );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Sunhillo' );
	if ( $in->{'version'} =~ /Application\s*Version:\s*(\b.+\b)/mi )
	{
		$out->print_element( 'core:version', $1 );
		$out->print_element( 'core:osType',  'RICI' );
	}
	$out->close_element('core:osInfo');
	if ( $in->{'version'} =~ /Board\s*Revision:\s*(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );
	$out->print_element( 'core:contact',    $in->{snmp}->{sysContact} );
	if ( defined $in->{uptime} )
	{
		my $now = time();
		my $lastReboot = $now - ( $in->{uptime} / 100 );
		$out->print_element( 'core:lastReboot', int($lastReboot) );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository = { 'core:name' => '/', };

	# now push all of the ucs contents as single files into the repository
	_push_configurations( $repository, $in->{unzippedBackup}, $in->{'activeConfig'} );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub _push_configurations
{
	my ( $repository, $hashZip, $activeConfigName ) = @_;
	for my $key ( keys %{$hashZip} )
	{
		if ( scalar $hashZip->{$key} =~ /^HASH/ )
		{
			my $folder = { 'core:name' => $key, };
			push( @{ $repository->{'core:folder'} }, $folder );
			_push_configurations( $folder, $hashZip->{$key}, $activeConfigName );
		}
		else
		{
			my $context = ( $activeConfigName eq $key ) ? 'active' : 'N/A';
			my $file = {
				'core:name'       => $key,
				'core:textBlob'   => encode_base64( $hashZip->{$key} ),
				'core:mediaType'  => 'text/xml',
				'core:context'    => $context,
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
	while ( ( $in->{passwd} =~ /^([^\s:]+):([^:]+):(\d+):(\d+):([^:]+):([^:]+):([^:]+)$/mig ) )
	{
		my $account = {
			accountName => $1,
			accessLevel => $4,
			password    => $2,
			fullName    => $5
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
	while ( $in->{snmpd} =~ /^(r[ow])community\s+(\S+)/mig )
	{
		push( @{ $in->{snmp}->{community} }, { accessType => uc($1), communityString => $2 } );
	}
	$out->print_element( 'snmp', $in->{snmp} );
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
		push( @{ $ntp->{'server'} }, $server );
	}

	my $services = { ntp => $ntp, };

	$out->print_element( 'services', $services ) if ($ntp);
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	while ( $in->{static_routes} =~
		/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|default)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).+(\b\S+\b)/mig )
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
	while ( $in->{activeConfigContents} =~ /<RADARIN\s*(.+?)<\/RADARIN>/sgi )
	{
		my $block     = $1;
		$LOGGER->debug($block);
		my $interface = {
			physical      => 'true',
			interfaceType => 'serial',
		};

		if ( $block =~ /PORT_TYPE="(.+?)"/i )
		{
			$interface->{description} = $1;
		}
		if ( $block =~ /BAUD_RATE="\S+_(\d+?)"/i )
		{
			$interface->{speed} = $1;
		}
		if ( $block =~ /SERIAL_PORT_NAME="(.+?)"/i )
		{
			$interface->{name} = $1;
		}

		push( @{ $in->{interfaces}->{interface} }, $interface );

	}
	$out->print_element( 'interfaces', $in->{interfaces} );
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
