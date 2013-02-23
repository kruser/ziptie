package ZipTie::Adapters::ThreeCom::Switch3300::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep);
use MIME::Base64 'encode_base64';

use Data::Dumper;

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{'system'} =~ /^Hardware Version\s+:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "3Com";
	
	# Default to "Unknown" for the model number just in case it is not found
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = "Unknown";
	
	if ($in->{'system'} =~ /^Product Number\s+:\s+(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ($in->{'system'} =~ /^Serial Number\s+:\s+(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;		
	} 

	$out->print_element( "core:asset", $chassisAsset );

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{'system'} =~ /^System Name\s+:\s+(.+)$/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element('core:make', '3Com');
	if ( $in->{'system'} =~ /summary\s+(\S.+)System Name/mis )
	{
		$out->print_element( 'core:name', trim($1) );
	}
	if ( $in->{'system'} =~ /^Operational Version\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', '1000/1100/3300 Switch' );
	$out->close_element('core:osInfo');

	if ( $in->{'system'} =~ /^Boot Version\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{'system'} =~ /^Contact\s+:\s+(\S.+)$/mi;
	$out->print_element( 'core:contact', trim($contact) );

	# Time Since Reset        : 5947 Hrs 3 Mins 20 Seconds
	if ( $in->{'system'} =~ /^Time Since Reset\s+:\s+(\S.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*Years?/;
		my ($weeks)   = /(\d+)\s*Weeks?/;
		my ($days)    = /(\d+)\s*Days?/;
		my ($hours)   = /(\d+)\s*Hrs?/;
		my ($minutes) = /(\d+)\s*Mins?/;
		my ($seconds) = /(\d+)\s*Seconds?/;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$lastReboot -= $seconds						  if ($seconds);
		$out->print_element( "core:lastReboot", $lastReboot );
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

sub parse_routing
{
	my ( $in, $out ) = @_;
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");

	my $users = $in->{users};
	$users =~ s/[^-]+-+//mis;
	while ( $users =~ /^(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
	{
		my $account = { accountName => $1 };
		$account->{accessGroup} = $2;
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
	
	my $vlans;
	foreach (sort(keys %{$in->{vlan}}))
	{
		$in->{vlan}->{$_} =~ /.*name:(.*)\n.*Unit\s+Ports\s+\d+\s+(.*)Unicast/migs;
		my ($name, $blob) = ($1,$2);
		my $vlanInstance;
		
		$name =~ s/\s*$//mig;
		$name =~ s/^\s*//mig;
		$vlanInstance->{enabled} = 'true';
		$vlanInstance->{name} = $name;
		$vlanInstance->{number} = $_;
		
		$blob =~ s/\n//mig;
		while ($blob =~ /\s*(\d+),?/mig)
		{
			push( @{ $vlanInstance->{interfaceMember} }, $1 );	
		}
		
		push( @{ $vlans->{vlan} }, $vlanInstance );
	}
	
	$out->print_element( "vlans", $vlans ) if ($vlans);
	
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;
	my $instance;

	my $mac1 = get_crep('mac1');
	if  ( $in->{stp}  =~ /^Designated Root:\s+[a-f0-9]{4} ($mac1)/mi )
	{
		$instance->{designatedRootMacAddress} = $1;
	}
	if  ( $in->{stp}  =~ /\brootCost:\s+(\d+)/mi )
	{
		$instance->{designatedRootCost} = $1;
	}
	if  ( $in->{stp}  =~ /\bbridgeMaxAge:\s+(\d+)/mi )
	{
		$instance->{designatedRootMaxAge} = $1;
	}
	if  ( $in->{stp}  =~ /\bbridgeHelloTime:\s+(\d+)/mi )
	{
		$instance->{designatedRootHelloTime} = $1;
	}
	if  ( $in->{stp}  =~ /\bbridgeFwdDelay:\s+(\d+)/mi )
	{
		$instance->{designatedRootForwardDelay} = $1;
	}
	if  ( $in->{stp}  =~ /\bmaxAge:\s+(\d+)/mi )
	{
		$instance->{maxAge} = $1;
	}
	if  ( $in->{stp}  =~ /\bhelloTime:\s+(\d+)/mi )
	{
		$instance->{helloTime} = $1;
	}
	if  ( $in->{stp}  =~ /\bforwardDelay:\s+(\d+)/mi )
	{
		$instance->{forwardDelay} = $1;
	}
	if  ( $in->{stp}  =~ /\bholdTime:\s+(\d+)/mi )
	{
		$instance->{holdTime} = $1;
	}
	if  ( $in->{stp}  =~ /^Bridge Identifier:\s+[a-f0-9]{4} ($mac1)/mi )
	{
		$instance->{systemMacAddress} = $1;
	}
	if  ( $in->{stp}  =~ /\bpriority:\s+(?:0x)?(\d+)/mi )
	{
		$instance->{priority} = hex($1);
	}
	if ( $instance )
	{
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

1;
