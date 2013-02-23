package ZipTie::Adapters::CheckPoint::SecurePlatform::Disconnect;

use strict;
use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Logger;

use Exporter 'import';
our @EXPORT_OK = qw(disconnect);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub disconnect
{
	# Grab the CLI protocol
	my $cliProtocol = shift;
	
	# Close this session and exit
	$cliProtocol->send("exit");
	$cliProtocol->send("exit");
	
	# Finally, disconnect from our CLIProtocol
	$cliProtocol->disconnect();
}

1;