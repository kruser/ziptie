package ZipTie::Adapters::HP::ProcurveM::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Common ip/mask regular expression
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

# MAC addresses regular expressions
our $MAC_RE1	= '[0-9a-f]{12}';
our $MAC_RE2	= '[0-9a-f]{1,2}(?:[:\.][0-9a-f]{1,2}){5}';
our $MAC_RE3	= '[0-9a-f]{4}\.[0-9a-f]{4}\.[0-9a-f]{4}';
our $MAC_RE4	= '[0-9a-f]{6}\-[0-9a-f]{6}';

sub parse_chassis
{
	my ( $in, $out ) = @_;
	
	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{'system'} =~ /\bSerial Number\s+:\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
		$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "HP";
	}
	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = 'Procurve M Series';
	$out->open_element("chassis");
	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	_parse_memory( $in, $out );

	$out->close_element("chassis");
}

sub _parse_memory
{
	# populate the memory elements of the chassis
	my ( $in, $out ) = @_;

	if ( $in->{'system'} =~ /\bMemory\s+-\s+Total\s+:\s+([\d\,]+)/mi )
	{
		my $msize	= $1;
		my $mtype	= 'RAM';
		my $mdesc	= 'RAM';
		$msize		=~ s/\,//g;
		my $memory = {
			'core:description' => $mdesc,
			kind => $mtype,
			size => $msize
		};
		$out->print_element( "memory", $memory );
	}  
	if ( $in->{'system'} =~ /\bPacket\s+-\s+Total\s+:\s+([\d\,]+)/mi )
	{
		my $msize	= $1;
		my $mtype	= 'PacketMemory';
		my $mdesc	= 'Packet';
		$msize		=~ s/\,//g;
		my $memory = {
			'core:description' => $mdesc,
			kind => $mtype,
			size => $msize
		};
		$out->print_element( "memory", $memory );
	}
}


sub _parse_cards
{
	my ( $in, $out ) = @_;
	if ( defined $in->{module} )
	{
		while ( $in->{module} =~ /^\s*([A-Z])\s+(\S+)\s+(\S.+\b)/mg )
		{
			my $slot     	= $1;
			my $type     	= $2;
			my $description	= $3;
			if ($description !~ /Available/)
			{
				my $card      	= {
					"core:description"	=> $description,
					"slotNumber"	=> ord($slot) - 64,
				};
				#$card->{"core:asset"}->{"core:assetType"} = "Card";
				$out->print_element( "card", $card );
			}
		}
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	$_ = $1 if ( $in->{config} =~ /\bSYSTEM\s*(\([^\)]+?\))/mis );
	if ( /\bNAME=~([^~]+)~/mi )
	{
		$out->print_element( 'core:systemName', $1 );		
	}

	$out->open_element('core:osInfo');
	#if ( $sysBlob =~ /^\s*RFILEs=~([^~]+)~/mi )
	#{
	#	$out->print_element( 'core:fileName', $1 );
	#}
	$out->print_element('core:make', 'HP');
	$out->print_element( 'core:name', 'HP ProCurveM');
	if ( $in->{'system'} =~ /^\s*Firmware revision\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'ProCurveM' );
	$out->close_element('core:osInfo');

	if ( $in->{'system'} =~ /^\s*ROM Version\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

 	if ( $in->{'system'} =~ /^\s*System Contact\s+:\s+(\S+)/mi )
	{
		$out->print_element( 'core:contact', $1 );		
	}

	# Up Time            : 176 days
	if ( $in->{'system'} =~ /^\s*Up Time\s+:\s+(\d+\s+\S+)/mi )
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

	$in->{'config'} =~ s#\d+-\w{3}-\d+\s+\d{1,2}:\d{1,2}:\d{1,2}##mig; # remove date
	$in->{'config'} =~ s#-- MORE --##mig; # remove more
	$in->{'config'} =~ s#DEFAULT_VLAN:.+$##mis; # remove prompt text
	$in->{'config'} =~ s#(^\s*$){1,}##mig; # remove double white lines

	# build the simple text configuration
	my $config;
	$config->{'core:name'}      	= 'config';
	#$config->{'core:textBlob'}  	= encode_base64( $in->{'config'} );
	$config->{'core:textBlob'}  	= encode_base64( $in->{'config'} );
	$config->{'core:mediaType'} 	= 'text/plain';
	$config->{'core:context'}   	= 'active';
	$config->{'core:promotable'}  	= 'true';

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

	while ( $in->{snmp} =~ /^\s+Community Name\s+:\s+(\S+)\s+MIB View\s+:\s+(\S+)\s+Write Access\s+:\s+(\S+)/mig )
	{
		$out->print_element( "community", { communityString => $1, accessType => (lc($3) eq 'unrestricted' ? 'RW' : 'RO'), mibView => $2 } );
	}

	my $sysNamePrinted;
	$_ = $1 if ( $in->{config} =~ /\bSYSTEM\s*(\([^\)]+?\))/mis );
	if ( /\bCONTACT=~([^~]+)~/mi )
	{
		$out->print_element( "sysContact", $1 );		
	}
	if ( /\bLOCATION=~([^~]+)~/mi )
	{
		$out->print_element( "sysLocation", $1 );		
	}
	if ( /\bNAME=~([^~]+)~/mi )
	{
		$out->print_element( "sysName", $1 );
		$sysNamePrinted = 1;		
	}

	if ( defined $sysNamePrinted )
	{
		my ($trapBlob)	= $in->{config} =~ /\bTRAPS (\(.+?\)\s+\))/mis;
		my $cipm		= get_crep('cipm');
		while ( $trapBlob =~ /\bIP_ADDR=($cipm)\s+COMMUNITY=(\S+)/mig )
		{
			my $mask = '255.255.255.255'; 
			$out->print_element( "trapHosts", { communityString => $2, ipAddress => $1, mask => $mask } );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;
# this parsing is wrong
=head

	my ($strouteBlob) = $in->{config_plain} =~ /^\s+Internet \(IP\) Service(.+)VLAN Names/mis;
	while ( $strouteBlob =~ /^\s*\S+\s+\|\s+\S+\s+($CIPM_RE)\s+($CIPM_RE)\s+($CIPM_RE)\s+$/mig )
	{
		my $route = {
			destinationAddress 	=> $1,
			destinationMask    	=> $2,
			gatewayAddress     	=> $3,
			defaultGateway     	=> ($1 ne '0.0.0.0' ? 'false' : 'true'),
		};

		push( @{ $staticRoutes->{staticRoute} }, $route );
	}
=cut
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");

	while ($in->{ports} =~ /^\s+(\S+)\s+(\S+)\s+\|\s+\S+\s+\S+\s+(Up|Down)\s+(\S+)\s+/mig)
	{
		my $interface =
			{
				name			=> $1,
				adminStatus		=> lc($3),
				interfaceType	=> get_interface_type($1),
				physical		=> _is_physical($1),
				speed			=> getESMT($2),
			};
		$interface->{interfaceEthernet}->{macAddress}	= '';
		$interface->{interfaceEthernet}->{mediaType}	= $2;
		$_ = $4;
		if ( /ADx|Auto/i )
		{
			$interface->{interfaceEthernet}->{autoDuplex}			= 'true';
			#$interface->{interfaceEthernet}->{operationalDuplex}	= 'auto';
		}
		elsif ( /HDx/i )
		{
			$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
			$interface->{interfaceEthernet}->{operationalDuplex}	= 'half';
		}
		elsif ( /FDx/i )
		{
			$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
			$interface->{interfaceEthernet}->{operationalDuplex}	= 'full';
		}
		my $cipm = get_crep('cipm');
		if ( $in->{ports_ip} =~ /^\s*\S+\s+\|\s+\S+\s+($cipm)\s+($cipm)\s+($cipm)\s+$/mi)
		{
			push @{$interface->{interfaceIp}->{ipConfiguration}},{'ipAddress' => $1, 'mask' => mask_to_bits($2)};
		}
		$_ = $interface->{name};
		if ( $in->{ports_spantree} =~ /^\s*$_\s+\S+\s+(\d+)\s+(\d+)\s+(\S+)/mi )
		{
			$interface->{interfaceSpanningTree}->{cost}		= $1;
			$interface->{interfaceSpanningTree}->{priority}	= $2;
			$interface->{interfaceSpanningTree}->{state}	= lc($3);
		}

		$out->print_element( "interface", $interface );
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;

	my @vlans   			= ();
	my $anyVLAN;
	while ( $in->{config} =~ /VLAN\s*(\([^\)]+?\))/mig )
	{
		$anyVLAN = 1;
		$_ = $1;
		my $name;
		$name = $1 if ( /\bNAME=(\S+)/mi );
		my $num = 1;
		$num = $1 if ( /\bVLAN_ID=(\d+)/mi );
		my $vlan = { number => $num, name => $name, enabled => 'true'};
		push( @vlans, $vlan );
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

	if ( $in->{stp} =~ /STP Enabled\s+:\s+Yes/mi )
	{
		my ($priority)	= $in->{stp} =~ /^\s*Switch Priority\s+:\s+(\S+)/mi;
		$priority		=~ s/\D//g;
		my ($max_age)	= $in->{stp} =~ /^\s*Max Age\s+:\s+(\d+)/mi;
		my ($hello)		= $in->{stp} =~ /^\s*Hello Time\s+:\s+(\d+)/mi;
		my ($fwd_del)	= $in->{stp} =~ /^\s*Forward Delay\s+:\s+(\d+)/mi;
		my ($dmacadd)	= $in->{stp} =~ /^\s*Root MAC Address\s+:\s+(\S+)/mi;
		$dmacadd		= strip_mac($dmacadd);
		my ($drcost)	= $in->{stp} =~ /^\s*Root Path Cost\s+:\s+(\d+)/mi;
		my ($drport)	= $in->{stp} =~ /^\s*Root Port\s+:\s+(\S+)/mi;
		my ($dpriority)	= $in->{stp} =~ /^\s*Root Priority\s+:\s+(\S+)/mi;
		$dpriority		=~ s/\D//g;
		my $instance =
			{
				forwardDelay	=> $fwd_del
				, helloTime		=> $hello
				, maxAge		=> $max_age
				, priority		=> $priority
				, designatedRootCost		=> $drcost
				, designatedRootMacAddress	=> $dmacadd
				, designatedRootPort		=> $drport
				, designatedRootPriority	=> $dpriority
			};
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
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

ZipTie::Adapters::HP::ProcurveM::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::HP::ProcurveM::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
