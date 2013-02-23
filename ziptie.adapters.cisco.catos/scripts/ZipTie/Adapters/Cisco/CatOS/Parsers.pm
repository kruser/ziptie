package ZipTie::Adapters::Cisco::CatOS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_arp parse_cdp parse_telemetry_interfaces parse_mac_table parse_vtp parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_services);

sub parse_arp
{
	my ( $in, $out ) = @_;
	$out->open_element('arpTable');

	while ( $in->{arp} =~ /^(\S+)\s+at\s+(\S+)\s+port\s+(\S+)\s+on\s+vlan\s+(\S+)\s*$/mig )
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
	my $version;
	if ( $in->{cdp} =~ /Version\s+:\s+(\S.+)/mi )
	{
		$version = trim ( $1 );
	}
	while ( $in->{cdp} =~ /^\s+(\d+\/\d+)\s+(\S+)\s+(\S+)\s+(\S.+)$/mig )
	{
		$out->open_element('discoveryProtocolNeighbors') if (!$opened);
		$opened = 1;
		my $port		= $1;
		my $deviceId	= $2;
		my $portId		= $3;
		my $platform	= $4;
		my $singleCdpBlob = trim ( $1 );
		my $neighbor = { protocol => 'CDP', };
		$neighbor->{sysName}		= $deviceId;
		$neighbor->{localInterface} = $port;
		$neighbor->{platform}		= $platform;
		$neighbor->{sysDescr}		= $version;
		$out->print_element('discoveryProtocolNeighbor', $neighbor);
	}
	$out->close_element('discoveryProtocolNeighbors') if ($opened);
}

sub parse_telemetry_interfaces
{
	my ( $in, $out ) = @_;
	my $interfaces;

	my ( $status_blob ) = $in->{port_status} =~ /^[-\s]+^(.+)/imsg;
	while ( $status_blob =~ /^\s*(\S+)(?:\s+\S+)?\s+(\S+)\s+(\d+)\s+\S+\s+\S+\s+\S+\s+(?:No Connector|\S+)\s*$/mig )
	{
		my $vlan = $3;
		my $interface = {
			name       => $1,
			type       => 'ethernet',
			inputBytes => 0,
			operStatus => ( $2 eq 'connected' ? 'Up' : 'Down' ),
		};
		$_ = $1;
		$interface->{inputBytes} = $1 if ( $in->{"port_counters_$_"} =~ /rxByteCount\s+=\s+(\d+)\s+/mi );
		if ( $in->{interface} =~ /^\s*vlan\s+$vlan\s+inet\s+(\S+)\s+netmask\s+(\S+)/mi )
		{
			my $ipEntry = {
				ipAddress => $1,
				mask      => mask_to_bits ( $2 ),
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
	while ( $in->{mac} =~ /^(\d+)\s+(\S+)\s+(\S+)\s.+$/mig )
	{
		if (!$openedMacTable)
		{
			$out->open_element('macTable');
			$openedMacTable = 1;
		}
		my $macEntry = {
			vlan => $1,
			macAddress => strip_mac($2),
			interface => _full_int_name($3),
		};
		$out->print_element('macEntry', $macEntry);
	}
	$out->close_element('macTable') if ($openedMacTable);
}

sub parse_vtp
{
	my ( $in, $out ) = @_;
	my @vtp_pieces = create_array_from_output( $in->{vtp_info} );
	my $vtp;

	my @cl = get_column_lengths( $vtp_pieces[0] );
	if ( $vtp_pieces[0] =~ /^\-[\-\s]+^(.{$cl[0]})\s+(.{$cl[1]})\s+(\d{1,$cl[2]})\s+(\S{1,$cl[3]})\s+(.+)$/mi )
	{
		$vtp->{'cisco:version'}    = $3;
		$vtp->{'cisco:domainName'} = $1;
		$vtp->{'cisco:localMode'}  = $4;
		$vtp->{'cisco:version'}    =~ s/\s+$//;
		$vtp->{'cisco:domainName'} =~ s/\s+$//;
		$vtp->{'cisco:localMode'}  =~ s/\s+$//;
		$vtp->{'cisco:localMode'}  = ucfirst( $vtp->{'cisco:localMode'} );
	}

	@cl = get_column_lengths( $vtp_pieces[1] );
	if ( $vtp_pieces[1] =~ /^\-[\-\s]+^(\d{1,$cl[0]})\s+(\d{1,$cl[1]})\s+(\d{1,$cl[2]})\s+(\S{1,$cl[3]})/mi )
	{
		$vtp->{'cisco:maxVlanCount'}             = $2;
		$vtp->{'cisco:vlanCount'}                = $1;
		$vtp->{'cisco:configVersion'}            = $3;
		$vtp->{'cisco:alarmNotificationEnabled'} = ( $4 =~ /^enabl/i ) ? 'true' : 'false';
		$vtp->{'cisco:maxVlanCount'}  =~ s/\s+$//;
		$vtp->{'cisco:vlanCount'}     =~ s/\s+$//;
		$vtp->{'cisco:configVersion'} =~ s/\s+$//;
	}

	@cl = get_column_lengths( $vtp_pieces[2] );
	if ( $vtp_pieces[2] =~ /^\-[\-\s]+^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S{1,$cl[1]})\s+(\S{1,$cl[2]})\s+(\S{1,$cl[3]})/mi )
	{
		$vtp->{'cisco:lastUpdater'}        = $1;
		$vtp->{'cisco:v2Mode'}             = $2;
		$vtp->{'cisco:vlanPruningEnabled'} = ( $3 =~ /^enabl/i ) ? 'true' : 'false';
		$vtp->{'cisco:lastUpdater'} =~ s/\s+$//;
		$vtp->{'cisco:v2Mode'}      =~ s/\s+$//;
	}

	#if ( $in->{vtp_info} =~ /^MD5 digest\s*:\s*(.*[^\s])$/mi )
	#{
	#	$vtp->{'cisco:password'} = $1;
	#}

	$vtp->{'cisco:serviceType'} = "vtp" if ( defined $vtp->{localMode} );

	$out->print_element( "cisco:vlanTrunking", $vtp );
}

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my @version_pieces = create_array_from_output( $in->{version} );

	# remove warning
	if ( $version_pieces[0] =~ /^WARNING:/mi )
	{
		shift(@version_pieces);
	}

	# get memory part
	my $unparsedMem = join( "\n", grep ( /^\s+(DRAM|FLASH|NVRAM)/i, @version_pieces ) );

	# delete the dash line
	$unparsedMem =~ s/^[\-\s]+$//;

	# parse memory
	my $dram  = { p => 1, s => 0 };
	my $nvram = { p => 3, s => 0 };
	my $flash = { p => 2, s => 0 };
	my @memories = ();
	while ( $unparsedMem =~ /^(.+)$/mg )
	{
		my $memline = $1;

		# let's just use the easiest one
		if (   ( $dram->{p} > 0 )
			&& ( $nvram->{p} > 0 )
			&& ( $flash->{p} > 0 )
			&& ( $memline =~ /^\d+\s+(\d+)K\s+\d+K\s+\d+K\s+(\d+)K\s+\d+K\s+\d+K\s+(\d+)K\s+\d+K\s+\d+K/i ) )
		{
			eval( '$dram->{s} = $dram->{s} + $' . $dram->{p} . ' * 1024;' );
			eval( '$nvram->{s} = $nvram->{s} + $' . $nvram->{p} . ' * 1024;' );
			eval( '$flash->{s} = $flash->{s} + $' . $flash->{p} . ' * 1024;' );
		}
	}
	push @memories, { kind => 'RAM',                 size => $dram->{s} };
	push @memories, { kind => 'ConfigurationMemory', size => $nvram->{s} };
	push @memories, { kind => 'Flash',               size => $flash->{s} };

	$out->open_element("chassis");

	# get hardware/model/serial part
	my $unparsedNumbers = "";
	if ( $in->{version} =~ /^(Hardware Version:.+)$/mi )
	{
		$unparsedNumbers = $1;
	}

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{version} =~ /^Hardware Version:?\s+([^\s\,]+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	if ( $unparsedNumbers =~ /\bSerial\s+#:?\s+([^\s\,]+)/i )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";
	if ( $unparsedNumbers =~ /\bModel:\s+(\S+)/i )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	$out->print_element( "core:asset", $chassisAsset );
	if ( $in->{version} =~ /^(WS-\S+ Software.+?)^\s+^/mis )
	{
		$out->print_element( 'core:description', $1 );
	}

	_parse_cards( $in, $out );

	#my $cpu;
	#$cpu->{"core:description"} = $description if $cpuid != -1 and $description;
	#$cpu->{cpuType} = $processorBoard if $cpuid != -1 and $processorBoard;
	#$out->print_element( "cpu", $cpu );

	_parse_file_storage( $in, $out );

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	_parse_power_supply( $in, $out );

	$out->close_element("chassis");
}

sub _parse_cards
{
	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	if ( defined $in->{module} )
	{
		my $verBlob;
		if ( $in->{mod_ver} =~ /(Bad module range|Error|Incorrect)/mi )
		{
			$verBlob = $in->{version};
		}
		else
		{
			$verBlob = $in->{mod_ver};
		}
		my @module_pieces = create_array_from_output( $in->{module} );
		my @cl1           = get_column_lengths( $module_pieces[0] );

		while ( $module_pieces[0] =~ /^\s*(\d+)\s+(\d+)\s+(\d+)\s+\b(.{$cl1[3]})\s+(WS\-\S+)\s+(\S+)\s+(\S+)\s*$/mig )
		{
			my $mod        = $1;
			my $no         = $2;
			my $portCount  = $3;
			my $cardStatus = $7;
			my $card       = {
				slotNumber         => $no,
				portCount          => $portCount,
				status		   => $cardStatus,
				"core:description" => $4,
			};

			my $modelNumber  = $5;
			my $partNumber   = $modelNumber;
			my $serialNumber = "";
			$card->{"core:description"} =~ s/\s+$//;
			$card->{"core:asset"}->{"core:assetType"} = "Card";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}		= 'Cisco';
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= $modelNumber;
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"}	= $partNumber;
			if ( $module_pieces[1] =~ /^$mod\s+.+\b(\S+)\s*$/mi )
			{
				$serialNumber = $1;
			}
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $serialNumber;

			# now get the HW, FW and SW versions
			( $_ ) = $verBlob =~ /^$mod(.+?)(?:^\d+|^\s+DRAM)/mis;
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = trim ( $1 ) if ( /\bHw\s+:(.+)$/mi );
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:firmwareVersion"} = trim ( $1 ) if ( /\bFw\s+:(.+)$/mi );
			$card->{"softwareVersion"}                                            = trim ( $1 ) if ( /\bSw\s+:(.+)$/mi );

			# now get any daughter cards (sub-mod)
			if ( defined $module_pieces[3] )
			{
				if ( $module_pieces[3] =~ /^\-[\s\-]+^(\S.+)/msi )
				{
					my $dcardContent = $1;
					while ( $dcardContent =~ /^$mod\s+(.+?)\s+(WS-\S+)\s+(\S+)\s+([^\s,]+),?\s*(\d+\.\S+)?\s*/mig )
					{
						my $daughterCard = { "core:description" => $1, };
						$daughterCard->{"core:asset"}->{"core:assetType"}                             				= "Card";
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}	      		= "Cisco";
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}		= $2;
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} 		= $2;
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}  	= $3;
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} 	= $4;
						$daughterCard->{"softwareVersion"} = $5 if ($5);

						push( @{ $card->{daughterCard} }, $daughterCard );
					}
				}
			}
			$out->print_element( "card", $card );
		}
	}
}

sub _parse_file_storage

{
	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;

	if ($in->{file_systems})
	{
		my @getFS = $in->{show_fs};
		my @filesys_pieces;
		my $storage = {};

		foreach my $gotFS (@getFS)
		{
			if ($gotFS =~ /(\S+,.+$)/m)	# Expect a comma delimited list of file systems ...
			{
				@filesys_pieces = split(/,\s/, $1);
			}
            elsif ($gotFS =~ /^(\w+)\s*$/m) # ... or a single file system.
			{
				push(@filesys_pieces, $1);
			}
		}

		foreach my $filesys_piece (@filesys_pieces)
		{
			if ($in->{file_systems}->{$filesys_piece} =~ /(show\sflash\s$filesys_piece.+?(\d+)\sbytes\savailable\s\((\d+)\sbytes\sused\))/sig)
			{
				my $flashSection 	= $1;
				my $bytesAvailable 	= $2;
				my $bytesUsed		= $3;

				$storage->{rootDir} 	= { name => "root", };
				$storage->{name}        = $filesys_piece;
				$storage->{storageType} = 'flash';
				$storage->{size}	= $bytesAvailable + $bytesUsed;
				$storage->{freeSpace}	= $bytesAvailable;

				# header of the files output (show flash 'flash_filesystem')
				# -#- ED --type-- --crc--- -seek-- nlen -length- -----date/time------ name
				if ($flashSection =~ /^-\#-\s+ED\s+--type--\s+--crc---\s+-seek--/mi)
				{
					while ($flashSection =~ /^\s*\d{1,3}\s+\S{1,2}\s+([a-f0-9]{1,8})\s+([a-f0-9]{1,8})\s+[a-f0-9]{1,7}\s+\d{1,4}\s+(\d{1,8})\s+(\S{1}.{19})\s+(.+)$/mig)
					{
						my $file = {
							size => $3,
							name => $5,
						};
						push( @{ $storage->{rootDir}->{file} }, $file );
					}
				}		

				$out->print_element( "deviceStorage", $storage );
			}
		}
	}
}

sub _parse_power_supply
{
	my ( $in, $out ) = @_;

	my $foundPowerSupply = 0;
	my @system_pieces = create_array_from_output( $in->{'system'} );
	while ( $system_pieces[0] =~ /\bPS(\d+)-Status/mig )
	{
		my $power_supply;
		my @ps_regex;
		my $psn = $1;
		for ( 1..$1 )
		{
			push @ps_regex, '\S+';
		}
		$ps_regex[$#ps_regex] = '(\S+)';
		my $pss = join ('\s+', @ps_regex);
		if ( $system_pieces[0] =~ /-+\s+-+\s+$pss/mi )
		{
			$power_supply->{number} = $psn;
			$power_supply->{status} = $1;
		}
		$power_supply->{"core:asset"}->{"core:assetType"}					= "PowerSupply";
		$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}	= 'Cisco';
		if ( $system_pieces[2] =~ /-+\s+-+\s+$pss/mi )
		{
			#$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"}	= $1;
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= $1;
		}
		if ( $in->{'system'} =~ /PS$psn\s+Capacity:?\s+(\S.+)$/mi )
		{
			$power_supply->{'core:description'} = trim($1);
		}
		if ( $in->{version} =~ /PS$psn\s+Module:\s+\S+\s+Serial #:\s+(\S+)/mi )
		{
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $1;
		}
		$out->print_element( "powersupply", $power_supply );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{config} =~ /^set\s+system\s+name(.+)$/mi;
	$systemName = 'Console' if ( $systemName =~ /^\s*$/ );
	$out->print_element( 'core:systemName', trim( $systemName ) );

	$out->open_element('core:osInfo');
	if ( $in->{bootinfo} =~ /Boot image name is \'(.*)\'/msi )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Cisco' );
	my $isSwitch = 0;
	if ( $in->{version} =~ /^(WS\-\S+)\s+/mi )
	{
		$out->print_element( 'core:name', $1 );
		$isSwitch = 1;
	}
	if ( $in->{version} =~ /\bSoftware(?:\,)?\s+Version\s+\S+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	elsif ( $in->{version} =~ /\bVersion (?:\S+):? (\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'CatOS' );
	$out->close_element('core:osInfo');

	if ( ( $in->{version} =~ /^System\s+Bootstrap\s+Version:?\s+([^\s,]+)/mi ) )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{config} =~ /^set\s+system\s+contact\s+(\S+)/mi;
	$out->print_element( 'core:contact', $contact );

	# Uptime is 59 days, 6 hours, 52 minutes
	if ( $in->{version} =~ /uptime is\s+(.+)/i )
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

	my $config;
	$config->{"core:name"}       = "config";
	$config->{"core:textBlob"}   = encode_base64( clean_show_output( $in->{"config"} ) );
	$config->{"core:mediaType"}  = "text/plain";
	$config->{"core:context"}    = "N/A";
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

	# local accounts - local usernames
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");

	while ( ( $in->{config} =~ /^set\s+localuser\s+user\s+([^\s]+)(?:\s+password\s+([^\s]+))?(?:\s+privilege\s+(\d+))?/mig ) )
	{
		my $username  = $1;
		my $password  = $2;
		my $privilege = $3;
		$privilege = defined($privilege) ? $privilege : 0;
		my $account = {
			accountName => $username,
			accessLevel => $privilege,
			password    => $password
		};
		$out->print_element( "localAccount", $account );
	}
	if ( $in->{config} =~ /^set\s+(password)\s+(\S+)/mig )
	{
		my $privilege = 0;
		my $password  = $2;
		my $account   = {
			accountName => $1,
			accessLevel => $privilege,
			password    => $password
		};
		$out->print_element( "localAccount", $account );
	}
	if ( $in->{config} =~ /^set\s+(enablepass)\s+(\S+)/mig )
	{
		my $privilege = 15;
		my $password  = $2;
		my $account   = {
			accountName => $1,
			accessLevel => $privilege,
			password    => $password
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
	my $c = ( $in->{config} =~ /^!$^#snmp(.+)^!$/migs ) ? $1 : $in->{config};
	$out->open_element("snmp");

	my $community = {};
	my @trapHosts = ();
	while ( $c =~ /^set\s+snmp\s+(\S+)\s+(.+)$/mig )
	{
		my $snmpCommand = lc($1);
		my $snmpComArgs = $2;
		if ( $snmpCommand eq 'community' )
		{
			if ( defined $community->{communityString} )
			{
				$out->print_element( "community", $community );
				$community = {};
			}
			if ( $snmpComArgs =~ /^\s*(\S+)\s+(\S+)?/i )
			{
				my $accessType      = $1;
				my $communityString = $2;
				
				if ($communityString) # $communiityString may not be defined in some valid config scenarios
				{
					if ( $accessType =~ /write/ )
					{
						$accessType = 'RW';
					}
					else
					{
						$accessType = 'RO';
					}
					$community->{communityString} = $communityString;
					$community->{accessType}      = $accessType;
				}
			}
			else
			{
				die('Invalid snmp set');
			}
		}
		elsif ( $snmpCommand eq 'view' )
		{
			if ( $snmpComArgs =~ /^\s*(\S+\s+)?(\S+)/i )
			{
				$community->{mibView} = $2;
			}
		}
		elsif ( $snmpCommand eq 'trap' )
		{
			if ( $snmpComArgs =~ /^\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)/i )
			{
				push( @trapHosts, { ipAddress => $1, communityString => $2 } );
			}
		}
	}
	if ( defined $community->{communityString} )
	{
		$out->print_element( "community", $community );
		$community = {};
	}

	my $someSysPrinted = 0;
	if ( $in->{config} =~ /^set\s+system\s+contact(.+)$/mi )
	{
		$_ = trim ( $1 );
		if ( $_ !~ /^$/ )
		{
			$out->print_element( "sysContact", $_ );
			$someSysPrinted = 1;
		}
	}
	if ( $in->{config} =~ /^set\s+system\s+location(.+)$/mi )
	{
		$_ = trim ( $1 );
		if ( $_ !~ /^$/ )
		{
			$out->print_element( "sysLocation", $_ );
			$someSysPrinted = 1;
		}
	}
	( $_ )	= $in->{config} =~ /^set\s+system\s+name(.+)$/mi;
	$_		= trim ( $1 );
	$_		= 'Console' if ( /^\s*$/ );
	$out->print_element( "sysName", $_ );
	$someSysPrinted = 1;

	if ($someSysPrinted)
	{
		foreach my $trapHost (@trapHosts)
		{
			$out->print_element( "trapHosts", $trapHost );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;
	my @static_routes_pieces = create_array_from_output( $in->{static_routes} );

	#my $primaryGateway;
	#if ($static_routes_pieces[1] =~ /\bprimary\s+gateway:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/)
	#{
	#	$primaryGateway = $1;
	#}

	while ( $static_routes_pieces[1] =~
		/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+0x([a-f0-9]{8}|0)\s+(\S+)\s+(\d+)\s+(\S+)/mig )
	{

		#set ip route destination[/netmask] gateway metric
		my $route = {
			destinationAddress => $1,
			destinationMask    => mask_to_bits ( conv_address_hex_dec($3) ),
			gatewayAddress     => $2,
			interface          => $6
		};
		if ( !defined $route->{destinationMask} )
		{
			$route->{destinationMask} = '32';
		}

		if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0.0.0.0' ) )
		{
			$route->{defaultGateway} = 'true';
		}
		else
		{
			$route->{defaultGateway} = 'false';
		}
		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;

	my $interface = {};
	my $order     = 1;
	$out->open_element("interfaces");

	# first parse interfaces from show interface output
	while ( $in->{interfaces} =~ /^(.+)$/mig )
	{
		my $iline = $1;
		if ( $iline =~ /^([^:]+):\s+(flags.+)$/i )
		{
			if ( defined $interface->{name} )
			{
				$out->print_element( "interface", $interface );
				$interface = {};
			}
			$order = 1;
			my $name = $1;
			my $blob = $2;
			$interface =
			{
				name          => $name,
				interfaceType => get_interface_type($name),
				physical      => _is_physical($name),
			};
			if ( $blob =~ /flags=(\d+)<(UP|DOWN)\,/i )
			{
				$interface->{adminStatus} = ( defined $2 ) ? lc($2) : 'up';
			}
			if ( $in->{ifalias} =~ /^(\d+)\s+$name/mi )
			{
				$interface->{ifIndex} = $1;
			}
		}
		elsif ( $iline =~
/^\s*(\S+)(\s+\d+)?(\s+inet)?\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(netmask|dest)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(\s+broadcast\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?/i
		  )
		{
			my $description = $1;
			$interface->{description} = $1;
			my $ipAddressExists = $3;
			my $ip1             = $4;
			my $ipMaskExists    = $5;
			my $mask            = mask_to_bits($6);
			my $broadcast       = $7;
			$order++;

			if ( defined $ipAddressExists )
			{
				if ( $ipAddressExists =~ /\s*inet/i )
				{
					if ( $ipMaskExists !~ /netmask/i )
					{
						$mask = '32';
					}
					if ( $broadcast =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ )
					{
						my $broadcastip = $1;
						push(
							@{ $interface->{"interfaceIp"}->{"ipConfiguration"} },
							{ broadcast => $broadcastip, ipAddress => $ip1, mask => $mask, precedence => $order }
						);
					}
					else
					{
						push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, { ipAddress => $ip1, mask => $mask, precedence => $order } );
					}
				}
			}
			else
			{
				push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, { ipAddress => $ip1, mask => '32', precedence => $order } )
				  if ( $ip1 ne '0.0.0.0' );
			}
		}
	}
	if ( defined $interface->{name} )
	{
		$out->print_element( "interface", $interface );
		$interface = {};
	}

	# then parse interfaces from show port output
	if ( defined $in->{ports} )
	{
		my @ports_pieces = create_array_from_output( $in->{ports} );
		my @cl0          = get_column_lengths( $ports_pieces[0] );
		my $line_regex   = "";
		if ( $ports_pieces[0] =~ /\bVlan\s+Level/mi )
		{
			$line_regex = '^(.{'
			  . $cl0[0]
			  . '}) (.{'
			  . $cl0[1]
			  . '}) (.{'
			  . $cl0[2]
			  . '}) (.{'
			  . $cl0[3]
			  . '}) (?:.{'
			  . $cl0[4]
			  . '}) (.{'
			  . $cl0[5]
			  . '}) (.{'
			  . $cl0[6]
			  . '}) (.+)$';
			$ports_pieces[0] =~ s/^\s*Port\s+Name\s+Status\s+Vlan\s+Level\s+Duplex\s+Speed\s+Type\s*$//mi;
		}
		else
		{
			$line_regex =
			  '^(.{' . $cl0[0] . '}) (.{' . $cl0[1] . '}) (.{' . $cl0[2] . '}) (.{' . $cl0[3] . '}) (.{' . $cl0[4] . '}) (.{' . $cl0[5] . '}) (.+)$';
			$ports_pieces[0] =~ s/^\s*Port\s+Name\s+Status\s+Vlan\s+Duplex\s+Speed\s+Type\s*$//mi;
		}
		$ports_pieces[0] =~ s/^[\s-]+$//mi;
		$ports_pieces[0] =~ s/^\s+^(\s*\d+)/$1/m;
		while ( $ports_pieces[0] =~ /$line_regex/mig )
		{
			my $port   = $1;
			my $name   = $2;
			my $status = $3;
			my $vlan   = $4;
			my $duplex = $5;
			my $speed  = $6;
			my $type   = $7;
			$port   =~ s/^\s+//;
			$port   =~ s/\s+$//;
			$name   =~ s/^\s+//;
			$name   =~ s/\s+$//;
			$status =~ s/^\s+//;
			$status =~ s/\s+$//;
			$vlan   =~ s/^\s+//;
			$vlan   =~ s/\s+$//;
			$duplex =~ s/^\s+//;
			$duplex =~ s/\s+$//;
			$speed  =~ s/^\s+//;
			$speed  =~ s/\s+$//;
			$type   =~ s/^\s+//;
			$type   =~ s/\s+$//;
			$interface =
			{
				adminStatus => ( lc($status) eq 'connected' ? 'up' : 'down' ),
				name => $port,
				interfaceType => get_interface_type($port),
				physical      => _is_physical($port),
			};

			if ( $name !~ /^\s*$/ )
			{
				$interface->{description} = $name;
			}
			if ( $speed =~ /^a-\S+/i )
			{
				$interface->{interfaceEthernet}->{autoSpeed} = 'true';
			}
			elsif ( $speed =~ /^\d+$/i )
			{
				$interface->{speed} = $speed;
			}
			if ( $in->{ifalias} =~ /^(\d+)\s+$port/mi )
			{
				$interface->{ifIndex} = $1;
			}
			elsif ( $in->{ifalias} =~ /^\s*$port\s+(\d+)/mi )
			{
				$interface->{ifIndex} = $1;
			}
			if (   $duplex =~ /^auto/i
				|| $duplex =~ /^a-\S+/i )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = 'true';
			}
			else
			{
				$interface->{interfaceEthernet}->{autoDuplex} = 'false';
				if ( $duplex =~ /^half/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = 'half';
				}
				elsif ( $duplex =~ /^full/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = 'full';
				}
			}
			$interface->{interfaceEthernet}->{mediaType} = $type;
			if ( $vlan =~ /^\d+$/ )
			{
				push @{ $interface->{interfaceVlanTrunks} }, { startVlan => $vlan };
			}
			if ( $in->{stp} =~ /^\s*$port\s+$vlan\s+(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s+\S.+$/mi )
			{
				$interface->{interfaceSpanningTree}->{cost}     = $2;
				$interface->{interfaceSpanningTree}->{priority} = $3;
				$_                                              = $1;
				if (/forw/i)
				{
					$interface->{interfaceSpanningTree}->{state} = 'forwarding';
				}
				elsif (/not-conn/i)
				{
					$interface->{interfaceSpanningTree}->{state} = 'disabled';
				}
				elsif (/learn/i)
				{
					$interface->{interfaceSpanningTree}->{state} = 'learning';
				}
				elsif (/list/i)
				{
					$interface->{interfaceSpanningTree}->{state} = 'listening';
				}
				elsif (/block/i)
				{
					$interface->{interfaceSpanningTree}->{state} = 'blocking';
				}
			}
			if ( $in->{interfaces} =~ /^\s*vlan\s+$vlan\s+inet\s+(\S+)\s+netmask\s+(\S+)/mi )
			{
				push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, { ipAddress => $1, mask => mask_to_bits ( $2 ), precedence => 1 } );
			}
			$out->print_element( "interface", $interface );
		}
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	my @vlans_pieces = create_array_from_output( $in->{vlans} );

	my @vlans    = ();
	my $anyVLAN  = 0;
	my $thisVlan = {};

	my @cl0 = get_column_lengths( $vlans_pieces[0] );

	#my @cl1 = get_column_lengths($vlans_pieces[1]);
	#my @cl3 = get_column_lengths($vlans_pieces[3]);
	foreach my $vlline ( split( /\n/, $vlans_pieces[0] ) )
	{
		if ( $vlline =~ /^(\d{1,$cl0[0]})\s+(\S.{1,$cl0[1]})\s+(\S.{1,$cl0[2]})\s+(\d{1,$cl0[3]})\s+([\d\/\-]{0,$cl0[4]})/i )
		{
			$anyVLAN = 1;
			my $number    = $1;
			my $name      = $2;
			my $status    = $3;
			my $ifindex   = $4;
			my $portspart = $5;
			$name =~ s/\s+$//;
			if ( $thisVlan->{number} )
			{
				push( @vlans, $thisVlan );
				$thisVlan = {};
			}
			$thisVlan = {
				number  => $number,
				name    => $name,
				enabled => ( $status =~ /^act/i ? "true" : "false" )
			};
			if ( $portspart =~ /^(\d+)\/(\d+)\-(\d+)$/ )
			{
				for ( $2 .. $3 )
				{

					push( @{ $thisVlan->{interfaceMember} }, $1 . "/" . $_ );
				}
			}
			elsif ( $portspart =~ /^(\d+)$/ )
			{
				push( @{ $thisVlan->{interfaceMember} }, $portspart );
			}
			$thisVlan->{configSource} = ( $name =~ /^defa/i ) ? 'default' : 'learned';
			if ( $vlans_pieces[1] =~ /^$number\s+(\S+)\s+(\d+)\s+(\d+)\s+([\d\-]+)\s+([a-f0-9x\-]+)\s+([a-f0-9x\-]+)\s+(\S+)\s+(\S+)\s+(.+)$/mig )
			{
				my $type     = $1;
				my $said     = $2;
				my $mtu      = $3;
				my $parent   = $4;
				my $ringno   = $5;
				my $brdgno   = $6;
				my $stp      = $7;
				my $brdgmode = $8;
				my $endtext  = $9;
				my $trans1   = 0;
				my $trans2   = 0;
				$brdgno =~ s/\s+$//;

				if ( $endtext =~ /(\d+)\s+(\d+)/ )
				{
					$trans1 = $1;
					$trans2 = $2;
				}
				$thisVlan->{bridgeMode}         = $brdgmode    unless ( $brdgmode eq "-" );
				$thisVlan->{bridgeNumber}       = hex($brdgno) unless ( $brdgno   eq "-" );
				$thisVlan->{implementationType} = $type        unless ( $type     eq "-" );
				$thisVlan->{mtu}                = $mtu         unless ( $mtu      eq "-" );
				$thisVlan->{parent}             = $parent      unless ( $parent   eq "-" );
				$thisVlan->{ringNumber}         = hex($ringno) unless ( $ringno   eq "-" );
				$thisVlan->{said}               = $said        unless ( $said     eq "-" );
				$thisVlan->{translationBridge1} = $trans1      unless ( $trans1   eq "-" );
				$thisVlan->{translationBridge2} = $trans2      unless ( $trans2   eq "-" );
			}

			# next fix -> implement @cl3
			if ( $vlans_pieces[3] =~ /^$number\s+(\d+)\s+(\d+)\s+(\S+)\s+.+$/mig )
			{
				my $arehops   = $1;
				my $stehops   = $2;
				my $backupcrf = $3;
				$thisVlan->{areHops}          = $arehops;
				$thisVlan->{backupCRFEnabled} = ( lc($backupcrf) eq 'off' ? 'false' : 'true' );
				$thisVlan->{steHops}          = $stehops;
			}
		}
		elsif ( $vlline =~ /^\s+(\d+)(\/\S+)?\s*$/i )
		{
			my $portspart = $1;
			$portspart .= $2 if defined $2;
			if ( $portspart =~ /^(\d+)\/(\d+)\-(\d+)/ )
			{
				for ( $2 .. $3 )
				{
					push( @{ $thisVlan->{interfaceMember} }, $1 . "/" . $_ );
				}
			}
			elsif ( $portspart =~ /^(\d+)$/ )
			{
				push( @{ $thisVlan->{interfaceMember} }, $portspart );
			}
		}
	}
	if ( $thisVlan->{number} )
	{
		push( @vlans, $thisVlan );
		$thisVlan = {};
	}

	if ($anyVLAN)
	{
		$out->open_element("vlans");

		foreach my $vlan (@vlans)
		{
			$out->print_element( "vlan", $vlan );
		}

		$out->close_element("vlans");
	}
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;

	# instances from "show spantree"
	while ( $in->{stp} =~ /^(VLAN)\s+(\d+)(.+?)^-+/msig )
	{
		my $blob           = $3;
		my $instance       = { vlan => $2, };
		my @thisTreePieces = create_array_from_output($3);
		if ( $thisTreePieces[0] !~ /^Designed/mi )
		{
			shift(@thisTreePieces);
		}

		# root section
		if ( $thisTreePieces[0] =~ /^Designated\s+Root\s+Priority\s+(\d+)/mi )
		{
			$instance->{designatedRootPriority} = $1;
		}
		if ( $thisTreePieces[0] =~ /^Designated\s+Root\s+([\da-f\-\.]{17})/mi )
		{
			$instance->{designatedRootMacAddress} = strip_mac($1);
		}
		if ( $thisTreePieces[0] =~ /^Designated\s+Root\s+Cost\s+(\d+)/mi )
		{
			$instance->{designatedRootCost} = $1;
		}
		if ( $thisTreePieces[0] =~ /^Designated\s+Root\s+Port\s+(\S+)/mi )
		{
			$instance->{designatedRootPort} = $1;
		}
		if ( $thisTreePieces[0] =~ /^Root\s+Max\s+Age\s+(\d+)\s+sec\s+Hello\s+Time\s+(\d+)\s+sec\s+Forward\s+Delay\s+(\d+)\s+sec/mi )
		{
			$instance->{designatedRootHelloTime}    = $2;
			$instance->{designatedRootMaxAge}       = $1;
			$instance->{designatedRootForwardDelay} = $3;
		}

		# bridge section
		if ( $thisTreePieces[1] =~ /Bridge\s+ID\s+Priority\s+(\d+)/mi )
		{
			$instance->{priority} = $1;
		}
		if ( $thisTreePieces[1] =~ /Bridge\s+ID\s+MAC\s+ADDR\s+([\da-f\-\.]{17})/mi )
		{
			$instance->{systemMacAddress} = strip_mac($1);
		}
		if ( $thisTreePieces[1] =~ /^Bridge\s+Max\s+Age\s+(\d+)\s+sec\s+Hello\s+Time\s+(\d+)\s+sec\s+Forward\s+Delay\s+(\d+)\s+sec/mi )
		{
			$instance->{helloTime}    = $2;
			$instance->{maxAge}       = $1;
			$instance->{forwardDelay} = $3;
		}
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

sub parse_services
{
	my ( $input, $output ) = @_;

	$output->open_element("services");

		parse_ntp( $input, $output);

		#other service parsers go here

	$output->close_element("services");
}

sub parse_ntp
{
	my ( $in, $out ) = @_;

	my $ntp;

	my $cfg = $in->{config};

	if ( $cfg =~ /^set\s+ntp/mi)
	{
		#CatOS has no specific NTP enable command - search for 'set ntp server' to see if it is active
		$ntp->{enabled} = ($cfg =~ /^(?:set\s+ntp\s+server\s+\d+\.\d+\.\d+\.\d+)/mi) ? "true" : "false";

		while ( $cfg =~ /^set\s+ntp\s+key\s+(\d+)\s+(trusted|untrusted)\s+md5-encrypted\s+(\S+)\s*$/mig )
		{
			#set ntp key 505 trusted md5-encrypted 060c0e2c495d
			#set ntp key 506 untrusted md5-encrypted 110b0b10191c0e1e

			my $key;

			$key->{keyNumber} = $1;
			my $the_key = $3;
			my $trust = ($2 =~ /untrusted/mi) ? "false" : "true";

			$key->{keyType} = "MD5";
			$key->{serverKey} = $the_key;
			$key->{trusted} = $trust;

			push ( @{ $ntp->{"localKeySettings"} }, $key);
		}

		while ( $cfg =~ /^set\s+ntp\s+server\s+(\d+\.\d+\.\d+\.\d+)(?:$|\s*(.*)$)/mig )
		{
			#ntp server (1.2.3.4) (key <number>)

			my $server;

			my $server_ip = $1;
			my $rest = $2;

			$server->{mode} = "server";

			$server->{serverIPaddress} = $server_ip;

			$server->{protocolVersion}->{protocol} = "ntp";
			$server->{protocolVersion}->{version} = "1"; #need to check catos default ntp version.

			if ( $rest =~ /key\s+(\d+)/mi )
			{
				$server->{keyNumber} = $1;
			}

			push ( @{ $ntp->{"server"} }, $server);
		}

		$ntp->{useAuthentication} = ($cfg =~ /^set\s+ntp\s+authentication\s+enable/mi) ? "true" : "false";
	}

	$out->print_element( "ntp", $ntp ) if ($ntp);
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

sub get_column_lengths
{
	my $table = shift;
	my @column_lengths;
	if ( $table =~ /^(\-[\s\-]+)$/mi )
	{
		foreach ( split( /\s+/, $1 ) )
		{
			push( @column_lengths, length );
		}
	}

	return @column_lengths;
}

sub conv_address_hex_dec
{
	my $hex_address = shift;
	if ( $hex_address =~ /^(0x)?([a-f0-9]{8})$/i )
	{
		return hex( substr( $2, 0, 2 ) ) . "." . hex( substr( $2, 2, 2 ) ) . "." . hex( substr( $2, 4, 2 ) ) . "." . hex( substr( $2, 6, 2 ) );
	}
	elsif ( $hex_address =~ /^0x0$/ )
	{
		return '0.0.0.0';
	}
	else
	{
		return 0;
	}
}

sub clean_show_output
{
	$_ = shift;
	s/^show\s+\S{1}.+$//mi;
	s/^\s+//mi;
	s/^\S+\>\s+\(enable\)//mi;
	s/^\#time: $//mi;
	$_;
}

sub create_array_from_output
{
	$_ = shift;
	my @clean_outputs = split( /^\s*$/mi, clean_show_output($_) );
	for ( my $x = 0 ; $x <= scalar(@clean_outputs) ; $x++ )
	{
		if ( defined $clean_outputs[$x] )
		{
			if ( $clean_outputs[$x] =~ /^\s+$/mi )
			{
				delete $clean_outputs[$x];
			}
		}
		else
		{
			delete $clean_outputs[$x];
		}
	}

	@clean_outputs;
}

sub _full_int_name
{

	# given a short name like "Fa3/15" return "FastEthernet3/15"
	my $name = trim(shift);
	for ($name)
	{
		s/^Fa(?=\d)/FastEthernet/;
		s/^Eth(?=\d)/Ethernet/;
		s/^Gig?(?=\d)/GigabitEthernet/;
	}
	return $name;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Cisco::CatOS::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Cisco::CatOS::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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

