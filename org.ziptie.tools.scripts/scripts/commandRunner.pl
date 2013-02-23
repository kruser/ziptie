#!/usr/bin/perl
use strict;
use Getopt::Long;
use MIME::Base64 'decode_base64';
use XML::Simple;

use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::Adapters::Invoker;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ( $connectionPathXml, $adapterId, $commandList, $promptOverride, );
GetOptions(
	"connectionPath=s" => \$connectionPathXml,
	"adapterId=s"      => \$adapterId,
	"commandList=s"    => \$commandList,
	"promptOverride:s" => \$promptOverride,
);

my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $device = $connectionPath->get_ip_address();

my $commandsXml    = '<commandList printStdout="false">';
my @commands = split(/\n/, $commandList);
foreach my $command (@commands)
{
	my $commandData = {
		command => $command,
		stripPrompt => 'false',
		promptOverride => $promptOverride,
	};
	$commandsXml .= XMLout($commandData, RootName => 'commandData');;
}
$commandsXml .= '</commandList>';

my $operation = 'commands';
$connectionPathXml =~ s/(<\/\w+>)$/$commandsXml$1/;
 
my $start            = time();
my $response;
eval { $response = ZipTie::Adapters::Invoker::invoke( $adapterId, $operation, $connectionPathXml ); };
my $secondsLapsed = time() - $start;
if ($@)
{
	if ( $@ =~ /Can't locate.+\.pm|Can't locate object method/i )
	{
		print "WARN,$device\n";
		print "\n";
		print "The \"$operation\" operation is not yet implemented for the $adapterId adapter\n";
		print "\n";
		print "Visit http://www.ziptie.org/zde for information on how to extend the $adapterId adapter.";
	}
	else
	{
		print "ERROR,$device,$secondsLapsed\n";
		print "\n";
		print "$@";
	}
}
else
{
	print "OK,$device,$secondsLapsed\n\n";
	my @cmds = @{$response->{commands}};
	foreach my $cmd (@cmds)
	{
		print decode_base64($cmd->{response});	
	}
}
