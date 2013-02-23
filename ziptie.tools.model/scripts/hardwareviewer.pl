#!/usr/bin/perl
use strict;
use Getopt::Long;
use XML::Twig;

use ZipTie::Logger;
use ZipTie::Tools::ServerElf qw(get_zed);

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ($ip);
GetOptions( "ip=s" => \$ip, );

my $zed = get_zed($ip, 'Default');
my ($chassisDoc) = $zed =~ /(<chassis.+<\/chassis>)/s;
if ($chassisDoc)
{
	my $twig = XML::Twig->new(
		twig_roots => {
			'chassis'      => \&_process_hardware,
			'card'         => \&_process_hardware,
			'daughterCard' => \&_process_hardware,
			'cpu'          => \&_process_hardware,
			'powersupply'  => \&_process_hardware,
		},
	);
	$twig->parse($chassisDoc);
	undef $chassisDoc;
	undef $zed;
}
else
{
	print "This device does not have a chassis defined\n";
}

sub _process_hardware
{
	my ( $twig, $element ) = @_;

	my ( $description, $assetType, $make, $model, $part, $serial, $hardware );
	my $description = _get_element_text( $element, 'core:description' );
	my $slot	  	= _get_element_text( $element, 'slotNumber' );
	$slot			= "" if ( !$slot );
	$description =~ s/[\n\r]//g;

	my $asset = $element->first_child('core:asset');
	my $elementName = $element->name;
	$assetType = _get_asset_type( $elementName );
	if ($asset)
	{
		my $factory = $asset->first_child('core:factoryinfo');
		if ($factory)
		{
			$make     = _get_element_text( $factory, 'core:make' );
			$model    = _get_element_text( $factory, 'core:modelNumber' );
			$part     = _get_element_text( $factory, 'core:partNumber' );
			$serial   = _get_element_text( $factory, 'core:serialNumber' );
			$hardware = _get_element_text( $factory, 'core:hardwareVersion' );
		}
	}
	print "\"$elementName\",\"$assetType\",\"$description\",\"$make\",\"$model\",\"$part\",\"$serial\",\"$hardware\",\"$slot\"\n";
}

sub _get_asset_type
{
	my $elementName = shift;
	return 'Card'          if ( $elementName eq 'card' );
	return 'Daughter Card' if ( $elementName eq 'daughterCard' );
	return 'Chassis'       if ( $elementName eq 'chassis' );
	return 'Power Supply'  if ( $elementName eq 'powersupply' );
	return 'CPU'           if ( $elementName eq 'cpu' );
	return $elementName;
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
