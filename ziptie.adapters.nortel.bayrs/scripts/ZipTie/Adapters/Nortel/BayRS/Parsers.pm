package ZipTie::Adapters::Nortel::BayRS::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits strip_mac seconds_since_epoch get_mask get_port_number trim get_interface_type parseCIDR bin2dec);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my @memories = ();

	my $ramsize = 0;
	while ( $in->{memory} =~ /^\s*\d+\s+\d+\s+\d+\s+(\d+)\s*$/mig )
	{
		$ramsize += $1;
	}
	$ramsize *= 1024;
	push @memories, { kind => 'RAM', size => $ramsize };

	my $chassisAsset = { "core:assetType" => "Chassis", };
	my $serialNumber = undef;
	my $modelNumber  = undef;
	if ( $in->{backplane} =~ /^\s*Backplane\s+Serial\s+Number:\s+(\d+)/mi )
	{
		$serialNumber = $1;
	}
	if ( $in->{backplane} =~ /^\s*Backplane\s+Type:\s+(\S+)/mi )
	{
		$modelNumber = $1;
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $serialNumber if $serialNumber;
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}         = "Nortel";
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'}  = $modelNumber if $modelNumber;

	$out->open_element("chassis");

	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	_parse_file_storage( $in, $out );

	foreach my $memory (@memories)
	{
		$out->print_element( "memory", $memory );
	}

	$out->close_element("chassis");
}

sub _parse_cards
{

	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	my $oldSerial;
	if ( defined $in->{show_slots} )
	{

		# old output
		if ( $in->{show_slots} =~ /^Location\s+/mi )
		{
			while ( $in->{show_slots} =~ /^\s*\S+\s+(\S+)\s+([\d\.]+)\s+(\d+)\s*$/mig )
			{
				if ( $oldSerial ne $2
						&& $2 ne '0.00' )
				{
					my $no   = 1;
					my $card = {
						slotNumber         => $no,
						"core:description" => $1,
					};
					$card->{"core:asset"}->{"core:assetType"}                          = "Card";
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}		   = 'Nortel';
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = $3;
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $2;
					$out->print_element( "card", $card );
					$oldSerial = $2;
				}
			}
		}

		# new output
		else
		{
			while ( $in->{show_slots} =~ /^\s*(\d+)\s+(\S+)\s+(\d+)\s+(\d+)\s+\S.+$/mig )
			{
				if ( $oldSerial ne $4
						&& $4 ne '0.00' )
				{
					my $no   = 1;
					my $card = {
						slotNumber         => $no,
						"core:description" => $2,
					};
					$card->{"core:asset"}->{"core:assetType"}                          = "Card";
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}		   = 'Nortel';
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = $3;
					$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $4;
					$oldSerial = $4;

					# now get any daughter cards (sub-mod)
					while ( $in->{show_daughter} =~ /^\s*$no\s+(\d+)\s+(\S+)\s+(\d+)\s*/mig )
					{
						my $daughterCard = { "core:description" => $1, };
						$daughterCard->{"core:asset"}->{"core:assetType"}                          = "Card";
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}		   = 'Nortel';
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}  = $2;
						$daughterCard->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $3;

						push( @{ $card->{daughterCard} }, $daughterCard );
					}
					$out->print_element( "card", $card );
				}
			}
		}
	}
}

sub _parse_file_storage
{

	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;

	while ( $in->{dinfo} =~ /^\s*(\d+:)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)/mig )
	{
		my $storage = {};
		$storage->{name}        = 'flash';
		$storage->{storageType} = 'flash';
		$storage->{size}        = $3;
		$storage->{freeSpace}   = $4;
		$storage->{rootDir}     = { name => "root", };
		my $vol_num = $storage->{name};
		$vol_num =~ s/\D//;

		while ( $in->{ 'dir_' . $vol_num } =~ /^(\S+)\s+(\d+)\s+(\d{1,2}\/\d{1,2}\/\d{1,2}).+$/mig )
		{
			my $file = {
				size => $2,
				name => $1,
			};
			push( @{ $storage->{rootDir}->{file} }, $file );
		}
		$out->print_element( "deviceStorage", $storage );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{system_info} =~ /^\s*System Name:(.+)$/mi;
	$systemName =~ s/^\s*//;
	$systemName =~ s/\s*$//;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Nortel' );

	if ( $in->{config} =~ /\bbuild-version\s+\{(BayRS)\s+([\d\.]+)/mi )
	{
		$out->print_element( 'core:name',    $1 );
		$out->print_element( 'core:version', $2 );
	}
	$out->print_element( 'core:osType', 'BayRS' );

	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Router' );

	my ($contact) = $in->{system_info} =~ /^\s*Contact:\s+(\S.+)$/mi;
	$contact =~ s/\s*$//i;
	$out->print_element( 'core:contact', $contact );

	if ( $in->{system_info} =~ /^\s*Up\s+Time:\s+(\S.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hrs?/;
		my ($minutes) = /(\d+)\s*mins?/;

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
	
	# pull garbage out of the config
	$in->{'config'} =~ s/^#\s+uptime.+//mg;
	$in->{'config'} =~ s/^#\s+ntp clock-period.+//mg;

	# build the simple text configuration
	my $config;
	$config->{'core:name'}       = 'bcc-view';
	$config->{'core:textBlob'}   = encode_base64( $in->{'config'} );
	$config->{'core:mediaType'}  = 'text/plain';
	$config->{'core:context'}    = 'active';
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
	my ( $in, $out ) = @_;
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
		my $snmp_line = $1;
		if ( $snmp_line =~ /^\s*(?:\d+)\s+(\S+)\s+(\S+)\s*$/i )
		{
			my $comm_string = $1;
			my $access_type = lc($2);
			$access_type = ( $access_type eq 'read-write' ) ? 'RW' : 'RO';
			push( @communities, { accessType => $access_type, communityString => $comm_string, mibView => $4 } );
		}
		elsif ( $snmp_line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S*)\s+(\d+)\s+(\S+)\s+(\S+)\s*$/i )
		{
			push( @traps, { communityString => $5, ipAddress => $1 } );
		}
	}

	# parse other snmp data and store the configuration
	foreach (@communities)
	{
		$out->print_element( "community", $_ );
	}

	my $allSysPrinted = 0;
	if ( $in->{system_info} =~ /^\s*Contact:\s+(\S.+)$/mi )
	{
		my $sysContact = $1;
		$sysContact =~ s/\s*$//i;
		$out->print_element( "sysContact", $sysContact );
		$allSysPrinted++;
	}

	if ( $in->{system_info} =~ /^\s*Location:\s+(\S.+)$/mi )
	{
		my $sysLocation = $1;
		$sysLocation =~ s/\s*$//i;
		$out->print_element( "sysLocation", $sysLocation );
		$allSysPrinted++;
	}

	if ( $in->{system_info} =~ /^\s*System Name:(.+)$/mi )
	{
		$_ = $1;
		s/^\s*//;
		s/\s*$//;
		$out->print_element( "sysName", $_ );
		$allSysPrinted++;
	}

	if ( $allSysPrinted == 3 )
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
	my ( $in, $out, $subnets ) = @_;
	my $staticRoutes;

	while ( $in->{ip_routes} =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d+)\s+(\S+)\s+\d+\s+\d+\s+(\d+)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/mig )
	{
		my $addresses   = parseCIDR($1);
		my $dst_host    = $addresses->{host};
		my $dst_network = $addresses->{network};

		my $route = {
			defaultGateway 	   => ( $dst_network eq '0.0.0.0' ? 'true' : 'false' ),
			destinationAddress => $dst_host,
			destinationMask    => mask_to_bits ( $dst_network ),
			gatewayAddress     => $4,
			routePreference    => $3,
			interface		   => _pick_subnet( $4, $subnets )
		};

		push( @{ $staticRoutes->{staticRoute} }, $route );

	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub _pick_subnet
{

	# choose from a hash of subnets and return the matching value
	my ( $gw, $subnets ) = @_;

	if ( defined $subnets )
	{
		foreach my $interfaceName ( sort ( keys(%$subnets) ) )
		{
			my @subnetsArray = @{ $subnets->{$interfaceName} };
			foreach my $subnet (@subnetsArray)
			{
				if ( $subnet->contains( $gw ) )
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

sub parse_interfaces
{

	# probably ospf parsing will be included soon
	my ( $in, $out ) = @_;
	my $subnets			= {};    # will be returned to the caller

	my $interface = {};
	$out->open_element("interfaces");
	while ( $in->{interfaces} =~ /^(.+)$/mig )
	{
		my $if_line = $1;
		if ( $if_line =~ /^Name:\s+(\S+)/i )
		{
			if ( defined $interface->{name} )
			{
				$out->print_element( "interface", $interface );
				$interface = {};
			}
			$interface = {
				name          => $1,
				interfaceType => get_interface_type($1),
				physical      => _is_physical($1),
			};
		}
		elsif ( $if_line =~ /^Admin\s+State:\s+(\S+)/i
			&& defined $interface->{name} )
		{
			$interface->{adminStatus} = lc($1);
			if ( $interface->{adminStatus} ne 'up' )
			{
				$interface->{adminStatus} = 'down';
			}
		}
		elsif ( $if_line =~ /^MAC\s+Address:\s+([a-f0-9\.]{17})/i
			&& defined $interface->{name} )
		{
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($1);
		}
		elsif ( $if_line =~ /^MTU:\s+(\d+|default)\s+Line\s+Speed:\s+(\d+\s*\S+)/i
			&& defined $interface->{name} )
		{
			my $mediaType = $2;
			$interface->{mtu} = $1 if ( $1 ne 'default' );
			$mediaType =~ s/\s+//;
			$interface->{interfaceEthernet}->{mediaType} = $mediaType;
			$interface->{speed} = getESMT($mediaType);
		}
		elsif ( $if_line =~ /^IP\s+Address:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+Mask:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/i
			&& defined $interface->{name} )
		{
			my $ipConfiguration = {
				ipAddress  => $1,
				mask       => mask_to_bits($2),
				precedence => 1,
			};
			push( @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
			my $subnet = new ZipTie::Addressing::Subnet( $1, mask_to_bits($2) );
			push( @{ $subnets->{$interface->{name}} }, $subnet );
		}
	}
	if ( defined $interface->{name} )
	{
		$out->print_element( "interface", $interface );
		$interface = {};
	}

	$out->close_element("interfaces");

	return $subnets;
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

# get Ethernet Speed by Media Type
sub getESMT
{
	my $mediaType = shift;

	if ( $mediaType =~ /(\d+)(\D\S+)/i )
	{
		return $1 * 1000 * 1000;
	}

	return 0;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Nortel::BayRS::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Nortel::BayRS::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
