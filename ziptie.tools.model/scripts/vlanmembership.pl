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
my ($doc) = $zed =~ /(<vlans.+<\/vlans>)/s;
if ($doc)
{
	my $twig = XML::Twig->new( twig_roots => { 'vlan' => \&_process_vlan } );
	$twig->parse($doc);
	undef $doc;
	undef $zed;
}
else
{
	print ",,No vlans defined on this device\n";
}

sub _process_vlan
{
	my ( $twig, $vlan ) = @_;
	my $name = _get_element_text($vlan, 'name');
	my $number = _get_element_text($vlan, 'number');
	foreach my $port ( $vlan->descendants('interfaceMember') )
	{
		my $portName = $port->text;
		print '"'.$number.'","'.$name.'","'.$portName.'"'."\n" if $portName;
	}
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