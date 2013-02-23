# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Transport::UDP6;

# $Id: UDP6.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object that handles the UDP/IPv6 Transport Domain for the SNMP Engine.

# Copyright (c) 2004-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Transport::UDP qw( DOMAIN_UDPIPV6 DOMAIN_UDPIPV6Z );

use IO::Socket qw( SOCK_DGRAM );

use Socket6 0.19 qw(
   in6addr_any in6addr_loopback getaddrinfo PF_INET6 pack_sockaddr_in6_all
   getnameinfo NI_NUMERICHOST NI_NUMERICSERV unpack_sockaddr_in6_all
);

## Version of the Net::SNMP::Transport::UDP6 module

our $VERSION = v2.0.0;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Net::SNMP::Transport::UDP Exporter );

sub import
{
   Net::SNMP::Transport::UDP->export_to_level(1, @_);
}

## RFC 3411 - snmpEngineMaxMessageSize::=INTEGER (484..2147483647)

sub MSG_SIZE_DEFAULT_UDP6() { 1452 } # Ethernet(1500) - IPv6(40) - UDP(8)

# [public methods] -----------------------------------------------------------

sub domain
{
   DOMAIN_UDPIPV6; # transportDomainUdpIpv6
}

sub type 
{
  'UDP/IPv6'; # udpIpv6(2)
}

sub agent_addr
{
   '0.0.0.0';
}

sub sock_flowinfo
{
   $_[0]->_flowinfo($_[0]->sock_name);
}

sub sock_scope_id
{
   $_[0]->_scope_id($_[0]->sock_name);
}

sub sock_tzone
{
   $_[0]->sock_scope_id;
}

sub dest_flowinfo
{
   $_[0]->_flowinfo($_[0]->dest_name);
}

sub dest_scope_id
{
   $_[0]->_scope_id($_[0]->dest_name);
}

sub dest_tzone
{
   $_[0]->dest_scope_id;
}

sub recv_flowinfo
{
   $_[0]->_flowinfo($_[0]->peer_name);
}

sub recv_scope_id
{
   $_[0]->_scope_id($_[0]->peer_name);
}

sub peer_tzone
{
   $_[0]->peer_scope_id;
}

# [private methods] ----------------------------------------------------------

sub _msg_size_default
{
   MSG_SIZE_DEFAULT_UDP6;
}

sub _addr_any
{ 
   in6addr_any; 
}

sub _addr_loopback
{
   in6addr_loopback; 
}

sub _hostname_resolve
{
   my ($this, $host, $nh) = @_;

   $nh->{addr} = undef;

   # See if the service/port was included in the address.

   my $serv = ($host =~ s/^\[(.+)\]:([\w\(\)\/]+)$/$1/) ? $2 : undef;

   if (defined($serv) && (!defined($this->_service_resolve($serv, $nh)))) {
      return $this->_error('Failed to resolve %s service', $this->type);
   }

   # See if the scope zone index was included in the address.

   $nh->{scope_id} = ($host =~ s/%(\d+)$//) ? $1 : 0;

   # Resolve the address. 

   my @info = getaddrinfo(($_[1] = $host), '', PF_INET6);

   if (@info >= 5) {
      $nh->{addr} = $this->_addr($info[3]);
      $nh->{flowinfo} = $this->_flowinfo($info[3]);
      $nh->{scope_id} ||= $this->_scope_id($info[3]); 
   } else {
      DEBUG_INFO('getaddrinfo(): %s', $info[0]);
      if ((my @host = split(':', $host)) == 2) { # <hostname>:<service> 
         $this->_hostname_resolve(($_[1] = sprintf('[%s]:%s', @host)), $nh);
      }
   }

   if (!defined($nh->{addr})) {
      $this->_error("Unable to resolve %s address '%s'", $this->type, $host); 
   } else {
      $nh->{addr};
   }
}

sub _name_pack
{
   pack_sockaddr_in6_all(
      $_[1]->{port}, $_[1]->{flowinfo} || 0, 
      $_[1]->{addr}, $_[1]->{scope_id} || 0 
   );
}

sub _socket_create
{
   IO::Socket->new->socket(PF_INET6, SOCK_DGRAM, (getprotobyname('udp'))[2]);
}

sub _address
{
   my $a = (getnameinfo($_[1], (NI_NUMERICHOST | NI_NUMERICSERV)))[0];
   $a =~ m/(.*)%(?:\d+)$/ ? $1 : $a; 
}

sub _addr
{
   (unpack_sockaddr_in6_all($_[1]))[2];
}

sub _port
{
   (unpack_sockaddr_in6_all($_[1]))[0];
}

sub _taddress
{
   my $s = $_[0]->_scope_id($_[1]);
   $s = $s ? sprintf('%%%d', $s) : '';
   sprintf('[%s%s]:%d', $_[0]->_address($_[1]), $s, $_[0]->_port($_[1]));
}

sub _taddr
{
   my $s = $_[0]->_scope_id($_[1]);
   $s = $s ? pack('N', $s) : '';
   $_[0]->_addr($_[1]) . $s . pack('n', $_[0]->_port($_[1]));
}

sub _tdomain
{
   $_[0]->_scope_id($_[1]) ? DOMAIN_UDPIPV6Z : DOMAIN_UDPIPV6;
}

sub _scope_id
{
   (unpack_sockaddr_in6_all($_[1]))[3];
}

sub _flowinfo
{
   (unpack_sockaddr_in6_all($_[1]))[1];
}

sub DEBUG_INFO
{
   return unless $Net::SNMP::Transport::DEBUG;

   printf(
      sprintf('debug: [%d] %s(): ', (caller(0))[2], (caller(1))[3]) .
      ((@_ > 1) ? shift(@_) : '%s') . 
      "\n",
      @_
   );

   $Net::SNMP::Transport::DEBUG;
}

# ============================================================================
1; # [end Net::SNMP::Transport::UDP6]
