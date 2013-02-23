package ZipTie::Adapters::APC::SmartUPS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(parse_routing create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_static_routes);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;

	$chassis->{'core:asset'}->{'core:assetType'} = 'Chassis';

	$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:make'} = 'APC';
	if ( $in->{system} =~ /Model Number\s*:\s*(\S+)/ )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ( $in->{system} =~ /Serial Number\s*:\s*(\S+)/ )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	if ( $in->{system} =~ /Hardware Revision\s*:\s*(\S+)/ )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	if ( $in->{system} =~ /MAC Address\s*:\s*(.+)/ )
	{
		my $mac = $1;
		$mac =~ s/\s+//g;
		$chassis->{'macAddress'} = $mac;
	}
	$out->print_element( "chassis", $chassis );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	$out->print_element( 'core:systemName', $in->{snmp}->{sysName} );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'APC' );
	if ( $in->{mainmenu} =~ /Card AOS\s+v(\d+\.\d+\.?\d*)/ )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'UPS' );
	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Power Supply' );
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
	my $repository;
	$repository->{'core:name'} = '/';

	# build the simple text configuration
	my $config;
	$config->{'core:name'}       = 'config.ini';
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
	if ( $in->{config} =~ /\[SystemUserManager\](.+?)(?=^\[)/ms )
	{
		my $blob = $1;
		$out->open_element('localAccounts');
		while ( $blob =~ /^(\S+)UserName=(\b.+\b)/mg )
		{
			my $newAccount = {
				accountName => $2,
				accessGroup => $1,
			};
			$out->print_element( 'localAccount', $newAccount );
		}
		$out->close_element('localAccounts');
	}
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = $in->{snmp};

	# add community strings
	while ( $in->{config} =~ /^AccessControl(\d+)Community=(\S+)/mg )
	{
		my $number          = $1;
		my $community       = { communityString => $2, };
		my $accessTypeRegex = 'AccessControl' . $number . 'AccessType';

		if ( $in->{config} =~ /^$accessTypeRegex=(\S+)/m )
		{
			my $accessType = $1;
			if ( $accessType =~ /Read/i )
			{
				$community->{accessType} = 'RO';
			}
			elsif ( $accessType =~ /Write/i )
			{
				$community->{accessType} = 'RW';
			}

			if ( $accessType !~ /Disabled/i )
			{
				push( @{ $snmp->{community} }, $community );
			}
		}
	}

	# add trap hosts
	while ( $in->{config} =~ /^TrapReceiver(\d+)Community=(\S+)/mg )
	{
		my $number   = $1;
		my $trapHost = { communityString => $2, };
		my $nmsRegex = 'TrapReceiver' . $number . 'NMS';

		if ( $in->{config} =~ /^$nmsRegex=(\S+)/m )
		{
			$trapHost->{ipAddress} = $1;    
			push( @{ $snmp->{trapHosts} }, $trapHost );
		}
	}

	$out->print_element( 'snmp', $snmp );
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	if ( $in->{config} =~ /^DefaultGateway=(\S+)/m )
	{
		$out->open_element('staticRoutes');
		my $defaultRoute = {
			defaultGateway     => 'true',
			destinationAddress => '0.0.0.0',
			destinationMask    => '0',
			gatewayAddress     => $1,
			interface          => 'Unknown',
		};
		$out->print_element( 'staticRoute', $defaultRoute );
		$out->close_element('staticRoutes');
	}
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->print_element( 'interfaces', $in->{interfaces} );
}

1;
