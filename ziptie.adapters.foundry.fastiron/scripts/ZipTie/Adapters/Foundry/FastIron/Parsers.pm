package ZipTie::Adapters::Foundry::FastIron::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac parseCIDR get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Common ip/mask regular expression
our $CIPM_RE = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

sub parse_chassis
{
	my ( $in, $out ) = @_;

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Foundry";
	if ( $in->{showVer} =~ /,\s+serial\s+number\s+(.+)/i )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	if ( $in->{showVer} =~ /^\s*HW:\s*(\b.+?),/m )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->open_element("chassis");
	$out->print_element( "core:asset", $chassisAsset );
	
	if ($in->{'showVer'} =~ /^\s*SW:\s*(.+?Compiled on.+?$)/ms)
	{
		$out->print_element( "core:description", $1);
	}

	_parse_cards( $in, $out );

	my $cpu;
	if ( $in->{'showVer'} =~ /^\s*(\d+\s+[KMG]Hz(\s+\w+)*)/mi )
	{
		$cpu->{"core:description"} = $1;
		$cpu->{cpuType} = $1 if ( $1 =~ /\b[KMG]Hz\s+(\w+(\s+\w+){1,2})/i );
		$out->print_element( "cpu", $cpu );
	}

	if ( $in->{'showVer'} =~ /(\d+)\s+KB+\s+code\s+flash\s+memory/ )
	{
		my $storage = {
			name        => 'flash',
			storageType => 'flash',
			size        => $1 * 1024,
		};
		$out->print_element( "deviceStorage", $storage );    
	}

	my ($memoryBlob) = $in->{'showVer'} =~ /Active\s+management\s+module:(.+)$/mis;
	if ( defined $memoryBlob )
	{
		_parse_memory( $memoryBlob, $out );
	}
	else
	{
		_parse_memory( $in->{'showVer'}, $out );
	}
	
	while ($in->{'showChassis'} =~ /^power supply\s+(\d+)\s+(\b.+\b)/mg)
	{
		my $number = $1;	
		my $status = $2;	
		if ($status !~ /not present|left to righ/i)
		{
			my $powerSupply = {
				number => $number,
				status => $status,
			};	
			$out->print_element( "powersupply", $powerSupply );
		}
	}

	$out->close_element("chassis");
}

sub _parse_cards
{

	# populate the card and daughter card elements of the chassis
	my ( $in, $out ) = @_;

	#asset?, description?, daughterCard*,
	#memory?, portCount?, slotNumber?, softwareVersion?
	while ( $in->{'showVer'} =~ /^=+\s+([^=]+)/migs )
	{
		my $vrs_part = $1;

		if ( $vrs_part =~ /^SL\s+(\d+):\s*(\S.+)$/mi )
		{
			my $card = {
				slotNumber         => $1,
				"core:description" => $2
			};
			$card->{"core:description"} =~ s/\s+$//;
			$card->{"core:asset"}->{"core:assetType"} = "Card";
			my $mod_card_re = '^S' . $1 . ':(.+)$';
			if ( $in->{'showMod'} =~ /^$mod_card_re/mi )
			{
				my $card_blob = $1;
				$card->{portCount} = $1 if ( $card_blob =~ /\s+(\d+)\s+[a-f0-9]{4}\.[a-f0-9]{4}\.[a-f0-9]{4}\s*$/i );
			}
			if ( $card->{"core:description"} =~ /^(\S+)/i )
			{
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} = $1;
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"} = 'Foundry';
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = '';
			}

			$out->print_element( "card", $card );
		}
	}
}

sub _parse_memory
{

	# populate the memory elements of the chassis
	my ( $in, $out ) = @_;

	while ( $in =~ /^\s*(\d+)\s+([KMG])B\s+(.+)$/mig )
	{
		my $mdesc = $3;
		my $msize = getUnitFreeNumber( $1, $2 );
		my $mtype = "";
		if ( $mdesc =~ /RAM/i )
		{
			$mtype = 'RAM';
		}
		elsif ( $mdesc =~ /flash/i )
		{
			$mtype = 'Flash';
		}
		else
		{
			$mtype = 'Other';
		}
		my $memory = {
			'core:description' => $mdesc,
			kind               => $mtype,
			size               => $msize
		};
		$out->print_element( "memory", $memory );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{showRun} =~ /^\s*hostname\s+(\S+)\s*$/mi )
	{
		$out->print_element( 'core:systemName', $1 );
	}
	elsif ( $in->{showRun} =~ /\S+\@(\S+)(?:>|#)\s*$/ )
	{
		$out->print_element( 'core:systemName', $1 );
	}

	if ( $in->{showVer} =~ /SW:\s+Version\s+(\S+)\s+Copyright/i )
	{
		$out->open_element('core:osInfo');
		$out->print_element( 'core:make',    'Foundry' );
		$out->print_element( 'core:version', $1 );
		$out->print_element( 'core:osType',  'Iron Software' );
		$out->close_element('core:osInfo');
	}

	if ( $in->{showFlash} =~ /Boot\s+Image\s+size\s+=\s+\d+\,\s+Version\s+(\S+)/i )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	my ($devType) = $in->{showVer} =~ /(Router|Switch)/i;

	if ( !($devType) && ( $in->{showVer} =~ /(FES|[Ff][Ii]\d+)/ ) )
	{
		my $devType = 'Switch';
	}

	$out->print_element( 'core:deviceType', $devType );

	my ($contact) = $in->{showRun} =~ /^snmp-server\s+contact\s+(\S+)/mi;
	$contact =~ s/"//g;
	$out->print_element( 'core:contact', $contact );

	if ( $in->{showVer} =~ /uptime is\s+(.+)/i )
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
	$running->{'core:context'}    = 'active';
	$running->{'core:mediaType'}  = 'text/plain';
	$running->{'core:name'}       = 'running-config';
	$running->{'core:promotable'} = 'false';
	$running->{'core:textBlob'}   = encode_base64( $in->{'showRun'} );

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $running );

	my $startup;
	$startup->{'core:context'}    = 'boot';
	$startup->{'core:mediaType'}  = 'text/plain';
	$startup->{'core:name'}       = 'startup-config';
	$startup->{'core:promotable'} = 'true';
	$startup->{'core:textBlob'}   = encode_base64( $in->{'showStart'} );

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

	my $alreadyOpened;
	while ( $in->{showRun} =~ /^username\s+(\S+)\s+password\s+(\S+)\s*$/mig )
	{
		if ( !defined $alreadyOpened )
		{
			$alreadyOpened = 1;
			$out->open_element("localAccounts");
		}
		my $account = {
			accountName => $1,
			password    => $2
		};
		$out->print_element( "localAccount", $account );
	}

	if ( defined $alreadyOpened )
	{
		$out->close_element("localAccounts");
	}
}

sub parse_filters
{
	my ( $in, $out ) = @_;

	my $openedFilterLists  = 0;

	while ( $in->{showRun} =~ /^(?:ip\s+)?access-list(\s+standard)?\s+(\S+)(.+?)!/migs )
	{
		my $standard	= $1;
		my $name		= $2;
		my $acl_blob	= $3;
		$name			= trim ( $standard ) if ( $standard !~ /standard/i && $standard !~ /^$/ );

		if ( !$openedFilterLists )
		{
			$openedFilterLists = 1;
			$out->open_element("filterLists");
		}
		
		$out->open_element("filterList");
		parse_rules ( $acl_blob, $out );
		$out->print_element( 'mode', 'stateless' );
		$out->print_element( "name", $name );
		$out->close_element("filterList");
	}

	$out->close_element("filterLists") if ( $openedFilterLists );
}

sub parse_rules
{
	my ( $in, $out )	= @_;
	my $cipm			= get_crep ( 'cipm' );
	my $process_order	= 0;

	while ( $in =~ /(?:\s*access-list \S+\s+)?(deny|perm)\s+(\S+)\s+(\S.+)$/mig )
	{
		my $primaryAction 	= lc ( $1 );
		my $protocol		= $2;
		my $nws_definition	= $3;
		my $thisEntry;
		my $log				= 'false';
		if ( $nws_definition =~ /\blog/i )
		{
			$log = 'true';
		}

		$out->open_element("filterEntry");
		$primaryAction = 'permit' if ( $primaryAction eq 'perm' );
		if ( $protocol =~ /^(\d+|icmp|igmp|igrp|ip|ospf|tcp|udp)$/i ) # extended rule
		{
			my $thisIPAddress;
			if ( $nws_definition =~ /host\s+(\S+)\s+host\s+(\S+)/i )
			{
				$thisIPAddress->{network} =
				{
					"address" => $2,
					"mask"    => "32",
				};
				$out->print_element( "destinationIpAddr", $thisIPAddress );
				$out->print_element( "log", $log );
				$out->print_element( "primaryAction", $primaryAction );
				$out->print_element( "processOrder", ++ $process_order );
				$out->print_element( "protocol", $protocol );
				$thisIPAddress->{network} =
				{
					"address" => $1,
					"mask"    => "32",
				};
				$out->print_element( "sourceIpAddr", $thisIPAddress );
				
			}
			elsif ( $nws_definition =~ /any\s+any/i )
			{
				$thisIPAddress->{network} =
				{
					"address" => "255.255.255.255",
					"mask"    => "32",
				};
				$out->print_element( "destinationIpAddr", $thisIPAddress );
				$out->print_element( "log", $log );
				$out->print_element( "primaryAction", $primaryAction );
				$out->print_element( "processOrder", ++ $process_order );
				$out->print_element( "protocol", $protocol );
				$out->print_element( "sourceIpAddr", $thisIPAddress );
			}
		}
		else # standard rule
		{
			$nws_definition = $protocol." ".$nws_definition;
			my $thisIPAddress;
			$out->print_element( "log", $log );
			$out->print_element( "primaryAction", $primaryAction );
			$out->print_element( "processOrder", ++ $process_order );
			if ( $nws_definition =~ /host\s+(\S+)/i )
			{
				$thisIPAddress->{network} =
				{
					"address" => $1,
					"mask"    => "32",
				};
				$out->print_element( "sourceIpAddr", $thisIPAddress );
			}
			elsif ( $nws_definition =~ /any/i )
			{
				$thisIPAddress->{network} =
				{
					"address" => "255.255.255.255",
					"mask"    => "32",
				};
				$out->print_element( "sourceIpAddr", $thisIPAddress );
			}
		}

		$out->close_element("filterEntry");
	}
}

sub parse_snmp
{
	my ( $in, $out ) = @_;
	$out->open_element("snmp");

	my $all_snmp_pr = 0;
	my @traps       = ();
	my ( $sysContact, $sysLocation, $sysName );

	#while ($in->{showRun} =~ /^snmp-server\s+community(?:\s+\d+)?\s+(\S+)\s+(r[ow])\s*$/mig)
	while ( $in->{showRun} =~ /^snmp-server\s+(\S.+)$/mig )
	{
		my $snmp_command = $1;
		if ( $snmp_command =~ /^community\s+(\S+)\s+(r[ow])\s*$/i )
		{
			$out->print_element( "community", { "communityString" => $1, "accessType" => uc($2) } );
		}
		elsif ( $snmp_command =~ /^host\s+($CIPM_RE)\s+(\S+)\s*$/i )
		{
			push( @traps, { communityString => $2, ipAddress => $1 } );
		}
		elsif ( $snmp_command =~ /^contact\s+(\S+)\s*$/i )
		{
			$_ = $1;
			s/"//g;
			$sysContact = $_;
			$all_snmp_pr++;
		}
		elsif ( $snmp_command =~ /^location\s+(\S+)\s*$/i )
		{
			$_ = $1;
			s/"//g;
			$sysLocation = $_;
			$all_snmp_pr++;
		}
	}
	if ( $in->{showRun} =~ /^\s*hostname\s+(\S+)\s*$/mi )
	{
		$sysName = $1;
		$all_snmp_pr++;
	}
	elsif ( $in->{showRun} =~ /\S+\@(\S+)(?:>|#)\s*$/ )
	{
		$sysName = $1;
		$all_snmp_pr++;
	}

	$out->print_element( "sysContact",  $sysContact )  if ( defined $sysContact );
	$out->print_element( "sysLocation", $sysLocation ) if ( defined $sysLocation );
	$out->print_element( "sysName",     $sysName )     if ( defined $sysName );

	if ( $all_snmp_pr == 3 )
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

	my ($routeBlob) = $in->{ip} =~ /^\s*Static Routes(.+)/mis;
	if ( defined $routeBlob )
	{
		while ( $routeBlob =~ /^\s*\d+\s+($CIPM_RE)\s+($CIPM_RE)\s+($CIPM_RE)\s+(\d+)\s+(\d+)\s*$/mig )
		{
			my $route = {
				destinationAddress => $1,
				destinationMask    => mask_to_bits ( $2 ),
				gatewayAddress     => $3,
				defaultGateway     => ( $1 ne '0.0.0.0' ? 'false' : 'true' ),
				routeMetric        => $4,
				interface		   => _pick_subnet( $3, $subnets )
			};
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
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
	my ( $in, $out ) = @_;
	my $subnets = {};    # will be returned to the caller

	$out->open_element("interfaces");

	my $interface = {};
	while ( $in->{interfaces} =~ /^(.+)$/mig )
	{
		my $if_line = $1;
		if ( $if_line =~ /^(\S+)\s+is\s+(up|down|enabled|disabled)(,\s+line\s+protocol\s+is\s+(?:up|down|enabled|disabled))?/i )
		{
			if ( defined $interface->{name} )
			{
				if ( lc( $interface->{adminStatus} ) eq 'up' )
				{
					if ( !defined $interface->{interfaceIp}->{ipConfiguration} )
					{
						my $precedence = 1;
						if ( $in->{showRun} =~ /^ip\s+address\s+($CIPM_RE)\s+($CIPM_RE)/mi )
						{
							push @{ $interface->{interfaceIp}->{ipConfiguration} }, { ipAddress => $1, mask => mask_to_bits($2), precedence => $precedence };
							my $subnet = new ZipTie::Addressing::Subnet( $1, mask_to_bits($2) );
							push( @{ $subnets->{$interface->{name}} }, $subnet );
						}
					}
				}
				$out->print_element( "interface", $interface );
				$interface = {};
			}
			$interface = {
				name          => $1,
				adminStatus   => ( lc($2) ne 'up' ? 'down' : 'up' ),
				interfaceType => get_interface_type($1),
				physical      => _is_physical($1)
			};
		}
		elsif ( $if_line =~ /,\s+address\s+is\s+([a-f0-9\.]{14})/i
			&& defined $interface->{name} )
		{
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($1);
		}
		elsif ( $if_line =~ /^\s*Configured\s+speed/i
			&& defined $interface->{name} )
		{
			if (   $if_line =~ /Configured\s+speed\s+(\d+)([a-zA-Z]+),\s+actual\s+unknown/i
				|| $if_line =~ /Configured\s+speed\s+\S+,\s+actual\s+(\d+)([a-zA-Z]+)/i )
			{
				$interface->{speed} = getUnitFreeNumber( $1, $2, 'bit' );
			}
			if (   $if_line =~ /,\s+configured\s+duplex\s+(f|a|h)dx,\s+actual\s+unknown/i
				|| $if_line =~ /,\s+configured\s+duplex\s+(?:f|a|h)dx,\s+actual\s+(f|a|h)dx/i )
			{
				if ( lc($1) eq 'a' )
				{
					$interface->{interfaceEthernet}->{autoDuplex}        = 'true';
					$interface->{interfaceEthernet}->{operationalDuplex} = 'auto';
				}
				elsif ( lc($1) eq 'h' )
				{
					$interface->{interfaceEthernet}->{autoDuplex}        = 'false';
					$interface->{interfaceEthernet}->{operationalDuplex} = 'half';
				}
				elsif ( lc($1) eq 'f' )
				{
					$interface->{interfaceEthernet}->{autoDuplex}        = 'false';
					$interface->{interfaceEthernet}->{operationalDuplex} = 'full';
				}
			}
		}
		elsif ( $if_line =~ /\bMTU\s+(\d+)\s+bytes/i
			&& defined $interface->{name} )
		{
			$interface->{mtu} = $1;
			if ( $if_line =~ /\bInternet\s+address\s+is\s+($CIPM_RE)\/(\d+),/i )
			{
				my $precedence = 1;
				push @{ $interface->{interfaceIp}->{ipConfiguration} },
				  { ipAddress => $1, mask => $2, precedence => $precedence };
				my $subnet = new ZipTie::Addressing::Subnet( $1, $2 );
				push( @{ $subnets->{$interface->{name}} }, $subnet );
			}
		}

		# this parsing might be wrong because
		# of 'Not member of any active trunks'
		# line within interfaces output
		elsif ( $if_line =~ /^\s*Member\s+of\s+(\S+)\s+VLAN/i
			&& defined $interface->{name} )
		{
			push @{ $interface->{interfaceVlanTrunks} }, { startVlan => $1 };
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
	my $spanningTree;

	my ($gl_stp_params) = $in->{stp} =~ /^Global\s+STP\s+Parameters:(.+)Port\s+STP\s+Parameters:/mis;
	if ( $gl_stp_params =~ /^\s*[a-f0-9]{16}\s+(\d+)\s+(\d+)\s+([a-f0-9]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+\d+\s+\d+\s+([a-f0-9]{12})\s*$/mi )
	{
		my $root_cost  = $1;
		my $root_port  = $2;
		my $priority   = hex($3);
		my $maxage     = $4;
		my $hello      = $5;
		my $hold       = $6;
		my $forward    = $7;
		my $brd_addres = $8;

		my ($port_stp_params) = $in->{stp} =~ /^Port STP Parameters:(.+)$/mis;
		while ( $port_stp_params =~ /^\s*(\d+)\s+([a-f0-9]+)\s+(\d+)\s+(\S+)\s+\d+\s+(\d+)\s+([a-f0-9]{16})\s+([a-f0-9]{16})\s*$/mig )
		{
			if ( uc($4) eq 'FORWARDING' )
			{
				my $ds_root_port  = $1;
				my $ds_priority   = hex($2);
				my $path_cost     = $3;
				my $ds_cost       = $5;
				my $ds_root_mac   = $6;
				my $ds_brd_addres = $7;
				$ds_brd_addres =~ s/^[0-9a-f]{4}//i;
				$ds_root_mac   =~ s/^[0-9a-f]{4}//i;
				my $instance = {
					designatedRootPriority   => $ds_priority,
					designatedRootMacAddress => $ds_root_mac,
					designatedRootCost       => $ds_cost,
					designatedRootPort       => $ds_root_port,
					priority                 => $priority,
					systemMacAddress         => $brd_addres,
					helloTime                => $hello,
					maxAge                   => $maxage,
					forwardDelay             => $forward,
					holdTime                 => $hold,
					vlan                     => $root_port
				};
				push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
			}
		}
	}

	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
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

ZipTie::Adapters::Foundry::FastIron::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Foundry::FastIron::Parsers;
	parse_filters( $xmlPrinter, $cliResponses );	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
Foundry device responses and print out ZipTie model elements.

=head2 Methods

=over 12

=item C<create_config>

Uses the Foundry startup and running configs to put together a ZipTie
configurationRepository element.

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

  Contributor(s): -Z. Salinas
  Date: September 20, 2007

=cut
