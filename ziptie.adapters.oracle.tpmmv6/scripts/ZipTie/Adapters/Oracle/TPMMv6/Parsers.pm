package ZipTie::Adapters::Oracle::TPMMv6::Parsers;

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

	$chassis->{'core:asset'}->{'core:assetType'} = 'Chassis';

	# $chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = 'TBD';
	# $chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = 'TBD';
	# $chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} = 'TBD';
	# $chassis->{'core:description'}                                       = 'TBD';
	
	$out->print_element( "chassis", $chassis );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	$out->print_element( 'core:systemName', $in->{snmp}->{sysName} );
	
	$out->open_element('core:osInfo');
	# $out->print_element( 'core:make',    'TBD' );
	# $out->print_element( 'core:version', 'TBD' );
	# $out->print_element( 'core:osType',  'TBD' );
	$out->close_element('core:osInfo');
		
	# $out->print_element( 'core:deviceType', 'TBD' );
	$out->print_element( 'core:contact',    $in->{snmp}->{sysContact} );
	
	if (defined $in->{uptime})
	{
		my $now = time();
		my $lastReboot = $now - ($in->{uptime} / 100);
		$out->print_element('core:lastReboot', int($lastReboot));
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
	$out->print_element('snmp', $in->{snmp});
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
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
