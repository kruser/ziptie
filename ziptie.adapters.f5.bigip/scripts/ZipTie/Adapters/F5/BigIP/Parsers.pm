package ZipTie::Adapters::F5::BigIP::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{license} =~ /^(Appliance\s+)?SN\s*:\s+(\S+)\s*$/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $2;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "F5 Networks";
	if ( $in->{license} =~ /^(Platform\s+)?ID\s*:\s+(\S+)\s*$/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = 'BIG-IP '.$2;
	}
	$out->print_element( "core:asset", $chassisAsset );

	my $cpu;
	if ( $in->{dmesg} =~ /^CPU\d+:\s+(\S.+Hz)/mi )
	{
		$cpu->{"core:description"} = $1;
		my $cputRE = createCPUTypesRE();
		if ( $cpu->{"core:description"} =~ /$cputRE/i )
		{
			$cpu->{cpuType} = $1;
		}
	}
	$out->print_element( "cpu", $cpu );

	_parse_file_storage( $in, $out );

	my @memories = ();

	# under BigIP only common RAM memory is available.
	if ( $in->{global} =~ /^Memory\s+\(?:total,\s*used\)\s*=\s*\(([\d\.]+)([MGK]),\s*([\d\.]+)([MGK])\)/mi )
	{
		my $memSize = $1;
		if ( uc($2) eq 'K' )
		{
			$memSize *= 1024;
		}
		elsif ( uc($2) eq 'M' )
		{
			$memSize *= 1024 * 1024;
		}
		if ( uc($2) eq 'G' )
		{
			$memSize *= 1024 * 1024 * 1024;
		}
		push @memories, { 'core:description' => 'RAM', kind => 'RAM', size => $memSize };
	}

	foreach (@memories)
	{
		$out->print_element( "memory", $_ );
	}

	$out->close_element("chassis");
}

sub _parse_file_storage
{

	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;
	while ( $in->{dmesg} =~ /^hd(\S+):\s*\d+\s+sectors\s+\((\d+)\s+([MGK])B\)/mig )
	{
		my $storage = {
			name        => 'hd' . $1,
			storageType => 'disk',
			size        => $2,
		};
		if ( uc($3) eq 'K' )
		{
			$storage->{size} *= 1024;
		}
		elsif ( uc($3) eq 'M' )
		{
			$storage->{size} *= 1024 * 1024;
		}
		if ( uc($3) eq 'G' )
		{
			$storage->{size} *= 1024 * 1024 * 1024;
		}

		# we won't populate FileDirectory node
		$out->print_element( "deviceStorage", $storage );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{hostname} =~ /\bgethostname\(\)=[\`\"\']([^\`\"\']+)[\`\"\']$/mi )
	{
		$out->print_element( 'core:systemName', $1 );
	}

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'F5' );

	if ( $in->{ucsv} =~ /^Product:\s+(\S+)/mi )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{ucsv} =~ /^Version:\s+([\d\.]+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'BIG-IP' );
	$out->close_element('core:osInfo');

	if ( ( $in->{dd} =~ /\b(REV\S*\s*\S+)\s*$/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Load Balancer' );

	my ($contact) = $in->{snmp} =~ /^syscontact\s+(.+)$/mi;
	$out->print_element( 'core:contact', $contact );

	# 22:26:48  up 107 days,  1:55,  1 user,  load average: 1.00, 1.00, 1.00
	if ( $in->{uptime} =~ /\bup\s+(.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;

		if ( !defined $hours )
		{
			my $temp = $_;
			if ( $temp =~ /(\d+)\:(\d+)/ )
			{
				$hours   = $1;
				$minutes = $2;
			}
		}

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

	# Open up the UCS file and read it into memory
	my $LOGGER = ZipTie::Logger::get_logger();
	open( UCS, $in->{ucsFileLocation} ) || $LOGGER->fatal("Could not open the retrieved configuration file stored in '$in->{ucsFileLocation}'");
	binmode UCS;
	my $ucsBits = join( "", <UCS> );
	close(UCS);

	# the name of the repository
	my $repository = { 'core:name' => '/', };

	# build the simple text configuration
	my $config = {
		'core:name'       => 'backup.ucs',
		'core:textBlob'   => encode_base64($ucsBits),
		'core:mediaType'  => 'application/x-compressed',
		'core:context'    => 'N/A',
		'core:promotable' => 'true',
	};

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	# now push all of the ucs contents as single files into the repository
	_push_configurations($repository, $in->{unzippedUcs});

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub _push_configurations
{
	my ($repository, $hashZip) = @_;
	for my $key ( keys %{$hashZip} )
	{
		if ( scalar $hashZip->{$key} =~ /^HASH/ )
		{
			my $folder = { 'core:name' => $key, };
			push( @{ $repository->{'core:folder'} }, $folder );
			_push_configurations($folder, $hashZip->{$key});
		}
		else
		{
			my $file = {
				'core:name'       => $key,
				'core:textBlob'   => encode_base64($hashZip->{$key}),
				'core:mediaType'  => 'text/plain',
				'core:context'    => 'N/A',
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

	while ( ( $in->{users} =~ /^([^\s:]+):([^:]+):(\d+):(\d+):([^:]+):([^:]+):([^:]+)$/mig ) )
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
	$out->open_element("snmp");
	my @communities = ();
	my @traps       = ();

	# parse communities and trap hosts
	while ( $in->{snmp} =~ /^(.+)$/mig )
	{
		my $commline = $1;
		if ( $commline =~ /^(r[ow])community\S*\s+(\S+)\s+\S+\s*(\S*)$/i )
		{
			push( @communities, { accessType => uc($1), communityString => $2, mibView => $4 } );
		}
		elsif ( $commline =~ /^trapsess.+\-c\s+(\S+)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).+$/i )
		{
			push( @traps, { ipAddress => $2, communityString => $1 } );
		}
	}

	# parse other snmp data and store the configuration
	foreach (@communities)
	{
		$out->print_element( "community", $_ );
	}

	my $someSysPrinted = 0;
	if ( $in->{snmp} =~ /^syscontact\s+(.+)$/mi )
	{
		$out->print_element( "sysContact", $1 );
		$someSysPrinted = 1;
	}

	if ( $in->{snmp} =~ /^syslocation\s+(.+)$/mi )
	{
		$out->print_element( "sysLocation", $1 );
		$someSysPrinted = 1;
	}

	if ( $in->{hostname} =~ /\bgethostname\(\)=[\`\"\']([^\`\"\']+)[\`\"\']$/mi )
	{
		$out->print_element( "sysName", $1 );
		$someSysPrinted = 1;
	}

	if ($someSysPrinted)
	{
		foreach (@traps)
		{
			$out->print_element( "trapHosts", $_ );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	# grab all data about static route
	while ( $in->{static_routes} =~ /^([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)$/mig )
	{
		if (   $1 ne '127.0.0.0'
			&& $1 ne '127.0.0.1' )
		{
			my $route = {
				destinationAddress => $1,
				destinationMask    => mask_to_bits ( $3 ),
			};
			$route->{gatewayAddress} = $2;
			$route->{interface}      = $8;
			if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0' ) )
			{
				$route->{defaultGateway} = 'true';
			}
			else
			{
				$route->{defaultGateway} = 'false';
			}
			$route->{routeMetric} = $5;
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");

	foreach my $if_part ( split( /^\s*$/mi, $in->{"interfaces"} ) )
	{

		# 1 grab the name, macAddress, status, mtu
		if ( $if_part =~ /^INTERFACE\s+(\S+)\s+(\S+)\s+(ENABLED|DISABLED)\s+(UP|DOWN|UNPOPULATED)\s+MTU\s+(\d+)/mi )
		{
			my $interface = {};
			$interface->{name}                            = $1;
			$interface->{description}                     = $1;
			$interface->{physical}                        = _is_physical($1);
			$interface->{interfaceType}                   = get_interface_type($1);
			$interface->{adminStatus}                     = lc($4);
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($2);
			$interface->{mtu}                             = $5;
			$interface->{interfaceEthernet}->{macAddress} =~ s/\://;

			if ( $interface->{adminStatus} !~ /^up$/i )
			{
				$interface->{adminStatus} = 'down';
			}

			# 2 grab IP address if interface is MGMT
			if ( $interface->{name} =~ /^mgmt$/i )
			{
				if ( $in->{"mgmt"} =~ /^MGMT\s+IP\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+\-\s+netmask\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/mi )
				{
					my $ipConfiguration = {
						ipAddress  => $1,
						mask       => mask_to_bits($2),
						precedence => 1,
					};
					push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
				}
			}

			# 3 autoDuplex, media type, operational duplex
			if ( ( $if_part =~ /^\|\s*media\s+(\S+)\s+(.+)$/mi ) )
			{
				my $autoDuplex = "false";
				if ( $1 =~ /auto/i )
				{
					$autoDuplex = "true";
				}
				$interface->{interfaceEthernet}->{autoSpeed} = $autoDuplex;
				if ( defined $2 )
				{
					my $line = $2;
					if ( $line =~ /\((\d+base\S+)\s+(\S+)\)/i )
					{
						my $mediaType  = $1;
						my $operDuplex = $2;

						$interface->{interfaceEthernet}->{mediaType}         = $mediaType;
						$interface->{interfaceEthernet}->{operationalDuplex} = $operDuplex;
					}
				}
			}
			$out->print_element( "interface", $interface );
		}
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	my @vlans = ();

	$out->open_element("vlans");
	foreach my $vlan_part ( split( /^\s*$/mi, $in->{"vlans"} ) )
	{
		if ( $vlan_part =~ /^VLAN\s+(\S+)\s+tag\s+(\d+)\s+(?:(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2})?\s+MTU\s+(\d+)/mi )
		{
			my $vlan = {};
			$vlan->{name}    = $1;
			$vlan->{number}  = $2;
			$vlan->{mtu}     = $3;
			$vlan->{enabled} = 'true';

			while ( $vlan_part =~ /^\s*\+\->\s+INTERFACE\s+([\d\.]+)/mig )
			{
				push( @{ $vlan->{interfaceMember} }, _full_int_name($1) );
			}

			$out->print_element( "vlan", $vlan );
		}
	}
	$out->close_element("vlans");
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;

	my ( $helloTime, $maxAge, $forwardDelay, $holdTime, $stpmode ) = ( 0, 0, 0, 0, );

	if ( $in->{stp} =~ /^STP\s+MODE\s+(\S+)/mi )
	{
		$stpmode = $1;
		$spanningTree->{mode} = $stpmode;
	}

	if ( $in->{stp} =~ /^\|\s*Forward\s+delay\s+(\d+)\s+Hello\s+time\s+(\d+)\s+Max.\s+age\s+(\d+)\s+Transmit\s+hold\s+(\d+)/mi )
	{
		$helloTime    = $2;
		$maxAge       = $3;
		$forwardDelay = $1;
		$holdTime     = $4;
	}

	foreach my $stpins_part ( split( /^\+\->\s+STP\s+INSTANCE/mi, $in->{"stp"} ) )
	{
		if ( $stpins_part =~ /^\s*(\d+)\s+priority\s+(\d+)\s+root\s+bridge\s+([\da-f\:]{17})/mi )
		{
			my $instance = {
				helloTime        => $helloTime,
				maxAge           => $maxAge,
				forwardDelay     => $forwardDelay,
				holdTime         => $holdTime,
				priority         => $2,
				systemMacAddress => strip_mac($3)
			};
			if ( $stpins_part =~ /^\s*\+\->\s+STP\s+VLAN\s+\d+\s+(\S+)/mi )
			{
				$instance->{vlan} = $1;
			}
			push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
		}
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

sub _is_physical
{
	my $name = shift;
	if ( $name =~ /\.\d+$/ )
	{
		return "false";
	}
	elsif ( $name =~ /seri|eth|gig|^fe|^fa|token|[bp]ri/i )
	{
		return "true";
	}
	else
	{
		return "false";
	}
}

sub _full_int_name
{

	# given a short name like "Fa3/15" return "FastEthernet3/15"
	my $name = trim(shift);
	for ($name)
	{
		s/^Fa(?=\d)/FastEthernet/;
		s/^Eth(?=\d)/Ethernet/;
		s/^Gig(?=\d)/GigabitEthernet/;
	}
	return $name;
}

sub createCPUTypesRE
{
	my @cpuTypes = qw(Pentium Celeron Xeon XeonMP Itanium
	  Athlon AthlonFX Opteron OpteronMP Duron Sempron);
	'\b(' . join( '|', @cpuTypes ) . ')';
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::F5::BigIP::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::F5::BigIP::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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

  Contributor(s): rkruse
  Date: Apr 23, 2007

=cut
