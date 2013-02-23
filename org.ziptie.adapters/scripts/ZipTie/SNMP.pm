package ZipTie::SNMP;

use strict;
use Net::SNMP qw(oid_lex_sort oid_base_match SNMP_VERSION_1 DEBUG_ALL);
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub get
{
	# Make sure the Net::SNMP object is valid
	my $session = shift;
	unless ($session)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nNo Net::SNMP object specified to perform an SNMP get action with!");
	}

	# Make sure the reference to the list of object identifiers is valid
	my $var_bind_list_ref = shift;
	unless ($var_bind_list_ref)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nNo object identifiers specified for the SNMP get action!");
	}

	# Retrieve the values for all of the object identifiers in the list
	my $resultRef = $session->get_request( -varbindlist => $var_bind_list_ref );

	# Check to see if the result list reference is valid
	unless ($resultRef)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nError while performing SNMP get action\n[ERROR MESSAGE]\n" . $session->error);
	}

	# Return the reference to the hash that maps object identifiers to their corresponding values on
	# the remote SNMP agent.
	return $resultRef;
}

sub set
{
	my $session = shift;
	unless ($session)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nNo Net::SNMP object specified to perform an SNMP set action with!");
	}

	# Make sure the reference to the list of object identifiers is valid
	my $var_bind_list_ref = shift;
	unless ($var_bind_list_ref)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nNo object identifiers specified for the SNMP set action!");
	}

	# Retrieve the values for all of the object identifiers in the list
	my $resultRef = $session->set_request( -varbindlist => $var_bind_list_ref );

	# Check to see if the result list reference is valid
	unless ($resultRef)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nError while performing SNMP set action\n[ERROR MESSAGE]\n" . $session->error);
	}

	# Return the reference to the hash that maps object identifiers to their corresponding values on
	# the remote SNMP agent.
	return $resultRef;
}

# Returns a simple hash where the key is the OID and the value is the result.
sub walk
{
	my $session = shift;
	my $root_oid = shift;
	unless ($session)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nNo Net::SNMP object specified to perform an SNMP walk action with!");
	}

	my $results = {};

	# Make sure the root OID is valid
	unless ($root_oid)
	{
		$LOGGER->fatal("[$SNMP_ERROR]\nNo root object identifier specified for the SNMP walk action!");
	}

	# Specify the arguments to use for walking
	my @args = ( -varbindlist => [$root_oid] );

	# If the SNMP version is 1, use the GETNEXT request
	if ( $session->version == SNMP_VERSION_1 )
	{
		while ( defined( $session->get_next_request(@args) ) )
		{
			$_ = ( keys( %{ $session->var_bind_list } ) )[0];

			if ( !oid_base_match( $root_oid, $_ ) ) { last; }
			$LOGGER->debug(sprintf( "%s => %s", $_, $session->var_bind_list->{$_} ));
			$results->{$_} = $session->var_bind_list->{$_};
			@args = ( -varbindlist => [$_] );
		}
	}

	# Otherwise, use the faster GETBULK request
	else
	{
		push( @args, -maxrepetitions => 1 );
	  outer: while ( defined( $session->get_bulk_request(@args) ) )
		{

			my @oids = oid_lex_sort( keys( %{ $session->var_bind_list } ) );

			foreach (@oids)
			{

				if ( !oid_base_match( $root_oid, $_ ) ) { last outer; }
				$LOGGER->debug(sprintf( "%s => %s", $_, $session->var_bind_list->{$_} ));
				$results->{$_} = $session->var_bind_list->{$_};    

				# Make sure we have not hit the end of the MIB
				if ( $session->var_bind_list->{$_} eq 'endOfMibView' ) { last outer; }
			}

			# Get the last OBJECT IDENTIFIER in the returned list
			@args = ( -maxrepetitions => 1, -varbindlist => [ pop(@oids) ] );
		}

	}
	return $results;
}

1;

__END__

=head1 NAME

ZipTie::SNMP - Allows easy execution of basic SNMP actions using Net::SNMP as the back-end.

=head1 SYNOPSIS

	use ZipTie::SNMP;
	my $resultsHash = ZipTie::SNMP::get($snmpSession, $var_bind_list_ref);
	my $resultsHash = ZipTie::SNMP::set($snmpSession, $var_bind_list_ref);
	my $resultsHash = ZipTie::SNMP::walk($snmpSession, $root_oid);

=head1 DESCRIPTION

C<ZipTie::SNMP> provides an easy way to execute the following SNMP actions: C<GET>, C<SET>, and C<WALK> (similar to get_next and get_bulk).

Leveraging the power of the C<Net::SNMP> module, only a valid C<Net::SNMP> session, in addition to the necessary parameters,
are needed to execute each action.  In order to create a valid C<Net::SNMP> session, you can use the C<ZipTie::SnmpSessionFactory>
module in conjunction with valid C<ZipTie::ConnectionPath> and C<ZipTie::Credentials> objects to create a valid C<Net::SNMP> session
that utilizes that parameters set on the other specified objects.  If you wish to create a C<Net::SNMP> on your own, refer
the the documentation for that specific module.

=head1 SUBROUTINES

=over 12

=item C<get($snmpSession, $var_bind_list_ref)>

Retrieves information for each I<object identifier (OID)> specified from a remote SNMP agent.

$snmpSession -	A valid C<Net::SNMP> object that contains of the information needed to perform an SNMP
			C<GET> action.  This typically means that following has been specified: the hostname/IP
			of the device to connect to, the port to connect on, and the community strinng
			credential required to retrieve information via SNMP.

$var_bind_list_ref -	A reference to an array of object identifiers, specified in dotted decimal notation.
						Each object identifier will be used to retrieve the value of the objects that correspond
						to the identifier handled by the remote SNMP agent.

Returns a reference to a hash that maps each OID to the values retrieved from the remote SNMP agent.

=item C<set($snmpSession, $var_bind_list_ref)>

Sets the data for each I<object identifier (OID)> specified on a remote SNMP agent.

$snmpSession -	A valid C<Net::SNMP> object that contains of the information needed to perform an SNMP
			C<SET> action.  This typically means that following has been specified: the hostname/IP
			of the device to connect to, the port to connect on, and the community strinng
			credential required to retrieve information via SNMP.

$var_bind_list_ref -	A reference to a list that consists of one or more groups of information.  Each group
						contains three elements: the object identifier (in dotted decimal notation) to reference
						on the remote agent, the object type (in ASN.1 notation), and the actual value to set.
						This essentially means that ever three elements of the list represent a specific "trio"
						of information.

Return a reference to a hash that maps each object identifier to the values that were set on the remote SNMP agent.

=item C<walk($snmpSession, $root_oid)>

Retrieves the contents of a specified root I<object identifier (OID)> node and all of it's children's OIDs from a remote
SNMP agent.  This is accomplished by "walking" the subtree of OIDs from the root OID using either the SNMP I<GETNEXT> action
(SNMP version 1 only), or the SNMP I<GETBULK> action (SNMP version 2 and above).

$snmpSession -	A valid C<Net::SNMP> object that contains of the information needed to perform an SNMP
			C<GETNEXT> or C<GETBULK> action.  This typically means that following has been specified: the hostname/IP
			of the device to connect to, the port to connect on, and the community strinng
			credential required to retrieve information via SNMP.

$root_oid -	The root OID that will be used as a starting point that will have it and it's children OIDs traversed using either
			the SNMP I<GETNEXT> action (SNMP version 1 only), or the SNMP I<GETBULK> action (SNMP version 2 and above).

Returns a hash that maps each OID to the values retrieved from the remote SNMP agent.

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

Contributor(s): dwhite (dylamite@ziptie.org)
Date: Jun 27, 2007

=cut

