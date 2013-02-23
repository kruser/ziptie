#!/usr/bin/perl
use strict;
use Getopt::Long;
use Text::CSV;
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

my $ip;
GetOptions( "ip=s" => \$ip, );

my $zed = get_zed( $ip, 'Default' );
my ($filterListsDoc) = $zed =~ /(<filterLists.+<\/filterLists>)/s;
if ($filterListsDoc)
{
	my $twig = XML::Twig->new( twig_roots => { 'filterList' => \&_process_filter_list } );
	$twig->parse($filterListsDoc);
	undef $filterListsDoc;
	undef $zed;
}
else
{
	print "No filters defined on this device\n";
}

sub _process_filter_list
{
	my ( $twig, $filterList ) = @_;
	my $filterListName = $filterList->first_child('name')->text;
	foreach my $filterEntryElement ( $filterList->descendants('filterEntry') )
	{
		my $filterEntry = _get_element_text( $filterEntryElement, 'name' );
		$filterEntry = _get_element_text( $filterEntryElement, 'processOrder' ) if ( !$filterEntry );
		my $primaryAction = _get_element_text( $filterEntryElement,   'primaryAction' );
		my $protocol      = _get_element_text( $filterEntryElement,   'protocol' );
		my $srcAddr       = _get_filter_addr( $filterEntryElement,    'sourceIpAddr' );
		my $srcService    = _get_filter_service( $filterEntryElement, 'sourceService' );
		my $dstAddr       = _get_filter_addr( $filterEntryElement,    'destinationIpAddr' );
		my $dstService    = _get_filter_service( $filterEntryElement, 'destinationService' );
		my $logging       = _get_element_text( $filterEntryElement,   'log' );

		print
		  "$filterListName,$filterEntry,$primaryAction,$protocol,$srcAddr,$srcService,$dstAddr,$dstService,$logging\n";
	}
}

sub _get_filter_service
{
	my ( $filterElement, $child ) = @_;
	my $result;
	foreach my $filterIp ( $filterElement->descendants($child) )
	{
		$result .= '; ' if ($result);

		# first check portExpressions
		my $portExpression = $filterIp->first_child('portExpression');
		if ($portExpression)
		{
			my $port     = _get_element_text( $portExpression, 'port' );
			my $operator = _get_element_text( $portExpression, 'operator' );
			$result .= $operator . ' ' . $port;
			next;
		}

		# now check ranges.
		my $range = $filterIp->first_child('portRange');
		if ($range)
		{
			my $start = _get_element_text( $range, 'portStart' );
			my $end   = _get_element_text( $range, 'portEnd' );
			$result .= $start . '-' . $end;
			next;
		}

		# finally check object-groups if we're still here
		my $objectGroup = _get_element_text( $filterIp, 'objectGroupReference' );
		if ($objectGroup)
		{
			$result .= $objectGroup;
			next;
		}
	}
	return $result;
}

sub _get_filter_addr
{
	my ( $filterElement, $child ) = @_;
	my $result;
	foreach my $filterIp ( $filterElement->descendants($child) )
	{
		$result .= '; ' if ($result);

		# first check hosts
		my $address = _get_element_text( $filterIp, 'host' );
		if ($address)
		{
			$result .= $address;
			next;
		}

		# now check networks.
		my $network = $filterIp->first_child('network');
		if ($network)
		{
			my $net  = _get_element_text( $network, 'address' );
			my $mask = _get_element_text( $network, 'mask' );
			$result .= $net . '/' . $mask;
			next;
		}

		# now check ranges.
		my $range = $filterIp->first_child('range');
		if ($range)
		{
			my $start = _get_element_text( $range, 'startAddress' );
			my $end   = _get_element_text( $range, 'endAddress' );
			$result .= $start . '/' . $end;
			next;
		}

		# finally check object-groups if we're still here
		my $objectGroup = _get_element_text( $filterIp, 'objectGroupReference' );
		if ($objectGroup)
		{
			$result .= $objectGroup;
			next;
		}
	}
	return $result;
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
