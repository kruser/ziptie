package ZipTie::Adapters::BaseAdapter;

use strict;
use warnings;

use Net::Ping;
use Net::IP;
use Switch;

use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Adapters::Utils qw(choose_admin_ip mask_to_bits get_model_filehandle close_model_filehandle);
use ZipTie::Logger;
use ZipTie::Model::XmlPrint;
use ZipTie::SNMP;
use ZipTie::SnmpSessionFactory;

# OIDs used for discovery
my $FORWARDING               = '.1.3.6.1.2.1.4.1.0';
my $EIGRP_PEER_ADDR          = "1.3.6.1.4.1.9.9.449.1.4.1.1.3";
my $EIGRP_PEER_IF_INDEX      = "1.3.6.1.4.1.9.9.449.1.4.1.1.4";
my $OSPF_NEIGHBORS           = "1.3.6.1.2.1.14.10.1.1";
my $OSPF_NEIGHBORS_ROUTER_ID = "1.3.6.1.2.1.14.10.1.3";
my $OSPF_NEIGHBORS_IFINDEX   = "1.3.6.1.2.1.14.10.1.2";
my $INTERFACES               = '.1.3.6.1.2.1.2';
my $IF_DESCR                 = $INTERFACES . '.2.1.2';
my $IF_TYPE                  = $INTERFACES . '.2.1.3';
my $IF_OPER_STATUS           = $INTERFACES . '.2.1.8';
my $IF_IN_OCTETS             = $INTERFACES . '.2.1.10';
my $IP_ADDR_TABLE            = '.1.3.6.1.2.1.4.20';
my $IP_AD_ENT_IF_INDEX       = $IP_ADDR_TABLE . '.1.2';
my $IP_AD_ENT_NETMASK        = $IP_ADDR_TABLE . '.1.3';
my $BGP_PEER_IDENTIFIER      = "1.3.6.1.2.1.15.3.1.1";
my $CDP_CACHE                = "1.3.6.1.4.1.9.9.23.1.2.1.1";
my $ARP_ENTRIES              = "1.3.6.1.2.1.4.22.1.2";
my $MAC_TABLE                = "1.3.6.1.2.1.17.4.3";
my $BRIDGE_PORT_IFINDEX      = "1.3.6.1.2.1.17.1.4.1.2";
my $CISCO_VLAN_NAMES         = "1.3.6.1.4.1.9.9.46.1.3.1.1.4";

my $CISCO_EID_REGEX = '^\.1\.3\.6\.1\.4\.1\.9\.';

my $LOGGER = ZipTie::Logger::get_logger();

sub telemetry
{
	my $pkg               = shift;
	my $connectionPathDoc = shift;

	# setup work
	my ( $connectionPath, $discoveryParams ) = ZipTie::Typer::translate_document( $connectionPathDoc, 'connectionPath' );
	my $snmpSession = ZipTie::SnmpSessionFactory->create($connectionPath);

	my $filehandle = get_model_filehandle( "BaseAdapter", $connectionPath->get_ip_address() );
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'telemetry' );
	$printer->attributes(1);
	$printer->open_discovery_event();

	# begin discovery operations
	my $systemInfo = ZipTie::Adapters::GenericAdapter::get_snmp($snmpSession);
	$printer->print_element( 'sysName',     $systemInfo->{sysName} );
	$printer->print_element( 'sysObjectId', $systemInfo->{sysObjectId} );
	$printer->print_element( 'sysDescr',    $systemInfo->{sysDescr} );

	# gather interface stats
	my $interfaces = _gather_telemetry_interfaces($snmpSession);
	my $adminIp    = $connectionPath->get_ip_address();
	if ( $discoveryParams->{calculateAdminIp} eq 'true' )
	{
		$adminIp = _calculate_admin_ip( $snmpSession, $interfaces, $adminIp );
	}
	$printer->print_element( 'adminIp', $adminIp );
	$printer->open_element('interfaces');
	foreach my $key ( sort ( keys(%$interfaces) ) )
	{
		$interfaces->{$key}->{inputBytes} = 0 if ( !defined $interfaces->{$key}->{inputBytes} );
		$printer->print_element( 'interface', $interfaces->{$key} );
	}
	$printer->close_element('interfaces');

	# Gather neighbors
	$printer->open_element('neighbors');
	_routing_neighbors( $printer, $snmpSession, $systemInfo->{sysObjectId}, $interfaces );
	_cdp_neighbors( $printer, $snmpSession, $systemInfo->{sysObjectId}, $interfaces );
	_arp_table( $printer, $snmpSession, $interfaces );
	_mac_table( $printer, $snmpSession, $systemInfo->{sysObjectId}, $interfaces, $connectionPath );
	$printer->close_element('neighbors');

	$printer->close_element('DiscoveryEvent');
	close_model_filehandle($filehandle);
}

sub _calculate_admin_ip
{
	my ( $session, $interfaces, $originalIp ) = @_;
	$LOGGER->debug("Calculating the administrative IP address for $originalIp");

	my $pureIntHash = {};

	foreach my $key ( sort ( keys(%$interfaces) ) )
	{
		push( @{ $pureIntHash->{interface} }, $interfaces->{$key} );
	}
	return choose_admin_ip( $originalIp, $pureIntHash );
}

sub _mac_table
{
	my ( $printer, $session, $sysOid, $interfaces, $connectionPath ) = @_;
	my @macEntries = ();
	if ( $sysOid =~ /$CISCO_EID_REGEX/ )
	{
		@macEntries = _cisco_mac_table( $session, $connectionPath, $interfaces );
	}
	else
	{
		@macEntries = _standard_mac_table( $session, $interfaces );
	}

	if ( @macEntries > 0 )
	{
		$printer->open_element('macTable');
		foreach my $entry (@macEntries)
		{
			$printer->print_element( 'macEntry', $entry );
		}
		$printer->close_element('macTable');
	}
}

sub _cisco_mac_table
{

	# for Cisco MAC tables you need to create a community string in the form
	# of <community>@<vlanNumber> for each vlan.
	my ( $session, $connectionPath, $interfaces ) = @_;
	my $originalCommunity = $connectionPath->get_credential_by_name('roCommunityString');
	my @macEntries        = ();
	my $foundVlans        = 0;
	my $vlans             = ZipTie::SNMP::walk( $session, $CISCO_VLAN_NAMES );
	while ( my ( $key, $value ) = each %$vlans )
	{
		$foundVlans = 1;
		if ( $key =~ /(\d+)$/ )
		{
			my $vlanId = $1;
			$connectionPath->{credentials}->{roCommunityString} = $originalCommunity . '@' . $vlanId;
			my $tempSession = ZipTie::SnmpSessionFactory->create($connectionPath);
			my @singleVlanMacs = _standard_mac_table( $tempSession, $interfaces );
			foreach my $entry (@singleVlanMacs)
			{
				$entry->{vlan} = $value;
			}
			@macEntries = ( @singleVlanMacs, @macEntries );
		}
	}
	$connectionPath->{credentials}->{roCommunityString} = $originalCommunity;
	@macEntries = _standard_mac_table( $session, $interfaces ) if ( !$foundVlans );
	return @macEntries;
}

sub _standard_mac_table
{
	my ( $session, $interfaces ) = @_;

	my $macTable = ZipTie::SNMP::walk( $session, $MAC_TABLE );
	my $macTableSize = %$macTable;
	if ($macTableSize)
	{
		my $portToIfIndexMap = _get_bridge_port_to_if_index($session);
		my $macEntryBuilder  = {};
		while ( my ( $key, $value ) = each %$macTable )
		{
			if ( $key =~ /(\d+)\.(\d+\.\d+\.\d+\.\d+\.\d+\.\d+)$/ )
			{
				my $attr     = $1;
				my $instance = $2;

				if ( $attr eq '1' )
				{
					my $mac = substr( $value, -12 );
					$macEntryBuilder->{$instance}->{macAddress} = $mac if ( $mac =~ /[\da-z]{12}/ );
				}
				elsif ( $attr eq '2' )
				{
					my $ifIndex = $portToIfIndexMap->{$value};
					$macEntryBuilder->{$instance}->{interface} = $interfaces->{$ifIndex}->{name};
				}
			}
		}

		my @macEntries = ();
		foreach my $key ( keys(%$macEntryBuilder) )
		{
			if ($macEntryBuilder->{$key}->{macAddress})
			{
				push( @macEntries, $macEntryBuilder->{$key} );
			}
		}
		return @macEntries;
	}
	else
	{
		return ();
	}
}

sub _get_bridge_port_to_if_index
{

	# reads the bridge ports to ifIndex mapping so that we can get a real name
	# for a bridge port
	my $session     = shift;
	my $bridgePorts = ZipTie::SNMP::walk( $session, $BRIDGE_PORT_IFINDEX );
	my $map         = {};
	while ( my ( $key, $value ) = each %$bridgePorts )
	{
		if ( $key =~ /(\d+)$/ )
		{
			$map->{$1} = $value;
		}
	}
	return $map;
}

sub _arp_table
{
	my ( $printer, $session, $interfaces ) = @_;
	my $arpTable = ZipTie::SNMP::walk( $session, $ARP_ENTRIES );
	my $opened = 0;
	while ( my ( $key, $value ) = each %$arpTable )
	{
		$printer->open_element('arpTable') if ( !$opened );
		$opened = 1;
		if ( $key =~ /(\d+)\.(\d+\.\d+\.\d+\.\d+)$/ && length($value) >= 12 )
		{
			my $arpEntry = {
				ipAddress  => $2,
				macAddress => substr( $value, -12 ),
				interface  => $interfaces->{$1}->{name},
			};
			$printer->print_element( 'arpEntry', $arpEntry );
		}
	}
	$printer->close_element('arpTable') if $opened;
}

sub _cdp_neighbors
{
	my ( $printer, $session, $sysOid, $interfaces ) = @_;
	if ( $sysOid =~ /$CISCO_EID_REGEX/ )
	{
		my $cdpCache     = ZipTie::SNMP::walk( $session, $CDP_CACHE );
		my $cdpNeighbors = {};
		my $openElement  = 0;
		foreach my $key ( sort ( keys(%$cdpCache) ) )
		{
			$printer->open_element('discoveryProtocolNeighbors') if ( !$openElement );
			$openElement = 1;
			if ( $key =~ /(\d+)\.((\d+)\.\d+)$/ )
			{
				my $attribute = $1;
				my $ifIndex   = $3;
				my $instance  = $2;
				$cdpNeighbors->{$instance}->{protocol} = 'CDP';
				switch ($attribute)
				{
					case [4]
					{
						my $ip = _ip_from_hex( $cdpCache->{$key} );
						$cdpNeighbors->{$instance}->{ipAddress}      = $ip if($ip);
						$cdpNeighbors->{$instance}->{localInterface} = $interfaces->{$ifIndex}->{name};
					}    # addr
					case [5] { $cdpNeighbors->{$instance}->{sysDescr} = $cdpCache->{$key}; }    # sysDescr
					case [6]
					{
						$cdpNeighbors->{$instance}->{sysName} = $cdpCache->{$key};
						$cdpNeighbors->{$instance}->{sysName} =~ s/[^!-~]//g;                   # remove non-ascii chars
					}    # device ID
					case [7]
					{
						$cdpNeighbors->{$instance}->{remoteInterface} = $cdpCache->{$key};
					}    # interface
					case [8] { $cdpNeighbors->{$instance}->{platform} = $cdpCache->{$key}; }    # platform
				}
			}
		}
		foreach my $key ( sort ( keys(%$cdpNeighbors) ) )
		{
			$printer->print_element( 'discoveryProtocolNeighbor', $cdpNeighbors->{$key} );
		}
		$printer->close_element('discoveryProtocolNeighbors') if ($openElement);
	}
}

sub _routing_neighbors
{
	my ( $printer, $session, $sysOid, $interfaces ) = @_;

	my $forwarding = ZipTie::SNMP::get( $session, [$FORWARDING] );
	if ( $forwarding->{$FORWARDING} )
	{
		$printer->open_element('routingNeighbors');
		_eigrp_neighbors( $printer, $session, $interfaces ) if ( $sysOid =~ /$CISCO_EID_REGEX/ );    # only on Cisco
		_ospf_neighbors( $printer, $session, $interfaces );
		_bgp_neighbors( $printer, $session );
		$printer->close_element('routingNeighbors');
	}

}

sub _bgp_neighbors
{
	my ( $printer, $session ) = @_;
	my $bgpPeers = ZipTie::SNMP::walk( $session, $BGP_PEER_IDENTIFIER );
	foreach my $key ( sort ( keys(%$bgpPeers) ) )
	{
		if ( $key =~ /(\d+\.\d+\.\d+\.\d+)$/ )
		{
			my $neighbor = {
				protocol  => 'BGP',
				ipAddress => $1,
				routerId  => $bgpPeers->{$key},
			};
			$printer->print_element( 'routingNeighbor', $neighbor );
		}
	}
}

sub _ospf_neighbors
{
	my ( $printer, $session, $interfaces ) = @_;
	my $ospfRouterIds   = ZipTie::SNMP::walk( $session, $OSPF_NEIGHBORS_ROUTER_ID );
	my $ospfNeighbors   = ZipTie::SNMP::walk( $session, $OSPF_NEIGHBORS );
	my $ospfAddressless = ZipTie::SNMP::walk( $session, $OSPF_NEIGHBORS_IFINDEX );

	foreach my $key ( sort ( keys(%$ospfRouterIds) ) )
	{
		if ( $key =~ /(\d+\.\d+\.\d+\.\d+\.\d+)$/ )
		{
			my $instance  = $1;
			my $ipAddress = $ospfNeighbors->{ $OSPF_NEIGHBORS . '.' . $instance };
			my $neighbor  = {
				protocol  => 'OSPF',
				routerId  => $ospfRouterIds->{$key},
				ipAddress => $ipAddress,
				interface => _find_ospf_interface_name( $ipAddress, $ospfAddressless->{ $OSPF_NEIGHBORS_IFINDEX . '.' . $instance }, $interfaces, ),
			};
			$printer->print_element( 'routingNeighbor', $neighbor );
		}
	}
}

sub _find_ospf_interface_name
{
	my ( $ipAddress, $portNumber, $interfaces ) = @_;
	if (!$portNumber)
	{
		foreach my $key ( sort ( keys(%$interfaces) ) )
		{
			if ( defined $interfaces->{$key}->{ipEntry} )
			{
				my @ips = @{ $interfaces->{$key}->{ipEntry} };
				foreach my $ip (@ips)
				{
					if ( defined $ip->{mask} )
					{
						my $subnet = new ZipTie::Addressing::Subnet($ip->{ipAddress}, $ip->{mask});
						if ($subnet->contains($ipAddress))
						{
							return $interfaces->{$key}->{name};
						}
					}
				}
			}
		}
	}
	else
	{
		return $interfaces->{$portNumber}->{name};
	}
}

sub _eigrp_neighbors
{
	my ( $printer, $session, $interfaces ) = @_;
	my $peerAddr    = ZipTie::SNMP::walk( $session, $EIGRP_PEER_ADDR );
	my $peerIfIndex = ZipTie::SNMP::walk( $session, $EIGRP_PEER_IF_INDEX );

	foreach my $key ( sort ( keys(%$peerAddr) ) )
	{
		if ( $key =~ /(\d+\.\d+\.\d+)$/ )
		{
			my $instance = $1;
			my $ip       = _ip_from_hex( $peerAddr->{$key} );
			my $ifIndex  = $peerIfIndex->{ $EIGRP_PEER_IF_INDEX . '.' . $instance };

			my $neighbor = {
				protocol  => 'EIGRP',
				interface => $interfaces->{$ifIndex}->{name},
				routerId  => '0.0.0.0',
				ipAddress => $ip,
			};
			$printer->print_element( 'routingNeighbor', $neighbor );
		}
	}

}

sub _ip_from_hex
{
	my $hex = shift;
	if ( length($hex) >= 8 )
	{
		return join '.', unpack "C*", pack "H*", substr( $hex, -8 );
	}
	return undef;
}

sub _gather_telemetry_interfaces
{
	my $session    = shift;
	my $interfaces = {};
	_populate_int_field( $interfaces, $session, $IF_DESCR,       'name' );
	_populate_int_field( $interfaces, $session, $IF_TYPE,        'type' );
	_populate_int_field( $interfaces, $session, $IF_OPER_STATUS, 'operStatus' );
	_populate_int_field( $interfaces, $session, $IF_IN_OCTETS,   'inputBytes' );
	_populate_ip_entries( $interfaces, $session );
	return $interfaces;
}

sub _populate_ip_entries
{
	my ( $interfaces, $session ) = @_;
	my $ifIndexes = ZipTie::SNMP::walk( $session, $IP_AD_ENT_IF_INDEX );
	my $netmasks  = ZipTie::SNMP::walk( $session, $IP_AD_ENT_NETMASK );
	foreach my $key ( sort ( keys(%$ifIndexes) ) )
	{
		if ( $key =~ /^$IP_ADDR_TABLE\.1\.2\.(\d+\.\d+\.\d+\.\d+)/ )
		{
			my $ifIndex = $ifIndexes->{$key};
			my $ip      = $1;
			my $mask    = $netmasks->{ $IP_AD_ENT_NETMASK . '.' . $ip };
			my $ipEntry = {
				ipAddress => $ip,
				mask      => mask_to_bits($mask),
			};
			
			# Some devices improperly put IP addresses in the ipAddr table on
			# ifIndex numbers that don't exist in the interfaces table
			if (!defined $interfaces->{$ifIndex})
			{
				$interfaces->{$ifIndex} = {
					name 		=> 'undefined',
					operStatus 	=> 'Unknown',
					type 		=> 'other',
				}
			}
			
			push( @{ $interfaces->{$ifIndex}->{ipEntry} }, $ipEntry );
		}
	}
}

sub _populate_int_field
{
	my ( $interfaces, $session, $oid, $fieldName ) = @_;
	my $result = ZipTie::SNMP::walk( $session, $oid );
	foreach my $key ( sort ( keys(%$result) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			my $value = $result->{$key};
			($value) = ZipTie::Adapters::GenericAdapter::resolve_type($value) if ( $fieldName eq 'type' );
			$value = _resolve_oper_status($value) if ( $fieldName eq 'operStatus' );
			$interfaces->{$1}->{$fieldName} = $value;
		}
	}
}

sub _resolve_oper_status
{
	my $intStatus = shift;
	my $status    = 'up';
	switch ($intStatus)
	{
		case [1] { $status = "Up" };
		case [2] { $status = "Down" };
		case [3] { $status = "Testing" };
		case [4] { $status = "Unknown" };
		case [5] { $status = "Dormant" };
		case [6] { $status = "NotPresent" };
		case [7] { $status = "LowerLayerDown" };
	}
	return $status;
}

1;

__END__

=head1 NAME

ZipTie::Adapters::BaseAdapter 

=head1 SYNOPSIS

This module is not designed to be used directly.  All Adapters should
inherit their methods from this module so they can take advantage of any
abstracted operations.

To inherit these methods simply put this line of code in your adapter module
	
	our @ISA = qw(ZipTie::Adapters::BaseAdapter);

=head1 DESCRIPTION

description

=head1 METHODS

=over 12

=item C<telemetry>

Uses SNMP to gether system level information along with neighbor information

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
  Date: Jun 19, 2008

=cut
