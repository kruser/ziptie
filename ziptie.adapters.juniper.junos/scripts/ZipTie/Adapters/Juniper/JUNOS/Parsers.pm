package ZipTie::Adapters::Juniper::JUNOS::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils
  qw(seconds_since_epoch strip_mac get_mask get_port_number trim get_interface_type getUnitFreeNumber);
use XML::Twig;
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_discovery_neighbors parse_routing_neighbors parse_arp parse_telemetry_interfaces parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces);

sub parse_discovery_neighbors
{
	my ( $in, $out ) = @_;
	my $opened = 0;
	while ( $in->{ndp} =~ /^([a-f:\d]+)\s+([a-f:\d]+)\s+\S+\s+\d+\s+\S+\s+(\S+)/mig )
	{
		$out->open_element('discoveryProtocolNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol       => 'NDP',
			ipAddress      => $1,
			macAddress     => strip_mac($2),
			localInterface => $3,
		};
		$out->print_element( 'discoveryProtocolNeighbor', $neighbor );
	}
	$out->close_element('discoveryProtocolNeighbors') if ($opened);
}

sub parse_routing_neighbors
{
	my ( $in, $out ) = @_;
	my $opened = 0;
	while ( $in->{ospf} =~ /^([\da-f.:]+)\s+(\S+)\s+\S+\s+([\da-f.:]+)\s+\d+\s+\d+\s*$/gm )
	{
		$out->open_element('routingNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol  => 'OSPF',
			routerId  => $3,
			ipAddress => $1,
			interface => $2,
		};
		$out->print_element( 'routingNeighbor', $neighbor );
	}
	while ( $in->{bgp} =~ /^\s*Peer\s+ID:\s+([\da-f.:]+)\s+Local\s+ID:\s+([\da-f.:]+)/gm )
	{
		$out->open_element('routingNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol  => 'BGP',
			routerId  => $2,
			ipAddress => $1,
		};
		$out->print_element( 'routingNeighbor', $neighbor );
	}
	while ( $in->{rip} =~ /^\s*(\S+)\s+\S+\s+([\da-f.:]+)\s+([\da-f.:]+)\s+/gm )
	{
		$out->open_element('routingNeighbors') if ( !$opened );
		$opened = 1;
		my $neighbor = {
			protocol  => 'RIP',
			routerId  => $2,
			ipAddress => $3,
			interface => $1,
		};
		$out->print_element( 'routingNeighbor', $neighbor );
	}
	$out->close_element('routingNeighbors') if ($opened);
}

sub parse_arp
{
	my ( $in, $out ) = @_;
	$out->open_element('arpTable');
	while ( $in->{arp} =~ /^([\da-f.:]{17})\s+([\da-f.:]+)\s+(\S+)/mg )
	{
		my $arp = {
			ipAddress  => $2,
			macAddress => strip_mac($1),
			interface  => $3,
		};
		$out->print_element( 'arpEntry', $arp );
	}
	$out->close_element('arpTable');
}

sub parse_telemetry_interfaces
{

	# creates the ZipTie interfaces model by reading the Juniper interface-information
	# XML with XML::Twig and then traversing the twigs.  This could be streamlined
	# by reading only physical-interface blocks at a time and using a twig callback
	# to a method that parses that single interface
	my ( $in, $out ) = @_;
	my $interfaces;
	
	my ($intSection) = $in->{interfaces} =~ /(<interface-information.+<\/interface-information>)/s;
	my $interfacesTwig = XML::Twig->new();
	$interfacesTwig->parse($intSection);
	undef $intSection;

	foreach my $physicalInt ( $interfacesTwig->descendants('physical-interface') )
	{
		my $name       = $physicalInt->first_child('name')->text();
		my $operStatus = lc( $physicalInt->first_child('oper-status')->text() );
		my $type       = _get_interface_type( $physicalInt->first_child('if-type') );
		
		my $trafficStatsElement = $physicalInt->first_child('traffic-statistics');
		my $inputBytes = 0;
		if (defined $trafficStatsElement)
		{
			my $inputPacketsElement = $trafficStatsElement->first_child('input-packets');
			if (defined $inputPacketsElement)
			{
				$inputBytes = $inputPacketsElement->text();
			}
		}

		my $majorInt = {
			name       => $name,
			operStatus => ucfirst($operStatus),
			type       => $type,
			inputBytes => $inputBytes,
		};

		push( @{ $interfaces->{interface} }, $majorInt );

		foreach my $logicalInt ( $physicalInt->descendants('logical-interface') )
		{
			my $subName = $logicalInt->first_child('name')->text() if ( $logicalInt->first_child('name') );
			next if ( !$subName );
			my $subInt = {
				name       => $subName,
				operStatus => ucfirst($operStatus),
				type       => $type,
				inputBytes => 0,
			};

			foreach my $fam ( $logicalInt->descendants('address-family') )
			{
				foreach my $addr ( $fam->descendants('interface-address') )
				{
					my $ip = new Net::IP($addr->first_child('ifa-local')->text());
					if (defined $ip)
					{
						my $ipConfiguration = { "ipAddress" => $ip->ip(), };
						if ( defined $addr->first_child('ifa-destination') )
						{
							my ($mask) = $addr->first_child('ifa-destination')->text() =~ /\/(\d+)/;
							$ipConfiguration->{mask} = $mask;
						}
						push( @{ $subInt->{"ipEntry"}}, $ipConfiguration );
					}
				}
			}
			push( @{ $interfaces->{interface} }, $subInt );
		}
	}
	$out->print_element( 'interfaces', $interfaces );
	return $interfaces;
}

sub parse_routing
{

	# process BGP configuration data
	my ( $in, $out ) = @_;
	my ($bgpSection) = $in->{showBgp} =~ /(<bgp-information.+<\/bgp-information>)/s;
	if ($bgpSection)
	{
		my $twig = XML::Twig->new();
		$twig->parse($bgpSection);
		undef $bgpSection;

		my $bgp;
		foreach my $peerElement ( $twig->descendants('bgp-peer') )
		{
			if ( !$bgp->{routerId} )
			{
				my $routerId = $peerElement->first_child('local-address')->text();
				$routerId =~ s/\+\d+$//;
				$bgp->{routerId} = $routerId;
			}
			$bgp->{asNumber} = $peerElement->first_child('local-as')->text() if ( !$bgp->{asNumber} );

			my $neighbor = {
				address  => $peerElement->first_child('peer-address')->text(),
				asNumber => $peerElement->first_child('peer-as')->text(),
			};
			$neighbor->{address} =~ s/\+\d+$//;    # strip trailing digits after the +
			push( @{ $bgp->{neighbor} }, $neighbor );
		}

		if ($bgp)
		{
			$out->open_element('routing');
			$out->print_element( 'bgp', $bgp );
			$out->close_element('routing');
		}
	}
}

sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element('chassis');
	my $chassisAsset;
	$chassisAsset = { 'core:assetType' => 'Chassis', };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'} = 'Juniper';
	if ( $in->{showVer} =~ /^\s*Model:\s+(\S+)/im )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}

	my @powerSupplies;
	my @cards;
	my @cpus;

	my ($hardwareSection) = $in->{showHardware} =~ /(<chassis[\s|>].+<\/chassis>)/s;
	if ($hardwareSection)
	{
		my $twig = XML::Twig->new();
		$twig->parse($hardwareSection);
		undef $hardwareSection;

		my $rootElement = $twig->root();
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $rootElement->first_child('serial-number')->text();
		$out->print_element( 'core:asset',       $chassisAsset );
		$out->print_element( 'core:description', $rootElement->first_child('description')->text() );

		foreach my $chassisModule ( $rootElement->descendants('chassis-module') )
		{
			my $name   = $chassisModule->first_child('name')->text();
			my $module = {};
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}            = 'Juniper';
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'}     = 'Unknown';
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:hardwareVersion'} =
			  $chassisModule->first_child('version')->text()
			  if ( defined $chassisModule->first_child('version') );
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:partNumber'} =
			  $chassisModule->first_child('part-number')->text()
			  if ( defined $chassisModule->first_child('part-number') );
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} =
			  $chassisModule->first_child('serial-number')->text()
			  if ( defined $chassisModule->first_child('serial-number') );
			$module->{'core:description'} = $chassisModule->first_child('description')->text()
			  if ( defined $chassisModule->first_child('description') );

			#These two are mandatory and we don't know their value
			#so we are giving these default values
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = "Juniper";
			$module->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = "Unknown";

			if ( $name =~ /Power\s+Supply\s+(\S)/i )
			{
				my $number = ord($1) - 64;
				$module->{'core:asset'}->{'core:assetType'} = "PowerSupply";
				$module->{number} = $number;
				push( @powerSupplies, $module );
			}
			elsif ( $name =~ /^FPC\s+(\d+)/ )
			{
				$module->{'core:asset'}->{'core:assetType'} = "Card";
				$module->{'slotNumber'} = $1;

				# daughter cards
				foreach my $daughterCard ( $chassisModule->descendants('chassis-sub-module') )
				{
					my $name = $daughterCard->first_child('name')->text();
					my $dc   = {};
					$dc->{'core:asset'}->{'core:assetType'}                             = "Card";
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}            = 'Juniper';
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'}     = 'Unknown';
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:hardwareVersion'} =
					  $daughterCard->first_child('version')->text()
					  if ( defined $daughterCard->first_child('version') );
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:partNumber'} =
					  $daughterCard->first_child('part-number')->text()
					  if ( defined $daughterCard->first_child('part-number') );
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:serialNumber'} =
					  $daughterCard->first_child('serial-number')->text()
					  if ( defined $daughterCard->first_child('serial-number') );
					$dc->{'core:description'} = $daughterCard->first_child('description')->text()
					  if ( defined $daughterCard->first_child('description') );

					#These two are mandatory and we don't know their value
					#so we are giving these default values
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = "Juniper";
					$dc->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = "Unknown";

					if ( $name =~ /(\d+)$/ )
					{
						$dc->{'slotNumber'} = $1;
					}

					push( @{ $module->{daughterCard} }, $dc );
				}
				push( @cards, $module );
			}
			elsif ( $name =~ /^FEB/ )
			{
				$module->{'core:asset'}->{'core:assetType'} = "CPU";
				push( @cpus, $module );
			}
		}
	}

	foreach (@cards)
	{
		$out->print_element( "card", $_ );
	}
	foreach (@cpus)
	{
		$out->print_element( "cpu", $_ );
	}

	if ( $in->{showMAC} =~ /Public base address\s+((?:\w{2}\:){5}\w{2})/ )
	{
		my $mac = strip_mac($1);
		$out->print_element( "macAddress", $mac );
	}

	if ( $in->{showRen} =~ /^\s*DRAM\s+(\d+)\s+(\S+)/mi )
	{
		my $memory = {
			"core:description" => "RAM",
			kind               => "RAM",
			size               => getUnitFreeNumber( $1, $2, 'byte' ),
		};
		$out->print_element( "memory", $memory );
	}

	# print power supply elements where they are expected by the XSD
	foreach (@powerSupplies)
	{
		$out->print_element( "powersupply", $_ );
	}

	$out->close_element("chassis");
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{showVer} =~ /^\s*Hostname:\s+(\S+)/im )
	{
		$out->print_element( "core:systemName", $1 );
	}
	elsif ( $in->{snmp} =~ /<system-name>(.*)<\/system-name>/im )
	{
		$out->print_element( "core:systemName", $1 );
	}

	$out->open_element('core:osInfo');

	if ( $in->{showFirmware} =~ /Juniper ROM Monitor Version\s(\d+\.\w+)/s )
	{
		$out->print_element( "core:fileName", $1 );
	}

	if ( $in->{showVer} =~ /^\s*JUNOS (Base OS Software Suite|Software Release) \[(.*)\]/im )
	{
		$out->print_element( 'core:make',    'Juniper' );
		$out->print_element( 'core:version', $2 );
		$out->print_element( 'core:osType',  'JUNOS' );
	}

	$out->close_element('core:osInfo');

	# Version extracted from show version command
	# Ex: JUNOS Base OS boot [7.0R2.7]
	if ( $in->{showVer} =~ /OS\s[Bb]oot\s+\[(\d+\.\S+)\]/ )
	{
		$out->print_element( "core:biosVersion", $1 );
	}

	# Parse device type from "show snmp mib walk system", but default to "Router" if no match is found
	if ( $in->{showMibSystem} =~ /^sysDescr.*Juniper\s*Networks.*ex\d+/mi )
	{
		$out->print_element( "core:deviceType", "Switch" );
	}
	else
	{
		$out->print_element( "core:deviceType", "Router" );
	}

	# System booted: 2007-03-08 10:09:09 CST (6w6d 03:03 ago)
	if ( $in->{showUptime} =~ /^System booted:\s+(\d+)-(\d+)-(\d+)\s+(\d{1,2}:\d{1,2}:\d{1,2})\s+(\S+)/mi )
	{
		my $year     = $1;
		my $month    = $2;
		my $day      = $3;
		my $time     = $4;
		my $timezone = $5;
		my ( $hour, $min, $sec ) = $time =~ /(\d+):(\d+):(\d+)/;
		$out->print_element( "core:lastReboot",
			seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
	}

}

sub create_config
{

	# Populates the configuration entity for the main Juniper config
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $candidate;
	$candidate->{"core:name"}       = "candidate-config";
	$candidate->{"core:textBlob"}   = encode_base64( $in->{"candidate"} );
	$candidate->{"core:mediaType"}  = "text/plain";
	$candidate->{"core:context"}    = "candidate";
	$candidate->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $candidate );

	my $active;
	$active->{"core:name"}       = "active-config";
	$active->{"core:textBlob"}   = encode_base64( $in->{"active"} );
	$active->{"core:mediaType"}  = "text/plain";
	$active->{"core:context"}    = "active";
	$active->{'core:promotable'} = 'false';

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $active );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
}

sub parse_local_accounts
{

	# using the configuration, populate the ZipTie localAccounts model
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");
	my ($login) = _get_section( "login", $in->{candidate} );
	my @users = _get_section( "user", $login );
	foreach (@users)
	{
		my ($user)  = $_ =~ /^\s+user\s*(\S+)/mi;
		my ($class) = $_ =~ /^\s+class\s*(\S+\b)/mi;

		my $account = {
			accountName => $user,
			accessGroup => $class,
		};
		$out->print_element( "localAccount", $account );
	}
	$out->close_element("localAccounts");
}

sub parse_filters
{

	# uses partial loading of the firewall XML output to process all filters
	my ( $in, $out ) = @_;
	my ($firewallSection) = $in->{showFirewall} =~ /(<firewall.+<\/firewall>)/s;
	if ($firewallSection)
	{
		$out->open_element("filterLists");
		my $twig = XML::Twig->new( twig_roots => { 'filter' => _process_filter($out) } );
		$twig->parse($firewallSection);
		undef $firewallSection;
		$out->close_element("filterLists");
	}
}

sub _process_filter
{
	my ($out) = @_;
	return sub {

		# processes a single firewall filter as an XML::Twig
		my ( $twig, $element ) = @_;
		$out->open_element("filterList");
		foreach my $filterEntryElement ( $element->descendants('term') )
		{
			my $filterEntry = {
				name          => _get_element_text($filterEntryElement, 'name'),
				log           => "false",
				primaryAction => 'none',
			};
			my $from = $filterEntryElement->first_child('from');

			# process the address information
			if ($from)
			{
				my $address = $from->first_child('address');
				$filterEntry->{sourceIpAddr} = _process_address($address) if ($address);
				my $dstAddr = $from->first_child('destination-address');
				$filterEntry->{destinationIpAddr} = _process_address($dstAddr) if ($dstAddr);
				my $srcAddr = $from->first_child('source-address');
				$filterEntry->{sourceIpAddr} = _process_address($srcAddr) if $srcAddr;

				# process the port information
				my @ports = $from->children('port');
				$filterEntry->{sourceService} = _process_port(@ports) if (@ports);
				my @dstPorts = $from->children('destination-port');
				$filterEntry->{destinationService} = _process_port(@dstPorts) if (@dstPorts);
				my @srcPorts = $from->children('source-port');
				$filterEntry->{sourceService} = _process_port(@srcPorts) if @srcPorts;

				foreach my $prot ( $from->children('protocol') )
				{
					push( @{ $filterEntry->{protocol} }, $prot->text() );
				}
			}

			my $then = $filterEntryElement->first_child('then');
			if ($then)
			{
				if ( $then->first_child('accept') )
				{
					$filterEntry->{primaryAction} = "permit";
				}
				elsif ( $then->first_child('reject') )
				{
					$filterEntry->{primaryAction} = "deny";
				}
				if ( $then->first_child('log') )
				{
					$filterEntry->{log} = "true";
				}
			}

			$out->print_element( "filterEntry", $filterEntry );
		}
		my $filterName = _get_element_text($element, 'name');
		$out->print_element( "mode", 'stateless' );
		$out->print_element( "name", $filterName );
		$out->close_element("filterList");
	  }
}

sub _get_element_text
{
	# if the element is defined this returns the text value of the element.
	# if the element is not defined this returns undef;
	my ( $twig, $elementName ) = @_;
	my $child = $twig->first_child($elementName);
	if ($child)
	{
		return $child->text();
	}
	else
	{
		return undef;
	}
}

sub _process_address
{

	# puts a TWIG into a hash for a single filterEntry's ip address
	my $twig = shift;

	my $addresses;
	foreach my $child ( $twig->children('name') )
	{
		my ( $addr, $mask ) = split( /\//, $child->text() );
		push( @{$addresses}, { network => { address => $addr, mask => $mask, } } );
	}
	return $addresses;
}

sub _process_port
{

	# puts a TWIG into a hash for a single filterEntry's port
	my $portArray;
	foreach my $port (@_)
	{
		my $p = $port->text();
		if ( $p =~ /^(\d+)\-(\d+)$/ )
		{
			push( @{$portArray}, { portRange => { portStart => $1, portEnd => $2, } } );
		}
		elsif ( $p =~ /^\d+$/ )
		{
			push( @{$portArray}, { portExpression => { operator => 'eq', port => $p, } } );
		}
		elsif ( $p =~ /\S+/ )
		{
			push( @{$portArray}, { portExpression => { operator => 'eq', port => get_port_number($p), } } );
		}
	}
	return $portArray;
}

sub parse_snmp
{

	# using the configuration, populate the ZipTie SNMP model
	my ( $in, $out ) = @_;
	my $snmp = {};

	if ( $in->{candidate} =~ /^\s+host-name\s+\"?(.+?)\"?;\s*$/mi )
	{
		$snmp->{sysName} = $1;
	}

	my ($snmpSection) = $in->{snmp} =~ /(<snmp>.+<\/snmp>)/s;
	if ($snmpSection)
	{
		my $twig = XML::Twig->new();
		$twig->parse($snmpSection);
		undef $snmpSection;
		my $root = $twig->root;

		$snmp->{sysContact}  = $root->first_child('contact')->text  if ( $root->first_child('contact') );
		$snmp->{sysLocation} = $root->first_child('location')->text if ( $root->first_child('location') );

		foreach my $communityElement ( $twig->descendants('community') )
		{
			if ( $communityElement->first_child('name') )
			{
				my $communityHash = {
					communityString => $communityElement->first_child('name')->text(),
					accessType      => 'RO',
				};

				if ( $communityElement->first_child('authorization') )
				{
					$communityHash->{accessType} = 'RW'
					  if ( $communityElement->first_child('authorization')->text eq 'read-write' );
				}

				foreach my $clientElement ( $communityElement->descendants('clients') )
				{
					my $fullClient = $clientElement->first_child('name')->text;

					if ( $fullClient =~ /(\d+\.\d+\.\d+\.\d+)\/(\d+)/mi )
					{
						my $address = { network => { address => $1, mask => $2, } };
						push( @{ $communityHash->{embeddedAccessFilter} }, $address );
					}
				}

				push( @{ $snmp->{community} }, $communityHash );
			}
		}
		foreach my $trapGroupElement ( $twig->descendants('trap-group') )
		{
			foreach my $trapHostElement ( $trapGroupElement->descendants('targets') )
			{
				my $trapHost = { ipAddress => $trapHostElement->first_child('name')->text, };
				push( @{ $snmp->{trapHosts} }, $trapHost );
			}
		}
	}
	$out->print_element( "snmp", $snmp );
}

sub parse_interfaces
{

	# creates the ZipTie interfaces model by reading the Juniper interface-information
	# XML with XML::Twig and then traversing the twigs.  This could be streamlined
	# by reading only physical-interface blocks at a time and using a twig callback
	# to a method that parses that single interface
	my ( $in, $out ) = @_;

	$out->open_element("interfaces");

	my ($intSection) = $in->{interfaces} =~ /(<interface-information.+<\/interface-information>)/s;
	my $interfaces = XML::Twig->new();
	$interfaces->parse($intSection);
	undef $intSection;

  # Chec to see if the response from the "show ospf interface detail | display xml" command contains valid info for OSPF
	my ($ospfIntSection) = $in->{showOspfInterface} =~ /(<ospf-interface-information.+<\/ospf-interface-information>)/s;
	my $ospfInts = undef;

	# If any OSPF interface information section was found, the create an XML::Twig object to store it
	if ($ospfIntSection)
	{
		$ospfInts = XML::Twig->new();
		$ospfInts->parse($ospfIntSection);
		undef $ospfIntSection;
	}

	foreach my $physicalInt ( $interfaces->descendants('physical-interface') )
	{
		my $name        = $physicalInt->first_child('name')->text();
		my $adminStatus = lc( $physicalInt->first_child('admin-status')->text() );
		my $ifDescr = $physicalInt->first_child('description')->text() if ( $physicalInt->first_child('description') );
		my $type    = _get_interface_type( $physicalInt->first_child('if-type') );

		my $majorInt = {
			name          => $name,
			adminStatus   => $adminStatus,
			interfaceType => $type,
			speed         => _process_speed( $physicalInt->first_child('speed') ),
			physical      => _is_physical($name),
			mtu           => _get_mtu( $physicalInt->first_child('mtu') ),
		};

		if ($ifDescr)
		{
			$majorInt->{"description"} = $ifDescr;
		}

		my $mac = _process_mac( $physicalInt->first_child('hardware-physical-address') );
		if ($mac)
		{
			$majorInt->{"interfaceEthernet"}->{"macAddress"} = $mac;
		}

		my $ospfInterface = _get_ospf_interface( $majorInt->{name}, $ospfInts );
		if ($ospfInterface)
		{
			$majorInt->{interfaceOspf} = $ospfInterface;
		}
		$out->print_element( "interface", $majorInt );

		foreach my $logicalInt ( $physicalInt->descendants('logical-interface') )
		{
			my $subName = $logicalInt->first_child('name')->text() if ( $logicalInt->first_child('name') );
			next if ( !$subName );
			my $subDesc = $logicalInt->first_child('description')->text()
			  if ( $logicalInt->first_child('description') );
			my $subInt = {
				name          => $subName,
				adminStatus   => $adminStatus,
				interfaceType => $type,
				physical      => "false",
				speed         => _process_speed( $logicalInt->first_child('speed') ),
			};

			if ($subDesc)
			{
				$subInt->{"description"} = $subDesc;
			}

			my $subOspfInt = _get_ospf_interface( $subName, $ospfInts );
			if ($subOspfInt)
			{
				$subInt->{interfaceOspf} = $subOspfInt;
			}

			foreach my $fam ( $logicalInt->descendants('address-family') )
			{
				foreach my $addr ( $fam->descendants('interface-address') )
				{
					my $ip = new Net::IP($addr->first_child('ifa-local')->text());
					if (defined $ip)
					{
						my $ipConfiguration = { "ipAddress" => $addr->first_child('ifa-local')->text(), };
						if ( defined $addr->first_child('ifa-destination') )
						{
							my ($mask) = $addr->first_child('ifa-destination')->text() =~ /\/(\d+)/;
							$ipConfiguration->{mask} = $mask;
						}
						push( @{ $subInt->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
					}
				}
			}
			$out->print_element( "interface", $subInt );
		}
	}
	$out->close_element("interfaces");
}

sub _get_ospf_interface
{

	# given a TWIG of the 'show ospf interfaces detail' command and the name
	# of a real interface, parse out the ospf details for the specific interface
	my ( $name, $twig ) = @_;

	# Only continue if the XML::Twig object representing the OSPF interface information is valid
	if ( defined($twig) )
	{
		foreach my $int ( $twig->descendants('ospf-interface') )
		{
			my $ospfIntName = $int->first_child('interface-name')->text();
			if ( $name eq $ospfIntName )
			{
				my $routerPriority = $int->first_child('router-priority')->text()
				  if ( $int->first_child('router-priority') );
				my $ospfInt = {
					area               => $int->first_child('ospf-area')->text(),
					networkType        => _normalize_ospf_type( $int->first_child('interface-type')->text() ),
					routerState        => $int->first_child('ospf-interface-state')->text(),
					helloInterval      => $int->first_child('hello-interval')->text(),
					cost               => $int->first_child('interface-cost')->text(),
					retransmitInterval => $int->first_child('retransmit-interval')->text(),
				};

				if ($routerPriority)
				{
					$ospfInt->{"routerPriority"} = $routerPriority;
				}

				return $ospfInt;
			}
		}
	}
	return 0;
}

sub _normalize_ospf_type
{

	# follow the ZipTie network type enum
	my $networkType = shift;
	for ($networkType)
	{
		return /LAN/i ? "BROADCAST"
		  : /NBMA/i   ? "NON_BROADCAST"
		  : /P2P/i    ? "POINT_TO_POINT"
		  : /P2MP/i   ? "POINT_TO_MULTIPOINT"
		  : /Virtual/ ? "VIRTUAL_LINK"
		  : $networkType;
	}
}

sub _get_mtu
{
	my $mtuTwig = shift;
	if ($mtuTwig)
	{

		# translate "unlimited"
		my $mtu = $mtuTwig->text();
		if ( $mtu eq "Unlimited" )
		{
			return "2147483647";    # what SNMP says
		}
		elsif ( $mtu =~ /(\d+)/ )
		{
			return $1;
		}
	}
	return 0;
}

sub _is_hash
{

	# determines if the incoming variable is a hash reference or not
	# returns 1 if it is, 0 otherwise
	my $in = shift;
	if ( scalar($in) =~ /^HASH/ )
	{
		return 1;
	}
	return 0;
}

sub _process_mac
{

	# strips a MAC address of everything but the hex values
	# to comply with the ZipTie model
	my $twig = shift;
	if ($twig)
	{
		my $mac = $twig->text();
		$mac =~ s/[^0-9a-f]//gi;
		return $mac;
	}
	return 0;
}

sub _get_interface_type
{
	my $typeTwig = shift;
	if ( !$typeTwig )
	{
		return get_interface_type("unknown");
	}
	else
	{
		return get_interface_type( $typeTwig->text() );
	}
}

sub _process_speed
{

	# Juniper has a free format for speed.  This method normalizes that speed
	# into bps
	my $speed = shift;
	if ( !$speed )
	{
		return 0;
	}
	elsif ( $speed->text() =~ /(\d+)m/i )
	{
		return $1 * 1000 * 1000;
	}
	elsif ( $speed->text() =~ /(\d+)k/i )
	{
		return $1 * 1000;
	}
	elsif ( $speed->text() =~ /(\d+)/i )
	{
		return $1;
	}
	elsif ( $speed->text() eq "Unlimited" )
	{
		return "2147483647";    # this is what SNMP says
	}
	else
	{
		return 0;
	}
}

sub _is_physical
{

	# even though Juniper may call their loopback a physical interface, ziptie doesn't.
	my $name = shift;
	if ( $name =~ /seri|eth|gig|^fe|^fa|token/i )
	{
		return "true";
	}
	else
	{
		return "false";
	}
}

sub _get_section
{

	# given the name of a juniper configuration section, returns an array of
	# each section
	my ( $section, $input ) = @_;
	my @results;
	while ( $input =~ /^((\s+)$section[^\n]*?{(.+?)^\2})/msig )
	{
		push( @results, $1 );
	}
	return @results;
}

# returns the 0.0.0.0/0 address
sub _get_any
{
	my $address = {};
	$address->{address} = "0.0.0.0";
	$address->{mask}    = "0.0.0.0";
	return $address;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Juniper::JUNOS::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Juniper::JUNOS::Parsers;
	parse_filters( $xmlPrinter, $cliResponses );	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
JUNOS device responses and print out ZipTie model elements.

Ideally the methods in this module will deal with XML output
from the JUNOS devices.  From the command line you can get XML
formatted output using "<command> | display xml".  See the C<parse_interfaces>
method for an example of this.

=head2 Methods

=over 12

=item C<create_config>

Uses the Juniper JUNOS active and candidate configs to put together a ZipTie
configurationRepository element.

=item C<parse_local_accounts>

Uses the Juniper JUNOS configuration to put together the ZipTie
localAccounts portion of the model.

=item C<parse_chassis>

Given the JUNOS output from 'show system memory' and 'show host os' parses out
some chassis level details from the core ZipTie model

=item C<parse_filters>

Uses the Juniper JUNOS configuration to put together the ZipTie
localAccounts portion of the model.

=item C<parse_routing>

Parses out global BGP and OSPF parameters.

=item C<parse_snmp>

Uses the Juniper JUNOS configuration to put together the ZipTie
SNMP portion of the model.

=item C<parse_system>

Given the JUNOS output from 'show version' and 'show host name' parses out
some top level core attributes of the ZipTie model ZiptieElementDocument

=item C<_get_any>

Method used internally to this module that returns a 0.0.0.0/0 IP address
definition.

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
