#!/usr/bin/perl
use strict;
use Getopt::Long;
use Text::CSV;
use XML::Twig;

use ZipTie::Tools::ServerElf qw(get_zed);
use ZipTie::Logger;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ( $ip, );
GetOptions( "ip=s" => \$ip, );

my $zed = get_zed($ip, 'Default');
my ($doc) = $zed =~ /(<interfaces.+<\/interfaces>)/s;
if ($doc)
{
	my $twig = XML::Twig->new(
		twig_roots => {
			'cisco:interface' => \&_process_interface,
			'interface'       => \&_process_interface,
		}
	);
	$twig->parse($doc);
	undef $doc;
	undef $zed;
}
else
{
	print ",,No interfaces defined on this device\n";
}

sub _process_interface
{
	my ( $twig, $interfaceElement ) = @_;
	my ( $adminStatus, $name, $type, $ips, $speed, $mtu, $mac );
	$adminStatus = _get_element_text( $interfaceElement, 'adminStatus' );
	$name        = _get_element_text( $interfaceElement, 'name' );
	$type        = _get_element_text( $interfaceElement, 'interfaceType' );
	$mtu         = _get_element_text( $interfaceElement, 'mtu' );
	$speed       = _get_element_text( $interfaceElement, 'speed' );

	my $ethernet = $interfaceElement->first_child('interfaceEthernet');
	if ($ethernet)
	{
		$mac = _get_element_text( $ethernet, 'macAddress' );
	}

	my $ipProps = $interfaceElement->first_child('interfaceIp');
	if ($ipProps)
	{
		foreach my $ipConfig ( $ipProps->descendants('ipConfiguration') )
		{
			$ips .= ', ' if $ips;
			my $ip   = _get_element_text( $ipConfig, 'ipAddress' );
			my $mask = _get_element_text( $ipConfig, 'mask' );

			$ips .= $ip;
			$ips .= '/' . $mask if ( defined $mask );
		}
	}

	print '"'
	  . $adminStatus . '","'
	  . $name . '","'
	  . $type . '","'
	  . $ips . '","'
	  . $speed . '","'
	  . $mtu . '","'
	  . $mac . '"'
	  . "\n";
}

sub _get_element_text
{

	# if the element is defined this returns the text value of the element.
	# if the element is not defined this returns undef;
	my ( $twig, $elementName ) = @_;
	my $child = $twig->first_child($elementName);
	if ($child)
	{
		return $child->text();
	}
	else
	{
		return undef;
	}
}

