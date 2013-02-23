package ZipTie::Adapters::Enterasys::VerticalHorizon::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number trim get_interface_type get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;

	$out->open_element("chassis");

	my $chassisAsset = { "core:assetType" => "Chassis", };
	if ( $in->{'system'} =~ /\bSystem Description\s+:\s+(\S.+)$/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'}	= trim($1);
		$chassisAsset->{'core:factoryinfo'}->{'core:make'}			= "Enterasys";
	}
	$out->print_element( "core:asset", $chassisAsset );

	if ( $in->{'system'} =~ /\bSystem Description\s+:\s+(\S.+)$/mi )
	{
		$out->print_element( 'core:description', trim($1) );
	}

	_parse_cards( $in, $out );

	$out->close_element("chassis");
}

sub _parse_cards
{
	my ( $in, $out ) = @_;

	my $card;
	my $slotNumber;
	while ( $in->{switch} =~ /^(.+)$/mig )
	{
		$_ = trim( $1 );
		if ( /^\s*$/ ) { next; } # skip empty lines
		if ( /<OK>/ ) { next; } # skip buttons

		$slotNumber = $1 if ( /Switch Information : Unit: (\d+)/ );

		if ( $_ !~ /:/ )
		{
			$out->print_element( "card", $card ) if ( $card->{"core:asset"}->{"core:location"}->{"core:description"} );
			$card															= undef;
			$card->{"core:asset"}->{"core:location"}->{"core:description"}	= $_;
			$card->{slotNumber}												= $slotNumber if ( $slotNumber );
			$card->{"core:asset"}->{"core:assetType"}						= "Card";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}		= 'Enterasys';
		}
		if ( $card->{"core:asset"}->{"core:location"}->{"core:description"} )
		{
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"}	= $1 if ( /Hardware Version\s+: V?([^\s\/]+)/i );
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:firmwareVersion"}	= $1 if ( /Firmware Version\s+: V?([^\s\/]+)/i );
			$card->{portCount}														= $1 if ( /Port Number\s+: (\d+)/i );
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"}		= $1 if ( /MainBoard Type\s+: (\S+)/i );
			if ( !$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} )
			{
				$card->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = 'Unknown';
			}
			#$card->{"core:description"}												= $1 if ( /MainBoard Type\s+: (\S+)/i );
		}
	}
	$out->print_element( "card", $card ) if ( $card->{location} );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{'system'} =~ /\bSystem Name\s+:\s+(\S.+)$/mi;
	$out->print_element( 'core:systemName', trim($systemName) );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Enterasys' );
	$out->print_element( 'core:name', 'VerticalHorizon' );
	if ( $in->{switch} =~ /Firmware Version\s+: V?([^\s]+)/mi )
	{
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'VerticalHorizon' );
	$out->close_element('core:osInfo');

	if ( $in->{switch} =~ /POST ROM Version\s+: V?([^\s\/]+)/mi)
	{
		$out->print_element( 'core:biosVersion', $1 );
	}
	$out->print_element( 'core:deviceType', 'Switch' );

	my ($contact) = $in->{'system'} =~ /\bSystem Contact\s+:\s+(\S.+)$/mi;
	$out->print_element( 'core:contact', trim($contact) );

	if ( $in->{'system'} =~ /\bSystem Up Time\s+:\s+(\d+)/mi )
	{
		$out->print_element( "core:lastReboot", $1 );
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
	$config->{'core:mediaType'}  = 'application/x-compressed';
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

	while ( $in->{snmp_communities} =~ /\s*\d\.\s+(\S+)\s+(READ ONLY|READ\/WRITE)\s+(\S+)\s+$/mig )
	{
		my $comm_str	= $1;
		my $access_type	= uc($2);
		if ( $access_type eq 'READ/WRITE' )
		{
			$access_type = 'RW';
		}
		else
		{
			$access_type = 'RO';
		}
		$out->print_element( "community", { communityString => $comm_str, accessType => $access_type } );
	}

	my $someSysPrinted = 0;
	if ( $in->{'system'} =~ /\bSystem Contact\s+:\s+(\S.+)$/mi )
	{
		$out->print_element( "sysContact", trim($1) );
		$someSysPrinted = 1;
	}
	if ( $in->{'system'} =~ /\bSystem Location\s+:\s+(\S.+)$/mi )
	{
		$out->print_element( "sysLocation", trim($1) );
		$someSysPrinted = 1;
	}
	if ( $in->{'system'} =~ /\bSystem Name\s+:\s+(\S.+)$/mi )
	{
		$out->print_element( "sysName", trim($1) );
		$someSysPrinted = 1;
	}

	if ($someSysPrinted)
	{
		my $cipm = get_crep('cipm');
		while ( $in->{snmp_traps} =~ /\s*\d\.\s+($cipm)\s+(\S+)/mig )
		{
			$out->print_element( "trapHosts", { ipAddress => $1, communityString => $2 } );
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

	while ( $in->{interfaces} =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+\S+\s+(\S+)\s*$/mig )
	{
		my $number			= $1;
		my $type			= $2;
		my $status			= lc($3);
		my $speed_duplex	= $4;
		my $speed			= 'auto';
		my $duplex			= 'auto';
		my $interface =
			{
				adminStatus			=> ( $status eq 'enabled' ? 'up' : 'down' ),
				name          		=> $number,
				interfaceType		=> 'ethernet',
				physical      		=> 'true',
				interfaceEthernet	=> { mediaType => $type },
			};
		if ( $speed_duplex =~ /^(\d+)_(HALF|FULL|AUTO)$/i )
		{
			$speed	= $1 * 1000 * 1000;
			$duplex	= lc($2);
		}
		if ( $speed eq 'auto' )
		{
			$interface->{interfaceEthernet}->{autoSpeed} = 'true';
		}
		else
		{
			$interface->{speed} = $speed;
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
		if ( $in->{ports_stp} =~ /^\s*$number\s+\S+\s+(\d+)\s+(\d+)\s+(\S+)/mi )
		{
			$interface->{interfaceSpanningTree}->{priority}	= $1;
			$interface->{interfaceSpanningTree}->{cost}		= $2;
			$interface->{interfaceSpanningTree}->{state}	= lc($3);
		}
		$out->print_element( "interface", $interface );
	}

	$out->close_element("interfaces");
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;
	my $instance;

	my $mac1	= get_crep('mac1');
	my $ins		= '\(in\s+seconds\)';
 
	$_			= $in->{'bridge_info'};
	if ( /
		Priority\s+					: \s+(\d+)\s+
		Hello\s+Time\s+$ins\s+		: \s+(\d+)\s+
		Max\s+Age\s+$ins\s+			: \s+(\d+)\s+
		Forward\s+Delay\s+$ins\s+	: \s+(\d+)\s+
		Hold\s+Time\s+$ins\s+		: \s+(\d+)\s+
		Designated\s+Root\s+		: \s+[a-f0-9]+\.($mac1)\s+
		Root\s+Cost\s+				: \s+(\d+)\s+
		Root\s+Port\s+				: \s+(\d+)\s+
		/mixs )
	{
		$instance->{designatedRootCost}			= $7;
		$instance->{designatedRootForwardDelay}	= $4;
		$instance->{designatedRootHelloTime}	= $2;
		$instance->{designatedRootMacAddress}	= $6;
		$instance->{designatedRootMaxAge}		= $3;
		$instance->{designatedRootPort}			= $8;
		$instance->{designatedRootPriority}		= $1;
	}
	#if ( $in->{'bridge_info'} )
	#{
	#	$instance->{designatedRootCost}			= $1 if ( $in->{'bridge_info'} =~ /\bRoot Cost\s+:\s+(\d+)/mi );
	#	$instance->{designatedRootForwardDelay}	= $1 if ( $in->{'bridge_info'} =~ /\bForward Delay \(in seconds\)\s+:\s+(\d+)/mi );
	#	$instance->{designatedRootHelloTime}	= $1 if ( $in->{'bridge_info'} =~ /\bHello Time \(in seconds\)\s+:\s+(\d+)/mi );
	#	$instance->{designatedRootMacAddress}	= $1 if ( $in->{'bridge_info'} =~ /\bDesignated Root\s+:\s+[a-f0-9]+\.($mac1)/mi );
	#	$instance->{designatedRootMaxAge}		= $1 if ( $in->{'bridge_info'} =~ /\bMax Age \(in seconds\)\s+:\s+(\d+)/mi );
	#	$instance->{designatedRootPort}			= $1 if ( $in->{'bridge_info'} =~ /\bRoot Port\s+:\s+(\d+)/mi );
	#	$instance->{designatedRootPriority}		= $1 if ( $in->{'bridge_info'} =~ /\bPriority\s+:\s+(\d+)/mi );
	#}
	$_ = $in->{'bridge_conf'};
	if ( /
		Spanning\s+Tree\s+Protocol\s+	: \s+\S+\s+

		Priority\s+						: \s+(\d+)\s+

		Hello\s+Time\s+$ins\s+			: \s+(\d+)\s+

		Max\s+Age\s+$ins\s+				: \s+(\d+)\s+

		Forward\s+Delay\s+$ins\s+		: \s+(\d+)\s+
		/mixs )
	{
		$instance->{forwardDelay}	= $4;
		$instance->{helloTime}		= $2;
		$instance->{maxAge}			= $3;
		$instance->{priority}		= $1;
	}
	#if ( $in->{'bridge_conf'} )
	#{
	#	$instance->{forwardDelay}	= $1 if ( $in->{'bridge_conf'} =~ /\bForward Delay \(in seconds\)\s+:\s+(\d+)/mi );
	#	$instance->{helloTime}		= $1 if ( $in->{'bridge_conf'} =~ /\bHello Time \(in seconds\)\s+:\s+(\d+)/mi );
	#	$instance->{maxAge}			= $1 if ( $in->{'bridge_conf'} =~ /\bMax Age \(in seconds\)\s+:\s+(\d+)/mi );
	#	$instance->{priority}		= $1 if ( $in->{'bridge_conf'} =~ /\bPriority\s+:\s+(\d+)/mi );
	#}

	push( @{ $spanningTree->{spanningTreeInstance} }, $instance ) if ( $instance );
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
}

1;
