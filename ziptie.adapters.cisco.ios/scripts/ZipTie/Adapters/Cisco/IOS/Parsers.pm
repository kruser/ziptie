package ZipTie::Adapters::Cisco::IOS::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils
  qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep);
use ZipTie::Logger;
use MIME::Base64 'encode_base64';

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_arp parse_cdp parse_routing_neighbors parse_telemetry_interfaces parse_mac_table parse_vtp parse_static_routes parse_vlans parse_stp parse_routing parse_access_ports create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_services parse_mpls parse_qos);

# Class constants.
# The reasonable memory sizes in MBs: 2 to the n-th power.
our @VALID_MEMSIZES = map { 2**$_ } qw(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16);

# The string which collects the sizes from 4 (2**2) MBs to 65536 (2**16) MBs.
# Format the array into a space-padded string.
our $SIZEPATTERNS_STRING = " @VALID_MEMSIZES ";

# The number of KBs in 80 percent of 1 MB.
our $KBS_80PERCENTMB = int( my $volatile = 1024 * 0.8 );

sub parse_routing_neighbors
{
	my ( $in, $out ) = @_;
	my $opened = 0;
	while ( $in->{ospf} =~ /^([\da-f.:]+)\s+\d+\s+\S+\s+\S+\s+([\da-f.:]+)\s+(\S+)\s*$/gm )
	{
		$out->open_element('routingNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol  => 'OSPF',
			routerId  => $1,
			ipAddress => $2,
			interface => $3,
		};
		$out->print_element( 'routingNeighbor', $neighbor );
	}
	while ( $in->{bgp} =~ /^BGP neighbor is ([\da-f:.]+)(.+?)BGP state/gsm )
	{
		$out->open_element('routingNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol  => 'BGP',
			ipAddress => $1,
		};
		my $blob = $2;
		if ( $blob =~ /router ID\s*([\da-f:.]+)/ )
		{
			$neighbor->{routerId} = $1;
		}
		$out->print_element( 'routingNeighbor', $neighbor );
	}
	while ( $in->{eigrp} =~ /^(?:\d+\s+)?([\da-f:.]{3,})\s+(\S+)/gm )
	{
		$out->open_element('routingNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol  => 'EIGRP',
			ipAddress => $1,
			routerId  => $1,
			interface => _full_int_name($2),
		};
		$out->print_element( 'routingNeighbor', $neighbor );
	}
	$out->close_element('routingNeighbors') if ($opened);
}

sub parse_arp
{
	my ( $in, $out ) = @_;
	$out->open_element('arpTable');
	while ( $in->{arp} =~ /^\S+\s+(\S+)\s+\S+\s+(\S+)\s+\S+\s+(\S+)\s*$/mg )
	{
		my $arp = {
			ipAddress  => $1,
			macAddress => strip_mac($2),
			interface  => $3,
		};
		$out->print_element( 'arpEntry', $arp );
	}
	$out->close_element('arpTable');
}

sub parse_cdp
{
	my ( $in, $out ) = @_;
	my $opened = 0;
	while ( $in->{cdp} =~ /^-+\s*$(.+?advertisement.+?)(?=^\s)/msg )
	{
		$out->open_element('discoveryProtocolNeighbors') if ( !$opened );
		$opened = 1;
		my $singleCdpBlob = $1;
		my $neighbor = { protocol => 'CDP', };
		if ( $singleCdpBlob =~ /Device\s*ID:\s*(\S+)/ )
		{
			$neighbor->{sysName} = $1;
		}
		if ( $singleCdpBlob =~ /IP address:\s*(\S+)/i )
		{
			$neighbor->{ipAddress} = $1;
		}
		if ( $singleCdpBlob =~ /Interface:\s*(\S+)/m )
		{
			$neighbor->{localInterface} = $1;
			$neighbor->{localInterface} =~ s/,$//;
		}
		if ( $singleCdpBlob =~ /\(outgoing port\):\s*(\S+)/ )
		{
			$neighbor->{remoteInterface} = $1;
		}
		if ( $singleCdpBlob =~ /Platform:\s*(\b[^,]+)/ )
		{
			$neighbor->{platform} = $1;
		}
		if ( $singleCdpBlob =~ /Version\s*:\s*(.+?)(?=^\s+)/ms )
		{
			$neighbor->{sysDescr} = trim($1);
		}
		$out->print_element( 'discoveryProtocolNeighbor', $neighbor );
	}
	while ( $in->{ndp} =~ /^([A-F:\d]+)\s+\d+\s+([a-f\.\d]+)\s+\S+\s+(\S+)/mig )
	{
		$out->open_element('discoveryProtocolNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol       => 'NDP',
			ipAddress      => $1,
			macAddress     => strip_mac($2),
			localInterface => _full_int_name($3),
		};
		$out->print_element( 'discoveryProtocolNeighbor', $neighbor );
	}
	$out->close_element('discoveryProtocolNeighbors') if ($opened);
}

sub parse_telemetry_interfaces
{
	my ( $in, $out ) = @_;
	my $interfaces;
	while ( $in->{interfaces} =~ /(\S+)\s+(is.+?)(?=^\S)/msg )
	{
		my $blob      = $2;
		my $interface = {
			name       => $1,
			type       => get_interface_type($1),
			inputBytes => 0,
		};
		if ( $blob =~ /line protocol is (down|up)/i )
		{
			$interface->{operStatus} = ucfirst($1);
		}
		if ( $blob =~ /packets input,.*?(\d+)\s*bytes/ )
		{
			$interface->{inputBytes} = $1;
		}
		while ( $blob =~ /Internet\s+address\s+is\s+([\d.:a-fA-F]+)\/(\d+)/gi )
		{
			my $ipEntry = {
				ipAddress => $1,
				mask      => $2,
			};
			push( @{ $interface->{ipEntry} }, $ipEntry );
		}
		push( @{ $interfaces->{interface} }, $interface );
	}
	$out->print_element( 'interfaces', $interfaces );
	return $interfaces;
}

sub parse_mac_table
{
	my ( $in, $out ) = @_;
	my $openedMacTable = 0;
	my $regex;
	if ( $in->{mac} =~ /Vlan\s*Mac Address\s*Type\s*Ports/i )
	{
		$regex = '(\S+)\s*([\da-f.]{14})\s*\S+\s*(\S+)';
	}
	else
	{
		$regex = '(\S+)\s*([\da-f.]{14})\s*\S+\s*(?:Yes|No)\s*(\S+)';
	}
	while ( $in->{mac} =~ /$regex/g )
	{
		if ( !$openedMacTable )
		{
			$out->open_element('macTable');
			$openedMacTable = 1;
		}
		my $macEntry = {
			vlan       => $1,
			macAddress => strip_mac($2),
			interface  => _full_int_name($3),
		};
		$out->print_element( 'macEntry', $macEntry );
	}
	$out->close_element('macTable') if ($openedMacTable);
}

sub parse_vtp
{
	my ( $in, $out ) = @_;
	my $vtp;

	if ( $in->{vtp_status} =~ /^VTP Version\s*:\s*(\d+)$/mi )
	{
		$vtp->{'cisco:version'} = $1;
	}
	if ( $in->{vtp_status} =~ /^Configuration Revision\s*:\s*(\d+)$/mi )
	{
		$vtp->{'cisco:configVersion'} = $1;
	}
	if ( $in->{vtp_status} =~ /^Maximum VLANs supported locally\s*:\s*(\d+)$/mi )
	{
		$vtp->{'cisco:maxVlanCount'} = $1;
	}
	if ( $in->{vtp_status} =~ /^Number of existing VLANs\s*:\s*(\d+)$/mi )
	{
		$vtp->{'cisco:vlanCount'} = $1;
	}
	if ( $in->{vtp_status} =~ /^VTP Operating Mode\s*:\s*(\S+)$/mi )
	{
		$vtp->{'cisco:localMode'} = $1;
	}
	if ( $in->{vtp_status} =~ /^VTP Domain Name\s*:\s*(\S+)$/mi )
	{
		$vtp->{'cisco:domainName'} = $1;
	}
	if ( $in->{vtp_status} =~ /^VTP Pruning Mode\s*:\s*(\S+)$/mi )
	{
		$vtp->{'cisco:vlanPruningEnabled'} = ( $1 =~ /enabled/i ) ? 'true' : 'false';
	}
	if ( $in->{vtp_status} =~ /^VTP V2 Mode\s*:\s*(\S+)$/mi )
	{
		$vtp->{'cisco:v2Mode'} = $1;
	}
	if ( $in->{vtp_status} =~ /^VTP Traps Generation\s*:\s*(\S+)$/mi )
	{
		$vtp->{'cisco:alarmNotificationEnabled'} = ( $1 =~ /enabled/i ) ? 'true' : 'false';
	}
	if ( $in->{vtp_status} =~ /^MD5 digest\s*:\s*(.*[^\s])$/mi )
	{
		$vtp->{'cisco:password'} = $1;
	}
	if ( $in->{vtp_status} =~ /^last modified by\s+(\S+)/mi )
	{
		$vtp->{'cisco:lastUpdater'} = $1;
	}
	$vtp->{'cisco:serviceType'} = "vtp" if ( defined $vtp->{localMode} );

	$out->print_element( "cisco:vlanTrunking", $vtp );
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	my $staticRoutes;
	while ( $in->{running_config} =~ /^ip route\s+(\d+\.\S+)\s+(\d+\.\S+)\s+(\S+)(.*)/mig )
	{
		my $route = {
			destinationAddress => $1,
			destinationMask    => mask_to_bits($2),
		};
		my $gateway   = $3;
		my $remainder = $4;

		if ( $gateway =~ /\d+\.\d+\.\d+\.\d+/ )
		{
			$route->{gatewayAddress} = $gateway;
		}
		else
		{
			$route->{interface} = $gateway;
		}

		if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0' ) )
		{
			$route->{defaultGateway} = 'true';
		}
		else
		{
			$route->{defaultGateway} = 'false';
		}

		if (
			( defined $remainder )
			&& (   ( $remainder =~ /^\s*(\d+)\s*$/ )
				|| ( $remainder =~ /^\s*(\d+)\s+.*$/ )
				|| ( $remainder =~ /^\s*\S+\s+(\d+)\s+.*$/ ) )
		  )
		{
			$route->{routePreference} = $1;
		}
		$route->{interface} = _pick_subnet( $route, $subnets );
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
	if ( $in->{running_config} =~ /^ip default-gateway\s+(\d+\.\d+\.\d+\.\d+)\s*$/im )
	{
		my $route = {
			destinationAddress => '0.0.0.0',
			destinationMask    => '0',
			gatewayAddress     => $1,
			defaultGateway     => 'true',
		};
		$route->{interface} = _pick_subnet( $route, $subnets );
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub _pick_subnet
{

	# choose from a hash of subnets and return the matching value
	my ( $route, $subnets ) = @_;
	if ( $route->{interface} )
	{
		return $route->{interface};
	}
	elsif ( defined $subnets )
	{
		foreach my $interfaceName ( sort ( keys(%$subnets) ) )
		{
			my @subnetsArray = @{ $subnets->{$interfaceName} };
			foreach my $subnet (@subnetsArray)
			{
				if ( $subnet->contains( $route->{gatewayAddress} ) )
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

sub parse_chassis
{
	my ( $in, $out ) = @_;

	my $cpuref;
	my $cpuid           = -1;
	my $description     = "";
	my $systemimagefile = "";
	my $activeslot      = "";
	my $mac             = "";

	my ( $flashpbtype, $flashpbname, $flashpbsize ) = ( 0, 0, -1 );
	my ( $flashpc0type, $flashpc0name, $flashpc0size, $flashpc0num ) = ( 0, 0, -1, 0 );
	my ( $flashpc1type, $flashpc1name, $flashpc1size, $flashpc1num ) = ( 0, 0, -1, 0 );
	my ( $flashpu0type, $flashpu0name, $flashpu0size, $flashpu0num ) = ( 0, 0, -1, 0 );
	my ( $flashpu1type, $flashpu1name, $flashpu1size, $flashpu1num ) = ( 0, 0, -1, 0 );
	my ( $flashp1type,  $flashp1name,  $flashp1size,  $flashp1num )  = ( 0, 0, -1, 0 );
	my ( $flashp2type,  $flashp2name,  $flashp2size,  $flashp2num )  = ( 0, 0, -1, 0 );
	my ($dualFlashFlag) = 0;
	my ( $configMemory, $ramMemory, $packetMemory, $processorBoard );
	my ( $ciscoModel, $serialNumber ) = ( 0, 0 );

	foreach my $line ( split( /\n/, $in->{version} ) )
	{
		if (   ( $line =~ /Cisco \S+\s+\((.*)\) processor\s+.*\s+with \S+ bytes of memory/i )
			or ( $line =~ /Cisco \S+\s+\((.*)\) processor with \S+ bytes of memory./i ) )
		{
			$cpuid          = 0;
			$processorBoard = $1;
		}
		elsif (( $line =~ /^(\S+\s+CPU\s+at\s+\S+,.*)/i )
			or ( $line =~ /^(\S+)\s+CPU\s+at\s+\S+,.*/i )
			or ( $line =~ /Cisco Catalyst ([19|28].*\s+processor) with \S+ bytes of memory/i )
			or ( $line =~ /CPU part number (\w+)/i ) )
		{
			$cpuid       = 0;
			$description = $1;
		}
		elsif ( $line =~ /System\s+image\s+file\s+is\s+"(\S+)"/i )
		{
			$systemimagefile = $1;
			if ( $systemimagefile =~ /(\S+):(\S+)/i )
			{
				$activeslot = $1;
			}
			elsif ( $line =~ /System\s+image\s+file\s+is\s+"\S+".*via\s+([A-Za-z]+)/i )
			{
				$activeslot = $1;
			}
		}

		#20480K bytes of Flash PCMCIA card at slot 0 (Sector size 128K).
		#20480K bytes of Flash PCMCIA card at slot 1 (Sector size 128K).
		elsif ( $line =~ /(\d+)K bytes of Flash PCMCIA card at (\w+) (\d) \(/i )
		{
			$dualFlashFlag = 1;
			if ( $3 == 0 )
			{
				( $flashpc0type, $flashpc0name, $flashpc0size, $flashpc0num ) = ( $2 . $3, "pcmciacard", $1, 0 );
			}
			elsif ( $3 == 1 )
			{
				( $flashpc1type, $flashpc1name, $flashpc1size, $flashpc1num ) = ( $2 . $3, "pcmciacard", $1, 1 );
			}
		}

		#20480K bytes of processor board PCMCIA Slot0 flash (Read/Write)
		#20480K bytes of processor board PCMCIA Slot1 flash (Read/Write)
		elsif ( $line =~ /(\d+)K bytes of processor board PCMCIA (\w+) flash \(/i )
		{
			$dualFlashFlag = 1;
			my ( $flashsize, $slotnum ) = ( $1, $2 );
			if ( $slotnum =~ /0/ )
			{
				( $flashpu0type, $flashpu0name, $flashpu0size, $flashpu0num ) =
				  ( lcfirst($slotnum), "pcmcia", $flashsize, 0 );
			}
			elsif ( $slotnum =~ /1/ )
			{
				( $flashpu1type, $flashpu1name, $flashpu1size, $flashpu1num ) =
				  ( lcfirst($slotnum), "pcmcia", $flashsize, 1 );
			}
		}

		#8192K bytes of processor board System flash partition 1 (Read/Write)
		elsif ( $line =~ /(\d+)K bytes of processor board System flash partition 1 \(/i )
		{
			$dualFlashFlag = 1;
			( $flashp1type, $flashp1name, $flashp1size, $flashp1num ) = { "flash", "partition", $1, 1 };
		}

		#8192K bytes of processor board System flash partition 2 (Read/Write)
		elsif ( $line =~ /(\d+)K bytes of processor board System flash partition 2 \(/i )
		{
			$dualFlashFlag = 1;
			( $flashp2type, $flashp2name, $flashp2size, $flashp2num ) = ( "flash", "partition", $1, 2 );
		}

		#8192K bytes of processor board System flash (Read/Write)
		elsif ( $line =~ /(\d+)K bytes of processor board System flash \(/i )
		{
			$dualFlashFlag = 1;
			( $flashpbtype, $flashpbname, $flashpbsize ) = ( "flash", "none", $1 );
		}

		# Configuration memory, RAM, Packet memory sizes.
		if (   ( $line =~ /Cisco\s+.*with\s+(\d+)K\/(\d+)K\s+bytes of .*memory/i )
			or ( $line =~ /processor.*with\s+(\d+)K\/(\d+)K\s+bytes of .*memory/i ) )
		{

			# See bug #7740 for more information on ramMemory and packetMemory
			( $ramMemory, $packetMemory ) = ( $1, $2 );

			# Round up the ram size, if residue > 819 KBs (80% of 1 MB).
			my $roundup = $ramMemory % 1024 > $KBS_80PERCENTMB ? 1 : 0;
			my $ramMBs = int( my $volatile = $ramMemory / 1024 ) + $roundup;

			# Use the ram size value, if it is reasonable (2**n);
			# Otherwise, choose the (ram+packet) sum as the size value.
			$ramMemory +=
			  ( $SIZEPATTERNS_STRING =~ /\s($ramMBs)\s/ )
			  ? 0
			  : $packetMemory;
		}
		elsif ( $line =~ /Cisco\s+.*with\s+(\d+)K\s+bytes of .*memory/i )
		{
			$ramMemory = $1;
		}
		if (   ( $line =~ /(\d+)K bytes of non-volatile configuration memory/i )
			or ( $line =~ /(\d+)K bytes of flash-simulated non-volatile configuration memory./i ) )
		{
			$configMemory = $1;
		}
		elsif ( $line =~ /(\d+)K bytes of NVRAM/i )
		{
			$configMemory = $1;
		}

		if ( $line =~ /^IOS\s+\(tm\)\s+c(16|17|26|29)\d\d(XL)?\s+Software.*/i )
		{
			$ciscoModel = $1;
		}

		if ( defined $ciscoModel && $ciscoModel =~ /^16$|^17$|^26$/ )
		{
			if ( $line =~ /^Processor\s+board\s+ID\s+(\w+)\s+(\(\d+\))/i )
			{
				$serialNumber = $1;
			}
		}
		if ( defined $ciscoModel && $ciscoModel == 29 )
		{
			if (   ( $line =~ /System\s+serial\s+number:\s+(\S+)/i )
				or ( $line =~ /System\s+serial\s+number\s+:\s+(\S+)/i ) )
			{
				$serialNumber = $1;
			}
		}
		else
		{
			if ( $line =~ /^Processor\s+board\s+ID\s+([^,]+)/i )
			{
				$serialNumber = $1;
			}
		}
	}

	# only use the SNMP Chassis ID if it is longer than 5 chars
	if ( $in->{snmp} =~ /^Chassis:\s*(\S{5,})/mi )
	{
		$serialNumber = $1;
	}

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $serialNumber if $serialNumber;
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";
	if ( $in->{version} =~ /^(?:Product\/)?Model number\s*:\s*(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^cisco\s+((?:WS-C|Cat|AS|C|VG)?\d{3,4}\S*\b)\S*\b/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^cisco\s+((?:SOHO)?\d{2}\S*\b)\S*\b/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^cisco\s+((?:uBR)?\d{3}\S*\b)\S*\b/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^Cisco\s+(\S+)(?:\s\(\S+\))?\s*processor.+?(?=with)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^Cisco\s+(\S+)\s.+?Voice\sLinecard.+?\sprocessor(?:\s\(.+?\))? with/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^cisco\s+catalyst\s+(\d{3,4})\s/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{version} =~ /^cisco CISCO(\d+) [(]R\d+[)] processor [(]revision/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	$out->print_element( "core:asset", $chassisAsset );

	# chassis/core:description
	if ( $in->{version} =~ /(^Cisco\s+(?:Internetwork\s+Operating\s+System|IOS)\s+Software.+^Compiled.+?$)/msi )
	{
		$out->print_element( "core:description", $1 );
	}
	elsif ( $in->{version} =~ /(Cisco Catalyst .* Enterprise Edition Software.+Copyright.+?$)/msi )
	{
		$out->print_element( "core:description", $1 );
	}

	_parse_cards( $in, $out );
	my $cpu;
	$cpu->{"core:description"} = $description if $cpuid != -1 and $description;
	$cpu->{cpuType} = $processorBoard if $cpuid != -1 and $processorBoard;
	$out->print_element( "cpu", $cpu );
	_parse_file_storage( $in, $out );

	# Chassis->MACAddress
	if ( $in->{version} =~ /Base\sEthernet\s(?:MAC |)Address:\s+([^\s]+)/msi )
	{
		$mac = $1;
	}
	elsif ( $in->{version} =~ /Ethernet\sAddress:\s+([^\s]+)/msi )
	{
		$mac = $1;
	}
	if ($mac)
	{
		$mac =~ s/[^\da-z]//gi;
		$out->print_element( "macAddress", $mac );
	}

	my @memories = ();
	push @memories, { kind => 'Flash', size => $flashpbsize * 1024 }  if $flashpbsize != -1  and $flashpbtype  ne "";
	push @memories, { kind => 'Flash', size => $flashpc0size * 1024 } if $flashpc0size != -1 and $flashpc0type ne "";
	push @memories, { kind => 'Flash', size => $flashpc1size * 1024 } if $flashpc1size != -1 and $flashpc1type ne "";
	push @memories, { kind => 'Flash', size => $flashpu0size * 1024 } if $flashpu0size != -1 and $flashpu0type ne "";
	push @memories, { kind => 'Flash', size => $flashpu1size * 1024 } if $flashpu1size != -1 and $flashpu1type ne "";
	push @memories, { kind => 'Flash', size => $flashp1size * 1024 }  if $flashp1size != -1  and $flashp1type  ne "";
	push @memories, { kind => 'Flash', size => $flashp2size * 1024 }  if $flashp2size != -1  and $flashp2type  ne "";
	push @memories, { 'core:description' => 'RAM', kind => 'RAM', size => $ramMemory * 1024 } if $ramMemory;
	push @memories, { 'core:description' => 'PacketMemory', kind => 'PacketMemory', size => $packetMemory * 1024 }
	  if $packetMemory;
	push @memories, { kind => 'ConfigurationMemory', size => $configMemory * 1024 } if $configMemory;

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	# Power supply parsing
	my $foundPowerSupplies;
	if ( defined $in->{'show_power'} && $in->{'show_power'} =~ /(^PS.+?)(?=^\s)/ms )
	{
		my $psBlob = $1;
		if ( $in->{'show_power'} =~ /Supply\s+Model\s+No\s+Type\s+Status/ )
		{

			# 4000 chassis
			while ( $psBlob =~ /^PS(\d+)\s+(\S+)\s+(\S+.+?W\b)\s+(\S+)/mg )
			{
				my $number = $1;
				my $powerSupply = { number => $number, };
				$powerSupply->{'core:asset'}->{'core:assetType'}                         = "PowerSupply";
				$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = "Unknown";
				$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = "Unknown";
				$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:partNumber'}  = $2;
				$powerSupply->{'core:description'}                                       = $3;

				my $status = $4;
				if ( $status =~ /good/i )
				{
					$status = "OK";
				}
				else
				{
					$status = "Fault";
				}
				$powerSupply->{'status'} = $status;

				$out->print_element( "powersupply", $powerSupply );
				$foundPowerSupplies = 1;
			}
		}
		else
		{
			while ( $psBlob =~ /(\d+)\s+(\S+)\s+(\d+.\d\d)\s+(\d+.\d\d)\s+(OK|\S+)\s+(OK|\S+)\s+(on|off)/mg )
			{
				my $number      = $1;
				my $status      = $6;
				my $powerSupply = { number => $number, };
				$powerSupply->{'core:asset'}->{'core:assetType'}                         = "PowerSupply";
				$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = "Unknown";
				$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = "Unknown";
				$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:partNumber'}  = $2;
				if ( $in->{'show_inventory'} =~ /PS\s+$number\b.+?DESCR:\s"(.+?)".+?SN:\s+(\S+)/s )
				{
					$powerSupply->{'core:description'} = $1;
					$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} = $2;
				}

				if ( $status =~ /OK/i )
				{
					$status = "OK";
				}
				else
				{
					$status = "Fault";
				}
				$powerSupply->{'status'} = $status;

				$out->print_element( "powersupply", $powerSupply );
				$foundPowerSupplies = 1;
			}
		}
	}

	# for Catalyst 3000 series switches
	if ( ( $in->{version} =~ /Power\s+supply\s+part\s+number\s*:\s+(\S+)/i ) && !$foundPowerSupplies )
	{
		my $powerSupply = { number => 1, };
		$powerSupply->{'core:asset'}->{'core:assetType'}                         = "PowerSupply";
		$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = "Unknown";
		$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = "Unknown";
		$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:partNumber'}  = $1;
		if ( $in->{version} =~ /Power\s+supply\s+serial\s+number\s*:\s+(\S+)/i )
		{
			$powerSupply->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
		}
		$out->print_element( "powersupply", $powerSupply );
	}
	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{running_config} =~ /^hostname (\S+)/m;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	if ( $in->{version} =~ /^System image file is "([^"]+)/m )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Cisco' );
	if ( $in->{version} =~ /^(IOS.+?),/m )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{version} =~ /^(?:Cisco )?IOS.+Version (\S[^\s,]+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	elsif ( $in->{version} =~ /^Version\s+V(\d+\.\d+\.\d+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'IOS' );
	$out->close_element('core:osInfo');

	if (   ( $in->{version} =~ /ROM:\s+System\s+Bootstrap[,]\s+Version\s+([^\s,]+)/i )
		or ( $in->{version} =~ /ROM:\s+Bootstrap\s+program\s+is\s+(.*)/i )
		or ( $in->{version} =~ /BOOTLDR:\s+\S+\s+Boot\s+Loader.*Version\s+([^\s,]+)/i )
		or ( $in->{version} =~ /^ROM:\s+TinyROM\s+version\s+([^\s]+)/mi )
		or ( $in->{version} =~ /^ROM:\s+([^\s]+)/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	if ( $in->{version} =~ /\b(cat|(WS|ME)-C)\d{4}|catalyst|CIGESM/i )
	{
		$out->print_element( 'core:deviceType', 'Switch' );
	}
	elsif ( $in->{version} =~ /\bC1200\b|\bAIR/ )
	{
		$out->print_element( 'core:deviceType', 'Wireless Access Point' );
	}
	else
	{
		$out->print_element( 'core:deviceType', 'Router' );
	}

	my ($contact) = $in->{running_config} =~ /^snmp-server contact (.+)/m;
	$out->print_element( 'core:contact', $contact );

	# System restarted at 18:00:01 CST Sun Feb 28 1993
	if ( $in->{version} =~
		/^System restarted (?:by \S+\s)?at\s+(\d{1,2}:\d{1,2}:\d{1,2})\s+(\S+)\s+\S+\s+(\S+)\s+(\d{1,2})\s+(\d{4})/mi )
	{
		my $year     = $5;
		my $month    = $3;
		my $day      = $4;
		my $time     = $1;
		my $timezone = $2;

		my ( $hour, $min, $sec ) = $time =~ /(\d+):(\d+):(\d+)/;

		$out->print_element( "core:lastReboot",
			seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
	}
	elsif ( $in->{version} =~ /uptime is\s+(.+)/i )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;

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

sub parse_vlans
{

	# "show vlan" output parsing into the ZED Vlan model
	my ( $in, $out ) = @_;
	if ( $in->{vlans} =~ /^VLAN\s+Name\s+Status\s+Ports(.+?)^\s*$/msi )
	{

		# IOS output

		# create a variable with only section 2 data
		my $section2;
		while ( $in->{vlans} =~
			/^VLAN\s+Type\s+SAID\s+MTU\s+Parent\s+RingNo\s+BridgeNo\s+Stp\s+BrdgMode\s+Trans1\s+Trans2(.+?)^\s*$/msig )
		{
			$section2 .= $1;
		}

		my $section1      = $1 . "\nEND";
		my $headerPrinted = 0;
		while ( $section1 =~ /^(\d+)\s+(\S+)\s+(\S+)(.*?)(?=^\b)/msg )
		{
			$out->open_element("vlans") if ( !$headerPrinted );
			$headerPrinted = 1;

			my $number = $1;
			my $name   = $2;
			my $status = $3;
			my $ports  = $4;

			my $vlan = { number => $number, name => $name, };
			if ( $status =~ /^act/i )
			{
				$vlan->{enabled} = "true";
			}
			else
			{
				$vlan->{enabled} = "false";
			}

			if ($ports)
			{
				foreach my $line ( split /\n/, $ports )
				{
					foreach my $port ( split /,/, $line )
					{
						push( @{ $vlan->{interfaceMember} }, _full_int_name($port) );
					}
				}
			}

			if ( $section2 =~
				/^$number+\s+(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+\s+(\S+)\s+(\d+)\s+(\d+)/m )
			{
				$vlan->{implementationType} = $1;
				$vlan->{said}               = $2;
				$vlan->{mtu}                = $3;
				$vlan->{parent}             = $4 if ( $4 ne "-" );
				$vlan->{ringNumber}         = $5 if ( $5 ne "-" );
				$vlan->{bridgeNumber}       = $6 if ( $6 ne "-" );
				$vlan->{bridgeMode}         = $7 if ( $7 ne "-" );
				$vlan->{translationBridge1} = $8;
				$vlan->{translationBridge2} = $9;
			}

			$out->print_element( "vlan", $vlan );
		}
		$out->close_element("vlans") if ($headerPrinted);
	}
	else
	{

		# MSFC output
		my $headerPrinted = 0;
		while ( $in->{vlans} =~ /Virtual LAN ID:\s+(\d+)\s+(.+?)(?=^\S)/msig )
		{
			$out->open_element("vlans") if ( !$headerPrinted );
			$headerPrinted = 1;
			my $vlan = {
				number  => $1,
				name    => "vlan" . $1,
				enabled => "true",
			};
			my $blob = $2;
			while ( $blob =~ /VLAN Trunk Interface:\s+(\S+)/gi )
			{
				push( @{ $vlan->{interfaceMember} }, _full_int_name($1) );
			}
			$out->print_element( "vlan", $vlan );
		}
		$out->close_element("vlans") if ($headerPrinted);
	}

}

sub create_config
{

	# Populates the configuration entity for the main IOS configs
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( _apply_masks( $in->{"running_config"} ) );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{"core:promotable"} = "false";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	if ( defined $in->{"startup_config"} )
	{
		my $startup;
		$startup->{"core:name"}       = "startup-config";
		$startup->{"core:textBlob"}   = encode_base64( _apply_masks( $in->{"startup_config"} ) );
		$startup->{"core:mediaType"}  = "text/plain";
		$startup->{"core:context"}    = "boot";
		$startup->{"core:promotable"} = "true";

		# push the configuration into the repository
		push( @{ $repository->{'core:config'} }, $startup );
	}

	# print the repository
	$out->print_element( "core:configRepository", $repository );
}

sub parse_local_accounts
{

	# local accounts - local usernames
	my ( $in, $out ) = @_;
	my $c = $in->{running_config};
	$out->open_element("localAccounts");

	while ( $c =~ /^username\s+([^\s]+)\s+(.+)/mig )
	{
		my $account = { accountName => $1, };
		my $userconfig = $2;
		if ( $userconfig =~ /privilege\s+([^\s]+)/ )
		{
			$account->{accessLevel} = $1;
		}
		if ( $userconfig =~ /password\s+([^\s]+)\s+([^\s]+)/ )
		{
			$account->{password} = $2;
		}
		$out->print_element( "localAccount", $account );
	}

	# local accounts - enable and enable secret
	while ( $c =~ /^enable\s+(\S+)\s+(level\s)?(\d*)\s?([^\s]+)/mig )
	{
		my $enabletype = $1;
		my $username   = "enable";
		my $encryption = $3;
		if ( $encryption eq "" )
		{
			$encryption = "0";
		}

		if ( $enabletype eq "secret" ) { $username = "enablesecret"; }
		my $account = {
			accountName => $username,
			password    => $4,
			accessLevel => 15,
		};
		$out->print_element( "localAccount", $account );
	}
	$out->close_element("localAccounts");

}

sub parse_filters
{
	my ( $in, $out ) = @_;
	my $timeRanges         = parse_time_range($in);
	$out->open_element('filterLists');
	my $lineNumber = 0;
	my $processOrder = 0;
	my $currentList;
	
	foreach my $line ( split( /\n/, $in->{running_config} ) )
	{
		$lineNumber++;
		if ( $line =~ /^ip access-list\s+(extended|dynamic|standard)\s+(.+\b)/ )
		{
			if ($currentList)
			{
				$processOrder = 0;
				_close_list($currentList, $out);
				undef $currentList;
			}
			$currentList = {
				type     => $1,
				protocol => 'ip',
				name     => $2,
			};
			$out->open_element('filterList configPath="running-config"');
		}
		elsif ($line =~ /^ipv6 access-list\s+(\b.+\b)/)
		{
			if ($currentList)
			{
				$processOrder = 0;
				_close_list($currentList, $out);
				undef $currentList;
			}
			$currentList = {
				type     => 'ipv6',
				protocol => 'ipv6',
				name     => $1,
			};
			$out->open_element('filterList configPath="running-config"');
		}
		elsif ($line =~ /^access-list\s+(\d+)(\s+.+)/)
		{
			my $aclNumber = $1;
			my $aceBody = $2;
			if ($currentList && $currentList->{name} ne $aclNumber)
			{
				_close_list($currentList, $out);
				undef $currentList;
			}
			
			if (!$currentList)
			{
				$processOrder = 0;
				$currentList = {
					protocol => 'ip',
					name     => $aclNumber,
				};
				$out->open_element('filterList configPath="running-config"');
			}
			if ($line !~ /\s+remark/i)
			{
				if ($aclNumber < 100)
				{
					_standard_term( $aceBody, $processOrder, $lineNumber, $timeRanges, $out);	
				}
				else 
				{
					_extended_term( $aceBody, $processOrder, $lineNumber, $timeRanges, $out);	
				}
				$processOrder++;
			}
		}
		elsif ($line =~ /^\S/)
		{
			if ($currentList)
			{
				$processOrder = 0;
				_close_list($currentList, $out);
			}
			undef $currentList;
		}
		elsif ($currentList && $line !~ /^\s*remark/)
		{
			if ($currentList->{type} =~ /standard/i)
			{
				_standard_term( $line, $processOrder, $lineNumber, $timeRanges, $out);	
			}
			elsif ($currentList->{type} =~ /extended/i)
			{
				_extended_term( $line, $processOrder, $lineNumber, $timeRanges, $out);	
			}
			elsif ($currentList->{type} =~ /ipv6/i)
			{
				_extended_term( $line, $processOrder, $lineNumber, $timeRanges, $out, 'ipv6');	
			}
			$processOrder++;
		}
	}
	$out->close_element('filterLists');
}

sub _close_list
{
	my ( $list, $out ) = @_;
	$out->print_element('mode', 'stateless');
	$out->print_element('name', $list->{name});
	$out->close_element('filterList');
}

sub _get_any
{
	my $ipv6 = shift;
	if ($ipv6)
	{
		return { address => '::', mask => '0' };
	}
	else
	{
		return { address => '0.0.0.0', mask => '0' };
	}
}

# process a standard term:
sub _standard_term
{
	my ( $acl_line, $term_process_order, $lineNumber, $time_range, $out ) = @_;
	my $thisterm = { processOrder => $term_process_order, };
	$thisterm->{'-attributes'} = {lineStart=>$lineNumber, lineEnd=>$lineNumber,};
	if ( $acl_line =~ /^\s*(no permit|permit|deny)\s+(any)/i )
	{
		my $primaryAction = $1;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"}  = $primaryAction;
		push @{ $thisterm->{'sourceIpAddr'}->{'network'} }, _get_any();
	}
	elsif ( $acl_line =~ /^\s*(no permit|permit|deny)\s+(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/i )
	{
		my $primaryAction = $1;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;

		my $thisIPAddress = {
			"address" => $2,
			"mask"    => mask_to_bits( _inverse_wildcard_mask($3) ),
		};
		push @{ $thisterm->{"sourceIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /^\s*(no permit|permit|deny)\s+host\s+(\d+\.\d+\.\d+\.\d+)/i )
	{
		my $primaryAction = $1;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;
		my $thisIPAddress = { "host" => $2, };
		push @{ $thisterm->{"sourceIpAddr"} }, $thisIPAddress;
	}
	elsif (
		$acl_line =~ /^\s*(no permit|permit|deny)\s+(\d+\.\d+\.\d+\.\d+),\s+wildcard\s+bits\s+(\d+\.\d+\.\d+\.\d+)/i )
	{
		my $primaryAction = $1;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;
		my $thisIPAddress = {
			"address" => $2,
			"mask"    => mask_to_bits( _inverse_wildcard_mask($3) ),
		};
		push @{ $thisterm->{"sourceIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /^\s*(no permit|permit|deny)\s+(\d+\.\d+\.\d+\.\d+)/i )
	{
		my $primaryAction = $1;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;
		my $thisIPAddress = { "host" => $2, };
		push @{ $thisterm->{"sourceIpAddr"} }, $thisIPAddress;
	}

	if ( $acl_line =~ /\s+log\s*$/ )
	{
		$thisterm->{log} = "true";
	}
	else
	{
		$thisterm->{log} = "false";
	}

	# look for the time-range instruction
	if ( $acl_line =~ /\btime-range\s+(\S+)/i )
	{
		$thisterm->{timeAllowed} = $time_range->{$1};
	}
	$out->print_element('filterEntry', $thisterm);
}

sub _extended_term
{
	# process an extended term:
	my ( $acl_line, $term_process_order, $lineNumber, $time_range, $out, $ipv6 ) = @_;
	my $thisterm = { processOrder => $term_process_order, };
	$thisterm->{'-attributes'} = {lineStart=>$lineNumber, lineEnd=>$lineNumber,};
	my $ipaddresses = [];

	# permit/deny and dynamic acl settings
	if ( $acl_line =~ /^\s*(no permit|deny|permit)/i )
	{
		my $primaryAction = $1;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;
	}
	elsif ( $acl_line =~ /^\s*dynamic\s+(\S+)\s+timeout\s+(\S+)\s+(no permit|deny|permit)/i )
	{
		my $primaryAction = $3;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;
	}
	elsif ( $acl_line =~ /^\s*dynamic\s+(\S+)\s+(no permit|deny|permit)/i )
	{
		my $primaryAction = $2;
		if ( $primaryAction eq "no permit" )
		{
			$primaryAction = "deny";
		}
		$thisterm->{"primaryAction"} = $primaryAction;
	}
	else
	{
		return; 
	}

	# set term protocol
	if ( $acl_line =~ /^\s*(no permit|deny|permit)\s+(\S+)\s+/i )
	{
		$thisterm->{"protocol"} = $2;
	}

	# choose source address format
	my $srctext;
	if ( $acl_line =~ /^(\s*(no permit|deny|permit)\s+\S+\s+any)\s+/i )
	{
		$srctext = $1;
		push @{ $thisterm->{"sourceIpAddr"}->{network} }, _get_any($ipv6);
	}
	elsif ( $acl_line =~ /^(\s*(no permit|deny|permit)\s+\S+\s+(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+))\s+/i )
	{
		$srctext = $1;
		my $thisIPAddress = {
			"address" => $3,
			"mask"    => mask_to_bits( _inverse_wildcard_mask($4) ),
		};
		push @{ $thisterm->{"sourceIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ($ipv6 && $acl_line =~ /^(\s*(no permit|deny|permit)\s+\S+\s+([a-f\d:]+)\/(\d+))\s+/i )
	{
		$srctext = $1;
		my $thisIPAddress = {
			"address" => $3,
			"mask"    => $4,
		};
		push @{ $thisterm->{"sourceIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~
		/^(\s*(no permit|deny|permit)\s+\S+\s+(\d+\.\d+\.\d+\.\d+),\s+wildcard\s+bits\s+(\d+\.\d+\.\d+\.\d+))\s+/i )
	{
		$srctext = $1;
		my $thisIPAddress = {
			"address" => $3,
			"mask"    => mask_to_bits( _inverse_wildcard_mask($4) ),
		};
		push @{ $thisterm->{"sourceIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /^(\s*(no permit|deny|permit)\s+\S+\s+host\s+(\d+\.\d+\.\d+\.\d+|[a-f\d:]+))\s+/i )
	{
		$srctext = $1;
		my $thisIPAddress = { "host" => $3, };
		push @{ $thisterm->{"sourceIpAddr"} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /^(\s*(no permit|deny|permit)\s+\S+\s+(\d+\.\d+\.\d+\.\d+))\s+/i )
	{
		$srctext = $1;
		my $thisIPAddress = { "host" => $3, };
		push @{ $thisterm->{"sourceIpAddr"} }, $thisIPAddress;
	}

	# now look for the src port
	my $srcport = "";
	if ( $acl_line =~ /$srctext\s+((lt|gt|eq|neq)\s+(\S+))/i )
	{
		$srcport = $1;
		my $operator = $2;
		if ( $operator =~ /neq/ )
		{
			$operator = "ne";
		}
		my $thisport = {
			"port"     => _int_port($3),
			"operator" => $operator,
		};
		push @{ $thisterm->{"sourceService"}->{portExpression} }, $thisport;
	}
	elsif ( $acl_line =~ /$srctext\s+(range\s+(\S+)[-\s](\S+))/i )
	{
		my $thisport = {
			"portStart" => _int_port($2),
			"portEnd"   => _int_port($3),
		};
		push @{ $thisterm->{"sourceService"}->{portRange} }, $thisport;
	}

	# destination address
	my $dsttext;
	if ( $acl_line =~ /$srctext\s*$srcport\s*(any)/i )
	{
		$dsttext = $1;
		push @{ $thisterm->{"destinationIpAddr"}->{network} }, _get_any($ipv6);
	}
	elsif ( $acl_line =~ /$srctext\s*$srcport\s*((\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+))/i )
	{
		$dsttext = $1;
		my $thisIPAddress = {
			"address" => $2,
			"mask"    => mask_to_bits( _inverse_wildcard_mask($3) ),
		};
		push @{ $thisterm->{"destinationIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /$srctext\s*$srcport\s*(([a-f\d:]+)\/(\d+))/i )
	{
		$dsttext = $1;
		my $thisIPAddress = {
			"address" => $2,
			"mask"    => $3,
		};
		push @{ $thisterm->{"destinationIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /$srctext\s*$srcport\s*((\d+\.\d+\.\d+\.\d+),\s+wildcard\s+bits\s+(\d+\.\d+\.\d+\.\d+))/i )
	{
		$dsttext = $1;
		my $thisIPAddress = {
			"address" => $2,
			"mask"    => mask_to_bits( _inverse_wildcard_mask($3) ),
		};
		push @{ $thisterm->{"destinationIpAddr"}->{network} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /$srctext\s*$srcport\s*(host\s+(\d+\.\d+\.\d+\.\d+|[a-f\d:]+))/i )
	{
		$dsttext = $1;
		my $thisIPAddress = { "host" => $2, };
		push @{ $thisterm->{"destinationIpAddr"} }, $thisIPAddress;
	}
	elsif ( $acl_line =~ /$srctext\s*$srcport\s*(\d+\.\d+\.\d+\.\d+|[a-f\d:]+)/i )
	{
		$dsttext = $1;
		my $thisIPAddress = { "host" => $1, };
		push @{ $thisterm->{"destinationIpAddr"} }, $thisIPAddress;
	}

	# now look for the dst port
	my $dstport;
	unless ( defined $dsttext )
	{
	}
	if ( $acl_line =~ /$srctext\s*$srcport\s*$dsttext\s+((lt|gt|eq|neq)\s+(\S+))/i )
	{
		$dstport = $1;
		my $operator = $2;
		if ( $operator =~ /neq/ )
		{
			$operator = "ne";
		}
		my $thisport = {
			"port"     => _int_port($3),
			"operator" => $operator,
		};
		push @{ $thisterm->{"destinationService"}->{portExpression} }, $thisport;
	}
	elsif ( $acl_line =~ /$srctext\s*$srcport\s*$dsttext\s+(range\s+(\S+)[-\s](\S+))/i )
	{
		$dstport = $1;
		my $thisport = {
			"portStart" => _int_port($2),
			"portEnd"   => _int_port($3),
		};
		push @{ $thisterm->{"destinationService"}->{portRange} }, $thisport;
	}

	if ( $acl_line =~ /\s+log\s*$/ )
	{
		$thisterm->{log} = "true";
	}
	else
	{
		$thisterm->{log} = "false";
	}

	# look for the time-range instruction
	if ( $acl_line =~ /\btime-range\s+(\S+)/i )
	{
		$thisterm->{timeAllowed} = $time_range->{$1};
	}
	$out->print_element('filterEntry', $thisterm);
}

sub parse_time_range
{
	my ($in) = @_;

	my $months = {
		JAN => '01',
		FEB => '02',
		MAR => '03',
		APR => '04',
		MAY => '05',
		JUN => '06',
		JUL => '07',
		AUG => '08',
		SEP => '09',
		OCT => '10',
		NOV => '12',
		DEC => '12',
	};
	my $time_range;
	while ( $in->{running_config} =~ /^time-range\s+(\S+)(.+?)(?:!|: end)/migs )
	{
		my $name = $1;
		$_ = $2;
		if (/absolute\s+start\s+(\d+:\d+)\s+(\d+)\s+(\S+)\s+(\d+)\s+end\s+(\d+:\d+)\s+(\d+)\s+(\S+)\s+(\d+)/mi)
		{
			$time_range->{$name}->{startTime} = $1 . ':00';
			$time_range->{$name}->{startDate} = $4 . '-' . $months->{ uc( substr( $3, 0, 4 ) ) } . '-' . $2;
			$time_range->{$name}->{endTime}   = $5 . ':00';
			$time_range->{$name}->{endDate}   = $8 . '-' . $months->{ uc( substr( $7, 0, 4 ) ) } . '-' . $6;
			$time_range->{$name}->{startTime} = '0' . $time_range->{$name}->{startTime}
			  if ( $time_range->{$name}->{startTime} =~ /^\d:/ );
			$time_range->{$name}->{endTime} = '0' . $time_range->{$name}->{endTime}
			  if ( $time_range->{$name}->{endTime} =~ /^\d:/ );
		}
		elsif (/periodic\s+(\D+)(\d+:\d+)\s+to\s+(\d+:\d+)/mi)
		{
			my $days = $1;
			$time_range->{$name}->{startTime} = $2 . ':00';
			$time_range->{$name}->{endTime}   = $3 . ':00';
			$time_range->{$name}->{startTime} = '0' . $time_range->{$name}->{startTime}
			  if ( $time_range->{$name}->{startTime} =~ /^\d:/ );
			$time_range->{$name}->{endTime} = '0' . $time_range->{$name}->{endTime}
			  if ( $time_range->{$name}->{endTime} =~ /^\d:/ );
			$days =~ s{ (\w+) }{ ( lc ( $1 ) ne 'thursday' ? substr ( $1, 0, 3 ) : substr ( $1, 0, 4 ) ) }gex;
			push @{ $time_range->{$name}->{days} }, split( /\s+/, $days );
		}
	}

	return $time_range;
}

sub print_filter_address
{
	my ( $in, $out, $v ) = @_;

	$v ||= 6;

	my $any_network = $v == 6 ? { "address" => "::", "mask" => "0" } : { "address" => "0.0.0.0", "mask" => "0" };
	if ( $in =~ /^any$/i )
	{
		push @{ $out->{network} }, $any_network;
	}
	elsif ( $in =~ /^[\da-f\.\:\/]+$/i )
	{
		my ( $address, $mask ) = split( /\//, $in );
		push @{ $out->{network} }, { "address" => $address, "mask" => ( $v == 6 ? $mask : mask_to_bits($mask) ) };
	}
	elsif ( $in =~ /^([\da-f\.\:]+)\s+([\da-f\.\:]+)$/i )
	{
		push @{ $out->{network} }, { "address" => $1, "mask" => ( $v == 6 ? $2 : mask_to_bits($2) ) };
	}
	elsif ( $in =~ /^host\s+(\S+)$/i )
	{
		push @{ $out->{host} }, $1;
	}
	elsif ( $in =~ /^object-group\s+(\S+)$/i )
	{
		push @{ $out->{objectGroupReference} }, $1;
	}
}

sub print_filter_service
{
	my ( $in, $out ) = @_;

	if ( $in =~ /^(lt|gt|eq|neq)\s+(\S+)$/i )
	{
		push @{ $out->{portExpression} }, { "port" => _int_port($2), "operator" => ( $1 ne 'neq' ? $1 : 'ne' ) };
	}
	elsif ( $in =~ /^range\s+([^\s\-]+)[-\s]([^\s\-]+)$/i )
	{
		push @{ $out->{portRange} }, { "portStart" => _int_port($1), "portEnd" => _int_port($2) };
	}
	elsif ( $in =~ /^object-group\s+(\S+)$/i )
	{
		push @{ $out->{objectGroupReference} }, $1;
	}
}

# checks to see if the incoming port is an integer.  If not
# it will do a lookup of the service name to convert it to an integer
sub _int_port
{
	my ($port) = @_;
	if ( $port =~ /^\d+$/ )
	{
		return $port;
	}
	else
	{
		return get_port_number($port);
	}
}

sub parse_access_ports
{
	my ( $in, $out ) = @_;
	my $headerPrinted = 0;
	while ( $in->{running_config} =~ /\bline\s+(vty|aux|con)?\s*(\d+)\s*(\d*)(.+?)(?=^\S)/msig )
	{
		$out->open_element("accessPorts") if ( !$headerPrinted );
		$headerPrinted++;

		my $endInstance = $3;
		my $blob        = $4;
		my $port        = {
			type => ( $1 or "unknown" ),
			startInstance => $2,
		};
		$port->{endInstance} = $endInstance if ($endInstance);

		if ( $blob =~ /^\s+exec-timeout\s+(\d+)\s+(\d+)/mi )
		{
			$port->{inactivityTimeout} = ( $1 * 60 ) + $2;
		}
		if ( $blob =~ /^\s+session-timeout\s+(\d+)\s+(\d+)/mi )
		{
			$port->{sessionTimeout} = ( $1 * 60 ) + $2;
		}
		if ( $blob =~ /^\s+absolute-timeout\s+(\d+)\s+(\d+)/mi )
		{
			$port->{absoluteTimeout} = ( $1 * 60 ) + $2;
		}
		if ( $blob =~ /^\s+transport\s+input\s+(.*\S)\s*$/mi )
		{
			$port->{inboundProtocol} = $1;
		}
		if ( $blob =~ /^\s+transport\s+output\s+(.*\S)\s*$/mi )
		{
			$port->{outboundProtocol} = $1;
		}
		if ( $blob =~ /^\s+access-class\s+(\S+)\s+(in|out)\s*$/mi )
		{
			my $aclname   = $1;
			my $direction = $2;
			if ( $direction =~ /out/i )
			{
				$port->{egressFilter} = $aclname;
			}
			else
			{
				$port->{ingressFilter} = $aclname;
			}
		}

		$out->print_element( "accessPort", $port );
	}
	$out->close_element("accessPorts") if ($headerPrinted);
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $c = $in->{running_config};
	$out->open_element("snmp");

	while ( $c =~ /^(snmp-server\s+community\s+([^\s]+).*)$/mig )
	{
		my $line = $1;
		my $community = { communityString => $2, };
		if ( $line =~ /\s+(RO|RW)/i )
		{
			$community->{accessType} = uc($1);
		}
		if ( $line =~ /\s+view\s+([^\s]+)/ )
		{
			$community->{mibView} = $1;
		}
		if ( $line =~ /\s+(RO|RW)\s+(\d+)/i )
		{
			$community->{filter} = $2;
		}
		$out->print_element( "community", $community );
	}

	if ( $c =~ /^snmp-server\s+contact\s+(.*[^\s])\s*$/mi )
	{
		$out->print_element( "sysContact", $1 );
	}
	if ( $c =~ /^snmp-server\s+location\s+(.*[^\s])\s*$/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}
	if ( $c =~ /^hostname\s+(\S+)/mi )
	{
		$out->print_element( "sysName", $1 );
	}
	if ( $c =~ /^snmp-server\s+system-shutdown\s*$/mi )
	{
		$out->print_element( "systemShutdownViaSNMP", "true" );
	}

	while ( $c =~ /^(snmp-server\s+host\s+\"?(\d+\.\d+\.\d+\.\d+)\"?.*$)/mig )
	{
		my $trapHost = { ipAddress => $2, };
		my $line     = $1;

		if ( $line =~ /\"?\d+\.\d+\.\d+\.\d+\"?\s+([^\s]+.*)$/ )
		{
			my $extraInformation = $1;
			my $communityString;

			if ( $extraInformation =~ /^trap\s+version\s+\S+\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^trap\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^inform\s+version\s+\S+\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^inform\s+(\S+)/i )
			{
				$communityString = $1;
			}
			elsif ( $extraInformation =~ /^(\S+)/ )
			{
				$communityString = $1;
			}

			if ($communityString)
			{
				$trapHost->{communityString} = $communityString;
			}
		}
		$out->print_element( "trapHosts", $trapHost );
	}
	if ( $c =~ /^snmp-server\s+trap-source\s+(.*[^\s])\s*$/mi )
	{
		$out->print_element( "trapSource", $1 );
	}
	if ( $c =~ /^snmp-server\s+trap-timeout\s+(\d+)/mi )
	{
		$out->print_element( "trapTimeout", $1 );
	}
	$out->close_element("snmp");
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $subnets = {};    # will be returned to the caller
	$out->open_element("interfaces");
	my $cipm = get_crep('cipm');

	while ( $in->{"running_config"} =~ /^interface\s+(\S+)(.+?)^!/smig )
	{
		my $name      = $1;
		my $blob      = $2;
		my $interface = {
			name          => $name,
			interfaceType => get_interface_type($name),
			physical      => _is_physical($name),
		};

		if ( $blob =~ /^\s*description\s+(.+?)\s*$/mi )
		{
			$interface->{description} = $1;
		}

		# get the ip addresses
		my $order = 1;
		if ( $blob =~ /^\s*ip address\s+($cipm)\s+($cipm)\s*$/mi )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => mask_to_bits($2),
				precedence => $order,
			};
			$order++;
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
			my $subnet = new ZipTie::Addressing::Subnet( $ipConfiguration->{ipAddress}, $ipConfiguration->{mask} );
			push( @{ $subnets->{$name} }, $subnet );
		}
		while ( $blob =~ /^\s*ip address\s+($cipm)\s+($cipm)(\ssecondary)/mig )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => mask_to_bits($2),
				precedence => $order,
			};
			$order++;
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
			my $subnet = new ZipTie::Addressing::Subnet( $ipConfiguration->{ipAddress}, $ipConfiguration->{mask} );
			push( @{ $subnets->{$name} }, $subnet );
		}
		$order = 1;
		while ( $blob =~ /^\s*ipv6 address\s+([A-Z\d:]+)\/(\d+)/mig )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => $2,
				precedence => $order,
			};
			$order++;
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
			my $subnet = new ZipTie::Addressing::Subnet( $ipConfiguration->{ipAddress}, $ipConfiguration->{mask} );
			push( @{ $subnets->{$name} }, $subnet );
		}
		while ( $blob =~ /^\s*ip helper-address\s+(\S+)/mig )
		{
			push( @{ $interface->{"interfaceIp"}->{"udpForwarder"} }, $1 );
		}
		while ( $blob =~ /^\s*ip access-group\s*\b(.+?)\b\s+(in|out)\s*$/mig )
		{
			my $acl       = $1;
			my $direction = $2;
			if ( $direction eq "out" )
			{
				$interface->{"egressFilter"} = $1;
			}
			elsif ( $direction eq "in" )
			{
				$interface->{"ingressFilter"} = $1;
			}
		}

		# process ethernet properties
		if ( $name =~ /eth/i )
		{
			if ( $blob =~ /^(\s+(half|full|auto).duplex|\s+duplex\s+(\S+))/mi )
			{
				my $duplex;
				$duplex = $2 if defined $2;    # left of the pipe
				$duplex = $3 if defined $3;    # right of the pipe
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
			elsif ( $blob =~ /^\s+speed\s+\d+/mi )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = "false";
			}
			elsif ( $blob =~ /^\s+speed\s+auto/mi )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = "true";
			}
			elsif ( $blob =~ /^\s+no negotiation/mi )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = "false";
			}
		}

		while ( $blob =~
			/^\s+(no\s+ip|ip)\s+(directed.broadcast|local.proxy.arp|redirects|route.cache|mroute.cache)\s*$/mig )
		{
			my $checkneg  = $1;
			my $ipsetting = $2;
			my $bool      = "true";
			$bool = "false" if ( $checkneg eq "no ip" );
			$interface->{interfaceIp}->{directedBroadcast} = $bool
			  if ( $ipsetting =~ /^directed.broadcast$/ );
			$interface->{interfaceIp}->{localProxyARP} = $bool
			  if ( $ipsetting =~ /^local.proxy.arp$/ );
			$interface->{interfaceIp}->{redirects} = $bool
			  if ( $ipsetting =~ /^redirects$/ );
			$interface->{interfaceIp}->{routeCache} = $bool
			  if ( $ipsetting =~ /^route.cache$/ );
			$interface->{interfaceIp}->{mRouteCache} = $bool
			  if ( $ipsetting =~ /^mroute.cache$/ );
		}

		# SONET (as POS)
		if ( $interface->{name} =~ /^pos(\d|\s+\d)/i )
		{
			if ( $blob =~ /^\s+bandwidth\s+(\d+)/mi )
			{
				$interface->{interfaceSonet}->{bandwidth} = $1;
			}
			if ( $blob =~ /^\s+clock\s*source\s+(\S+)/mi )
			{
				$interface->{interfaceSonet}->{clockSource} = $1;
			}
			if ( $blob =~ /^\s+crc\s+(\d+)/mi )
			{
				$interface->{interfaceSonet}->{crc} = $1;
			}
			if ( $blob =~ /^\s+encapsulation\s+(\S+)/mi )
			{
				$interface->{interfaceSonet}->{encapsulation} = $1;
			}
			if ( $blob =~ /^\s+keepalive\s+(\d+)/mi )
			{
				$interface->{interfaceSonet}->{keepAlive} = $1;
			}
			if ( $blob =~ /^\s+framing\s+(\S+)/mi )
			{
				$interface->{interfaceSonet}->{framing} = $1;
			}
			if ( $blob =~ /^\s+flag[s]*\s+(.+)/mi )
			{
				$interface->{interfaceSonet}->{flag} = $1;
			}
			if ( $blob =~ /^\s+loopback\s+(\S+)/mi )
			{
				$interface->{interfaceSonet}->{loopBack} = $1;
			}
			if ( $blob =~ /^\s+down-when-looped/mi )
			{
				$interface->{interfaceSonet}->{downWhenLooped} = "true";
			}
			else
			{
				$interface->{interfaceSonet}->{downWhenLooped} = "false";
			}
		}

		# PPP
		if ( $blob =~ /^\s+ppp\s+authentication\s+(\S+)/mi )
		{
			$interface->{interfacePPP}->{authenticationType} = $1;
		}
		if ( $blob =~ /^\s+ppp\s+\S+\s+sent-username\s+(\S+)/mi )
		{
			$interface->{interfacePPP}->{username} = $1;
		}
		if ( $blob =~ /^\s+ppp\s+callback\s+(\S+)/mi )
		{
			$interface->{interfacePPP}->{callBack} = $1;
		}
		if ( $blob =~ /^\s+ppp\s+compression\s+(\S+)/mi )
		{
			$interface->{interfacePPP}->{compression} = $1;
		}
		if ( $blob =~ /^\s+password\s+(\S+)/mi )
		{
			$interface->{interfacePPP}->{password} = $1
			  if ( $interface->{interfacePPP} );

			# cmd is unspecific to ppp, check for other elements exist
		}

		# SERIAL
		if ( $interface->{name} =~ /^serial(\d|\s+\d)/i )
		{
			if ( $blob =~ /^\s+dsu.?bandwidth\s+(\d+)/mi )
			{
				$interface->{interfaceSerial}->{dsuBandwidth} = $1;
			}
			if ( $blob =~ /^\s+keepalive\s+(\d+)/mi )
			{
				$interface->{interfaceSerial}->{keepAlive} = $1;
			}
			if ( $blob =~ /^\s+cable.?length\s+(\d+)/mi )
			{
				$interface->{interfaceSerial}->{cableLength} = $1;
			}
			if ( $blob =~ /^\s+encapsulation\s+(\S+)/mi )
			{
				$interface->{interfaceSerial}->{encapsulation} = $1;
			}
			if ( $blob =~ /^\s+idle.?character\s+(\S+)/mi )
			{
				$interface->{interfaceSerial}->{idleCharacter} = $1;
			}
			if ( $blob =~ /^\s+framing\s+(\S+)/mi )
			{
				$interface->{interfaceSerial}->{framing} = $1;
			}
			if ( $blob =~ /^\s+scramble\s+(\S+)/mi )
			{
				$interface->{interfaceSerial}->{scramble} = $1;
			}
			if ( $blob =~ /^\s+dsu.?mode\s+(\S+)/mi )
			{
				$interface->{interfaceSerial}->{dsuMode} = $1;
			}
			if ( $blob =~ /^\s+crc\s+(\d+)/mi )
			{
				$interface->{interfaceSerial}->{crc} = $1;
			}
			if ( $blob =~ /^\s+down-when-looped/mi )
			{
				$interface->{interfaceSerial}->{downWhenLooped} = "true";
			}
			else
			{
				$interface->{interfaceSerial}->{downWhenLooped} = "false";
			}
		}

		# ATM
		if ( $interface->{name} =~ /^atm(\d|\s+\d)/i )
		{
			if ( $blob =~ /^\s+loopback\s+(\S+)/mi )
			{
				$interface->{interfaceATM}->{loopback} = $1;
			}
			if ( $blob =~ /^\s+atm\s+\S+?keepalive\s+(\d+)/mi )
			{
				$interface->{interfaceATM}->{keepAlive} = $1;
			}
			if ( $blob =~ /^\s+atm\s+clock\s+(.+)/mi )
			{
				my $clock = lc($1);
				$interface->{interfaceATM}->{clock} = $clock;
			}
			if ( $blob =~ /^\s+atm\s+\S+?pvc-discovery\s+(.+)/mi )
			{
				$interface->{interfaceATM}->{ilmiPVCDiscovery} = $1;
			}
			if ( $blob =~ /^\s+atm\s+scrambling\s+(.+)/mi )
			{
				$interface->{interfaceATM}->{scrambling} = $1;
			}

			# This is one way that IOS displays ATM PVCs, one per line
			while ( $blob =~ /^(\s*atm\s+pvc\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+).*)$/mig )
			{
				my $line          = $1;
				my $vcd           = $2;
				my $vpi           = $3;
				my $vci           = $4;
				my $encapsulation = $5;

				my $logicalAtm = {
					vpi           => $vpi,
					vci           => $vci,
					vcd           => $vcd,
					encapsulation => $encapsulation,
				};

				if ( $line =~ /$encapsulation\s+(\d+)\s+(\d+)\s+(\d+)/ )
				{
					$logicalAtm->{peak}    = $1;
					$logicalAtm->{average} = $2;
					$logicalAtm->{burst}   = $3;
				}
				elsif ( $line =~ /$encapsulation\s+(\d+)\s+(\d+)/ )
				{
					$logicalAtm->{peak}    = $1;
					$logicalAtm->{average} = $2;
				}

				if ( $line =~ /oam\s+(\d+)/i )
				{
					$logicalAtm->{oam} = $1;
				}
				push( @{ $interface->{interfaceATM}->{interfaceLogicalATM} }, $logicalAtm );
			}
		}

		# ISDN (as BRI)
		if ( $interface->{name} =~ /^bri(\d|\s+\d)/i )
		{
			if ( $blob =~ /^\s+encapsulation\s+(\S+)/mi )
			{
				$interface->{interfaceISDN}->{encapsulation} = $1;
			}
			if ( $blob =~ /^\s+keepalive\s+(\d+)/mi )
			{
				$interface->{interfaceISDN}->{keepAlive} = $1;
			}
			if ( $blob =~ /^\s+isdn\s+switch.?type\s+(\S+)/mi )
			{
				$interface->{interfaceISDN}->{switchType} = $1;
			}
			if ( $blob =~ /^\s+isdn\s+spid1\s+(.+)/mi )
			{
				$interface->{interfaceISDN}->{spid1} = $1;
			}
			if ( $blob =~ /^\s+isdn\s+spid2\s+(.+)/mi )
			{
				$interface->{interfaceISDN}->{spid2} = $1;
			}
			if ( $blob =~ /^\s+isdn caller\s+(\S+)/mi )
			{
				$interface->{interfaceISDN}->{caller} = $1;
			}
			if ( $blob =~ /^\s+loopback\s+(\S+)/mi )
			{
				$interface->{interfaceISDN}->{loopback} = $1;
			}
		}

		# IPX and IPX addresses <-- needs more testing
		if ( $blob =~ /^\s+ipx\s+link-delay\s+(\d+)/mi )
		{
			$interface->{interfaceIPX}->{linkDelay} = $1;
		}
		if ( $blob =~ /^\s+ipx\s+throughput\s+(\d+)/mi )
		{
			$interface->{interfaceIPX}->{throughPut} = $1;
		}
		if ( $blob =~ /^\s+ipx\s+network\s+(\S+)\s+encapsulation\s+(\S+)\s+secondary/mi )
		{
			push(
				@{ $interface->{interfaceIPX}->{interfaceIPXAddress} },
				{ ipxAddress => $1, encapsulation => $2, ipxOrder => 2 }
			);
		}
		if ( $blob =~ /^\s+ipx\s+network\s+(\S+)\s+encapsulation\s+(\S+)/mi )
		{
			push(
				@{ $interface->{interfaceIPX}->{interfaceIPXAddress} },
				{ ipxAddress => $1, encapsulation => $2, ipxOrder => 1 }
			);
		}
		if ( $blob =~ /^\s+ipx\s+network\s+(\S+)\s+secondary/mi )
		{
			push( @{ $interface->{interfaceIPX}->{interfaceIPXAddress} }, { ipxAddress => $1, ipxOrder => 2 } );
		}
		if ( $blob =~ /^\s+ipx\s+network\s+(\S+)/mi )
		{
			push( @{ $interface->{interfaceIPX}->{interfaceIPXAddress} }, { ipxAddress => $1, ipxOrder => 1 } );
		}

		# FRAME RELAY
		if ( $blob =~ /\s+encapsulation\s+frame-relay\s+(\S+)\s*$/mi )
		{
			$interface->{interfaceFrameRelay}->{encapsulation} = $1;
		}
		if ( $blob =~ /^\s+frame-relay\s+lmi-type\s+(\S+)\s*$/mi )
		{
			$interface->{interfaceFrameRelay}->{lmiType} = $1;
		}
		if ( $blob =~ /^\s+frame-relay\s+interface-dlci\s+(\d+)/mi )
		{
			push( @{ $interface->{interfaceFrameRelay}->{virtualFrameRelay} }, { dlci => $1 } );
		}

		# VLAN trunk references
		if ( $blob =~ /^\s+switchport\s+trunk\s+allowed\s+vlan\s+(\S+)/mi )
		{
			my $vlandata = $1;
			if ( $vlandata =~ /^\d+$/ )
			{
				push( @{ $interface->{interfaceVlanTrunks} }, { startVlan => $vlandata, } );
			}
			else
			{
				foreach my $trunkedvlan ( split /,/, $vlandata )
				{
					if ( $trunkedvlan =~ /-/ )
					{
						my ( $start, $end ) = split /-/, $trunkedvlan;
						push( @{ $interface->{interfaceVlanTrunks} }, { startVlan => $start, endVlan => $end, } );
					}
					else
					{
						push( @{ $interface->{interfaceVlanTrunks} }, { startVlan => $trunkedvlan, } );
					}
				}
			}
		}

		# EIGRP
		if ( $blob =~ /hello-interval eigrp (\d+) (\d+)/ )
		{
			$interface->{"cisco:eigrp"}->{"cisco:asNumber"}      = $1;
			$interface->{"cisco:eigrp"}->{"cisco:helloInterval"} = $2;
		}
		if ( $blob =~ /hold-time eigrp (\d+) (\d+)/ )
		{
			$interface->{"cisco:eigrp"}->{"cisco:asNumber"} = $1;
			$interface->{"cisco:eigrp"}->{"cisco:holdTime"} = $2;
		}

		# process this particular interface from "show ip ospf interface"
		if ( $in->{ospf_ints} =~ /^($name\s.+?)(?=^\S)/msi )
		{
			my $blob = $1;
			if ( $blob =~ /Area (\S+)/i )
			{
				$interface->{interfaceOspf}->{area} = $1;
			}
			if ( $blob =~ /Process ID\s+(\d+),\s*Router ID\s+\S+,\s*Network Type\s+(\S+),\s*Cost:\s+(\d+)/i )
			{
				$interface->{interfaceOspf}->{processId}   = $1;
				$interface->{interfaceOspf}->{networkType} = $2;
				$interface->{interfaceOspf}->{cost}        = $3;
			}
			if ( $blob =~ /Transmit Delay is (\d+) sec,\s*State (\S+),\s*(Priority (\d+))?/i )
			{
				$interface->{interfaceOspf}->{transmitDelay}  = $1;
				$interface->{interfaceOspf}->{routerState}    = $2;
				$interface->{interfaceOspf}->{routerPriority} = $4 if ($4);
			}
			if ( $blob =~ /Hello\s*(\d+),\s*Dead\s*(\d+),\s*Wait\s*(\d+),\s*Retransmit\s*(\d+)/i )
			{
				$interface->{interfaceOspf}->{helloInterval}      = $1;
				$interface->{interfaceOspf}->{deadInterval}       = $2;
				$interface->{interfaceOspf}->{waitInterval}       = $3;
				$interface->{interfaceOspf}->{retransmitInterval} = $4;
			}
		}

		# process this particular interface from "show interfaces"
		if ( $in->{interfaces} =~ /^($name\s.+?)(?=^\S)/msi )
		{
			my $intBlob = $1;
			if ( $intBlob =~ /$name\s+is\s+(up|\S+\s+down|down),/mi )
			{
				$interface->{adminStatus} = ( $1 =~ /down/i ) ? 'down' : 'up';    # Defaults to 'up'.
			}
			if ( $intBlob =~ /address is ([a-f0-9A-F]{4}\.[a-f0-9A-F]{4}\.[a-f0-9A-F]{4})/mi )
			{
				my $macAddress = $1;
				$interface->{interfaceEthernet}->{macAddress} = strip_mac($macAddress);
			}
			if ( $intBlob =~ /MTU\s+(\d+)\s+bytes,\s+BW\s+(\d+)\s+(\S+),/mi )
			{
				my $mtu   = $1;
				my $speed = $2;
				my $units = $3;
				if ( $units =~ /Mb/i ) { $speed = $speed * 1000 * 1000; }
				if ( $units =~ /Kb/i ) { $speed = $speed * 1000; }
				$interface->{speed} = $speed;
				$interface->{mtu}   = $mtu;
			}
			if ( $intBlob =~ /MTU\s+(\d+)\s+bytes,\s+sub\s+MTU\s+\d+,\s+BW\s+(\d+)\s+(\S+),/ )
			{
				my $mtu   = $1;
				my $speed = $2;
				my $units = $3;
				if ( $units =~ /Mbit/i ) { $speed = $speed * 1000; }
				$interface->{speed} = $speed;
				$interface->{mtu}   = $mtu;
			}
			if ( $intBlob =~ /Encapsulation\s([^\s^,]+)/ )
			{
				my $encaps = $1;
				if (   ( defined $interface->{interfaceEthernet} )
					|| ( $interface->{interfaceType} eq "ethernet" ) )
				{
					$interface->{interfaceEthernet}->{encapsulation} = $encaps;
				}
			}
			if ( $intBlob =~ /(Half|Full|Auto)[- ]duplex,\s+(100Mb|10Mb|Auto).+,\s+(media type is |)(\S+)/i )
			{
				my $duplex    = $1;
				my $autospeed = $2;
				my $media     = $4;
				if ( $duplex =~ /half/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = "half";
				}
				elsif ( $duplex =~ /full/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = "full";
				}
				elsif ( $duplex =~ /auto/i )
				{
					$interface->{interfaceEthernet}->{autoDuplex} = "true";
				}
				if ( $autospeed =~ /auto/i )
				{
					$interface->{interfaceEthernet}->{autoSpeed} = "true";
				}
				$interface->{interfaceEthernet}->{mediaType} = $media;
			}
		}

		if ( $in->{"running_config"} =~ /^ntp\s+(server|peer)/mi )    #i.e. not running sntp AND ntp is active
		{
			$interface->{ntpServerEnabled} = ( $blob =~ /ntp\s+disable/mi ) ? "false" : "true";
		}

		my @failovers = ( 'standby', 'vrrp', 'glbp' );
		foreach my $failover (@failovers)
		{
			if ( $blob =~ $failover )
			{
				my $fail;

				#For each interface evaluate each standby blob
				while ( $blob =~ /(\s+(?:$failover)\s+(\d+)\s+.*\n(?:\s+(?:$failover)\s+\2\s+.*\n)*)/mig )
				{
					my $fail_blob   = $1;
					my $fail_number = $2;

					my $group;

					if ( $fail_blob =~ /weighting\s+(\d+.*)$/mi )    #only applies to GLBP
					{
						my $values = $1;

						my ( $max, $val1, $val2 ) = $values =~ /(\d+)(?:\s+(lower\s+\d+))?(?:\s+(upper\s+\d+))?/mi;

						$group->{glbpWeighting}->{maximum} = $max;
						if ( !$val2 )
						{
							if ( $val1 =~ /upper/mi )
							{
								$val2 = $val1;
								undef $val1;
							}
						}

						$val1 =~ s/lower\s+//mi;
						$val2 =~ s/upper\s+//mi;

						$group->{glbpWeighting}->{lower} = $val1 if ($val1);
						$group->{glbpWeighting}->{upper} = $val2 if ($val2);
					}

					$group->{groupID} = $fail_number;

					if ( $fail_blob =~ /(?:name|description)\s+(.*)$/mi )
					{
						$group->{groupName} = $1;
					}

					if ( $fail_blob =~ /mac-address\s+(\d{4}\.\d{4}\.\d{4})/mi )
					{
						$group->{macAddress} = strip_mac($1);
					}
					elsif ( $in->{$failover} )    # try to get the virtual mac from the show commands
					{
						my ($mac_blob) =
						  $in->{$failover} =~ /($name\s+-\s+Group\s+$fail_number.*\n(?:\S+.*\n)?(?:\s+.*\n)*)/mi;
						if ($mac_blob)
						{
							if ( $mac_blob =~
								/^\s+(?:local\s+)?virtual\s+MAC\s+address\s+is\s+(\S+)/mi )    #VRRP and HSRP only
							{
								$group->{macAddress} = strip_mac($1);
							}
						}
					}

					if ( $fail_blob =~ /preempt\s*(delay\s+.*)$/mi )
					{
						my $preempt_blob = $1;

						$group->{preempt}->{state} = "true";
						if ( $preempt_blob =~ /minimum\s+(\d+)/mi )
						{
							$group->{preempt}->{delay} = $1;
						}
						if ( $preempt_blob =~ /reload\s+(\d+)/mi )
						{
							$group->{preempt}->{reloadDelay} = $1;
						}
						if ( $preempt_blob =~ /sync\s+(\d+)/mi )
						{
							$group->{preempt}->{syncDelay} = $1;
						}
					}

					if ( $fail_blob =~ /ip\s+(\d+\.\d+\.\d+\.\d+)\s*$/mi )
					{
						$group->{primaryIPaddress} = $1;
					}

					if ( $fail_blob =~ /priority\s+(\d+)/mi )
					{
						$group->{priority} = $1;
					}

					while ( $fail_blob =~ /ip\s+(\d+\.\d+\.\d+\.\d+)\s+secondary\s*$/mig )
					{
						push( @{ $group->{"secondaryIPaddress"} }, $1 );
					}

					if ( $fail_blob =~ /authentication\s+(.*)/mi )
					{
						my $authentication_line = $1;

						if ( $authentication_line =~ /md5\s+(key-chain|key-string)\s+(\S+|\d+\s+\S+)/mi )
						{
							my $type     = $1;
							my $key_blob = $2;

							$group->{security}->{encryption} = "MD5";
							if ( $authentication_line =~ /key-string\s+\d+\s+(\S+)/mi )
							{
								$group->{security}->{keyString} = $1;
							}
							else
							{
								( $group->{security}->{keyChain}->{keyChainName} ) =
								  $authentication_line =~ /key-chain\s+(\S+)/mi;
							}
						}
						else
						{
							$group->{security}->{encryption} = "Plain text";
							$group->{security}->{keyString}  = $authentication_line;
						}
					}

					if ( $fail_blob =~
						/timers\s+(?:((?:msec\s+)?\d+)\s+((?:msec\s+)?\d+)|advertise\s+((?:msec\s+)?\d+))/mi
					  )    # glbp&hsrp | vrrp
					{
						my $hello = ($3) ? $3 : $1; #if $3 is filled then it's an "advertise xxx" else it's a "xxx yyy".
						my $hold  = $2;             #only for hsrp & glbp

						$group->{timers}->{helloTimer} = ( $hello =~ /msec\s+(\d+)/mi ) ? $1 : $hello * 1000;
						$group->{timers}->{holdTimer} = ( $hold =~ /msec\s+(\d+)/mi ) ? $1 : $hold * 1000 if ($hold);
					}

					while ( $fail_blob =~ /track\s+(\S+)\s*(?:(?:decrement\s+)?(\d+))?/mig )
					{
						my $track;

						my $tracker   = $1;
						my $decrement = $2;

						if ( $tracker =~ /^(?:(?:[1-4]?[0-9]?[0-9])|500)$/mi
						  )    #if the track object is just the number between 1 and 500 (Cisco Tracker ID range)
						{
							$track->{objectID} = $tracker;
						}
						else
						{
							$track->{interface} = $tracker;
						}

						$track->{decrement} = ($decrement) ? $decrement : 10;

						push( @{ $group->{"track"} }, $track );
					}

					push( @{ $fail->{"failoverGroup"} }, $group );
				}

				if ( $failover eq "standby" )
				{
					$fail->{icmpRedirect} = "true" if ( $blob =~ /standby\s+redirect/mi );

					my ( $min_del, $reload_del ) = $blob =~ /standby\s+delay\s+minimum\s+(\d+)\s+reload\s+(\d+)/mi;
					$fail->{interfaceDelay} = $min_del if ($min_del);

					if ( $blob =~ /standby\s+mac-refresh\s+(\d+)/mi )
					{
						$fail->{macRefresh} = $1;
					}

					$fail->{reloadDelay} = $reload_del if ($reload_del);

					$fail->{version} = ( $blob =~ /standby\s+version\s+(\d+)/ ) ? $1 : "1";
				}

				$failover = "hsrp" if ( $failover eq "standby" );
				$interface->{failover}->{$failover} = $fail if ($fail);
			}
		}

		if ( $blob =~ /service-policy\s+(input|output)\s+(\S+)\s*/mi )
		{
			my $direction  = $1;
			my $policyName = $2;

			$direction = "Inbound"  if ( $direction eq "input" );
			$direction = "Outbound" if ( $direction eq "output" );

			my $appliedQos = {
				name      => $policyName,
				direction => $direction,
			};

			$interface->{interfaceQOS}->{policyMap} = $appliedQos;
		}

		while ( $blob =~
/rate-limit\s+(input|output)(?:\s+dscp\s(\d+))?(?:\s+access-group\s+(?:rate-limit\s+)?(\d+))?\s+(\d+)\s+(\d+)\s+(\d+)\s+conform-action\s+(.*?)\s+exceed-action\s+(.*?)\s*$/mig
		  )
		{
			my $direction = $1;
			my $dscp      = $2;
			my $acl       = $3;
			my $bps       = $4;
			my $normal    = $5;
			my $max       = $6;
			my $conform   = $7;
			my $exceed    = $8;

			my $rateLimit;

			$direction = "Inbound"  if ( $direction eq "input" );
			$direction = "Outbound" if ( $direction eq "output" );

			$rateLimit->{direction}            = $direction;
			$rateLimit->{dscp}                 = $dscp if ($dscp);
			$rateLimit->{accessGroup}          = $acl if ($acl);
			$rateLimit->{bps}->{bandwidthBits} = $bps;
			$rateLimit->{normalBurst}          = $normal;
			$rateLimit->{maxBurst}             = $max;
			$rateLimit->{conformAction}        = _set_action($conform);
			$rateLimit->{exceedAction}         = _set_action($exceed);

			push( @{ $interface->{"interfaceQOS"}->{"rateLimit"} }, $rateLimit );
		}

		$out->print_element( "cisco:interface", $interface );
	}

	$out->close_element("interfaces");
	return $subnets;
}

sub parse_stp
{

	# parses Spanning Tree information
	my ( $in, $out ) = @_;
	my $spanningTree;

	# instances from "show spanning-tree"
	while ( $in->{stp} =~ /^(VLAN|MST)0*(\d+)(.+?)^-+/msig )
	{
		my $blob = $3;
		my $instance = { vlan => $2, };
		if ( $blob =~ /^\s*Root\s+ID(.+?)^\s*$/msi )
		{
			my $rootSection = $1;
			if ( $rootSection =~ /Priority\s+(\d+)/i )
			{
				$instance->{designatedRootPriority} = $1;
			}
			if ( $rootSection =~ /Address\s+([0-9a-f.]+)/i )
			{
				$instance->{designatedRootMacAddress} = strip_mac($1);
			}
			if ( $rootSection =~ /Cost\s+(\d+)/i )
			{
				$instance->{designatedRootCost} = $1;
			}
			if ( $rootSection =~ /Port\s+\d+\s+\((\S+)\)/i )
			{
				$instance->{designatedRootPort} = $1;
			}
			if ( $rootSection =~ /Hello Time\s+(\d+) sec\s+Max Age\s+(\d+) sec\s+Forward Delay\s+(\d+) sec/i )
			{
				$instance->{designatedRootHelloTime}    = $1;
				$instance->{designatedRootMaxAge}       = $2;
				$instance->{designatedRootForwardDelay} = $3;
			}
		}
		if ( $blob =~ /^\s*Bridge\s+ID(.+?)^\s*$/msi )
		{
			my $bridgeSection = $1;
			if ( $bridgeSection =~ /Priority\s+(\d+)/i )
			{
				$instance->{priority} = $1;
			}
			if ( $bridgeSection =~ /Address\s+([0-9a-f.]+)/i )
			{
				$instance->{systemMacAddress} = strip_mac($1);
			}
			if ( $bridgeSection =~ /Hello Time\s+(\d+) sec\s+Max Age\s+(\d+) sec\s+Forward Delay\s+(\d+) sec/i )
			{
				$instance->{helloTime}    = $1;
				$instance->{maxAge}       = $2;
				$instance->{forwardDelay} = $3;
			}
		}
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

sub parse_routing
{
	my ( $in, $out ) = @_;

	my $protocols = {};

	# parse out BGP, OSPF and EIGRP details
	while ( $in->{running_config} =~ /^router\s+(eigrp|ospf|bgp|rip)(?:\s+(\d+))?\s*\n((?:\s+.*?\n)*)/msig )
	{
		my $type = $1;
		my $id   = $2;
		my $blob = $3;
		my $areas;    # used for OSPF

		my $protocol;
		my $ns = ( $type eq "eigrp" ) ? "cisco:" : "";

		while ( $blob =~ /^\s*redistribute\s*(bgp|ospf|eigrp|rip)(\s(\d+))?/img )
		{
			my $redistribution = { targetProtocol => $1, };
			$redistribution->{processId} = $3 if ($3);

			push( @{ $protocol->{ $ns . "redistribution" } }, $redistribution );
		}
		if ( $blob =~ /synchronization/i )
		{
			$protocol->{ $ns . "synchronization" } = ( $blob =~ /no synch/i ) ? "false" : "true";
		}
		if ( $blob =~ /auto-summary/i )
		{
			$protocol->{ $ns . "autoSummarization" } = ( $blob =~ /no auto-sum/i ) ? "false" : "true";
		}

		if ( $type eq 'ospf' )
		{
			while ( $blob =~ /^\s*area\s(\d+\S*)\s(nssa|stub)/img )
			{
				my $area     = $1;
				my $areaType = $2;
				if ( !defined $areas->{$1} )
				{
					$areaType = "SA" if ( $areaType eq 'stub' );
					$areas->{$1} = { areaId => $area, areaType => uc($areaType), };
				}
			}
			while ( $blob =~ /^\s*network\s*(\d+\.\d+\.\d+\.\d+)\s*(\d+\.\d+\.\d+\.\d+).+?area\s(\d+\S*)/img )
			{
				my $area    = $3;
				my $network = {
					address => $1,
					mask    => mask_to_bits($2),
				};
				if ( !defined $areas->{$area} )
				{
					$areas->{$area} = {
						areaId   => $area,
						areaType => 'normal'
					};
				}
				push( @{ $areas->{$area}->{network} }, $network );
			}
		}
		elsif ( $type eq 'rip' )
		{
			while ( $blob =~ /^\s*network\s*((\d+)\.\d+\.\d+\.\d+)\s*/mig )
			{
				my $net    = { address => $1, };
				my $octet1 = $2;

				my $mask;
				$mask = '255.0.0.0'     if ( $octet1 < 127 );
				$mask = '255.255.0.0'   if ( $octet1 >= 127 && $octet1 < 192 );
				$mask = '255.255.255.0' if ( $octet1 >= 192 );

				$net->{mask} = mask_to_bits($mask);
				push( @{ $protocol->{ $ns . "network" } }, $net );
			}
		}
		else
		{
			while ( $blob =~ /^\s*network\s*(\d+\.\d+\.\d+\.\d+)\s*(\d+\.\d+\.\d+\.\d+)?/mig )
			{
				my $net = { address => $1, };
				my $mask = $2;
				if ( !$mask )
				{
					my @address = split( /\./, $net->{address} );
					foreach my $piece (@address)
					{
						$mask .= '.' if ( length($mask) );
						if ( $piece eq '0' )
						{
							$mask .= '255';
						}
						else
						{
							$mask .= '0';
						}
					}
				}
				$net->{mask} = mask_to_bits($mask);
				push( @{ $protocol->{ $ns . "network" } }, $net );
			}
		}

		foreach my $key ( keys %$areas )
		{
			push( @{ $protocol->{"area"} }, $areas->{$key} );
		}

		while ( $blob =~ /summary-address\s+(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)/g )
		{
			my $summarizedAddress = {
				address => $1,
				mask    => mask_to_bits($2),
			};
			push( @{ $protocol->{ $ns . "summarizedAddress" } }, $summarizedAddress );
		}

		if ( $blob =~ /^\s*passive-interface default/ )
		{
			if ( $type =~ /ospf|rip/mi )
			{
				$protocol->{allInterfacesEnabled} = 'true';
			}
			elsif ( $type eq 'eigrp' )
			{
				$protocol->{'cisco:passiveInterfaceDefault'} = 'false';
			}
		}
		else
		{
			if ( $type =~ /ospf|rip/mi )
			{
				$protocol->{allInterfacesEnabled} = 'false';
			}
			elsif ( $type eq 'eigrp' )
			{
				$protocol->{'cisco:passiveInterfaceDefault'} = 'false';
			}
		}

		while ( $blob =~ /^\s*no passive-interface (\S+)/mig )
		{
			my $int = $1;
			if ( $int ne 'default' )
			{
				if ( $type =~ /ospf|rip/mi )
				{
					push( @{ $protocol->{enabledInterface} }, $int );
				}
				elsif ( $type eq 'eigrp' )
				{
					push( @{ $protocol->{'cisco:activeInterface'} }, $int );
				}
			}
		}
		while ( $blob =~ /^\s*passive-interface (\S+)/mig )
		{
			my $int = $1;
			if ( $int ne 'default' )
			{
				if ( $type =~ /ospf|rip/mi )
				{
					push( @{ $protocol->{disabledInterface} }, $int );
				}
				elsif ( $type eq 'eigrp' )
				{
					push( @{ $protocol->{'cisco:passiveInterface'} }, $int );
				}
			}
		}

		if ( $type =~ /eigrp|bgp/i )
		{
			$protocol->{ $ns . "asNumber" } = $id;
		}
		elsif ( $type eq "ospf" )
		{
			$protocol->{processId} = $id;
		}

		# get the OSPF router ID
		if ( $type eq 'ospf' )
		{
			if ( $blob =~ /^\s*router-id\s*(\S+)/mi )
			{
				$protocol->{"routerId"} = $1;
			}
			elsif ( $in->{protocols} =~ /^Routing Protocol is \"$type $id\"(.+?)(?=^\S)/msi )
			{
				my $protBlob = $1;
				if ( $protBlob =~ /^\s*Router ID\s+(\S+)/im )
				{
					$protocol->{"routerId"} = $1;
				}
			}
		}

		# get the BGP neighbor definitions
		if ( $type eq 'bgp' )
		{
			my $peerGroupAsNumbers = {};
			while ( $blob =~ /^\s*neighbor\s(\S+)\s+remote-as\s+(\d+)/mig )
			{
				my $def = $1;
				my $as  = $2;
				if ( $def =~ /\d+\.\d+\.\d+\.\d+/ )
				{
					push( @{ $protocol->{neighbor} }, { address => $def, asNumber => $as, } );
				}
				else
				{
					$peerGroupAsNumbers->{$def} = $as;
				}
			}
			while ( $blob =~ /^\s*neighbor\s(\d+\.\d+\.\d+\.\d+)\s+peer-group\s+(\S+)/mig )
			{
				if ( $peerGroupAsNumbers->{$2} )
				{
					push( @{ $protocol->{neighbor} }, { address => $1, asNumber => $peerGroupAsNumbers->{$2}, } );
				}
			}
		}

		#check RIP version
		if ( $type eq 'rip' )
		{
			my $version = 2;
			$version = 1 if ( $blob =~ /version\s1/mi );

			$protocol->{version} = $version;
		}

		$type = "cisco:" . $type if ( $type eq "eigrp" );
		push( @{ $protocols->{$type} }, $protocol );
	}

	if ( defined $protocols )
	{

		# the generic routing protocols must come before the cisco:eigrp definition
		$out->open_element("cisco:routing");
		foreach my $prot ( @{ $protocols->{bgp} } )
		{
			$out->print_element( "bgp", $prot );
		}
		foreach my $prot ( @{ $protocols->{ospf} } )
		{
			$out->print_element( "ospf", $prot );
		}
		foreach my $prot ( @{ $protocols->{rip} } )
		{
			$out->print_element( "rip", $prot );
		}
		foreach my $prot ( @{ $protocols->{'cisco:eigrp'} } )
		{
			$out->print_element( "cisco:eigrp", $prot );
		}
		$out->close_element("cisco:routing");
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
		s/^Et(?=\d)/Ethernet/;
		s/^Gig?(?=\d)/GigabitEthernet/;
	}
	return $name;
}

sub _parse_file_storage
{

	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;
	while ( $in->{show_fs} =~ /^\*?\s+(\d+)\s+(\d+)\s+\b(\S+)\b\s+[A-Za-z]+\s+(\S+):/mig )
	{
		my $storage = {
			name        => $4,
			storageType => $3,
			size        => $1,
			freeSpace   => $2,
		};

		if ( $storage->{storageType} !~ /opaque|nvram/i )
		{
			my $show = $in->{file_systems}->{ $storage->{name} };

			if ( defined $show )
			{
				$storage->{rootDir} = { name => "root", };
				if ( $show =~ /^\s*File\s+Length\s+Name\/status\s*$/ms )    # 'show flash' format output
				{
					while ( $show =~ /^\s*(\d+)\s+(\d+)\s+(\S+)\s*$/mig )
					{
						my $file = {
							size => $2,
							name => $3,
						};

						push( @{ $storage->{rootDir}->{file} }, $file );
					}

					# this is the more accurate physical size
					if ( $show =~ /^\s*(\d+)K bytes of processor board/mi )
					{
						$storage->{size} = $1 * 1024;
					}
				}
				elsif ( $show =~ /^\s*-#-\s--length--\s-----date\/time------\spath\s*$/ms )  # 'show disk' format output
				{
					while ( $show =~ /^\s*\d+\s+(\d+)\s(?:.+?\s){4}(\S+)\s*$/mig )
					{
						my $file = {
							size => $1,
							name => $2,
						};

						push( @{ $storage->{rootDir}->{file} }, $file );
					}
				}
				elsif ( $show =~ /^\s*-#-\sED\s.+?type.+?crc.+?seek.+?nlen.+?length.+?date\/time.+name\s*$/ms
				  )    # 'show bootflash format output
				{
					while ( $show =~ /^\s*\d+\s+(?:\S+\s+){5}(\d+)\s(?:\S+\s+){5}(\S+)\s*$/mig )
					{
						my $file = {
							size => $1,
							name => $2,
						};

						push( @{ $storage->{rootDir}->{file} }, $file );
					}
				}
				elsif ( $show =~ /^\s*\d+\s+[-drwx]{4}\s+(\d+)\s+(?:.*?)\s+\d+:\d+:\d+\s+(?:.*?)\s+(\S+)\s*\n/ms ) #show flash output that has no headers
				{
					while ( $show =~ /^\s*\d+\s+[-drwx]{4}\s+(\d+)\s+(?:.*?)\s+\d+:\d+:\d+\s+(?:.*?)\s+(\S+)\s*\n/mig )
					{
						my $file = {
							size => $1,
							name => $2,
						};

						push( @{ $storage->{rootDir}->{file} }, $file );
					}
				}
			}
			$out->print_element( "deviceStorage", $storage );
		}
	}
}

sub _parse_cards
{

	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	if ( defined $in->{show_inventory} )
	{
		my $first_chassis = 1;
		while ( $in->{show_inventory} =~ /(NAME:.+?)SN:\s+(\S+)/migs )
		{
			if ( !$first_chassis )
			{
				my $chassisBlob	= $1;
				my $chassisSN	= $2;
				my ( $desc )	= $chassisBlob =~ /DESCR:(.+)$/mi;
				$desc			=~ s/"//g;
				my $card =
				{
					"core:description" => trim ( $desc )
				};
				my ( $model )	= $chassisBlob =~ /PID:\s+(\S+)/mi;

				$card->{"core:asset"}->{"core:assetType"}                          = "Card";
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}         = "Cisco";
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = $model;
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $chassisSN;

				$out->print_element( "card", $card );
			}
			$first_chassis = 0;
		}
	}

	if ( defined $in->{show_module} )
	{

		#Mod Ports Card Type                              Model              Serial No.
		#--- ----- -------------------------------------- ------------------ -----------
		while ( $in->{show_module} =~ /^\s*(\d+)\s+(\d+)\s+\b(.+?)\s+((?:WS|7600)-\S+)\s+(\S+)\s*$/mig )
		{
			my $no   = $1;
			my $card = {
				slotNumber         => $no,
				portCount          => $2,
				"core:description" => $3,
			};

			$card->{"core:asset"}->{"core:assetType"}                          = "Card";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}         = "Cisco";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = "Unknown";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"}   = $4;
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $5;

			# now get the card status
			if ( $in->{show_module} =~
				/^\s*$no\s+[a-f0-9.]{14}\s+to\s+[a-f0-9.]{14}\s+(?:[\w.()]+)\s+(?:[\w.()]+)\s+(?:\S+)\s+(\S+)/mi )
			{
				$card->{"status"} = $1;
			}

			# now get the HW, FW and SW versions from 'show mod ver' output
			($_) = $in->{show_mod_ver} =~ /^\s+$no(.+?)(?:^\s+\d+|^\S+)/mis;
			if ( defined $_ )
			{
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = trim($1) if (/\bHw\s+:(.+)$/mi);
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:firmwareVersion"} = trim($1) if (/\bFw\s+:(.+)$/mi);
				$card->{"softwareVersion"}                                            = trim($1) if (/\bSw\s+:(.+)$/mi);
			}

			# now get any daughter cards (sub-mod)
			if ( $in->{show_module} =~ /^Mod\s+Sub-Mod(.+?)^\s*$/msi )
			{
				my $blob = $1;
				while ( $blob =~ /^\s*$no(?:\/\d+)?\s+\b(.+?)\s+((?:WS|SPA)-\S+)\s+(\S+)\s+([\d.]+)\s+(\S+)/mig )
				{
					my $daughterCard = { "core:description" => $1, };
					$daughterCard->{"core:asset"}->{"core:assetType"}                             = "Card";
					$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}            = "Cisco";
					$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}     = "Unknown";
					$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"}      = $2;
					$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}    = $3;
					$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = $4;
					$daughterCard->{"status"}                                                     = $5;

					push( @{ $card->{daughterCard} }, $daughterCard );
				}
			}
			$out->print_element( "card", $card );
		}
	}
	elsif ( defined $in->{show_diag} )
	{
		my $slotnum   = 0;
		my $slotcount = -1;
		my $cardref;
		my $desc             = "";
		my $hwVer            = "";
		my $snum             = "";
		my $pnum             = "";
		my $frupnum          = "";
		my $dslotnum         = -1;
		my $cardtype         = "";
		my $type             = "";
		my $mslotType        = "";
		my $mslotnum         = -1;
		my $mslotname        = "";
		my $dslotname        = "";
		my $nodesc           = 0;
		my $nodescencryptaim = 0;
		my $nodescaimmodule  = 0;
		my $nodescaimcarrier = 0;

		foreach my $line ( split( /\n/, $in->{show_diag} ) )
		{

			# mother card
			if ( $line =~ /^Slot\s+(\d+):/i )
			{
				$slotnum          = $1;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "physical";
				$mslotname        = "";
				$dslotname        = "";
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# AIM mother card
			elsif ( $line =~ /^AIM\s+slot\s+(\d+):\s+([A-Za-z-\/ ]+)/i )
			{
				$slotnum          = $1 + 100;
				$mslotnum         = $1;
				$desc             = $2;
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "physical";
				$mslotname        = "AIM";
				$dslotname        = "";
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# Encryption AIM mother card
			elsif ( $line =~ /Encryption\s+AIM\s+(\d+):/i )
			{
				$slotnum          = $1 + 300;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "physical";
				$mslotname        = "Encryption AIM";
				$dslotname        = "";
				$nodescencryptaim = 1;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# Compression AIM mother card
			elsif ( $line =~ /Compression\s+AIM\s+(\d+):/i )
			{
				$slotnum          = $1 + 500;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "physical";
				$mslotname        = "Compression AIM";
				$dslotname        = "";
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# ATM AIM mother card
			elsif ( $line =~ /ATM\s+AIM\s*[: ]\s*(\d+)/i )
			{
				$slotnum          = $1 + 900;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "physical";
				$mslotname        = "ATM AIM";
				$dslotname        = "";
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# AIM module mother card
			elsif ( $line =~ /AIM\s+Module\s+in\s+slot[: ]\s*(\d+)/i )
			{
				$slotnum          = $1 + 800;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "physical";
				$mslotname        = "AIM Module";
				$dslotname        = "";
				$nodescencryptaim = 0;
				$nodescaimmodule  = 1;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# virtual mother card
			elsif ( $line =~ /^Slot\s+(\d+)\s+\(virtual\):/i )
			{
				$slotnum          = $1 + 200;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "virtual";
				$mslotname        = "(virtual)";
				$dslotname        = "";
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# logical mother card
			elsif ( $line =~ /^Slot\s+(\d+):Logical_index\s+(\d+)/i )
			{
				$slotnum          = $2 + 400;
				$mslotnum         = $1;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "logical";
				$mslotname        = "Logical_index";
				$dslotname        = "";
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "mother";
			}

			# WIC/VIC daughter card
			elsif ( ( $line =~ /([A-Z\/]*IC) Slot\s+(\d+):/i ) )
			{

				# handle no stop state
				if ($cardtype)
				{
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:description"} = $desc if ($desc);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:hardwareVersion"} = $hwVer
					  if ($hwVer);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:make"} = "Cisco";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:modelNumber"} = "Unknown";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:serialNumber"} = $snum
					  if ($snum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:partNumber"} = $pnum
					  if ($pnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:fruPartNumber"} = $frupnum
					  if ($frupnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:assetType"} = "Card";

					if ( $dslotnum >= 0 )
					{
						my $actualslotnum = $dslotnum;
						$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotNumber} =
						    $actualslotnum > 99
						  ? $actualslotnum -= 100
						  : $actualslotnum += 0;
					}
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotName} = $dslotname if ($dslotname);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotType} = $mslotType if ($mslotType);
				}
				$dslotnum         = $2;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "";
				$dslotname        = $1;
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "daughter";
			}

			# (on Carrier Card) AIM daughter card
			elsif ( $line =~ /AIM\s+on\s+Carrier\s+Card\s+(\d+):/i )
			{
				if ($cardtype)
				{
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:description"} = $desc if ($desc);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:make"} = "Cisco";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:modelNumber"} = "Unknown";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:hardwareVersion"} = $hwVer
					  if ($hwVer);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:serialNumber"} = $snum
					  if ($snum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:partNumber"} = $pnum
					  if ($pnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:fruPartNumber"} = $frupnum
					  if ($frupnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:assetType"} = "Card";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotType} = $mslotType if ($mslotType);
				}
				$dslotnum         = $1;
				$desc             = "AIM on Carrier Card " . $1;
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "";
				$dslotname        = "AIM on Carrier Card";
				$type             = "";
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 1;
				$cardtype         = "daughter";
			}

			# PVDM daughter card
			elsif (( $line =~ /(PVDM) Slot\s+(\d+):/i )
				or ( $line =~ /(Packet Voice DSP Module) Slot\s+(\d+):/i ) )
			{

				# handle no stop state
				if ( $cardtype ne "" )
				{
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:description"} = $desc if ($desc);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:make"} = "Cisco";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:modelNumber"} = "Unknown";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:hardwareVersion"} = $hwVer
					  if ($hwVer);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:serialNumber"} = $snum
					  if ($snum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:partNumber"} = $pnum
					  if ($pnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:fruPartNumber"} = $frupnum
					  if ($frupnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:assetType"} = "Card";

					if ( $dslotnum >= 0 )
					{
						my $actualslotnum = $dslotnum;
						$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotNumber} =
						    $actualslotnum > 99
						  ? $actualslotnum -= 100
						  : $actualslotnum += 0;
					}
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotName} = $dslotname if ($dslotname);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotType} = $mslotType if ($mslotType);
				}
				$dslotnum         = $2 + 100;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "";
				$dslotname        = $1;
				$nodesc           = 1;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "daughter";
			}

			# PA Bay daughter card
			elsif (( $line =~ /(PA\s+Bay)\s+(\d+)\s+Information:/i )
				or ( $line =~ /(PA)\s+(\d+)\s+Information:/i ) )
			{

				$dslotnum         = $2;
				$desc             = "";
				$hwVer            = "";
				$snum             = "";
				$pnum             = "";
				$frupnum          = "";
				$mslotType        = "";
				$dslotname        = $1;
				$nodesc           = 0;
				$nodescencryptaim = 0;
				$nodescaimmodule  = 0;
				$nodescaimcarrier = 0;
				$cardtype         = "daughter";
			}

			# description
			elsif (
				    ($cardtype)
				and ( $desc eq "" )
				and (  ( $line =~ /\s*(.*\s+Port\s+adapter,\s+\S+\s+\S+)/i )
					or ( $line =~ /\s*(.*\s+[a-z]+.\s+Port\s+adapter)/i )
					or ( $line =~ /\s*(.*daughter\s+card)/i ) )
			  )
			{
				$desc = trim($1);
			}

			# description and Hardware revision
			elsif ( ($cardtype)
				and ( $line =~ /\s+([^,]+),\s+HW\s+rev\s+([^,]+),\s+board\s+revision\s+(\S+)/i ) )
			{
				$desc = $1;
				$hwVer = $2 if ($hwVer);
			}

			# Hardware revision and board revision
			elsif ( ($cardtype)
				and ( $line =~ /Hardware revision\s([^ ]+)\s+Board revision\s+([^ ]+)/i ) )
			{
				$hwVer = $1;
			}

			# description -- 2nd line after "slot" as default case
			elsif ( ( $desc eq "" )
				and ( $nodesc == 0 )
				and ( $nodescencryptaim == 0 )
				and ( $nodescaimmodule == 0 )
				and ( $nodescaimcarrier == 0 )
				and ( $line =~ /\s+(.*)/ ) )
			{
				$desc = $1;
			}

			elsif (
				($cardtype)
				and (
					(
						$line =~
						/\s+(Hardware|(.*),\s+HW)\s+(Revision|rev)\s+(\d+.\d+)[,\s+]\s+Board\s+Revision\s+(\S+)/i
					)
					or ( $line =~ /((HW)\s+(rev))\s+(\S+),\s+Board\s+revision/i )
				)
			  )
			{
				$hwVer = $4 if ( !$hwVer );
			}

			# hardwareVersion
			elsif ( ($cardtype) and ( $line =~ /\s+Hardware\s+Revision\s+:\s+(\d+.\d+)/i ) )
			{
				$hwVer = $1 if ( !$hwVer );
			}

			# serialNumber must precede the next serial number and part number
			elsif ( ($cardtype)
				and ( $line =~ /\s+Serial\s+Number[:\s+]\s+(\S+|\d+)\s+Part\s+Number[:\s+]\s+(\S+|\d+).*/i ) )
			{
				$snum = $1 if ( !$snum );
				$pnum = $2 if ( !$pnum );

				if ( ( $dslotname =~ /PA/ ) and ( $cardtype eq "daughter" ) )
				{
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:description"} = $desc if ($desc);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:make"} = "Cisco";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:modelNumber"} = "Unknown";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:hardwareVersion"} = $hwVer
					  if ($hwVer);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:serialNumber"} = $snum
					  if ($snum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:partNumber"} = $pnum
					  if ($pnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:fruPartNumber"} = $frupnum
					  if ($frupnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:assetType"} = "Card";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotNumber} = $dslotnum  if ( $dslotnum >= 0 );
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotType}   = $mslotType if ($mslotType);
				}
			}

			# serialNumber
			elsif ( ( $cardtype ne "" )
				and ( $line =~ /\s+\S+\s+Serial\s+Number\s+:\s+(\w+)/i ) )
			{
				$snum = $1 if ( !$snum );
			}

			# partNumber
			elsif ( ( $cardtype ne "" )
				and ( $line =~ /\s+Part\s+Number\s+:\s+(\S+)/i ) )
			{
				if ( $pnum eq "" )
				{
					$pnum = $1;
				}
			}

			# FRU partNumber
			elsif (
				( $cardtype ne "" )
				and (  ( $line =~ /FRU Part Number[: ]\s*([^ ]+)/i )
					or ( $line =~ /Product \(FRU\) Number\s+:\s+([^ ]+)/i ) )
			  )
			{
				$frupnum = $1 if ( !$frupnum );
			}

			# connectorType
			elsif ( ( $cardtype ne "" )
				and ( ( $line =~ /Connector\s+Type\s+[: ]\s+(.*)/i ) ) )
			{
				$type = $1;
			}

			elsif ( ( $cardtype ne "" )
				and ( $line =~ /EEPROM\s+contents\s+\(hex\):/i ) )
			{
				if ( $cardtype eq "mother" )
				{
					$cardref->{$slotnum}->{"core:description"} = $desc if ($desc);
					$cardref->{$slotnum}->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}            = "Cisco";
					$cardref->{$slotnum}->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}     = "Unknown";
					$cardref->{$slotnum}->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = $hwVer
					  if ($hwVer);
					$cardref->{$slotnum}->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $snum
					  if ($snum);
					$cardref->{$slotnum}->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} = $pnum if ($pnum);
					$cardref->{$slotnum}->{"core:asset"}->{"core:factoryinfo"}->{"core:fruPartNumber"} = $frupnum
					  if ($frupnum);
					$cardref->{$slotnum}->{"core:asset"}->{"core:assetType"} = "Card";
					$cardref->{$slotnum}->{slotNumber}                       = $mslotnum;
					$cardref->{$slotnum}->{slotType}                         = $mslotType;
				}
				elsif ( $cardtype eq "daughter" )
				{
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:description"} = $desc if ($desc);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:make"} = "Cisco";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:modelNumber"} = "Unknown";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:hardwareVersion"} = $hwVer
					  if ($hwVer);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:serialNumber"} = $snum
					  if ($snum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:partNumber"} = $pnum
					  if ($pnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:factoryinfo"}
					  ->{"core:fruPartNumber"} = $frupnum
					  if ($frupnum);
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{"core:asset"}->{"core:assetType"} = "Card";
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotNumber} = $dslotnum  if ( $dslotnum >= 0 );
					$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotType}   = $mslotType if ( $mslotType >= 0 );

					if ( $dslotnum >= 0 )
					{
						my $actualslotnum = $dslotnum;
						$cardref->{$slotnum}->{daughterCard}->{$dslotnum}->{slotNumber} =
						    $actualslotnum > 99
						  ? $actualslotnum -= 100
						  : $actualslotnum += 0;
					}
				}
				$cardtype = "";
			}
			elsif ( $line =~ /Controller\s+Memory\s+Size:\s+(\d+)\s+MBytes/i )
			{
				my $cardmem = $1 * 1024 * 1024;
				$cardref->{$slotnum}->{memory}->{size} = $cardmem;
			}
		}

		foreach my $key ( keys %$cardref )
		{
			my @dcs;

			# pull off any daughter cards
			if ( defined $cardref->{$key}->{daughterCard} )
			{
				foreach my $dc ( keys %{ $cardref->{$key}->{daughterCard} } )
				{
					push( @dcs, $cardref->{$key}->{daughterCard}->{$dc} );
				}
				$cardref->{$key}->{daughterCard} = \@dcs if ( @dcs > 0 );
			}
			$out->print_element( "card", $cardref->{$key} );
		}
	}
	elsif ( defined $in->{version} )
	{
		my ($stack) =
		  $in->{version} =~
		  /^switch\s+Ports\s+Model\s+SW\sVersion\s+SW\sImage\s*\n--.*\n((?:\*?\s+\d+\s+\d+\s+\S+\s+\S+\s+\S+\s*\n)*)/mi;

		if ($stack)
		{

#			my $members = 0; #count number of member devices (the ones without a *). If > 0 then populate stack information else ignore as it is a stack only of the master.
#			while ( $stack =~ /^(\s+)(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
#			{
#				$members++;
#			}

			#			if ( $members > 0 )
			#			{
			while ( $stack =~ /^(\*?\s+)(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
			{
				my $member = $2;
				$member = "0" . $member if ( $member < 10 );
				my $ports   = $3;
				my $model   = $4;
				my $sw_ver  = $5;
				my $sw_imag = $6;
				my $master  = $1 =~ /\*/mi ? 1 : 0;

				my $card;

				$card->{"core:asset"}->{"core:assetType"}                        = "Card";
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}       = "Cisco";
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} = "$model";
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = "$model";

				if ( $master == 1 )
				{
					my ($serial) = $in->{version} =~ /^System\sserial\snumber\s+:\s+(\S+)/mi;
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $serial if ($serial);

					$card->{"core:description"} = "Master Switch";
				}
				else
				{
					my ($stack_memdef) = $in->{version} =~ /^Switch\s+$member\s*\n-+\n((?:\S+.*\n)*)\s*\n/mi;

					my ($serial) = $stack_memdef =~ /^System\sserial\snumber\s+:\s+(\S+)/mi;
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $serial if ($serial);

					$card->{"core:description"} = "Member Switch";
				}

				$card->{portCount}         = $ports;
				$card->{slotNumber}        = $member;
				$card->{slotType}          = "Stack";
				$card->{"softwareVersion"} = "$sw_ver ($sw_imag)";

				$out->print_element( "card", $card );
			}

			#			}
		}
	}
}

sub parse_services
{
	my ( $input, $output ) = @_;

	$output->open_element("services");

	parse_ntp( $input, $output );
	parse_jailer( $input, $output );

	#other service parsers go here

	$output->close_element("services");
}

sub parse_ntp
{
	my ( $in, $out ) = @_;

	my $ntp;

	my $cfg = $in->{running_config};

	if ( $cfg =~ /^s?ntp/mi )
	{
		while ( $cfg =~ /^ntp\s+access-group\s+(\S+)\s+(\d+)/mig )
		{

			#ntp access-group (query-only) (98)

			my $access;

			$access->{filterList} = $2;
			$access->{groupType}  = $1;

			push( @{ $ntp->{"accessGroup"} }, $access );
		}

		#IOS has no specific NTP enable command - search for ntp master, ntp server or ntp peer to see if it is active
		$ntp->{enabled} =
		  ( $cfg =~
			  /^(?:ntp\s+master\s+\d+)|(?:ntp\s+server\s+\d+\.\d+\.\d+\.\d+)|(?:ntp\s+peer\s+\d+\.\d+\.\d+\.\d+)/mi )
		  ? "true"
		  : "false";

		my ($trusted_key) = $cfg =~ /^ntp\s+trusted-key\s+(\d+)/mi;

		while ( $cfg =~ /^ntp\s+authentication-key\s+(\d+)\s+(md5)\s+(\S+)(?:\s+.*$)/mig )
		{

			#ntp authentication-key 2 md5 0948480E150E1D160D000321212024353E281701 7

			my $key;

			$key->{keyNumber} = $1;
			my $the_key  = $3;
			my $the_rest = $4;

			$key->{keyType}   = ( $2 =~ /md5/mi ) ? "MD5" : "Plain text";
			$key->{serverKey} = $the_key;
			$key->{trusted}   = ( $key->{keyNumber} == $trusted_key ) ? "true" : "false";

			push( @{ $ntp->{"localKeySettings"} }, $key );
		}

		if ( $cfg =~ /^ntp\s+master\+(\d+)/mi )
		{
			$ntp->{masterStratum} = $1;
		}

		if ( $cfg =~ /^ntp\s+max-associations\s+(\d+)/mi )
		{
			$ntp->{maxAssociations} = $1;
		}

		while ( $cfg =~ /^(sntp|ntp)\s+(server|peer)\s+(\d+\.\d+\.\d+\.\d+)\s*(.*)$/mig )
		{

			#(ntp) (peer|server) (1.2.3.4) (key <number> prefer source <interfaceName> version <1|2|3>)

			my $server;

			my $protocol  = $1;
			my $mode      = $2;
			my $server_ip = $3;
			my $rest      = $4;

			if ( $protocol eq "sntp" )
			{
				$server->{mode} = "client";
			}
			else
			{
				$server->{mode} = ( $mode =~ /peer/ ) ? "peer" : "server";
			}

			$server->{serverIPaddress} = $server_ip;

			$server->{protocolVersion}->{protocol} = lc $protocol;
			$server->{protocolVersion}->{version}  = ( $rest =~ /version\s+(\d+)/ ) ? "$1" : "1";

			if ( $rest =~ /key\s+(\d+)/mi )
			{
				$server->{keyNumber} = $1;
			}

			if ( $rest =~ /source\s+(\S+)/mi )
			{
				$server->{sourceInterface} = $1;
			}

			$server->{preference} = ( $rest =~ /prefer/ ) ? "true" : "false";

			push( @{ $ntp->{"server"} }, $server );
		}

		if ( $cfg =~ /^ntp\s+source(?:-interface)\s+(\S+)/mi )
		{
			$ntp->{sourceInterface} = $1;
		}

		$ntp->{useAuthentication} = ( $cfg =~ /^ntp authenticate$/mi ) ? "true" : "false";
	}

	$out->print_element( "ntp", $ntp ) if ($ntp);
}

sub parse_jailer
{
	my ( $in, $out ) = @_;

	my $cfg = $in->{running_config};

	my $jailer;

	#first go check any configured key-chains
	if ( $cfg =~ /^key\s+chain/mi )
	{
		my $keyFob;

		while ( $cfg =~ /^key\s+chain\s+(\S+)\s*\n((?:\s+.*\n)*)/mig )
		{
			my $keyRing;

			$keyRing->{ringName} = $1;
			my $key_blobs = $2;

			while ( $key_blobs =~ /^\skey\s+(\d+)\s*\n((?:\s\s.*\n)*)/mig )
			{
				my $aKey;

				$aKey->{number} = $1;
				my $remainder = $2;

				my ($keyString) = $remainder =~ /^\s+key-string\s+(\d+)\s+(\S+)\s*$/mi;
				$aKey->{string} = $2;

				push( @{ $keyRing->{"key"} }, $aKey ) if ($aKey);
			}

			push( @{ $keyFob->{"keyring"} }, $keyRing ) if ($keyRing);
		}

		$jailer->{keyfob} = $keyFob if ($keyFob);
	}

	#place other Jailer related parsing here (eg. SSL certs/RSA keys)

	$out->print_element( "jailer", $jailer ) if ($jailer);
}

sub parse_mpls
{
	my ( $in, $out ) = @_;

	my $mpls;

	$out->print_element( 'mpls', $mpls ) if ( defined $mpls );
}

sub parse_qos
{
	my ( $in, $out ) = @_;

	my $precedence_vals = {
		'0' => 'routine',
		'1' => 'priority',
		'2' => 'immediate',
		'3' => 'flash',
		'4' => 'flash-override',
		'5' => 'critical',
		'6' => 'internet',
		'7' => 'network',
	};

	my $qos;

	#parse class_maps

	my $class_maps;

	while ( $in->{running_config} =~ /^class-map\s+match-(any|all)\s+(\S+)\n((?:\s+.*\n)*)/mig )
	{
		my $class_map;

		my $type = $1;
		my $name = $2;
		my $rest = $3;

		$class_map->{domain} = lc $name;
		$class_map->{match}  = lc $type;

		while ( $rest =~ /^\s+match\s+(.*)$/mig )
		{
			my $line = $1;

			my $match;

			$match->{reverseLogic} = 'true' if ( $line =~ /^not\s+/ );

			if ( $line =~ /access\-group\s+(?:name\s+)?(\S+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchAccessGroup"} }, $match );
			}
			elsif ( $line =~ /class\-map\s+(\S+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchClassMap"} }, $match );
			}
			elsif ( $line =~ /destination\-address\s+mac\s+(\S+)/mi )
			{
				$match->{value} = strip_mac($1);
				push( @{ $class_map->{"matchDestinationMAC"} }, $match );
			}
			elsif ( $line =~ /discard\-class\s+(\d+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchDiscardClass"} }, $match );
			}
			elsif ( $line =~ /fr\-de/mi )
			{
				$match->{value} = 'true';
				push( @{ $class_map->{"matchFrDE"} }, $match );
			}
			elsif ( $line =~ /flow\s+(\S+)/mi )
			{
				$match->{value} = lc $1;
				push( @{ $class_map->{"matchFlow"} }, $match );
			}
			elsif ( $line =~ /fr\-dlci\s+(\d+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchFrDLCI"} }, $match );
			}
			elsif ( $line =~ /input\-interface\s+(\S+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchInputInterface"} }, $match );
			}
			elsif ( $line =~ /cos((?:\s+\d+)+)/mi )
			{
				my $blob = $1;
				while ( $blob =~ /\s+(\d+)/mig )
				{
					push( @{ $match->{"value"} }, $1 );
				}

				push( @{ $class_map->{"matchIpCOS"} }, $match );
			}
			elsif ( $line =~ /ip dscp((?:\s+\S+)+)/mi )    #dscp string
			{
				my $blob       = $1;
				my $foundMatch = 0;
				while ( $blob =~ /\s+(\d+)/mig )
				{
					$foundMatch = 1;
					push( @{ $match->{"value"} }, $1 );
				}
				push( @{ $class_map->{"matchIpDSCP"} }, $match ) if $foundMatch;
			}
			elsif ( $line =~ /ip\s+precedence((?:\s+\S+)+)/mi )    #ip precedence
			{
				my $blob = $1;
				while ( $blob =~ /\s+(\d+)/mig )
				{
					my $new_val = $precedence_vals->{$1};
					push( @{ $match->{"value"} }, $new_val );
				}

				push( @{ $class_map->{"matchIpPrecedence"} }, $match );
			}
			elsif ( $line =~ /packet\s+length((?:\s+(?:min|max)\s+\d+)*)/mi )    #packet length
			{
				my $blob = $1;
				my ($min) = $blob =~ /min\s+(\d+)/mi;
				my ($max) = $blob =~ /max\s+(\d+)/mi;

				$match->{minValue} = $min if $min;
				$match->{maxValue} = $max if $max;

				push( @{ $class_map->{"matchPacketLength"} }, $match );
			}
			elsif ( $line =~ /protocol\s+(\S+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchProtocol"} }, $match );
			}
			elsif ( $line =~ /qos\-group\s+(\d+)/mi )
			{
				$match->{value} = $1;
				push( @{ $class_map->{"matchQosGroup"} }, $match );
			}
			elsif ( $line =~ /ip\s+rtp\s+(\d+\s+\d+)/mi )    #real-time protocol
			{
				my $blob = $1;
				my ( $start, $range ) = $blob =~ /(\d+)\s+(\d+)/mi;

				$match->{startPort} = $start;
				$match->{endPort}   = $start + $range;

				push( @{ $class_map->{"matchRTPport"} }, $match );
			}
			elsif ( $line =~ /source\-address\s+mac\s+(\S+)/mi )
			{
				$match->{value} = strip_mac($1);
				push( @{ $class_map->{"matchSourceMAC"} }, $match );
			}
			elsif ( $line =~ /vlan((?:\s+\d+(?:\-\d+)?)+)/mi )
			{
				my $vlan_string = $1;
				while ( $vlan_string =~ /((?:\d+)(?:\-\d+)?)/mig )
				{
					push( @{ $match->{"value"} }, $1 );
				}

				push( @{ $class_map->{"matchVlan"} }, $match );
			}

			#parsing for any other class map elements to go here

		}

		push( @{ $class_maps->{"classMap"} }, $class_map );
	}

	push( @{ $qos->{"qosClasses"} }, $class_maps ) if ($class_maps);

	#parse policy_maps

	my $policy_maps;

	while ( $in->{running_config} =~ /^policy-map\s+(\S+)\n((?:\s.*?\n)*)/mig )
	{
		my $policy_map;

		my $name = $1;
		my $rest = $2;

		$policy_map->{name} = $name;

		while ( $rest =~ /^\sclass\s+(\S+)\n((?:\s\s+.*?\n)*)/mig )
		{
			my $class_name = $1;
			my $class_blob = $2;

			my $class;

			$class->{classDomain} = $class_name;

			while ( $class_blob =~ /^\s+(.*)$/mig )
			{
				my $action = $1;

				if ( $action =~ /^set atm-clp/mi )
				{
					$class->{atmCLP} = 'true';
				}
				elsif ( $action =~ /^set\s+cos\s+(\d+)/mi )
				{
					$class->{cosValue} = $1;
				}
				elsif ( $action =~ /^set\s+discard\-class\s+(\d+)/mi )
				{
					$class->{discardClass} = $1;
				}
				elsif ( $action =~ /^set\s+ip\s+dscp\s+(\d+)/mi )
				{
					$class->{ipDSCP} = $1;
				}
				elsif ( $action =~ /^set\s+fr\-de/mi )
				{
					$class->{frDE} = 'true';
				}
				elsif ( $action =~ /^set\s+ip\s+precedence\s+(\d+)/mi )
				{
					$class->{ipPrecedence} = $precedence_vals->{$1};
				}
				elsif ( $action =~ /^set\s+qos\-group\s+(\S+)/mi )
				{
					$class->{qosGroup} = $1;
				}
				elsif ( $action =~ /^drop/mi )
				{
					$class->{drop} = 'true';
				}
				elsif ( $action =~ /^bandwidth\s+(.+)/mi )
				{
					my $line = $1;
					my $result;

					if ( $line =~ /^(\d+)$/mi )
					{
						$result->{bandwidthBits} = $1;
					}
					elsif ( $line =~ /^remaining\s+percent\s+(\d+)/mi )
					{
						$result->{remainingPercent} = $1;
					}
					elsif ( $line =~ /^percent\s+(\d+)/mi )
					{
						$result->{bandwidthPercent} = $1;
					}

					$class->{bandwidth} = $result if ($result);
				}
				elsif ( $action =~ /^shape\s+(average|peak)\s+(.*)/mi )
				{
					my $type = $1;
					my $rest = $2;

					my $shape;

					$shape->{type} = $type;

					if ( $rest =~ /percent\s+(.*)/mi )
					{
						my $vals = $1;

						my ( $per, $sus, $exc ) = $vals =~ /(\d+)(?:\s+(\d+)\s+ms)?(?:\s+(\d+)\s+ms)?/mi;

						$shape->{percent}->{cirPercentage}   = $per;
						$shape->{percent}->{sustainedPeriod} = $sus if ($sus);
						$shape->{percent}->{excessPeriod}    = $exc if ($exc);
					}
					else
					{
						my ( $bps, $sus, $exc ) = $rest =~ /(\d+)(?:\s+(\d+))?(?:\s+(\d+))?/mi;

						$shape->{rate}->{targetRate}    = $bps;
						$shape->{rate}->{sustainedRate} = $sus if ($sus);
						$shape->{rate}->{excessRate}    = $exc if ($exc);
					}

					$class->{shaping} = $shape;
				}
				elsif ( $action =~
/^police\s+(\d+)\s+(\d+)(?:\s+(\d+))?\s+conform-action\s+(.*?)\s+exceed-action\s+(.*?)(?:\sviolate-action\s+(.*?))\s*$/mi
				  )
				{
					my $bps         = $1;
					my $burst_norm  = $2;
					my $burst_max   = $3;
					my $conf_action = $4;
					my $exce_action = $5;
					my $viol_action = $6;

					my $cir = { bandwidthBits => $bps };

					my $police = {
						bps         => $cir,
						normalBurst => $burst_norm,
					};

					$police->{maxBurst}      = $burst_max if ($burst_max);
					$police->{conformAction} = _set_action($conf_action);
					$police->{exceedAction}  = _set_action($exce_action);
					$police->{violateAction} = _set_action($viol_action) if ($viol_action);

					$class->{police} = $police;
				}

				#TODO: priority bandwidth <value> - is this used by anyone?

			}

			push( @{ $policy_map->{"class"} }, $class );
		}

		push( @{ $policy_maps->{"policyMap"} }, $policy_map );
	}

	push( @{ $qos->{"qosPolicies"} }, $policy_maps ) if ($policy_maps);

	#do any other QOS parsing here

	$out->print_element( 'qos', $qos ) if ( defined $qos );
}

sub _set_action
{
	my $action_string = shift;

	my $action;

	if ( $action_string =~ /^continue$/mi )
	{
		$action->{continue} = "true";
	}
	elsif ( $action_string =~ /^drop$/mi )
	{
		$action->{drop} = "true";
	}
	elsif ( $action_string =~ /^set-dscp-continue\s+(\S+)\s*$/mi )
	{
		$action->{setDSCPContinue} = $1;
	}
	elsif ( $action_string =~ /^set-dscp-transmit\s+(\S+)\s*$/mi )
	{
		$action->{setDSCPTransmit} = $1;
	}
	elsif ( $action_string =~ /^set-mpls-exp-continue\s+(\S+)\s*$/mi )
	{
		$action->{setMPLSexpContinue} = $1;
	}
	elsif ( $action_string =~ /^set-mpls-exp-transmit\s+(\S+)\s*$/mi )
	{
		$action->{setMPLSexpTransmit} = $1;
	}
	elsif ( $action_string =~ /^set-prec-continue\s+(\S+)\s*$/mi )
	{
		$action->{setPrecedenceContinue} = $1;
	}
	elsif ( $action_string =~ /^set-prec-transmit\s+(\S+)\s*$/mi )
	{
		$action->{setPrecedenceTransmit} = $1;
	}
	elsif ( $action_string =~ /^set-qos-continue\s+(\S+)\s*$/mi )
	{
		$action->{setQosContinue} = $1;
	}
	elsif ( $action_string =~ /^set-qos-transmit\s+(\S+)\s*$/mi )
	{
		$action->{setQosGroupTransmit} = $1;
	}
	elsif ( $action_string =~ /^transmit$/mi )
	{
		$action->{transmit} = "true";
	}

	return $action;
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

sub _apply_masks
{

	# remove any trivial pieces of the configuration that
	# may cause improper diffs.

	my $text = shift;
	$text =~ s/\n^ntp clock-period.+$//m;                    # remove the variable ntp clock-period line
	$text =~ s/\n^!\s*NVRAM config last updated at.+$//m;    # remove the NVRAM updated time comment
	$text =~ s/\n^!\s*Last configuration change at.+$//m;    # remove the Last config change comment
	return $text;
}

sub _inverse_wildcard_mask
{

	# i.e. turn 0.0.255.255 into 255.255.0.0
	my $mask_wild_dotted = shift;
	my $mask_wild_packed = pack 'C4', split /\./, $mask_wild_dotted;
	my $mask_norm_packed = ~$mask_wild_packed;
	my $mask_norm_dotted = join '.', unpack 'C4', $mask_norm_packed;
	return $mask_norm_dotted;
}

1;
