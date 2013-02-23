package ZipTie::Adapters::Argus::Cordex::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;

	$out->open_element('chassis');

	my $chassisAsset = {};
	$chassisAsset->{'core:assetType'}                         = 'Chassis';
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}        = 'Argus';
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = 'Cordex';

	if ( $in->{'system_info'} =~ /System_Serial:\s*\'(.+?)\'/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$out->print_element( 'core:asset', $chassisAsset );

	while ( $in->{'cards'} =~ /<devices\s+(.+?)<\/devices>/mig )
	{

		#<Devices A="CXRC 48-650W" B="1.03" E="N507436/0509"></Devices>
		my $data = $1;
		my $card = {};
		$card->{"core:asset"}->{"core:assetType"} = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"} = "Argus";

		if ( $data =~ /E=\"(\S+?)\"/ )
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $1;
		}
		if ( $data =~ /B=\"(\S+?)\"/ )
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = $1;
		}
		if ( $data =~ /A=\"(.+?)\"/ )
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = $1;
		}
		$out->print_element( 'card', $card );
	}

	if ( $in->{'factory_info'} =~ /MAC_Address:\s*\'(\S+?)\'/i )
	{
		$out->print_element( 'macAddress', $1 );
	}
	$out->close_element('chassis');
}

sub parse_system
{
	my ( $in, $out ) = @_;
	if ( defined( $in->{snmp} ) && $in->{snmp}->{sysName} )
	{
		$out->print_element( 'core:systemName', $in->{snmp}->{sysName} );
	}
	elsif ( $in->{'system_info'} =~ /Site_Name:\s*\'(.+?)\'/ )
	{
		$out->print_element( 'core:systemName', $1 );
	}

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Argus' );

	if ( $in->{'system_info'} =~ /System_Version:\s*\'(.+?)\'/ )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'TBD' );
	$out->close_element('core:osInfo');

	if ( $in->{'factory_info'} =~ /Motherboard_Rev:\s*\'(\S+?)\'/i )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

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
	$config->{'core:name'}       = 'config';
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
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = ( defined $in->{snmp} ? $in->{snmp} : {} );
	while ( $in->{'snmp_users'} =~ /Community_read\d+:\s*\'(\w+?)\'/mg )
	{
		my $communityString = {
			communityString  => $1,
			accessType => 'RO',
		};
		if (!$snmp->{'community'})
		{
			$snmp->{'community'} = ();	
		}
		push( @{ $snmp->{'community'} }, $communityString);
	}
	
	while ( $in->{'snmp_users'} =~ /Community_write\d+:\s*\'(\w+?)\'/mg )
	{
		my $communityString = {
			communityString  => $1,
			accessType => 'RW',
		};
		if (!$snmp->{'community'})
		{
			$snmp->{'community'} = ();	
		}
		push( @{ $snmp->{'community'} }, $communityString);
	}

	$out->print_element( 'snmp', $snmp );
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
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
