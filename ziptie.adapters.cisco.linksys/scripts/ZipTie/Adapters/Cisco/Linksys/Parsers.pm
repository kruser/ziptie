package ZipTie::Adapters::Cisco::Linksys::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac get_mask get_port_number trim get_interface_type getUnitFreeNumber get_crep strip_mac);
use XML::Twig;
use Switch;
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(parse_filters parse_snmp parse_system parse_chassis create_config parse_interfaces);

our $services;

sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element("chassis");

	my $chassisAsset;
	$chassisAsset = {
		"core:assetType"   => "Chassis",
	};
	$chassisAsset->{"core:factoryinfo"}->{"core:make"} = "Linksys";
	if ( $in->{home} =~ /the serial number of the\s+(\S+)\s+unit/i )
	{
		$chassisAsset->{"core:factoryinfo"}->{"core:modelNumber"} = $1;
	}
	if ( $in->{home} =~ /<td.+?>Serial Number\s*:(.+?)<\/td>/si )
	{
		my $blob = $1;
		if ( $blob =~ /^\s*([A-Z]\S+)\b\s*$/mi )
		{
			$chassisAsset->{"core:factoryinfo"}->{"core:serialNumber"} = $1;
		}
	}
	$out->print_element( "core:asset", $chassisAsset );

	$out->print_element( "core:description", "Linksys VPN Router" );

	if ( $in->{home} =~ /processor.\s+It is\s+(\S+)\s+(\S+)\b/i )
	{
		my $factoryInfo = {
			"core:make"        => $1,
			"core:modelNumber" => $2,
		};
		my $asset = {
			"core:assetType"   => "CPU",
			"core:factoryinfo" => $factoryInfo,
		};
		$out->print_element( "cpu", { "core:asset" => $asset, } );
	}

	if ( $in->{home} =~ /<td.+?>DRAM\s*:(.+?)<\/td>/si )
	{
		my $blob = $1;
		if ( $blob =~ /(\d+)M/ )
		{
			my $memory = {
				"core:description" => "DRAM",
				kind               => "RAM",
				size               => $1 * 1024 * 1024,
			};
			$out->print_element( "memory", $memory );
		}
	}
	if ( $in->{home} =~ /<td.+?>Flash\s*:(.+?)<\/td>/si )
	{
		my $blob = $1;
		if ( $blob =~ /(\d+)M/ )
		{
			my $flash = {
				"core:description" => "Flash",
				kind               => "Flash",
				size               => $1 * 1024 * 1024,
			};
			$out->print_element( "memory", $flash );
		}
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;
	if ( $in->{snmp} =~ /<input type.+snmp_Mib2SysName.+value=\\?'(\b\S+\b)/i )
	{
		$out->print_element( "core:systemName", $1 );
	}

	# This appears at the header of each page
	if ( $in->{home} =~ /firmware version\s*:\s*((?:\d+\.?){1,4})/i )
	{
		$out->open_element('core:osInfo');
		$out->print_element( 'core:make',    'Cisco' );
		$out->print_element( 'core:version', $1 );
		$out->print_element( 'core:osType',  'Linksys' );
		$out->close_element('core:osInfo');
	}

	$out->print_element( "core:deviceType", "Router" );
	if ( $in->{snmp} =~ /<input type.+snmp_Mib2SysContact.+value=\\?'(\b.+?\b)\\?'/i )
	{
		$out->print_element( "core:contact", $1 );
	}

	if ( $in->{home} =~ /<td.+?>System up time\s*:(.+?)<\/td>/msi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s+years?/i;
		my ($weeks)   = /(\d+)\s+weeks?/i;
		my ($days)    = /(\d+)\s+days?/i;
		my ($hours)   = /(\d+)\s+hours?/i;
		my ($minutes) = /(\d+)\s+minutes?/i;
		my ($seconds) = /(\d+)\s+seconds?/i;

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
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "RV042.exp";
	$running->{"core:textBlob"}   = encode_base64( $in->{config} );
	$running->{"core:mediaType"}  = "application/octet-stream";
	$running->{"core:context"}    = "N/A";
	$running->{'core:promotable'} = 'false';                          

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;

	$out->open_element("interfaces");
	my ($mac, $lanIp, $lanMask, $wan1Ip, $wan1Mask, $wan2Ip, $wan2Mask);
	$_		= get_crep('mac2');
	$mac	= strip_mac( $1 ) if ( $in->{network} =~ /MAC\s+Address:\s+($_)/mis );
	$lanIp = $1 if ( $in->{network} =~ /name=["']ipAddr1["']\s+value=["'](\d+)["']/mi );
	$lanIp .= ".$1" if ( $in->{network} =~ /name=["']ipAddr2["']\s+value=["'](\d+)["']/mi );
	$lanIp .= ".$1" if ( $in->{network} =~ /name=["']ipAddr3["']\s+value=["'](\d+)["']/mi );
	$lanIp .= ".$1" if ( $in->{network} =~ /name=["']ipAddr4["']\s+value=["'](\d+)["']/mi );
	$_		= get_crep('cipm');
	if ( $in->{network} =~ /<select name="netMask" size="1">(.+?)<\/select/mis )
	{
		if ( $1 =~ /<option\s+value="\d+"\s+selected>($_)/mis )
		{
			$lanMask = $1;
		}
	}

	$wan1Ip = $1 if ( $in->{network} =~ /name=["']Wan1AliasIp1["']\s+value=["'](\d+)["']/mi );
	$wan1Ip .= ".$1" if ( $in->{network} =~ /name=["']Wan1AliasIp2["']\s+value=["'](\d+)["']/mi );
	$wan1Ip .= ".$1" if ( $in->{network} =~ /name=["']Wan1AliasIp3["']\s+value=["'](\d+)["']/mi );
	$wan1Ip .= ".$1" if ( $in->{network} =~ /name=["']Wan1AliasIp4["']\s+value=["'](\d+)["']/mi );
	$wan1Mask = $1 if ( $in->{network} =~ /name=["']Wan1AliasMaskIp1["']\s+value=["'](\d+)["']/mi );
	$wan1Mask .= ".$1" if ( $in->{network} =~ /name=["']Wan1AliasMaskIp2["']\s+value=["'](\d+)["']/mi );
	$wan1Mask .= ".$1" if ( $in->{network} =~ /name=["']Wan1AliasMaskIp3["']\s+value=["'](\d+)["']/mi );
	$wan1Mask .= ".$1" if ( $in->{network} =~ /name=["']Wan1AliasMaskIp4["']\s+value=["'](\d+)["']/mi );

	$wan2Ip = $1 if ( $in->{network} =~ /name=["']Wan2AliasIp1["']\s+value=["'](\d+)["']/mi );
	$wan2Ip .= ".$1" if ( $in->{network} =~ /name=["']Wan2AliasIp2["']\s+value=["'](\d+)["']/mi );
	$wan2Ip .= ".$1" if ( $in->{network} =~ /name=["']Wan2AliasIp3["']\s+value=["'](\d+)["']/mi );
	$wan2Ip .= ".$1" if ( $in->{network} =~ /name=["']Wan2AliasIp4["']\s+value=["'](\d+)["']/mi );
	$wan2Mask = $1 if ( $in->{network} =~ /name=["']Wan2AliasMaskIp1["']\s+value=["'](\d+)["']/mi );
	$wan2Mask .= ".$1" if ( $in->{network} =~ /name=["']Wan2AliasMaskIp2["']\s+value=["'](\d+)["']/mi );
	$wan2Mask .= ".$1" if ( $in->{network} =~ /name=["']Wan2AliasMaskIp3["']\s+value=["'](\d+)["']/mi );
	$wan2Mask .= ".$1" if ( $in->{network} =~ /name=["']Wan2AliasMaskIp4["']\s+value=["'](\d+)["']/mi );

	while ( (my $key, my $value) = each(%{$in}) )
	{
		if ( $key =~ /^port_(\S+)$/i )
		{
			$_ = $value;
			my $interface	= 
			{
				name			=> $1,
				interfaceType	=> 'ethernet',
				physical		=> 'true',
			};
			if ( /document.write\("(WAN(?:1|2)?)"\)/mi )
			{
				$interface->{description} = trim ( $1 );
			}
			elsif ( /Interface(?:<[^>]+>(?:\s*<[^>]+>)*)\s*(?:&nbsp;)?\s*(\S[^<]+)/mi )
			{
				$interface->{description} = trim ( $1 );
			}
			if ( $interface->{description} =~ /LAN/i && $lanIp )
			{
				push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $lanIp, mask => $lanMask };
			}
			elsif ( $interface->{description} =~ /WAN1?$/i && $wan1Ip )
			{
				push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $wan1Ip, mask => $wan1Mask };
			}
			elsif ( $interface->{description} =~ /WAN2$/i && $wan2Ip )
			{
				push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $wan2Ip, mask => $wan2Mask };
			}
			if ( /Link\s+Status(?:<[^>]+>(?:\s*<[^>]+>)*)\s*(?:&nbsp;)?\s*(Down|Up)/mi )
			{
				$interface->{adminStatus} = lc ( $1 );
			}
			if ( /Speed\s+Status(?:<[^>]+>(?:\s*<[^>]+>)*)+\s*(?:&nbsp;)?\s*(\d+)\s+(\S)\S+/mi )
			{
				$interface->{speed} = getUnitFreeNumber($1, $2 , 'bit');
			}
			if ( /Duplex\s+Status(?:<[^>]+>(?:\s*<[^>]+>)*)\s*(?:&nbsp;)?\s*(\S+)/mi )
			{
				if ( lc ($1) eq 'auto' )
				{
					$interface->{interfaceEthernet}->{autoDuplex } = 'true';
				}
				else
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = lc ( $1 );
				}
			}
			if ( /Type(?:<[^>]+>(?:\s*<[^>]+>)*)\s*(?:&nbsp;)?\s*(\S[^<]+)/mi )
			{
				$interface->{interfaceEthernet}->{mediaType} = trim ( $1 );
			}
			$interface->{interfaceEthernet}->{macAddress} = $mac if ( $mac );
			$out->print_element( "interface", $interface );
		}
	}

	$out->close_element("interfaces");
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = {};
	if ( $in->{snmp} =~ /<input type.+snmp_Mib2SysName.+value=\\?'(\b\S+\b)/i )
	{
		$snmp->{sysName} = $1;
	}
	if ( $in->{snmp} =~ /<input type.+snmp_Mib2SysContact.+value=\\?'(.+?)\\?'/i )
	{
		$snmp->{sysContact} = $1;
	}
	if ( $in->{snmp} =~ /<input type.+snmp_Mib2SysLocation.+value=\\?'(.+?)\\?'/i )
	{
		$snmp->{sysLocation} = $1;
	}
	if ( $in->{snmp} =~ /<input type.+snmp_GetCommunity.+value=\\?'(\b\S+\b)/i )
	{
		my $community = {
			communityString => $1,
			accessType      => "RO",
		};
		push( @{ $snmp->{community} }, $community );
	}
	if ( $in->{snmp} =~ /<input type.+snmp_SetCommunity.+value=\\?'(\b\S+\b)/i )
	{
		my $community = {
			communityString => $1,
			accessType      => "RW",
		};
		push( @{ $snmp->{community} }, $community );
	}
	my $trapHost;
	if ( $in->{snmp} =~ /<input type.+snmp_SendTrap.+value=\\?'(.+?)\\?'/i )
	{
		$trapHost->{ipAddress} = $1;
	}
	if ( defined $trapHost && $in->{snmp} =~ /<input type.+snmp_TrapCommunity.+value=\\?'(\b\S+\b)\\?'/i )
	{
		$trapHost->{communityString} = $1;
	}
	$snmp->{trapHosts} = $trapHost if ( defined $trapHost );
	$out->print_element( "snmp", $snmp );
}

sub parse_filters
{
	my ( $in, $out ) = @_;

	# first process the service definitions to get the port and protocol information
	while ( $in->{services} =~ />(\b[^>]+?\b)\s*\[(UDP|TCP)\/(\d+)~(\d+)/ig )
	{
		$services->{$1} = {
			protocol  => $2,
			portStart => $3,
			portEnd   => $4,
		};
	}

	# find the right table of the filters
	my $filterTable;
	while ( $in->{filters} =~ /(<table.+?<\/table>)/sig )
	{
		my $table = $1;
		if ( $table =~ /Priority/i && $table =~ /Enable/i && $table =~ /Action/i )
		{
			$filterTable = $table;
		}
	}

	# process each table row <tr>
	if ($filterTable)
	{
		$out->open_element("filterLists");
		$out->open_element("filterList");

		my $row = 0;
		while ( $filterTable =~ /(<tr\s.+?<\/tr>)/sig )
		{
			_process_filter( $1, $out ) if ( $row > 0 );    # skip the header
			$row++;
		}

		$out->print_element( "mode", "stateful" );
		$out->print_element( "name", "main" );
		$out->close_element("filterList");
		$out->close_element("filterLists");
	}
}

sub _process_filter
{
	my ( $filter, $out ) = @_;
	my $column = 0;
	my $filterEntry = { log => "false", };
	while ( $filter =~ /<td.*?>(.*?)<\/td>/sig )
	{
		my $content = $1;
		switch ($column)
		{
			case [0]
			{
				if ( $content =~ /<option selected>(\d+)/i ) { $filterEntry->{processOrder} = $1; }
			};
			case [2]
			{
				if    ( $content =~ /Allow/i ) { $filterEntry->{primaryAction} = "permit"; }
				elsif ( $content =~ /Deny/i )  { $filterEntry->{primaryAction} = "deny"; }
			};
			case [3]
			{
				if ( $content !~ /all traffic/i )
				{
					$filterEntry->{sourceService}->{portRange} = _resolve_service($content);
				}
			};
			case [4] { $filterEntry->{name}              = trim($content); };
			case [5] { $filterEntry->{sourceIpAddr}      = _parse_filter_ip($content); };
			case [6] { $filterEntry->{destinationIpAddr} = _parse_filter_ip($content); };
			case [7]
			{
				if ( $content !~ /Always/i ) { ( $filterEntry->{timeAllowed}->{startTime}, $filterEntry->{timeAllowed}->{endTime} ) = _get_time($content); }
			};
			case [8]
			{
				if ( $content =~ /All/i )
				{
					$filterEntry->{timeAllowed}->{days} = "All";
				}
				elsif ( $content =~ /\S+/ )
				{
					foreach my $day ( split( /,/, $content ) )
					{
						$day = trim($day);
						push( @{ $filterEntry->{timeAllowed}->{days} }, $day ) if $day;
					}
				}
			};
		}
		$column++;
	}
	$out->print_element( "filterEntry", $filterEntry );
}

sub _get_time
{

	#picks a real time from the firewall rules table
	my $content = shift;
	my ( $start, $end ) = split( /~/, $content );
	return ( _pad_time($start), _pad_time($end) );
}

sub _pad_time
{
	my $time = trim(shift);

	# given a time line 9:59, returns 09:59:00
	my ( $hour, $minute ) = split( /:/, $time );
	$hour   = "0" . $hour   if ( $hour < 10 );
	$minute = "0" . $minute if ( $minute < 10 );
	return $hour . ":" . $minute . ":00";
}

sub _parse_filter_ip
{

	# takes an address definition
	my $content = shift;
	if ( $content =~ /Any/i )
	{
		return { network => { address => '0.0.0.0', mask => '0' } };
	}
	elsif ( $content =~ /(\d+\.\d+\.\d+\.\d+)\s*~\s*(\d+\.\d+\.\d+\.\d+)/ )
	{
		return { range => {startAddress => $1, endAddress => $2 } };
	}
}

sub _resolve_service
{

	# takes in a service definition and gets the real protocol and port information
	my $content = shift;
	if ( $content =~ /(\b.+?\b)\s*\[/ )
	{
		return $services->{$1};
	}
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Cisco::Linksys::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Cisco::Linksys::Parsers;
	parse_chassis( $responses, $xmlPrinter );	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
Linksys HTML documents and print out ZipTie model elements.

=head2 Methods

=over 12

=item C<create_config>

Creates a ZipTie common configuration repository

=item C<parse_chassis>

Populate a chassis 

=item C<parse_snmp>

Parses out SNMP system attributes as well as community string information

=item C<parse_system>

Some top level attributes such as serial number, model number, etc.

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

=head1 AUTHOR

  Contributor(s): rkruse
  Date: May 21, 2007

=cut
