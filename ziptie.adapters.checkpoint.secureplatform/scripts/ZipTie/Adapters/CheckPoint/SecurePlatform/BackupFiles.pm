package ZipTie::Adapters::CheckPoint::SecurePlatform::BackupFiles;

use strict;

use ZipTie::Adapters::Utils qw(create_empty_file escape_filename);
use ZipTie::Logger;
use File::Temp;

use Exporter 'import';
our @EXPORT_OK = qw(get_file);

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();

# Get the instance of the ZipTie::Recording module
my $RECORDING = ZipTie::Recording::get_recording();

sub get_file
{
	my ( $filename, $cliProtocol, $connectionPath, $promptRegex ) = @_;

	my $tftpServer = $connectionPath->get_file_server_by_name("TFTP");
	if ( defined $tftpServer )
	{
		my $prefix     = escape_filename( $cliProtocol->get_ip_address().'-' );
		my $tftpFolder = $tftpServer->get_root_dir();
		my $fullFile   = File::Temp::tempnam( $tftpFolder, $prefix );
		my $shortFile  = $fullFile;
		$shortFile =~ s/^.+[\\\/]//;
		create_empty_file($fullFile);

		$cliProtocol->send_and_wait_for( 'tftp ' . $tftpServer->get_ip_address(), 'tftp>' );
		my $tftpResponse = $cliProtocol->send_and_wait_for( 'put ' . $filename .' '.$shortFile, 'tftp>', 180 );
		$cliProtocol->send_and_wait_for( 'quit', $promptRegex );
		if ($tftpResponse =~ /timed out/i)
		{
			$LOGGER->fatal_error_code($TFTP_ERROR);
		}
		return $fullFile;
	}
	else
	{
		$LOGGER->fatal_error_code($TFTP_ERROR);
	}
}

1;
