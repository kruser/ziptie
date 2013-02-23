package ZipTie::Adapters::Eltek::BCJC::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type);
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
	$chassisAsset->{'core:assetType'} = 'Chassis';
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}        = 'Eltek';
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = 'Powershelf';
	$out->print_element('core:asset', $chassisAsset);

	while ( $in->{rect} =~ /^\s*(\d+)\s+(\d+)\s+\S+\s+\S+\s+\S+\s+(\d+)\s+(\S+)/mgi )
	{
		my $card = { 
			"core:description" => 'Rectifier', 
			"slotNumber" => $2,
		};
		$card->{"core:asset"}->{"core:assetType"}                          = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}         = "Eltek";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = $4;
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $3;
		$out->print_element('card', $card);
	}
	while ( $in->{lvd} =~ /^\s*(\d+)\s+(\d+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s+(\S+)/mgi )
	{
		my $card = { 
			"core:description" => 'LVD', 
			"slotNumber" => $2,
		};
		$card->{"core:asset"}->{"core:assetType"}                          = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}         = "Eltek";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = $4;
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $3;
		$out->print_element('card', $card);
	}
	$out->close_element('chassis');
}

sub parse_system
{
	my ( $in, $out ) = @_;

	$out->print_element( 'core:systemName', get_system_name($in) );

	$out->open_element('core:osInfo');

	$out->print_element( 'core:make',    'Eltek' );
	$out->print_element( 'core:version', 'TBD' );
	$out->print_element( 'core:osType',  'unknown' );
	$out->close_element('core:osInfo');
	$out->print_element( 'core:deviceType', 'Power Supply' );

	# $out->print_element( 'core:contact', $in->{snmp}->{sysContact} );

	if ( $in->{systemInfo} =~ /^\s*Runtime:\s*(\d+)\s*days\s*(\d+):(\d+):(\d+)/mi )
	{
		my $days    = $1;
		my $hours   = $2;
		my $minutes = $3;
		my $seconds = $4;

		my $now           = time();
		my $uptimeSeconds = ( $days * 86400 ) + ( $hours * 3600 ) + ( $minutes * 60 ) + $seconds;

		my $lastReboot = $now - $uptimeSeconds;
		$out->print_element( 'core:lastReboot', int($lastReboot) );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	foreach my $key ( keys %{ $in->{'config'} } )
	{

		# build the simple text configuration
		my $config;
		$config->{'core:name'}       = $key;
		$config->{'core:textBlob'}   = encode_base64( $in->{'config'}->{$key} );
		$config->{'core:mediaType'}  = 'text/plain';
		$config->{'core:context'}    = 'N/A';
		$config->{'core:promotable'} = 'false';

		# push the configuration into the repository
		push( @{ $repository->{'core:config'} }, $config );
	}

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_local_accounts
{

	# TODO
	my ( $in, $out ) = @_;
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = { sysName => get_system_name($in) };
	while ( $in->{traps} =~ /Trap Dest.+?=\s*([\d\.]+)/mgi )
	{
		my $trapHost = { ipAddress => $1, };
		if ( $trapHost != '0.0.0.0' )
		{
			push( @{ $snmp->{trapHosts} }, $trapHost );
		}
	}
	$out->print_element( "snmp", $snmp );
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $interface = {
		adminStatus   => 'up',
		name          => 'eth0',
		interfaceType => 'ethernet',
		physical      => 'true',
	};

	my $ipConfiguration = {};
	if ( $in->{interfaces} =~ /Ip Address\s*=\s*([\d\.]+)/ )
	{
		$ipConfiguration->{ipAddress} = $1;
	}
	if ( $in->{interfaces} =~ /Ip Mask\s*=\s*([\d\.]+)/ )
	{
		$ipConfiguration->{mask} = mask_to_bits($1);
	}

	$interface->{interfaceIp}->{ipConfiguration} = $ipConfiguration;
	my $interfaces->{interface} = $interface;
	$out->print_element( "interfaces", $interfaces );
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_stp
{
	my ( $in, $out ) = @_;
}

sub get_system_name
{
	my $in = shift;
	if ( $in->{systemInfo} =~ /Location:\s*(\S+)/i )
	{
		return $1;
	}
	return '';
}

1;
