# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::PDU;

# $Id: PDU.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object used to represent a SNMP PDU. 

# Copyright (c) 2001-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Message qw( 
   :types :versions asn1_itoa ENTERPRISE_SPECIFIC TRUE FALSE 
);

use Net::SNMP::Transport qw( DOMAIN_UDPIPV4 DOMAIN_TCPIPV4 );

## Version of the Net::SNMP::PDU module

our $VERSION = v2.1.1;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Net::SNMP::Message Exporter );

sub import
{
   Net::SNMP::Message->export_to_level(1, @_);
}

## Initialize the global request-id/msgID.  

our $REQUEST_ID = int(rand((2**16) - 1) + (time() & 0xff));

# [public methods] -----------------------------------------------------------

sub new
{
   my $class = shift;

   # We play some games here to allow us to "convert" a Message into a PDU. 

   my $this = ref($_[0]) ? bless shift(@_), $class : $class->SUPER::new;

   # Override or initialize fields inherited from the base class
 
   $this->{_error_status}   = 0;
   $this->{_error_index}    = 0;
   $this->{_scoped}         = FALSE;
   $this->{_var_bind_list}  = undef;
   $this->{_var_bind_names} = [];
   $this->{_var_bind_types} = undef;

   my (%argv) = @_;

   # Validate the passed arguments

   foreach (keys %argv) {

      if (/^-?callback$/i) {
         $this->callback($argv{$_});
      } elsif (/^-?contextengineid/i) {
         $this->context_engine_id($argv{$_});
      } elsif (/^-?contextname/i) {
         $this->context_name($argv{$_});
      } elsif (/^-?debug$/i) {
         $this->debug($argv{$_});
      } elsif (/^-?leadingdot$/i) {
         $this->leading_dot($argv{$_});
      } elsif (/^-?maxmsgsize$/i) {
         $this->max_msg_size($argv{$_});
      } elsif (/^-?requestid$/i) {
         $this->request_id($argv{$_});
      } elsif (/^-?security$/i) {
         $this->security($argv{$_});
      } elsif (/^-?translate$/i) {
         $this->{_translate} = $argv{$_};
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

   if (!defined($this->{_transport})) {
      $this->_error('No Transport Domain defined');
      return wantarray ? (undef, $this->{_error}) : undef;
   }

   return wantarray ? ($this, '') : $this;
}

sub prepare_get_request
{
   my ($this, $oids) = @_;

   $this->_error_clear;

   $this->prepare_pdu(GET_REQUEST, $this->_create_oid_null_pairs($oids));
}

sub prepare_get_next_request
{
   my ($this, $oids) = @_; 

   $this->_error_clear;

   $this->prepare_pdu(GET_NEXT_REQUEST, $this->_create_oid_null_pairs($oids));
}

sub prepare_get_response
{
   my ($this, $trios) = @_;

   $this->_error_clear;

   $this->prepare_pdu(GET_RESPONSE, $this->_create_oid_value_pairs($trios));
}

sub prepare_set_request
{
   my ($this, $trios) = @_; 

   $this->_error_clear;

   $this->prepare_pdu(SET_REQUEST, $this->_create_oid_value_pairs($trios));
}

sub prepare_trap
{
   my ($this, $enterprise, $addr, $generic, $specific, $time, $trios) = @_;

   $this->_error_clear;

   return $this->_error('Missing arguments for Trap-PDU') if (@_ < 6);

   # enterprise

   if (!defined($enterprise)) {

      # Use iso(1).org(3).dod(6).internet(1).private(4).enterprises(1) 
      # for the default enterprise.

      $this->{_enterprise} = '1.3.6.1.4.1';

   } elsif ($enterprise !~ /^\.?\d+\.\d+(?:\.\d+)*/) {
      return $this->_error(
         'Expected enterprise as an OBJECT IDENTIFIER in dotted notation'
      );
   } else {
      $this->{_enterprise} = $enterprise;
   }

   # agent-addr

   if (!defined($addr)) {

      # See if we can get the agent-addr from the Transport
      # Layer.  If not, we return an error.

      if (defined($this->{_transport})) {
         if (($this->{_transport}->domain ne DOMAIN_UDPIPV4) &&
             ($this->{_transport}->domain ne DOMAIN_TCPIPV4)) 
         {
            $this->{_agent_addr} = '0.0.0.0';
         } else {   
            $this->{_agent_addr} = $this->{_transport}->agent_addr;
            delete($this->{_agent_addr}) if ($this->{_agent_addr} eq '0.0.0.0');
         }
      }
      if (!exists($this->{_agent_addr})) { 
         return $this->_error('Unable to resolve local agent-addr');
      }
 
   } elsif ($addr !~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
      return $this->_error('Expected agent-addr in dotted notation');
   } else {
      $this->{_agent_addr} = $addr;
   } 

   # generic-trap

   if (!defined($generic)) {

      # Use enterpriseSpecific(6) for the generic-trap type.
      $this->{_generic_trap} = ENTERPRISE_SPECIFIC;

   } elsif ($generic !~ /^\d+$/) {
      return $this->_error('Expected positive numeric generic-trap type');
   } else {
      $this->{_generic_trap} = $generic;
   }

   # specific-trap

   if (!defined($specific)) {
      $this->{_specific_trap} = 0;
   } elsif ($specific !~ /^\d+$/) {
      return $this->_error('Expected positive numeric specific-trap type');
   } else {
      $this->{_specific_trap} = $specific;
   }

   # time-stamp

   if (!defined($time)) {

      # Use the "uptime" of the script for the time-stamp.
      $this->{_time_stamp} = ((time() - $^T) * 100);

   } elsif ($time !~ /^\d+$/) {
      return $this->_error('Expected positive numeric time-stamp');
   } else {
      $this->{_time_stamp} = $time;
   }

   $this->prepare_pdu(TRAP, $this->_create_oid_value_pairs($trios));
}

sub prepare_get_bulk_request
{
   my ($this, $repeaters, $repetitions, $oids) = @_;

   $this->_error_clear;

   return $this->_error('Missing arguments for GetBulkRequest-PDU') if (@_ < 3);

   # non-repeaters

   if (!defined($repeaters)) {
      $this->{_error_status} = 0;
   } elsif ($repeaters !~ /^\d+$/) {
      return $this->_error('Expected positive numeric non-repeaters value');
   } elsif ($repeaters > 2147483647) { 
      return $this->_error('Exceeded maximum non-repeaters value [2147483647]');
   } else {
      $this->{_error_status} = $repeaters;
   }

   # max-repetitions

   if (!defined($repetitions)) {
      $this->{_error_index} = 0;
   } elsif ($repetitions !~ /^\d+$/) {
      return $this->_error('Expected positive numeric max-repetitions value');
   } elsif ($repetitions > 2147483647) {
      return $this->_error(
         'Exceeded maximum max-repetitions value [2147483647]'
      );
   } else {
      $this->{_error_index} = $repetitions;
   }

   # Some sanity checks

   if (defined($oids) && (ref($oids) eq 'ARRAY')) {

      if ($this->{_error_status} > @{$oids}) {
         return $this->_error(
            'Non-repeaters greater than the number of variable-bindings'
         );
      }

      if (($this->{_error_status} == @{$oids}) && ($this->{_error_index})) {
         return $this->_error( 
            'Non-repeaters equals the number of variable-bindings and ' .
            'max-repetitions is not equal to zero'
         );
      }
   }

   $this->prepare_pdu(GET_BULK_REQUEST, $this->_create_oid_null_pairs($oids));
}

sub prepare_inform_request
{
   my ($this, $trios) = @_;

   $this->_error_clear;

   $this->prepare_pdu(INFORM_REQUEST, $this->_create_oid_value_pairs($trios));
}

sub prepare_snmpv2_trap
{
   my ($this, $trios) = @_;

   $this->_error_clear;

   $this->prepare_pdu(SNMPV2_TRAP, $this->_create_oid_value_pairs($trios));
}

sub prepare_report
{
   my ($this, $trios) = @_;

   $this->_error_clear;

   $this->prepare_pdu(REPORT, $this->_create_oid_value_pairs($trios));
}

sub prepare_pdu
{
   my ($this, $type, $var_bind) = @_;

   # Clear the buffer
   $this->_buffer_get;

   # Clear the "scoped" indication
   $this->{_scoped} = FALSE;

   # VarBindList::=SEQUENCE OF VarBind
   if (!defined($this->_prepare_var_bind_list($var_bind || []))) {
      return $this->_error;
   }

   # PDU::=SEQUENCE 
   if (!defined($this->_prepare_pdu_sequence($type))) {
      return $this->_error;
   }

   TRUE;
}

sub prepare_var_bind_list
{
   my ($this, $var_bind) = @_;

   $this->_prepare_var_bind_list($var_bind || []);
}

sub prepare_pdu_sequence
{
   my ($this, $type) = @_;

   $this->_prepare_pdu_sequence($type);
}

sub prepare_pdu_scope
{
   $_[0]->_prepare_pdu_scope;
}

sub process_pdu
{
   my ($this) = @_;

   # Clear any errors 
   $this->_error_clear;

   # PDU::=SEQUENCE
   return $this->_error unless defined($this->_process_pdu_sequence);

   # VarBindList::=SEQUENCE OF VarBind
   $this->_process_var_bind_list;
}

sub process_pdu_scope
{
   $_[0]->_process_pdu_scope;
}

sub process_pdu_sequence
{
   $_[0]->_process_pdu_sequence;
}

sub process_var_bind_list
{
   $_[0]->_process_var_bind_list;
}

sub status_information
{
   my $this = shift;

   if (@_) {
      $this->{_error} = (@_ > 1) ? sprintf(shift(@_), @_) : $_[0];
      if ($this->debug) {
         printf("error: [%d] %s(): %s\n", 
            (caller(0))[2], (caller(1))[3], $this->{_error}
         );
      }
      $this->callback_execute;
   }

   $this->{_error} || '';
}

sub process_response_pdu
{
   $_[0]->callback_execute;
}

sub expect_response
{
   my ($this) = @_;

   if (($this->{_pdu_type} == GET_RESPONSE) ||
       ($this->{_pdu_type} == TRAP)         ||
       ($this->{_pdu_type} == SNMPV2_TRAP)  ||
       ($this->{_pdu_type} == REPORT)) 
   {
      return FALSE;
   }

   TRUE;
}

sub pdu_type
{
   $_[0]->{_pdu_type};
}

sub error_status 
{
   my ($this, $status) = @_;

   # error-status::=INTEGER { noError(0) .. inconsistentName(18) } 

   if (@_ == 2) {
      if (!defined($status)) {
         return $this->_error('error-status not defined');
      }
      if (($status < 0) || 
          ($status > (($this->version > SNMP_VERSION_1) ? 18 : 5))) 
      {
         return $this->_error('Invalid error-status value [%s]', $status);
      }
      $this->{_error_status} = $status;
   }

   $this->{_error_status} || 0; # noError(0)
}

sub error_index
{
   my ($this, $index) = @_;

   # error-index::=INTEGER (0..max-bindings) 

   if (@_ == 2) {
      if (!defined($index)) {
         return $this->_error('error-index not defined');
      }
      if (($index < 0) || ($index > 2147483647)) {
         return $this->_error('Invalid error-index value [%s]', $index);
      }
      $this->{_error_index} = $index;
   }

   $this->{_error_index} || 0; 
}

sub non_repeaters
{
   $_[0]->{_error_status} || 0; # non-repeaters::=INTEGER (0..max-bindings)
}

sub max_repetitions 
{
   $_[0]->{_error_index}  || 0; # max-repetitions::=INTEGER (0..max-bindings)
}

sub enterprise
{
   $_[0]->{_enterprise}; 
}

sub agent_addr
{
   $_[0]->{_agent_addr};
}

sub generic_trap
{
   $_[0]->{_generic_trap};
}

sub specific_trap
{
   $_[0]->{_specific_trap};
}

sub time_stamp
{
   $_[0]->{_time_stamp};
}

sub var_bind_list
{
   my ($this, $vbl, $types) = @_;

   return if defined($this->{_error});

   if (@_ > 1) {

      # The VarBindList HASH is being updated from an external
      # source.  We need to update the VarBind names ARRAY to
      # correspond to the new keys of the HASH.  If the updated
      # information is valid, we will use lexicographical ordering
      # for the ARRAY entries since we do not have a PDU to use
      # to determine the ordering.  The ASN.1 types HASH is also
      # updated here if a cooresponding HASH is passed.  We double
      # check the mapping by populating the hash with the keys of
      # the VarBindList HASH. 

      if (!defined($vbl) || (ref($vbl) ne 'HASH')) {

         $this->{_var_bind_list}  = undef;
         $this->{_var_bind_names} = [];
         $this->{_var_bind_types} = undef; 

      } else {

         $this->{_var_bind_list} = $vbl;

         @{$this->{_var_bind_names}} =
            map  { $_->[0] }
            sort { $a->[1] cmp $b->[1] }
            map  {
               my $oid = $_;
               $oid =~ s/^\.//o;
               $oid =~ s/ /\.0/og;
               [$_, pack('N*', split('\.', $oid))]
            } keys(%{$vbl});

         if (!defined($types) || (ref($types) ne 'HASH')) {
             $types = {};
         }

         map { 
            $this->{_var_bind_types}->{$_} = 
               exists($types->{$_}) ? $types->{$_} : undef; 
         } keys(%{$vbl});

      }

   }

   $this->{_var_bind_list};
}

sub var_bind_names
{
   my ($this) = @_;

   return [] if defined($this->{_error}) || !defined($this->{_var_bind_names});

   $this->{_var_bind_names};
}

sub var_bind_types
{
   my ($this) = @_;

   return if defined($this->{_error});

   $this->{_var_bind_types};
}

sub scoped
{
   $_[0]->{_scoped};
}

# [private methods] ----------------------------------------------------------

sub _prepare_pdu_scope
{
   my ($this) = @_;

   return TRUE if (($this->{_version} < SNMP_VERSION_3) || ($this->{_scoped}));

   # contextName::=OCTET STRING
   if (!defined($this->prepare(OCTET_STRING, $this->context_name))) {
      return $this->_error;
   }

   # contextEngineID::=OCTET STRING
   if (!defined($this->prepare(OCTET_STRING, $this->context_engine_id))) {
      return $this->_error;
   }

   # ScopedPDU::=SEQUENCE
   if (!defined($this->prepare(SEQUENCE))) {
       return $this->_error;
   } 

   # Indicate that this PDU has been scoped and return success.
   $this->{_scoped} = TRUE;
}

sub _prepare_pdu_sequence
{
   my ($this, $type) = @_;

   # Do not do anything if there has already been an error
   return $this->_error if defined($this->{_error});

   # Make sure the PDU type was passed
   return $this->_error('No SNMP PDU type defined') unless (@_ > 0);

   # Set the PDU type
   $this->{_pdu_type} = $type;

   # Make sure the request-id has been set
   if (!exists($this->{_request_id})) {
      $this->{_request_id} = _create_request_id();
   }

   # We need to encode everything in reverse order so the
   # objects end up in the correct place.

   if ($this->{_pdu_type} != TRAP) { # PDU::=SEQUENCE

      # error-index/max-repetitions::=INTEGER 
      if (!defined($this->prepare(INTEGER, $this->{_error_index}))) {
         return $this->_error;
      }

      # error-status/non-repeaters::=INTEGER
      if (!defined($this->prepare(INTEGER, $this->{_error_status}))) {
         return $this->_error;
      }

      # request-id::=INTEGER  
      if (!defined($this->prepare(INTEGER, $this->{_request_id}))) {
         return $this->_error;
      }

   } else { # Trap-PDU::=IMPLICIT SEQUENCE

      # time-stamp::=TimeTicks 
      if (!defined($this->prepare(TIMETICKS, $this->{_time_stamp}))) {
         return $this->_error;
      }

      # specific-trap::=INTEGER 
      if (!defined($this->prepare(INTEGER, $this->{_specific_trap}))) {
         return $this->_error;
      }

      # generic-trap::=INTEGER  
      if (!defined($this->prepare(INTEGER, $this->{_generic_trap}))) {
         return $this->_error;
      }

      # agent-addr::=NetworkAddress 
      if (!defined($this->prepare(IPADDRESS, $this->{_agent_addr}))) {
         return $this->_error;
      }

      # enterprise::=OBJECT IDENTIFIER 
      if (!defined($this->prepare(OBJECT_IDENTIFIER, $this->{_enterprise}))) {
         return $this->_error;
      }

   }

   # PDUs::=CHOICE 
   if (!defined($this->prepare($this->{_pdu_type}))) {
      return $this->_error;
   }

   TRUE;
}

sub _prepare_var_bind_list
{
   my ($this, $var_bind) = @_;

   # The passed array is expected to consist of groups of four values
   # consisting of two sets of ASN.1 types and their values.

   if (@{$var_bind} % 4) {
      $this->var_bind_list(undef);
      return $this->_error(
         'Invalid number of VarBind parameters [%d]', scalar(@{$var_bind})
      );
   }

   # Initialize the "var_bind_*" data.

   $this->{_var_bind_list}  = {};
   $this->{_var_bind_names} = [];
   $this->{_var_bind_types} = {};

   # Use the object's buffer to build each VarBind SEQUENCE and then append
   # it to a local buffer.  The local buffer will then be used to create 
   # the VarBindList SEQUENCE.
    
   my ($buffer, $name_type, $name_value, $syntax_type, $syntax_value) = ('');
 
   while (@{$var_bind}) {

      # Pull a quartet of ASN.1 types and values from the passed array.
      ($name_type, $name_value, $syntax_type, $syntax_value) = 
         splice(@{$var_bind}, 0, 4);

      # Reverse the order of the fields because prepare() does a prepend.

      # value::=ObjectSyntax
      if (!defined($this->prepare($syntax_type, $syntax_value))) {
         $this->var_bind_list(undef);
         return $this->_error;
      }

      # name::=ObjectName
      if ($name_type != OBJECT_IDENTIFIER) {
         $this->var_bind_list(undef);
         return $this->_error('Expected OBJECT IDENTIFIER in VarBindList');
      }
      if (!defined($this->prepare($name_type, $name_value))) {
         $this->var_bind_list(undef);
         return $this->_error;
      }

      # VarBind::=SEQUENCE
      if (!defined($this->prepare(SEQUENCE))) {
         $this->var_bind_list(undef);
         return $this->_error;
      }

      # Append the VarBind to the local buffer.
      $buffer .= $this->_buffer_get;

      # Populate the "var_bind_*" data so we can provide consistent
      # output for the methods regardless of whether we are a request 
      # or a response PDU.  Make sure the HASH key is unique if in 
      # case duplicate OBJECT IDENTIFIERs are provided.

      while (exists($this->{_var_bind_list}->{$name_value})) {
         $name_value .= ' '; # Pad with spaces
      }
 
      $this->{_var_bind_list}->{$name_value}  = $syntax_value;
      $this->{_var_bind_types}->{$name_value} = $syntax_type; 
      push(@{$this->{_var_bind_names}}, $name_value);

   }

   # VarBindList::=SEQUENCE OF VarBind
   if (!defined($this->prepare(SEQUENCE, $buffer))) {
      $this->var_bind_list(undef);
      return $this->_error;
   }

   TRUE;
}

sub _create_oid_null_pairs
{
   my ($this, $oids) = @_;

   return [] unless defined($oids);

   if (ref($oids) ne 'ARRAY') {
      return $this->_error('Expected array reference for variable-bindings');
   }

   my $pairs = [];

   for (@{$oids}) {
      if (!/^\.?\d+\.\d+(?:\.\d+)*/) {
         return $this->_error('Expected OBJECT IDENTIFIER in dotted notation');
      }
      push(@{$pairs}, OBJECT_IDENTIFIER, $_, NULL, '');
   }

   $pairs;
}

sub _create_oid_value_pairs
{
   my ($this, $trios) = @_;

   return [] unless defined($trios);

   if (ref($trios) ne 'ARRAY') {
      return $this->_error('Expected array reference for variable-bindings');
   }

   if (@{$trios} % 3) {
      return $this->_error(
         'Expected [OBJECT IDENTIFIER, ASN.1 type, object value] combination'
      );
   }

   my $pairs = [];

   for (my $i = 0; $i < $#{$trios}; $i += 3) {
      if ($trios->[$i] !~ /^\.?\d+\.\d+(?:\.\d+)*/) {
         return $this->_error('Expected OBJECT IDENTIFIER in dotted notation');
      }
      push(@{$pairs},
         OBJECT_IDENTIFIER, $trios->[$i], $trios->[$i+1], $trios->[$i+2]
      );
   }

   $pairs;
}

sub _process_pdu_scope
{
   my ($this) = @_;

   return TRUE if ($this->{_version} < SNMP_VERSION_3);

   # ScopedPDU::=SEQUENCE
   return $this->_error unless defined($this->process(SEQUENCE));

   # contextEngineID::=OCTET STRING
   if (!defined($this->context_engine_id($this->process(OCTET_STRING)))) {
      return $this->_error;
   }

   # contextName::=OCTET STRING
   if (!defined($this->context_name($this->process(OCTET_STRING)))) {
      return $this->_error;
   } 

   # Indicate that this PDU is scoped and return success.
   $this->{_scoped} = TRUE;
}

sub _process_pdu_sequence
{
   my ($this) = @_;

   # PDUs::=CHOICE
   if (!defined($this->{_pdu_type} = $this->process)) {
      return $this->_error;
   }

   if ($this->{_pdu_type} != TRAP) { # PDU::=SEQUENCE

      # request-id::=INTEGER
      if (!defined($this->{_request_id} = $this->process(INTEGER))) {
         return $this->_error;
      }
      # error-status::=INTEGER
      if (!defined($this->{_error_status} = $this->process(INTEGER))) {
         return $this->_error;
      }
      # error-index::=INTEGER
      if (!defined($this->{_error_index} = $this->process(INTEGER))) {
         return $this->_error;
      }

      # Indicate that we have an SNMP error
      if (($this->{_error_status}) || ($this->{_error_index})) {
         if ($this->{_pdu_type} != GET_BULK_REQUEST) {
            $this->_error(
               'Received %s error-status at error-index %d',
               _error_status_itoa($this->{_error_status}), $this->{_error_index}
            );
         }
      } 

   } else { # Trap-PDU::=IMPLICIT SEQUENCE

      # enterprise::=OBJECT IDENTIFIER
      if (!defined($this->{_enterprise} = $this->process(OBJECT_IDENTIFIER))) {
         return $this->_error;
      }
      # agent-addr::=NetworkAddress
      if (!defined($this->{_agent_addr} = $this->process(IPADDRESS))) {
         return $this->_error;
      }
      # generic-trap::=INTEGER
      if (!defined($this->{_generic_trap} = $this->process(INTEGER))) {
         return $this->_error;
      }
      # specific-trap::=INTEGER
      if (!defined($this->{_specific_trap} = $this->process(INTEGER))) {
         return $this->_error;
      }
      # time-stamp::=TimeTicks
      if (!defined($this->{_time_stamp} = $this->process(TIMETICKS))) {
         return $this->_error;
      }

   }

   TRUE;
}

sub _process_var_bind_list
{
   my ($this) = @_;

   my $value;

   # VarBindList::=SEQUENCE
   if (!defined($value = $this->process(SEQUENCE))) {
      return $this->_error;
   }

   # Using the length of the VarBindList SEQUENCE, 
   # calculate the end index.

   my $end = $this->index + $value;

   $this->{_var_bind_list}  = {};
   $this->{_var_bind_names} = [];
   $this->{_var_bind_types} = {};

   my ($oid, $type);

   while ($this->index < $end) {

      # VarBind::=SEQUENCE
      if (!defined($this->process(SEQUENCE))) {
         return $this->_error;
      }
      # name::=ObjectName
      if (!defined($oid = $this->process(OBJECT_IDENTIFIER))) {
         return $this->_error;
      }
      # value::=ObjectSyntax
      if (!defined($value = $this->process(undef, $type))) {
         return $this->_error;
      }

      # Create a hash consisting of the OBJECT IDENTIFIER as a
      # key and the ObjectSyntax as the value.  If there is a
      # duplicate OBJECT IDENTIFIER in the VarBindList, we pad
      # that OBJECT IDENTIFIER with spaces to make a unique
      # key in the hash.

      while (exists($this->{_var_bind_list}->{$oid})) {
         $oid .= ' '; # Pad with spaces
      }

      DEBUG_INFO('{ %s => %s: %s }', $oid, asn1_itoa($type), $value);
      $this->{_var_bind_list}->{$oid}  = $value;
      $this->{_var_bind_types}->{$oid} = $type;

      # Create an array with the ObjectName OBJECT IDENTIFIERs
      # so that the order in which the VarBinds where encoded
      # in the PDU can be retrieved later.

      push(@{$this->{_var_bind_names}}, $oid);

   }

   # Return an error based on the contents of the VarBindList
   # if we received a Report-PDU.

   return $this->_report_pdu_error if ($this->{_pdu_type} == REPORT);

   # Return the var_bind_list hash
   $this->{_var_bind_list};
}

sub _create_request_id()
{
   (++$REQUEST_ID > ((2**31) - 1)) ? $REQUEST_ID = ($^T & 0xff) : $REQUEST_ID;
}

{
   my @error_status = qw(
      noError
      tooBig
      noSuchName
      badValue
      readOnly
      genError
      noAccess
      wrongType
      wrongLength
      wrongEncoding
      wrongValue
      noCreation
      inconsistentValue
      resourceUnavailable
      commitFailed
      undoFailed
      authorizationError
      notWritable
      inconsistentName
   );

   sub _error_status_itoa
   {
      return '??' unless (@_ == 1);

      if (($_[0] > $#error_status) || ($_[0] < 0)) {
         return sprintf('??(%d)', $_[0]);
      }

      sprintf('%s(%d)', $error_status[$_[0]], $_[0]);
   }
}

{
   my %report_oids = (
      '1.3.6.1.6.3.11.2.1.1' => 'snmpUnknownSecurityModels',
      '1.3.6.1.6.3.11.2.1.2' => 'snmpInvalidMsgs',
      '1.3.6.1.6.3.11.2.1.3' => 'snmpUnknownPDUHandlers',
      '1.3.6.1.6.3.12.1.4'   => 'snmpUnavailableContexts',
      '1.3.6.1.6.3.12.1.5'   => 'snmpUnknownContexts',
      '1.3.6.1.6.3.15.1.1.1' => 'usmStatsUnsupportedSecLevels',
      '1.3.6.1.6.3.15.1.1.2' => 'usmStatsNotInTimeWindows',
      '1.3.6.1.6.3.15.1.1.3' => 'usmStatsUnknownUserNames',
      '1.3.6.1.6.3.15.1.1.4' => 'usmStatsUnknownEngineIDs',
      '1.3.6.1.6.3.15.1.1.5' => 'usmStatsWrongDigests',
      '1.3.6.1.6.3.15.1.1.6' => 'usmStatsDecryptionErrors'
   );

   sub _report_pdu_error
   {
      my ($this) = @_;

      # Remove the leading dot (if present) and replace
      # the dotted notation of the OBJECT IDENTIFIER
      # with the text representation if it is known.

      my $count = 0;
      my %var_bind_list;

      map {
         my $oid = $_;
         $oid =~ s/^\.//;
         $count++;
         map { $oid =~ s/\Q$_/$report_oids{$_}/; } keys(%report_oids);
         $var_bind_list{$oid} = $this->{_var_bind_list}->{$_};
      } @{$this->{_var_bind_names}};
     
      if ($count == 1) {
         # Return the OBJECT IDENTIFIER and value.
         my $oid = (keys(%var_bind_list))[0]; 
         $this->_error(
            'Received %s Report-PDU with value %s', $oid, $var_bind_list{$oid}
         );
      } elsif ($count > 1) {
         # Return a list of OBJECT IDENTIFIERs.
         $this->_error(
            'Received Report-PDU [%s]', join(', ', keys(%var_bind_list))
         );
      } else {
         $this->_error('Received empty Report-PDU');
      }

   }
}

sub DEBUG_INFO
{
   return unless $Net::SNMP::Message::DEBUG;

   printf(
      sprintf('debug: [%d] %s(): ', (caller(0))[2], (caller(1))[3]) .
      ((@_ > 1) ? shift(@_) : '%s') .
      "\n",
      @_
   );

   $Net::SNMP::Message::DEBUG;
}

# ============================================================================
1; # [end Net::SNMP::PDU]
