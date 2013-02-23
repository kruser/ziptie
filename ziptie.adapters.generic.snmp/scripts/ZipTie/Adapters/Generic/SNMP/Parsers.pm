package ZipTie::Adapters::Generic::SNMP::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::EnterpriseNumbers;
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(parse_chassis parse_system create_config);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element('chassis');
	my $chassisAsset = {
		"core:assetType"   => "Chassis",
	};
	$chassisAsset->{"core:factoryinfo"}->{"core:make"} = ZipTie::Adapters::EnterpriseNumbers::get_enterprise_name( $in->{snmp}->{sysObjectId} );
	$chassisAsset->{"core:factoryinfo"}->{"core:modelNumber"} = "Unknown" ;
	$out->print_element( "core:asset", $chassisAsset );
	$out->print_element( "core:description", $in->{snmp}->{sysDescr} );
	$out->close_element('chassis');
}

sub parse_system
{
	my ( $in, $out ) = @_;
	my $lastReboot = time();

	$out->print_element( 'core:systemName', $in->{snmp}->{sysName} );
	
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make',    'Unknown' );
	$out->print_element( 'core:version', 'Undefined' );
	$out->print_element( 'core:osType',  'Unknown' );
	$out->close_element('core:osInfo');
	
	$out->print_element( 'core:deviceType', 'Router' );
	$out->print_element( 'core:contact',    $in->{snmp}->{sysContact} );
	
	# Gather the system uptime
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

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

1;
