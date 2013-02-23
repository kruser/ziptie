# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Transport;

# $Id: Transport.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Base object for the Net::SNMP Transport Domain objects.

# Copyright (c) 2004-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

## Version of the Net::SNMP::Transport module

our $VERSION = v2.0.0;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Exporter );

our @EXPORT_OK = qw( TRUE FALSE );

our %EXPORT_TAGS = (
   domains => [
      qw( DOMAIN_UDP DOMAIN_UDPIPV4 DOMAIN_UDPIPV6 DOMAIN_UDPIPV6Z
          DOMAIN_TCPIPV4 DOMAIN_TCPIPV6 DOMAIN_TCPIPV6Z )  
   ], 
   msgsize => [ qw( MSG_SIZE_DEFAULT MSG_SIZE_MINIMUM MSG_SIZE_MAXIMUM ) ], 
   ports   => [ qw( SNMP_PORT SNMP_TRAP_PORT )                           ],
   retries => [ qw( RETRIES_DEFAULT RETRIES_MINIMUM RETRIES_MAXIMUM )    ],
   timeout => [ qw( TIMEOUT_DEFAULT TIMEOUT_MINIMUM TIMEOUT_MAXIMUM )    ]
);

Exporter::export_ok_tags( qw( domains msgsize ports retries timeout ) );

$EXPORT_TAGS{ALL} = [ @EXPORT_OK ];

## Transport Layer Domain definitions

# RFC 3417 Transport Mappings for SNMP
# Presuhn, Case, McCloghrie, Rose, and Waldbusser; December 2002

sub DOMAIN_UDP()            { '1.3.6.1.6.1.1' }  # snmpUDPDomain

# RFC 3419 Textual Conventions for Transport Addresses
# Consultant, Schoenwaelder, and Braunschweig; December 2002

sub DOMAIN_UDPIPV4()  { '1.3.6.1.2.1.100.1.1' }  # transportDomainUdpIpv4
sub DOMAIN_UDPIPV6()  { '1.3.6.1.2.1.100.1.2' }  # transportDomainUdpIpv6
sub DOMAIN_UDPIPV6Z() { '1.3.6.1.2.1.100.1.4' }  # transportDomainUdpIpv6z
sub DOMAIN_TCPIPV4()  { '1.3.6.1.2.1.100.1.5' }  # transportDomainTcpIpv4
sub DOMAIN_TCPIPV6()  { '1.3.6.1.2.1.100.1.6' }  # transportDomainTcpIpv6
sub DOMAIN_TCPIPV6Z() { '1.3.6.1.2.1.100.1.8' }  # transportDomainTcpIpv6z

## SNMP well-known ports

sub SNMP_PORT()              { 161 }
sub SNMP_TRAP_PORT()         { 162 }

## RFC 3411 - snmpEngineMaxMessageSize::=INTEGER (484..2147483647)

sub MSG_SIZE_DEFAULT()      {  484 }  
sub MSG_SIZE_MINIMUM()      {  484 }
sub MSG_SIZE_MAXIMUM()     { 65535 }   # 2147483647 is not reasonable

sub RETRIES_DEFAULT()         {  1 }
sub RETRIES_MINIMUM()         {  0 }
sub RETRIES_MAXIMUM()         { 20 }

sub TIMEOUT_DEFAULT()       {  5.0 }
sub TIMEOUT_MINIMUM()       {  1.0 }
sub TIMEOUT_MAXIMUM()       { 60.0 }

## Truth values

sub TRUE()                  { 0x01 }
sub FALSE()                 { 0x00 }

## Shared socket array indexes

sub _SHARED_SOCKET()           { 0 }   # Shared Socket object
sub _SHARED_REFC()             { 1 }   # Reference count
sub _SHARED_MAXSIZE()          { 2 }   # Shared maxMsgSize

## Package variables

our $DEBUG = FALSE;                    # Debug flag

our $AUTOLOAD;                         # Used by the AUTOLOAD method

our $SOCKETS = {};                     # List of shared sockets

## Load the module for the default Transport Domain.

require Net::SNMP::Transport::UDP;

# [public methods] -----------------------------------------------------------

sub new
{
   my ($class, %argv) = @_;

   my $domain = DOMAIN_UDPIPV4;
   my $error  = '';

   # See if a Transport Layer Domain argument has been passed.

   foreach (keys %argv) {

      if (/^-?domain$/i) {

         # Allow the user some flexability
         my $supported = {
            'udp4',          DOMAIN_UDPIPV4,
            'udpip4',        DOMAIN_UDPIPV4,
            'udpipv4',       DOMAIN_UDPIPV4,
            'udp/ipv4',      DOMAIN_UDPIPV4,
            DOMAIN_UDP,      DOMAIN_UDPIPV4,
            DOMAIN_UDPIPV4,  DOMAIN_UDPIPV4,
            'udp6',          DOMAIN_UDPIPV6,
            'udpip6',        DOMAIN_UDPIPV6,
            'udpipv6',       DOMAIN_UDPIPV6,
            'udp/ipv6',      DOMAIN_UDPIPV6,
            DOMAIN_UDPIPV6,  DOMAIN_UDPIPV6,
            DOMAIN_UDPIPV6Z, DOMAIN_UDPIPV6,
            'tcp4',          DOMAIN_TCPIPV4,
            'tcpip4',        DOMAIN_TCPIPV4,
            'tcpipv4',       DOMAIN_TCPIPV4,
            'tcp/ipv4',      DOMAIN_TCPIPV4,
            DOMAIN_TCPIPV4,  DOMAIN_TCPIPV4,
            'tcp6',          DOMAIN_TCPIPV6,
            'tcpip6',        DOMAIN_TCPIPV6,
            'tcpipv6',       DOMAIN_TCPIPV6,
            'tcp/ipv6',      DOMAIN_TCPIPV6,
            DOMAIN_TCPIPV6,  DOMAIN_TCPIPV6,
            DOMAIN_TCPIPV6Z, DOMAIN_TCPIPV6
         };

         my $key   = $_;
         my @match = grep(/^\Q$argv{$key}/i, keys(%{$supported}));

         if (@match > 1) {
            if (lc($argv{$key}) eq 'udp') {
               $match[0] = 'udp4';
            } elsif (lc($argv{$key}) eq 'tcp') {
               $match[0] = 'tcp4';
            } else { 
               $error = err_msg('Ambiguous Transport Domain [%s]', $argv{$_});
               return wantarray ? (undef, $error) : undef;
            }
         } elsif (@match != 1) {
            $error = err_msg(
               'Unknown or invalid Transport Domain [%s]', $argv{$_}
            );
            return wantarray ? (undef, $error) : undef;
         }

         $argv{$key} = $domain = $supported->{$match[0]}
      }

   }

   # Return the appropriate object based on the Transport Domain.  To
   # avoid consuming unnecessary resources, load the non-default modules 
   # only when requested.  Some modules require non-core modules and if
   # these modules are not present, we gracefully return an error.

   if ($domain eq DOMAIN_UDPIPV6) {
      if (defined($error = load_module('Net::SNMP::Transport::UDP6'))) {
         wantarray ? (undef, 'UDP/IPv6 support unavailable ' . $error) : undef;
      } else {
         Net::SNMP::Transport::UDP6->new(%argv);
      }
   } elsif ($domain eq DOMAIN_TCPIPV6) {
      if (defined($error = load_module('Net::SNMP::Transport::TCP6'))) {
         wantarray ? (undef, 'TCP/IPv6 support unavailable ' . $error) : undef;
      } else {
         Net::SNMP::Transport::TCP6->new(%argv);
      }
   } elsif ($domain eq DOMAIN_TCPIPV4) {
      if (defined($error = load_module('Net::SNMP::Transport::TCP'))) {
         wantarray ? (undef, 'TCP/IPv4 support unavailable ' . $error) : undef;
      } else {
         Net::SNMP::Transport::TCP->new(%argv);
      }
   } else {
      Net::SNMP::Transport::UDP->new(%argv);
   }

}

sub max_msg_size
{
   my ($this, $size) = @_;

   if (@_ == 2) {

      $this->_error_clear;

      if ($size =~ /^\d+$/) {
         if (($size >= MSG_SIZE_MINIMUM) && ($size <= MSG_SIZE_MAXIMUM)) { 
            $this->_shared_max_size($this->{_max_msg_size} = $size);
         } else {
            return $this->_error(
               'Invalid maxMsgSize value [%s], range %d - %d octets',
               $size, MSG_SIZE_MINIMUM, MSG_SIZE_MAXIMUM
            );
         }
      } else {
         return $this->_error('Expected positive numeric maxMsgSize value');
      }

   }

   $this->{_max_msg_size};
}

sub timeout
{
   my ($this, $timeout) = @_;

   if (@_ == 2) {

      $this->_error_clear;

      if ($timeout =~ /^\d+(\.\d+)?$/) {
         if (($timeout >= TIMEOUT_MINIMUM) && ($timeout <= TIMEOUT_MAXIMUM)) {
            $this->{_timeout} = $timeout;
         } else {
            return $this->_error(
               'Invalid timeout value [%s], range %03.01f - %03.01f seconds',
               $timeout, TIMEOUT_MINIMUM, TIMEOUT_MAXIMUM
            );
         }
      } else {
         return $this->_error('Expected positive numeric timeout value');
      }

   }

   $this->{_timeout};
}

sub retries
{
   my ($this, $retries) = @_;

   if (@_ == 2) {

      $this->_error_clear;

      if ($retries =~ /^\d+$/) {
         if (($retries >= RETRIES_MINIMUM) && ($retries <= RETRIES_MAXIMUM)) {
            $this->{_retries} = $retries;
         } else {
            return $this->_error(
               'Invalid retries value [%s], range %d - %d',
               $retries, RETRIES_MINIMUM, RETRIES_MAXIMUM
            );
         }
      } else {
         return $this->_error('Expected positive numeric retries value');
      }

   }

   $this->{_retries};
}

sub agent_addr
{
   '0.0.0.0';
}

sub connectionless
{
   TRUE;  
}

sub debug
{
   (@_ == 2) ? $DEBUG = ($_[1]) ? TRUE : FALSE : $DEBUG;
}

sub domain
{
   '0.0';
}

sub error
{
   $_[0]->{_error} || '';
}

sub fileno
{
   defined($_[0]->{_socket}) ? $_[0]->{_socket}->fileno : undef;
}

sub socket
{
   $_[0]->{_socket};
}

sub type
{
   '<unknown>'; # unknown(0)
}

sub sock_name
{
   $_[0]->{_sock_name};
}

sub sock_hostname
{
   $_[0]->{_sock_hostname} || $_[0]->sock_address;
}

sub sock_address
{
   $_[0]->_address($_[0]->sock_name);
}

sub sock_addr
{
   $_[0]->_addr($_[0]->sock_name);
}

sub sock_port
{
   $_[0]->_port($_[0]->sock_name);
}

sub sock_taddress
{
   $_[0]->_taddress($_[0]->sock_name);
}

sub sock_taddr
{
   $_[0]->_taddr($_[0]->sock_name);
}

sub sock_tdomain
{
   $_[0]->_tdomain($_[0]->sock_name);
}

sub dest_name
{
   $_[0]->{_dest_name};
}

sub dest_hostname
{
   $_[0]->{_dest_hostname} || $_[0]->dest_address;
}

sub dest_address
{
   $_[0]->_address($_[0]->dest_name);
}

sub dest_addr
{
   $_[0]->_addr($_[0]->dest_name);
}

sub dest_port
{
   $_[0]->_port($_[0]->dest_name);
}

sub dest_taddress
{
   $_[0]->_taddress($_[0]->dest_name);
}

sub dest_taddr
{
   $_[0]->_taddr($_[0]->dest_name);
}

sub dest_tdomain
{
   $_[0]->_tdomain($_[0]->dest_name);
}

sub peer_name
{
   $_[0]->{_socket}->peername || $_[0]->dest_name;
}

sub peer_hostname
{
   $_[0]->peer_address;
}

sub peer_address
{
   $_[0]->_address($_[0]->peer_name);
}

sub peer_addr
{
   $_[0]->_addr($_[0]->peer_name);
}

sub peer_port
{
   $_[0]->_port($_[0]->peer_name);
}

sub peer_taddress
{
   $_[0]->_taddress($_[0]->peer_name);
}

sub peer_taddr
{
   $_[0]->_taddr($_[0]->peer_name);
}

sub peer_tdomain
{
   $_[0]->_tdomain($_[0]->peer_name);
}

sub AUTOLOAD
{
   my $this = shift;

   return if $AUTOLOAD =~ /::DESTROY$/;

   $AUTOLOAD =~ s/.*://;

   if (ref($this)) {
      if (defined($this->{_socket}) && ($this->{_socket}->can($AUTOLOAD))) {
         $this->{_socket}->$AUTOLOAD(@_);
      } else { 
         $this->_error(
            'Feature not supported by this Transport Domain [%s]', $AUTOLOAD
         );
      }
   } else {
      die sprintf('Unsupported function call [%s]', $AUTOLOAD);
   }
}

sub DESTROY
{
   my ($this) = @_;

   # Connection-oriented transports do not share sockets.
   return unless ($this->connectionless);

   # Decrement the reference count and clear the shared
   # socket structure if no one is using it.

   return unless (defined($this->{_sock_name}) &&
                  exists($SOCKETS->{$this->{_sock_name}}));

   if (--$SOCKETS->{$this->{_sock_name}}->[_SHARED_REFC] < 1) {
      delete($SOCKETS->{$this->{_sock_name}});
   }
}

## Deprecated accessor methods

sub DEPRECATED
{
   my ($this, $method) = splice(@_, 0, 2);

   warn
      sprintf(
         "%s() is deprecated, use %s() instead at %s line %d.\n",
         (caller(1))[3], $method, (caller(1))[1], (caller(1))[2]
      );

   $this->${\$method}(@_);
}

sub name     { $_[0]->DEPRECATED('type');          }

sub srcaddr  { $_[0]->DEPRECATED('sock_addr');     }

sub srcport  { $_[0]->DEPRECATED('sock_port');     }

sub srchost  { $_[0]->DEPRECATED('sock_address');  }

sub srcname  { $_[0]->DEPRECATED('sock_address');  }

sub dstaddr  { $_[0]->DEPRECATED('dest_addr');     }

sub dstport  { $_[0]->DEPRECATED('dest_port');     }

sub dsthost  { $_[0]->DEPRECATED('dest_address');  }

sub dstname  { $_[0]->DEPRECATED('dest_hostname'); }

sub recvaddr { $_[0]->DEPRECATED('peer_addr');     }

sub recvport { $_[0]->DEPRECATED('peer_port');     }

sub recvhost { $_[0]->DEPRECATED('peer_address');  }


# [private methods] ----------------------------------------------------------

sub _new
{
   my ($class, %argv) = @_;

   my $this = bless {
      '_dest_hostname' => 'localhost',                # Destination hostname
      '_dest_name'     => undef,                      # Destination sockaddr
      '_error'         => undef,                      # Error message
      '_max_msg_size'  => $class->_msg_size_default,  # maxMsgSize
      '_retries'       => RETRIES_DEFAULT,            # Number of retries      
      '_socket'        => undef,                      # Socket object
      '_sock_hostname' => '',                         # Socket hostname
      '_sock_name'     => undef,                      # Socket sockaddr
      '_timeout'       => TIMEOUT_DEFAULT,            # Timeout period (secs)
   }, $class;

   # Default the values for the "name (sockaddr) hashes".

   my $sock_nh = { port => 0,         addr => $this->_addr_any      };
   my $dest_nh = { port => SNMP_PORT, addr => $this->_addr_loopback };

   # Validate the "port" arguments first to allow for a consistency
   # check with any values passed with the "address" arguments.

   my ($dest_port, $sock_port, $listen) = (undef, undef, 0); 

   foreach (keys %argv) {

      if (/^-?debug$/i) {
         $this->debug(delete($argv{$_}));
      } elsif (/^-?(?:de?st|peer)?port$/i) {
         $this->_service_resolve(delete($argv{$_}), $dest_nh);
         $dest_port = $dest_nh->{port};
      } elsif (/^-?(?:src|sock|local)port$/i) {
         $this->_service_resolve(delete($argv{$_}), $sock_nh);
         $sock_port = $sock_nh->{port};
      }

      if (defined($this->{_error})) {
         return wantarray ? (undef, $this->{_error}) : undef;
      }
   }

   # Validate the rest of the arguments.

   foreach (keys %argv) {

      if (/^-?domain$/i) {
         if ($argv{$_} ne $this->domain) {
            $this->_error('Invalid Transport Domain [%s]', $argv{$_});
         }
      } elsif ((/^-?hostname$/i) || (/^-?(?:de?st|peer)?addr$/i)) {
         $this->_hostname_resolve($this->{_dest_hostname} = $argv{$_}, $dest_nh);
         if (defined($dest_port) && ($dest_port != $dest_nh->{port})) {
            $this->_error(
               'Inconsistent %s port information specified [%d != %d]',
               $this->type, $dest_port, $dest_nh->{port}
            );
         }
      } elsif (/^-?(?:src|sock|local)addr$/i) {
         $this->_hostname_resolve($this->{_sock_hostname} = $argv{$_}, $sock_nh);
         if (defined($sock_port) && ($sock_port != $sock_nh->{port})) {
            $this->_error(
               'Inconsistent %s port information specified [%d != %d]',
               $this->type, $sock_port, $sock_nh->{port}
            );
         }
      } elsif (/^-?listen$/i) {
         if (($argv{$_} !~ /^\d+$/) || ($argv{$_} < 1)) {
            $this->_error('Expected positive non-zero listen queue size');
         } elsif (!$this->connectionless) {
            $listen = $argv{$_};
         }
      } elsif ((/^-?maxmsgsize$/i) || (/^-?mtu$/i)) {
         $this->max_msg_size($argv{$_});
      } elsif (/^-?retries$/i) {
         $this->retries($argv{$_});
      } elsif (/^-?timeout$/i) {
         $this->timeout($argv{$_});
      } else {
         $this->_error("Invalid argument '%s'", $_);
      }

      if (defined($this->{_error})) {
         return wantarray ? (undef, $this->{_error}) : undef;
      }

   }

   # Pack the socket name (sockaddr) information.
   $this->{_sock_name} = $this->_name_pack($sock_nh);

   # Pack the destination name (sockaddr) information.
   $this->{_dest_name} = $this->_name_pack($dest_nh);

   # For all connection-oriented transports and for each unique source 
   # address for connectionless transports, create a new socket. 

   if ((!$this->connectionless) || (!exists($SOCKETS->{$this->{_sock_name}}))) {

      # Create a new IO::Socket object.

      if (!defined($this->{_socket} = $this->_socket_create)) {
         $this->_perror('Failed to open %s socket', $this->type);
         return wantarray ? (undef, $this->{_error}) : undef
      }

      DEBUG_INFO('opened %s socket [%d]', $this->type, $this->fileno);

      # Bind the socket.

      if (!defined($this->{_socket}->bind($this->{_sock_name}))) {
         $this->_perror('Failed to bind %s socket', $this->type);
         return wantarray ? (undef, $this->{_error}) : undef
      }

      # For connection-oriented transports, we either listen or connect.

      if (!$this->connectionless) {
         if ($listen) {
            if (!defined($this->{_socket}->listen($listen))) {
               $this->_perror('Failed to listen on %s socket', $this->type);
               return wantarray ? (undef, $this->{_error}) : undef
            }
         } else {
            if (!defined($this->{_socket}->connect($this->{_dest_name}))) {
               $this->_perror(
                  "Failed to connect to remote host '%s'", $this->dest_hostname 
               );
               return wantarray ? (undef, $this->{_error}) : undef
            }
         }
      }

      # Flag the socket as non-blocking outside of socket creation or 
      # the object instantiation fails on some systems (e.g. MSWin32). 

      $this->{_socket}->blocking(FALSE);

      # Add the socket to the global socket list with a reference
      # count to track when to close the socket and the maxMsgSize
      # associated with this new object for connectionless transports.

      if ($this->connectionless) {
         $SOCKETS->{$this->{_sock_name}} = [ 
            $this->{_socket}, 1, $this->{_max_msg_size}
         ];
      }

   } else {

      # Bump up the reference count.
      $SOCKETS->{$this->{_sock_name}}->[_SHARED_REFC]++;

      # Assign the socket to the object.
      $this->{_socket} = $SOCKETS->{$this->{_sock_name}}->[_SHARED_SOCKET]; 

      # Adjust the shared maxMsgSize if necessary.
      $this->_shared_max_size($this->{_max_msg_size});

      DEBUG_INFO('reused %s socket [%d]', $this->type, $this->fileno);

   }

   # Return the object and empty error message (in list context)
   wantarray ? ($this, '') : $this;
}

sub _service_resolve
{
   my ($this, $serv, $nh) = @_;

   $nh->{port} = undef;

   if ($serv !~ /^\d+$/) {
      my $port = ($serv =~ s/\((\d+)\)$//) ? ($1 <= 65535) ? $1 : undef : undef;
      $nh->{port} = getservbyname($serv, $this->_protocol_name) || $port;
      if (!defined($nh->{port})) {
         $this->_error(
            "Unable to resolve %s service name '%s'", $this->type, $_[1]
         );
      }
   } elsif ($serv > 65535) {
      $this->_error('Invalid %s port number specified [%s]', $this->type, $serv);
   } else {
      $nh->{port} = $serv;
   }

}

sub _shared_max_size
{
   my ($this, $size) = @_;

   # Connection-oriented transports do not share sockets.
   if (!$this->connectionless) {
      return $this->{_max_msg_size};
   }

   if (@_ == 2) {

      # Handle calls during object creation.
      if (!defined($this->{_sock_name})) {
         return $this->{_max_msg_size};
      }

      # Update the shared maxMsgSize if the passed
      # value is greater than the current size.

      if ($size > $SOCKETS->{$this->{_sock_name}}->[_SHARED_MAXSIZE]) {
         $SOCKETS->{$this->{_sock_name}}->[_SHARED_MAXSIZE] = $size;
      }

   }

   $SOCKETS->{$this->{_sock_name}}->[_SHARED_MAXSIZE];
}

sub _msg_size_default
{
   MSG_SIZE_DEFAULT;
}

sub _error
{
   my $this = shift;

   if (!defined($this->{_error})) {
      $this->{_error} = (@_ > 1) ? sprintf(shift(@_), @_) : $_[0];
      if ($this->debug) {
         printf("error: [%d] %s(): %s\n",
            (caller(0))[2], (caller(1))[3], $this->{_error}
         );
      }
   }

   return;
}

sub strerror()
{
   if ($! =~ /^Unknown error/) {
      return sprintf('%s', $^E) if ($^E);
      require Errno;
      map { return sprintf('Error %s', $_) if ($!{$_}); } keys(%!);
      return sprintf('%s (%d)', $!, $!);
   }

   $! ? sprintf('%s', $!) : 'No error';
}

sub _perror
{
   my $this = shift;

   if (!defined($this->{_error})) {
      $this->{_error}  = ((@_ > 1) ? sprintf(shift(@_), @_) : $_[0]) || '';
      $this->{_error} .= ($this->{_error}) ? ': ' . strerror() : strerror();
      if ($this->debug) {
         printf("error: [%d] %s(): %s\n",
            (caller(0))[2], (caller(1))[3], $this->{_error}
         );
      }
   }

   return;
}

sub _error_clear
{
   $! = 0;
   $_[0]->{_error} = undef;
}

{
   my %modules;

   sub load_module
   {
      my ($module) = @_;

      # We attempt to load the required module under the protection of an 
      # eval statement.  If there is a failure, typically it is due to a 
      # missing module required by the requested module and we attempt to 
      # simplify the error message by just listing that module.  We also 
      # need to track failures since require() only produces an error on 
      # the first attempt to load the module.

      # NOTE: Contrary to our typical convention, a return value of "undef"
      # actually means success and a defined value means error.

      return $modules{$module} if (exists($modules{$module}));

      if (!eval("require $module")) {
         if ($@ =~ /locate (\S+\.pm)/) {
            $modules{$module} = err_msg('(Required module %s not found)', $1);
         } else {
            $modules{$module} = err_msg('(%s)', $@);
         }
      } else {
         $modules{$module} = undef;  
      }
   }
}

sub err_msg(@)
{
   my $msg = (@_ > 1) ? sprintf(shift(@_), @_) : $_[0]; 

   if ($DEBUG) {
      printf("error: [%d] %s(): %s\n", (caller(0))[2], (caller(1))[3], $msg);
   }

   $msg;
}

sub DEBUG_INFO
{
   return unless $DEBUG;

   printf(
      sprintf('debug: [%d] %s(): ', (caller(0))[2], (caller(1))[3]) .
      ((@_ > 1) ? shift(@_) : '%s') .
      "\n",
      @_
   );

   $DEBUG;
}

# ============================================================================
1; # [end Net::SNMP::Transport]
