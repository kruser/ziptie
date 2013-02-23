package ZipTie::Adapters::Nortel::Contivity::GetConfig;

use strict;

use ZipTie::CLIProtocol;
use ZipTie::Response;
use ZipTie::Recording;
use ZipTie::Recording::Interaction;
use ZipTie::TransferProtocolFactory;
use ZipTie::TransferProtocol;
use ZipTie::ConnectionPath;
use ZipTie::ConnectionPath::Protocol;
use ZipTie::ConnectionPath::FileServer;
use ZipTie::Logger;
use ZipTie::FTP;
use ZipTie::Adapters::Utils qw(escape_filename);

use Exporter 'import';
our @EXPORT_OK = qw(get_config);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_config
{

	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $cli_protocol    = shift;
	my $connection_path = shift;
	#my $filepath		= shift;

	# Create an undef reference that can eventually hold the configuration contents that are found
	my $response = undef;
	my $ftpProtocol = $connection_path->get_protocol_by_name("FTP") if ( defined($connection_path) );

	if (defined $ftpProtocol)
	{
		$response = get_ftp_config( $cli_protocol, $connection_path );
		return $response;
	}
	else
	{
		$LOGGER->fatal("Unable to backup without FTP.");
	}
}

sub get_cli_config
{
	# Grab our ZipTie::CLIProtocol object
	my $cli_protocol	= shift;
	
	# Sending "show config all" command
	my $command = "show running-config";
	$cli_protocol->send( $command );
	
	# Fall back to matching '#'
	my $regex = '(#|\$)\s*$';
	my $response = $cli_protocol->wait_for($regex);

	# remove the prompt
	$response =~ s/^(#|\$)\s*$//;

	# remove show command
	$response =~ s/^show running-configs*//;

	# Return the configuration found
	return $response;
}

sub get_files_to_backup
{
	my $cli_protocol    = shift;
	my $connection_path = shift;

	my $prompt_regex	= '(#|\$)\s*$';
	my $response		= $cli_protocol->send_and_wait_for( "show current-config-file", $prompt_regex );
	my $files_list;
	if ( $response =~ /\s+(\/\S+)/mi )
	{
		push @{$files_list}, $1;
	}
	$response			= $cli_protocol->send_and_wait_for( "dir /ide0/system/slapd/db/", $prompt_regex );
	while ( $response =~ /^\s*\d+\s+\S+\s+\S+\s+\d+\s+\d+:\d+:\d+\s+\d+\s+(\S+)\s*$/mig )
	{
		push @{$files_list}, '/system/slapd/db/'.$1;
	}

	return $files_list;
}

sub get_ftp_config
{
	my $cli_protocol    = shift;
	my $connection_path = shift;
	
	# Grab the ZipTie::ConnectionPath::Protocol object representing SCP from the ZipTie::ConnectionPath object
	my $ftpProtocol = $connection_path->get_protocol_by_name("FTP");

	# Retrieve the configuration file from the device
	my $ftpClient = ZipTie::TransferProtocolFactory::create( $connection_path );
	$ftpClient->connect(	$connection_path->get_ip_address(),
							$ftpClient->get_port(),
							$connection_path->get_credential_by_name("username"),
							$connection_path->get_credential_by_name("password"),
							0,
	 );

	my $files_list = get_files_to_backup( $cli_protocol, $connection_path );
	foreach (@{$files_list})
	{
		my ($filename) = /.+\/([^\s\/]+)$/i;
		if ( $filename !~ /^\s*$/ )
		{
			$filename = $cli_protocol->get_ip_address().".$filename";
			$ftpClient->get( $_, $filename );
		}
		else
		{
			$LOGGER->fatal("Invalid response from device encountered!");
		}
	}
	$ftpClient->disconnect();

	return _finish($files_list,$cli_protocol->get_ip_address());
}

sub _finish
{

	# Grab our ZipTie::CLIProtocol and optional ZipTie::ConnectionPath
	my $files_list	= shift;
	my $server_ip	= shift;

	# Open up the binary configuration file and read it into memory
	my $config_contents;
	my $old_filepath = "";
	my $hash_sk		 = "";
	foreach (@{$files_list})
	{
		my ($filepath,$filename)	= /(.+\/)([^\s\/]+)$/i;
		if ( $filepath ne $old_filepath )
		{
			$old_filepath = $filepath;
			$hash_sk	  = "";
			foreach (split ( /\//, $filepath ))
			{
				$hash_sk .= '->{\''.$_.'\'}' if ( $_ !~ /^\s*$/ );
			}
		}
		
		my $temp_filename = escape_filename("$server_ip.$filename");
		
		open( CONFIG, $temp_filename ) || $LOGGER->fatal("Error: Could not open $temp_filename");
		binmode(CONFIG);
		my $tmp_content	= '';
		eval('$config_contents'.$hash_sk.'->{\''.$filename.'\'} = \'\';');
		while ( read( CONFIG, $b, 1 ) )
		{
			eval('$config_contents'.$hash_sk.'->{\''.$filename.'\'} .= $b;');
			$tmp_content .= $b;
		}
		close(CONFIG);

		# Clean up our tracks by deleteing the configuration file that was sent to the TFTP server
		unlink($temp_filename);

		# Record the file transfer of the config
    	# Arguments: protocol name, file name, response/contents, whether or not ZipTie acted as the file transfer server
    	$RECORDING->create_xfer_interaction("FTP", $_, $tmp_content, 0);
	}

	# Return the contents of the running configuration
	return $config_contents;
}

1;
