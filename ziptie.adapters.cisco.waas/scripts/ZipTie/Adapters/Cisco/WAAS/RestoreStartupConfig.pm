package ZipTie::Adapters::Cisco::WAAS::RestoreStartupConfig;

use strict;
use warnings;

use ZipTie::Response;
use ZipTie::TransferProtocolFactory;
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(escape_filename);

my $LOGGER = ZipTie::Logger::get_logger();

sub restore_via_tftp
{
	my ( $connection_path, $cli_protocol, $startup_file ) = @_;
	my $enable_prompt       = $cli_protocol->get_prompt_by_name("enablePrompt");
	my $tftp_file_server    = $connection_path->get_file_server_by_name("TFTP");
	my $startup_config_name = escape_filename ( $cli_protocol->get_ip_address() ) . ".startup-config";
	my $startup_config_file = $tftp_file_server->get_root_dir() . "/$startup_config_name";

	# Write out the file to the TFTP directory
	open( STARTUP, ">$startup_config_file" );
	print STARTUP $startup_file->get_blob();
	close(STARTUP);

	my $response = $cli_protocol->send_and_wait_for( "copy tftp startup-config " . $tftp_file_server->get_ip_address() . " " . $startup_config_name, $enable_prompt, 120);

	if ( $response =~ /error|failed|incomplete/i )
	{
		$LOGGER->fatal( "TFTP restore of the startup-config failed.\n" . $response );
	}
	unlink($startup_config_file);
}

1;
