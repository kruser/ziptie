package ZipTie::Adapters::Cisco::VxWorks::Parsers;

use strict;
use warnings;
use ZipTie::Addressing::Subnet;
use ZipTie::Adapters::Utils qw(mask_to_bits seconds_since_epoch get_mask get_port_number trim get_interface_type getUnitFreeNumber get_crep);
use MIME::Base64 'encode_base64';

use Exporter 'import';
our @EXPORT_OK =
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);

sub parse_chassis
{
	my ( $in, $out ) = @_;
	my $chassis;

	$chassis->{'core:asset'}->{'core:assetType'} = 'Chassis';

	$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:make'}        = 'Cisco';
	if ( $in->{home} =~ /(Cisco.+?AP\S*\s+[^<]+)/mi )
	{
		$chassis->{'core:asset'}->{'core:factoryinfo'}->{'core:modelNumber'} = $1;
	}
	$out->print_element( "chassis", $chassis );
}

sub parse_system
{
	my ( $in, $out ) = @_;

	my ($systemName) = $in->{home} =~ /<td nowrap><big><strong>([^\s<]+)<\/strong><\/big>/mi;
	$out->print_element( 'core:systemName', unescape_html_string($systemName) );

	$out->open_element('core:osInfo');
	$out->print_element( 'core:make', 'Cisco' );
	if ( $in->{home} =~ /<font color="#FF0000"><small>Cisco.+?(AP\S*)\s+([^<]+)/mi )
	{
		$out->print_element( 'core:name', unescape_html_string($1) );
		$out->print_element( 'core:version', unescape_html_string($2) );
	}
	$out->print_element( 'core:osType', 'VxWorks' );
	$out->close_element('core:osInfo');

	$out->print_element( 'core:deviceType', 'Wireless Access Point' );

	my ($contact) = $in->{snmp} =~ /<input type="text" value="([^"]*)" name="text_sysContact"/mi;
	$out->print_element( 'core:contact', unescape_html_string($contact) );

	if ( $in->{home} =~ /Uptime:( \d+ days?,)? (\d+):(\d+):(\d+)/i )
	{
		$_				= $1;
		my $hour		= $2;
		my $min			= $3;
		my $sec			= $4;
		my $timezone	= 'CST';
		#my ($years)		= /(\d+)\s*years?/;
		#my ($weeks)		= /(\d+)\s*weeks?/;
		my ($days)		= /(\d+)\s*days?/ if ();
		$days			= 0 if ( !defined $days );
		#$days			= $days + ( $weeks * 7 )  if ( $weeks );
		#$days			= $days + ( $years * 365 )  if ( $years );

		my ($sec2,$min2,$hour2,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$out->print_element( "core:lastReboot", seconds_since_epoch( $sec, $min, $hour, ($mday - $days), ($mon + 1), ($year + 1900), $timezone ) );
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
	$config->{'core:textBlob'}   = encode_base64( unescape_html_string($in->{'config'}) );
	$config->{'core:mediaType'}  = 'text/plain';
	$config->{'core:context'}    = 'active';
	$config->{'core:promotable'} = 'false';                             

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
	$out->open_element("localAccounts");

	my ($usr_tbl)	= $in->{users} =~ /<div align="center"><center>(<table.+<\/table>)/mis;
	$usr_tbl		= strip_html_tags($usr_tbl);
	$usr_tbl		=~ s/User Name.+Admin//mis;
	$usr_tbl		=~ s/\[Home\]\[Map\].+//mis;
	$usr_tbl		= trim($usr_tbl);
	$usr_tbl		.= "\n \n";
	while ( $usr_tbl =~ /^(\S.+?)^\s+/migs )
	{
		$_ = $1;
		if ( /^(\S+)/ )
		{
			my $account =
			{
				accountName => unescape_html_string($1),
				#accessLevel => ,
			};
			$out->print_element( "localAccount", $account );
		}
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
	#<input type="text" value="10.10.1.62" name="text_snmpTrapDest"
	#<input type="text" value="public" name="text_snmpTrapCommunity"
	if ( $in->{snmp} =~ /<input type="text" value="([^"]+)" name="text_sysContact"/mi )
	{
		$out->print_element( "sysContact", unescape_html_string($1) );
	}
	if ( $in->{snmp} =~ /<input type="text" value="([^"]+)" name="text_sysLocation"/ )
	{
		$out->print_element( "sysLocation", unescape_html_string($1) );
	}
	if ( $in->{snmp} =~ /<input type="text" value="([^"]+)" name="text_sysName"/mi )
	{
		$out->print_element( "sysName", unescape_html_string($1) );
	}
	$out->close_element("snmp");
}

sub parse_static_routes
{
	my ( $in, $out, $subnets ) = @_;
	my $staticRoutes;
	my ( $str_blob ) = $in->{routes} =~ /<select name="oldIpRouteDest" size="5">(.+)\<\/select>/mis;
	my $cipm		 = get_crep('cipm');

	while ( $str_blob =~ /<option value="$cipm">($cipm)(?:&nbsp;){1,}($cipm)(?:&nbsp;){1,}($cipm)<\/option>/mig )
	{
		my $route =
		{
			destinationAddress => $1,
			destinationMask    => mask_to_bits ( $2 ),
			gatewayAddress     => $3,
			interface		   => _pick_subnet( $3, $subnets ),
		};
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

sub parse_interfaces
{
	my ( $in, $out ) = @_;
	my $subnets = {};    # will be returned to the caller

	my ( $if_blob ) = $in->{home} =~ /Network Ports(.+)\[Home\]/mis;
	$out->open_element("interfaces");

	my $cipm = get_crep('cipm');
	my $mac1 = get_crep('mac1');
	while ( $if_blob =~ /<[^>]+><a\s+href="([^"]+)">([^<]+)(?:<[^>]+>){1,}([^<]+)(?:<[^>]+>){1,}([\d\.]+)(?:<[^>]+>){1,}($cipm)(?:<[^>]+>){1,}($mac1)(?:<[^>]+>){1,}/mig )
	{
		my $if_link		= $1;
		my $status		= $3;
		my $description	= $2;
		my $macAddr		= $6;
		my $speed		= $4;
		my $interface	=
			{
				adminStatus	  => ( lc( unescape_html_string($status) ) eq 'up' ? 'up' : 'down' ),
				description	  => unescape_html_string($description),
				interfaceType => get_interface_type( unescape_html_string($description) ),
				physical      => _is_physical( unescape_html_string($description) ),
			};
		$interface->{interfaceEthernet}->{macAddress} = unescape_html_string($macAddr);
		$interface->{speed} = getUnitFreeNumber( unescape_html_string($speed),'M','bit' );
		if ( $if_link =~ /ifIndex=(\d+)/i )
		{
			my $if_id				= $1;
			($interface->{name})	= $in->{'ifs'.$if_id} =~ /\bStatus of \&quot;([^\s\&<]+)/mi;
			if ( !$interface->{name} )
			{
				$interface->{name} = $interface->{description};
			}
			if ( $in->{'ifs'.$if_id} =~ /Duplex(?:<[^>]+>){1,}([^\s<&]+)/mi )
			{
				$_ = lc($1);
				if ( /auto/i )
				{
					$interface->{interfaceEthernet}->{autoDuplex} = 'true';
				}
				else
				{
					$interface->{interfaceEthernet}->{autoDuplex}		= 'false';
					$interface->{interfaceEthernet}->{operationalDuplex}	= $_;
				}
			}
			if ( $in->{'ifi'.$if_id} =~ /<[^>]+>Current IP Address:<[^>]+>\s+(?:<[^>]+>{1,})($cipm)/mi )
			{
				my $ip		= $1;
				my $mask	= '24';
				if ( $in->{'ifi'.$if_id} =~ /<[^>]+>Current IP Subnet Mask:<[^>]+>\s+(?:<[^>]+>{1,})($cipm)/mi )
				{
					$mask = mask_to_bits($1);
				}
				push @{$interface->{interfaceIp}->{ipConfiguration}}, { ipAddress => $ip , mask => $mask };
				my $subnet = new ZipTie::Addressing::Subnet( $ip, $mask );
				push( @{ $subnets->{$interface->{name}} }, $subnet );
			}
			if ( $in->{'ifi'.$if_id} =~ /<[^>]+>Maximum Packet Data Length:<[^>]+>\s+(?:<[^>]+>{1,})(\d+)/mi )
			{
				$interface->{mtu} = $1;
			}
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
}

sub strip_html_tags
{
	$_ = shift;
	s/<[^>]+>//mig;

	$_;
}

sub unescape_html_string
{
	$_ = shift;
	s/&nbsp;/ /mig;
	s/&amp;/&/mig;
	s/&quot;/"/mig;

	$_;
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
