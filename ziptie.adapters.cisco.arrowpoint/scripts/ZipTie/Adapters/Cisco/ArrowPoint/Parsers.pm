package ZipTie::Adapters::Cisco::ArrowPoint::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number strip_mac trim get_interface_type mask_to_bits get_crep);
use MIME::Base64 'encode_base64';
use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp get_file_list);

# PARSE SYSTEM INFO
# systemName, osInfo, biosVersion?, deviceType, contact?, lastReboot
sub parse_system
{
	my ( $in, $out ) = @_;

	#systemName
	my ($systemName) = $in->{chassis} =~ /^Name:\s+(\S+\s+\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	#osInfo::= fileName?, make, name?, softwareImage?, version, osType
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Cisco' );
	
	if ( $in->{version} =~ /Flash \(Operational\):\s+(\b.+\b)/i )
	{
		$out->print_element( 'core:version', $1 );
	}
	
	$out->print_element( 'core:osType', 'CSS/ArrowPoint' );
	$out->close_element('core:osInfo');

	#deviceType
	$out->print_element( 'core:deviceType', 'Content Switch' );

	#lastReboot (in seconds)
	if ( $in->{uptime} =~ /(\d+)\s+days\s+(\d+):(\d+):(\d+)\s*$/mi )
	{
		my $days       = $1;
		my $hours      = $2;
		my $min        = $3;
		my $sec        = $4;
		my $lastReboot = ( $days * 86400 ) + ( $hours * 3600 ) + ( $min * 60 ) + $sec;
		$out->print_element( "core:lastReboot", $lastReboot );
	}
}

# PARSES CHASSIS
# asset?, description?, card*, cpu*, deviceStorage*, memory*, powersupply*
# asset ::= assetTag? : assetType : dateCreated? : description? : factoryinfo? : location? : owner
sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element("chassis");
	my $chassisAsset = { "core:assetType" => 'Chassis' };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Cisco";

	if ( $in->{chassis} =~ /Name:\s+(CSS\s?\S+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ( $in->{chassis} =~ /Serial Number:\s+(\S+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	if ( $in->{chassis} =~ /HW Major Version:\s+(\S+)/ )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );
	parse_deviceStorage( $in, $out );
	parse_memory( $in, $out );
	$out->close_element("chassis");
}

#Helping parser to gather volatile memory info. (is part of Chassis information.)
sub parse_memory
{
	my ( $in, $out ) = @_;

	# Installed Memory:   134,217,728 (128 MB)
	if ( $in->{memory} =~ /^\s*Installed\s+Memory:\s+(\S+)\s+.+$/im )
	{
		my $size = $1;
		$size =~ s/,//gm;
		$out->print_element( "memory", { kind => 'RAM', size => $size } );
	}
}

#Helping parser to gather device's storage information like HD's. (is part of Chassis information)
#total # of clusters:  32878
#   bytes per cluster:  16384
#       free clusters:  24113
sub parse_deviceStorage
{
	my ( $in, $out ) = @_;
	my $size     = 0;
	my $freeSize = 0;
	my $flag = 0;
	if ( $in->{disk} =~ /\s*Disk\s+Size:\s+(\S+)\s+(\S+)\s*/igm )
	{
		$size = $1;
		my $unit = $2;
		$size =~ s/,//;
		$size = to_bytes( $size, $unit );
		$flag = 1;
	}
	if ( $in->{disk} =~ /\s*Disk\s+Free:\s+(\S+)\s+(\S+)\s*/igm )
	{
		$freeSize = $1;
		my $unit = $2;
		$freeSize =~ s/,//;
		$freeSize = to_bytes( $freeSize, $unit );
		$flag = 1;
	}
	if($flag == 0)
	{
		if ( $in->{disk} =~ /\s*total\s+#\s+of\s+clusters:\s+(\d+)\s*/igm )
		{
			my $clusters = $1;
			my $bytes_per_cluster = 0;
			if ( $in->{disk} =~ /\s*bytes\s+per\s+cluster:\s+(\d+)\s*/igm )
			{
				$bytes_per_cluster = $1;
			}
			if ( $in->{disk} =~ /\s*free\s+bytes:\s+(\d+)\s*/igm )
			{
				$freeSize = $1;
			}		
			$size = $clusters * $bytes_per_cluster;
		}
	}
	$out->print_element( "deviceStorage", { name => '/', storageType => 'disk', size => $size, freeSpace => $freeSize } );
}

#Helping method to match a description to a predifined type.
sub infer_asset_type
{
	my $part = shift;
	if ( $part =~ /(Chassis|CPU|Card|PowerSupply|Backplane|Software|Stack|Memory|Other)/i )
	{
		return $1;
	}
	else
	{
		return "Other";
	}

}

# CREATE CONFIG
# config*, name?, repository*
# config::= context, mediaType, name, textBlob
sub create_config
{
	my ( $in, $out, $files ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';
	while ( ( my $key, my $value ) = each %{$files} )
	{
		# remove headers that would cause a diff
		$value->{"text"} =~ s/^!Generated.*$//im;
		$value->{"text"} =~ s/^!Active.*$//im;
		
		# Remove any null characters
		$value->{"text"} =~ s/\000//g;
	
		my $config;
		$config->{'core:context'}    = 'active';
		$config->{'core:mediaType'}  = 'text/plain';
		$config->{'core:name'}       = $key;		
		$config->{'core:promotable'} = $value->{"promotable"};
		$config->{'core:textBlob'}   = encode_base64( $value->{"text"} );

		push( @{ $repository->{'core:config'} }, $config );
	}
	$out->print_element( 'core:configRepository', $repository );
}

# PARSE INTERFACES
# interfaces ::= interface+
# interface ::= adminStatus?, description?, egressFilter?, ingressFilter?, interfaceEthernet?,
#				interfaceFrameRelay?, interfaceIp?, interfaceOspf?, interfaceSpanningTree?,
#				interfaceType, interfaceVlanTrunks*, mtu?, name, physical, speed?
sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");
	my $txt = remove_blank_lines( $in->{interfaces} );
	if ( $txt =~ /^Name\s+.+-+\s+(.+)/mgis )
	{
		my $data = $1;
		while ( $data =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+\s+\S+)\s*$/mig )
		{
			my $name      = $1;
			my $type      = $3;
			my $oper      = $4;
			my $admin     = $5;
			my $interface = {
				adminStatus   => lc($oper),
				interfaceType => infer_interface_type($type),
				name          => $name,
				physical      => is_physical($type),
			};
			$out->print_element( "interface", $interface );
		}
	}
	$out->close_element("interfaces");
}

#Helping method to match a description to a predifined type.
sub infer_interface_type
{

	#"other", "unknown", "atm", "ethernet", "frameRelay", "gre", "isdn", "modem", "ppp", "serial", "softwareLoopback", "sonet", "tokenRing"
	my $part = shift;
	if ( $part =~ /(unknown|atm|ethernet|frameRelay|gre|isdn|modem|ppp|serial|softwareLoopback|sonet|tokenRing)/i )
	{
		return $1;
	}
	elsif ( $part =~ /fe|ge/i )
	{
		return "ethernet";
	}
	else
	{
		return "other";
	}

}

#Helping method.
sub is_physical
{
	my $part = shift;
	if ( $part =~ /(fe|ge)/i )
	{
		return 1;
	}
	else
	{
		return 0;
	}

}

sub parse_filters
{
	my ( $in, $out ) = @_;

	$in->{"running-config"} .= "\n".'!';
	if ( $in->{"running-config"} =~ /\s*!\*+\s+ACL([^!]+)!/mi )
	{
		my $all_acls_blob = $1;
		my $name;
		my $cipm = get_crep ( 'cipm' );
		my $openedFilterLists;

		while ( $all_acls_blob =~ /^(.+)$/mig )
		{
			$_ = trim ( $1 );
			next if ( /^$/ ); # skip empty lines

			if ( /acl (\S+)/i )
			{
				$out->open_element("filterLists") if ( !$openedFilterLists );
				$openedFilterLists	= 1;
				if ( $name )
				{
					$out->print_element( "mode", 'stateful');
					$out->print_element( "name", $name );
					$out->close_element("filterList");
				}
				$out->open_element("filterList");
				$name = $1;
			}
			elsif ( /clause\s+(\d+)\s+(\S+)\s+(\S.+)$/i )
			{
				my $processOrder	= $1;
				my $primaryAction	= $2;
				my $nwss_def		= $3;
				my $protocol;

				my $thisterm =
				{
					processOrder	=> $processOrder ,
					primaryAction	=> $primaryAction ,
					'log'			=> 'false'
				};

				$thisterm->{log} = 'true' if ( $nwss_def =~ /\blog/i );

				if ( $nwss_def =~ /^(\S+)\s+(any|$cipm|$cipm\s+$cipm)\s+(any|(?:gt|neq|eq|lt)\s+\d+)?/i )
				{
					$protocol		= lc ( $1 );
					my $source_nw	= $2;
					my $source_srv	= $3;
					if ( $source_nw =~ /^any$/i )
					{
						$thisterm->{sourceIpAddr}->{network} = { "address" => "0.0.0.0", "mask" => "0" };
					}
					elsif ( $source_nw =~ /($cipm)\s+($cipm)/i )
					{
						$thisterm->{sourceIpAddr}->{network} = { "address" => $1, "mask" => mask_to_bits ( $2 ) };
					}
					elsif ( $source_nw =~ /^($cipm)$/i )
					{
						$thisterm->{sourceIpAddr}->{host} = $1;
					}
					if ( $source_srv =~ /(gt|neq|eq|lt)\s+(\d+)/ )
					{
						$thisterm->{sourceService}->{portExpression} = { "operator" => ( lc ( $1 ) ne 'neq' ? lc ( $1 ) : 'ne' ), "port" => $2 };
					}
				}

				$thisterm->{protocol} = $protocol if ( $protocol ne 'any' );

				if ( $nwss_def =~ /destination\s+(any|$cipm|$cipm\s+$cipm)\s+(any|(?:gt|neq|eq|lt)\s+\d+)?/i )
				{
					my $dest_nw		= $2;
					my $dest_srv	= $3;
					if ( $dest_nw =~ /^any$/i )
					{
						$thisterm->{destinationIpAddr}->{network} = { "address" => "0.0.0.0", "mask" => "0" };
					}
					elsif ( $dest_nw =~ /($cipm)\s+($cipm)/i )
					{
						$thisterm->{destinationIpAddr}->{network} = { "address" => $1, "mask" => mask_to_bits ( $2 ) };
					}
					elsif ( $dest_nw =~ /^($cipm)$/i )
					{
						$thisterm->{destinationIpAddr}->{host} = $1;
					}
					if ( $dest_srv =~ /(gt|neq|eq|lt)\s+(\d+)/ )
					{
						$thisterm->{destinationService}->{portExpression} = { "operator" => ( lc ( $1 ) ne 'neq' ? lc ( $1 ) : 'ne' ), "port" => $2 };
					}
				}

				$out->print_element( "filterEntry", $thisterm );
			}
		}
		if ( $name )
		{
			$out->print_element( "mode", 'stateful');
			$out->print_element( "name", $name );
			$out->close_element("filterList");
		}

		$out->close_element("filterLists") if ( $openedFilterLists );
	}
}

# PARSE LOCAL ACCOUNTS.
# localAccounts::= localAccount+
# localAccount::= accountName : accessGroup? : accessLevel? : fullName? : password?
sub parse_local_accounts
{

	# local accounts - local usernames
	#  username testlab des-password hbnctdqefb6dbcbe superuser
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");

	#my $accs = remove_blank_lines($in->{config});
	my $accs = $in->{config};
	while ( $accs =~ /^\s*username\s+(\S+)\s+(?:des-password|password)\s+(\S+)/mig )
	{
		my $accountName = $1;
		my $password    = $2;
		my $account     = {
			accountName => $accountName,
			password    => $password
		};
		$out->print_element( "localAccount", $account );

	}
	$out->close_element("localAccounts");
}

# Helping method for getting the password for a specific username
sub getPassword
{
	my $in   = shift;
	my $user = shift;
	if ( $in->{config} =~ /^\s+username\s+$user\s+\.+password\s+(\S+)\s*$/mig )
	{

		#Ex:   username ceige des-password iaabfasfdgsgfcbbuf3hcakejgvdscmh
		return $1;
	}
	else
	{
		return "";
	}
}

# PARSE SNMP
# snmp ::= community*, sysContact?, sysLocation?, sysName, sysObjectId?, systemShutdownViaSNMP?,
#		   trapHosts*, trapSource?, trapTimeout?
sub parse_snmp
{
	my ( $in, $out ) = @_;
	my ($systemName) = $in->{config} =~ /\s*snmp\s+name\s+"(\S+)"\s*/mig;
	my ($contact)    = $in->{config} =~ /\s*snmp\s+contact\s+"(\S+)"\s*/mig;
	my ($location)   = $in->{config} =~ /\s*snmp\s+location\s+"(\S+)"\s*/mig;
	$out->open_element("snmp");
	my $community = {};
	while ( $in->{config} =~ /\s*snmp\s+community\s+(\S+)\s+(\S+)\s*/mig )
	{
		$community->{communityString} = $1;
		if ( defined $2 )
		{
			if ( $2 =~ /read-only/i )
			{
				$community->{accessType} = "RO";
			}
			elsif ( $2 =~ /read-write/i )
			{
				$community->{accessType} = "RW";
			}
		}
		$out->print_element( "community", $community );

	}
	$out->print_element( "sysContact",  $contact );
	$out->print_element( "sysLocation", $location );
	$out->print_element( "sysName",     $systemName );
	my $trapHost = {};
	while ( $in->{config} =~ /\s*snmp\s+trap-host\s+(\S+)\s+(\S+)\s*/mig )
	{
		$trapHost->{ipAddress}       = $1;
		$trapHost->{communityString} = $2;
		$out->print_element( "trapHosts", $trapHost );

	}

	$out->close_element("snmp");
}

#Helping method.
#defaultGateway : destinationAddress : destinationMask : gatewayAddress : interface? : routeMetric? : routePreference?
sub get_ip
{
	my $ip = shift;
	$ip =~ /(\S+)\/\d+/;
	return $ip;
}

#   PARSE SPANNING TREE
#   spanningTree ::= forwardDelay?, helloTime?, maxAge?, mode?, priority?, spanningTreeInstance*,
#				systemMacAddress?, type?
#   spannigTreeInstance::= designatedRootCost? : designatedRootForwardDelay? : designatedRootHelloTime? :
#   designatedRootMacAddress? : designatedRootMaxAge? : designatedRootPort? :
#   designatedRootPriority? : forwardDelay? : helloTime : holdTime? : maxAge? :
#   priority : systemMacAddress? : vlan?
#   e.g.
#	VLAN1 STP State:        Enabled
#
#	VLAN1:   Root Max Age: 20  Root Hello Time:  2  Root Fwd Delay: 15
#	Designated Root: 60-de-00-17-94-45-ee-80
#	Bridge ID:       80-00-aa-3a-9d-49-05-08
#	                                                                 Root Port Desg
#	Port       State    Designated Bridge       Designated Root      Cost Cost Port
#	----       ----- ----------------------- ----------------------- ---- ---- ----
#	e6          Fwd  80-de-00-0a-f4-50-63-40 60-de-00-17-94-45-ee-80   23   19 8002

sub parse_stp
{
	my ( $in, $out, $vlans ) = @_;
	my $spanningTree;
	while ( ( my $key, my $value ) = each( %{$vlans} ) )
	{
		my $vlan     = $key;
		my $text     = $value;
		my $thistree = $text;
		my $instance = {};
		if ( $thistree =~ /Root\s+Fwd\s+Delay:\s+(\d+)/mi )
		{
			$instance->{designatedRootForwardDelay} = $1;
		}

		if ( $thistree =~ /Root\s+Hello\s+Time:\s+(\d+)/mi )
		{
			$instance->{designatedRootHelloTime} = $1;
			$instance->{helloTime}               = $instance->{designatedRootHelloTime};
		}

		if ( $thistree =~ /^Designated\s+Root:\s+\S*(\S{17})/mi )
		{
			$instance->{designatedRootMacAddress} = strip_mac($1);
		}

		if ( $thistree =~ /Root\s+Max\s+Age:\s+(\d+)/mi )
		{
			$instance->{designatedRootMaxAge} = $1;
		}

		$instance->{vlan}     = $vlan;
		$instance->{priority} = 0;
		my $foundBridges = 0;
		if ( $thistree =~ /^[-+\s+]+-+$(.+)/smg )
		{

			#																  Root Port Desg
			#Port       State    Designated Bridge       Designated Root      Cost Cost Port
			#----       ----- ----------------------- ----------------------- ---- ---- ----
			#e6          Fwd  80-de-00-0a-f4-50-63-40 60-de-00-17-94-45-ee-80   23   19 8002
			my $bridge = $1;
			while ( $bridge =~ /^(\S+)\s+(\S+)\s+\S*(\S{17})\s+\S*(\S{17})\s+(\S+)\s+(\S+)\s+(\S+)$/mg )
			{
				my $bri  = $3;
				my $cost = $5;
				my $port = $7;
				$instance->{systemMacAddress}   = strip_mac($bri);
				$instance->{designatedRootCost} = $cost;
				$instance->{designatedRootPort} = $port;
				$foundBridges                   = 1;
				push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
			}
		}
		if ( $foundBridges == 0 )
		{
			if ( $thistree =~ /^Bridge\s+ID:\s+\S*(\S{17})/mi )
			{
				$instance->{systemMacAddress} = strip_mac($1);
			}
			push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
		}
	}

	#Base Mac Address:  aa-3a-9d-49-05-07
	if ( $in->{chassis} =~ /Base\s+Mac\s+Address:\s+(\S+)/i )
	{
		$spanningTree->{systemMacAddress} = strip_mac($1);
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

# PARSE STATIC ROUTES
# staticRoutes::= staticRoute+
# staticRoute::= defaultGateway : destinationAddress : destinationMask : gatewayAddress
#				: interface? : routeMetric? : routePreference?
sub parse_static_routes
{
	my ( $in, $out ) = @_;
	my $staticRoutes;

	#prefix/length      next hop      if   type  proto       age       metric
	#------------------ --------------- ---- ------ -------- ---------- -----------
	#0.0.0.0/0          10.100.22.1     1023 remote static      3001545           0
	if ( $in->{routes} =~ /^[-+\s+]+-+$(.+)/smg )
	{
		my $data = $1;
		while ( $data =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/mig )
		{
			my $route = {
				destinationAddress => get_ip ( $1 ),
				destinationMask    => mask_to_bits ( $1 ),
				gatewayAddress     => $2,
				interface          => $3,
				routeMetric        => $7,
				defaultGateway     => 'false'
			};
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
		$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
	}
}

# PARSE VLANS
# vlans::= vlan+
# vlan ::= areHops?, backupCRFEnabled?, bridgeMode?, bridgeNumber?, configSource?, enabled, implementationType?,
# interfaceMember*, mtu?, name?, number, parent?, ringNumber?, said?, steHops?, translationBridge1?, translationBridge2?
sub get_vlan_number
{
	my $vlan = shift;
	if ( $vlan =~ /\w+(\d+)/ )
	{
		return $1;
	}

}

#Helping method.
sub is_vlan_enabled
{
	my $vlan = shift;
	if ( $vlan =~ /enabled/i )
	{
		return 1;
	}
	else
	{
		return 0;
	}

}

# PARSE VLANS
# vlans::= vlan+
# vlan ::= areHops?, backupCRFEnabled?, bridgeMode?, bridgeNumber?, configSource?, enabled, implementationType?,
# interfaceMember*, mtu?, name?, number, parent?, ringNumber?, said?, steHops?, translationBridge1?, translationBridge2?
sub parse_vlans
{
	my ( $in, $out ) = @_;
	my @vlans    = ();
	my $thisVlan = {};
	if ( $in->{circuits} =~ /^[-+\s+]+-+\s*$(.+)/smg )
	{
		my $data = $1;
		while ( $data =~ /^\s*(\S+)\s+(\S+)\s+(\S+)(?:\s+(\S+)\s+\S+)?\s*$/mig )
		{
			$thisVlan = {
				name    => $1,
				number  => get_vlan_number($1),
				enabled => is_vlan_enabled($2)
			};

			if ( defined $4 )
			{
				$thisVlan->{interfaceMember} = $4;
			}

			if ( $thisVlan->{number} )
			{
				push( @vlans, $thisVlan );
				$thisVlan = {};
			}

		}
	}

	$out->open_element("vlans");
	foreach my $vlan (@vlans)
	{
		$out->print_element( "vlan", $vlan );
	}
	$out->close_element("vlans");
}

#OTHER UTLITY METHODS.
sub remove_blank_lines
{

	# remove leading and trailing whitespace
	my $string = shift;
	$string =~ s/^\s*^\s*//misg;
	return $string;
}

sub remove_blank_lines2
{

	# remove leading and trailing whitespace
	my $string = shift;
	$string =~ s/^\s+$//migs;
	return $string;
}

# Utility method to parse kB,MB,GB,TB to bytes.
sub to_bytes
{
	my $size = shift;
	my $unit = shift;
	if ( $unit =~ /kB/ )
	{
		return $size * 1024;
	}
	elsif ( $unit =~ /MB/ )
	{
		return $size * 1024 * 1024;
	}
	elsif ( $unit =~ /GB|G/ )
	{
		return $size * 1024 * 1024 * 1024;
	}
	elsif ( $unit =~ /TB/ )
	{
		return $size * 1024 * 1024 * 1024 * 1024;
	}
	else
	{
		return 0;
	}
}

sub get_file_list
{
	my $in = shift;
	my $files;
	while ( $in->{files} =~ /^\s*(\S+)\s+(\w+\s+\d+\s+\S+)\s+\S+\s*$/mg )
	{
		my $file = {};
		$files->{$1} = "";
	}
	return $files;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Cisco::ArrowPoint::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Cisco::ArrowPoint::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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

  Contributor(s): Ashuin Sharma (asharma@isthmusit.com), rkruse
  Date: Apr 23, 2007

=cut
