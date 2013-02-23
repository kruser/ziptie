package ZipTie::Adapters::Nokia::Checkpoint::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type parseCIDR bin2dec merge_hashes);
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
	if ( $in->{'hw:chassis:serialnumber'} =~ /^hw:chassis:serialnumber\s*=\s*(\S+)$/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Nokia";
	if ( $in->{'product:model'} =~ /^(?:\s*dbget\s+product:model)?\s*(\S+)/mis )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );
	
	if ($in->{motherboard} =~ /serialnumber\s*=\s*(\S+)/i)
	{
		my $motherboard = {
			'core:description' => 'motherboard',
		};
		$motherboard->{'core:asset'}->{'core:assetType'}							= "Card";
		$motherboard->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}			= 'Nokia';
		$motherboard->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'}	= 'Unknown';
		$motherboard->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'}	= $1;
		
		if ($in->{motherboard} =~ /revision\s*=\s*(\S+)/i)
		{
			$motherboard->{'core:asset'}->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
		}
		if ($in->{motherboard} =~ /modelname\s*=\s*(\S+)/i)
		{
			$motherboard->{'core:asset'}->{'core:factoryinfo'}->{'core:partNumber'} = $1;
		}
		$out->print_element( "card", $motherboard );
	}

	my $cpu;
	if ( $in->{dmesg} =~ /^CPU:\s+(\S.+)/mi )
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

	# under Nokia::Checkpoint only common RAM memory is available.
	if ( $in->{dmesg} =~ /^real\s+memory\s+=\s+(\d+)/mi )
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

	my $storage = undef;

	# we won't populate FileDirectory node
	while ( $in->{hdd} =~ /^(.+)$/mig )
	{
		my $hdd_line = $1;
		if ( $hdd_line =~ /^model\s+(\S.+)$/i )
		{
			if ( defined $storage->{name} )
			{
				$out->print_element( "deviceStorage", $storage );
				$storage = undef;
			}
			$storage = {
				name        => $1,
				storageType => 'disk',
			};
		}
		elsif ( $hdd_line =~ /^capacity\s+(\d+)([MKG])B$/i
			&& defined $storage->{name} )
		{
			my $size = $1;
			if ( lc($2) eq 'k' )
			{
				$size *= 1024;
			}
			elsif ( lc($2) eq 'm' )
			{
				$size *= 1024 * 1024;
			}
			elsif ( lc($2) eq 'g' )
			{
				$size *= 1024 * 1024 * 1024;
			}
			$storage->{size} = $size;
		}
	}
	if ( defined $storage->{name} )
	{
		$out->print_element( "deviceStorage", $storage );
		$storage = undef;
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{hostname} =~ /^(?:\s*hostname)?\s*(\S+)/mis;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Nokia' );
	if ( $in->{kern_osrelease} =~ /^kern:osrelease\s*=\s*([^\s\-]+)-(\S+)/mi )
	{
		$out->print_element( 'core:name',    $2 );
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'Checkpoint' );
	$out->close_element('core:osInfo');

	if ( $in->{bios_version} =~ /hw:bios:version\s*=\s*(\S+)/i )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Firewall' );

	my ($contact) = $in->{snmp} =~ /^sysContact\s+(\S+)/mi;
	$out->print_element( 'core:contact', $contact );

	# 5:36PM  up 144 days,  1:59, 5 users, load averages: 0.00, 0.00, 0.00
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
	my ( $in, $out, $parsed_files ) = @_;
	
	# Open up the UCS file and read it into memory
	my $LOGGER = ZipTie::Logger::get_logger();
	open( TGZ, $in->{config} ) || $LOGGER->fatal("Could not open the retrieved configuration file stored in '$in->{ucsFileLocation}'");
	binmode TGZ;
	my $tarBits = join( "", <TGZ> );
	close(TGZ);

	# build the simple text configuration
	my $config =
	{
		'core:name'       => 'backup1.tgz',
		'core:textBlob'   => encode_base64($tarBits),
		'core:mediaType'  => 'application/x-compressed',
		'core:context'    => 'N/A',
		'core:promotable' => 'true',
	};

	$tarBits = '';
	open( TGZ, $in->{config2} ) || $LOGGER->fatal("Could not open the retrieved configuration file stored in '$in->{ucsFileLocation}'");
	binmode TGZ;
	$tarBits = join( "", <TGZ> );
	close(TGZ);

	# build the simple text configuration
	my $config2 =
	{
		'core:name'       => 'backup2.tgz',
		'core:textBlob'   => encode_base64($tarBits),
		'core:mediaType'  => 'application/x-compressed',
		'core:context'    => 'N/A',
		'core:promotable' => 'true',
	};

	$tarBits = '';

	# the name of the repository
	my $repository = { 'core:name' => '/', };

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );
	push( @{ $repository->{'core:config'} }, $config2 );

	my $unzipped = merge_hashes( $in->{unzipped}, $in->{unzipped2} );
	_push_configurations( $repository, $unzipped );

	# now push all of the ucs contents as single files into the repository
	#_push_configurations( $repository, $in->{unzipped} );

	# now push all of the ucs contents as single files into the repository
	#_push_configurations( $repository, $in->{unzipped2} );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub _push_configurations
{
	my ( $repository, $hashZip ) = @_;
	for my $key ( keys %{$hashZip} )
	{
		if ( scalar $hashZip->{$key} =~ /^HASH/ )
		{
			my $folder = { 'core:name' => $key, };
			push( @{ $repository->{'core:folder'} }, $folder );
			_push_configurations( $folder, $hashZip->{$key} );
		}
		else
		{
			my $file = {
				'core:name'       => $key,
				'core:textBlob'   => encode_base64( $hashZip->{$key} ),
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

	$out->open_element("filterLists");

	my $thisacl = {};
	my $filters;
	my $filterEntry;
	while ( $in->{acl_rules} =~ /^(.+)$/mig )
	{
		my $aclline = $1;
		if ( $aclline =~ /^ACL\s+rule\s+for\s+(\S+)\s*$/i )
		{
			if ( defined $thisacl->{name} )
			{
				$out->open_element("filterList");
				$filterEntry->{processOrder} = 1;

				#push @{$thisacl->{filterEntry}},$filterEntry;
				$out->print_element( "filterEntry", $filterEntry );
				$out->print_element( "mode",        'stateless' );
				$out->print_element( "name",        $thisacl->{name} );
				$out->close_element("filterList");
				$thisacl     = {};
				$filterEntry = {};
			}
			$thisacl->{name} = $1;
			$filterEntry->{'log'} = 'false';
		}
		elsif ( $aclline =~ /^\s*Action:\s+(\S+)\s*$/i
			&& defined $thisacl->{name} )
		{
			if ( lc($1) eq 'accept' )
			{
				$filterEntry->{primaryAction} = 'permit';
			}
			else
			{
				$filterEntry->{primaryAction} = 'deny';
			}
		}
		elsif ( $aclline =~ /^\s*Source\s+IP\s+address:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*$/i
			&& defined $thisacl->{name} )
		{
			my $net_mask = '32';
			push @{ $filterEntry->{sourceIpAddr} }, { network => {address => $1, mask => $net_mask} };
		}
		elsif ( $aclline =~ /^\s*Destination\s+IP\s+address:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*$/i
			&& defined $thisacl->{name} )
		{
			my $net_mask = '32';
			push @{ $filterEntry->{destinationIpAddr} }, { network => {address => $1, mask => $net_mask} };
		}
		elsif ( $aclline =~ /^\s*Protocol:\s+(\S+)\s*$/i
			&& defined $thisacl->{name} )
		{
			$thisacl->{filterEntry}->{"protocol"} = $1;
		}
		elsif ( $aclline =~ /^\s*Source\s+port\s+range:\s+(\d+)\-(\d+)\s*$/i
			&& defined $thisacl->{name} )
		{
			push @{ $filterEntry->{sourceService} }, { portRange => {portStart => $1, portEnd => $2} };
		}
		elsif ( $aclline =~ /^\s*Destination\s+port\s+range:\s+(\d+)\-(\d+)\s*$/i
			&& defined $thisacl->{name} )
		{
			push @{ $filterEntry->{destinationService} }, { portRange => {portStart => $1, portEnd => $2} };
		}
		elsif ( $aclline =~ /^\s*TOS:\s+(\S+)\s*$/i
			&& defined $thisacl->{name} )
		{
			$filterEntry->{"tos"} = $1;
		}
	}
	if ( defined $thisacl->{name} )
	{
		$out->open_element("filterList");
		$filterEntry->{processOrder} = 1;

		#push @{$thisacl->{filterEntry}},$filterEntry;
		$out->print_element( "filterEntry", $filterEntry );
		$out->print_element( "mode",        'stateless');
		$out->print_element( "name",        $thisacl->{name} );
		$out->close_element("filterList");
		$thisacl     = {};
		$filterEntry = {};
	}

	$out->close_element("filterLists");
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
		if ( $commline =~ /^(r[ow])community\s+(\S+)$/i )
		{
			push( @communities, { accessType => uc($1), communityString => $2 } );
		}

		# change trap hosts
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
	if ( $in->{snmp} =~ /^sysContact\s+(.+)$/mi )
	{
		$out->print_element( "sysContact", $1 );
		$someSysPrinted++;
	}

	if ( $in->{snmp} =~ /^sysLocation\s+(.+)$/mi )
	{
		$out->print_element( "sysLocation", $1 );
		$someSysPrinted++;
	}

	if ( $in->{hostname} =~ /^(?:\s*hostname)?\s*(\S+)/mis )
	{
		$out->print_element( "sysName", $1 );
		$someSysPrinted++;
	}

	if ( $someSysPrinted == 3 )
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

	while ( $in->{static_routes} =~ /^\S+\s+([\d\.\/]+)\s+(\S.+)$/mig )
	{
		my $defaultGw    = 'false';
		my $route_blob   = $2;
		my $addresses    = parseCIDR($1);
		my $dest_address = $addresses->{host};
		my $dest_mask    = mask_to_bits ( $addresses->{network} );
		my $route        = {
			destinationAddress => $dest_address,
			destinationMask    => $dest_mask,
		};
		if ( lc($dest_address) eq '0.0.0.0' )
		{
			$defaultGw = 'true';
		}
		$route->{defaultGateway} = $defaultGw;
		if ( $route_blob =~ /\s*via\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\,\s]+)\,\s+cost\s+(\d+)/ )
		{
			$route->{gatewayAddress}  = $1;
			$route->{interface}       = $2;
			$route->{routePreference} = $3;
		}
		if ( $route_blob =~ /\s*is\s+directly\s+connected,\s+(\S+)/ )
		{
			$route->{gatewayAddress} = $route->{destinationAddress};
			$route->{interface}      = $1;
		}
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

		if ( $if_line =~ /^([^:\s]+):(?:\s*(\S+\s+)*)?flags=[^<\s]+<(\S+)>/i )
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
				if ( $if_line =~ /^\s*ether\s+([a-f0-9:]{11,17})\s+speed\s+(10)([KM])\s+(half|full|auto)\s+duplex/i )
				{
					$interface->{interfaceEthernet}->{macAddress} = $1 if ( defined $1 );
					$interface->{speed} = $2;
					my $duplex = $4;
					if ( defined $interface->{speed} )
					{
						my $speed_msrm = $3;
						if ( $speed_msrm =~ /M/i ) { $interface->{speed} = $interface->{speed} * 1000 * 1000; }
						if ( $speed_msrm =~ /K/i ) { $interface->{speed} = $interface->{speed} * 1000; }
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
					if ( ( defined $duplex ) && ( $duplex =~ /auto/i ) )
					{
						$interface->{interfaceEthernet}->{autoDuplex} = "true";
					}
					elsif ( defined $duplex )
					{
						$interface->{interfaceEthernet}->{autoDuplex}        = "false";
						$interface->{interfaceEthernet}->{operationalDuplex} = $duplex;
					}
				}
				elsif ( $if_line =~ /^\s*inet\s+mtu\s+(\d+)\s+(\d+\.\d+\.\d+\.\d+)\/(\d+)\s+broadcast\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*$/i )
				{
					my $if_address = $2;
					my $if_mask    = $3;
					$interface->{mtu} = $1;

					push(
						@{ $interface->{"interfaceIp"}->{"ipConfiguration"} },
						{ broadcast => $4, ipAddress => $if_address, mask => $if_mask, precedence => $order }
					);
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
}

sub parse_stp
{
	my ( $in, $out ) = @_;
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

sub createCPUTypesRE
{
	my @cpuTypes = qw(Pentium Celeron Xeon XeonMP Itanium
	  Athlon AthlonFX Opteron OpteronMP Duron Sempron);
	'\b(' . join( '|', @cpuTypes ) . ')';
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Nokia::Checkpoint::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Nokia::Checkpoint::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
