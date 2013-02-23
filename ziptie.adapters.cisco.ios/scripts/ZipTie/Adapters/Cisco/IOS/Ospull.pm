package ZipTie::Adapters::Cisco::IOS::Ospull;

use strict;
use warnings;

use File::Copy;
use File::Path;

use ZipTie::Adapters::Utils qw(create_empty_file escape_filename);
use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Cisco::IOS::AutoLogin;
use ZipTie::Model::XmlPrint;

my $LOGGER = ZipTie::Logger::get_logger();

sub invoke
{
	my $pkg            = shift;
	my $ospullDocument = shift;

	# Initial connection
	my ( $connectionPath, $filestore ) = ZipTie::Typer::translate_document( $ospullDocument, 'connectionPath' );
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $promptRegex = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	$cliProtocol->send_and_wait_for( 'terminal length 0', $promptRegex );

	#  Create the output document
#	my $filehandle = ZipTie::Adapters::Utils::_get_output_filehandle( 'IOS', $cliProtocol->get_ip_address(), '_ospull.xml' );
#	my $printer = ZipTie::Model::XmlPrint->new($filehandle);
#	$printer->open_element('ospullFiles');

	# Pull and organize the primary image file
	my $imageName = _find_image( $cliProtocol, $promptRegex );
	if ( defined $imageName )
	{
		$imageName =~ s/"//g;
		$imageName =~ s/,//g;
		my $shortName = _get_short_name($imageName);
		my $file = { name => $shortName, };
		if ( _already_stored( $shortName, $filestore ) )
		{
			$LOGGER->debug("The file $shortName already exists");
			$file->{status} = "Exists";
		}
		else
		{
			my $fileOnTftpServer = _transfer_image( $cliProtocol, $promptRegex, $connectionPath, $imageName );
			my $finalFolder = $filestore->get_path . '/' . _get_folder_name($shortName);
			if (!-e $finalFolder)
			{
				mkpath($finalFolder);
			}
			my $finalPath = $finalFolder . '/' . $shortName;
			$LOGGER->debug("Moving $fileOnTftpServer to $finalPath");
			move( $fileOnTftpServer, $finalPath );    
			$file->{status} = "Success";
		}
#		$printer->print_element( 'file', $file );
		$cliProtocol->send('exit');
	}
	else
	{
		$LOGGER->fatal("No image file found");
	}
#	$printer->close_element('ospullFiles');
}

sub _find_image
{
	my ( $cliProtocol, $prompt, ) = @_;
	my $version = $cliProtocol->send_and_wait_for( 'show version', $prompt );
	if ( $version =~ /system image file is (\S+)/i )
	{
		return $1;
	}
	else
	{
		return undef;
	}
}

sub _transfer_image
{
	my ( $cliProtocol, $prompt, $connectionPath, $imageName ) = @_;
	my $tftpProtocol = $connectionPath->get_protocol_by_name("TFTP") if ( defined($connectionPath) );
	my ($imageNameOnly) = _get_short_name($imageName);
	my $localFilename = $imageNameOnly . '-' . escape_filename ( $cliProtocol->get_ip_address() );
	my $copyResponse;

	# Check to see if TFTP is supported.  If so, a combination of a CLI Protocol AND TFTP will be used
	# to retrieve the startup configuration
	if ( defined($tftpProtocol) )
	{
		my $tftpServer = $connectionPath->get_file_server_by_name("TFTP");
		$LOGGER->debug("Attempting to transfer $imageName");
		my $fileOnTftpServer = $tftpServer->get_root_dir() . "/" . $localFilename;
		create_empty_file($fileOnTftpServer);
		$cliProtocol->send( 'copy ' . $imageName . ' tftp');
		$copyResponse = $cliProtocol->wait_for( '.+\]', 30 );
		if ($copyResponse =~ /remote host/i)
		{
			$cliProtocol->send_and_wait_for( $tftpServer->get_ip_address(), 'filename.+?' );
			my $response = $cliProtocol->send_and_wait_for( $localFilename, '(?i)' . $prompt . '|Error|Invalid|Timeout', 600 );
			if ( $response =~ /Error|Invalid|Timeout/i )
			{
				$LOGGER->fatal_error_code( $TFTP_ERROR, "unable to transfer $imageName from ".$cliProtocol->get_ip_address().": " . $response );
			}
			return $fileOnTftpServer;			
		}
		elsif ($copyResponse =~ /destination/i)
		{
			$cliProtocol->send_and_wait_for( $localFilename, 'remote host', 120 );
			my $response = $cliProtocol->send_and_wait_for( $tftpServer->get_ip_address(), '(?i)' . $prompt . '|Error|Invalid|Timeout', 600 );
			if ( $response =~ /Error|Invalid|Timeout/i )
			{
				$LOGGER->fatal_error_code( $TFTP_ERROR, "unable to transfer $imageName from ".$cliProtocol->get_ip_address().": " . $response );
			}
			return $fileOnTftpServer;
		}
		else
		{
			$LOGGER->fatal("Unexpected response: '$copyResponse'");
		}
	}	
	else
	{
		$LOGGER->fatal("This ospull operation does not work without a TFTP server");
	}

}

sub _already_stored
{

	# return 1 if this image already exists on the filestore
	my ( $imageFile, $filestore ) = @_;
	my $folder = _get_folder_name($imageFile);
	return ( -e $filestore->get_path() . '/' . $folder . '/' . $imageFile );
}

sub _get_folder_name
{

	# get the name of the folder inside of the home directory
	my $imageFile = shift;
	my ($subFolder) = $imageFile =~ /^(\w+)/;
	return 'Cisco/' . $subFolder;
}

sub _get_short_name
{
	my $imageFilename = shift;
	my ($imageNameOnly) = $imageFilename =~ /:([^:]+)$/;
	return $imageNameOnly;
}
1;
