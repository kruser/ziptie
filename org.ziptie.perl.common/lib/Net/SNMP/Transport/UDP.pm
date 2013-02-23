# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Transport::UDP;

# $Id: UDP.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object that handles the UDP/IPv4 Transport Domain for the SNMP Engine.

# Copyright (c) 2001-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Transport qw( DOMAIN_UDPIPV4 );

use IO::Socket qw(
   INADDR_ANY INADDR_LOOPBACK inet_aton PF_INET SOCK_DGRAM sockaddr_in 
   inet_ntoa
);

## Version of the Net::SNMP::Transport::UDP module

our $VERSION = v3.0.0;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Net::SNMP::Transport Exporter );

sub import
{
   Net::SNMP::Transport->export_to_level(1, @_);
}

## RFC 3411 - snmpEngineMaxMessageSize::=INTEGER (484..2147483647)

sub MSG_SIZE_DEFAULT_UDP4() { 1472 } # Ethernet(1500) - IPv4(20) - UDP(8)

# [public methods] -----------------------------------------------------------

sub new
{
   shift->SUPER::_new(@_);
}

sub send
{
   my $this = shift;

   $this->_error_clear;

   if (length($_[0]) > $this->{_max_msg_size}) {
      return $this->_error('Message size exceeded maxMsgSize');
   }

   my $bytes = $this->{_socket}->send($_[0], 0, $this->{_dest_name});

   defined($bytes) ? $bytes : $this->_perror('Send failure');
}

sub recv
{
   my $this = shift;

   $this->_error_clear;

   my $name = $this->{_socket}->recv($_[0], $this->_shared_max_size, 0);

   defined($name) ? $name : $this->_perror('Receive failure');
}

sub domain
{
   DOMAIN_UDPIPV4; # transportDomainUdpIpv4
}

sub type 
{
   'UDP/IPv4'; # udpIpv4(1)
}

sub agent_addr 
{
   my ($this) = @_;

   $this->_error_clear;

   my $name = $this->{_socket}->sockname || $this->{_sock_name};

   if ($this->{_socket}->connect($this->{_dest_name})) {
      $name = $this->{_socket}->sockname || $this->{_sock_name};
      if (!$this->{_socket}->connect((pack('x') x length($name)))) {
         $this->_perror('Failed to disconnect');
      }
   }

   $this->_address($name);
}

# [private methods] ----------------------------------------------------------

sub _protocol_name
{
   'udp';
}

sub _msg_size_default
{
   MSG_SIZE_DEFAULT_UDP4;
}

sub _addr_any
{
   INADDR_ANY;
}

sub _addr_loopback
{
   INADDR_LOOPBACK;
}

sub _hostname_resolve
{
   my ($this, $host, $nh) = @_;

   $nh->{addr} = undef;

   # See if the the service/port was included in the address.

   my $serv = ($host =~ s/:([\w\(\)\/]+)$//) ? $1 : undef;

   if (defined($serv) && (!defined($this->_service_resolve($serv, $nh)))) {
      return $this->_error('Failed to resolve %s service', $this->type);
   }

   # Resolve the address.

   if (!defined($nh->{addr} = inet_aton($_[1] = $host))) {
      $this->_error("Unable to resolve %s address '%s'", $this->type, $host);
   } else {
      $nh->{addr};
   }
} 

sub _name_pack
{
   sockaddr_in($_[1]->{port}, $_[1]->{addr});
}

sub _socket_create
{
   IO::Socket->new->socket(PF_INET, SOCK_DGRAM, (getprotobyname('udp'))[2]);
}

sub _address
{
   inet_ntoa($_[0]->_addr($_[1]));
}

sub _addr
{
   (sockaddr_in($_[1]))[1];
}

sub _port
{
   (sockaddr_in($_[1]))[0];
}

sub _taddress
{
   sprintf('%s:%d', $_[0]->_address($_[1]), $_[0]->_port($_[1]));
}

sub _taddr
{
   $_[0]->_addr($_[1]) . pack('n', $_[0]->_port($_[1]));
}

sub _tdomain
{
    DOMAIN_UDPIPV4; 
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
1; # [end Net::SNMP::Transport::UDP]
