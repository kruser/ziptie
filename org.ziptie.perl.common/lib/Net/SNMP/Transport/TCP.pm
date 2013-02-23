# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Transport::TCP;

# $Id: TCP.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object that handles the TCP/IPv4 Transport Domain for the SNMP Engine.

# Copyright (c) 2004-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Transport qw( MSG_SIZE_MAXIMUM DOMAIN_TCPIPV4 TRUE FALSE );

use Net::SNMP::Message qw( SEQUENCE );

use IO::Socket qw(
   INADDR_ANY INADDR_LOOPBACK inet_aton sockaddr_in PF_INET SOCK_STREAM 
   inet_ntoa
);

## Version of the Net::SNMP::Transport::TCP module

our $VERSION = v2.0.0;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Net::SNMP::Transport Exporter );

sub import
{
   Net::SNMP::Transport->export_to_level(1, @_);
}

## RFC 3411 - snmpEngineMaxMessageSize::=INTEGER (484..2147483647)

sub MSG_SIZE_DEFAULT_TCP4() { 1460 } # Ethernet(1500) - IPv4(20) - TCP(20)

# [public methods] -----------------------------------------------------------

sub new
{
   my ($this, $error) = shift->SUPER::_new(@_);

   if (defined($this)) {
      if (!defined($this->_reasm_init)) {
         return wantarray ? (undef, $this->error) : undef;
      }
   }
   
   wantarray ? ($this, $error) : $this;
}

sub accept
{
   my ($this) = @_;

   $this->_error_clear;

   my $socket = $this->{_socket}->accept;

   if (!defined($socket)) {
      return $this->_perror('Failed to accept connection');
   }

   DEBUG_INFO('opened %s socket [%d]', $this->type, $socket->fileno);

   # Create a new object by copying the current object.

   my $new = bless { %{$this} }, ref($this); 

   # Now update the appropriate fields.

   $new->{_socket}        = $socket;
   $new->{_dest_name}     = $socket->peername;
   $new->{_dest_hostname} = $new->_address($new->{_dest_name});

   if (!defined($new->_reasm_init)) {
      return $this->_error($new->error);
   }

   # Return the new object.
   $new;
}

sub send
{
   my $this = shift;

   $this->_error_clear;

   if (length($_[0]) > $this->{_max_msg_size}) {
      return $this->_error('Message size exceeded maxMsgSize');
   }

   if (!defined($this->{_socket}->connected)) {
      return $this->_error(
         "Not connected to remote host '%s'", $this->dest_hostname
      );
   }

   my $bytes = $this->{_socket}->send($_[0], 0);

   defined($bytes) ? $bytes : $this->_perror('Send failure');
}

sub recv
{
   my $this = shift;

   $this->_error_clear;

   if (!defined($this->{_socket}->connected)) {
      $this->_reasm_reset;
      return $this->_error(
         "Not connected to remote host '%s'", $this->dest_hostname
      );
   }

   # RCF 3430 Section 2.1 - "It is possible that the underlying TCP 
   # implementation delivers byte sequences that do not align with 
   # SNMP message boundaries.  A receiving SNMP engine MUST therefore 
   # use the length field in the BER-encoded SNMP message to separate 
   # multiple requests sent over a single TCP connection (framing).  
   # An SNMP engine which looses framing (for example due to ASN.1 
   # parse errors) SHOULD close the TCP connection."

   # If the reassembly bufer is empty then there is no partial message
   # waiting for completion.  We must then process the message length
   # to properly determine how much data to receive.

   my $name;

   if ($this->{_reasm_buffer} eq '') {

      if (!defined($this->{_reasm_object})) {
         return $this->_error('Reassembly object not defined');
      }

      # Read enough data to parse the ASN.1 type and length.

      $name = $this->{_socket}->recv($this->{_reasm_buffer}, 6, 0);

      if ((!defined($name)) || ($!)) {
         $this->_reasm_reset;
         return $this->_perror('Receive failure');   
      } elsif (!length($this->{_reasm_buffer})) {
         $this->_reasm_reset;
         return $this->_error(
            "Connection closed by remote host '%s'", $this->dest_hostname
         );
      }
 
      $this->{_reasm_object}->append($this->{_reasm_buffer});

      $this->{_reasm_length} = $this->{_reasm_object}->process(SEQUENCE) || 0;

      if ((!$this->{_reasm_length}) || 
           ($this->{_reasm_length} > MSG_SIZE_MAXIMUM)) 
      {
         $this->_reasm_reset;
         return $this->_error(
            "Message framing lost with remote host '%s'", $this->dest_hostname
         );
      }

      # Add in the bytes parsed to define the expected message length.
      $this->{_reasm_length} += $this->{_reasm_object}->index;

   }

   # Setup a temporary buffer for the message and set the length
   # based upon the contents of the reassembly buffer. 

   my $buf = '';
   my $buf_len = length($this->{_reasm_buffer});

   # Read the rest of the message.

   $name = $this->{_socket}->recv($buf, ($this->{_reasm_length} - $buf_len), 0);

   if ((!defined($name)) || ($!)) {
      $this->_reasm_reset;
      return $this->_perror('Receive failure');
   } elsif (!length($buf)) {
      $this->_reasm_reset;
      return $this->_error(
         "Connection closed by remote host '%s'", $this->dest_hostname
      );
   }

   # Now see if we have the complete message.  If it is not complete,
   # success is returned with an empty buffer.  The application must
   # continue to call recv() until the message is reassembled.

   $buf_len += length($buf);
   $this->{_reasm_buffer} .= $buf;

   if ($buf_len < $this->{_reasm_length}) {
      DEBUG_INFO(
         'message is incomplete (expect %u bytes, have %u bytes)',
         $this->{_reasm_length}, $buf_len
      );
      $_[0] = '';
      return $name || $this->{_socket}->connected;
   } 

   # Validate the maxMsgSize.
   if ($buf_len > $this->{_max_msg_size}) {
      $this->_reasm_reset;
      return $this->_error('Incoming message size exceeded maxMsgSize');
   }  

   # The message is complete, copy the buffer to the caller.
   $_[0] = $this->{_reasm_buffer};

   # Clear the reassembly buffer and length.
   $this->_reasm_reset;
 
   $name || $this->{_socket}->connected;
}

sub connectionless
{
   FALSE;
}

sub domain
{
   DOMAIN_TCPIPV4; # transportDomainTcpIpv4
}

sub type 
{
   'TCP/IPv4'; # tcpIpv4(5)
}

sub agent_addr
{
   $_[0]->_address($_[0]->{_socket}->sockname || $_[0]->{_sock_name});
}

# [private methods] ----------------------------------------------------------

sub _protocol_name
{
   'tcp';
}

sub _msg_size_default
{
   MSG_SIZE_DEFAULT_TCP4;
}

sub _reasm_init
{
   my ($this) = @_;

   my $error;

   ($this->{_reasm_object}, $error) = Net::SNMP::Message->new;

   if (!defined($this->{_reasm_object})) {
      return $this->_error('Failed to create reassembly object: %s', $error);
   }

   $this->_reasm_reset;

   TRUE;
}

sub _reasm_reset
{
   my ($this) = @_;

   if (defined($this->{_reasm_object})) {
      $this->{_reasm_object}->error(undef);
      $this->{_reasm_object}->clear;
   }

   $this->{_reasm_buffer} = '';
   $this->{_reasm_length} = 0;
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
   IO::Socket->new->socket(PF_INET, SOCK_STREAM, (getprotobyname('tcp'))[2]);
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
    DOMAIN_TCPIPV4; # transportDomainTcpIpv4
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
1; # [end Net::SNMP::Transport::TCP]
