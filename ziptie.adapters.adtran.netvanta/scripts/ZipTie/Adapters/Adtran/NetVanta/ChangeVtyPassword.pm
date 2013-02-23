package ZipTie::Adapters::Adtran::NetVanta::ChangeVtyPassword;

use strict;
use warnings;

use ZipTie::Adapters::Adtran::NetVanta::AutoLogin;
use ZipTie::Adapters::Utils qw(mask_to_bits);
use ZipTie::CLIProtocolFactory;
use ZipTie::Logger;
use ZipTie::Typer;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $syslogDocument = shift;

	# Initial connection
	my ( $connectionPath, $newPassword ) = ZipTie::Typer::translate_document( $syslogDocument, 'connectionPath' );

	my $cliProtocol		= ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex		= ZipTie::Adapters::Adtran::NetVanta::AutoLogin::execute( $cliProtocol, $connectionPath );
	my $response		= $cliProtocol->send_and_wait_for( "terminal length 0", $promptRegex );
	if ( $response =~ /Unrecognized command/mi )
	{
		# set the --more-- prompt if the term length 0 didn't go through
		$cliProtocol->set_more_prompt( '--MORE--', '20' );
	}
	my $configPrompt	= '#\s*$';
	my $rconfig			= $cliProtocol->send_and_wait_for( 'show running-config', $promptRegex );
	$response			.= $cliProtocol->send_and_wait_for( 'configure terminal', $configPrompt );

	if ( $newPassword =~ /^\S+$/i )
	{
		# grab vty config
		my ( $vty_config ) = $rconfig =~ /^(line\s+telnet\s+\d+\s+\d+.+?)!/mis;
		if ( $vty_config )
		{
			# reprint all the vty config but password line
			while ( $vty_config =~ /^(.+)$/mg )
			{
				$_ = $1;
				if ( $_ !~ /^\s*password/i )
				{
					$response .= $cliProtocol->send_and_wait_for( "$_", $configPrompt );
				}
				else
				{
					$response .= $cliProtocol->send_and_wait_for( "password \"$newPassword\"", $configPrompt );
				}
			}
			$response .= $cliProtocol->send_and_wait_for( "exit", $configPrompt );
		}
		else
		{
			$response .= $cliProtocol->send_and_wait_for( "line telnet 0 4", $configPrompt );
			$response .= $cliProtocol->send_and_wait_for( "password \"$newPassword\"", $configPrompt );
			$response .= $cliProtocol->send_and_wait_for( "exit", $configPrompt );
		}
	}
	$response .= $cliProtocol->send_and_wait_for( "exit", $promptRegex );
	$response .= $cliProtocol->send_and_wait_for( "write memory", $promptRegex );

	_disconnect($cliProtocol);

	return $response;
}

sub _disconnect
{
	# Grab the ZipTie::CLIProtocol object passed in
	my $cli_protocol = shift;

	# Close this session and exit
	$cli_protocol->send("exit");
}

1;
