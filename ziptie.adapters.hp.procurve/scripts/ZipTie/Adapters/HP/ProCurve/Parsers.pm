package ZipTie::Adapters::HP::ProCurve::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(strip_mac);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_chassis create_config parse_system parse_interfaces parse_stp parse_snmp parse_vlan_info parse_vlan_ids);

# Common ip/mask regular expression
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

sub parse_chassis
{
	my ( $in, $out ) = @_;
	
	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "HP";
	if ( $in->{'version'} =~ /Serial Number\s*:\s*(\S+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	if ( $in->{'version'} =~ /Firmware revision\s*:\s*(\S+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:firmwareVersion'} = $1;
	}
	#if ($in->{'sysDescr'} =~ /ProCurve.*Switch\s+(\w+)/i)
	#{
	#	$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	#}
	if ( $in->{version} =~ /sysDescr\.0\s*=\s*([\w\s\-]+),/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->open_element("chassis");
	$out->print_element( "core:asset", $chassisAsset );
	if ( $in->{'version'} =~ /Base MAC Addr\s*:\s*(\S+)/ )
	{
		my $mac = $1;
		$mac =~ s/[^a-zA-Z\d]//g;
		$out->print_element("macAddress", $mac);
	}
	if ( $in->{'version'} =~ /Memory\s*-\s*Total\s*:\s*([\d,]+)/ )
	{
		my $bytes = $1;
		$bytes =~ s/[^\d]//g;
		my $memory = {
			size => $bytes,
			kind => 'RAM',
		};
		$out->print_element("memory", $memory);
	}
	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{version} =~ /System Name\s*:\s*(\S+)/;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	if ( $in->{version} =~ /^Boot Image:\s+(.*?)\s+$/m )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'HP' );
	if ( $in->{version} =~ /^Image stamp:\s+(.*?)\s+$/m )
	{
		$out->print_element( 'core:name', $1 );
	}
	if ( $in->{version} =~ /(Software|Firmware) revision\s*:*\s+([A-Z]\.\d+\.\d+)\s+/mi )
	{
		$out->print_element( 'core:version', $2 );
	}
	elsif ( $in->{'sysDescr'} =~ /revision\s*:*\s+([A-Z]\.\d+\.\d+)/mi )
	{
        $out->print_element( 'core:version', $1 );
    }
	$out->print_element( 'core:osType', 'ProCurve' );
	$out->close_element('core:osInfo');

	if ( $in->{version} =~ /ROM Version\s+:\s+([A-Z]\.\d+\.\d+)\s+/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{version} =~ /System Contact\s+:\s+(.*?)\s+$/m;
	$out->print_element( 'core:contact', $contact );

	if ( $in->{version} =~ /Up Time\s+:\s+(.+)\s+Memory/i )
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

	# Populates the configuration entity for the main ProCurve configs
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( $in->{"running_config"} );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{"core:promotable"} = "false";

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{"core:name"}       = "startup-config";
	$startup->{"core:textBlob"}   = encode_base64( $in->{"startup_config"} );
	$startup->{"core:mediaType"}  = "text/plain";
	$startup->{"core:context"}    = "boot";
	$startup->{"core:promotable"} = "true";                                                     

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $startup );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $macAddress = '';

	if ( $in->{version} =~ /Base\s+MAC\s+Addr\s+:\s+([0-9a-f-]+)/i )
	{
		$macAddress = strip_mac($1);
	}

	$out->open_element("interfaces");

	my ($ifBlob) = $in->{interfaces};
	my ($stp_blob) = $in->{stp} =~/Designated\s+Bridge[-|\s|\+]+(\d+.*)$/mis;
	my $name;
	my $done_ifs;

	while ($ifBlob =~ /^\s+(\S+)\s+(\S+)\s+\|\s+\w+\s+(\w+)\s+(\w+)\s+(\w+)\s+.*$/migc)

	{
		next if ( lc ($1) eq 'port' && lc ($2) eq 'type' );
		if ( !$done_ifs->{$1} )
		{
			$done_ifs->{$1} = 1;
			$name = $1;
			my $interface =
			{
				name		=> $name,
				adminStatus	=> lc($4),
				interfaceType	=> "unknown",
				physical	=> "true"
			};

			$interface->{interfaceEthernet}->{macAddress}	= $macAddress;
			$interface->{interfaceEthernet}->{mediaType}	= $2;

			$_ = $5;
			if ( /ADx|Auto/i )
			{
				$interface->{interfaceEthernet}->{autoDuplex}		= 'true';
			}
			elsif ( /HDx/i )
			{
				$interface->{interfaceEthernet}->{autoDuplex}		= 'false';
				$interface->{interfaceEthernet}->{operationalDuplex}	= 'half';
			}
			elsif ( /FDx/i )
			{
				$interface->{interfaceEthernet}->{autoDuplex}		= 'true';
				$interface->{interfaceEthernet}->{operationalDuplex}	= 'full';
			}
			while ( $stp_blob =~/^\s*(\d+)(?:\s+\S+)?\s+(\d+)\s+(\d+)\s+(\w+)\s.+$/migc )
			{
				if ($name eq $1)
				{
					$interface->{interfaceSpanningTree}->{cost}	= $2;
					$interface->{interfaceSpanningTree}->{priority}	= $3;
					$interface->{interfaceSpanningTree}->{state} = lc($4);
					last;
				}
			}

			$out->print_element( "interface", $interface );
		}
	}

	$out->close_element("interfaces");
}

sub parse_stp
{
	# Parses Spanning Tree information
	my ( $in, $out ) = @_;
	my $spanningTree;
	my $blob;
	my $instance;

	#If the STP is disabled, no info is shown and therefore
	#no tag is to be added to the ZED
	if ($in->{stp} =~ /STP\s+Enabled\s+:\s+No/msig)
	{
		return;
	}
	
	if ( $in->{stp} =~ /^(.+?)^\s+-+/msig )
	{
		$blob = $1;
	}
	else
	{
		return;
	}

	if ( $blob =~ /Spanning\s+Tree\s+Information/i )
	{
		
		
		if ( $blob =~ /Switch\s+Priority\s+:\s+(\d+)/gic )
		{
			$instance->{priority} = $1;
		}
		if ( $blob =~ /Hello\s+Time\s+:\s+(\d+)/gic )
		{
			$instance->{helloTime} = $1;
		}
		if ( $blob =~ /Max\s+Age\s+:\s+(\d+)/gic )
		{
			$instance->{maxAge} = $1;
		}
		if ( $blob =~ /Forward\s+Delay\s+:\s+(\d+)/gic )
		{
			$instance->{forwardDelay} = $1;
		}
		if ( $blob =~ /Root\s+MAC\s+Address\s+:\s+([0-9a-f-]+)/gic )
		{
			$instance->{designatedRootMacAddress} = strip_mac($1);
		}
		if ( $blob =~ /Root\s+Path\s+Cost\s+:\s+(\d+)/gic )
		{
			$instance->{designatedRootCost} = $1;
		}
		if ( $blob =~ /Root\s+Port\s+:\s+(\d+)/gic )
		{
			$instance->{designatedRootPort} = $1;
		}
		if ( $blob =~ /Root\s+Priority\s+:\s+(\d+)/gic )
		{
			$instance->{designatedRootPriority} = $1;
		}
		
		#Get the MAC Address
		if ( $in->{version} =~ /Base\s+MAC\s+Addr\s+:\s+([0-9a-f-]+)/i )
		{
			$instance->{systemMacAddress} = strip_mac($1);
		}
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );

		$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
	}
}

sub parse_snmp
{
	#Parses the SNMP Configuration
	my ( $in, $out ) = @_;
	
	my $name = undef;
	my ($snmp_blob,$traps_blob) = $in->{snmp} =~/^\s+SNMP.+Write\s+Access(.+?)Trap\s+Receivers.+Sent\s+in\s+Trap(.+)$/mis;
	$snmp_blob =~s/^[-|\s]+$//mis;
	$out->open_element("snmp");
	
	while ( $snmp_blob =~ /^\s+(\S+)\s+(\S+)\s+(\S+)\s*$/migc )
	{
		$out->print_element( "community", { communityString => $1, accessType => (lc($3) eq 'unrestricted' ? 'RW' : 'RO'), mibView => $2 } );
	}
	
	if ( $in->{version} =~ /^\s+System\s+Name\s+:\s+(\S+)/migc )
	{
		$name = $1;
			
	}
	if ( $in->{version} =~ /^\s+System\s+Contact\s+:\s+(\S+)/migc )
	{
		$out->print_element( "sysContact", $1 );
				
	}
	if ( $in->{version} =~ /^\s+System\s+Location\s+:\s+(\S+)/migc )
	{
		$out->print_element( "sysLocation", $1 );
				
	}
	
	if($name)
	{
		$out->print_element( "sysName", $name );
	}
	
	$traps_blob =~ s/^[-\s]+$//mig;
	while ( $traps_blob =~ /^\s+($CIPM_RE)\s+(\S+)\s+\S+\s+$/migco )
	{
		my $mask = '255.255.255.255'; 
		$out->print_element( "trapHosts", { communityString => $2, ipAddress => $1} );
	}

	$out->close_element("snmp");
}

sub parse_vlan_ids
{
	#Parses the VLAN ID's for later
	#retrieval of detailed info
	my ($in, $out) = @_;  
	
	my @ids;
	my ($id_blob) = $in->{vlans} =~/^\s+802\.1Q\s+VLAN\s+ID\s+Name(?:\s+\|)?\s+Status(?:\s+Voice\s+Jumbo)?\s+\-[\s+-]+^(.*)$/mis;

	#print "id_blob:\n*******\n$id_blob\n*******\n";
	if ( $id_blob )
	{
		while ($id_blob =~ /^\s+(\d+)\s+\w+\|?\s+/migc)
		{
			push(@ids,$1);
		}
	}
	return @ids;
}

sub parse_vlan_info
{
	#Get the detailed info for each VLAN
	my ($in, $out) = @_;

	$out->open_element("vlans");

	while ( (my $key, my $value) = each(%{$in}) )
	{
	
		next if ( $key !~ /^vlan_\S+$/i );

		my ($id) = $value =~/802.1Q\s+VLAN\s+ID\s+:\s+(\d+)/misgc;
		my ($name, $info_blob) = $value =~/\s+Name\s+:\s+(\S+).*?[-\s]+(.*)$/misgc;

		$out->open_element("vlan");
		$out->print_element("enabled", "true");

		while($info_blob =~/^\s*(\d+)\s+\w+\s+\w+\s+\w+\s*$/migc)
		{
			$out->print_element("interfaceMember",$1);
		}

		$out->print_element("name",$name);
		$out->print_element("number", $id);
		$out->close_element("vlan");
	}

	$out->close_element("vlans");
}
	

sub getESMT
{
	my $mediaType = shift;

	if ($mediaType =~ /(\d+)/)
	{
		return $1 * 1000 * 1000;
	}

	return 0;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::HP::ProCurve::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::HP::ProCurve::Parsers;
	create_config( $cliResponses, $xmlPrinter );	
	parse_system( $cliResponses, $xmlPrinter );	
	parse_interfaces( $cliResponses, $xmlPrinter );	
	parse_stp( $cliResponses, $xmlPrinter );	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
ProCurve device responses and print out ZipTie model elements.

=head2 Methods

=over 12

=item C<create_config>

Uses the HP ProCurve startup and running configs to put together a ZipTie
configurationRepository element.

=item C<parse_system>

Some top level attributes such as model number, etc.

=item C<parse_interfaces>

Uses "show interfaces brief" command to populate 
the ZipTie interfaces model.

=item C<parse_stp>

Uses "show spanning-tree" information
from ProCurve switches to populate the ZipTie STP model.

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

  Contributor(s): rkruse, Brent Gerig (brgerig@taylor.edu)
  Date: November 20, 2007

=cut
