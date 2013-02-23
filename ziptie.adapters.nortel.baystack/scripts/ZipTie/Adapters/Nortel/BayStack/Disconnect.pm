package ZipTie::Adapters::Nortel::BayStack::Disconnect;    

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
	
	my $prompt = $cliProtocol->get_prompt_by_name( "prompt" );
	if ($prompt)
	{
		$cliProtocol->send("logout");
	}
	$cliProtocol->send_as_bytes("03");  # ctrl+c
	$cliProtocol->send("l");		# logout from CLI if there
	
	# Disconnect from the CLI protocol
	$cliProtocol->disconnect();
}

1;
