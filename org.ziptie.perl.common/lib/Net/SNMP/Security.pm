# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Security;

# $Id: Security.pm,v 1.1 2007/05/31 17:36:51 dwhite Exp $

# Base object that implements the Net::SNMP Security Models.

# Copyright (c) 2001-2004 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Message qw(
   :securityLevels :securityModels :versions TRUE FALSE 
);

## Version of the Net::SNMP::Security module

our $VERSION = v1.1.0;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Exporter );

our @EXPORT_OK;

our %EXPORT_TAGS = (
   levels => [
      qw( SECURITY_LEVEL_NOAUTHNOPRIV SECURITY_LEVEL_AUTHNOPRIV
          SECURITY_LEVEL_AUTHPRIV )
   ],
   models => [ 
      qw( SECURITY_MODEL_ANY SECURITY_MODEL_SNMPV1 SECURITY_MODEL_SNMPV2C
          SECURITY_MODEL_USM )
   ]
);

Exporter::export_ok_tags( qw( levels models ) );

$EXPORT_TAGS{ALL} = [ @EXPORT_OK ];

## Package variables

our $DEBUG = FALSE;  # Debug flag

our $AUTOLOAD;       # Used by the AUTOLOAD method

#perl2exe_include    Net::SNMP::Security::USM

## Load the module for the default Security Model.

require Net::SNMP::Security::Community;

# [public methods] -----------------------------------------------------------

sub new 
{
   my ($class, %argv) = @_;

   my $version = SNMP_VERSION_1;

   # See if a SNMP version has been passed
   foreach (keys %argv) {
      if (/^-?version$/i) {
         if (($argv{$_} == SNMP_VERSION_1)  ||
             ($argv{$_} == SNMP_VERSION_2C) ||
             ($argv{$_} == SNMP_VERSION_3))
         {
            $version = $argv{$_};
         }
      }
   }

   # Return the appropriate object based on the SNMP version.  To avoid
   # consuming unnessary resources, load the User-based Security Model
   # only when requested.  The Net::SNMP::Security::USM module requires 
   # four non-core modules.  If any of these modules are not present, we 
   # gracefully return an error.

   if ($version == SNMP_VERSION_3) {
      if (defined(my $error = load_module('Net::SNMP::Security::USM'))) {
         wantarray ? (undef, 'SNMPv3 support unavailable ' . $error) : undef;
      } else {
         Net::SNMP::Security::USM->new(%argv);
      }
   } else {
      Net::SNMP::Security::Community->new(%argv);
   }
}

sub version
{
   my ($this) = @_;

   if (@_ > 1) {
      $this->_error_clear;
      return $this->_error('SNMP version is not modifiable');
   }

   $this->{_version};
}

sub discovered
{
   TRUE; 
}

sub security_model
{
   # RFC 3411 - SnmpSecurityModel::=TEXTUAL-CONVENTION

   SECURITY_MODEL_ANY; 
}

sub security_level
{
   # RFC 3411 - SnmpSecurityLevel::=TEXTUAL-CONVENTION

   SECURITY_LEVEL_NOAUTHNOPRIV;
}

sub security_name
{
   '';
}

sub debug
{
   (@_ == 2) ? $DEBUG = ($_[1]) ? TRUE : FALSE : $DEBUG;
}

sub error
{
   $_[0]->{_error} || '';
}

sub AUTOLOAD
{
   my ($this) = @_;

   return if $AUTOLOAD =~ /::DESTROY$/;

   $AUTOLOAD =~ s/.*://;

   if (ref($this)) {
      $this->_error(
         'Feature not supported by this Security Model [%s]', $AUTOLOAD
      );
   } else {
      die sprintf('Unsupported function call [%s]', $AUTOLOAD);
   }
}

# [private methods] ----------------------------------------------------------

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
1; # [end Net::SNMP::Security]

