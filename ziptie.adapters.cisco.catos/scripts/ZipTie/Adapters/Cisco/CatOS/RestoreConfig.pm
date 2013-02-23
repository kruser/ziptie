package ZipTie::Adapters::Cisco::CatOS::RestoreConfig;

use strict;
use warnings;

use ZipTie::Response;
use ZipTie::TransferProtocolFactory;
use ZipTie::Logger;
use ZipTie::Adapters::Utils qw(escape_filename);

my $LOGGER = ZipTie::Logger::get_logger();
my $configFile;

sub restore_via_tftp
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;

	my @responses = ();
	push( @responses, ZipTie::Response->new( 'address or name of remote', \&_send_tftp_ip ) );
	push( @responses, ZipTie::Response->new( 'File system in use',        undef, $DEVICE_MEMORY_ERROR ) );

	$cliProtocol->send("copy tftp flash");
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

sub _send_tftp_ip
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	my $tftpFileServer = $connectionPath->get_file_server_by_name("TFTP");
	my $configName     = escape_filename ( $cliProtocol->get_ip_address() ) . ".config";
	$configFile = $tftpFileServer->get_root_dir() . "/$configName";

	# Write out the file to the TFTP directory
	open( STARTUP, ">$configFile" );
	print STARTUP $promoteFile->get_blob();
	close(STARTUP);

	$cliProtocol->send_and_wait_for( $tftpFileServer->get_ip_address(), 'Name of file' );

	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Flash device', \&_send_bootflash ) );
	push( @responses, ZipTie::Response->new( 'is unrecognized|TFTP connection fail', undef, $TFTP_ERROR ) );
	$cliProtocol->send( $configName, $promptRegex );
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

sub _send_bootflash
{
	my ( $connectionPath, $cliProtocol, $promoteFile, $promptRegex ) = @_;
	$cliProtocol->send_and_wait_for( 'bootflash',        'Name of file to copy' );
	$cliProtocol->send_and_wait_for( 'ziptieconfig.cfg', 'proceed|Overwrite auto-config' );
	_send_yes( $cliProtocol, $promptRegex );
}

sub _send_yes
{
	my ( $cliProtocol, $promptRegex ) = @_;

	my @responses = ();
	push( @responses, ZipTie::Response->new( 'proceed \(y\/n\)',                                                            \&_send_yes ) );
	push( @responses, ZipTie::Response->new( $promptRegex,                                                                  \&_squeeze ) );
	push( @responses, ZipTie::Response->new( 'too many recursions|No response from host|File not found|File system in use', undef, $TFTP_ERROR ) );
	push( @responses, ZipTie::Response->new( 'memory invalid',                                                              undef, $DEVICE_MEMORY_ERROR ) );
	$cliProtocol->send('y');
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $cliProtocol, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _squeeze
{
	my ( $cliProtocol, $promptRegex ) = @_;
	unlink($configFile);

	my $response = $cliProtocol->send_and_wait_for( 'squeeze bootflash:', "proceed|$promptRegex", 180 );
	if ( $response =~ /proceed/i )
	{
		my $squeezeResponse = $cliProtocol->send_and_wait_for( 'y', "proceed|$promptRegex", 180 );
		if ( $squeezeResponse =~ /proceed/i )
		{
			$cliProtocol->send_and_wait_for( 'y', $promptRegex, 180 );
		}
	}
	_make_config_live( $cliProtocol, $promptRegex );
}

sub _make_config_live
{
	my ( $cliProtocol, $promptRegex ) = @_;
	my @responses = ();
	push( @responses, ZipTie::Response->new( 'CONFIG_FILE|Unknown', \&_copy_config ) );
	push( @responses, ZipTie::Response->new( 'invalid config|not a valid',   undef, $DEVICE_MEMORY_ERROR ) );    

	$cliProtocol->send('set boot auto-config bootflash:ziptieconfig.cfg');
	my $response = $cliProtocol->wait_for_responses( \@responses );
	if ($response)
	{
		my $nextMethod = $response->get_next_interaction();
		return &$nextMethod( $cliProtocol, $promptRegex );
	}
	else
	{
		$LOGGER->fatal("Invalid response from device encountered!");
	}
}

sub _copy_config
{
	my ( $cliProtocol, $promptRegex ) = @_;
	my $response = $cliProtocol->send_and_wait_for('copy ziptieconfig.cfg config', "Configure using bootfla|$promptRegex", 120);
	if ($response =~ /Configure using bootfla/)
	{
		$cliProtocol->send_and_wait_for('y', $promptRegex, 120);
	}
}

1;
