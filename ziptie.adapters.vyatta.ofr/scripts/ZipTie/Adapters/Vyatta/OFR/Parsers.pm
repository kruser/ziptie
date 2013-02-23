package ZipTie::Adapters::Vyatta::OFR::Parsers;

use strict;
use warnings;
use ZipTie::Adapters::Utils qw(strip_mac seconds_since_epoch get_mask get_port_number get_interface_type);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK = qw(parse_interfaces create_config parse_local_accounts parse_chassis parse_filters parse_routing parse_snmp parse_system);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;

	$chassis->{"core:asset"}->{"core:assetType"}                         = "Chassis";
	$chassis->{"core:asset"}->{"core:factoryinfo"}->{"core:make"}        = "Vyatta";
	$chassis->{"core:asset"}->{"core:factoryinfo"}->{"core:modelNumber"} = "Open Flexible Router";
	$chassis->{"core:description"}                                       = "Open Flexible Router";

	if ( $in->{showMem} =~ /Total:\s*(\d*)/i )
	{
		$chassis->{"memory"}->{"core:description"} = "RAM";
		$chassis->{"memory"}->{"kind"}             = "RAM";
		$chassis->{"memory"}->{"size"}             = int($1);
	}

	if ( $in->{showOs} =~ /(\w+).*(\d.\d.\d+)\s+#\d+.*\d{4}\s+(\w+)/ )
	{
		$chassis->{"cpu"}->{"core:description"} = $3;
	}
	$out->print_element( "chassis", $chassis );
}

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my ($interfaces) = _get_section( "interfaces", $in->{config} );
	my $headerPrinted = 0;
	while ( $interfaces =~ /^(\s+)(\S+)\s+(\S+)\s*{(.+?)^\1}/msg )
	{
		$out->open_element("interfaces") if ( !$headerPrinted );
		$headerPrinted = 1;

		my $name = $3;
		my $blob = $4;

		my $interface = {
			name          => $name,
			interfaceType => get_interface_type($2),
			physical      => _is_physical($name),
		};

		$interface->{adminStatus} = ( $blob =~ /^\s+disable:\s+false/mi ) ? "up" : "down";

		if ( $blob =~ /^\s*description:\s*\"(.*?)\"\s*$/mi )
		{
			$interface->{description} = $1;
		}
		if ( $blob =~ /^\s*hw-id:\s*(\S+)/mi )
		{
			$interface->{interfaceEthernet}->{macAddress} = strip_mac($1);
		}
		if ( $name =~ /eth/i )
		{
			$interface->{interfaceEthernet}->{autoSpeed}  = ( $blob =~ /^\s+speed:\s+\"?auto\"?/mi )  ? "true" : "false";
			$interface->{interfaceEthernet}->{autoDuplex} = ( $blob =~ /^\s+duplex:\s+\"?auto\"?/mi ) ? "true" : "false";
		}
		while ( $blob =~ /^(\s*)address\s+(\S+)\s+{(.+?)^\1}/msig )
		{
			my $props = $3;
			my $ipConfiguration = { ipAddress => $2, };
			if ( $props =~ /^\s*prefix-length:\s*(\d+)/mi )
			{
				$ipConfiguration->{mask} = $1;
			}
			push( @{ $interface->{interfaceIp}->{ipConfiguration} }, $ipConfiguration );
		}
		my ($firewall) = _get_section( "firewall", $blob );
		if ($firewall)
		{
			my ($ingress) = _get_section( "in", $firewall );
			if ( $ingress =~ /^\s*name:\s*\"?(.+?)\"?\s*$/mi )
			{
				$interface->{ingressFilter} = $1;
			}
			my ($egress) = _get_section( "out", $firewall );
			if ( $egress =~ /^\s*name:\s*\"?(.+?)\"?\s*$/mi )
			{
				$interface->{egressFilter} = $1;
			}
		}

		# MTU comes from "show interfaces"
		if ( $in->{interfaces} =~ /^\s*$name.+mtu\s*(\d+)/mi )
		{
			$interface->{mtu} = $1;
		}

		$out->print_element( "interface", $interface );
	}
	$out->close_element("interfaces") if ($headerPrinted);
}

sub parse_system
{
	my ( $in, $out ) = @_;

	if ( $in->{showName} =~ /^\w*@(\w*)\S\s/mi )
	{
		$out->print_element( "core:systemName", $1 );
	}

	if ( $in->{showVer} =~ /Version:\s+(\S+)/mi )
	{
		$out->open_element('core:osInfo');
		$out->print_element( 'core:make',    'Vyatta' );
		$out->print_element( 'core:version', $1 );
		$out->print_element( 'core:osType',  'OFR' );
		$out->close_element('core:osInfo');
	}

	$out->print_element( "core:deviceType", "Router" );

	# System booted: Tue Apr 17 19:23:10 UTC 2007
	if ( $in->{showVer} =~ /System booted:\s+\S+\s+(\S+)\s+(\d+)\s+(\d{1,2}:\d{1,2}:\d{1,2})\s+(\S+)\s+(\d{4})/i )
	{
		my $year     = $5;
		my $month    = $1;
		my $day      = $2;
		my $time     = $3;
		my $timezone = $4;
		my ( $hour, $min, $sec ) = $time =~ /(\d+):(\d+):(\d+)/;
		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, $day, $month, $year, $timezone ) );
	}
	else
	{
		$out->print_element( "core:lastReboot", "-1" );
	}

}

# Populates the configuration entity for the main Vyatta config
sub create_config
{
	my ( $in, $out ) = @_;

	# the name of the repository
	my $repository;
	$repository->{"core:name"} = "/";

	# build the simple text configuration
	my $config;
	$config->{"core:name"}       = "config";
	$config->{"core:textBlob"}   = encode_base64( $in->{config} );
	$config->{"core:mediaType"}  = "text/plain";
	$config->{"core:context"}    = "N/A";
	$config->{'core:promotable'} = 'false';                          

	# push the configuration into the repository
	push( @{ $repository->{'core:config'} }, $config );

	# print the repository
	$out->print_element( "core:configRepository", $repository );
}

# using the configuration, populate the ZipTie localAccounts model
sub parse_local_accounts
{
	my ( $in, $out ) = @_;
	$out->open_element("localAccounts");
	while ( $in->{config} =~ /^(\s+)user\s+(\S+)\s*{(.+?)^\1}/msig )
	{
		my $account = {};
		$account->{accountName} = $2;
		my $blob = $3;
		if ( $blob =~ /^\s+full-name:\s*\"(.*?)\"/m )
		{
			$account->{fullName} = $1;
		}
		if ( $blob =~ /^\s+(plaintext|encrypted)-password:\s*\"(.+?)\"/m )
		{
			$account->{password} = $2;
		}
		$out->print_element( "localAccount", $account );
	}
	$out->close_element("localAccounts");
}

# put the vyatta firewall rules into the ZipTie filters model
sub parse_filters
{
	my ( $in, $out ) = @_;

	my ($version) = $in->{showVer} =~ /Version:\s+(\S+)/mi ;
	#version 3 contains no filter list info, if we find
	#that this device has that version, we skip this part
	unless ( $version =~ /2/mi )
	{
		return;
	}
	
	if ( $in->{config} =~ /^(\s{1,6})firewall\s*{(.+?)^\1}/msi )
	{
		my $blob = $2;
		$out->open_element("filterLists");
		
		# iterate over each firewall set
		while ( $blob =~ /^(\s+)name\s+(\b.+?\b)\s*{(.+?)^\1}/msig )
		{
			$out->open_element("filterList");
			my $processOrder = 0;
			my $firewallName = $2;
			my $rules        = $3;
			if ( $rules =~ /^\s+description:\s*\"?(\b.+\b)\"?/mi )
			{
				$out->print_element( "description", $1 );
			}

			# iterate over each rule
			while ( $rules =~ /^(\s+)rule\s+(\d+)\s*{(.+?)^\1}/msig )
			{
				$processOrder++;

				my $rule     = {};
				my $ruleBody = $3;
				$rule->{name}         = $2;
				$rule->{processOrder} = $processOrder;

				if ( $ruleBody =~ /^\s+protocol:\s*\"?\b(\S+)\b\"?/m )
				{
					$rule->{protocol} = $1;
				}
				if ( $ruleBody =~ /^\s+action:\s*\"?\b(\S+)\b\"?/m )
				{
					my $action = $1;
					if ( $action eq "accept" )
					{
						$action = "permit";
					}
					elsif ( $action eq "reject" )
					{
						$action = "deny";
					}
					$rule->{primaryAction} = $action;
				}

				# is logging on for this rule
				if ( $ruleBody =~ /^\s+log:\s*\"enable/m )
				{
					$rule->{log} = "true";
				}
				else
				{
					$rule->{log} = "false";
				}

				while ( $ruleBody =~ /^(\s+)(source|destination)\s*{(.+?)^\1}/msig )
				{
					my $location = $2;
					my $details  = $3;
					$rule->{ $location . "IpAddr" }->{network} = _get_any();
					if ( $details =~ /network:\s+(\d+\.\d+\.\d+\.\d+)\/(\d+)/i )
					{
						my $address = {};
						$address->{address}             = $1;
						$address->{mask}                = $2;
						$rule->{ $location . "IpAddr" }->{network} = $address;
					}
					elsif ( $details =~ /address:\s+(\d+\.\d+\.\d+\.\d+)/i )
					{
						my $address = {};
						$address->{host}             = $1;
						$rule->{ $location . "IpAddr" } = $address;
					}

					if ( $details =~ /port-number:\s+(\d+)/ )
					{
						my $port = { portExpression => {port => $1, operator=> 'eq', }};
						$rule->{ $location . "Service" } = $port;
					}
					elsif ( $details =~ /port-name:\s+\"?(\b\S+\b)/ )
					{
						my $port = { portExpression => {port=> get_port_number($1), operator=> 'eq',} };
						$rule->{ $location . "Service" } = $port;
					}
					elsif ( $details =~ /port-range.+?start:\s+(\d+).+?stop:\s+(\d+)/msi )
					{
						my $port = { portRange => {portStart => $1, portEnd => $2,} };
						$rule->{ $location . "Service" } = $port;
					}
				}
				$out->print_element( "filterEntry", $rule );
			}

			$out->print_element( "mode", 'stateful' );
			$out->print_element( "name", $firewallName );
			$out->close_element("filterList");
		}
		$out->close_element("filterLists");
	}
}

sub parse_routing
{

	# parses out BGP and OSPF specifics of the global configuration
	my ( $in, $out ) = @_;
	$out->open_element("routing");
	if ( $in->{config} =~ /^(\s+)bgp\s*{(.+?)^\1}/sm )
	{
		my $bgp  = {};
		my $blob = $2;
		if ( $blob =~ /^\s+bgp-id:\s*(\d+\.\d+\.\d+\.\d+)/m )
		{
			$bgp->{routerId} = $1;
		}
		if ( $blob =~ /^\s+local-as:\s*(\d+)/m )
		{
			$bgp->{asNumber} = $1;
		}
		while ( $blob =~ /^(\s+)peer\s*"?(\d+\.\d+\.\d+\.\d+)"?\s*{(.+?)^\1}/smg )
		{
			my $neighbor = { address => $2, };
			my $neighborBlob = $3;
			if ( $neighborBlob =~ /^\s*as:\s*(\d+)/m )
			{
				$neighbor->{asNumber} = $1;
			}
			push( @{ $bgp->{neighbor} }, $neighbor );
		}
		$out->print_element( "bgp", $bgp );
	}
	if ( $in->{config} =~ /^(\s+)ospf4\s*{(.+?)^\1}/sm )
	{
		my $blob = $2;
		my $ospf;
		if ( $blob =~ /^\s+router-id:\s*(\d+\.\d+\.\d+\.\d+)/m )
		{
			$ospf->{routerId} = $1;
		}
		while ( $blob =~ /^(\s+)area\s+(\S+)\s*{(.+?)^\1}/msg )
		{
			my $areaBlob = $3;
			my $area = { areaId => $2, };
			if ( $areaBlob =~ /^\s*area-type\s*:\s+\"?(\S+\b)/mi )
			{
				$area->{areaType} = $1;
			}
			push( @{ $ospf->{area} }, $area );
		}
		$out->print_element( "ospf", $ospf );
	}
	$out->close_element("routing");
}

# using the configuration, populate the ZipTie SNMP model
sub parse_snmp
{
	my ( $in, $out ) = @_;
	my $snmp = {};

	# Capture top level SNMP attributes
	if ( $in->{config} =~ /^\s+contact:\s+\"(.*)\"\s*$/mi )
	{
		$snmp->{sysContact} = $1 if $1;
	}
	if ( $in->{config} =~ /^\s+location:\s+\"(.*)\"\s*$/mi )
	{
		$snmp->{sysLocation} = $1 if $1;
	}
	if ( $in->{config} =~ /^\s+host-name:\s+\"(.*)\"\s*$/mi )
	{
		$snmp->{sysName} = $1 if $1;
	}

	# Capture community strings
	while ( $in->{config} =~ /^\s+community\s+(\S+)\s*{(.+?)^\s+}/smg )
	{
		my $blob      = $2;
		my $community = {};
		$community->{communityString} = $1;
		$community->{accessType}      = "RO";
		if ( $blob =~ /^\s+authorization:\s+\"(\S+?)\"/m )
		{
			$community->{accessType} = uc($1);
		}

		while ( $blob =~ /^\s+client\s+(\d+\.\d+\.\d+\.\d+)/mg )
		{
			push( @{ $community->{embeddedAccessFilter} }, {host => $1} );
		}
		while ( $blob =~ /^\s+network\s+(\d+\.\d+\.\d+\.\d+)\/(\d+)/mg )
		{
			my $address = {
				address => $1,
				mask    => $2,
			};
			push( @{ $community->{embeddedAccessFilter} }, {network => $address} );
		}

		push( @{ $snmp->{community} }, $community );
	}

	# capture trap hosts
	while ( $in->{config} =~ /^\s+trap-target\s+(\S+)\s*$/mig )
	{
		my $trapHost = {};
		$trapHost->{ipAddress} = $1;
		push( @{ $snmp->{trapHosts} }, $trapHost );
	}

	$out->print_element( "snmp", $snmp );
}

# returns the 0.0.0.0/0 address
sub _get_any
{
	my $address = {};
	$address->{address} = "0.0.0.0";
	$address->{mask}    = "0";
	return $address;
}

sub _get_section
{

	# given the name of a OFR configuration section, returns an array of
	# each section
	my ( $section, $input ) = @_;
	my @results;
	while ( $input =~ /^((\s+)$section[^\n]*?{(.+?)^\2})/msig )
	{
		push( @results, $1 );
	}
	return @results;
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

=head1 NAME

ZipTie::Adapters::Vyatta::OFR::Parsers

=head1 SYNOPSIS

	use ZipTie::Adapters::Vyatta::OFR::Parsers;
	parse_filters( $xmlPrinter, $cliResponses );	

=head1 DESCRIPTION

Module with many static methods that take in a hash of
OFR device responses and print out ZipTie model elements

=head2 Methods

=over 12

=item C<create_config>

Uses the Vyatta OFR configuration to put together a ZipTie
configurationRepository element.

=item C<parse_local_accounts>

Uses the Vyatta OFR configuration to put together the ZipTie
localAccounts portion of the model.

=item C<parse_chassis>

Given the OFR output from 'show system memory' and 'show host os' parses out
some chassis level details from the core ZipTie model

=item C<parse_filters>

Uses the Vyatta OFR configuration to put together the ZipTie
localAccounts portion of the model.

=item C<parse_routing>

Parses out global BGP and OSPF parameters.

=item C<parse_snmp>

Uses the Vyatta OFR configuration to put together the ZipTie
SNMP portion of the model.

=item C<parse_snmp>

Uses the Vyatta OFR configuration to put together the ZipTie
SNMP portion of the model.

=item C<parse_system>

Given the OFR output from 'show version' and 'show host name' parses out
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
