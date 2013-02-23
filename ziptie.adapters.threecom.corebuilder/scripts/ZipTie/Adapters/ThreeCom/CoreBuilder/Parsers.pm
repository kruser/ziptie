package ZipTie::Adapters::ThreeCom::CoreBuilder::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep strip_mac getUnitFreeNumber);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp parse_port_ip_by_vlan);

my $MAC 	= get_crep('mac2');
my $CIPM_RE	= get_crep('cipm');

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;
	
	my ($ap, $apUnits)= $in->{system} =~ /AP memory size\s+:\s+(\d+)\s+(\w+)\s*$/mig;
	my ($fp, $fpUnits) = $in->{system} =~ /FP memory size\s+:\s+(\d+)\s+(\w+)\s*$/migc;
	my ($flash, $fUnits) = $in->{system} =~ /Flash memory size\s+:\s+(\d+)\s+(\w+)\s*$/migc;
	my ($buffer, $bufUnits) = $in->{system} =~ /Buffer memory size\s+:\s+(\d+)\s+(\w+)\s*$/migc;
	
	$out->open_element("chassis");
	$out->open_element("core:asset");
	
	$out->print_element('core:assetType','Chassis');
	$out->open_element('core:factoryinfo');
	$out->print_element('core:make','3Com');
	$out->print_element('core:modelNumber', '9300');
	$out->close_element('core:factoryinfo');
	$out->close_element("core:asset");
	
	#Print the existent memories (size > 0)
	my $memory;
	my $size;
	if ($ap > 0)
	{
		$size = getUnitFreeNumber($ap,$apUnits);
		$memory->{kind} = 'Other';
		$memory->{size} = $size;
		$out->print_element( "memory", $memory );
	}
	
	if ($fp > 0)
	{
		$size = getUnitFreeNumber($fp,$fpUnits);
		$memory->{kind} = 'Other';
		$memory->{size} = $size;
		$out->print_element( "memory", $memory );
	}
	
	if ($flash > 0)
	{
		$size = getUnitFreeNumber($flash,$fUnits);
		$memory->{kind} = 'Flash';
		$memory->{size} = $size;
		$out->print_element( "memory", $memory );
	}
	
	if ($buffer > 0)
	{
		$size = getUnitFreeNumber($buffer,$bufUnits);
		$memory->{kind} = 'Other';
		$memory->{size} = $size;
		$out->print_element( "memory", $memory );
	}
	
	$out->close_element("chassis");
}



sub parse_system
{
	my ( $in, $out ) = @_;
	
	my ($version) = $in->{system} =~ /^\s*Version\s*(\d+\.\d+\.\d+)\s*/mis;
	my ($name) = $in->{system} =~ /^\s*System Name:\s+(.*)$/mi;

	$out->print_element( 'core:systemName', $name );
	
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make',    '3Com' );
	$out->print_element( 'core:version', $version );
	$out->print_element( 'core:osType',  'CoreBuilder' );
	$out->close_element('core:osInfo');
		
	$out->print_element( 'core:deviceType', 'Switch' );
	
	if (defined $in->{uptime})
	{
		my $now = time();
		my $lastReboot = $now - ($in->{uptime} / 100);
		$out->print_element('core:lastReboot', int($lastReboot));
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
	
	my ($roComm) = $in->{snmp} =~ /Read-only community is (\S+)\s*/mig;
	my ($rwComm) = $in->{snmp} =~ /Read-write community is (\S+)\s*/mig;
	my ($name) = $in->{system} =~ /^\s*System Name:\s+(.*)$/mi;
	
	$out->open_element("snmp");
	
	$out->open_element("community");
	$out->print_element("accessType", 'RO');
	$out->print_element("communityString", $roComm);
	$out->close_element("community");
	
	$out->open_element("community");
	$out->print_element("accessType", 'RW');
	$out->print_element("communityString", $rwComm);
	$out->close_element("community");
	
	$out->print_element( "sysName", $name );
	
	$out->close_element("snmp");
}


sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	
	my $staticRoutes;
	
	my ($blob) = $in->{routes} =~ /Status\s+(.*?)menu/migs;
	
	while ($blob =~ /\s*((?:$CIPM_RE|default route))\s+((?:$CIPM_RE|\-*))\s+((?:\d+|\-*))\s+((?:$CIPM_RE|\-*))\s+(\w+)\s*/migo)
	{
		my ($dest, $mask, $metric, $gtwy, $status) = ($1,$2,$3,$4,$5);
		$mask = mask_to_bits ( $mask );
		
		unless ($status =~ /static/i)
		{
			next;
		}
		
		if ($dest =~ /default/i)
		{
			$dest = '0.0.0.0';
		}
		
		if ($mask =~  /--/)
		{
			$mask = '0';
		}
		
		my $route = {
			destinationAddress => $dest,
			destinationMask    => $mask,
			gatewayAddress     => $gtwy,
			interface		   => _pick_subnet( $gtwy, $subnets ),
		};
		
		unless ($metric =~ /--/)
		{
			$route->{metric} = $metric;
		}
		
		if ( !defined $route->{destinationMask} )
		{
			$route->{destinationMask} = '32';
		}

		if ( ( $route->{destinationAddress} eq '0.0.0.0' ) && ( $route->{destinationMask} eq '0' ) )
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

sub parse_port_ip_by_vlan
{
	my ( $in ) = @_;
	my $ports_ips;

	while ( $in->{vlans} =~ /^\s*(\d+)\s+\d+\s+\S+\s+\S+\s+\S+\s+(\S.+)$/mig )
	{
		my $index	= $1;
		$_			= trim ( $2 );
		if ( $_ )
		{
			my @ports = split ( /\s+/ );
			if ( $in->{vlan_ips} =~ /^\s*$index\s+\S+\s+(\S+)\s+(\S+)\s+\S+\s*$/mi )
			{
				my $ip		= $1;
				my $mask	= mask_to_bits ( $2 );
				foreach (@ports)
				{
					$ports_ips->{$_} = { ipAddress => $ip, mask => $mask };
				}
			}
		}
	}

	return $ports_ips;
}

sub parse_interfaces
{
	my ( $in, $out, $ports_ips ) = @_;
	my $subnets			= {};    # will be returned to the caller
	
	my ($blob1) = $in->{interfaces} =~ /port\s+portLabel\s+(.+?)(?=port)/migsc;
	my ($blob2) = $in->{interfaces} =~ /port\s+portType\s+portState\s+(.+?)(?=port)/migsc;
	my ($blob3) = $in->{interfaces} =~ /port.+autoNegState\s+(.+?)(?=port)/migsc;
	my ($blob4) = $in->{interfaces} =~ /port.+reqFlowControl\s+(.+?)(?=port)/migsc;
	my ($blob5) = $in->{interfaces} =~ /port\s+macAddress\s+(.+)/migsc;
	
	my ($ifblob1) = $in->{stp_ifs} =~ /port\s+stp\s+linkState\s+state\s+(.*?)(?=port)/migsc;
	my ($ifblob2) = $in->{stp_ifs} =~ /port\s+priority\s+pathCost\s+designatedCost\s+(.*?)(?=port)/migsc;
	
	my $port1Min = -1;
	my $port1Max = -1;
	
	my $port2Min = -1;
	my $port2Max = -1;
	
	my $HEX = get_crep('hex');

	$out->open_element("interfaces");
	
	my ($prio, $cost, $state);
	
	while ($blob1 =~ /(\d+)([^\n]*)/mig)
	{
		my $id1 = $1;
		$_ = trim($2);
		my $name = $_  || $1;
		$blob2 =~ /\s*(\d+)\s+\S+\s+(\S+)\s*/migc;
		my ($id2, $status) = ($1,$2);
		$blob3 =~ /\s*(\d+)\s+\S+\s+(\w+)\s+\w+\s*/migc;
		my ($id3, $auto) = ($1,$2);
		$blob4 =~ /\s*(\d+)\s+\S+\s+(\d+)(\w+)\s+\S+\s*/migc;
		my ($id4, $speed, $mode) = ($1,$2,$3);
		$blob5 =~ /\s*(\d+)\s+($MAC)\s*/migco;
		my ($id5, $mac) = ($1,$2);
		
				
		unless (($id1 == $id2) && ($id1 == $id3) && ($id1 == $id4) && ($id1 == $id5))
		{
			$LOGGER->debug("Invalid response from device encountered when parsing interfaces!");
			last;
		}
		
		my $interface = {
			name		=> $name,
			interfaceType	=> "ethernet",
			physical	=> "true",
			speed => $speed * 10000
		};
		
		if ( $id1 > $port1Max )
		{
			#get the next set of port stp info
			$ifblob1 =~ /\s*(\d+)(?:-(\d+))?\s+\S+\s+\S+\s+(\S+).*/mig;
			$port1Min = $1;
			$port1Max = $2 || $1;
			$state = $3;
				
			$ifblob2 =~ /\s*(\d+)(?:-?(\d+))?\s+(0x$HEX+)\s+(\d+)\s+.*/mig;
			$port2Min = $1;
			$port2Max = $2 || $1;
			$prio = hex($3);
			$cost = $4;
						
			unless ( ($port1Min == $port2Min) && ($port1Max == $port2Max) )
			{
				$LOGGER->debug("Invalid response from device encountered when parsing interfaces!");
				last;
			}
		}
		
		if ( ($id1 >= $port1Min) && ($id1 <= $port1Max) )
		{
			#We can put the stp info in this interface
			$interface->{interfaceSpanningTree}->{cost} = $cost;
			$interface->{interfaceSpanningTree}->{state} = $state;
			$interface->{interfaceSpanningTree}->{priority} = $prio;
		}

		


		$interface->{interfaceEthernet}->{macAddress}	= strip_mac($mac);

		if ( $auto =~ /enable/i )
		{
			$interface->{interfaceEthernet}->{autoDuplex}		= 'true';
		}
		else
		{
			$interface->{interfaceEthernet}->{autoDuplex}		= 'false';
		}
		
		if ( $mode =~ /full/i )
		{
			$interface->{interfaceEthernet}->{operationalDuplex}	= 'full';
		}
		else
		{
			$interface->{interfaceEthernet}->{operationalDuplex}	= 'half';
		}
		
		if ($status =~ /off-line/i)	
		{
			$interface->{adminStatus}	= 'down';
		}
		else
		{
			$interface->{adminStatus}	= 'up';
		}

		if ( $ports_ips->{$id1} )
		{
			push @{ $interface->{"interfaceIp"}->{"ipConfiguration"} }, $ports_ips->{$id1} ;
			my $subnet = new ZipTie::Addressing::Subnet( $ports_ips->{$id1}->{ipAddress}, $ports_ips->{$id1}->{mask} );
			push( @{ $subnets->{$interface->{name}} }, $subnet );
		}

		$out->print_element( "interface", $interface );
		
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
	
	my ($stMac, $rtMaxAge) = 	$in->{stp} =~ /bridgeMaxAge\s*\n\s+\d+\s+[0-9a-f]+\s+($MAC)\s+(\d+)\s*/migso;
	my ($maxAge, $rtHelloTime, $helloTime) = $in->{stp} =~ /maxAge.*helloTime\s*\n\s*(\d+)\s+(\d+)\s+(\d+)\s*/migcs;
	my ($rtFwdDelay, $fwdDelay, $holdTime) = $in->{stp} =~ /bridgeFwdDelay.*holdTime\s*\n\s+(\d+)\s+(\d+)\s+(\d+)\s*/migsc;
	my ($rtCost, $rtPort, $priority) = $in->{stp} =~ /rootCost.*priority\s*\n\s*(\d+)\s+(\d+|No Port)\s+(\S+)/migcs;
	
	my $instance;
	my $spanningTree;
	
	$instance->{priority} = hex($priority); #it comes in hexadecimal
	$instance->{helloTime} = $helloTime;
	$instance->{holdTime} = $holdTime;
	$instance->{maxAge} = $maxAge;
	$instance->{forwardDelay} = $fwdDelay;
	$instance->{designatedRootCost} = $rtCost;
	$instance->{designatedRootForwardDelay} = $rtFwdDelay;
	$instance->{designatedRootHelloTime} = $rtHelloTime;
	$instance->{designatedRootMaxAge} = $rtMaxAge;
	
	if ( $rtPort =~ /\d+/)
	{
		$instance->{designatedRootPort} = $rtPort;
	}
	
	$instance->{systemMacAddress} = strip_mac($stMac);
	
	push( @{ $spanningTree->{spanningTreeInstance} }, $instance );

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);

}


1;
