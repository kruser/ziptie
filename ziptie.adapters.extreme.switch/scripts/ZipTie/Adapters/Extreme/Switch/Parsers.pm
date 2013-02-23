package ZipTie::Adapters::Extreme::Switch::Parsers;
use strict;
use warnings;
use ZipTie::Adapters::Utils qw(seconds_since_epoch get_mask get_port_number strip_mac trim get_interface_type trim);
use MIME::Base64 'encode_base64';
use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

# Utility methods

sub separateTime
{
	if ( $_[0] =~ /(\d\d):(\d\d):(\d\d)/i )
	{
		return ( $1, $2, $3 );
	}

}

# PARSE SYSTEM INFO
# systemName, osInfo, biosVersion?, deviceType, contact?, lastReboot
sub parse_system
{
	my ( $in, $out ) = @_;

	#systemName
	my ($systemName) = $in->{switch} =~ /SysName:\s+(\S+)/mi;
	$out->print_element( 'core:systemName', $systemName );

	#osInfo::= fileName?, make, name?, softwareImage?, version, osType
	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Extreme' );
	if ( $in->{switch} =~ /(\bPrimary\s+Config.+Secondary\s+Config)/migs )
	{
		my $temp = $1;
		$temp =~ /Version:(?:\s|$)+(\S+)/migs;
		$out->print_element( 'core:version', $1 );
	}
	$out->print_element( 'core:osType', 'Summit' );
	$out->close_element('core:osInfo');

	#biosVersion
	if ( $in->{version} =~ /BootROM\s+:\s+(\S+)/mig )
	{
		$out->print_element( 'core:biosVersion', $1 );
	}

	#deviceType
	$out->print_element( 'core:deviceType', 'Switch' );

	#contact
	my ($contact) = $in->{switch} =~ /^SysContact:\s+(\S+)/mi;
	$out->print_element( 'core:contact', $contact );

	#lastReboot (in seconds)
	#Boot Time:        Mon Apr 16 15:20:19 2007
	my $boot_time = 0;

	if ( $in->{switch} =~ /^Boot\s+Time:\s+(\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+))$/mi )
	{
		my $month    = $2;
		my $date     = $3;
		my $time     = $4;
		my $year     = $5;
		my $timezone = "CST";
		my ( $hour, $min, $sec ) = separateTime($time);
		my $lastReboot = seconds_since_epoch( $sec, $min, $hour, $date, $month, $year, $timezone );
		$out->print_element( "core:lastReboot", $lastReboot );
	}
}

# PARSES CHASSIS
# asset?, description?, card*, cpu*, deviceStorage*, memory*, powersupply*
# asset ::= assetTag? : assetType : dateCreated? : description? : factoryinfo? : location? : owner?
sub parse_chassis
{
	my ( $in, $out ) = @_;
	$out->open_element("chassis");
	my $chassisAsset = { "core:assetType" => "Chassis", };
	$chassisAsset->{'core:factoryinfo'}->{'core:make'}         = "Extreme";

	#System Serial Number:  800138-00-03
	if ($in->{version} =~ /System\s+Serial\s+Number:\s+\S+\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	elsif ( $in->{version} =~ /\b(?:Switch|Chassis)\s+:\s+\S+\s+(\S+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:serialNumber'} = $1;
	}
	if ($in->{version} =~ /System\s+Serial\s+Number:\s+\S+\s+(\d+-\d+-\d+)/mi )
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:partNumber'} = $1;
	}
	if ($in->{switch} =~ /^\s*Platform:\s+(\S+)/mi)
	{
		$chassisAsset->{'core:factoryinfo'}->{'core:modelNumber'}  = $1;
	}
	$out->print_element( "core:asset", $chassisAsset );
	parse_memory( $in, $out );
	$out->close_element("chassis");
}

#System Memory Information
#-----------------------
#Total DRAM Size: 134217728 (128MB)

sub parse_memory
{
	my ( $in, $out ) = @_;
	if ( $in->{memory} =~ /^Total\s+(\S+)\s+Size:\s+(\d+)/mig )
	{
		$out->print_element( "memory", { 'core:description' => 'RAM', kind => 'RAM', size => $2 } );
	}
}

# CREATE CONFIG
# config*, name?, repository*
# config::= context, mediaType, name, textBlob
sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{'core:name'} = '/';

	# config
	my $config;
	$config->{"core:context"}    = "active";
	$config->{"core:mediaType"}  = "text/plain";
	$config->{"core:name"}       = "config";
	$config->{"core:textBlob"}   = encode_base64( $in->{"config"} );    #Gets the Config File.
	$config->{"core:promotable"} = 'false';                             
	                                                                    # push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	# print the repository
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
	$out->print_element( "interfaces", $in->{interfaces} );
}

# PARSE LOCAL ACCOUNTS.
# localAccounts::= localAccount+
# localAccount::= accountName : accessGroup? : accessLevel? : fullName? : password?

sub parse_local_accounts
{

	# local accounts - local usernames
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");

	if ( $in->{accounts} =~ /^[-+\s+]+-+(.+)(^-+)$/migs )
	{
		my $accounts = $1;
		while ( $accounts =~ /\s+(\S+).+\s+(\S+)$/mig )
		{
			my $accountName = $1;
			my $accessGroup = $2;
			my $password    = getPassword( $in, $accountName );
			my $account     = {
				accessGroup => $accessGroup,
				accountName => $accountName,
				password    => $password
			};
			$out->print_element( "localAccount", $account );
		}
	}
	$out->close_element("localAccounts");
}

# Helping method for getting the password for a specific username
sub getPassword
{
	my $in   = shift;
	my $user = shift;
	if ( $in->{config} =~ /^create\s+account\s+\S+\s+"$user"\s+encrypted\s+"(.+)"$/mig )
	{

		#Ex: create account user "user" encrypted "fw3NfO$t389o7FDPHOFA3g2rDima."
		return $1;
	}
	elsif ( $in->{config} =~ /^configure\s+account\s+$user\s+encrypted\s+(.+)\s+.+$/mig )
	{

		#Ex: configure account admin encrypted 452ejK$KkunfCWJoYDtilAhn0/oq0 452ejK$KkunfCWJoYDtilAhn0/oq0
		return $1;
	}
}

# PARSE SNMP
# snmp ::= community*, sysContact?, sysLocation?, sysName, sysObjectId?, systemShutdownViaSNMP?,
#		   trapHosts*, trapSource?, trapTimeout?
sub parse_snmp
{
	my ( $in, $out ) = @_;
	my ($systemName) = $in->{switch} =~ /^SysName:\s+(\S+)$/mi;
	my ($contact)    = $in->{switch} =~ /^SysContact:\s+(\S+)/mi;
	my ($location)   = $in->{switch} =~ /^SysLocation:\s+(.+)$/mi;
	$location		 = trim($location) if ( $location );
	$out->open_element("snmp");
	my $community = {};
	while ( $in->{config} =~ /^config\s+snmpv3\s+add\s+community\s+encrypted\s+"(\S+)".+(\S\S)"$/mig )
	{
		$community->{communityString} = $1;
		if ( defined $2 && validAccess($2) )
		{
			$community->{accessType} = uc($2);
		}
		else
		{
			$community->{accessType} = "RO";
		}
		$out->print_element( "community", $community );

	}
	$out->print_element( "sysContact",  $contact );
	$out->print_element( "sysLocation", $location );
	$out->print_element( "sysName",     $systemName );
	$out->close_element("snmp");
}

sub validAccess
{
	my $type = shift;
	$type = lc($type);
	if ( $type eq "ro" || $type eq "wo" || $type eq "rw" )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

#   PARSE SPANNING TREE
#   spanningTree ::= forwardDelay?, helloTime?, maxAge?, mode?, priority?, spanningTreeInstance*,
#				systemMacAddress?, type?
#   spannigTreeInstance::= designatedRootCost? : designatedRootForwardDelay? : designatedRootHelloTime? :
#   designatedRootMacAddress? : designatedRootMaxAge? : designatedRootPort? :
#   designatedRootPriority? : forwardDelay? : helloTime : holdTime? : maxAge? :
#   priority : systemMacAddress? : vlan?

sub parse_stp
{
	my ( $in, $out ) = @_;
	my $spanningTree;
	while ( $in->{stp} =~ /^(Stpd:.+)^\s*^/msig )
	{
		my $thistree = $1;
		my $instance = {};

		#Root Section

		if ( $thistree =~ /^RootPathCost:\s+(\d+)/mi )
		{
			$instance->{designatedRootCost} = $1;
		}

		if ( $thistree =~ /\s+ForwardDelay:\s+(\d+)/mi )
		{
			$instance->{designatedRootForwardDelay} = $1;
		}

		if ( $thistree =~ /\s+HelloTime:\s+(\d+)/mi )
		{
			$instance->{designatedRootHelloTime} = $1;
		}

		if ( $thistree =~ /^Designated\s+root:\s+\S*(\S{17})/mi )
		{

			$instance->{designatedRootMacAddress} = strip_mac($1);
		}

		if ( $thistree =~ /^MaxAge:\s+(\d+)/mi )
		{
			$instance->{designatedRootMaxAge} = $1;
		}

		if ( $thistree =~ /\s+Root\s+Port:\s+(\d+)/mi )
		{
			if ( defined $1 )
			{
				$instance->{designatedRootPort} = $1;
			}
		}

		# 	Bridge Section
		#   forwardDelay? : helloTime : holdTime? : maxAge? :
		#   priority : systemMacAddress? : vlan?

		if ( $thistree =~ /\s+CfgBrForwardDelay:\s+(\d+)/mi )
		{
			$instance->{forwardDelay} = $1;
		}

		if ( $thistree =~ /\s+CfgBrHelloTime:\s+(\d+)/mi )
		{
			$instance->{helloTime} = $1;
		}

		if ( $thistree =~ /\s+Hold\stime:\s+(\d+)/mi )
		{
			$instance->{holdTime} = $1;
		}

		if ( $thistree =~ /^CfgBrMaxAge:\s+(\d+)/mi )
		{
			$instance->{maxAge} = $1;
		}

		if ( $thistree =~ /^Bridge\s+Priority:\s+(\d+)/mi )
		{
			$instance->{priority} = $1;
		}

		if ( $thistree =~ /^BridgeID:\s+\S*(\S{17})/mi )
		{
			$instance->{systemMacAddress} = strip_mac($1);
		}

		if ( $thistree =~ /^Active\s+Vlans:\s+(\S+\s+\S+)$/mi )
		{
			$instance->{vlan} = $1;
		}
		elsif ( $thistree =~ /^Active\s+Vlans:\s+(\S+)\s*$/mi )
		{
			$instance->{vlan} = $1;
		}
		push( @{ $spanningTree->{spanningTreeInstance} }, $instance );
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

	while ( $in->{routes} =~ /^(Destination.+?)^\s+/misg )
	{
		my $content = $1;
		if ( $content =~ /^Destination:\s+(\S+)\/(\d+).*Gateway:\s+(\S+)\s+Metric:\s+(\S+).+VLAN:\s+(\S+)\s*$/migs )
		{
			my $route = {
				destinationAddress => $1,
				destinationMask    => $2,
				gatewayAddress     => $3,
				interface          => $5,
				routeMetric        => $4,
				defaultGateway     => 'false'
			};
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
		elsif ( $content =~ /^Destination:\s+(\S+\s+\S+).*Gateway:\s+(\S+)\s+Metric:\s+(\S+).+VLAN:\s+(\S+)\s*$/migs )
		{
			my $route = {
				destinationAddress => $1,
				destinationMask    => "24",
				gatewayAddress     => $2,
				interface          => $4,
				routeMetric        => $3,
				defaultGateway     => 'true'
			};
			push( @{ $staticRoutes->{staticRoute} }, $route );
		}
	}
	$out->print_element( 'staticRoutes', $staticRoutes ) if ( defined $staticRoutes );
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

	while ( $in->{vlans} =~ /^(VLAN\s+.+?)^\s+$/misg )
	{
		my $content = $1;
		if ( $content =~ /^VLAN.+name\s+"(\w+)".+\s+Tagging:\s+\S+\s+(?:Tag|\(Internal\stag)\s+(\d+)(?:$|\))/migs )
		{
			$thisVlan = {
				name    => $1,
				number  => $2,
				enabled => ("true")
			};

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

#-----------------------------------

sub parse_filters
{
	my ( $in, $out ) = @_;
}

sub parse_routing
{
	my ( $in, $out ) = @_;
}

1;

__END__

=head1 Parsers

ZipTie::Adapters::Extreme::Switch::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Extreme::Switch::Parsers qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
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
  Date: Aug 29, 2007

=cut
