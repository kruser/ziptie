package ZipTie::Adapters::Cisco::SecurityAppliance::Restore;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::ConnectionPath;
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(escape_filename);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

sub execute
{
	my ( $connection_path, $cli_protocol, $enable_prompt_regex, $restoreFile ) = @_;

	# Check to see if either TFTP or SCP are supported
	my $tftp_protocol = $connection_path->get_protocol_by_name("TFTP") if ( defined($connection_path) );
	if ( defined($tftp_protocol) )
	{
		my $showVer = $cli_protocol->send_and_wait_for( 'show version', $enable_prompt_regex );
		if ($showVer =~ /(Adaptive\s+Security\s+Appliance|ASA)/)
		{
			_asa_restore( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
		}
		elsif ($showVer =~ /FWSM/i)
		{
			_fwsm_restore( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
		}
		else
		{
			_pix_restore( $connection_path, $cli_protocol, $restoreFile, $enable_prompt_regex );
		}
	}
	else
	{
		$LOGGER->fatal("Unable to restore SecurityAppliance config.  Protocol TFTP is not available.");
	}
}

sub _pix_restore
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $configName     = escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile     = $tftpFileServer->get_root_dir() . "/$configName";
	
	my $blob = $promoteFile->get_blob();
	$promoteFile = undef;
	$blob =~ s/isakmp\s+key\s+\*+.*//m;
	
	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $blob;
	close(CONFIG_FILE);
	$blob = undef;
	
	# first blow away everything in the running config except connectivity data 
	my $configPrompt = '(config)#\s*$';
	$cliProtocol->send_and_wait_for('configure terminal', $configPrompt);
	$cliProtocol->send_and_wait_for('no banner motd', $configPrompt);
	$cliProtocol->send_and_wait_for('no banner exec', $configPrompt);
	$cliProtocol->send_and_wait_for('no banner login', $configPrompt);
	$cliProtocol->send_and_wait_for('clear configure secondary', $configPrompt);
	
	# now merge the startup config that we are promoting into the running config
	my $tftpAddress = $tftpFileServer->get_ip_address();
	$tftpAddress = '['.$tftpAddress.']' if $tftpAddress =~ /:/;  # IPv6 must be in square brackets
	my $response = $cliProtocol->send_and_wait_for('configure net '.$tftpAddress.':'.$configName, $configPrompt, 120);
	unlink $configFile;
	if ($response =~ /failed|error/i)
	{
		$LOGGER->fatal_error_code($TFTP_ERROR, $cliProtocol->get_ip_address(), $response);
	}
	
	# write running to startup
	$cliProtocol->send_and_wait_for('write mem', $configPrompt);
	$cliProtocol->send_and_wait_for('exit', $promptRegex);
}

sub _fwsm_restore
{
	# first changeto system context and then run the promote just like it was an ASA.
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $systemPrompt = '\S+#\s*$';
	$cliProtocol->send_and_wait_for('changeto system', $systemPrompt);
	_asa_restore( $connectionPath, $cliProtocol, $promoteFile, $systemPrompt );
}

sub _asa_restore
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Ee]rror|[Ff]ail|Invalid input', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( 'Address or name of remote host', \&_send_tftp_address ) );
	push( @responses, ZipTie::Response->new( 'Source filename',                \&_send_source_filename ) );
	push( @responses, ZipTie::Response->new('\d+ bytes copied in \S+ secs') );

	$cliProtocol->send( "copy tftp: startup-config" );
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_tftp_address
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $tftpServerIP   = $tftpFileServer->get_ip_address();

	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Ee]rror|[Ff]ail|Address or name of remote host', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( 'Source filename', \&_send_source_filename ) );
	push( @responses, ZipTie::Response->new('\d+ bytes copied in \S+ secs') );

	$cliProtocol->send("$tftpServerIP");
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _send_source_filename
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $configName     = escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile     = $tftpFileServer->get_root_dir() . "/$configName";

	my @responses = ();
	push( @responses, ZipTie::Response->new( '[Ee]rror|[Ff]ail|Address or name of remote host|Source filename', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( '\d+ bytes copied in \S+ secs', \&_finish ) );

	# Write out the file to the TFTP directory
	open( CONFIG_FILE, ">$configFile" );
	print CONFIG_FILE $promoteFile->get_blob();
	close(CONFIG_FILE);

	$cliProtocol->send("$configName");
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $connectionPath, $cliProtocol, $promoteFile, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _finish
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $configName     = escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	my $configFile     = $tftpFileServer->get_root_dir() . "/$configName";
	unlink($configFile);

	return 0;
}

1;
