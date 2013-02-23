package ZipTie::Adapters::Nortel::Passport::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac get_crep getUnitFreeNumber);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Common ip/mask regular expression
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

# Classless InterDomain Routing address regular expression 
our $CIDR_RE	= '\d{1,3}(?:\.\d{1,3}){0,3}\/\d+';

# MAC addresses regular expressions
our $MAC_RE1	= '[0-9a-f]{12}';
our $MAC_RE2	= '[0-9a-f]{1,2}(?:[:\.][0-9a-f]{1,2}){5}';
our $MAC_RE3	= '[0-9a-f]{4}\.[0-9a-f]{4}\.[0-9a-f]{4}';
our $MAC_RE4	= '[0-9a-f]{6}\-[0-9a-f]{6}';

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ($in->{sys_info} =~ /\bSerial#\s+:\s+(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;		
	} 
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Nortel";
	if ($in->{sys_info} =~ /^\s*Chassis\s*:\s*(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	_parse_file_storage( $in, $out );
	
	_parse_memory( $in, $out );
	
	$out->close_element("chassis");
}

sub _parse_cards
{
	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;
	
	my $card = {};
	while ($in->{"cards"} =~ /^(.+)$/mig)
	{
		my $card_line = $1;
		if ($card_line =~ /^\s*Slot\s+(\d+)\s+:\s*$/i)
		{
			if (defined $card->{slotNumber})
			{
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = 'Unknown';
				$out->print_element( "card", $card );
				$card = {};
			}
			$card->{slotNumber} = $1;
			$card->{"core:asset"}->{"core:assetType"}					= "Card";
			$card->{"core:asset"}->{'core:factoryinfo'}->{'core:make'}	= "Nortel";
		}
		elsif ($card_line =~ /^\s*FrontType\s+:\s+(\S+)\s*$/i
				&& defined $card->{slotNumber})
		{
			$card->{"core:description"} = $1;				
		}
		elsif ($card_line =~ /^\s*FrontSerialNum\s+:\s+(\S+)\s*$/i
				&& defined $card->{slotNumber})
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $1;				
		}
		elsif ($card_line =~ /^\s*FrontPartNumber\s+:\s+(\S+)\s*$/i
				&& defined $card->{slotNumber})
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} = $1;				
		}
		elsif ($card_line =~ /^\s*FrontHwVersion\s+:\s+(\S+)\s*$/i
				&& defined $card->{slotNumber})
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = $1;				
		}
		#$card->{"core:asset"}->{"core:factoryinfo"}->{"core:firmwareVersion"} = $2;
	}
	if (defined $card->{slotNumber})
	{
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = 'Unknown';
		$out->print_element( "card", $card );
		$card = {};
	}
}

sub _parse_file_storage
{
	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;

	my $storage = {};
	while ( $in->{'directory'} =~ /^(.+)$/mig )
	{
		my $stLine = $1;
		if ($stLine =~ /^\s*(\d+)\s+\S+\s+\S+\s+(\S.+)$/i)
		{
			my $file = {
				size => $1,
				name => $2,
			};
			$file->{name} =~ s/\s*$//i;
			if ($file->{name} !~ /\s*<DIR>/i)
			{
				if (!defined $storage->{rootDir})
				{
					if ($file->{name} =~ /^\/([^\/]+)\//)
					{
						$storage->{rootDir} = { name => $1, };
					}
					else
					{
						$storage->{rootDir} = { name => 'root', };
					}				
				}
				push( @{ $storage->{rootDir}->{file} }, $file );
			}
		}
		elsif ($stLine =~ /^\s*total:/i)
		{
			$_ = $stLine;
			my ($szfree)  = /free:\s+(\d+)/i;
			my ($sztotal) = /total:\s+(\d+)/i;
			$storage->{storageType} = (lc($storage->{rootDir}->{name}) eq 'flash') ? 'flash' : 'other';
			$storage->{name} = $storage->{rootDir}->{name};
			$storage->{size} = $sztotal;
			$storage->{freeSpace} = $szfree;
			$out->print_element( "deviceStorage", $storage );
			$storage = {};
		}
	}
}

sub _parse_memory
{
	# populate the memory elements of the chassis
	my ( $in, $out ) = @_;

	my @memories = ();
	if ( $in->{sys_perf} =~ /^\s*DramSize:\s+(\d+)\s+(\S+)$/mi )
	{
		push @memories, {'core:description' => 'Dram', kind => 'RAM', size => getUnitFreeNumber($1,$2,'byte')};
	}

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{sys_info} =~ /^\s*SysName\s+:\s+(\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	if ( $in->{sys_sw} =~ /\bPrimaryImageSource\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element('core:make', 'Nortel');
	if ( $in->{config_plain} =~ /\bbox\s+type\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:name', $1);
	}
	if ( $in->{config_plain} =~ /\bsoftware\s+version\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'Passport' );
	$out->close_element('core:osInfo');

	#$out->print_element( 'core:biosVersion', "" );

	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{sys_info} =~ /^\s*SysContact\s+:\s+(\S+)/mi;
	$out->print_element( 'core:contact', $contact );

	# SysUpTime    : 1 day(s), 03:11:19
	if ( $in->{sys_info} =~ /^\s*SysUpTime\s+:\s+(\S.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*year\(s\)?/;
		my ($weeks)   = /(\d+)\s*week\(s\)?/;
		my ($days)    = /(\d+)\s*day\(s\)?/;
		my ($hours)   = /\s*(\d+):\d+:\d+/;
		my ($minutes) = /\s*\d+:(\d+):\d+/;

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

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	# build the simple text configuration
	my $config;
	$config->{'core:context'}    = 'active';
	$config->{'core:mediaType'}  = 'text/plain';
	$config->{'core:name'}       = 'config.cfg';
	$config->{'core:textBlob'}   = encode_base64( $in->{'config'} );
	$config->{'core:promotable'} = 'true';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	# build the simple text configuration
	my $boot_config;
	$boot_config->{'core:context'}    = 'boot';
	$boot_config->{'core:mediaType'}  = 'text/plain';
	$boot_config->{'core:name'}       = 'boot.cfg';
	$boot_config->{'core:textBlob'}   = encode_base64( $in->{'boot_config'} );
	$boot_config->{'core:promotable'} = 'true';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $boot_config );

	# build the simple text configuration
	my $running_config;
	$running_config->{'core:context'}    = 'active';
	$running_config->{'core:mediaType'}  = 'text/plain';
	$running_config->{'core:name'}       = 'running-config';
	$running_config->{'core:textBlob'}   = encode_base64( $in->{'running_config'} );
	$running_config->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running_config );

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
	my ($usrlstBlob) = $in->{users} =~ /^\s+ACCESS\s+LOGIN(.+)/mis;
	$out->open_element("localAccounts");

	while ($usrlstBlob =~ /^\s+(\S+)\s+(\S+)\s+$/mig)
	{
		my $account = { accountName => $2 };
		$account->{accessGroup} = $1;
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

	# set default for Passport community strings
	$out->print_element( "community", {"communityString" => "public", "accessType" => "RO"});
	$out->print_element( "community", {"communityString" => "private", "accessType" => "RW"});
	$out->print_element( "community", {"communityString" => "l1", "accessType" => "RW"});
	$out->print_element( "community", {"communityString" => "l2", "accessType" => "RW"});
	$out->print_element( "community", {"communityString" => "l3", "accessType" => "RW"});
	$out->print_element( "community", {"communityString" => "secret", "accessType" => "RW"});
	
	if ( $in->{sys_info} =~ /^\s*SysContact\s+:\s+(\S+)/mi )
	{
		$out->print_element( "sysContact", $1 );
	}
	if ( $in->{sys_info} =~ /^\s*SysLocation\s+:\s+(\S+)/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}
	if ( $in->{sys_info} =~ /^\s*SysName\s+:\s+(\S+)/mi )
	{
		$out->print_element( "sysName", $1 );
	}
	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;

	my $staticRoutes;
	my ($routeBlob) = $in->{routes} =~ /^\s*Route:(.+)TYPE\s+Legend:/mis; 
	while ( $routeBlob =~ /^\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d+)\s+(\S+)\s*/mig )
	{
		my $route = {
			destinationAddress => $1,
			destinationMask    => mask_to_bits ( $2 ),
			gatewayAddress     => $3,
			defaultGateway     => ($1 ne '0.0.0.0' ? 'false' : 'true'),
			routePreference	   => $4,
			interface		   => $5,
		};
		push( @{ $staticRoutes->{staticRoute} }, $route ); 
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");
	my ($iparpblob)		= $in->{ip_arp};
	my ($portIfBlob)	= $in->{port_if};
	my ($portNameBlob)	= $in->{port_name};
	my ($portOSPF)		= $in->{port_ospf};
	my ($portSTG)		= $in->{port_stg};
	my ($vlanPorts)		= $in->{vlan_ports};
	my ($vlanIPs)		= $in->{vlan_ip};
	$vlanPorts			=~ s/^.+?-+\s*//mis;
	$vlanIPs			=~ s/^.+?-+\s*//mis;
	#my ($portSTGExt)	= $in->{tech} =~ /^\s*Port Stg Extended\s+=+(.+)=+/mis;

	my $cipm = get_crep('cipm');
	my $portIPs;
	while ( $vlanIPs =~ /(\d+)\s+($cipm)\s+($cipm)/mig )
	{
		my $id		= $1;
		my $ip		= $2;
		my $mask	= $3;
		if ( $vlanPorts =~ /\s*$id\s+(\S+)/mi )
		{
			my @ports	= split ( /\,/, $1 );
			foreach ( @ports )
			{
				if ( /^(\d+)\/(\d+)\-(\d+)\/(\d+)$/ )
				{
					if ( $1 ne $3 )
					{
						exit 'Bad response was received';
					}
					for ( $2..$4 )
					{
						$_						= $1.'/'.$_;
						$portIPs->{$_}->{ip}	= $ip;
						$portIPs->{$_}->{mask}	= $mask;
					}
				}
				else
				{
					$portIPs->{$_}->{ip}	= $ip;
					$portIPs->{$_}->{mask}	= $mask;
				}
			}
		}
	}

	while ( $portIfBlob =~ /^\s*(\d+\/\d+)\s+\d+\s+(\S+)\s+\S+\s+\S+\s+(\d+)\s+($MAC_RE2)\s+(\S+)\s+\S+\s*$/mig )
	{
		my $name      = $1;
		my $interface =
		{
			adminStatus		=> $5,
			description		=> $2,
			name          	=> $1,
			interfaceType 	=> get_interface_type($1),
			mtu				=> $3,
			physical      	=> _is_physical($1),
			speed			=> getESMT($2),
		};
		$interface->{interfaceEthernet}->{macAddress} = strip_mac($4);
		my $post_slot = $1;
		if ( $portNameBlob =~ /^\s*$post_slot(?:\s+\S+)?\s+\S+\s+\S+\s+(\S+)\s+\d+\s+\S+\s*$/mi )
		{
			if ( lc($1) eq 'full' || lc($1) eq 'half' )
			{
				$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
				$interface->{interfaceEthernet}->{operationalDuplex}	= lc($1);
			}
			elsif ( lc($1) eq 'auto' )
			{
				$interface->{interfaceEthernet}->{autoDuplex}			= 'true';
			}
		}
		if ( $portOSPF =~ /^\s*$post_slot\s+\S+\s+(\d+)\s+(\d+)\s+(\d+)\s+\d+\s+\S+\s+(?:\S+\s+)?(\S+)\s*$/mi )
		{
			$interface->{interfaceOspf}->{area}				= $4;
			$interface->{interfaceOspf}->{deadInterval}		= $1;
			$interface->{interfaceOspf}->{helloInterval}	= $2;
			$interface->{interfaceOspf}->{routerPriority}	= $3;
		}
 		if ( $portSTG =~ /^\s*(\d+)\s+$post_slot\s+(\d+)\s+(\S+)\s+\S+\s+\S+\s+(\d+)\s+\d+\s+\S+\s*$/mi )
		{
			$interface->{interfaceSpanningTree}->{cost}					= $4;
			$interface->{interfaceSpanningTree}->{state}				= $3;
			$interface->{interfaceSpanningTree}->{priority}				= $2;
			$interface->{interfaceSpanningTree}->{spanningTreeInstance}	= $1;
		}
		if ( $portIPs->{$name}->{ip} )
		{
			push @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, { ipAddress => $portIPs->{$name}->{ip}, mask => mask_to_bits($portIPs->{$name}->{mask}) } ;
		}

		$out->print_element( "interface", $interface );
	}
	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	
	my ($vlanBasicBlob) = $in->{vlan_basic};
	my ($vlanAdvBlob)	= $in->{vlan_advance};
	my ($vlanIPBlob)	= $in->{vlan_ip};

	my $headerPrinted = 0;
    while ($vlanBasicBlob =~ /^\s*(\d+)\s+(\S+)\s+\S.+$/mig)
	{
		my $number = $1;
		my $name = $2;
		my $vlan = { number => $number, name => $name, enabled => 'true'};
		if ($vlanAdvBlob =~ /^\s*$number\s+$name\s+(\S+)/mi)
		{
			push( @{ $vlan->{interfaceMember} }, _full_int_name($1) );
		}
		if ($vlanIPBlob =~ /^\s*$number\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+\S+\s+(\d+)\s+\S.+$/mi)
		{
			$vlan->{mtu} = $1;
		}
		$out->open_element("vlans") if ( !$headerPrinted );
		$headerPrinted = 1;
		$out->print_element( "vlan", $vlan );
	}
	$out->close_element("vlans") if ($headerPrinted);
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;

    while ($in->{stg_config} =~ /^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)(?:\s+\S+)?\s*$/mig)
	{
		my $stgId = $1;
		my $instance = {
			helloTime => $4,
			maxAge => $3,
			priority => $2,
			forwardDelay => $5
		};
		if ($in->{stg_config} =~ /^\s*$stgId\s+(?:[a-f0-9\:]{17})\s+(\d+)\s+\S.+$/mi)
		{
			$instance->{vlan} = $1;
		}
		if ($in->{stg_status} =~ /^\s*\d+\s+([a-f0-9\:]{17})\s+(\d+)\s+(\S)+\s+(\d+)\s*$/mi)
		{
			$instance->{systemMacAddress} = strip_mac($1);
		}
		if ($in->{stg_status} =~ /^\s*(\d+)\s+([a-f0-9\:]{23})\s+(\d+)\s+(\S)+\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/mi)
		{
			$instance->{designatedRootCost} = $3;
			$instance->{designatedRootForwardDelay} = $8;
			$instance->{designatedRootHelloTime} = $6;
			$instance->{designatedRootMacAddress} = strip_mac($2);
			$instance->{designatedRootMaxAge} = $5;
			$instance->{designatedRootPort} = $4;
			$instance->{designatedRootMacAddress} =~ s/^\S{4}//i;
		}
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

sub createCPUTypesRE
{
	my @cpuTypes = qw(Pentium Celeron Xeon XeonMP Itanium
					Athlon AthlonFX Opteron OpteronMP Duron Sempron);
	'\b('.join('|',@cpuTypes).')';
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

# get Ethernet Speed by Media Type
sub getESMT
{
	my $mediaType = shift;

	if ($mediaType =~ /(?:(\d+)(?:\/(\d+))?)(\D\S+)/i)
	{
		return (!defined $2) ? $1 * 1000 * 1000 : $2 * 1000 * 1000;  
	}

	return 0;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Nortel::Passport::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Nortel::Passport::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
