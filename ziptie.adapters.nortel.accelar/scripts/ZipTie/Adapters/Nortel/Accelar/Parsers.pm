package ZipTie::Adapters::Nortel::Accelar::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type strip_mac);
use MIME::Base64 'encode_base64';

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

use Exporter 'import';
our @EXPORT_OK =
  qw( create_config parse_local_accounts parse_chassis parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
  
our $CIPM_RE	= '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
our $MAC 	= '[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}\:[0-9a-f]{2}';

sub parse_chassis
{
	my ( $in, $out ) = @_;
	
	$out->open_element("chassis");
	$out->open_element("core:asset");
		
	$out->print_element("core:assetType", "Chassis");
	my ($unparsedNumbers) = $in->{system} =~ /Chassis Info\s*:\s+(.*)Power Supply/mis;

	# get serial number
	
	$out->open_element('core:factoryinfo');
	$out->print_element('core:make', "Nortel");
	$out->print_element('core:modelNumber', "1200");
	if ( $unparsedNumbers =~ /HwRev\s+:\s+(\S+)\s*$/mi)
	{
		$out->print_element('core:revisionNumber', $1);
	}
	if ( $unparsedNumbers =~ /Serial#\s*:\s*(\S+)/mi )
	{
		$out->print_element('core:serialNumber', $1);
	}

	$out->close_element('core:factoryinfo');
	
	my ($location) = $in->{system} =~ /SysLocation\s*:\s*(.+)$/migc;
	$out->open_element('core:location');
	$out->print_element('core:description', $location);
	$out->close_element('core:location');
	
	$out->close_element('core:asset');

	_parse_cards( $in, $out );

	_parse_file_storage( $in, $out );

	_parse_power_supply( $in, $out );
	
	$out->close_element("chassis");
}

sub _parse_cards
{

	# populate the card elements of the chassis
	my ( $in, $out ) = @_;

	if ( defined $in->{system} )
	{
		my ($blob) = $in->{system} =~ /Card info :.*?Status\s+(.*)\s+System Error Info/mis;
		
		while ( $blob =~ /^\s*(\d+)\s+(\d+)x(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\w+).*$/mig )
		{
			my $no        = $1;
			my $portCount = $2;
			my $card      = {
				slotNumber         => $no,
				portCount          => $portCount,
				status						 => $7,
				"core:description" => $3,
			};

			my $partNumber  = $4;
			my $serialNumber = $5;
			$card->{"core:description"} =~ s/\s+$//;

			$card->{"core:asset"}->{"core:assetType"} = "Card";
			$card->{"core:asset"}->{"core:factoryinfo"}->{'core:make'} = "Nortel";
	    $card->{"core:asset"}->{"core:factoryinfo"}->{'core:modelNumber'} =  "1200";
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} = $partNumber;
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $serialNumber;

			# now get the HW version
			$card->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = $6;
					
			$out->print_element( "card", $card );
		}
	}
}

sub _parse_file_storage
{

	# populate the deviceStorage elements of the chassis
	my ( $in, $out ) = @_;
	return if ( !defined $in->{files} );

	if ( $in->{files} !~ /not found/mi )
	{
		#just to be safe, reset \G to zero
		pos($in->{files}) = 0;
		my $storage;
		while ( $in->{files} =~ /^\s*Device:\s+(\w+)\s*$/migc ) 
		{
			
			$storage->{name}        = $1;
			$storage->{storageType} = $1;
			$storage->{rootDir} = { name => "root" };
			
			my ($blob) = $in->{files} =~ /\G(.*)/miscg;

			while ( $blob =~ /^\s*\d+\s+(\S+)\s+[CXZDLNTS]+\s+(\d+)\s*$/mig )
			{
				my $file = {
					size => $2,
					name => $1,
				};
				push( @{ $storage->{rootDir}->{file} }, $file );
			}
			my ($used,$freeSpace) = $blob =~ /bytes used=\s*(\d+)\s+free=\s*(\d+)/i;
			$storage->{freeSpace} = $freeSpace;
			$storage->{size} = $used + $freeSpace;
			$out->print_element( "deviceStorage", $storage );
		}
	}
}


sub _parse_power_supply
{
	my ( $in, $out ) = @_;

	my ($blob) = $in->{system} =~ /^\s*Power\s*Supply\s*Info\s*:\s*(.*)Fan Info :/mis; 
	
	while ( $blob =~ /Ps#(\d+)\s+Stat.*?:\s+(\w+)$/migc )
	{
		my $power_supply = { number => $1, status => $2, };
		
		next if  ($power_supply->{status} =~ /empty/i) ;
		
		if ( $blob =~ /type\s+:(.*)$/migc )
		{
			$power_supply->{'core:description'} = $1;
			$power_supply->{'core:description'} =~ s/\s+$//;
		}
		
		$power_supply->{"core:asset"}->{"core:assetType"} = "PowerSupply";
		if ( $blob =~ /Serial Number\s*:(.*)$/migc )
		{
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:serialNumber"} = $1;
			
		}
		if ($blob =~ /Version\s+:(.*)$/migc)
		{
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:hardwareVersion"} = $1;
		}
		
		$power_supply->{"core:asset"}->{"core:factoryinfo"}->{'core:make'} = "unknown";
		$power_supply->{"core:asset"}->{"core:factoryinfo"}->{'core:modelNumber'} =  "unknown";
		
		if ($blob =~ /Part Number\s+:(.*)$/migc)
		{
			$power_supply->{"core:asset"}->{"core:factoryinfo"}->{"core:partNumber"} = $1;
		}
		
		$out->print_element( "powersupply", $power_supply );
	}
}

sub parse_system
{
	my ( $in, $out ) = @_;
		
	my ($systemName) = $in->{system} =~ /SysName\s*:\s*(\S+)/mig;
	$out->print_element( 'core:systemName', "$systemName" );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Nortel' );
	
	if ( $in->{config} =~ /software version\s+:\s+(\S+)\s*$/mig )
	{
		$out->print_element( 'core:version', $1 );
	}
	else
	{
		$out->print_element( 'core:version', 'Unknown' );
	}
	
	$out->print_element( 'core:osType', 'Accelar' );
	$out->close_element('core:osInfo');

	if ( $in->{config} =~ /boot monitor version\s+:\s*(\S+)/mi )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	$out->print_element( 'core:deviceType', 'Router' );
	
	my ($contact) = $in->{system} =~ /SysContact\s*:\s*(.+)$/mig;
	$out->print_element( 'core:contact', $contact );

	# SysUpTime    : 248 day(s), 00:23:27
	if ( $in->{system} =~ /SysUpTime\s+:\s*?(?:(\d+) years,)?(?:\s*?(\d+) day\(s\),)?\s*?(\d+):(\d+):(\d+)\s*$/mig )
	{
		my ($years)   = $1;
		my ($days)    = $2;
		my ($hours)   = $3;	
		my ($minutes) = $4;
		my ($seconds) = $5;

		# subract the last reboot from the current time
		my $lastReboot = time();
		$lastReboot -= $years * 52 * 7 * 24 * 60 * 60 if ($years);
		$lastReboot -= $days * 24 * 60 * 60           if ($days);
		$lastReboot -= $hours * 60 * 60               if ($hours);
		$lastReboot -= $minutes * 60                  if ($minutes);
		$lastReboot -= $seconds												if ($seconds);
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
	my $config;
	$config->{'core:name'}       = 'config';
	$config->{'core:textBlob'}   = encode_base64( $in->{'config'} );
	$config->{'core:mediaType'}  = 'text/plain';
	$config->{'core:context'}    = 'active';
	$config->{'core:promotable'} = 'true';   
	
	push( @{ $repository->{'core:config'} }, $config );

	# print the repository
	$out->print_element( 'core:configRepository', $repository );
}

sub parse_local_accounts
{
	my ( $in, $out ) = @_;
	
	$out->open_element("localAccounts");

	my ($acc_blob) = $in->{accounts} =~/ACCESS\s+LOGIN\s+PASSWORD\s+(.+)$/mis;
	

	while ($acc_blob =~/\s*(\w+)\s+(\w+)\s+(\w+)\s*?$/migc)
	{
		$out->print_element( "localAccount", { accountName => $2, accessGroup => $1, password => $3 } );
	}
		
	
	$out->close_element("localAccounts");
}



sub parse_snmp
{
	my ( $in, $out ) = @_;
	
	my ($blob) = $in->{config} =~ /sys\s+set\s+(contact.*)back\s+syslog/mis;
	
	my $contact = undef;
	my $location = undef;
	my $name = undef;
	
	$out->open_element("snmp");
	
	if ($in->{system} =~ /SysName\s*:\s*(\S+)/mi)
	{
		$name = $1;
	}
	if ($blob =~ /contact\s+\"(.*)\"\s*$/migc)
	{
		$contact = $1;
	}
	if ($blob =~ /location\s+\"(.*)\"\s*$/migc)
	{
		$location = $1;
	}
	
	#extract the communities
	my $access;
	my $comm;
	while ( $blob =~  /\s+snmp\s+community\s+(\w+)\s+(\w+)\s*$/migc )
	{
		$comm = $2;
		if ($1 =~ /rw|l2|l3|rwa/)
		{
			$access = 'RW';
		}
		else
		{
			$access = 'RO';
		}
		$out->print_element( "community", { communityString => $comm, accessType => $access } );
	}
	
	if ($contact)
	{
		$out->print_element( "sysContact", $contact);
	}
	
	if ($location)
	{
		$out->print_element( "sysLocation", $location );
	}
	
	if($name)
	{
		$out->print_element( "sysName", $name );
	}
	else
	{
		$out->print_element( "sysName", "unknown" );
	}
	$out->close_element("snmp");
		
	
}

sub parse_static_routes
{
	my ( $in, $out ) = @_;
	
	my $staticRoutes;
	
	my ($blob) = $in->{routes} =~ /Ip Route\s+=+.*owner\s+-+(.*?)Total/mis;
	
	while ($blob =~ /\s*($CIPM_RE)\s+($CIPM_RE)\s+($CIPM_RE)\s+(\d+)\s+\d+\s+((?:\d+|-)\/(?:\d+|-))\s+.+$/mig)
	{
		#set ip route destination[/netmask] gateway metric
		my $route = {
			destinationAddress => $1,
			destinationMask    => mask_to_bits ( $2 ),
			gatewayAddress     => $3,
			routeMetric 	   => $4,
			interface          => $5
		};
		
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

sub parse_interfaces
{
	my ( $in, $out ) = @_;
  
  my ($blob) = $in->{interfaces} =~ /MAXSIZE[\s|-]+(.*)$/mis;
  
  $out->open_element("interfaces");
  while( $blob =~ /^\s*(\S+)\s+($CIPM_RE)\s+($CIPM_RE).+$/mig )
  {
  	
  	my ($phys,$type);
  	$type = get_interface_type($1);
  	my $interface = {
				name		=> $1,
				interfaceType	=> $type,
			};
		$interface->{interfaceIp}->{ipConfiguration}->{ipAddress} = $2;
		$interface->{interfaceIp}->{ipConfiguration}->{mask} = mask_to_bits($3);
		
  	$phys = $1;
  	if ($phys =~ /vlan/mi) 
  	{
  		$phys = 'false';
  	}
  	else
  	{
  		$phys = "true";
  	}
  	
  	$interface->{physical} = $phys;

		$out->print_element( "interface", $interface );  	
	}
	
	$out->close_element("interfaces");
}

sub parse_stp
{
	my ( $in, $out ) = @_;
	
	my ($blob11, $blob12) = $in->{stp1} =~ /stg config.*stp\s+trap[\s|-]+(.*)\s+stg\s+taggbpdu.*vlan_id\s+member[\s|-]+(.*)$/mis;
	my ($blob21, $blob22) = $in->{stp2} =~ /stg status.*specification\s+changes[\s|-]+(.*)\s+stg\s+designated.*time\s+delay[\s|-]+(.*)$/mis;
	
	my $instance;
	my $spanningTree;
	
	while ( $blob11 =~ /\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+).*$/migc )
	{
		#first, save all captures, as next matches will write on $1,$2...
		my ($id, $priority, $max_age, $hello, $fwd_delay) = ($1,$2,$3,$4,$5);
		
		my ($id2, $vlan) = $blob12 =~ /\s*(\d+)\s+$MAC\s+(\d+).*$/migc;
		
		my ($id3, $sys_mac) = $blob21 =~ /\s*(\d+)\s+($MAC).*$/migc;
		
		my ($id4, $rt_mac, $rt_cost, $rt_port, $rt_age, $rt_hello, $hold, $rt_fwd_delay) =	$blob22 =~ /\s*(\d+)\s+($MAC)\s+(\d+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/migc;
		
		unless ( ($id == $id2) && ($id == $id3) && ($id == $id4) )
		{
			$LOGGER->fatal("Corrupt information received from device's STP configuration");
		}
		
		$instance->{priority} = $priority;
		$instance->{helloTime} = $hello;
		$instance->{maxAge} = $max_age;
		$instance->{forwardDelay} = $fwd_delay;
		$instance->{vlan} = $vlan;
		$instance->{systemMacAddress} = strip_mac($sys_mac);
		$instance->{holdTime} = $hold;
		
		$instance->{designatedRootMacAddress} = strip_mac($rt_mac);
		$instance->{designatedRootCost} = $rt_cost;
		$instance->{designatedRootPort} = $rt_port;
		$instance->{designatedRootHelloTime} = $rt_hello;
		$instance->{designatedRootForwardDelay} = $rt_fwd_delay;
		$instance->{designatedRootMaxAge} = $rt_age;
		
		
		
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
	}
	
	
	$out->print_element( "spanningTree", $spanningTree ) if ($spanningTree);
	
}

sub parse_vlans
{
	my ( $in, $out ) = @_;
	
	$out->open_element("vlans");
	
	while( $in->{vlans} =~ /^\s*(\d+)\s+(\w+)\s+(\w+).*$/migc )
	{
		$out->open_element("vlan");
		$out->print_element("enabled", "true");
		$out->print_element("implementationType", $3);
		$out->print_element("name",$2);
		$out->print_element("number", $1);
		$out->close_element("vlan");
	}
	
	$out->close_element("vlans");
	
}

1;
