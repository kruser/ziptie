# -*- mode: perl -*- 
# ============================================================================

package Net::SNMP::Security::Community;

# $Id: Community.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Object that implements the SNMPv1/v2c Community-based Security Model.

# Copyright (c) 2001-2005 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Security qw( SECURITY_MODEL_SNMPV1 SECURITY_MODEL_SNMPV2C );

use Net::SNMP::Message qw(
   OCTET_STRING SEQUENCE INTEGER SNMP_VERSION_1 SNMP_VERSION_2C TRUE
); 

## Version of the Net::SNMP::Security::Community module

our $VERSION = v1.1.1;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Net::SNMP::Security Exporter );

sub import
{
   Net::SNMP::Security->export_to_level(1, @_);
}

## RFC 3584 - snmpCommunityName::=OCTET STRING 

sub COMMUNITY_DEFAULT() { 'public' }

# [public methods] -----------------------------------------------------------

sub new 
{
   my ($class, %argv) = @_;

   # Create a new data structure for the object
   my $this = bless {
      '_error'     => undef,             # Error message
      '_version'   => SNMP_VERSION_1,    # SNMP version
      '_community' => COMMUNITY_DEFAULT  # Community name

   }, $class;

   # Now validate the passed arguments

   foreach (keys %argv) {
      if (/^-?community$/i) {
         $this->_community($argv{$_});
      } elsif (/^-?debug$/i) {
         $this->debug($argv{$_}); 
      } elsif (/^-?version$/i) {
         $this->_version($argv{$_});
      } else {
         $this->_error("Invalid argument '%s'", $_);
      }

      if (defined($this->{_error})) {
         return wantarray ? (undef, $this->{_error}) : undef;
      }
   }

   # Return the object and an empty error message (in list context)
   wantarray ? ($this, '') : $this;
}

sub generate_request_msg
{
   my ($this, $pdu, $msg) = @_;

   # Clear any previous errors
   $this->_error_clear;

   return $this->_error('Required PDU and/or Message missing') unless (@_ == 3);

   if ($pdu->version != $this->{_version}) {
      return $this->_error('Invalid version [%d]', $pdu->version);
   }

   # Append the PDU
   if (!defined($msg->append($pdu->copy))) {
      return $this->_error($msg->error);
   }

   # community::=OCTET STRING
   if (!defined($msg->prepare(OCTET_STRING, $this->{_community}))) {
      return $this->_error($msg->error);
   }

   # version::=INTEGER
   if (!defined($msg->prepare(INTEGER, $this->{_version}))) {
      return $this->_error($msg->error);
   }

   # message::=SEQUENCE
   if (!defined($msg->prepare(SEQUENCE))) {
      return $this->_error($msg->error);
   }

   # Return the message
   $msg;
}

sub process_incoming_msg
{
   my ($this, $msg) = @_;

   # Clear any previous errors
   $this->_error_clear;

   return $this->_error('Required Message missing') unless (@_ == 2);

   if ($msg->security_name ne $this->{_community}) {
      return $this->_error('Bad incoming community [%s]', $msg->security_name);
   }

   TRUE;
}

sub community
{
   $_[0]->{_community};
}

sub security_model
{
   my ($this) = @_;

   # RFC 3411 - SnmpSecurityModel::=TEXTUAL-CONVENTION 

   if ($this->{_version} == SNMP_VERSION_2C) {
      SECURITY_MODEL_SNMPV2C;
   } else {
      SECURITY_MODEL_SNMPV1; 
   }
}

sub security_name
{
   $_[0]->{_community};
}

# [private methods] ----------------------------------------------------------

sub _community
{
   my ($this, $community) = @_;

   return $this->_error('Community not defined') unless defined($community);
   
   $this->{_community} = $community;
}

sub _version
{
   my ($this, $version) = @_;

   if (($version != SNMP_VERSION_1) && ($version != SNMP_VERSION_2C)) {
      return $this->_error('Invalid SNMP version specified [%s]', $version);
   }

   $this->{_version} = $version;
}

sub DEBUG_INFO
{
   return unless $Net::SNMP::Security::DEBUG;

   printf(
      sprintf('debug: [%d] %s(): ', (caller(0))[2], (caller(1))[3]) .
      ((@_ > 1) ? shift(@_) : '%s') .
      "\n",
      @_
   );

   $Net::SNMP::Security::DEBUG;
}

# ============================================================================
1; # [end Net::SNMP::Security::Community]

