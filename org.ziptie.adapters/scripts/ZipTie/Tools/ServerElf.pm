package ZipTie::Tools::ServerElf;

use strict;
use warnings;

use ZipTie::Client;

use Exporter 'import';
use MIME::Base64 qw(decode_base64);
our @EXPORT_OK = qw(get_zed update_credential update_dependent_credential);

sub get_zed
{
	my ( $ipAddress, $managedNetwork ) = @_;
	return get_configuration($ipAddress, $managedNetwork, '/ZipTie-Element-Document');
}

sub get_configuration
{
	my ( $ipAddress, $managedNetwork, $configurationName ) = @_;
	my $client      = ZipTie::Client->new();
	my $configstore = $client->configstore();
	my $rev         = $configstore->retrieveRevision(
		ipAddress      => $ipAddress,
		managedNetwork => $managedNetwork,
		configPath     => $configurationName,
	);
	$client->logout();
	return decode_base64( $rev->{content} );
}

sub update_credential
{
	my ( $ipAddress, $managedNetwork, $credentialKey, $newCredentialValue ) = @_;
	my $client      = ZipTie::Client->new();
	my $credService = $client->credentials();
	$credService->updateSingleCredential(
		ipAddress       => $ipAddress,
		managedNetwork  => $managedNetwork,
		credentialKey   => $credentialKey,
		credentialValue => $newCredentialValue,
	);
	$credService->purgeUnmappedCredentials();
    $client->logout();
}

sub update_dependent_credential
{
	my ( $ipAddress, $managedNetwork, $credentialKey, $newCredentialValue, $dependentCredentialKey,
		$dependentCredentialValue )
	  = @_;
	my $client      = ZipTie::Client->new();
	my $credService = $client->credentials();
	$credService->updateDependentCredential(
		ipAddress                => $ipAddress,
		managedNetwork           => $managedNetwork,
		credentialKey            => $credentialKey,
		credentialValue          => $newCredentialValue,
		dependentCredentialKey   => $dependentCredentialKey,
		dependentCredentialValue => $dependentCredentialValue,
	);
	$credService->purgeUnmappedCredentials();
    $client->logout();
}

1;

__END__

=head1 NAME

ZipTie::Tools::ServerElf

=head1 SYNOPSIS

    use ZipTie::Tools::ServerElf qw(get_zed);
	my $zed = get_zed($ipAddress, $managedNetwork);
	
    use ZipTie::Tools::ServerElf qw(update_credential);
	update_credential($ipAddress, $managedNetwork, 'enablePassword', $newCredentialValue);

=head1 DESCRIPTION

This module is a simple abstraction of common calls into the ZipTie Server.  
The implementation uses the ZipTie::Client module to call into the server
that is expected to be running on the 'localhost'.

This module also only works within the context of a tool being run
from the ZipTie server, i.e. it doesn't need to know how to login.

=head1 METHODS

=over 12

=item C<get_zed($ipAddress, $managedNetwork)>

Retrieves the latest ZiptieElementDocument, or ZED, for the provided device.

=item C<get_configuration($ipAddress, $managedNetwork, $configurationName)>

Retrieves the latest configuration named $configurationName, for the provided device.

The $configurationName should be the full path, with all paths starting with a forward
slash, '/'.  For example:

	my $runningConfig = ZipTie::Tools::ServerElf::get_configuration('10.100.4.8', 'Default', '/running-config');

=item C<update_credential($ipAddress, $managedNetwork, $credentialKey, $newCredentialValue)>

Utility method to update existing credentil definitions, one key at a time.

	$credentialKey - the credential key must be well known to the ZipTie server. e.g. 'enablePassword'.
	
=item C<update_dependent_credential($ipAddress, $managedNetwork, $credentialKey, $newCredentialValue, $dependentCredentialKey, $dependentCredentialValue)>

Utility method to update existing credentil definitions, one key at a time, but only if the
credentials currently contain a matching credential, defined by the $dependentCredentialKey and $dependentCredentialValue.

For example, if you would like to update the password for a device, but only for the username 'ryan', then you would do the following:

	use ZipTie::Tools::ServerElf qw(update_dependent_credential);
	update_dependent_credential('10.100.4.8', 'Default', 'password', 'myP@ssw0rd', 'username', 'ryan');
	
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

  Contributor(s): rkruse
  Date: Jun 2, 2008

=cut
