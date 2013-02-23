package ZipTie::Adapters::F5::ThreeDNS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';
use File::Temp;
use Compress::Zlib;
use Archive::Tar;

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{license} =~ /Serial\s+:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "F5 Networks";
	
	my $productType = 'BIG-IP';
	if ($in->{license} =~ /3DNS/i)
	{
		$productType = '3DNS';	
	}
	
	if ( $in->{license} =~ /Platform\s+ID\s+:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $productType.' '.$1;
	}
	$out->print_element( "core:asset", $chassisAsset );

	my $cpu;
	if ( $in->{dmesg} =~ /Cpu-\d+\s+=\s+(.+)$/mi )
	{
		$cpu->{"core:description"} = $1;

		# clean up cpu description
		$cpu->{"core:description"} =~ s/\bmdl.+$//i;
		my $cputRE = createCPUTypesRE();
		if ( $cpu->{"core:description"} =~ /$cputRE/i )
		{
			$cpu->{cpuType} = $1;
		}
	}
	$out->print_element( "cpu", $cpu );

	_parse_file_storage( $in, $out );

	my @memories = ();

	# under 3DNS only common RAM memory is available.
	if ( $in->{dmesg} =~ /^real\s+mem\s+=\s+(\d+)/mi )
	{
		push @memories, { 'core:description' => 'RAM', kind => 'RAM', size => $1 };
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

	while ( $in->{df} =~ /^(\S+)\s+(?:\d+)\s+(\d+)\s+(\d+)\s+(\d+)%\s+\S.+$/mig )
	{
		my $prt_name   = $1;
		my $total_size = $2 + $3;
		my $storage    = {
			name        => $prt_name,
			storageType => 'disk',
			size        => $total_size,
		};

		# we won't populate FileDirectory node
		$out->print_element( "deviceStorage", $storage );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{hostname} =~ /^hostname\s*(\S+)$/mi )
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

	if ( $in->{hostname} =~ /^hostname\s*(\S+)$/mi )
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

	while ( $in->{static_routes} =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|default)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+\S+\s+\d+\s+(\S+)/mig )
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
	$out->open_element("interfaces");

	my $interface;
	my $order = 1;
	while ( $in->{interfaces} =~ /^(.+)$/mig )
	{
		my $if_line = $1;

		if ( $if_line =~ /^([^:\s]+):(?:\s*\((\S+)\))?\s*flags=\d+<(\S+)>/i )
		{
			if ( defined $interface->{name} )
			{
				$out->print_element( "interface", $interface );
			}
			$interface         = {};
			$order             = 1;
			$interface->{name} = $1;
			$interface->{description}   = $2 if ( defined $2 );
			$interface->{interfaceType} = get_interface_type($1);
			$interface->{physical}      = _is_physical($1);
			$interface->{adminStatus}   = $3;

			if ( $interface->{adminStatus} =~ /\bUP\,?/i )
			{
				$interface->{adminStatus} = 'up';
			}
			else
			{
				$interface->{adminStatus} = 'down';
			}
		}
		else
		{
			if ( defined $interface->{name} )
			{
				if ( $if_line =~ /^\s*link\s+type\s+(\S+)(?:\s+([a-f0-9:]{11,17}))?\s+mtu\s(\d+)(?:\s+speed\s+(\d+)([a-z]+))?/i )
				{
					$interface->{interfaceEthernet}->{macAddress} = $2 if ( defined $2 );
					$interface->{mtu}                             = $3;
					$interface->{speed}                           = $4 if ( defined $4 );
					if ( defined $interface->{speed} )
					{
						my $speed_msrm = $5;
						if ( $speed_msrm =~ /Mb/i ) { $interface->{speed} = $interface->{speed} * 1000 * 1000; }
						if ( $speed_msrm =~ /Kb/i ) { $interface->{speed} = $interface->{speed} * 1000; }
					}
					if ( defined $interface->{interfaceEthernet} )
					{
						my $macAddress = "";
						foreach ( split( /:/, $interface->{interfaceEthernet}->{macAddress} ) )
						{
							$macAddress .= ( length($_) == 1 ) ? '0' . $_ : $_;
						}
						$interface->{interfaceEthernet}->{macAddress} = $macAddress;
					}
				}
				elsif ( $if_line =~
/^\s*inet\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+netmask\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+broadcast\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*$/i
				  )
				{
					push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, { broadcast => $3, ipAddress => $1, mask => mask_to_bits($2), precedence => $order } );
					$order++;
				}
			}
		}
	}

	if ( defined $interface->{name} )
	{
		$out->print_element( "interface", $interface );
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	$out->open_element("vlans");

	my $vlan;
	while ( $in->{vlans} =~ /^(.+)$/mig )
	{
		my $vl_line = $1;
		if ( $vl_line =~ /^VLAN (\S+)/i )
		{
			if ( $vlan->{name} )
			{
				$out->print_element( "vlan", $vlan );
				$vlan = {};
			}
			$vlan->{name}		= $1;
			$vlan->{enabled}	= 'true';
		}
		elsif ( $vl_line =~ /^\s*tag\s+(\d+)/i && $vlan->{name} )
		{
			$vlan->{number} = $1;
		}
		elsif ( $vl_line =~ /^\s*untagged interfaces\s+(\S+)/i && $vlan->{name} )
		{
			push @{$vlan->{interfaceMember}}, $1;
		}
	}
	if ( $vlan->{name} )
	{
		$out->print_element( "vlan", $vlan );
		$vlan = {};
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

sub createCPUTypesRE
{
	my @cpuTypes = qw(Pentium Celeron Xeon XeonMP Itanium
	  Athlon AthlonFX Opteron OpteronMP Duron Sempron);
	'\b(' . join( '|', @cpuTypes ) . ')';
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

1;

__END__

=head1 Parsers

ZipTie::Adapters::F5::ThreeDNS::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::F5::ThreeDNS::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
