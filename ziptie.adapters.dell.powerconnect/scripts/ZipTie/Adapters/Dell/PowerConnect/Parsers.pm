package ZipTie::Adapters::Dell::PowerConnect::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep strip_mac);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = "Dell";
	if ( $in->{'system'} =~ /System Description:\s+(\b.+\b)/i)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	if ( $in->{version} =~ /^HW version\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:hardwareVersion'} = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );

	if ( $in->{'running-config'} =~ /^description \"([^\"]+)\"/mi )
	{
		$out->print_element( "core:description", $1 );
	}

	if ( $in->{'system'} =~ /^\s*(\S.+)(?=unit)/mi )
	{
		my $power_supply;
		$_							 = trim($1);
		($power_supply->{number})	 = $in->{'system'} =~ /\s*Power.+unit(\d+)/mi;
		$power_supply->{status}		 = 'ok';
		$power_supply->{'core:description'} = $_;
		#$power_supply->{"core:asset"}->{"core:assetType"} = "PowerSupply";
		$out->print_element( "powersupply", $power_supply );
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{'running-config'} =~ /^hostname (\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	$out->open_element('core:osInfo');
	$out->print_element('core:make', 'Dell');
	$out->print_element( 'core:name', 'PowerConnect');
	if ( $in->{version} =~ /\bSW version\s+(\S+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'PowerConnect' );
	$out->close_element('core:osInfo');

	if ( $in->{version} =~ /^Boot version\s+(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Switch' );

	if ( $in->{'running-config'} =~ /^snmp-server contact (.+)$/mi )
	{
		$out->print_element( 'core:contact', trim($1) );
	}

	if ( $in->{'system'} =~ /^System Up Time \(days,hour:min:sec\):\s+(\d+),(\d{1,2}):(\d{1,2}):(\d{1,2})/mi )
	{
		$_ = $1;
		my ($years);
		my ($weeks);
		my ($hours)		= '';
		my ($minutes)	= '';
		my ($days)		= /(\d+)/;

		#my $timezone	= 'CST';

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

	# build the simple text configuration
	my $rconfig;
	$rconfig->{'core:name'}       = 'running-config';
	$rconfig->{'core:textBlob'}   = encode_base64( $in->{'running-config'} );
	$rconfig->{'core:mediaType'}  = 'text/plain';
	$rconfig->{'core:context'}    = 'active';
	$rconfig->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $rconfig );

	# build the simple text configuration
	my $sconfig;
	$sconfig->{'core:name'}       = 'startup-config';
	$sconfig->{'core:textBlob'}   = encode_base64( $in->{'startup-config'} );
	$sconfig->{'core:mediaType'}  = 'text/plain';
	$sconfig->{'core:context'}    = 'boot';
	$sconfig->{'core:promotable'} = 'true';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $sconfig );

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

	while ( $in->{'running-config'} =~ /^username (\S+) password (\S+)(?: level (\d+))? encrypted\s*$/mig )
	{
		my $account =
		{
			accountName => $1,
			password => $2,
		};
		if ( defined $3 )
		{
			$account->{accessLevel} = $1 if ( $3 =~ /^(\d+)$/ );
		}
		$out->print_element( "localAccount", $account );
	}
	if ( $in->{'running-config'} =~ /^enable password level (\d+) (\S+) encrypted\s*$/mi )
	{
		$out->print_element( "localAccount", { accountName => 'enable', password => $2, accessLevel => $1 } );
	}

	$out->close_element("localAccounts");
}

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_snmp
{
	my ( $in, $out ) = @_;

	$out->open_element("snmp");

	my $trapsHosts;
	my $cipm = get_crep('cipm');
	my $sysLocation;
	my $sysContact;
	while ( $in->{'running-config'} =~ /^snmp-server (\S+) (\S.+)$/mig )
	{
		my $snmpCommand = $1;
		my $snmpBlob	= trim($2);
		if ( $snmpCommand =~ /host/i )
		{
			if ( $snmpBlob =~ /($cipm)\s+(\S+)/i )
			{
				push @{$trapsHosts}, { communityString => $2 , ipAddress => $1 };
			}
		}
		elsif ( $snmpCommand =~ /location/i )
		{
			$sysLocation = trim($snmpBlob);
		}
		elsif ( $snmpCommand =~ /contact/i )
		{
			$sysContact = trim($snmpBlob);
		}
		elsif ( $snmpCommand =~ /community/i )
		{
			if ( $snmpBlob =~ /(\S+) (su|rw|)?/i )
			{
				$_ = $1;
				if ( $2 =~ /(su|rw)/ )
				{
					$out->print_element( "community", { communityString => $_ , accessType => 'RW' } );
				}
				else
				{
					$out->print_element( "community", { communityString => $_ , accessType => 'RO' } );
				}
			}
		}
	}

	my $someSysPrinted = 0;
	if ( $sysContact )
	{
		$out->print_element( "sysContact", $sysContact );
		$someSysPrinted = 1;
	}
	if ( $sysLocation )
	{
		$out->print_element( "sysLocation", $sysLocation );
		$someSysPrinted = 1;
	}
	if ( $in->{'running-config'} =~ /^hostname (\S+)/mi )
	{
		$out->print_element( "sysName", $1 );
		$someSysPrinted = 1;
	}

	if ( $someSysPrinted )
	{
		foreach (@{$trapsHosts})
		{
			$out->print_element( "trapHosts", $_ );
		}
	}

	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	$out->open_element("interfaces");

	while ( $in->{interfaces} =~ /^(\d\/\S+)\s+(\S+)\s+(Full|Half|Auto)\s+(\S+)\s+\S+\s+\S+\s+(\S+)\s+\S+\s+\S+\s*$/mig )
	{
		my $mType	= $2;
		my $duplex	= lc($3);
		my $speed	= $4;
		my $interface =
		{
			adminStatus	 	  => lc($5),
			name          	  => $1,
			interfaceType 	  => 'ethernet',
			physical     	  => _is_physical($1),
		};
		if ( $speed =~ /^\d+$/ )
		{
			$interface->{speed} = $speed;
		}
		if ( $mType !~ /^[-\s]+$/ )
		{
			$interface->{interfaceEthernet}->{mediaType} = $mType;
		}
		if ( $duplex eq 'auto' )
		{
			$interface->{interfaceEthernet}->{autoDuplex} = 'true';
		}
		else
		{
			$interface->{interfaceEthernet}->{autoDuplex}			= 'false';
			$interface->{interfaceEthernet}->{operationalDuplex}	= $duplex;
		}
		$_ = $interface->{name};
		if ( $in->{stp} =~ /^\s*$_\s+(\d+)\s+(\S+)\s+\S+\s+(\d+)/mi )
		{
			my $if_stp =
			{
				cost		=> $3,
				priority	=> $1,
			};
			$_ = $2;
			if ( /FRW/i )
			{
				$if_stp->{state} = 'forwarding';
			}
			elsif ( /DSBL/i )
			{
				$if_stp->{state} = 'disabled';
			}
			$interface->{interfaceSpanningTree} = $if_stp;
		}
		$out->print_element( "interface", $interface );
	}

	while ( $in->{interfaces} =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(?:Enabled|Disabled)\s+\S+\s+(\S+)\s+(?:Enabled|Disabled)\s*$/mig )
	{
		my $mType	= $2;
		my $speed	= $3;
		my $interface =
		{
			adminStatus	 	  => lc($4),
			name          	  => $1,
			interfaceType 	  => 'other',
			physical     	  => _is_physical($1),
		};
		if ( $speed =~ /^\d+$/ )
		{
			$interface->{speed} = $speed;
		}
		if ( $mType !~ /^[-\s]+$/ )
		{
			$interface->{interfaceEthernet}->{mediaType} = $mType;
		}
		$_ = $interface->{name};
		if ( $in->{stp} =~ /^\s*$_\s+(\d+)\s+(\S+)\s+\S+\s+(\d+)/mi )
		{
			my $if_stp =
			{
				cost		=> $3,
				priority	=> $1,
			};
			$_ = $2;
			if ( /FRW/i )
			{
				$if_stp->{state} = 'forwarding';
			}
			elsif ( /DSBL/i )
			{
				$if_stp->{state} = 'disabled';
			}
			$interface->{interfaceSpanningTree} = $if_stp;
		}
		$out->print_element( "interface", $interface );
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;

	my $vlansOpened;
	while ( $in->{vlans} =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+\S+\s*$/mig )
	{
		if ( !$vlansOpened )
		{
			$out->open_element("vlans");
			$vlansOpened = 1;
		}
		my $vlan =
		{
			number	=> $1,
			name	=> $2,
			enabled	=> 'true',
		};
		my @ports	= split( /,/, $3 );
		foreach ( @ports )
		{
			if ( /(^[^\s\(]+)\((\d+)-(\d+)/ )
			{
				foreach ( $2..$3 )
				{
					push @{$vlan->{interfaceMember}}, $1.$_;
				}
			}
 		}
		$out->print_element( "vlan", $vlan ); 
	}

	if ( $vlansOpened )
	{
		$out->close_element("vlans");
	}
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;

	my ($rootBlob)		= $in->{stp} =~ /Spanning tree enabled mode STP(.+)Bridge ID/mis;
	my ($bridgeBlob)	= $in->{stp} =~ /Bridge ID(.+)Number of topology changes/mis;

	if ( $rootBlob && $bridgeBlob )
	{
		my $instance;
		if ( $bridgeBlob =~ /Hello Time\s+(\d+) sec\s+Max Age\s+(\d+) sec\s+Forward Delay\s+(\d+) sec/mi )
		{
			$instance->{designatedRootForwardDelay}	= $3;
			$instance->{designatedRootHelloTime}	= $1;
			$instance->{designatedRootMaxAge}		= $2;
		}
		if ( $bridgeBlob =~ /Priority\s+(\d+)/mi )
		{
			$instance->{designatedRootPriority} = $1;
		}
		$_ = get_crep('mac2');
		if ( $bridgeBlob =~ /Address\s+($_)/mi )
		{
			$instance->{designatedRootMacAddress} = strip_mac($1);
		}
		if ( $rootBlob =~ /Hello Time\s+(\d+) sec\s+Max Age\s+(\d+) sec\s+Forward Delay\s+(\d+) sec/mi )
		{
			$instance->{forwardDelay}	= $3;
			$instance->{helloTime}	= $1;
			$instance->{maxAge}		= $2;
		}
		if ( $rootBlob =~ /Priority\s+(\d+)/mi )
		{
			$instance->{priority} = $1;
		}
		$_ = get_crep('mac2');
		if ( $rootBlob =~ /Address\s+($_)/mi )
		{
			$instance->{systemMacAddress} = strip_mac($1);
		}
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

1;
