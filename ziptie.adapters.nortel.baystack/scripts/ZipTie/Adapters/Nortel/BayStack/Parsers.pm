package ZipTie::Adapters::Nortel::BayStack::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(get_mask get_port_number trim get_interface_type);
use ZipTie::Logger;
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(create_config parse_static_routes parse_chassis parse_snmp parse_system parse_interfaces parse_vlans parse_stp);

my $LOGGER = ZipTie::Logger::get_logger();

sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element('chassis');

	my $chassisAsset;
	$chassisAsset = { 'core:assetType' => 'Chassis', };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = 'Nortel';
	if ( $in->{system} =~ /sysDescr:\s+BayStack\s+(\d+\S*)/im )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{system} =~ /sysDescr:\s+Business\s+Policy\s+Switch\s+(\d+\S*)/im )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{system} =~ /sysDescr:\s+Ethernet\s+Routing\s+Switch\s+(\d+\S*)/im )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	elsif ( $in->{system} =~ /sysDescr:\s+Ethernet\s+Switch\s+(\d+\S*)/im )
    {
        $chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
    }
	if ( $in->{system} =~ /Serial\s+#:\s+(\S+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	$out->print_element( 'core:asset',       $chassisAsset );
	$out->print_element( 'core:description', $in->{snmp_system}->{sysDescr} );
	if ( $in->{system} =~ /MAC Address:\s*(\S+)/i )
	{
		my $mac = $1;
		$mac =~ s/-//g;
		$out->print_element( 'macAddress', $mac );
	}

	if ( $in->{tech} )
	{
		( $_ ) = $in->{tech} =~ /MEMORY INFORMATION(.+)IP Configuration/mis;
		if ( /free\s+(\d+)\s+\d+\s+\d+\s+\d+/mi )
		{
			my $memory =
				{
					kind	=> 'RAM'
					, size	=> $1
				};
			$out->print_element( "memory", $memory );
		}
	}

	$out->close_element('chassis');
}

sub parse_system
{
	my ( $in, $out ) = @_;
	if ( $in->{system} =~ /sysName:\s*\[?\s*(\S.+?)\s*$/im )
	{
		$_ = $1;
		s/\s+\]\s*$//;
		$out->print_element( 'core:systemName', $_ );
	}

	if ( $in->{system} =~ /SW:(v\d+\S+)/i )
	{
		$out->open_element('core:osInfo');
		$out->print_element( 'core:make',    'Nortel' );
		$out->print_element( 'core:version', $1 );
		$out->print_element( 'core:osType',  'BayStack' );
		$out->close_element('core:osInfo');
	}

	if ( $in->{system} =~ /FW:(V?\d+\S+)/i )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	if ( $in->{system} =~ /sysUpTime:\s+(.+)$/m )
	{
		$_ = $1;
		my ($years) = /(\d+)\s+years?/i;
		my ($weeks) = /(\d+)\s+weeks?/i;
		my ($days)  = /(\d+)\s+days?/i;
		my ( $hours, $minutes, $seconds ) = /(\d+):(\d+):(\d+)/;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$out->print_element( 'core:lastReboot', $lastReboot );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	my $config = {
		'core:name'       => 'config',
		'core:textBlob'   => encode_base64( $in->{config} ),
		'core:mediaType'  => 'application/octet-stream',
		'core:context'    => 'N/A',
		'core:promotable' => 'true',
	};

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	if ( $in->{running_config} )
	{
		my $running = {
			'core:name'       => 'running-config',
			'core:textBlob'   => encode_base64( $in->{running_config} ),
			'core:mediaType'  => 'text/plain',
			'core:context'    => 'N/A',
			'core:promotable' => 'false',
		};

		# push the configuration into the repository
		push( @{ $repository->{'core:config'} }, $running );
	}

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	my @routes;
	if ( $in->{ip_config} =~ /Default Gateway:\s*\[?\s*(\S+)/i )
	{
		my $defaultGateway = {
			defaultGateway     => 'true',
			destinationAddress => '0.0.0.0',
			destinationMask    => '0',
			gatewayAddress     => $1,
			interface	       => trim ( _pick_subnet( $1, $subnets ) ),
		};
		push( @routes, $defaultGateway );
		$out->open_element('staticRoutes');
		$out->print_element( 'staticRoute', @routes );
		$out->close_element('staticRoutes');
	}
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

sub parse_vlans
{
	my ( $in, $out ) = @_;
	my $vlanResults = $in->{snmp_vlans};
	my $vlans       = {};
	foreach my $key ( sort ( keys(%$vlanResults) ) )
	{
		if ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.3\.2\.1\.1\.(\d+)$/ )
		{
			$LOGGER->debug("VLAN: $1");
			my $vlannum = $1;
			$vlans->{$vlannum}->{number}  = $vlannum;
			$vlans->{$vlannum}->{enabled} = 'true';
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.3\.2\.1\.2\.(\d+)$/ )
		{

			# remove
			my $vlanName = $vlanResults->{$key};
			$LOGGER->debug("VLAN $1 name: $vlanName");
			$vlans->{$1}->{name} = $vlanName;
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.3\.2\.1\.11\.(\d+)$/ )
		{
			my $vlannum = $1;
			my $portSet = $vlanResults->{$key};
			$LOGGER->debug("VLAN portMember: $1 => $portSet");

			# TODO: rkruse - need to figure this out
			# push( @{$vlans->{$vlannum}->{interfaceMember}}, $portSet);    # this is 0 if not used
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.3\.2\.1\.10\.(\d+)$/ )
		{
			my $vlannum = $1;
			my $type    = $vlanResults->{$key};
			$LOGGER->debug("VLAN type: $vlannum => $type");
			$vlans->{$vlannum}->{implementationType} = $type;
		}
	}
	$out->open_element('vlans');
	foreach my $key ( sort ( keys(%$vlans) ) )
	{
		$out->print_element( 'vlan', $vlans->{$key} );
	}
	$out->close_element('vlans');
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $stgResults = $in->{snmp_stp};
	my $groups     = {};

	foreach my $key ( sort ( keys(%$stgResults) ) )
	{
		if ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.1\.(\d+)$/ )
		{
			my $id = $1;
			$groups->{$1} = {};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.4\.(\d+)$/ )
		{
			my $id = $1;
			my ($mac) = $stgResults->{$key} =~ /([\da-fA-F]{12})$/;
			$groups->{$id}->{systemMacAddress} = $mac;
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.7\.(\d+)$/ )
		{
			my $id = $1;
			$groups->{$id}->{priority} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.10\.(\d+)$/ )
		{
			my $id = $1;
			my ($mac) = $stgResults->{$key} =~ /([\da-fA-F]{12})$/;
			$groups->{$id}->{designatedRootMacAddress} = $mac;
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.11\.(\d+)$/ )
		{
			$groups->{$1}->{designatedRootCost} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.12\.(\d+)$/ )
		{
			$groups->{$1}->{designatedRootPort} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.13\.(\d+)$/ )
		{
			$groups->{$1}->{designatedRootMaxAge} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.14\.(\d+)$/ )
		{
			$groups->{$1}->{designatedRootHelloTime} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.16\.(\d+)$/ )
		{
			$groups->{$1}->{designatedRootForwardDelay} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.17\.(\d+)$/ )
		{
			$groups->{$1}->{maxAge} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.18\.(\d+)$/ )
		{
			$groups->{$1}->{helloTime} = $stgResults->{$key};
		}
		elsif ( $key =~ /1\.3\.6\.1\.4\.1\.2272\.1\.13\.4\.1\.19\.(\d+)$/ )
		{
			$groups->{$1}->{forwardDelay} = $stgResults->{$key};
		}
	}
	$out->open_element('spanningTree');
	foreach my $key ( sort ( keys(%$groups) ) )
	{
		$out->print_element( 'spanningTreeInstance', $groups->{$key} );
	}
	$out->close_element('spanningTree');
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = $in->{snmp_system};

	if ( $in->{snmp} =~ /Read-Only Community String:\s*\[?\s*(\S+)/mi )
	{
		my $community = {
			communityString => $1,
			accessType      => 'RO',
		};
		push( @{ $snmp->{community} }, $community );
	}
	if ( $in->{snmp} =~ /Read-Write Community String:\s*\[?\s*(\S+)/mi )
	{
		my $community = {
			communityString => $1,
			accessType      => 'RW',
		};
		push( @{ $snmp->{community} }, $community );
	}
	while ( $in->{snmp} =~ /^\s*Trap #\d IP Address:\s+\[\s*(\d+\.\d+\.\d+\.\d+).+?Community String:\s+\[\s*(\S+)?\s*\]/msig )
	{

		# for menu based systems
		my $trapHost = {
			ipAddress       => $1,
			communityString => $2,
		};
		push( @{ $snmp->{trapHosts} }, $trapHost ) if ( $trapHost->{ipAddress} ne '0.0.0.0' );
	}
	while ( $in->{snmp} =~ /Trap #\d IP Address:\s+(\d+\.\d+\.\d+\.\d+)(.+?)(?=Trap)/msig )
	{
		my $ip   = $1;
		my $rest = $2;

		if ( $ip ne '0.0.0.0' )
		{
			my $trapHost = { ipAddress => $ip, };
			if ( $rest =~ /Community String:\s+(\S+)/i )
			{
				$trapHost->{communityString} = $1;
			}

			# for cli based systems
			push( @{ $snmp->{trapHosts} }, $trapHost );
		}
	}

	$out->print_element( 'snmp', $snmp );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $subnets		 = {};    # will be returned to the caller

	my $ints = $in->{snmp_interfaces};
	my $foundSubnets;

	# add port details
	while ( $in->{ports} =~ /^\s*(\d+)\s+\[\s*\S+\s*\]\s+\S+\s+\[\s*\S+\s*\]\s*\[\s*(Enabled|Disabled)\s*\]\s+\[(.*?)\]/mig )
	{
		my $port            = $1;
		my $speedDuplexBlob = $3;
		my $autoNegotiation = ( $2 =~ /Enabled/i ) ? 'true' : 'false';

		# find the matching interface to update
		foreach my $interface ( @{ $ints->{interface} } )
		{
			if ( $interface->{name} =~ /\s+$port$/ )
			{
				$interface->{interfaceEthernet}->{autoDuplex} = $autoNegotiation;
				$interface->{interfaceEthernet}->{autoSpeed}  = $autoNegotiation;
				if ( $speedDuplexBlob =~ /(full|half)/i )
				{
					$interface->{interfaceEthernet}->{operationalDuplex} = lc($1);
				}
				if ( $interface->{interfaceIp}->{ipConfiguration} )
				{
					my ( $ipAddress, $mask ) = ( $interface->{interfaceIp}->{ipConfiguration}->[0]->{ipAddress}, $interface->{interfaceIp}->{ipConfiguration}->[0]->{mask} );
					if ( $ipAddress && $mask && $mask > 0 && $mask <= 32 )
					{
						$foundSubnets = 1;
						my $subnet = new ZipTie::Addressing::Subnet( $ipAddress, $mask );
						push( @{ $subnets->{$interface->{name}} }, $subnet );
					}
				}
			}
		}
	}

	# find the matching interface to update
	if ( !$foundSubnets )
	{
		foreach my $interface ( @{ $ints->{interface} } )
		{
			if ( $interface->{name} && $interface->{interfaceIp}->{ipConfiguration} )
			{
				my ( $ipAddress, $mask ) = ( $interface->{interfaceIp}->{ipConfiguration}->[0]->{ipAddress}, $interface->{interfaceIp}->{ipConfiguration}->[0]->{mask} );
				my $subnet = new ZipTie::Addressing::Subnet( $ipAddress, $mask );
				push( @{ $subnets->{$interface->{name}} }, $subnet );
			}
		}
	}

	# Add spanning tree data for each port
	while ( $in->{stp_ports} =~ /^\s*(\d+)\s+.+?(\d+)\s+(\d+)\s+(\S+)\s*$/mg )
	{
		my $port     = $1;
		my $stp_port = {
			cost     => $3,
			state    => lc($4),
			priority => $2,
		};

		# find the matching interface to update
		foreach my $interface ( @{ $ints->{interface} } )
		{
			if ( $interface->{name} =~ /\s+$port$/ )
			{
				$interface->{interfaceSpanningTree} = $stp_port;
			}
		}
	}

	$out->print_element( 'interfaces', $ints );

	return $subnets;
}

1;
