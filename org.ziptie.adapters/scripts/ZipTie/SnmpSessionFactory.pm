package ZipTie::SnmpSessionFactory;

use strict;
use warnings;
use Net::SNMP;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub create
{
	my $type           = shift;
	my $connectionPath = shift;
	my $credentials    = $connectionPath->get_credentials();

	# DEFAULTS
	my $version          = 1;
	my $retries          = 2;
	my $timeout          = 1;
	my $v3Authentication = 'MD5';
	my $v3Privacy        = 'DES';
	my $domain           = 'udp';

	my $snmpProtocol = $connectionPath->get_protocol_by_name("SNMP");
	if ( defined $snmpProtocol )
	{
		my $versionString = $snmpProtocol->get_property('Version');
		if ( $versionString =~ /(\d)/ )
		{
			$version = $1;
		}
		my $retries = $snmpProtocol->get_property('Retries');
		if ( !defined $retries )
		{
			$retries = 2;
		}
		my $timeoutProperty = $snmpProtocol->get_property('Timeout(ms)');
		if (defined $timeoutProperty)
		{
			$timeout = $timeoutProperty / 1000;
			if ( $timeout < 1 )
			{
				$timeout = 1;
			}
			elsif ( $timeout > 60 )
			{
				$timeout = 60;
			}
		}
		my $v3Authentication = $snmpProtocol->get_property('V3 Authentication');
		if ( !$v3Authentication )
		{
			$v3Authentication = "MD5";
		}
		my $v3Privacy = $snmpProtocol->get_property('V3 Encryption');
		if ( !$v3Privacy )
		{
			$v3Privacy = "DES";
		}
	}

	my $session;
	my $error;

	my $host = $connectionPath->get_ip_address();
	if ( $host =~ /^(([\dA-Fa-f]{0,4})(:{1,2}|$))+$/ )
	{
		$domain = "udp/ipv6";
	}

	if ( $version =~ /[12]/ )
	{
		( $session, $error ) = Net::SNMP->session(
			-hostname  => $connectionPath->get_ip_address(),
			-version   => $version,
			-timeout   => $timeout,
			-retries   => $retries,
			-community => $credentials->{roCommunityString},
			-domain    => $domain,
		);
	}
	elsif ( $version =~ /3/ )
	{
		my $authPass = $credentials->{snmpAuthPassword};
		my $privPass = $credentials->{snmpPrivPassword};

		if ( $authPass && $privPass )
		{

			# AuthPriv
			( $session, $error ) = Net::SNMP->session(
				-hostname     => $connectionPath->get_ip_address(),
				-version      => $version,
				-timeout      => $timeout,
				-retries      => $retries,
				-authprotocol => $v3Authentication,
				-privprotocol => $v3Privacy,
				-username     => $credentials->{snmpUsername},
				-authpassword => $authPass,
				-privpassword => $privPass,
				-domain       => $domain,
			);
		}
		elsif ($authPass)
		{

			# AuthNoPriv
			( $session, $error ) = Net::SNMP->session(
				-hostname     => $connectionPath->get_ip_address(),
				-version      => $version,
				-timeout      => $timeout,
				-retries      => $retries,
				-authprotocol => $v3Authentication,
				-privprotocol => $v3Privacy,
				-username     => $credentials->{snmpUsername},
				-authpassword => $authPass,
				-domain       => $domain,
			);
		}
		else
		{

			# NoAuthNoPriv
			( $session, $error ) = Net::SNMP->session(
				-hostname     => $connectionPath->get_ip_address(),
				-version      => $version,
				-timeout      => $timeout,
				-retries      => $retries,
				-authprotocol => $v3Authentication,
				-privprotocol => $v3Privacy,
				-username     => $credentials->{snmpUsername},
				-domain       => $domain,
			);
		}
	}

	unless ($session)
	{
		if ( !defined($error) )
		{
			$error = "No Net::SNMP error could be found!";
		}
		elsif ( $error =~ /usmStatsWrongDigests/i )
		{
			$LOGGER->fatal("[$INVALID_CREDENTIALS]\nError while creating Net::SNMP session: $error");
		}
		else    
		{
			$LOGGER->fatal("[$SNMP_ERROR]\nError while creating Net::SNMP session: $error");
		}
	}
	return $session;
}

1;

__END__

=head1 NAME

ZipTie::SnmpSessionFactory - Creates a Net::SNMP session

=head1 SYNOPSIS

	use ZipTie::SnmpSessionFactory;
	my $snmpSession = ZipTie::SnmpSessionFactory->create( $connectionPath, $credentials );

=head1 DESCRIPTION

Given a connection path and credentials used in a standard ZipTie adapter, the SnmpSessionFactory
creates a Net::SNMP session.  An adapter that uses SNMP should use a single session across all
SNMP activity.

=head2 Methods

=over 12

=item C<create($connectionPath)>

This method returns the Net::SNMP session object.

Inputs:
	$connectionPath - contains the URL including the SNMP parameters such as timeout, retries, version, etc.

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
  Date: Jun 26, 2007

=cut

1;
