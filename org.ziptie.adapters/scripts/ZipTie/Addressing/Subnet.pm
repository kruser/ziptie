package ZipTie::Addressing::Subnet;

use strict;
use warnings;
use Math::BigInt;
use Net::IP;
use integer;

my $LOW_32_BIT_VALUE = 0x80000000;
my $LOW_128_BIT_VALUE = new Math::BigInt('-85070591730234615865843651857942052864');

sub new
{
	my $class_name = shift;
	my $host       = shift;
	my $mask       = shift;

	if ( !defined $mask )
	{
		$mask = 32;
	}

	my $hostIp = new Net::IP($host);

	my $shifted;
	if ( $hostIp->version == 6 )
	{
		$shifted = $LOW_128_BIT_VALUE;
		$shifted->brsft($mask - 1);
	}
	else
	{
		$shifted = $LOW_32_BIT_VALUE >> ( $mask - 1 );
	}

	my $bigInt = $hostIp->intip();
	$bigInt->band($shifted);

	my $intIp    = Net::IP::ip_inttobin( $bigInt, $hostIp->version );
	my $stringIp = Net::IP::ip_bintoip( $intIp,   $hostIp->version );
	my $subnet = new Net::IP( $stringIp . '/' . $mask );

	my $this = {
		hostNetIp   => $hostIp,
		mask        => $mask,
		subnetNetIp => $subnet,
		originalHost => $host,
		originalMask => $mask,
	};

	bless( $this, $class_name );
	return $this;
}

sub to_string
{
	my $this = shift;
	if (defined $this->{subnetNetIp})
	{
		return $this->{subnetNetIp}->print;
	}
	else
	{
		return 'INVALID SUBNET DEFINITION: '.$this->{originalHost}.'/'.$this->{originalMask};
	}
}

sub contains
{
	my $this       = shift;
	my $targetHost = shift;
	
	my $targetNetIp = new Net::IP($targetHost);
	if (defined $this->{subnetNetIp} && defined $targetNetIp)
	{
		return $this->{subnetNetIp}->overlaps($targetNetIp);
	}
	else
	{
		return 0;
	}
}

1;

__END__

=head1 NAME

ZipTie::Addressing::Subnet

=head1 SYNOPSIS

    use ZipTie::Addressing::Subnet;
    my $host = '192.168.1.50';   # doesn't need to be the network address
    my $mask = 24;
	my $subnet = ZipTie::Addressing::Subnet->new($host, $bitMask);
	if ($subnet->contains('192.168.1.33'))
	{
		print 'Yes, this would be the case';
	}
	

=head1 DESCRIPTION

Build a subnet definition, IPv4 or IPv6 based on any host address in the subnet, and a subnet mask in bits.

Requires Net::IP to function.

=head1 CONSTRUCTOR

=over 12

=item C<new($host, $bitMask)>

Builds a ZipTie::Addressing::Subnet object from a host and mask.

=head1 METHODS

=over 12

=item C<to_string()>

Returns the subnet in slash notation form.  For example '192.168.20.0/8';

=item C<contains($host)>

Returns true if the subnet contains or overlaps the provided host.  The host
arguments should be a string form of an IP address.

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
  Date: Jul 23, 2008

=cut
