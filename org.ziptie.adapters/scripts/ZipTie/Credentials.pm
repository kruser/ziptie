package ZipTie::Credentials;

use strict;

use XML::Parser;
use ZipTie::Logger;
use XML::Simple;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

##############################################################################
#
#	METHODS
#
##############################################################################

sub new
{
	my ( $proto, %params ) = @_;
	my $package = ref($proto) || $proto;

	my $self = {
		username          => '',
		password          => '',
		enableUsername    => '',
		enablePassword    => '',
		roCommunityString => '',
		rwCommunityString => '',
	};

	foreach my $key ( keys %params )
	{
		$self->{$key} = $params{$key};
	}

	bless( $self, $package );

	return $self;
}

sub to_string
{
	my $self = shift;

	my $str = '';
	foreach my $key ( keys %$self )
	{
		$str .= $key . " => '" . $self->{$key} . "', ";
	}
	return $str;
}

##############################################################################
#
#	SUB-ROUTINES
#
##############################################################################

sub from_xml
{
	my $in_value = shift or $LOGGER->fatal( "ERROR - No XML specified to convert into a ZipTie::Credentials object!" );

	my $xml_hash_ref = XMLin( $in_value, ContentKey => '-value', ForceArray => [ 'credential' ], );

	# Retrieve all of the credentials
	my $credential_xml_hash_ref = $xml_hash_ref->{credentials}->{credential};

	return ZipTie::Credentials->new(%{$credential_xml_hash_ref});
}

1;

__END__

=head1 NAME

ZipTie::Credentials - A simple hash to store the various credential types that are supported by ZipTie.

=head1 SYNOPSIS

	use ZipTie::Credentials;

	my $credentials = ZipTie::Credentials->new(
		username=> "someUsername",
		password => "somePassword",
		enableUsername => "someEnableUsername"
		enablePassword => "someEnablePassword",
		roCommunityString => "someSNMPReadOnlyCommString",
		rwCommunityString => "someSNMPReadAndWriteCommString"
	);

=head1 DESCRIPTION

The C<ZipTie::Credentials> module defines a simple hash to store the various credential types that are supported by
ZipTie.  Users of an instance C<ZipTie::Credentials> module can reference any entry in the hash that represents a type of
credential to be used by referencing the credential type as the key on the C<ZipTie::Credentials> module hash itself.
These credential types include the following:

=over

=item *

C<username> - The C<username> credential typically represents the user/account login name for authenticating with a device.

=item *

C<password> - The C<password> credential typically represents the password for the user/account login name specified with
for the C<username> credential.

=item *

C<enableUsername> - The C<enableUsername> credential typically represents an administrative level user/account login name
to be used with a device when administrative or super-user privileges are required.

=item *

C<enablePassword> - The C<enablePassword> credential typically represents the password for an administrative level
user/account login name to be used with a device when administrative or super-user privileges are required.

=item *

C<roCommunityString> - The C<roCommunityString> credential represents the read-only string used during an SNMP action
against a device that does not alter the device, such as an SNMP C<GET>, C<GETNEXT>, or C<GETBULK> action.

=item *

C<rwCommunityString> - The C<rwCommunityString> credential represents the read-write string used during an SNMP action
against a device that does alter the device, such as an SNMP C<SET> action.

=back

=head1 METHODS

=over 12

=item C<new(%args)>

Creates a new instance of the C<ZipTie::Credentials> module.  One or more credential types can be specified as arguments
in a key => value format, with the credential type being the key, and the value to set the credential to as the value.

Arguments:

	-username
	-password
	-enableUsername
	-enablePassword
	-roCommunityString
	-rwCommunityString

=item C<to_string()>

Prints out the contents of this instance of the C<ZipTie::Credentials> module a "key => value" style.

Example:

	username=> "someUsername",
	password => "somePassword",
	enableUsername => "someEnableUsername"
	enablePassword => "someEnablePassword",
	roCommunityString => "someSNMPReadOnlyCommString",
	rwCommunityString => "someSNMPReadAndWriteCommString",

=item C<from_xml($input_xml_element)>

Creates a new instance of the C<ZipTie::Credentials> module by parsing an input XML string that represents an XML element
that contains one or many name/value pairs that represent a credential type as the name, and the value of that credential
type as the value.

An example of the input XML string:

	<credentials>
		<credential name="enablePassword" value='someEnablePassword'/>
		<credential name="password" value='somePassword'/>
		<credential name="roCommunityString" value='someRoCommunityString'/>
		<credential name="username" value='someUsername'/>
	</credentials>

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

=head1 AUTHOR

Contributor(s): Leo Bayer (lbayer@ziptie.org), Dylan White (dylamite@ziptie.org)
Date: Jul 1, 2007

=cut
