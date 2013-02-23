package ZipTie::HTTP;

use strict;
use LWP::UserAgent;
use HTTP::Response;
use HTTP::Request;
use ZipTie::Logger;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub new
{
	my $class_name = shift;

	# Initialize this instance of the class
	my $this = {
		client       => undef,
		protocol_name => undef,
		ip_address    => undef,
		port         => undef,
		username     => undef,
		password     => undef,
	};

	# The HTTP agent will need to make heavy use of the ZipTie::HTTPClient class to provide the functionality
	# needed to get/retrieve data via HTTP/HTTPS.  Default the timeout to 30 seconds.
	$this->{client} = ZipTie::HTTPClient->new();
	$this->{client}->timeout(30);
	$this->{client}->protocols_allowed( [ 'http', 'https' ] );

	# Turn $this into a ZipTie::HTTP object
	bless( $this, $class_name );

	# Return the object
	return $this;
}

sub connect
{
	my $this         = shift;    
	my $protocol_name = shift;
	my $ip_address    = shift;
	my $port         = shift;
	my $username     = shift;
	my $password     = shift;
	my $relativeUrl = shift;
	
	# Verify that the protocol is either HTTP or HTTPS
	my $lcProtocolName = lc($protocol_name);
	unless ($lcProtocolName eq "http" || $lcProtocolName eq "https")
	{
		$LOGGER->fatal("[$HTTP_ERROR]\n'$lcProtocolName' is NOT a supported protocol!");
	}
	
	# Set the name of the protocol that is being used
	$this->{protocol_name} = uc($protocol_name);

	# Store the parameters passed in for future requests
	my $client = $this->{client};
	$this->{ip_address} = $ip_address;
	
	if (!defined($port) || $port <= 0)
	{
		$LOGGER->debug("Invalid port '$port' defined."); 
		if ($lcProtocolName eq "http" )
		{
			$LOGGER->debug("Defaulting to port '80' ");
			$port = 80;
		}
		else
		{
			$LOGGER->debug("Defaulting to port '443' ");
			$port = 443;
		}
	}
	
	$this->{port} = $port;
	$client->set_username($username);
	$client->set_password($password);

	# Do a simple get against the device to verify we could connect
	$this->get($relativeUrl);

	# If we have gotten this far, we have successfully connected
	$LOGGER->debug("Connected successfully to $ip_address over port $port using $this->{protocol_name}");
}

sub get
{
	my $this         = shift;
	my $relative_url = shift;
	my $protocol     = lc($this->get_protocol_name());
	my $absolute_url =
	    $protocol . '://'
	  . $this->get_ip_address() . ':'
	  . $this->get_port() . '/'
	  . $relative_url;

	# Send a get request for the URL and store the response (an HTTP::Response object)
	my $client   = $this->{client};
	my $response = $client->get($absolute_url);

	# Do some error handling
	#
	# If we weren't able to get a response
	unless ( $response->is_success )
	{
		# Check for invalid credentials
		if ($response->code() == 401)
		{
			$LOGGER->fatal("[$INVALID_CREDENTIALS]\n" .
							"Invalid credentials used when authenticating with '$absolute_url'\n" .
							($response->header('WWW-Authenticate') || "Error accessing $absolute_url" ) . 
							"\n " .
				  			$response->status_line);
		}
		
		$LOGGER->fatal("[$HTTP_ERROR]\n" .
						($response->header('WWW-Authenticate') || "Error accessing $absolute_url" ) . 
						"\n " .
			  			$response->status_line);
	}

	# Return the raw HTML content as well as the actual HTTP::Response object;
	return wantarray ? ( $response->content, $response ) : $response->content;
}

sub post
{
	my $this         = shift;
	my $relative_url = shift;
	my $form_ref     = shift;
	
	my $protocol     = lc($this->get_protocol_name());
	my $absolute_url =
	    $protocol . '://'
	  . $this->get_ip_address() . ':'
	  . $this->get_port() . '/'
	  . $relative_url;

	# Send a get request for the URL and store the response (an HTTP::Response object)
	my $client   = $this->{client};
	my $response = $client->post($absolute_url, $form_ref);

	# Do some error handling
	#
	# If we weren't able to get a response
	unless ( $response->is_success )
	{
		# Check for invalid credentials
		if ($response->code() == 401)
		{
			$LOGGER->fatal("[$INVALID_CREDENTIALS]\n" .
							"Invalid credentials used when authenticating with '$absolute_url'\n" .
							($response->header('WWW-Authenticate') || "Error accessing $absolute_url" ) . 
							"\n " .
				  			$response->status_line);
		}
		
		$LOGGER->fatal("[$HTTP_ERROR]\n" .
						($response->header('WWW-Authenticate') || "Error accessing $absolute_url" ) . 
						"\n " .
			  			$response->status_line);
	}

	# Return the raw HTML content as well as the actual HTTP::Response object;
	return wantarray ? ( $response->content, $response ) : $response->content;
}

sub get_ip_address
{
	my $this = shift;
	return $this->{ip_address};
}

sub get_port
{
	my $this = shift;
	return $this->{port};
}

sub get_protocol_name
{
	my $this = shift;
	return $this->{protocol_name};
}

sub get_timeout
{
	my $this = shift;
	return $this->{client}->timeout();
}

sub set_timeout
{
	my $this = shift;
	if (@_)
	{
		my $newTimeout = shift;
		$this->{client}->timeout($newTimeout);
	}
}

{
	package ZipTie::HTTPClient;
	our @ISA = qw(LWP::UserAgent);

	sub new
	{
		my $class_name = shift;
		my $args       = @_;

		my $this = LWP::UserAgent->new($args);
		$this->{username} = undef;
		$this->{password} = undef;

		# Turn $this into a ZipTie::HTTPClient object
		bless( $this, $class_name );

		# Return the object
		return $this;
	}

	sub get_basic_credentials
	{
		my ( $this, $realm, $uri ) = @_;
		return ( $this->{username}, $this->{password} );
	}

	sub set_username
	{
		my $this = shift;
		if (@_)
		{
			$this->{username} = shift;
		}
	}

	sub set_password
	{
		my $this = shift;
		if (@_)
		{
			$this->{password} = shift;
		}
	}
}

1;

__END__

=head1 NAME

ZipTie::HTTP - Agent/client for performing various HTTP/HTTPS requests.

=head1 SYNOPSIS

	use ZipTie::HTTP;

	my $http_agent = ZipTie::HTTP->new();
	$http_agent->connect("HTTP", "10.10.10.10", 80, "someUsername", "somePassword");

	my $index_page_response = $http_agent->get("index.html");

=head1 DESCRIPTION

C<ZipTie::HTTP> serves an agent/client for performing various HTTP/HTTPS requests.  It utilizes much of the C<LWP> modules
(C<LWP::UserAgent>, C<HTTP::Reponse>, C<HTTP::Request>, etc.) to provide an easy interface for performing C<GET> and C<POST>
requests.  Please refer to the documentation for C<LWP> for more understanding and context around the modules that provide
the core functionality to this module.

In order to enable HTTPS support, the C<Crypt::SSLeay> module must be properly installed on your system.  This is not a
requirement of C<ZipTie::HTTP> explicitly, but is implicit because the underlying functionality provided by the LWP and
HTTP modules utilize the C<Crypt::SSLeay> module.  Refer to the "SEE ALSO" section of this documentation for link to the
C<Crypt::SSLeay> module documentation.

=head1 METHODS

=over 12

=item C<new()>

Creates a new instance of the C<ZipTie::HTTP> module with a default timeout value of 30 seconds.  This value can be altered
by a call to set_timeout($timeout).

After creating a new instance of the C<ZipTie::HTTP> module, it is assumed that the
C<connect($protocol_name, $ip_address, $port, $username, $password)> method will be called in order to establish and verify
a connection a the HTTP/HTTPS enabled device.

=item C<connect($protocol_name, $ip_address, $port, $username, $password, $relativeUrl)>

Connects to a device at a specified IP address and port using the specified protocol and any credentials that may be required.
The protocol that is specified must either be "HTTP" or "HTTPS", with it being case-insensitive.  Also, the username and
password parameters are optional depending on whether or not the device requires username/password authentication.

In order to use HTTPS to connect to a device, the C<Crypt::SSLeay> module must be properly installed.  Refer to the
"SEE ALSO" section of this documentation for link to the C<Crypt::SSLeay> module documentation.

$protocol_name -	The name of the protocol to use, either HTTP or HTTPS is supported.
$ip_address -		The administrative IP address of a device.
$port -				The port to connect to on the device.
$username -			Optional. The username credential for the device.
$password -			Optional. The password credential for the device.
$relativeUrl -		Optional. The relativeUrl to connect to.  This is usually necessary if an HTTPS server requires that you login using some page
				    other than the root.

=item C<get($relative_url)>

Sends a HTTP C<GET> request to a URL that is relative the the hostname/IP address that this C<ZipTie::HTTP>
object is currently connected to; the results from the request will be retrieved.

$relative_url -	A URL that is relative to the hostname/IP address that this C<ZipTie::HTTP object> is already connected to.
				For example,  if connected to "10.100.10.10", the relative URL could be something like "home.htm" or
				"someone/somedir/righthere/blarg.htm".

Depending on the context of the call, different values will be returned.  If a scalar return context is desired, the raw
HTML contents of the C<GET> request response will be returned.  If an array/list return context is desired, the raw HTML
contents along with a C<HTTP::Response> object that encapsulates the raw response will be returned.

=item C<post($relative_url, $form_ref)>

Sends a HTTP C<POST> request to a URL that is relative the the hostname/IP address that this C<ZipTie::HTTP>
object is currently connected to.  This method is essentially an interface to the LWP::UserAgent method, which
itself is just a wrapper for the C<HTTP::Request::Common::POST> method fuctionality.  Refer to the documentation for either
of these modules/methods for more information on the parameters passed in.

$relative_url -	A URL that is relative to the hostname/IP address that this C<ZipTie::HTTP> object is already connected to.
				For example,  if connected to "10.100.10.10", the relative URL could be something like "home.htm" or
				"someone/somedir/righthere/blarg.htm".

$form_ref -	A reference to either a hash or array that stores key-value pairs for any addition parameters and/or headers
			that should be part of this C<POST> request.  This will eventually be passed to the C<HTTP::Request::Common::POST>
			method, so please refer to its documentation if more context is required.

Depending on the context of the call, different values will be returned.  If a scalar return context is desired, the raw
HTML contents of the C<POST> request response will be returned.  If an array/list return context is desired, the raw HTML
contents along with a C<HTTP::Response> object that encapsulates the raw response will be returned.

=item C<get_ip_address()>

Retrieves the IP address that this C<ZipTie::HTTP> object is connected to.

=item C<get_port()>

Retrieves the port that this C<ZipTie::HTTP> object is connected over.

=item C<get_protocol_name()>

Retrieves the name of the protocol used by this C<ZipTie::HTTP> object for connecting to a server.  This will either be
"HTTP" or "HTTPS" but will be case-insensitive.

=item C<get_timeout()>

Retrieves the time, in seconds, that this C<ZipTie::HTTP> object will wait before timing out during a connection or specific
request.

=item C<set_timeout($timeout)>

Specifies the time, in seconds, that this C<ZipTie::HTTP> object will wait before timing out during a connection or specific
request.

=back

=head1 ZipTie::HTTPClient Inner Class

=head2 NAME

C<ZipTie::HTTPClient> - Inner-class of the C<ZipTie::HTTP> module to handle username/password credential authentication.

=head2 SYNOPSIS

=head2 DESCRIPTION

The C<ZipTie::HTTPClient> is an inner-class of the C<ZipTie::HTTP> module that handles username/password credential
authentication.  This is achieved by extending the C<LWP::UserAgent> module to always return a particular username and
password anytime a call is made to C<get_basic_credentials> method.  This allows one to control the exact username and password
that is should be used without having to parse every single HTTP header after a request to figure out what the realm is for
authentication.

=head2 METHODS THAT ARE OVERWRITTEN

=over 12

=item C<get_basic_credentials()>

Overrides the C<LWP::UserAgent::get_basic_credentials()> module to return the username and password values set by
calls to C<set_username($username)> and C<set_password($password)>.

=back

=head2 METHODS

=over 12

=item C<new(@args)>

Creates a new instance of the C<ZipTie::HTTPClient> class, which is just an implementation of the C<LWP::UserAgent> class.
Any possible arguments that could be passed into the constructor for the C<LWP::UserAgent> module can also be passed into
this method.

=item C<set_username($username)>

Sets the username credential that will be used in any authentication is required by any requests.

=item C<set_password($password)>

Sets the password credential that will be used in any authentication is required by any requests.

=back

=head1 SEE ALSO

C<LWP> - L<http://search.cpan.org/~gaas/libwww-perl-5.805/lib/LWP.pm>

C<Crypt::SSLeay> - L<http://search.cpan.org/~dland/Crypt-SSLeay-0.55/SSLeay.pm>

C<LWP::UserAgent> - L<http://search.cpan.org/~gaas/libwww-perl-5.805/lib/LWP/UserAgent.pm>

C<HTTP::Reponse> - L<http://search.cpan.org/~gaas/libwww-perl-5.805/lib/HTTP/Response.pm>

C<HTTP::Request> - L<http://search.cpan.org/~gaas/libwww-perl-5.805/lib/HTTP/Request.pm>

C<HTTP::Request::Common> - L<http://search.cpan.org/~gaas/libwww-perl-5.805/lib/HTTP/Request/Common.pm>

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
Date: Jun 28, 2007

=cut
