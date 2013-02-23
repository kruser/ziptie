package ZipTie::Adapters::Aruba::ArubaOS::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac parseCIDR);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Common ip/mask regular expression
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

# Classless InterDomain Routing address regular expression 
our $CIDR_RE	= '\d{1,3}(?:\.\d{1,3}){0,3}\/\d+';

# MAC addresses regular expressions
our $MAC_RE1	= '[0-9a-f]{12}';
our $MAC_RE2	= '[0-9a-f]{1,2}(?:[:\.][0-9a-f]{1,2}){5}';
our $MAC_RE3	= '[0-9a-f]{4}\.[0-9a-f]{4}\.[0-9a-f]{4}';
our $MAC_RE4	= '[0-9a-f]{6}\-[0-9a-f]{6}';

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassisAsset = { "core:assetType" => "Chassis", };

	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Aruba";

	if ( $in->{inventory} =~ /^System Serial#\s+:\s+(\S+)$/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	if ( $in->{switchinfo} =~ /ArubaOS\s+\(Model:\s*Aruba(\w+)/i )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->open_element("chassis");
	$out->print_element( "core:asset", $chassisAsset );

	_parse_cards( $in, $out );

	if ( $in->{switchinfo} =~ /^Processor (.+?)(?=with)/mi )
	{
		my $cpu;
		$cpu->{"core:description"} = $1;
		$out->print_element( "cpu", $cpu );
	}

	_parse_file_storage( $in, $out );

	_parse_memory( $in, $out );

	$out->close_element("chassis");
}

sub _parse_cards
{

	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	if ( $in->{inventory} =~ /^Supervisor FPGA\s+:\s+(\S+) Rev (\S+)/mi )
	{
		my $card =
		{
			"core:description" => "Supervisor FPGA",
		};
		$card->{"core:asset"}->{"core:assetType"} = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}			= "Aruba";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= hex($2);
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}	= $1;
		$out->print_element( "card", $card );
	}
	if ( $in->{inventory} =~ /^Optical Card\s+:\s+(\S+) Rev (\S+)/mi )
	{
		my $card =
		{
			"core:description" => "Optical Card",
		};
		$card->{"core:asset"}->{"core:assetType"} = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}			= "Aruba";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= hex($2);
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}	= $1;
		$out->print_element( "card", $card );
	}
	if ( $in->{inventory} =~ /^SC\s+Serial#\s+: (\S+)/mi )
	{
		my $card =
		{
			"core:description" => "SC",
		};
		$card->{"core:asset"}->{"core:assetType"} = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}			= "Aruba";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}	= $1;
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= $1 if ( $in->{inventory} =~ /^SC\s+Assembly#\s+: (\S+)/mi );
		$out->print_element( "card", $card );
	}
	if ( $in->{inventory} =~ /^Line Card \d+ Switch Chip\s+: (\S+) (\S+) Rev (\S+)/mi )
	{
		my $card =
		{
			"core:description" => $1,
		};
		$card->{"core:asset"}->{"core:assetType"} = "Card";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}			= "Aruba";
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"}	= $2;
		$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}	= hex($3);
		$out->print_element( "card", $card );
	}
}

sub _parse_memory
{
	# populate the memory elements of the chassis
	my ( $in, $out ) = @_;

	my $memory;
	if ( $in->{switchinfo} =~ /^Processor \(revision(.+)$/mi )
	{
		$_ = $1;
		if (/(\d+)(G|M|K)? bytes of memory\s*$/i)
		{
			$memory->{'core:description'}	= 'RAM';
			$memory->{kind}					= 'RAM';
			$memory->{size}					= getUnitFreeNumber($1,$2);
			$out->print_element( "memory", $memory );
		}
	}
	if ( $in->{switchinfo} =~ /^(\d+)(G|M|K)? bytes of non-volatile configuration memory.\s*$/mi )
	{
		$memory->{'core:description'}	= 'non-volatile';
		$memory->{kind}					= 'ConfigurationMemory';
		$memory->{size}					= getUnitFreeNumber($1,$2);
		$out->print_element( "memory", $memory );
	}
	if ( $in->{switchinfo} =~ /^(\d+)(G|M|K)? bytes of Supervisor Card System flash/mi )
	{
		$memory->{'core:description'}	= 'Supervisor Card System';
		$memory->{kind}					= 'Flash';
		$memory->{size}					= getUnitFreeNumber($1,$2);
		$out->print_element( "memory", $memory );
	}
}

sub _parse_file_storage
{
	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;

	my $tsize = 0; 
	my $fsize = 0;
	while ( $in->{storage} =~ /^\S+\s+(\d+\.\d+)(G|M|K)?\s+(?:\d+(?:\.\d+)?)(?:G|M|K)?\s+(\d+(?:\.\d+)?)(G|M|K)?/mig )
	{
		$tsize += (defined $2) ? getUnitFreeNumber($1,$2) : $1;
		$fsize += (defined $4) ? getUnitFreeNumber($3,$4) : $3;
	}
	my ($name) = $in->{switchinfo} =~ /^Boot Partition:\s+(PARTITION \d+)/mi;
	my $storage = {
		name        => $name,
		storageType => 'disk',
		size        => int($tsize + .5),
		freeSpace	=> int($fsize + .5),
	};
	$storage->{rootDir} = { name => '/', };

	while ( $in->{dir} =~ /^\S+\s+\d+\s+\S+\s+\S+\s+(\d+)\s+\S+\s+\d+\s+\S+\s+(\S+)\s*$/mig )
	{
		my $file = {
			size => $1,
			name => $2,
		};
		push( @{ $storage->{rootDir}->{file} }, $file );
	}

	$out->print_element( "deviceStorage", $storage );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{switchinfo} =~ /^Hostname is (\S+)/mi )
	{
		$out->print_element( 'core:systemName', $1 );
	}

	$out->open_element( 'core:osInfo' );
	if ( $in->{switchinfo} =~ /^Config File:\s+(\S+)/mi )
	{
		$out->print_element( 'core:fileName', $1 );
	}
	$out->print_element( 'core:make', 'Aruba');
	if ( $in->{switchinfo} =~ /^ArubaOS\s+\(MODEL:\s+([^\)\s]+)\),\s+Version\s+(\S+)\s*$/mi )
	{
		$out->print_element( 'core:name', $1 );
		$out->print_element( 'core:version', $2 );
		$out->print_element( 'core:osType', 'ArubaOS' );
	}
	$out->close_element( 'core:osInfo' );

	if ( $in->{switchinfo} =~ /^ROM:\s+System\s+Bootstrap,\s+Version\s+(\S+)\s+(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $2 );		
	}

	$out->print_element( 'core:deviceType', 'Switch' );	

	if ( $in->{contact} =~ /^(\S+)\s*$/mi )
	{
		$out->print_element( 'core:contact', $1 );
	}

	if ( $in->{switchinfo} =~ /\buptime is (\S.+)$/mi )
	{
		$_ = $1;
		my ($years)   = /(\d+)\s*years?/;
		my ($months)   = /(\d+)\s*months?/;
		my ($weeks)   = /(\d+)\s*weeks?/;
		my ($days)    = /(\d+)\s*days?/;
		my ($hours)   = /(\d+)\s*hours?/;
		my ($minutes) = /(\d+)\s*minutes?/;
		my ($seconds) = /(\d+)\s*seconds?/;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $months * 30 * 24 * 60 * 60    if ($months); # this calc is not exact
		$lastReboot -= $weeks * 7 * 24 * 60 * 60      if ($weeks);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$lastReboot -= $seconds  		              if ($seconds);
		$out->print_element( 'core:lastReboot', $lastReboot );
	}
}

sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	# build the simple text configuration
	my $running;
	$running->{"core:name"}       = "running-config";
	$running->{"core:textBlob"}   = encode_base64( $in->{"running-config"} );
	$running->{"core:mediaType"}  = "text/plain";
	$running->{"core:context"}    = "active";
	$running->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{"core:name"}       = "startup-config";
	$startup->{"core:textBlob"}   = encode_base64( $in->{"startup-config"} );
	$startup->{"core:mediaType"}  = "text/plain";
	$startup->{"core:context"}    = "boot";
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

	while ( $in->{config_plain} =~ /^mgmt-user\s+(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
	{
		my $account = 
			{
				accountName => $1,
			};
		if (	lc($2) eq 'root' )
		{
			$account->{accessLevel} = 1;
		}
		$out->print_element( "localAccount", $account );
	}

	if ( $in->{config_plain} =~ /^enable\s+(\S+)\s+"([^\s"]+)"/mi )
	{
		my $username = 'enable';
		my $account =
			{
				accountName => $username,
			};
		if ( lc($1) eq 'secret' )
		{
			$account->{accessLevel} = 15;
		}
		$out->print_element( "localAccount", $account );
	}

	$out->close_element("localAccounts");
}

sub parse_filters
{
	my ( $in, $out ) = @_;
	my $openedFilterLists;

	while ( (my $key, my $value) = each(%{$in}) )
	{
		if ( $key =~ /^acl_(\S+)$/i )
		{
			my $acl_name = $1;
			if ( !$openedFilterLists )
			{
				$openedFilterLists = 1;
				$out->open_element("filterLists");
			}
			$out->open_element("filterList");
			while ( $value =~ /^(.+)$/mig )
			{
				$_ = $1;
				if ( /^(\d+)\s+(\S+)\s+(\S+)\s+(\S+(?: \d+)?)\s+(\S+)(\s+\S+)?(\s+\S+)?.+/i )
				{
					my $priority	= $1;
					my $src			= $2;
					my $dest		= $3;
					my $srv			= $4;
					my $action		= lc($5);
					my $timerng		= $6;
					my $log			= lc($7);
					$timerng		=~ s/^\s*//;
					$log			=~ s/^\s*//;
					$log			= (lc($log) eq 'yes') ? 'true' : 'false';
					my ($src_add, $dest_add);
					my $srv_set;
					if ( $srv !~ / / )
					{
						if ( $in->{netservice} =~ /^$srv\s+(\S+)\s+(\d+)/mi )
						{
							my $port	= $2;
							my $proto	= uc( $1 );
							$proto		= 'TCP' if ($proto ne 'TCP' && $proto ne 'UDP' && $proto ne 'ICMP');
							push @{$srv_set}, { port => $port, operator => 'eq', protocol => lc ( $proto ) };
						}
					}
					elsif ( $srv =~ /([a-z]+) (\d+)/i )
					{
						push @{$srv_set}, { port => $2, operator => 'eq', protocol => lc ( $1 ) };
					}
					if ( $src !~ /$CIPM_RE/ )
					{
						$src_add = get_ip_from_net_dest($in->{destination},$src);
					}
					else
					{
						$src_add->{host} = $src;
						$src_add->{network} = '32';
					}
					if ( $dest !~ /$CIPM_RE/ )
					{
						$dest_add = get_ip_from_net_dest($in->{destination},$dest);
					}
					else
					{
						$dest_add->{host} = $dest;
						$dest_add->{network} = '32';
					}
					if ( $action eq 'redirect' )
					{
						$action = 'forward';
					}
					elsif ( $action =~ /(?:dst|src)-nat( \d+)*/ )
					{
						$action = 'forward';
					}
					my $dstNetwork = {address => $dest_add->{host}, mask => $dest_add->{network}};
					my $srcNetwork = {address => $src_add->{host}, mask => $src_add->{network}};
					my $filterEntry = {
						'destinationIpAddr'		=> { network => $dstNetwork } ,
						'destinationService'	=> { portExpression => $srv_set } ,
						'log'					=> $log ,
						'primaryAction'			=> $action ,
						'processOrder'			=> $priority ,
						'sourceIpAddr'			=> { network => $srcNetwork } ,
						'sourceService'			=> { portExpression => $srv_set } ,
					};
					$out->print_element( "filterEntry", $filterEntry );
				}
			}
			$out->print_element( "mode", 'stateless' ); 
			$out->print_element( "name", $acl_name );
			$out->close_element("filterList");
		}
	}

	if ( $openedFilterLists )
	{
		$out->close_element("filterLists");
	}
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	$out->open_element("snmp");

	my ($commBlob) = $in->{snmp_comm} =~ /^-+(?:\s+-+)+\s+(\S.+)/mis;
	while ( $commBlob =~ /^\s*(\S+)\s+(\S+)\s+\S.+$/mig )
	{
		$out->print_element("community", {"communityString" => $1, "accessType" => (uc($2) eq 'READ_ONLY' ? 'RO' : 'RW')});
	}

	if ( $in->{contact} =~ /^(\S+)\s*$/mi )
	{
		$out->print_element( "sysContact", $1 );
	}
	if ( $in->{config_plain} =~ /^location "([^\s"]+)"/mi )
	{
		$out->print_element( "sysLocation", $1 );
	}
	if ( $in->{switchinfo} =~ /^Hostname is (\S+)/mi )
	{
		$out->print_element( "sysName", $1 );
		# here should be parsed trap hosts
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	my $staticRoutes;

	while ( $in->{ip_route} =~ /^S\*?\s+($CIDR_RE)\s+\S+\s+via\s+($CIPM_RE)(\*)?/mig )
	{
		my $ip_address = parseCIDR($1);
		my $route = {
			destinationAddress => $ip_address->{host},
			destinationMask    => mask_to_bits ( $ip_address->{network} ),
			gatewayAddress     => $2,
			defaultGateway     => (!defined $3 ? 'false' : 'true'),
			interface		   => _pick_subnet( $2, $subnets ),
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
	my ( $in, $out )	= @_;
	my $subnets			= {};    # will be returned to the caller
	$out->open_element("interfaces");

	while ( $in->{config_plain} =~ /^interface (mgmt|fastethernet|gigabitethernet|vlan)(\s+\d+(?:\/(\d+))?)?.+?(?=!)/migs )
	{
		my $prefix	= lc($1);
		my $name	= $2;
		my $this_if	= undef;
		if ( defined $name )
		{
			$name		=~ s/^\s*//;
			$name		=~ s/\s*$//;
			$this_if	= "if-$prefix-$name";
		}
		else
		{
			$this_if	= "if-$prefix";
		}
		if ( defined $this_if 
			&& $in->{$this_if} !~ /Interface is not supported/mi )
		{
			my $start_re;
			if ( $prefix eq 'fastethernet' || $prefix eq 'gigabitethernet' )
			{
				$start_re = '\S+ \S+';
			}
			elsif ( $prefix eq 'vlan' )
			{
				$start_re = '\S+';
			}
			my ($status)	= $in->{$this_if} =~ /^$start_re is ([^\s\,]+),? line protocol is \S+/mi;
			$status			= 'down' if ( lc($status) ne 'up' );
			my $interface	=
			{
				name			=> $name,
				adminStatus		=> lc($status),
				interfaceType	=> get_interface_type($name),
				physical		=> _is_physical($name),
			};
			$interface->{description}						= $1 if ( $in->{$this_if} =~ /Description: (\S.+)/mi );
			$interface->{description}						=~ s/\s+$//;
			$interface->{interfaceEthernet}->{macAddress}	= strip_mac($1) if ( $in->{$this_if} =~ /address is ($MAC_RE2)/mi );
			$interface->{mtu}								= $1 if ( $in->{$this_if} =~ /MTU (\d+) bytes/mi );
			if ( $in->{$this_if} =~ /^Configured: Duplex \(\s*(AUTO|Full|Half)\s*\), speed \(\s*(AUTO|\d+ ([KMG])bps)\s*\)/mi )
			{
				if (lc($1) eq 'auto')
				{
					$interface->{interfaceEthernet}->{autoDuplex} = 'true';
				}
				else
				{
					$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
					$interface->{interfaceEthernet}->{operationalDuplex}	= lc($1);
				}
				if (lc($2) eq 'auto')
				{
					$interface->{interfaceEthernet}->{autoSpeed} = 'true';
				}
				else
				{
					$interface->{interfaceEthernet}->{autoSpeed}	= 'false';
					$interface->{speed}								= getUnitFreeNumber($2,$3,'bit');
				}
			}
			if ( $in->{$this_if} =~ /^Internet address is ($CIPM_RE)\s+($CIPM_RE)\s*$/mi )
			{
				push @{$interface->{interfaceIp}->{ipConfiguration}},{ ipAddress => $1 , mask => mask_to_bits($2) };
				my $subnet = new ZipTie::Addressing::Subnet( $1, mask_to_bits($2) );
				push( @{ $subnets->{$name} }, $subnet );
			}
			if ( $in->{span_tree} =~ /^\S+\s+$name\s+(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s*$/mi )
			{
				$_ = $1;
				$interface->{interfaceSpanningTree}->{cost}		= $2;
				$interface->{interfaceSpanningTree}->{priority}	= $3;
				if ( /disable/i )
				{
					$interface->{interfaceSpanningTree}->{state} = 'disabled';
				}
				elsif ( /forw/i )
				{
					$interface->{interfaceSpanningTree}->{state} = 'forwarding';
				}
				elsif ( /listen/i )
				{
					$interface->{interfaceSpanningTree}->{state} = 'listening';
				}
				elsif ( /learn/i )
				{
					$interface->{interfaceSpanningTree}->{state} = 'learning';
				}
				elsif ( /block/i )
				{
					$interface->{interfaceSpanningTree}->{state} = 'blocking';
				}
			}
			$out->print_element( "interface", $interface );
		}
	}

	$out->close_element("interfaces");

	return $subnets;
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	my $vlans_opened;

	while ( $in->{vlans} =~ /^(\d+)\s+(\S+)\s+(\S.+)$/mig )
	{
		my $vlan_number	= $1;
		my $vlan_name	= $2;
		my $vlan		=
		{
			enabled	=> 'true',
			name	=> $vlan_name,
			number	=> $vlan_number,
		};
		my $if_member	= $3;
		$if_member		=~ s/\s*$//;
		foreach (split (/ /,$if_member))
		{
			if ( /(\D+)(\d+)\/(\d+)(?:-(\d+))?/ )
			{
				if ( defined $4 )
				{
					foreach my $port ( $3 .. $4 )
					{
						push @{$vlan->{interfaceMember}},"$1$2/$port";
					}
				}
				else
				{
					push @{$vlan->{interfaceMember}},"$1$2/$3";
				}
			}
		}
		$out->open_element("vlans") if ( !defined $vlans_opened );
		$vlans_opened = 1;
		$out->print_element( "vlan", $vlan );
	}

	$out->close_element("vlans") if ( defined $vlans_opened );
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;
	my $instance;

	if ( $in->{span_tree} =~ /^Designated Root MAC\s+($MAC_RE2)\s*$/mi )
	{
		$instance->{designatedRootMacAddress} = strip_mac($1);
	}
	if ( $in->{span_tree} =~ /^Designated Root Priority\s+(\d+)\s*$/mi )
	{
		$instance->{designatedRootPriority} = $1;
	}
	if ( $in->{span_tree} =~ /^Root Max Age (\d+) sec\s+Hello Time (\d+) sec\s+ Forward Delay (\d+) sec\s*$/mi )
	{
		$instance->{designatedRootForwardDelay}	= $3;
		$instance->{designatedRootHelloTime}	= $2;
		$instance->{designatedRootMaxAge}		= $1;
	}
	if ( $in->{span_tree} =~ /^Bridge MAC\s+($MAC_RE2)\s*$/mi )
	{
		$instance->{systemMacAddress} = strip_mac($1);
	}
	if ( $in->{span_tree} =~ /^Bridge Priority\s+(\d+)\s*$/mi )
	{
		$instance->{priority} = $1;
	}
	if ( $in->{span_tree} =~ /^Configured Max Age (\d+) sec\s+Hello Time (\d+) sec\s+ Forward Delay (\d+) sec\s*$/mi )
	{
		$instance->{forwardDelay}	= $3;
		$instance->{helloTime}		= $2;
		$instance->{maxAge}			= $1;
	}

	if ( defined $instance )
	{
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
		$out->print_element( "spanningTree", $spanningTree );
	}
}

#sub parse_net_services
#{
#	my $in = shift;
#
#	my $net_services;
#	while ( $in =~ /^(\S+)\s+(\S+)\s+(\d+)( \d+)*.*$/mig )
#	{
#		$net_services->{$1}->{protocol}	= $2;
#		$net_services->{$1}->{port}		= $3;
#	}
#
#	return $net_services;
#}

sub get_ip_from_net_dest
{
	my ( $ndsBlob, $ndName ) = @_;
	my ( $ndBlob ) = $ndsBlob =~ /^$ndName(.+?)^\s+/mis;
	if ( defined $ndBlob )
	{
		if ( $ndBlob =~ /^\d+\s+(?:host|network)\s+($CIPM_RE)\s+($CIPM_RE)?/mi )
		{
			return {
				host => $1
				, network => ( defined $2 ? mask_to_bits($2) : '32') 
			};
		}
	}

	return 0;
}

sub getUnitFreeNumber
{
	my $number	= shift;
	my $unit	= shift;
	my $base	= shift;

	my $m = 1024;
	if (defined $base)
	{
		if ($base =~ /byte/i) # memory size is measured in bytes
		{
			$m = 1024;
		}
		elsif ($base =~ /bit/i) # network speed is measured in bits
		{
			$m = 1000;
		}
	}

	if ($unit =~ /K/i)
	{$number * $m;}

	elsif ($unit =~ /M/i)
	{$number * $m * $m;}

	elsif ($unit =~ /G/i)
	{$number * $m * $m * $m;}
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

1;

__END__

=head1 Parsers

ZipTie::Adapters::Aruba::ArubaOS::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Aruba::ArubaOS::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
