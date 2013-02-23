package ZipTie::Adapters::Cisco::CS500::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw( create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_access_ports);
  

# Class constants.
# The reasonable memory sizes in MBs: 2 to the n-th power.
our @VALID_MEMSIZES = map { 2**$_ } qw(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16);

# The string which collects the sizes from 4 (2**2) MBs to 65536 (2**16) MBs.
# Format the array into a space-padded string.
our $SIZEPATTERNS_STRING = " @VALID_MEMSIZES ";

# The number of KBs in 80 percent of 1 MB.
our $KBS_80PERCENTMB = int( my $volatile = 1024 * 0.8 );

# Common ip/mask regular expression
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
our $MAC 	= '[0-9a-f]{4}\.[0-9a-f]{4}\.[0-9a-f]{4}';


sub parse_chassis
{
	my ( $in, $out ) = @_;
	
	my $cpuref;
	my $cpuid           = -1;
	my $cpuDescription     = "";
	my $systemimagefile = "";

	my ( $flashpbtype, $flashpbname, $flashpbsize ) = ( 0, 0, -1 );
	my ( $flashpc0type, $flashpc0name, $flashpc0size, $flashpc0num ) = ( 0, 0, -1, 0 );
	my ( $flashpc1type, $flashpc1name, $flashpc1size, $flashpc1num ) = ( 0, 0, -1, 0 );
	my ( $flashpu0type, $flashpu0name, $flashpu0size, $flashpu0num ) = ( 0, 0, -1, 0 );
	my ( $flashpu1type, $flashpu1name, $flashpu1size, $flashpu1num ) = ( 0, 0, -1, 0 );
	my ( $flashp1type,  $flashp1name,  $flashp1size,  $flashp1num )  = ( 0, 0, -1, 0 );
	my ( $flashp2type,  $flashp2name,  $flashp2size,  $flashp2num )  = ( 0, 0, -1, 0 );
	my ($dualFlashFlag) = 0;
	my ( $configMemory, $ramMemory, $packetMemory, $processorBoard );

	foreach my $line ( split( /\n/, $in->{version} ) )
	{
		if (   ( $line =~ /(Cisco\S+\s+\((.*)\) processor\s+.*\s+with \S+ bytes of memory)/i )
			or ( $line =~ /(Cisco\S+\s+\((.*)\) processor with \S+ bytes of memory.)/i ) )
		{
			$cpuid          = 0;
			$processorBoard = $2;
			$cpuDescription = $1;
		}
		elsif ( $line =~ /System\s+image\s+file\s+is\s+"(\S+)"/i )
		{
			$systemimagefile = $1;
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
				( $flashpu0type, $flashpu0name, $flashpu0size, $flashpu0num ) = ( lcfirst($slotnum), "pcmcia", $flashsize, 0 );
			}
			elsif ( $slotnum =~ /1/ )
			{
				( $flashpu1type, $flashpu1name, $flashpu1size, $flashpu1num ) = ( lcfirst($slotnum), "pcmcia", $flashsize, 1 );
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

	}

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = "CS500";

	$out->print_element( "core:asset", $chassisAsset );

	# chassis/core:description
	if ($in->{version} =~ /(^CS\s+Software.+\nCopyright.+\nCompiled[^\n]+)/msi)
	{
		$out->print_element( "core:description", $1);
	}
	

	my $cpu;
	$cpu->{"core:description"} = $cpuDescription if $cpuid != -1 and $cpuDescription;
	$cpu->{cpuType} = $processorBoard if $cpuid != -1 and $processorBoard;
	$out->print_element( "cpu", $cpu );

	my @memories = ();
	push @memories, { kind => 'Flash', size => $flashpbsize * 1024 }  if $flashpbsize != -1  and $flashpbtype  ne "";
	push @memories, { kind => 'Flash', size => $flashpc0size * 1024 } if $flashpc0size != -1 and $flashpc0type ne "";
	push @memories, { kind => 'Flash', size => $flashpc1size * 1024 } if $flashpc1size != -1 and $flashpc1type ne "";
	push @memories, { kind => 'Flash', size => $flashpu0size * 1024 } if $flashpu0size != -1 and $flashpu0type ne "";
	push @memories, { kind => 'Flash', size => $flashpu1size * 1024 } if $flashpu1size != -1 and $flashpu1type ne "";
	push @memories, { kind => 'Flash', size => $flashp1size * 1024 }  if $flashp1size != -1  and $flashp1type  ne "";
	push @memories, { kind => 'Flash', size => $flashp2size * 1024 }  if $flashp2size != -1  and $flashp2type  ne "";
	push @memories, { 'core:description' => 'RAM',          kind => 'RAM',          size => $ramMemory * 1024 }    if $ramMemory;
	push @memories, { 'core:description' => 'PacketMemory', kind => 'PacketMemory', size => $packetMemory * 1024 } if $packetMemory;
	push @memories, { kind => 'ConfigurationMemory', size => $configMemory * 1024 } if $configMemory;

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;
	
	my ($systemName) = $in->{config} =~ /^hostname (\S+)/mi;
	$out->print_element( 'core:systemName', "$systemName" );

	$out->open_element('core:osInfo');
	if ( $in->{version} =~ /^System image file is "([^"]+)/m )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Cisco' );
	if ( $in->{version} =~ /^(CS Software.+?),/m )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{version} =~ /^(?:CS Software)?.+?CS500.+Version (\S[^\s,]+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	elsif ( $in->{version} =~ /^Version\s+V(\d+\.\d+\.\d+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'CS500' );
	$out->close_element('core:osInfo');

	if (   ( $in->{version} =~ /ROM:\s+System\s+Bootstrap[,]\s+Version\s+([^\s,]+)/i )
		or ( $in->{version} =~ /ROM:\s+Bootstrap\s+program\s+is\s+(.*)/i )
		or ( $in->{version} =~ /BOOTLDR:\s+\S+\s+Boot\s+Loader.*Version\s+([^\s,]+)/i )
		or ( $in->{version} =~ /^ROM:\s+TinyROM\s+version\s+([^\s]+)/mi )
		or ( $in->{version} =~ /^ROM:\s+([^\s]+)/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Terminal Server' );

	my ($contact) = $in->{config} =~ /^snmp-server contact (.+)/m;
	$out->print_element( 'core:contact', $contact );

	# System restarted at 18:00:01 CST Sun Feb 28 1993
	if ( $in->{version} =~ /^System restarted (?:by \S+\s)?at\s+(\d{1,2}:\d{1,2}:\d{1,2})\s+(\S+)\s+\S+\s+(\S+)\s+(\d{1,2})\s+(\d{4})/mi )
	{
		my $year     = $5;
		my $month    = $3;
		my $day      = $4;
		my $time     = $1;
		my $timezone = $2;

		my ( $hour, $min, $sec ) = $time =~ /(\d+):(\d+):(\d+)/;

		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
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
	$config->{'core:promotable'} = 'false';                             

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}


sub parse_local_accounts
{
	my ( $in, $out ) = @_;
	
	$out->open_element("localAccounts");
	
	if ($in->{config} =~/^\s*enable password\s+(\S.*)?$/mi)
	{
		$out->print_element( "localAccount", { accountName => 'enable', password => $1} );
	}
	else
	{
		$out->print_element( "localAccount", { accountName => 'enable', password => "unknown"} );
	}
	
	my ($acc_blob) = $in->{config} =~/^!\s*(username[^!]+)/mis;

	while ($acc_blob =~/^username\s+(\w+)(?:\s+password\s+(\S.*))?$/migc)
	{
		$out->print_element( "localAccount", { accountName => $1, password => $2} );
	}
	
	$out->close_element("localAccounts");
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	
	my ($snmp_blob) = $in->{config} =~/^\s*snmp-server community\s*(.*)^banner/migs;
	my $name = undef;
	my $location = undef;
	my $domain = undef;
	
	$out->open_element("snmp");
	
	while ($snmp_blob =~/^snmp-server community\s+(\w+)\s+(RO|RW)\s*$/migc)
	{
		$out->print_element( "community", { communityString => $1, accessType => uc($2) } );
	}
	if ( $snmp_blob =~ /^snmp-server\s+location\s+(\S+)/migc )
	{
		$location = $1;
	}
	if ( $snmp_blob =~ /^snmp-server\s+contact\s+(\S+)/migc )
	{
		$out->print_element( "sysContact", $1 );
	}
	
	if ( $in->{config} =~ /^hostname (\S+)/migc )
	{
		$name = $1;
	}
	
	if ( $in->{config} =~ /^ip domain-name (\S+)/migc )
	{
		$domain = $1;
	}

	if ($location)
	{
		$out->print_element( "sysLocation", $location );
	}
	if($name)
	{
		if($domain)
		{
			$out->print_element( "sysName", "$name.$domain" );
		}
		else
		{
			$out->print_element( "sysName", $name );
		}
	}

	$out->close_element("snmp");
	
		
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	
	my $name;
	my $macAddr;
	my $ip;
	my $mtu;
	my $mask;
	my $status;
	
	$out->open_element("interfaces");
	
	#In theory, this will always match only once, 
	#but we try to capture more than one interface
	#for robustness purposes.
	while ($in->{interfaces} =~/^(\w+) is (\w+), .*address is ($MAC).*Internet address is ($CIPM_RE), subnet mask is ($CIPM_RE).*MTU\s(\d+)\sbytes,.*$/migcs)
	{
		my $interface = {
					name		=> $1,
					adminStatus	=> lc($2),
					interfaceType	=> "unknown",
					physical	=> "true",
					mtu		=> $6
				};

		$interface->{interfaceEthernet}->{macAddress}	= strip_mac($3);
		$interface->{interfaceIp}->{ipConfiguration}->{ipAddress} = $4;
		$interface->{interfaceIp}->{ipConfiguration}->{mask} = mask_to_bits($5);
		$out->print_element( "interface", $interface );
	}
	
	$out->close_element("interfaces");
		
}

sub parse_access_ports
{
	my ( $in, $out ) = @_;
	
	my ($ports_blob) = $in->{accessPorts} =~/ .*?Overruns\s+(.*)$/mis;
	
	$out->open_element("accessPorts");
	
	while ($ports_blob =~/^[\*|\s]+(\d+)\s+(\w+)\.*/migc)
	{
		my $port = {type => $2, startInstance => $1};
		$out->print_element("accessPort", $port);
	}
	
	$out->close_element("accessPorts");
			    
}


1;
