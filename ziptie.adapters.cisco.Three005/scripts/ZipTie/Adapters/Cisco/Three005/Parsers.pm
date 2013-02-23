package ZipTie::Adapters::Cisco::Three005::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim strip_mac get_interface_type get_crep mask_to_bits);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
  
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
our $MAC 	= '[0-9a-f]{2}\.[0-9a-f]{2}\.[0-9a-f]{2}\.[0-9a-f]{2}\.[0-9a-f]{2}\.[0-9a-f]{2}';

sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element("chassis");
	my $chassisAsset = { "core:assetType" => 'Chassis' };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";

	if ( $in->{status} =~ /^VPN\sConcentrator\sType:\s*(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ( $in->{status} =~ /Serial\s+Number:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );
	#parse_deviceStorage( $in, $out );
	parse_memory( $in, $out );
	$out->close_element("chassis");
}

#Helping parser to gather volatile memory info. (is part of Chassis information.)
sub _to_bytes
{
	my ($size,$unit) = @_;
	if($unit eq "TB" || $unit eq "T")
	{
		return $size * 1024 * 1024 * 1024 * 1024;
	}elsif($unit eq "GB" || $unit eq "G" )
	{
		return $size * 1024 * 1024 * 1024;
	}elsif($unit eq "MB" || $unit eq "M" )
	{
		return $size * 1024 * 1024;
	}
	elsif($unit eq "kB" || $unit eq "k" )
	{
		return $size * 1024;
	}
	else
	{
		return $size;
	}
}

sub parse_memory
{
	my ( $in, $out ) = @_;

	# Installed Memory:   134,217,728 (128 MB)
	if ( $in->{status} =~ /RAM\s+Size:\s+(\S+)\s+(\S+)/mi )
	{
		my $size = _to_bytes($1,$2);
		$out->print_element( "memory", { kind => 'RAM', size => $size } );
	}
}


sub parse_system
{
	my ( $in, $out ) = @_;
	
	my $sysContact;
	if ($in->{config} =~ /\[system\](.+?)\n\[/ms)
	{
		my $systemBlob = $1;
		if ($systemBlob =~ /^name=(\S*)/mgc)
		{
			$out->print_element( 'core:systemName', $1 );
		}
		if ($systemBlob =~ /^contact=(\b.*)/mgc)
		{
			$sysContact = $1;
		}
	}

	#osInfo::= fileName?, make, name?, softwareImage?, version, osType
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Cisco' );
	
	if ( $in->{status} =~ /Concentrator\s+Version\s+(\S+)\s*/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	else
	{ 
		$out->print_element( 'core:version', "Unknown" );
	}
	
	$out->print_element( 'core:osType', 'VPN 3000' );
	$out->close_element('core:osInfo');

	#deviceType
	$out->print_element( 'core:deviceType', 'VPN Concentrator' );
	
	$out->print_element( 'core:contact', $sysContact) if ($sysContact);

	#lastReboot (in seconds)
	if ( $in->{status} =~  /Up\s+For\s+(\d+)d\s*(\d+):(\d\d):(\d\d)/mi)         
	{
		my $days = $1;
		my $hours = $2;
		my $minutes = $3;
		my $seconds = $4;
		my $uptime = ($days * 60 * 60 * 24) + ($hours * 60 * 60) + ($minutes * 60) + $seconds;
		$out->print_element( "core:lastReboot", $uptime );
	}
	else
	{
		$out->print_element( "core:lastReboot", -1 );
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
	$config->{'core:context'}   = 'active';
	$config->{'core:mediaType'} = 'text/plain';
	$config->{'core:name'}      = 'config';
	$config->{'core:promotable'} ='true';
	$config->{'core:textBlob'}  = encode_base64( $in->{'config'} );
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
	my $cipm = get_crep ( 'cipm' );
	my $openedFilterLists;

	while ( $in->{config} =~ /filterrules \d+\](.+?)\[/migs )
	{
		$_ = $1;
		my $name			= $1 if ( /name=(.+)$/mi );
		my $primaryAction	= $1 if ( /action=(\d+)/mi );
		my $protocol		= $1 if ( /protocol=(\d+)/mi );
		my $log				= 'false';
		if ( $protocol ne '255' )
		{
			$protocol = lc ( get_protocol_name_by_id ( $protocol ) );
		}
		else
		{
			$protocol = 'ip';
		}

		if ( $primaryAction eq '1' || $primaryAction eq '5' )
		{
			$primaryAction = 'drop';
		}
		elsif ( $primaryAction eq '2' || $primaryAction eq '6' )
		{
			$primaryAction = 'permit';
		}

		if ( $primaryAction eq '5' || $primaryAction eq '6' )
		{
			$log = 'true';
		}

		my $thisterm =
		{
			'log'			=> $log ,
			primaryAction	=> $primaryAction ,
			processOrder	=> 1 ,
			protocol		=> $protocol ,
		};

		my $address = $1 if ( /saddr=($cipm)/mi );
		my $mask	= $1 if ( /smask=($cipm)/mi );
		$thisterm->{sourceIpAddr}->{network} = { "address" => $address, "mask" => mask_to_bits ( $mask ) };

		$address	= $1 if ( /daddr=($cipm)/mi );
		$mask		= $1 if ( /dmask=($cipm)/mi );
		$thisterm->{destinationIpAddr}->{network} = { "address" => $address, "mask" => mask_to_bits ( $mask ) };

		my $l_port	= $1 if ( /sportlow=(\d+)/mi );
		my $h_port	= $1 if ( /sporthigh=(\d+)/mi );
		if ( $l_port eq $h_port )
		{
			$thisterm->{sourceService}->{portExpression} = { "operator" => 'eq', "port" => $l_port };
		}
		elsif ( $l_port lt $h_port )
		{
			$thisterm->{sourceService}->{portRange} = { "portStart" => $l_port, "portEnd" => $h_port };
		}

		$l_port	= $1 if ( /dportlow=(\d+)/mi );
		$h_port	= $1 if ( /dporthigh=(\d+)/mi );
		if ( $l_port eq $h_port )
		{
			$thisterm->{destinationService}->{portExpression} = { "operator" => 'eq', "port" => $l_port };
		}
		elsif ( $l_port lt $h_port )
		{
			$thisterm->{destinationService}->{portRange} = { "portStart" => $l_port, "portEnd" => $h_port };
		}

		$out->open_element("filterLists") if ( !$openedFilterLists );
		$openedFilterLists	= 1;

		$out->open_element("filterList");
		$out->print_element( "filterEntry", $thisterm );
		$out->print_element( "mode", 'stateful');
		$out->print_element( "name", $name );
		$out->close_element("filterList");
	}

	$out->close_element("filterLists") if ( $openedFilterLists );
}

sub get_protocol_name_by_id
{
	# visit http://www.iana.org/assignments/protocol-numbers/ for more protocols numbers
	my $protocols = 
	{
		1	=>	'ICMP',
		2	=>	'IGMP',
		3	=>	'GGP',
		4	=>	'IP',
		#5	=>	'ST',
		6	=>	'TCP',
		#7	=>	'CBT',
		8	=>	'EGP',
		9	=>	'IGP',
		#10	=>	'BBN-RCC-MON',
		#11	=>	'NVP-II',
		#12	=>	'PUP',
		#13	=>	'ARGUS',
		#14	=>	'EMCON',
		#15	=>	'XNET',
		#16	=>	'CHAOS',
		17	=>	'UDP',
		47	=>	'GRE',
		50	=>	'ESP',
		88	=>	'EIGRP',
		89	=>	'OSPF',
		112	=>	'VRRP'
	};

	return $protocols->{$_[0]};
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = {};
	
	my $sysname = "";
	my $sysloc = "";
	my $syscont = "";
	
	$out->open_element("snmp");
	while ($in->{snmp} =~ /\d+\.\s*(\S+)/migc)
	{
		my $community = {
			communityString => $1,
			accessType      => 'RO',
		};
		$out->print_element( "community", $community );
	}
	
	if ($in->{config} =~ /\[system\](.+?)\n\[/ms)
	{
		my $systemBlob = $1;
		if ($systemBlob =~ /^name=(\S*)/mgc)
		{
			$sysname = $1;
		}
		if ($systemBlob =~ /^location=(\b.*)/mgc)
		{
			$sysloc = $1;
		}
		if ($systemBlob =~ /^contact=(\b.*)/mgc)
		{
			$syscont = $1;
		}
	}
	
	$out->print_element( 'sysContact', $syscont );
	$out->print_element( 'sysLocation', $sysloc );
	$out->print_element( 'sysName', $sysname );
	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	my $staticRoutes = undef;
	while ($in->{routes} =~ /^\s*($CIPM_RE)\s+($CIPM_RE)\s+(\d+)\s+($CIPM_RE)\s*$/migo)
	{
		my $default = 'false';
		if($1 eq '0.0.0.0')
		{
			$default = 'true';
		}
		my $route = {
				destinationAddress => $1,
				destinationMask    => mask_to_bits ( $2 ),
				gatewayAddress     => $4,
				routeMetric        => $3,
				defaultGateway     => $default,
				interface     	   => _pick_subnet( $4, $subnets ),
			};
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub _pick_subnet
{

	# choose from a hash of subnets and return the matching value
	my ( $gw, $subnets ) = @_;
	if ( defined $subnets )
	{
		foreach my $interfaceName ( sort ( keys(%$subnets) ) )
		{
			my @subnetsArray = @{ $subnets->{$interfaceName} };
			foreach my $subnet (@subnetsArray)
			{
				if ( $subnet->contains( $gw ) )
				{
					return $interfaceName;
				}
			}
		}
	}
	else
	{
		return "";
	}
}

sub _match_interface_type
{

	#"other", "unknown", "atm", "ethernet", "frameRelay", "gre", "isdn", "modem", "ppp", "serial", "softwareLoopback", "sonet", "tokenRing"
	my $part = shift;
	if ( $part =~ /(unknown|atm|ethernet|frameRelay|gre|isdn|modem|ppp|serial|softwareLoopback|sonet|tokenRing)/i )
	{
		return $1;
	}
	elsif ( $part =~ /fe|ge|ether|eth/i )
	{
		return "ethernet";
	}
	else
	{
		return "other";
	}

}

sub _is_physical
{
	my $part = shift;
	if ( $part =~ /(ether|eth)/i )
	{
		return "true";
	}
	else
	{
		return "false";
	}

}

sub _get_ip
{
	my $ip_mask = shift;
	if($ip_mask =~ /(.*)\/(.*)/)
	{
		return $1;
	}
}

sub _get_mask
{
	my $ip_mask = shift;
	if($ip_mask =~ /(.*)\/(.*)/)
	{
		return $2;
	}
}


sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $subnets = {};    # will be returned to the caller

	$out->open_element("interfaces");
	if ($in->{interfaces} =~ /^\s*-+\s*$(.*)^\s*-+\s*$/ms)
	{
		my $var = $1;
		while($var =~ /^\s*(\S+)\s*\|\s*(\S+)\s*\|\s*($CIPM_RE)\/($CIPM_RE)\s*\|\s*($MAC)\s*/mogi)
		{
			my $interface = {
				adminStatus   => lc($2),
				interfaceType => _match_interface_type($1),
				name          => $1,
				physical      => _is_physical($1),
			};
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($5);			
			$interface->{interfaceIp}->{ipConfiguration}->{ipAddress} = $3;
			$interface->{interfaceIp}->{ipConfiguration}->{mask} = mask_to_bits($4);
			my $subnet = new ZipTie::Addressing::Subnet( $3, mask_to_bits($4) );
			push( @{ $subnets->{$1} }, $subnet );
			$out->print_element( "interface", $interface );
		}
		
	}
	else
	{
		#die "Interfaces are not available\n";
	}
	$out->close_element("interfaces");

	return $subnets;
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

__END__

=head1 Parsers

ZipTie::Adapters::Cisco::Three005::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Cisco::Three005::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
	parse_filters( $cliResponses, $xmlPrinter);	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
device responses and print out ZipTie model elements.

=head2 Methods

=over 12

=item C<create_config( $in, $out )>

Uses the device configs to put together a ZipTie configurationRepository element.

=item C<parse_local_accounts( $in, $out )>

Parse the local accounts.

=item C<parse_chassis( $in, $out )>

Parse out the chassis level elements.

=item C<parse_filters( $in, $out )>

Parse out firewall rules.

=item C<parse_routing( $in, $out )>

Parse out BGP and OSPF configuration

=item C<parse_snmp( $in, $out )>

Parse out the SNMP elements.

=item C<parse_system( $in, $out )>

Parses out some top level core attributes of the ZipTie model ZiptieElementDocument

=item C<parse_vlan( $in, $out )>

Parses out the VLAN elements.

=item C<parse_stp( $in, $out )>

Parses out the spannint tree elements.

=back

=head1 LICENSE

  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/
  
  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.
 
  The Original Code is Ziptie Client Framework.
  
  The Initial Developer of the Original Code is AlterPoint.
  Portions created by AlterPoint are Copyright (C) 2006,
  AlterPoint, Inc. All Rights Reserved.

=head1 AUTHOR

  Contributor(s): asharma, rkruse
  Date: Sep 29, 2007

=cut
