# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Message;

# $Id: Message.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object used to represent a SNMP message. 

# Copyright (c) 2001-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;
use bytes;

use Math::BigInt();

## Version of the Net::SNMP::Message module

our $VERSION = v2.0.3;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Exporter );

our @EXPORT_OK = qw( TRUE FALSE );

our %EXPORT_TAGS = (
   generictrap    => [
      qw( COLD_START WARM_START LINK_DOWN LINK_UP AUTHENTICATION_FAILURE
          EGP_NEIGHBOR_LOSS ENTERPRISE_SPECIFIC )
   ],
   msgFlags       => [ 
      qw( MSG_FLAGS_NOAUTHNOPRIV MSG_FLAGS_AUTH MSG_FLAGS_PRIV 
          MSG_FLAGS_REPORTABLE MSG_FLAGS_MASK )
   ],
   securityLevels => [
      qw( SECURITY_LEVEL_NOAUTHNOPRIV SECURITY_LEVEL_AUTHNOPRIV
          SECURITY_LEVEL_AUTHPRIV )
   ],
   securityModels => [
      qw( SECURITY_MODEL_ANY SECURITY_MODEL_SNMPV1 SECURITY_MODEL_SNMPV2C
          SECURITY_MODEL_USM )
   ],
   translate      => [
      qw( TRANSLATE_NONE TRANSLATE_OCTET_STRING TRANSLATE_NULL 
          TRANSLATE_TIMETICKS TRANSLATE_OPAQUE TRANSLATE_NOSUCHOBJECT 
          TRANSLATE_NOSUCHINSTANCE TRANSLATE_ENDOFMIBVIEW TRANSLATE_UNSIGNED 
          TRANSLATE_ALL )
   ],
   types          => [
      qw( INTEGER INTEGER32 OCTET_STRING NULL OBJECT_IDENTIFIER SEQUENCE
          IPADDRESS COUNTER COUNTER32 GAUGE GAUGE32 UNSIGNED32 TIMETICKS
          OPAQUE COUNTER64 NOSUCHOBJECT NOSUCHINSTANCE ENDOFMIBVIEW
          GET_REQUEST GET_NEXT_REQUEST GET_RESPONSE SET_REQUEST TRAP
          GET_BULK_REQUEST INFORM_REQUEST SNMPV2_TRAP REPORT )
   ],
   utilities      => [ qw( asn1_ticks_to_time asn1_itoa ) ],
   versions       => [ qw( SNMP_VERSION_1 SNMP_VERSION_2C SNMP_VERSION_3 ) ]
);

Exporter::export_ok_tags( 
   qw( generictrap msgFlags securityLevels securityModels translate types 
       utilities versions ) 
);

$EXPORT_TAGS{ALL} = [ @EXPORT_OK ];

## ASN.1 Basic Encoding Rules type definitions

sub INTEGER()                  { 0x02 }  # INTEGER
sub INTEGER32()                { 0x02 }  # Integer32           - SNMPv2c
sub OCTET_STRING()             { 0x04 }  # OCTET STRING
sub NULL()                     { 0x05 }  # NULL
sub OBJECT_IDENTIFIER()        { 0x06 }  # OBJECT IDENTIFIER
sub SEQUENCE()                 { 0x30 }  # SEQUENCE

sub IPADDRESS()                { 0x40 }  # IpAddress
sub COUNTER()                  { 0x41 }  # Counter
sub COUNTER32()                { 0x41 }  # Counter32           - SNMPv2c
sub GAUGE()                    { 0x42 }  # Gauge
sub GAUGE32()                  { 0x42 }  # Gauge32             - SNMPv2c
sub UNSIGNED32()               { 0x42 }  # Unsigned32          - SNMPv2c
sub TIMETICKS()                { 0x43 }  # TimeTicks
sub OPAQUE()                   { 0x44 }  # Opaque
sub COUNTER64()                { 0x46 }  # Counter64           - SNMPv2c

sub NOSUCHOBJECT()             { 0x80 }  # noSuchObject        - SNMPv2c
sub NOSUCHINSTANCE()           { 0x81 }  # noSuchInstance      - SNMPv2c
sub ENDOFMIBVIEW()             { 0x82 }  # endOfMibView        - SNMPv2c

sub GET_REQUEST()              { 0xa0 }  # GetRequest-PDU
sub GET_NEXT_REQUEST()         { 0xa1 }  # GetNextRequest-PDU
sub GET_RESPONSE()             { 0xa2 }  # GetResponse-PDU
sub SET_REQUEST()              { 0xa3 }  # SetRequest-PDU
sub TRAP()                     { 0xa4 }  # Trap-PDU
sub GET_BULK_REQUEST()         { 0xa5 }  # GetBulkRequest-PDU  - SNMPv2c
sub INFORM_REQUEST()           { 0xa6 }  # InformRequest-PDU   - SNMPv2c
sub SNMPV2_TRAP()              { 0xa7 }  # SNMPv2-Trap-PDU     - SNMPv2c
sub REPORT()                   { 0xa8 }  # Report-PDU          - SNMPv3

## SNMP RFC version definitions

sub SNMP_VERSION_1()           { 0x00 }  # RFC 1157 SNMPv1
sub SNMP_VERSION_2C()          { 0x01 }  # RFC 1901 Community-based SNMPv2
sub SNMP_VERSION_3()           { 0x03 }  # RFC 3411 SNMPv3

## RFC 1157 - generic-trap definitions

sub COLD_START()                  { 0 }  # coldStart(0)
sub WARM_START()                  { 1 }  # warmStart(1)
sub LINK_DOWN()                   { 2 }  # linkDown(2)
sub LINK_UP()                     { 3 }  # linkUp(3)
sub AUTHENTICATION_FAILURE()      { 4 }  # authenticationFailure(4)
sub EGP_NEIGHBOR_LOSS()           { 5 }  # egpNeighborLoss(5)
sub ENTERPRISE_SPECIFIC()         { 6 }  # enterpriseSpecific(6)

## RFC 3412 - msgFlags::=OCTET STRING

sub MSG_FLAGS_NOAUTHNOPRIV()   { 0x00 }  # Means noAuthNoPriv
sub MSG_FLAGS_AUTH()           { 0x01 }  # authFlag
sub MSG_FLAGS_PRIV()           { 0x02 }  # privFlag
sub MSG_FLAGS_REPORTABLE()     { 0x04 }  # reportableFlag
sub MSG_FLAGS_MASK()           { 0x07 }

## RFC 3411 - SnmpSecurityLevel::=TEXTUAL-CONVENTION

sub SECURITY_LEVEL_NOAUTHNOPRIV() { 1 }  # noAuthNoPriv
sub SECURITY_LEVEL_AUTHNOPRIV()   { 2 }  # authNoPriv
sub SECURITY_LEVEL_AUTHPRIV()     { 3 }  # authPriv

## RFC 3411 - SnmpSecurityModel::=TEXTUAL-CONVENTION

sub SECURITY_MODEL_ANY()          { 0 }  # Reserved for 'any'
sub SECURITY_MODEL_SNMPV1()       { 1 }  # Reserved for SNMPv1
sub SECURITY_MODEL_SNMPV2C()      { 2 }  # Reserved for SNMPv2c
sub SECURITY_MODEL_USM()          { 3 }  # User-Based Security Model (USM) 

## Translation masks

sub TRANSLATE_NONE()           { 0x00 }  # Bit masks used to determine
sub TRANSLATE_OCTET_STRING()   { 0x01 }  # if a specific ASN.1 type is
sub TRANSLATE_NULL()           { 0x02 }  # translated into a "human
sub TRANSLATE_TIMETICKS()      { 0x04 }  # readable" form.
sub TRANSLATE_OPAQUE()         { 0x08 }
sub TRANSLATE_NOSUCHOBJECT()   { 0x10 }
sub TRANSLATE_NOSUCHINSTANCE() { 0x20 }
sub TRANSLATE_ENDOFMIBVIEW()   { 0x40 }
sub TRANSLATE_UNSIGNED()       { 0x80 }
sub TRANSLATE_ALL()            { 0xff }

## Truth values 

sub TRUE()                     { 0x01 } 
sub FALSE()                    { 0x00 }

## Package variables

our $DEBUG = FALSE;                      # Debug flag

our $AUTOLOAD;                           # Used by the AUTOLOAD method

# [public methods] -----------------------------------------------------------

sub new
{
   my ($class, %argv) = @_;

   # Create a new data structure for the object
   my $this = bless {
      '_buffer'      =>  '',              # Serialized message buffer
      '_error'       =>  undef,           # Error message
      '_index'       =>  0,               # Buffer index
      '_leading_dot' =>  FALSE,           # Prepend leading dot on OIDs
      '_length'      =>  0,               # Buffer length
      '_security'    =>  undef,           # Security Model object
      '_translate'   =>  TRANSLATE_NONE,  # Translation mode
      '_transport'   =>  undef,           # Transport Layer object
      '_version'     =>  SNMP_VERSION_1   # SNMP version
   }, $class;

   # Validate the passed arguments

   foreach (keys %argv) {

      if (/^-?callback$/i) {
         $this->callback($argv{$_});
      } elsif (/^-?debug$/i) {
         $this->debug($argv{$_});
      } elsif (/^-?leadingdot$/i) {
         $this->leading_dot($argv{$_});
      } elsif (/^-?msgid$/i) {
         $this->msg_id($argv{$_}); 
      } elsif (/^-?requestid$/i) {
         $this->request_id($argv{$_});
      } elsif (/^-?security$/i) {
         $this->security($argv{$_});
      } elsif (/^-?translate$/i) {
         $this->translate($argv{$_});
      } elsif (/^-?transport$/i) {
         $this->transport($argv{$_});
      } elsif (/^-?version$/i) {
         $this->version($argv{$_});
      } else {
         $this->_error("Invalid argument '%s'", $_);
      }

      if (defined($this->{_error})) {
         return wantarray ? (undef, $this->{_error}) : undef;
      }

   }

   return wantarray ? ($this, '') : $this;
}

{
   my $prepare_methods = {
      INTEGER,            \&_prepare_integer,
      OCTET_STRING,       \&_prepare_octet_string,
      NULL,               \&_prepare_null,
      OBJECT_IDENTIFIER,  \&_prepare_object_identifier,
      SEQUENCE,           \&_prepare_sequence,
      IPADDRESS,          \&_prepare_ipaddress,
      COUNTER,            \&_prepare_counter,
      GAUGE,              \&_prepare_gauge,
      TIMETICKS,          \&_prepare_timeticks,
      OPAQUE,             \&_prepare_opaque,
      COUNTER64,          \&_prepare_counter64,
      NOSUCHOBJECT,       \&_prepare_nosuchobject,
      NOSUCHINSTANCE,     \&_prepare_nosuchinstance,
      ENDOFMIBVIEW,       \&_prepare_endofmibview,
      GET_REQUEST,        \&_prepare_get_request,
      GET_NEXT_REQUEST,   \&_prepare_get_next_request,
      GET_RESPONSE,       \&_prepare_get_response,
      SET_REQUEST,        \&_prepare_set_request,
      TRAP,               \&_prepare_trap,
      GET_BULK_REQUEST,   \&_prepare_get_bulk_request,
      INFORM_REQUEST,     \&_prepare_inform_request,
      SNMPV2_TRAP,        \&_prepare_v2_trap,
      REPORT,             \&_prepare_report
   };

   sub prepare 
   {
#     my ($this, $type, $value) = @_;

      return $_[0]->_error('ASN.1 type not defined') unless (@_ > 1);
      return $_[0]->_error if defined($_[0]->{_error});

      if (exists($prepare_methods->{$_[1]})) {
         $_[0]->${\$prepare_methods->{$_[1]}}($_[2]);
      } else {
         $_[0]->_error('Unknown ASN.1 type [%s]', $_[1]);
      }
   }
}

{
   my $process_methods = {
      INTEGER,            \&_process_integer32,
      OCTET_STRING,       \&_process_octet_string,
      NULL,               \&_process_null,
      OBJECT_IDENTIFIER,  \&_process_object_identifier,
      SEQUENCE,           \&_process_sequence,
      IPADDRESS,          \&_process_ipaddress,
      COUNTER,            \&_process_counter,
      GAUGE,              \&_process_gauge,
      TIMETICKS,          \&_process_timeticks,
      OPAQUE,             \&_process_opaque,
      COUNTER64,          \&_process_counter64,
      NOSUCHOBJECT,       \&_process_nosuchobject,
      NOSUCHINSTANCE,     \&_process_nosuchinstance,
      ENDOFMIBVIEW,       \&_process_endofmibview,
      GET_REQUEST,        \&_process_get_request,
      GET_NEXT_REQUEST,   \&_process_get_next_request,
      GET_RESPONSE,       \&_process_get_response,
      SET_REQUEST,        \&_process_set_request,
      TRAP,               \&_process_trap,
      GET_BULK_REQUEST,   \&_process_get_bulk_request,
      INFORM_REQUEST,     \&_process_inform_request,
      SNMPV2_TRAP,        \&_process_v2_trap,
      REPORT,             \&_process_report
   };

   sub process 
   {
#     my ($this, $expected, $found) = @_;

      return $_[0]->_error if defined($_[0]->{_error});
      return $_[0]->_error unless defined(my $type = $_[0]->_buffer_get(1));

      $type = unpack('C', $type);

      if (exists($process_methods->{$type})) {
         if ((@_ >= 2) && (defined($_[1])) && ($type != $_[1])) {
            return $_[0]->_error(
               'Expected %s, but found %s', asn1_itoa($_[1]), asn1_itoa($type)
            );
         }
         $_[2] = $type if (@_ == 3);
         $_[0]->${\$process_methods->{$type}}($type);
      } else {
         $_[0]->_error('Unknown ASN.1 type [0x%02x]', $type);
      }
   }
}

sub context_engine_id
{
   my ($this, $engine_id) = @_;

   # RFC 3412 - contextEngineID::=OCTET STRING

   if (@_ == 2) {
      if (!defined($engine_id)) {
         return $this->_error('contextEngineID not defined');
      }
      $this->{_context_engine_id} = $engine_id;
   }

   if (exists($this->{_context_engine_id})) {
      $this->{_context_engine_id};
   } elsif (defined($this->{_security})) {
      $this->{_security}->engine_id;
   } else {
      '';
   }
}

sub context_name
{
   my ($this, $name) = @_;

   # RFC 3412 - contextName::=OCTET STRING

   if (@_ == 2) {
      if (!defined($name)) {
         return $this->_error('contextName not defined');
      }
      $this->{_context_name} = $name;
   }

   exists($this->{_context_name}) ? $this->{_context_name} : '';
}

sub msg_flags
{
   my ($this, $flags) = @_;

   # RFC 3412 - msgFlags::=OCTET STRING (SIZE(1)) 

   # NOTE: The stored value is not an OCTET STRING.

   if (@_ == 2) {
      if (!defined($flags)) {
         return $this->_error('msgFlags not defined');
      }
      $this->{_msg_flags} = $flags;
   }

   exists($this->{_msg_flags}) ? $this->{_msg_flags} : MSG_FLAGS_NOAUTHNOPRIV;
}

sub msg_id
{
   my ($this, $msg_id) = @_;

   # RFC 3412 - msgID::=INTEGER (0..2147483647)

   if (@_ == 2) {
      if (!defined($msg_id)) {
         return $this->_error('msgId not defined');
      }
      if (($msg_id < 0) || ($msg_id > 2147483647)) {
         return $this->_error('Invalid msgId value [%s]', $msg_id);
      }
      $this->{_msg_id} = $msg_id;
   }

   if (exists($this->{_msg_id})) {
      $this->{_msg_id};
   } elsif (exists($this->{_request_id})) {
      $this->{_request_id};
   } else {
      0;
   }
}

sub msg_max_size
{
   my ($this, $size) = @_;

   # RFC 3412 - msgMaxSize::=INTEGER (484..2147483647)

   if (@_ == 2) {
      if (!defined($size)) {
         return $this->_error('msgMaxSize not defined');
      }
      if (($size < 484) || ($size > 2147483647)) {
         return $this->_error('Invalid msgMaxSize value [%s]', $size);
      }
      $this->{_msg_max_size} = $size;
   }

   $this->{_msg_max_size} || 484;
}

sub msg_security_model
{
   my ($this, $model) = @_;

   # RFC 3412 - msgSecurityModel::=INTEGER (1..2147483647)

   if (@_ == 2) {
      if (!defined($model)) {
         return $this->_error('msgSecurityModel not defined');
      }
      if (($model < 1) || ($model > 2147483647)) {
         return $this->_error('Invalid msgSecurityModel value [%s]', $model);
      }
      $this->{_security_model} = $model;
   }

   if (exists($this->{_security_model})) {
      $this->{_security_model};
   } elsif (defined($this->{_security})) {
      $this->{_security}->security_model;
   } else {
      if ($this->{_version} == SNMP_VERSION_1) {
         SECURITY_MODEL_SNMPV1;
      } elsif ($this->{_version} == SNMP_VERSION_2C) {
         SECURITY_MODEL_SNMPV2C;
      } elsif ($this->{_version} == SNMP_VERSION_3) {
         SECURITY_MODEL_USM;
      } else {
         SECURITY_MODEL_ANY;
      }
   }
}

sub request_id
{
   my ($this, $request_id) = @_;

   # request-id::=INTEGER

   if (@_ == 2) {
      if (!defined($request_id)) {
         return $this->_error('request-id not defined');
      }
      $this->{_request_id} = $request_id;
   }

   exists($this->{_request_id}) ? $this->{_request_id} : 0;
}

sub security_level
{
   my ($this, $level) = @_;

   # RFC 3411 - SnmpSecurityLevel::=INTEGER { noAuthNoPriv(1), 
   #                                          authNoPriv(2),
   #                                          authPriv(3) }

   if (@_ == 2) {
      if (!defined($level)) {
         return $this->_error('securityLevel not defined');
      }
      if (($level < SECURITY_LEVEL_NOAUTHNOPRIV) || 
          ($level > SECURITY_LEVEL_AUTHPRIV)) 
      {
         return $this->_error('Invalid securityLevel value [%s]', $level);
      }
      $this->{_security_level} = $level;
   }

   if (exists($this->{_security_level})) {
      $this->{_security_level};
   } elsif (defined($this->{_security})) {
      $this->{_security}->security_level;
   } else {
      SECURITY_LEVEL_NOAUTHNOPRIV;
   }
}

sub security_name
{
   my ($this, $name) = @_;

   if (@_ == 2) {
      if (!defined($name)) {
         return $this->_error('securityName not defined');
      }
      # No length checks due to no limits by RFC 1157 for community name.
      $this->{_security_name} = $name;
   }

   if (exists($this->{_security_name})) {
      $this->{_security_name};
   } elsif (defined($this->{_security})) {
      $this->{_security}->security_name;
   } else {
      '';
   }
}

sub version
{
   my ($this, $version) = @_;

   if (@_ == 2) {
      if (($version == SNMP_VERSION_1)  ||
          ($version == SNMP_VERSION_2C) ||
          ($version == SNMP_VERSION_3))
      {
         $this->{_version} = $version;
      } else {
         return $this->_error('Unknown or unsupported version [%s]', $version);
      }
   }

   $this->{_version};
}

sub error_status 
{ 
   0; # noError 
}

sub error_index
{ 
   0;
} 

sub var_bind_list 
{
   undef;
}

sub var_bind_names
{
   [];
}  

#
# Security Model accessor methods
#

sub security
{
   my ($this, $security) = @_;

   if (@_ == 2) {
      if (defined($security)) {
         $this->{_security} = $security;
      } else {
         $this->_error_clear;
         return $this->_error('No Security Model defined');
      }
   }

   $this->{_security};
}

#
# Transport Domain accessor methods
#

sub transport
{
   my ($this, $transport) = @_;

   if (@_ == 2) {
      if (defined($transport)) {
         $this->{_transport} = $transport;
      } else {
         $this->_error_clear;
         return $this->_error('No Transport Domain defined');
      }
   }

   $this->{_transport};
}

sub hostname
{
   defined($_[0]->{_transport}) ? $_[0]->{_transport}->dest_hostname : '';
}

sub dstname
{
   warn
      sprintf(
         "dstname() is deprecated, use hostname() instead at %s line %d.\n",
         (caller(0))[1,2]
      );

   $_[0]->hostname;
}

sub max_msg_size
{
   my ($this, $size) = @_;

   if (defined($this->{_transport})) { 
      if (@_ != 2) {
         $this->{_transport}->max_msg_size;
      } else {
         $this->_error_clear;
         $this->{_transport}->max_msg_size($size) ||
            $this->_error($this->{_transport}->error); 
      }
   } else {
      0;
   }
}

sub retries
{
   defined($_[0]->{_transport}) ? $_[0]->{_transport}->retries : 0; 
}

sub timeout
{
   defined($_[0]->{_transport}) ? $_[0]->{_transport}->timeout : 0;
}

sub send
{
   my ($this) = @_;

   $this->_error_clear;

   if (!defined($this->{_transport})) {
      return $this->_error('No Transport Domain defined');
   }

   DEBUG_INFO('transport address %s', $this->{_transport}->dest_taddress);
   $this->_buffer_dump;

   my $bytes = $this->{_transport}->send($this->{_buffer});

   defined($bytes) ? $bytes : $this->_error($this->{_transport}->error);
}

sub recv 
{
   my ($this) = @_;

   $this->_error_clear;

   if (!defined($this->{_transport})) {
      return $this->_error('No Transport Domain defined');
   }

   my $name = $this->{_transport}->recv($this->{_buffer});

   if (defined($name)) {

      $this->{_length} = CORE::length($this->{_buffer});

      DEBUG_INFO('transport address %s', $this->{_transport}->peer_taddress);
      $this->_buffer_dump;

      $name;

   } else {

      $this->_error($this->{_transport}->error);

   }
}

#
# Data representation methods
#

sub translate
{
   (@_ == 2) ? $_[0]->{_translate} = $_[1] : $_[0]->{_translate};
}

sub leading_dot
{
   (@_ == 2) ? $_[0]->{_leading_dot} = $_[1] : $_[0]->{_leading_dot};
}

#
# Callback handler methods
#

sub callback
{
   my ($this, $callback) = @_;

   if (@_ == 2) {
      if (ref($callback) eq 'CODE') {
         $this->{_callback} = $callback;
      } elsif (!defined($_[1])) {
         $this->{_callback} = undef;
      } 
   }

   $this->{_callback};
}

sub callback_execute
{
   my ($this) = @_;

   if (!defined($this->{_callback})) {
      DEBUG_INFO('no callback');
      return TRUE;
   }

   # Protect ourselves from user error.
   eval { $this->{_callback}->($this); };

   # We clear the callback in case it was a 
   # closure which might hold up the reference
   # count of the calling object.

   $this->{_callback} = undef;

   ($@) ? $this->_error($@) : TRUE; 
}

sub timeout_id
{
   (@_ == 2) ? $_[0]->{_timeout_id} = $_[1] : $_[0]->{_timeout_id};
}

#
# Buffer manipulation methods
#

sub index
{
   my ($this, $index) = @_;

   if ((@_ == 2) && ($index >= 0) && ($index <= $this->{_length})) {
      $this->{_index} = $index;
   }

   $this->{_index};
}

sub length
{
   $_[0]->{_length};
}

sub prepend
{
   shift->_buffer_put(@_);
}

sub append
{
   shift->_buffer_append(@_);
}

sub copy 
{
   $_[0]->{_buffer};
}

sub reference
{
   \$_[0]->{_buffer};
}

sub clear
{
   $_[0]->_buffer_get;
}

sub dump
{
   $_[0]->_buffer_dump;
}

#
# Debug/error handling methods
#

sub error
{
   my $this = shift;

   if (@_) {
      if (defined($_[0])) {
         $this->{_error} = (@_ > 1) ? sprintf(shift(@_), @_) : $_[0]; 
         if ($this->debug) {
            printf("error: [%d] %s(): %s\n",
               (caller(0))[2], (caller(1))[3], $this->{_error}
            );
         }
      } else {
         $this->{_error} = undef;
      }
   }

   $this->{_error} || '';
}

sub debug
{
   (@_ == 2) ? $DEBUG = ($_[1]) ? TRUE : FALSE : $DEBUG;
}

sub AUTOLOAD
{
   my ($this) = @_;

   return if $AUTOLOAD =~ /::DESTROY$/;

   $AUTOLOAD =~ s/.*://;

   if (ref($this)) {
      $this->_error('Feature not supported [%s]', $AUTOLOAD);
   } else {
      die sprintf('Unsupported function call [%s]', $AUTOLOAD);
   }
}

# [private methods] ----------------------------------------------------------

#
# Basic Encoding Rules (BER) prepare methods
#

sub _prepare_type_length
{
#  my ($this, $type, $value) = @_;

   return $_[0]->_error('ASN.1 type not defined') unless defined($_[1]);

   my $length = CORE::length($_[2]);

   if ($length < 0x80) {
      $_[0]->_buffer_put(pack('C2', $_[1], $length) . $_[2]);
   } elsif ($length <= 0xff) {
      $_[0]->_buffer_put(pack('C3', $_[1], 0x81, $length) . $_[2]);
   } elsif ($length <= 0xffff) {
      $_[0]->_buffer_put(pack('CCn', $_[1], 0x82, $length) . $_[2]);
   } else {
      $_[0]->_error('Unable to prepare ASN.1 length');
   }
}

sub _prepare_integer
{
   my ($this, $value) = @_;

   return $this->_error('INTEGER value not defined') unless defined($value);

   if ($value !~ /^-?\d+$/) {
      return $this->_error('Expected numeric INTEGER value');
   }

   $this->_prepare_integer32(INTEGER, $value);
}

sub _prepare_unsigned32
{
   my ($this, $type, $value) = @_;

   if (!defined($value)) {
      return $this->_error('%s value not defined', asn1_itoa($type));
   }

   if ($value !~ /^\d+$/) {
      return $this->_error(
         'Expected positive numeric %s value', asn1_itoa($type)
      );
   }

   $this->_prepare_integer32($type, $value);
}

sub _prepare_integer32
{
   my ($this, $type, $value) = @_;

   # Determine if the value is positive or negative
   my $negative = ($value =~ /^-/);

   # Check to see if the most significant bit is set, if it is we
   # need to prefix the encoding with a zero byte.

   my $size   = 4;     # Assuming 4 byte integers
   my $prefix = FALSE;
   my $bytes  = '';

   if ((($value & 0xff000000) & 0x80000000) && (!$negative)) {
      $size++;
      $prefix = TRUE;
   }

   # Remove occurances of nine consecutive ones (if negative) or zeros
   # from the most significant end of the two's complement integer.

   while ((((!($value & 0xff800000))) ||
           ((($value & 0xff800000) == 0xff800000) && ($negative))) &&
           ($size > 1))
   {
      $size--;
      $value <<= 8;
   }

   # Add a zero byte so the integer is decoded as a positive value
   if ($prefix) {
      $bytes = pack('x');
      $size--;
   }

   # Build the integer
   while ($size-- > 0) {
      $bytes .= pack('C*', (($value & 0xff000000) >> 24));
      $value <<= 8;
   }

   # Encode ASN.1 header
   $this->_prepare_type_length($type, $bytes);
}

sub _prepare_octet_string
{
   my ($this, $value) = @_;

   if (!defined($value)) {
      return $this->_error('OCTET STRING value not defined');
   }

   $this->_prepare_type_length(OCTET_STRING, $value);
}

sub _prepare_null
{
   $_[0]->_prepare_type_length(NULL, '');
}

sub _prepare_object_identifier
{
   my ($this, $value) = @_;

   if (!defined($value)) {
      return $this->_error('OBJECT IDENTIFIER value not defined');
   }

   # Input is expected in dotted notation, so break it up into subids
   my @subids = split(/\./, $value);

   # If there was a leading dot on _any_ OBJECT IDENTIFIER passed to
   # a prepare method, return a leading dot on _all_ of the OBJECT
   # IDENTIFIERs in the process methods.

   if ($subids[0] eq '') {
      DEBUG_INFO('leading dot present');
      $this->{_leading_dot} = TRUE;
      shift(@subids);
   }

   # RFC 2578 Section 3.5 - "...there are at most 128 sub-identifiers..."
   if (@subids > 128) {
      return $this->_error(
         'Exceeded the maximum of 128 sub-identifiers in an OBJECT IDENTIFIER'
      );
   }

   # ISO/IEC 8825 - Specification of Basic Encoding Rules for Abstract
   # Syntax Notation One (ASN.1) dictates that the first two subidentifiers
   # are encoded into the first identifier using the the equation:
   # subid = ((first * 40) + second).

   # We return an error if there are not at least two subidentifiers.

   if (@subids < 2) {
      return $this->_error(
         'Expected at least two sub-identifiers in an OBJECT IDENTIFIER'
      );
   }

   # The first subidentifiers are limited to ccitt(0), iso(1), and
   # joint-iso-ccitt(2) as defined by RFC 2578.

   if ($subids[0] > 2) {
      return $this->_error(
         'An OBJECT IDENTIFIER must begin with either 0 (ccitt), 1 ' .
         '(iso), or 2 (joint-iso-ccitt)'
      );
   }

   # If the first subidentifier is 0 or 1, the second is limited to 0 - 39.

   if (($subids[0] < 2) && ($subids[1] >= 40)) {
      return $this->_error(
         'The second subidentifier in the OBJECT IDENTIFIER must be ' .
         'less than 40'
      );
   } elsif ($subids[1] >= (4294967295 - 80)) {
      return $this->_error(
         'The second subidentifier in the OBJECT IDENTIFIER must be ' .
         'less than %u',
         (4294967295 - 80)
      );
   }

   # Now apply: subid = ((first * 40) + second)

   $subids[1] += (shift(@subids) * 40);

   # Encode each value as seven bits with the most significant bit
   # indicating the end of a sub-identifier.

   my @bytes;

   foreach (@subids) {
      if ($_ <= 0x7f) {
         push(@bytes, $_);
      } else {
         my @_bytes;
         while ($_) {
            unshift(@_bytes, (0x80 | ($_ & 0x7f)));
            $_ >>= 7;
         }
         $_bytes[-1] &= 0x7f;
         push(@bytes, @_bytes);
      }
   }

   # Encode the ASN.1 header
   $this->_prepare_type_length(OBJECT_IDENTIFIER, pack('C*', @bytes));
}

sub _prepare_sequence
{
   $_[0]->_prepare_implicit_sequence(SEQUENCE, $_[1]);
}

sub _prepare_implicit_sequence
{
   my ($this, $type, $value) = @_;

   if (defined($value)) {

      $this->_prepare_type_length($type, $value);

   } else {

      # If the passed value is undefined, we assume that the value of
      # the IMPLICIT SEQUENCE is the data currently in the serial buffer.

      if ($this->{_length} < 0x80) {
         $this->_buffer_put(pack('C2', $type, $this->{_length}));
      } elsif ($this->{_length} <= 0xff) {
         $this->_buffer_put(pack('C3', $type, 0x81, $this->{_length}));
      } elsif ($this->{_length} <= 0xffff) {
         $this->_buffer_put(pack('CCn', $type, 0x82, $this->{_length}));
      } else {
         $this->_error('Unable to prepare ASN.1 length');
      }

   }
}

sub _prepare_ipaddress
{
   my ($this, $value) = @_;

   return $this->_error('IpAddress not defined') unless defined($value);

   if ($value !~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
      return $this->_error('Expected IpAddress in dotted notation');
   }

   $this->_prepare_type_length(IPADDRESS, pack('C4', split(/\./, $value)));
}

sub _prepare_counter
{
   $_[0]->_prepare_unsigned32(COUNTER, $_[1]);
}

sub _prepare_gauge
{
   $_[0]->_prepare_unsigned32(GAUGE, $_[1]);
}

sub _prepare_timeticks
{
   $_[0]->_prepare_unsigned32(TIMETICKS, $_[1]);
}

sub _prepare_opaque
{
   my ($this, $value) = @_;

   return $this->_error('Opaque value not defined') unless defined($value);

   $this->_prepare_type_length(OPAQUE, $value);
}

sub _prepare_counter64
{
   my ($this, $value) = @_;

   # Validate the SNMP version
   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('Counter64 not supported in SNMPv1');
   }

   # Validate the passed value
   if (!defined($value)) {
      return $this->_error('Counter64 value not defined');
   }

   if ($value !~ /^\+?\d+$/) {
      return $this->_error('Expected positive numeric Counter64 value');
   }

   $value = Math::BigInt->new($value);

   if ($value eq 'NaN') {
      return $this->_error('Invalid Counter64 value');
   }

   # Make sure the value is no more than 8 bytes long
   if ($value->bcmp('18446744073709551615') > 0) {
      return $this->_error('Counter64 value too high');
   }

   my ($quotient, $remainder, @bytes);

   # Handle a value of zero
   if ($value == 0) {
      unshift(@bytes, 0x00);
   }

   while ($value > 0) {
      ($quotient, $remainder) = $value->bdiv(256);
      $value = Math::BigInt->new($quotient);
      unshift(@bytes, $remainder);
   }

   # Make sure that the value is encoded as a positive value
   if ($bytes[0] & 0x80) { unshift(@bytes, 0x00); }

   $this->_prepare_type_length(COUNTER64, pack('C*', @bytes));
}

sub _prepare_nosuchobject
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('noSuchObject not supported in SNMPv1');
   }

   $this->_prepare_type_length(NOSUCHOBJECT, '');
}

sub _prepare_nosuchinstance
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('noSuchInstance not supported in SNMPv1');
   }

   $this->_prepare_type_length(NOSUCHINSTANCE, '');
}

sub _prepare_endofmibview
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('endOfMibView not supported in SNMPv1');
   }

   $this->_prepare_type_length(ENDOFMIBVIEW, '');
}

sub _prepare_get_request
{
   $_[0]->_prepare_implicit_sequence(GET_REQUEST, $_[1]);
}

sub _prepare_get_next_request
{
   $_[0]->_prepare_implicit_sequence(GET_NEXT_REQUEST, $_[1]);
}

sub _prepare_get_response
{
   $_[0]->_prepare_implicit_sequence(GET_RESPONSE, $_[1]);
}

sub _prepare_set_request
{
   $_[0]->_prepare_implicit_sequence(SET_REQUEST, $_[1]);
}

sub _prepare_trap
{
   my ($this, $value) = @_;

   if ($this->{_version} != SNMP_VERSION_1) {
      return $this->_error('Trap-PDU only supported in SNMPv1');
   }

   $this->_prepare_implicit_sequence(TRAP, $value);
}

sub _prepare_get_bulk_request
{
   my ($this, $value) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('GetBulkRequest-PDU not supported in SNMPv1');
   }

   $this->_prepare_implicit_sequence(GET_BULK_REQUEST, $value);
}

sub _prepare_inform_request
{
   my ($this, $value) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('InformRequest-PDU not supported in SNMPv1');
   }

   $this->_prepare_implicit_sequence(INFORM_REQUEST, $value);
}

sub _prepare_v2_trap
{
   my ($this, $value) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('SNMPv2-Trap-PDU not supported in SNMPv1');
   }

   $this->_prepare_implicit_sequence(SNMPV2_TRAP, $value);
}

sub _prepare_report
{
   my ($this, $value) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('Report-PDU not supported in SNMPv1');
   }

   $this->_prepare_implicit_sequence(REPORT, $value);
}

#
# Basic Encoding Rules (BER) process methods
#

sub _process_length
{
#  my ($this) = @_;

   return $_[0]->_error if defined($_[0]->{_error});

   return $_[0]->_error unless defined(my $length = $_[0]->_buffer_get(1));

   $length = unpack('C', $length);

   if ($length & 0x80) {
      my $byte_cnt = ($length & 0x7f);
      if ($byte_cnt == 0) {
         return $_[0]->_error('Indefinite ASN.1 lengths not supported');
      } elsif ($byte_cnt <= 4) {
         if (!defined($length = $_[0]->_buffer_get($byte_cnt))) {
            return $_[0]->_error;
         }
         $length = unpack('N', ("\000" x (4 - $byte_cnt) . $length));
      } else {
         return $_[0]->_error('ASN.1 length too long (%u bytes)', $byte_cnt);
      }
   }

   $length;
}

sub _process_integer32
{
   my ($this, $type) = @_;

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   # Return an error if the object length is zero
   if ($length < 1) {
      return $this->_error("%s length equal to zero", asn1_itoa($type));
   }

   # Retrieve the whole byte stream outside of the loop.
   return $this->_error unless defined(my $bytes = $this->_buffer_get($length));

   my @bytes = unpack('C*', $bytes);
   my $negative = FALSE;
   my $int32 = 0;

   # Validate the length of the Integer32
   if (($length > 5) || (($length > 4) && ($bytes[0] != 0x00))) {
      return $this->_error(
         '%s length too long (%u bytes)', asn1_itoa($type), $length
      );
   }

   # If the first bit is set, the Integer32 is negative
   if ($bytes[0] & 0x80) {
      $int32 = -1;
      $negative = TRUE;
   }

   # Build the Integer32
   map { $int32 = (($int32 << 8) | $_) } @bytes;

   if ($negative) {
      if (($type == INTEGER) || (!($this->{_translate} & TRANSLATE_UNSIGNED))) {
         unpack('l', pack('l', $int32));
      } else {
         DEBUG_INFO('translating negative %s value', asn1_itoa($type));
         unpack('L', pack('l', $int32));
      }
   } else {
      unpack('L', pack('L', $int32));
   }
}

sub _process_octet_string
{
   my ($this, $type) = @_;

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   # Get the string
   return $this->_error unless defined(my $s = $this->_buffer_get($length));

   # Set the translation mask
   my $mask = ($type == OPAQUE) ? TRANSLATE_OPAQUE : TRANSLATE_OCTET_STRING;

   if (($this->{_translate} & $mask) &&
       ($s =~ /[\x01-\x08\x0b\x0e-\x1f\x7f-\xff]/g)) 
   {
      DEBUG_INFO("translating %s to printable hex string", asn1_itoa($type));
      sprintf('0x%s', unpack('H*', $s));
   } else {
      $s;
   }
}

sub _process_null
{
   my ($this) = @_;

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   return $this->_error('NULL length not equal to zero') if ($length != 0);

   if ($this->{_translate} & TRANSLATE_NULL) {
      DEBUG_INFO("translating NULL to 'NULL' string");
      'NULL';
   } else {
      '';
   }
}

sub _process_object_identifier
{
   my ($this) = @_;

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   if ($length < 1) {
      return $this->_error('OBJECT IDENTIFIER length equal to zero');
   }

   # Retrieve the whole byte stream outside of the loop (by Niilo Neuvo).

   return $this->_error unless defined(my $bytes = $this->_buffer_get($length));

   my ($subid, @oid) = (0, 0);

   foreach (unpack('C*', $bytes)) {
      if ($subid & 0xfe000000) {
         return $this->_error('OBJECT IDENTIFIER sub-identifier too large');
      }
      $subid = (($subid << 7) | ($_ & 0x7f));
      if (!($_ & 0x80)) {
         if (@oid == 128) {
            return $this->_error(
               'Exceeded maximum of 128 sub-identifiers in OBJECT IDENTIFIER'
            );
         }
         push(@oid, $subid);
         $subid = 0;
      }
   }

   # The first two sub-identifiers are encoded into the first identifier
   # using the the equation: subid = ((first * 40) + second).

   if ($oid[1] == 0x2b) {   # Handle the most common case
      $oid[0] = 1;          # first [iso(1).org(3)]
      $oid[1] = 3;
   } elsif ($oid[1] < 40) {
      $oid[0] = 0;
   } elsif ($oid[1] < 80) {
      $oid[0] = 1;
      $oid[1] -= 40;
   } else {
      $oid[0] = 2;
      $oid[1] -= 80;
   }

   # Return the OID in dotted notation (optionally with a 
   # leading dot if one was passed to the prepare routine).

   if ($this->{_leading_dot}) {
      DEBUG_INFO('adding leading dot');
      unshift(@oid, '');
   }

   join('.', @oid);
}

sub _process_sequence
{
   # Return the length, instead of the value
   $_[0]->_process_length;
}

sub _process_ipaddress
{
   my ($this) = @_;

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   if ($length != 4) {
      return $this->_error(
         'Invalid IpAddress length (%d byte%s)',
         $length, ($length != 1 ? 's' : '')
      );
   }

   if (defined(my $ip = $this->_buffer_get(4))) {
      sprintf('%vd', $ip);
   } else {
      $this->_error;
   }
}

sub _process_counter
{
   $_[0]->_process_integer32(COUNTER);
}

sub _process_gauge
{
   $_[0]->_process_integer32(GAUGE);
}

sub _process_timeticks
{
   my ($this) = @_;

   if (defined(my $ticks = $this->_process_integer32(TIMETICKS))) {
      if ($this->{_translate} & TRANSLATE_TIMETICKS) {
         DEBUG_INFO('translating %u TimeTicks to time', $ticks);
         asn1_ticks_to_time($ticks);
      } else {
         $ticks;
      }
   } else {
      $this->_error;
   }
}

sub _process_opaque
{
   $_[0]->_process_octet_string(OPAQUE);
}

sub _process_counter64
{
   my ($this, $type) = @_;

   # Verify the SNMP version
   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('Counter64 not supported in SNMPv1');
   }

   # Decode the length
   return $this->_error unless defined(my $length = $_[0]->_process_length);

   # Return an error if the object length is zero
   if ($length < 1) {
      return $this->_error('Counter64 length equal to zero');
   }

   # Retrieve the whole byte stream outside of the loop.
   return $this->_error unless defined(my $bytes = $this->_buffer_get($length));

   my @bytes = unpack('C*', $bytes);
   my $negative = FALSE;

   # Validate the length of the Counter64
   if (($length > 9) || (($length > 8) && ($bytes[0] != 0x00))) {
      return $_[0]->_error('Counter64 length too long (%u bytes)', $length);
   }

   # If the first bit is set, the integer is negative
   if ($bytes[0] & 0x80) {
      $bytes[0] ^= 0xff;
      $negative = TRUE;
   }

   # Build the Counter64
   my $int64 = Math::BigInt->new(shift(@bytes));
   map {
      $_ ^= 0xff if ($negative);
      $int64 *= 256;
      $int64 += $_;
   } @bytes;

   # If the value is negative the other end incorrectly encoded
   # the Counter64 since it should always be a positive value.

   if ($negative) {
      $int64 = Math::BigInt->new('-1') - $int64;
      if ($this->{_translate} & TRANSLATE_UNSIGNED) {
         DEBUG_INFO('translating negative Counter64 value');
         $int64 += Math::BigInt->new('18446744073709551616');
      }
   }

   # Perl 5.6.0 (force to string or substitution does not work).
   $int64 .= '';

   # Remove the plus sign (or should we leave it to imply Math::BigInt?)
   $int64 =~ s/^\+//;

   $int64;
}

sub _process_nosuchobject
{
   my ($this) = @_;

   # Verify the SNMP version
   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('noSuchObject not supported in SNMPv1');
   }

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   if ($length != 0) {
      return $this->_error('noSuchObject length not equal to zero');
   }

   if ($this->{_translate} & TRANSLATE_NOSUCHOBJECT) {
      DEBUG_INFO("translating noSuchObject to 'noSuchObject' string");
      'noSuchObject';
   } else {
      $this->{_error_status} = NOSUCHOBJECT;
      '';
   }
}

sub _process_nosuchinstance
{
   my ($this) = @_;

   # Verify the SNMP version
   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('noSuchInstance not supported in SNMPv1');
   }

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   if ($length != 0) {
      return $this->_error('noSuchInstance length not equal to zero');
   }

   if ($this->{_translate} & TRANSLATE_NOSUCHINSTANCE) {
      DEBUG_INFO("translating noSuchInstance to 'noSuchInstance' string");
      'noSuchInstance';
   } else {
      $this->{_error_status} = NOSUCHINSTANCE;
      '';
   }
}

sub _process_endofmibview
{
   my ($this) = @_;

   # Verify the SNMP version
   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('endOfMibView not supported in SNMPv1');
   }

   # Decode the length
   return $this->_error unless defined(my $length = $this->_process_length);

   if ($length != 0) {
      return $this->_error('endOfMibView length not equal to zero');
   }

   if ($this->{_translate} & TRANSLATE_ENDOFMIBVIEW) {
      DEBUG_INFO("translating endOfMibView to 'endOfMibView' string");
      'endOfMibView';
   } else {
      $this->{_error_status} = ENDOFMIBVIEW;
      '';
   }
}

sub _process_pdu_type
{
   # Generic methods used to process the PDU type.  The ASN.1 type is
   # returned by the method as passed by the generic process routine.

   defined($_[0]->_process_length) ? $_[1] : $_[0]->_error;
}

sub _process_get_request
{
   $_[0]->_process_pdu_type(GET_REQUEST);
}

sub _process_get_next_request
{
   $_[0]->_process_pdu_type(GET_NEXT_REQUEST);
}

sub _process_get_response
{
   $_[0]->_process_pdu_type(GET_RESPONSE);
}

sub _process_set_request
{
   $_[0]->_process_pdu_type(SET_REQUEST);
}

sub _process_trap
{
   my ($this) = @_;

   if ($this->{_version} != SNMP_VERSION_1) {
      return $this->_error('Trap-PDU only supported in SNMPv1');
   }

   $this->_process_pdu_type(TRAP);
}

sub _process_get_bulk_request
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('GetBulkRequest-PDU not supported in SNMPv1');
   }

   $this->_process_pdu_type(GET_BULK_REQUEST);
}

sub _process_inform_request
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('InformRequest-PDU not supported in SNMPv1');
   }

   $this->_process_pdu_type(INFORM_REQUEST);
}

sub _process_v2_trap
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('SNMPv2-Trap-PDU not supported in SNMPv1');
   }

   $this->_process_pdu_type(SNMPV2_TRAP);
}

sub _process_report
{
   my ($this) = @_;

   if ($this->{_version} == SNMP_VERSION_1) {
      return $this->_error('Report-PDU not supported in SNMPv1');
   }

   $this->_process_pdu_type(REPORT);
}

#
# Abstract Syntax Notation One (ASN.1) utility functions
#

{
   my $types = {
      INTEGER,            'INTEGER',
      OCTET_STRING,       'OCTET STRING',
      NULL,               'NULL',
      OBJECT_IDENTIFIER,  'OBJECT IDENTIFIER',
      SEQUENCE,           'SEQUENCE',
      IPADDRESS,          'IpAddress',
      COUNTER,            'Counter',
      GAUGE,              'Gauge',
      TIMETICKS,          'TimeTicks',
      OPAQUE,             'Opaque',
      COUNTER64,          'Counter64',
      NOSUCHOBJECT,       'noSuchObject',
      NOSUCHINSTANCE,     'noSuchInstance',
      ENDOFMIBVIEW,       'endOfMibView',
      GET_REQUEST,        'GetRequest-PDU',
      GET_NEXT_REQUEST,   'GetNextRequest-PDU',
      GET_RESPONSE,       'GetResponse-PDU',
      SET_REQUEST,        'SetRequest-PDU',
      TRAP,               'Trap-PDU',
      GET_BULK_REQUEST,   'GetBulkRequest-PDU',
      INFORM_REQUEST,     'InformRequest-PDU',
      SNMPV2_TRAP,        'SNMPv2-Trap-PDU',
      REPORT,             'Report-PDU'
   };

   sub asn1_itoa
   {
      my ($type) = @_;

      return '??' unless (@_ == 1);

      if (exists($types->{$type})) {
         $types->{$type};
      } else {
         sprintf('?? [0x%02x]', $type);
      }
   }
}

sub asn1_ticks_to_time
{
   my $ticks = shift || 0;

   my $days = int($ticks / (24 * 60 * 60 * 100));
   $ticks %= (24 * 60 * 60 * 100);

   my $hours = int($ticks / (60 * 60 * 100));
   $ticks %= (60 * 60 * 100);

   my $minutes = int($ticks / (60 * 100));
   $ticks %= (60 * 100);

   my $seconds = ($ticks / 100);

   if ($days != 0){
      sprintf('%d day%s, %02d:%02d:%05.02f', $days,
         ($days == 1 ? '' : 's'), $hours, $minutes, $seconds);
   } elsif ($hours != 0) {
      sprintf('%d hour%s, %02d:%05.02f', $hours,
         ($hours == 1 ? '' : 's'), $minutes, $seconds);
   } elsif ($minutes != 0) {
      sprintf('%d minute%s, %05.02f', $minutes,
         ($minutes == 1 ? '' : 's'), $seconds);
   } else {
      sprintf('%04.02f second%s', $seconds, ($seconds == 1 ? '' : 's'));
   }
}

#
# Error handlers
#

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

sub _error_clear
{
   $_[0]->{_error} = undef;
}

#
# Buffer manipulation methods
#

sub _buffer_append
{
#  my ($this, $value) = @_;

   return $_[0]->_error if defined($_[0]->{_error});

   # Always reset the index when the buffer is modified
   $_[0]->{_index} = 0;

   # Update our length
   $_[0]->{_length} += CORE::length($_[1]);

   # Append to the current buffer
   $_[0]->{_buffer} .= $_[1];
}

sub _buffer_get
{
#  my ($this, $count) = @_;

   return $_[0]->_error if defined($_[0]->{_error});

   # Return the number of bytes requested at the current 
   # index or clear and return the whole buffer if no arguments  
   # are passed.

   if (@_ == 2) {

      if (($_[0]->{_index} += $_[1]) > $_[0]->{_length}) {
         $_[0]->{_index} -= $_[1];
         if ($_[0]->{_length} >= $_[0]->max_msg_size) {
            return $_[0]->_error('Message size exceeded buffer maxMsgSize'); 
         }
         return $_[0]->_error('Unexpected end of message buffer');
      }
      substr($_[0]->{_buffer}, $_[0]->{_index} - $_[1], $_[1]);

   } else {

      $_[0]->{_index}  = 0; # Index is reset on modifies 
      $_[0]->{_length} = 0; 
      substr($_[0]->{_buffer}, 0, CORE::length($_[0]->{_buffer}), '');

   }
}

sub _buffer_put
{
#  my ($this, $value) = @_;

   return $_[0]->_error if defined($_[0]->{_error});

   # Always reset the index when the buffer is modified
   $_[0]->{_index} = 0;

   # Update our length
   $_[0]->{_length} += CORE::length($_[1]);

   # Add the prefix to the current buffer
   substr($_[0]->{_buffer}, 0, 0) = $_[1];
}

sub _buffer_dump
{
   my ($this) = @_;

   return unless $DEBUG;

   DEBUG_INFO("%d byte%s", $this->{_length}, $this->{_length} != 1 ? 's' : '');

   my ($offset, $hex, $text) = (0, '', '');

   while ($this->{_buffer} =~ /(.{1,16})/gs) {
      $hex  = unpack('H*', ($text = $1));
      $hex .= ' ' x (32 - CORE::length($hex));
      $hex  = sprintf('%s %s %s %s  ' x 4, unpack('a2' x 16, $hex));
      $text =~ s/[\x00-\x1f\x7f-\xff]/./g;
      printf("[%04d]  %s %s\n", $offset, uc($hex), $text);
      $offset += 16;
   }

   $this->{_buffer};
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
1; # [end Net::SNMP::Message]
