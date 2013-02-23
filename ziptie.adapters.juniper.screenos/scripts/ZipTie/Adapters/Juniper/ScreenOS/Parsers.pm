package ZipTie::Adapters::Juniper::ScreenOS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac parseCIDR);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_arp parse_telemetry_interfaces parse_mac_table parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Common ip/mask regular expression
our $CIPM_RE = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

# Classless InterDomain Routing address regular expression
our $CIDR_RE = '\d{1,3}(?:\.\d{1,3}){0,3}\/\d+';

# MAC addresses regular expressions
our $MAC_RE1 = '[0-9a-f]{12}';
our $MAC_RE2 = '[0-9a-f]{1,2}(?:[:\.][0-9a-f]{1,2}){5}';
our $MAC_RE3 = '[0-9a-f]{4}\.[0-9a-f]{4}\.[0-9a-f]{4}';

sub parse_arp
{
	my ( $in, $out ) = @_;
	$out->open_element('arpTable');
	while ( $in->{arp} =~ /^\s*([\da-f\.:\-]+)\s+([\da-f\.:]+)\s+(\S+)\s+\S+\s+\d+\s*/mig )
	{
		my $arp = {
			ipAddress  => $1,
			macAddress => strip_mac($2),
			interface  => $3
		};
		$out->print_element( 'arpEntry', $arp );
	}
	$out->close_element('arpTable');
}

sub parse_telemetry_interfaces
{
	my ( $in, $out ) = @_;
	my $interfaces;

	while ( $in->{interfaces} =~ /^\s*(\S+)\s+([\da-f\.\:]+)\/(\d+)\s+\S+\s+(?:[\da-f\.\:\-]+)\s+\S+\s+(\S+)\s+\S+\s*$/mig )
	{
		my $name		= $1;
		my $ipAddress	= $2;
		my $mask		= $3;
		my $status		= $4;
		my $interface = {
			name       => $name,
			type       => 'other',
			inputBytes => 0,
			operStatus => ( $status eq 'U' ? 'Up' : 'Down' ),
		};
		if ( $in->{"if_counter_$name"} =~ /in\s+bytes\s+(\d+)/mi )
		{
			$interface->{inputBytes} = $1;
		}
		my $ipEntry = {
			ipAddress => $ipAddress,
			mask      => mask_to_bits ( $mask ),
		};
		push( @{ $interface->{ipEntry} }, $ipEntry );
		push( @{ $interfaces->{interface} }, $interface );
	}
	$out->print_element( 'interfaces', $interfaces );

	return $interfaces;
}

sub parse_mac_table
{
	my ( $in, $out ) = @_;
	my $openedMacTable = 0;
	while ( $in->{mac} =~ /^\s*(\S+)\s+([\da-f\.:\-]+)\s+\S+\s+(\S+)\s*$/mig )
	{
		if (!$openedMacTable)
		{
			$out->open_element('macTable');
			$openedMacTable = 1;
		}
		my $macEntry = {
			vlan => $3,
			macAddress => strip_mac($2),	
			interface => _full_int_name($1),
		};
		$out->print_element('macEntry', $macEntry);
	}
	$out->close_element('macTable') if ($openedMacTable);
}

sub parse_chassis
{
	my ( $in, $out ) = @_;

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{'system'} =~ /^\s*Serial Number:\s+([^\,\s]+),/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
		$chassisAsset->{'core:factoryinfo'}->{'core:make'}         = "Juniper";
	}
	if ( $in->{'system'} =~ /^\s*Hardware\s+Version:\s+([^\,\s]+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:partNumber'} = $1;
	}
	if ( $in->{'system'} =~ /^Product Name:\s*(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{'system'} =~ /File\s*Name:\s*\/?(\S+?)\./mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	$out->open_element("chassis");
	$out->print_element( "core:asset", $chassisAsset );

	_parse_file_storage( $in, $out );

	$out->close_element("chassis");
}

sub _parse_file_storage
{
	my ( $in, $out ) = @_;

	if ( $in->{file_info} =~ /^There\s+are\s+(\d+)\s+bytes\s+free\s+\((\d+)\s+total\)\s+on\s+disk\s+\"(\S+)\"/mi )
	{
		my $storage = {};
		$storage->{name}        = $3;
		$storage->{size}        = $2;
		$storage->{freeSpace}   = $1;
		$storage->{storageType} = 'flash' if ( $storage->{name} =~ /flash/i );
		$storage->{storageType} = 'disk' if ( $storage->{name} =~ /disk/i );
		$storage->{storageType} = 'NVRAM' if ( $storage->{name} =~ /nvram/i );
		$storage->{storageType} = 'other' if ( !defined $storage->{storageType} );
		$storage->{rootDir}     = { name => 'root', };
		while ( $in->{files} =~ /^\s*(\S+)\s+(\d+)\s*$/mig )
		{
			push( @{ $storage->{rootDir}->{file} }, { name => $1, size => $2 } );
		}
		$out->print_element( "deviceStorage", $storage );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{config} =~ /^set\s+hostname\s+(\S+)/mi;
	if ( !defined $systemName )
	{
		if ( $in->{snmp} =~ /^Sysname\s+:(\S+)/mi )
		{
			$systemName = $1;
		}
	}
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	if ( $in->{'system'} =~ /^File\s+Name:\s+([^\s\,]+)/mi )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Juniper' );
	if ( $in->{'system'} =~ /^Product\s+Name:\s+(\S+)/mi )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{'system'} =~ /^Software\s+Version:\s+([^\s\,]+),\s+Type:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'ScreenOS' );
	$out->close_element('core:osInfo');

	if ( $in->{'system'} =~ /\bFirewall/mi )
	{
		$out->print_element( 'core:deviceType', 'Firewall' );
	}

	#$out->print_element( 'core:biosVersion', "" );

	my ($contact) = $in->{'config'} =~ /^set\s+snmp\s+contact\s+"([^\s\"]+)"/mi;
	$out->print_element( 'core:contact', $contact );

	# Up 8791 hours 15 minutes 9 seconds Since 30 Sept 2006 11:36:01
	if ( $in->{'system'} =~ /^Up (.+)$/mi )
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

	if ( $in->{config} =~ /^get\s+config/i )
	{
		$in->{config} =~ s/^get\s+config.*$//mi;
	}
	$in->{config}	=~ s/\s+[^\s>]+>\s*$//i;
	$in->{config}	=~ s/^Total\s+Config\s+size\s+\S+\s*$//mi;
	$in->{config}	= trim ( $in->{config} );

	my $startup;
	$startup->{'core:context'}    = 'boot';
	$startup->{'core:mediaType'}  = 'text/plain';
	$startup->{'core:name'}       = 'config';
	$startup->{'core:textBlob'}   = encode_base64( $in->{config} );
	$startup->{'core:promotable'} = 'true';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

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

	while ( $in->{config} =~ /^set\s+(?:user|admin\s+name)\s+"([^\s\"]+)"(?:\s+uid\s+(\d+)\s*)?$/mig )
	{
		my $account     = { accountName => $1 };
		my $accountName = $1;
		if (   $in->{config} =~ /^set\s+user\s+"$accountName"\s+hash-password\s+"([^\s"]+)"/mi
			|| $in->{config} =~ /^set\s+admin\s+password\s+"([^\s"]+)"/mi )
		{
			$account->{password} = $1;
		}
		$out->print_element( "localAccount", $account );
	}

	$out->close_element("localAccounts");
}

sub parse_filters
{
	my ( $in, $out ) = @_;

	my $openedFilterLists = 0;
	while ( $in->{policy} =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s.+$/mig )
	{
		my $ftr_id        = $1;
		my $ftr_from_zone = $2;
		my $ftr_to_zone   = $3;
		my $ftr_from_add  = $4;
		my $ftr_to_add    = $5;
		my $ftr_service   = $6;
		my $ftr_action    = $7;
		my $ftr_state     = $8;
		my $operator      = 'eq';
		my $ftr_name      = '';
		my $ftr_log       = '';
		if ( !$openedFilterLists )
		{
			$openedFilterLists = 1;
			$out->open_element("filterLists");
		}
		if ( $in->{ 'acl_' . $ftr_id } =~ /(?:^|, )name(?::"|\s)([^\s",]+)(?:"|,)/mi )
		{
			$ftr_name = $1;
		}
		$ftr_log = ( $in->{ 'acl_' . $ftr_id } =~ /^log no/mi ) ? 'false' : 'true';
		$out->open_element("filterList");
		my $filterEntry = {
			'log'         => $ftr_log,
			primaryAction => lc($ftr_action)
		};
		#my $from_add = getAddressByName( $in->{addresses}, $ftr_from_zone, $ftr_from_add );
		if ( $in->{ 'acl_' . $ftr_id } =~ /src "(\S+)\/(\d+)"/mi )
		{
			push @{ $filterEntry->{"sourceIpAddr"} }, { network => {address => $1, mask => $2 }};
		}

		# first look for services ports in acl_[id] entry of responses
		if ( $in->{ 'acl_' . $ftr_id } =~ /^\d+ services:\s+("(?:[^\s"]+)"(?:,\s+"(?:[^\s"]+)")*)\s*$/mi )
		{
			$_ = $1;
			s/"//g;
			my @ftr_ports = split(/,\s+/);
			foreach (@ftr_ports)
			{
				push @{ $filterEntry->{"sourceService"} }, { portExpression => {"port" => _int_port(lc), "operator" => $operator} };
			}
		}

		# then in general policy table
		elsif ( $ftr_service =~ /any/i )
		{
			push @{ $filterEntry->{"sourceService"} }, { portRange => {"portStart" => 0, "portEnd" => 65535} };
		}
		else
		{
			push @{ $filterEntry->{"sourceService"} }, { portExpression => {"port" => _int_port( lc($ftr_service) ), "operator" => $operator} };
		}
		#my $to_add = getAddressByName( $in->{addresses}, $ftr_to_zone, $ftr_to_add );
		if ( $in->{ 'acl_' . $ftr_id } =~ /dst "(\S+)\/(\d+)"/mi )
		{
			push @{ $filterEntry->{"destinationIpAddr"} }, { network => {address => $1, mask => $2} };
		}

		# first look for services ports in acl_[id] entry of responses
		if ( $in->{ 'acl_' . $ftr_id } =~ /^\d+ services:\s+("(?:[^\s"]+)"(?:,\s+"(?:[^\s"]+)")*)\s*$/mi )
		{
			$_ = $1;
			s/"//g;
			my @ftr_ports = split(/,\s+/);
			foreach (@ftr_ports)
			{
				push @{ $filterEntry->{"destinationService"} }, {portExpression => {"portStart" => _int_port(lc), "operator" => $operator} };
			}
		}

		# then in general policy table
		elsif ( $ftr_service =~ /any/i )
		{
			push @{ $filterEntry->{"destinationService"} }, { portRange => {"portStart" => 0, "portEnd" => 65535} };
		}
		else
		{
			push @{ $filterEntry->{"destinationService"} }, { portExpression => {"port" => _int_port( lc($ftr_service) ), "operator" => $operator} };
		}
		$out->print_element( "filterEntry", $filterEntry );
		$out->print_element( "mode",        'stateful');
		$out->print_element( "name",        $ftr_name );
		$out->close_element("filterList");
	}
	if ($openedFilterLists)
	{
		$openedFilterLists = 1;
		$out->close_element("filterLists");
	}
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	$out->open_element("snmp");

	my $all_snmp_pr = 0;
	my @traps       = ();
	my ( $sysContact, $sysLocation, $sysName );
	while ( $in->{config} =~ /^set\s+snmp\s+(\S.+)$/mig )
	{
		my $snmp_command = $1;
		if ( $snmp_command =~ /^community/i )
		{

			#community "public" Read-Write Trap-on  traffic version v1
			my $accessType = ( $snmp_command =~ /\bRead-Write/i ) ? 'RW' : 'RO';
			my ($commString) = $snmp_command =~ /community\s+"([^\s\"]+)"/i;
			$out->print_element( "community", { "communityString" => $commString, "accessType" => $accessType } );
		}
		elsif ( $snmp_command =~ /^host\s+"([^\s\"]+)"\s+($CIPM_RE)\s+($CIPM_RE)/i )
		{
			push( @traps, { communityString => $1, ipAddress => $2, mask => $3 } );
		}
		elsif ( $snmp_command =~ /^(contact|location|name)\s+"(([^\s\"]+))"/i )
		{
			$sysContact  = $2 if ( lc($1) eq 'contact' );
			$sysLocation = $2 if ( lc($1) eq 'location' );
			$sysName     = $2 if ( lc($1) eq 'name' );
			$all_snmp_pr++;
		}
	}
	if ( $in->{snmp} =~ /^Sysname\s+:(\S+)/mi && !( defined $sysName ) )
	{
		$sysName = $1;
		$all_snmp_pr++;
	}
	if ( $in->{config} =~ /^set\s+hostname\s+(\S+)/mi && !( defined $sysName ) )
	{
		$sysName = $1;
		$all_snmp_pr++;
	}

	$out->print_element( "sysContact",  $sysContact )  if ( defined $sysContact );
	$out->print_element( "sysLocation", $sysLocation ) if ( defined $sysLocation );
	$out->print_element( "sysName",     $sysName )     if ( defined $sysName );

	if ( defined $sysName )
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

	while ( $in->{routes} =~ /^\*\s+\d+\s+($CIDR_RE)\s+(\S+)\s+($CIPM_RE)\s+\S+\s+(\d+)\s+(\d+)\s+\S+\s*$/mig )
	{
		my $ip_address = parseCIDR($1);
		my $interface  = $2;
		my $gateway    = $3;
		my $preference = $4;
		my $metric     = $5;

		my $route = {
			destinationAddress => $ip_address->{host},
			destinationMask    => mask_to_bits ( $ip_address->{network} ),
			gatewayAddress     => $gateway,
			defaultGateway     => ( $ip_address->{host} ne '0.0.0.0' ? 'false' : 'true' ),
			interface          => $interface,
			routeMetric        => $metric,
			routePreference    => $preference,
		};

		push( @{ $staticRoutes->{staticRoute} }, $route );
	}

	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");

	while ( $in->{interfaces} =~ /^(\S+)\s+($CIPM_RE)\/(\d+)\s+\S.+?\s+($MAC_RE3)\s+(\S+)\s+(A|U|D|I|R)\s+\S+\s*$/mig )
	{
		my $interface = {
			name          => $1,
			adminStatus   => ( uc($6) ne 'U' ? 'down' : 'up' ),
			interfaceType => get_interface_type($1),              
			physical      => _is_physical($1)
		};
		$interface->{interfaceEthernet}->{macAddress} = strip_mac($4);
		my $precedence = 1;
		push @{ $interface->{interfaceIp}->{ipConfiguration} }, { ipAddress => $2, mask => $3, precedence => $precedence };
		my $ifname = $1;
		if ( defined $in->{ 'if_' . $ifname } )
		{
			if ( $in->{ 'if_' . $ifname } =~ /\b(auto|half|full)-duplex/mi )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = ( lc($1) eq 'auto' ? 'true' : 'false' );
				$interface->{interfaceEthernet}->{operationalDuplex} = lc($1);
			}
			if ( $in->{ 'if_' . $ifname } =~ /^\s*bandwidth:\s+physical\s+(\d+)([kmg])bps,\s+configured\s+(\d+)([kmg])bps,\s+current\s+(\d+)([kmg])bps/mi )
			{
				$interface->{speed} =
				  ( $5 ne '0' ) ? getUnitFreeNumber( $5, $6, 'bit' )
				  : (
					( $3 ne '0' ) ? getUnitFreeNumber( $3, $4, 'bit' )
					: getUnitFreeNumber( $1, $2, 'bit' )
				  );
			}
		}
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

sub getAddressByName
{
	my ( $addressesBlob, $zone, $name ) = @_;

	my ($zone_blob) = $addressesBlob =~ /^\s*$zone\s+Addresses:(.+)(?:addr\s+zone\s+name|\s*$)/mis;
	$zone =~ s#\(#\\\(#mg;
	$zone =~ s#\)#\\\)#mg;
	$name =~ s#\(#\\\(#mg;
	$name =~ s#\)#\\\)#mg;
	$name =~ s#(\d{1,3}(?:\.\d{1,3}){0,3})\/?\~#$1/\(\?:\[\\d\\.\]\+\)#mig;
	if ( $zone_blob =~ /^$name\s+($CIPM_RE)\s+($CIPM_RE)\s.+$/mi )
	{
		return
		{
			host    => $1,
			network => mask_to_bits($2),
		};
	}
	elsif ( $zone_blob =~ /^$name\s+($CIDR_RE)\s.+$/mi )
	{
		$_ = $1;
		/^([^\/]+)\/(\d+)$/;
		return
		{
			host    => $1,
			network => $2,
		};
	}

	return;
}

sub getUnitFreeNumber
{
	my $number = shift;
	my $unit   = shift;
	my $base   = shift;

	my $m = 1024;
	if ( defined $base )
	{
		if ( $base =~ /byte/i )    # memory size is measured in bytes
		{
			$m = 1024;
		}
		elsif ( $base =~ /bit/i )    # network speed is measured in bits
		{
			$m = 1000;
		}
	}

	if ( $unit =~ /K/i ) { $number * $m; }

	elsif ( $unit =~ /M/i ) { $number * $m * $m; }

	elsif ( $unit =~ /G/i ) { $number * $m * $m * $m; }
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

1;

__END__

=head1 Parsers

ZipTie::Adapters::Juniper::ScreenOS::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Juniper::ScreenOS::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
