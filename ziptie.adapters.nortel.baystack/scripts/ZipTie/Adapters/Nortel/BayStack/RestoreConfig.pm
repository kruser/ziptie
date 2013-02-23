package ZipTie::Adapters::Nortel::BayStack::RestoreConfig;

use strict;
use warnings;

use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(escape_filename);

my $LOGGER = ZipTie::Logger::get_logger();

sub restore_via_tftp
{

	# restore the config via TFTP
	my $connectionPath = shift;
	my $cliProtocol    = shift;
	my $restoreFile    = shift;
	my $promptRegex    = shift;

	# make a name for the temp
	my $tftpFileServer  = $connectionPath->get_file_server_by_name("TFTP");
	my $restoreFilename = escape_filename($cliProtocol->get_ip_address() . ".restore");
	my $fullFilename    = $tftpFileServer->get_root_dir() . "/$restoreFilename";

	# Write out the file to the TFTP directory
	open( CONFIG, ">$fullFilename" );
	binmode(CONFIG);
	print CONFIG $restoreFile->get_blob();
	close(CONFIG);

	if ($promptRegex)
	{

		# CLI
		_cli_based_xfer( $cliProtocol, $restoreFilename, $tftpFileServer->get_ip_address() );
	}
	else
	{

		# Menu
		_menu_based_xfer( $cliProtocol, $restoreFilename, $tftpFileServer->get_ip_address() );
	}
	_ping_until_alive($cliProtocol);
	unlink($fullFilename);
}

sub _menu_based_xfer
{
	my $cliProtocol  = shift;
	my $filename     = shift;
	my $tftpServerIp = shift;

	my $response = $cliProtocol->send_as_bytes_and_wait( '67', 'Configuration File Menu|onfiguration File Download\/Upload' );    # g
	if ( $response =~ /Configuration File Menu/ )
	{
		$cliProtocol->send_as_bytes_and_wait( '63', 'onfiguration File Download\/Upload' );                                       # 'c'
	}
	$cliProtocol->send($filename);
	$cliProtocol->get_response(1);
	$cliProtocol->send_as_bytes_and_wait( '1b5b42', 'Enter' );                                                                    # down arrow
	$cliProtocol->send($tftpServerIp);
	$cliProtocol->get_response(1);
	$response = $cliProtocol->send_as_bytes_and_wait( '1b5b421b5b42', '\[\s*(Yes|No)\s*\]' );                                     # two down arrows
	if ( $response =~ /\[\s*No\s*\]/i )
	{
		$cliProtocol->send_as_bytes_and_wait( '20', '\[\s*Yes\s*\]' );                                                            # space bar, toggle the yes/no
	}

	my $errorRegex =
	  "Error accessing configuration file|host not found or not responding|Data rejected|Operation aborted|Previous operation is currently in progress";
	$response = $cliProtocol->send_and_wait_for( '', 'Performing reconfiguration|' . $errorRegex, 120 );                          # confirm with an enter;
	if ( $response =~ /($errorRegex)/ )
	{
		$LOGGER->fatal("[$TFTP_ERROR] $1.");
	}
}

sub _cli_based_xfer
{
	my $cliProtocol  = shift;
	my $filename     = shift;
	my $tftpServerIp = shift;

	# issue the 'logout' command to return to the menu system.  Promoting the 'config' from
	# the CLI causes the BayStack switch to lose its passwords.
	my $response = $cliProtocol->send_and_wait_for( 'logout', 'nvalid|arrow keys' );
	if ( $response =~ /arrow keys/ )
	{
		$cliProtocol->turn_vt102_on( 150, 25 );
		_menu_based_xfer( $cliProtocol, $filename, $tftpServerIp );
		$cliProtocol->send_as_bytes('63');    # 'c', back to the CLI
		$cliProtocol->turn_vt102_off();
	}
	else
	{
		$LOGGER->fatal("[$TFTP_ERROR] This BayStack operating system does not support the clean restoration of the binary config.");
	}
}

sub _ping_until_alive
{
	my $cliProtocol = shift;

	sleep(30);    # initially wait 30 seconds for the reset to start
	my $maxWait = 90;                               # in seconds
	my $host    = $cliProtocol->get_ip_address();
	my $start = time();
	
	# Use the Net::Ping module
	use Net::Ping;
	
	my $pinger = Net::Ping->new();
	while ( time() - $start < $maxWait )
	{
		if ( $pinger->ping($host) )
		{
			$LOGGER->debug("$host is alive.");
			last;
		}
		else
		{
			$LOGGER->debug("$host not yet responding.");
			sleep(5);
		}
	}
	$pinger->close();
}

1;
