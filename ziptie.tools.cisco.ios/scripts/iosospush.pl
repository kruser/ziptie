#!/usr/bin/perl
use strict;
use Getopt::Long;
use MIME::Base64 'decode_base64';

use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Cisco::IOS::AutoLogin;
use ZipTie::ConnectionPath;
use ZipTie::Logger;
use ZipTie::Typer;
use ZipTie::SafeCopy;

# Redirect warnings to the Logger so they don't pollute Tool output
my $LOGGER = ZipTie::Logger::get_logger();
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ( $connectionPathXml, $imageFile, $filestore, $flash, $flashDirectory, $flashPartition, $deleteExisting, $changeBoot, $reboot, $dramRequired );
GetOptions(
	"connectionPath=s" => \$connectionPathXml,    
	"file=s"           => \$imageFile,
	"filestore=s"      => \$filestore,
	"flash=s"          => \$flash,
	"flashDirectory:s" => \$flashDirectory,
	"flashPartition:s" => \$flashPartition,
	"deleteExisting:s" => \$deleteExisting,
	"boot:s"           => \$changeBoot,
	"reboot:s"         => \$reboot,
	"dramRequired:s"   => \$dramRequired,
);

$deleteExisting = ($deleteExisting =~ /true/i) ? 1 : 0;
$changeBoot = ($changeBoot =~ /true/i) ? 1 : 0;
$reboot = ($reboot =~ /true/i) ? 1 : 0;

my ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXml, 'connectionPath' );
my $device = $connectionPath->get_ip_address();

# Perform the logic in an eval statement to catch any errors
my ( $shortFileName, $tftpServer, $fullResponse );
eval {
	
	my $fullFilePath = $filestore . '/' . $imageFile;
	my $tftpProtocol = $connectionPath->get_protocol_by_name("TFTP");
	if ( !defined($tftpProtocol) )
	{
		$LOGGER->fatal("Unable to push OS to $device without TFTP enabled.");
	}
	$tftpServer = $connectionPath->get_file_server_by_name("TFTP");
	($shortFileName) = $imageFile =~ /^.*[\/\\](\S+)$/;
	ZipTie::SafeCopy::safe_copy( $fullFilePath, $tftpServer->get_root_dir() . '/' . $shortFileName );
	my $tftpServerAddress = $tftpServer->get_ip_address();

	# Parse the backup operation XML document and extract a ZipTie::ConnectionPath object from it
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $prompt      = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );

	if ( $flashPartition eq 'none' )
	{
		$flashPartition = '';
	}
	if ($flashDirectory)
	{
		$flashDirectory =~ s/^\/*((\S+\/*)+)$/\1/g;
		$flashDirectory =~ s/(\S+\/*)+\/$/\1/g;
		if ( $flashDirectory eq '/' )
		{
			$flashDirectory = '';
		}
	}
	my $partitionsExist = check_for_partitions( $cliProtocol, $flash );
	if ( $partitionsExist && !$flash )
	{
		$LOGGER->fatal( "$flash is a partitioned device, but a partition wasn't specified, " . "-OR- an incorrect destination device was specified." );
	}
	my $enoughFlash = enough_flash_available( $cliProtocol, $flash, $fullFilePath, $flashDirectory, $shortFileName, $flashPartition );
	my $enoughMemory = enough_dram( $cliProtocol, $dramRequired );
	if ( $enoughFlash && $enoughMemory )
	{
		if ($deleteExisting)
		{
			delete_existing_image( $cliProtocol, $flash, $flashDirectory, $shortFileName, $flashPartition );
		}

		download_software_image( $cliProtocol, $flash, $flashDirectory, $shortFileName, $tftpServerAddress, $flashPartition );

		my $goodImageOnFlash = verify_new_image_on_flash( $cliProtocol, $flash, $flashDirectory, $shortFileName, $fullFilePath, $flashPartition );
		if ( !$goodImageOnFlash )
		{
			$LOGGER->fatal("Unable to verify the new image on $flash.\n\n$fullResponse");
		}
		if ($changeBoot)
		{
			change_system_boot_parameters( $cliProtocol, $flash, $flashDirectory, $shortFileName, $flashPartition );
		}
		if ($reboot)
		{
			reboot($cliProtocol);
		}
	}
	else
	{
		my $failString = "";
		if ( !$enoughFlash )
		{
			$failString .= "Not enough space on device [$flash]";
		}
		if ( $enoughMemory + $enoughFlash == 0 )
		{
			$failString .= " -AND- ";
		}
		if ( !$enoughMemory )
		{
			$failString .= "Not enough DRAM";
		}
		$LOGGER->fatal( '', $failString );
	}
	$cliProtocol->send('exit');
	$cliProtocol->disconnect();

	print "OK,$device\n\n";
	print $fullResponse;
};    # end eval block

# If an error occurred, exit with an error
if ($@)
{
	print "ERROR,$device\n";
	print "\n";
	print "$@";
}
ZipTie::SafeCopy::safe_delete( $tftpServer->get_root_dir() . '/' . $shortFileName );

sub download_software_image
{
	my ( $cliProtocol, $imageDestination, $flashDirectory, $filenameOnTftpServer, $tftpServerAddress, $flashPartition ) = @_;
	my $flashPartitionColon;
	my $response;
	$cliProtocol->set_timeout(3600);
	if ($flashPartition)
	{
		$flashPartitionColon = $flashPartition . ':';
	}
	if ($flashDirectory)
	{
		my @path = split( '\/', $flashDirectory );
		my $directoryToMake = '';
		foreach (@path)
		{
			$directoryToMake .= "$_/";
			$response = $cliProtocol->send_and_wait_for( "mkdir $imageDestination:$flashPartition$directoryToMake", '(\]\?|#)\s*$' );
			$fullResponse .= $response;
			if ( $response =~ /invalid\s+input/mi )
			{
				$LOGGER->fatal( '', "Device or IOS version doesn't support sub-directories" );
			}
			$fullResponse .= $cliProtocol->send_and_wait_for( '', '#\s*$' );
		}
		$flashDirectory = "$flashDirectory/";
	}
	$fullResponse .=
	  $cliProtocol->send_and_wait_for(
		"copy tftp://$tftpServerAddress/$filenameOnTftpServer $imageDestination:$flashPartitionColon$flashDirectory$filenameOnTftpServer", '\]\?\s*$' );
	$response = $cliProtocol->send_and_wait_for( "", '(#|confirm\]|\]\?)$' );
	$fullResponse .= $response;
	if ( $response =~ /error\s+opening/i )
	{
		$fullResponse .= $cliProtocol->send_as_bytes_and_wait( '03', '.*' );
		$LOGGER->fatal( '', "Error opening $filenameOnTftpServer on TFTP server." );
	}
	else
	{
		if ( $response =~ /(erase\s+\w+:*(\w+:*)?\s+before\s+copying|over\s+write)/mi )
		{
			if ( $response =~ /erase\s+\w+:*(\w+:*)?\s+before\s+copying/mi )
			{
				$fullResponse .= $cliProtocol->send_as_bytes_and_wait( '6e', '#' );    # 'n'
			}
			elsif ( $response =~ /over\s+write/mi )
			{
				if ($deleteExisting)
				{
					$fullResponse .= $cliProtocol->send_and_wait_for( '', 'confirm\]' );
					my $responseDelete = $cliProtocol->send_as_bytes_and_wait( '6e', '(confirm\]|#)\s*$' );    # 'n'
					$fullResponse .= $responseDelete;
					if ( $responseDelete =~ /confirm\]\s*$/ )
					{
						$fullResponse .= $cliProtocol->send_and_wait_for( '', '#' );
					}
				}
				else
				{
					$cliProtocol->set_timeout(30);
					$fullResponse .= $cliProtocol->send_as_bytes_and_wait( '03', '.*' );
					$LOGGER->fatal( '', "$flashDirectory$filenameOnTftpServer already exists on $imageDestination:$flashPartition." );
				}
			}
		}
	}
	$cliProtocol->set_timeout(30);
}

sub reboot
{
	my ($cliProtocol) = @_;
	$fullResponse .= $cliProtocol->send_and_wait_for( 'reload', '\]' );
	$fullResponse .= $cliProtocol->send_and_wait_for( '',       '.*' );
}

sub change_system_boot_parameters
{
	my ( $cliProtocol, $newImageDestination, $flashDirectory, $filenameOnTftpServer, $flashPartition ) = @_;
	if ($flashPartition)
	{
		$flashPartition .= ':';
	}
	if ( $flashDirectory gt '' )
	{
		$flashDirectory .= '/';
	}
	$cliProtocol->send_and_wait_for( "terminal length 0", '#' );
	my $response = $cliProtocol->send_and_wait_for( "show version", '#' );
	if ( $response =~ /System\s+image\s+file\s+is\s+"([^:]+):((\d):)?([^"]+)"/i )
	{
		my $activeImageDevice    = $1;    # First clear the "boot system" parameter for
		my $activeImagePartition = $3;    # the currently active image...
		my $activeImage          = $4;
		if ($activeImagePartition)
		{
			$activeImagePartition .= ':';
		}
		$fullResponse .= $cliProtocol->send_and_wait_for( "config term",                                                               '#' );
		$fullResponse .= $cliProtocol->send_and_wait_for( "no boot system flash $activeImageDevice:$activeImagePartition$activeImage", '#' );
		$fullResponse .= $cliProtocol->send_and_wait_for( "no boot system $activeImageDevice:$activeImagePartition$activeImage",       '#' );
	}
	$fullResponse .= $cliProtocol->send_as_bytes_and_wait( '1a', '#\s*$' );
	my $responseShowRun = $cliProtocol->send_and_wait_for( "show run", '#\s*$' );    # ...then store other existing "boot system"
	my @lines = split( '\n', $responseShowRun );                                     # parameters, to be appended to new primary
	my @bootSystemParams = ();                                                       # boot system parameter.
	foreach (@lines)
	{
		if ( $_ =~ /^boot\s+system/i )
		{
			push( @bootSystemParams, $_ );
		}
	}
	$fullResponse .= $cliProtocol->send_and_wait_for( 'config term', '#\s*$' );
	foreach (@bootSystemParams)                                                      # Clear remaining existing "boot system" params...
	{
		$fullResponse .= $cliProtocol->send_and_wait_for( "no $_", '#\s*$' );
	}
	my $responseBootSys =
	  $cliProtocol->send_and_wait_for( "boot system flash $newImageDestination:$flashPartition$flashDirectory$filenameOnTftpServer", '#\s*$' );
	$fullResponse .= $responseBootSys;
	if ( $responseBootSys =~ /invalid\s+input/mi )
	{
		$fullResponse .= $cliProtocol->send_and_wait_for( "boot system $newImageDestination:$flashPartition$flashDirectory$filenameOnTftpServer", '#\s*$' );
	}
	foreach (@bootSystemParams)
	{                                                                                # ...then prioritize the new "boot system"
		$fullResponse .= $cliProtocol->send_and_wait_for( $_, '#\s*$' );             # parameter, followed by the stored @bootSystemParams
	}
	$fullResponse .= $cliProtocol->send_and_wait_for( "exit", '#\s*$' );
	$response = $cliProtocol->send_and_wait_for( "write mem", '(#\s*|\])$' );
	$fullResponse .= $response;
	if ( ( $response =~ /\]$/ ) && ( $response !~ /\[OK\]/ ) )
	{
		$fullResponse .= $cliProtocol->send_and_wait_for( '', '#' );
	}
}

sub delete_existing_image
{
	my ( $cliProtocol, $destination, $flashDirectory, $image, $flashPartition ) = @_;
	$cliProtocol->set_timeout(120);
	if ($flashPartition)
	{
		$flashPartition .= ':';
	}
	if ($flashDirectory)
	{
		$flashDirectory .= '/';
	}
	$fullResponse .= $cliProtocol->send_and_wait_for( "terminal length 0", '#' );
	my $response = $cliProtocol->send_and_wait_for( "show version", '#' );
	my $currentVersionFound = 0;
	my ( $activeImageDevice, $activeImagePartition, $activeImage );
	if ( $response =~ /System\s+image\s+file\s+is\s+"([^:]+):((\d):)?([^"]+)"/i )
	{
		$currentVersionFound  = 1;
		$activeImageDevice    = $1;
		$activeImagePartition = $3;
		$activeImage          = $4;
		if ($activeImagePartition)
		{
			$activeImagePartition .= ":";
		}
	}
	elsif ( $response =~ /running\s+default\s+software/i )
	{
		$response = $cliProtocol->send_and_wait_for( 'show bootvar', '#' );
		if ( $response =~ /boot\s+variable\s+=\s+([^:]+):((\d):)?([^,]+),/i )
		{
			$currentVersionFound  = 1;
			$activeImageDevice    = $1;
			$activeImagePartition = $3;
			$activeImage          = $4;
			if ($activeImagePartition)
			{
				$activeImagePartition .= ":";
			}
		}
	}
	if ($currentVersionFound)
	{
		$fullResponse .= $cliProtocol->send_and_wait_for( "delete $activeImageDevice:$activeImagePartition$activeImage", '\]\?\s*$' );
		$fullResponse .= $cliProtocol->send_and_wait_for( $activeImage,                                                  '(\[confirm\]|#)' );
		$fullResponse .= $cliProtocol->send_and_wait_for( '',                                                            '#\s*$' );
	}
	$fullResponse .= $cliProtocol->send_and_wait_for( "delete $destination:$flashPartition$flashDirectory$image", '\]\?\s*$' );
	$fullResponse .= $cliProtocol->send_and_wait_for( $flashDirectory . $image,                                   '(\[confirm\]|#)' );
	$fullResponse .= $cliProtocol->send_and_wait_for( '',                                                         '#\s*$' );
	squeeze( $cliProtocol, $destination, $flashPartition );
	$fullResponse .= $cliProtocol->send_and_wait_for( "", '(\[confirm\]|#)' );
	$fullResponse .= $cliProtocol->send_and_wait_for( "", '#' );
	$cliProtocol->set_timeout(30);
}

sub enough_dram
{
	my ( $cliProtocol, $dramRequired ) = @_;
	if ($dramRequired)
	{
		$cliProtocol->send_and_wait_for( "terminal length 0", '#\s*$' );
		my $response = $cliProtocol->send_and_wait_for( "show version", '#\s*$' );
		if ( $response =~ /with\s+(\d+)K\/(\d+)K\s+bytes\s+of\s+memory/i )
		{
			my $dramInstalled = $1 + $2;
			if ( $dramInstalled > $dramRequired )
			{
				return (1);
			}
			else
			{
				return (0);
			}
		}
		elsif ( $response =~ /with\s+(\d+)K\s+bytes\s+of\s+memory/i )
		{
			my $dramInstalled = $1;
			if ( $dramInstalled > $dramRequired )
			{
				return (1);
			}
			else
			{
				return (0);
			}
		}
	}
	else
	{
		return 1;
	}
}

sub enough_flash_available
{

	#	Check space on destination media; disregard space consumed by by files that are about to be deleted.
	#	This complexity is preferred since it's safer to confirm that there will be enough space for the new image
	#	before deleting an existing image.

	my ( $cliProtocol, $destination, $imageFullPath, $flashDirectory, $filenameOnTftpServer, $flashPartition ) = @_;
	if ($flashPartition)
	{
		$flashPartition .= ":";
	}
	squeeze( $cliProtocol, $destination, $flashPartition );
	my ( $dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $sizeOfTftpImage, $atime, $mtime, $ctime, $blksize, $blocks ) = stat($imageFullPath);
	$cliProtocol->send_and_wait_for( "terminal length 0", '#\s*$' );
	my $response = $cliProtocol->send_and_wait_for( "show version", '#\s*$' );
	my $activeImageDevice;
	my $activeImagePartition;
	my $activeImage;
	my $activeImageDirectory;
	my $bytesToBeDeleted = 0;

	if ( $response =~ /System\s+image\s+file\s+is\s+"([^:]+):((\d):)?([^"]+)"/i )
	{
		$activeImageDevice    = $1;
		$activeImagePartition = $3;
		$activeImage          = $4;
		if ($activeImagePartition)
		{
			$activeImagePartition .= ":";
		}
		if ( $activeImage =~ /(\S+)\/\S+$/ )
		{
			$activeImageDirectory = $1;
		}
	}
	elsif ( $response =~ /running\s+default\s+software/i )
	{
		$response = $cliProtocol->send_and_wait_for( 'show bootvar', '#' );
		if ( $response =~ /boot\s+variable\s+=\s+([^:]+):((\d):)?([^,]+),/i )
		{
			$activeImageDevice    = $1;
			$activeImagePartition = $3;
			$activeImage          = $4;
			if ($activeImagePartition)
			{
				$activeImagePartition .= ":";
			}
			if ( $activeImage =~ /(\S+)\/\S+$/ )
			{
				$activeImageDirectory = $1;
			}
		}

	}
	else
	{
		$LOGGER->fatal('CLI parsing error');
	}
	my $bytesAvailable = 0;
	if ($flashPartition)
	{
		$flashPartition = "$flashPartition";
	}
	$response = $cliProtocol->send_and_wait_for( "dir $destination:$flashPartition", '#\s*$' );
	my $bytesAvailableBeforeDeletion;
	if ( $response =~ /\((\d+)\s+bytes\s+free\)/ )
	{
		$bytesAvailableBeforeDeletion = $1;
	}
	$bytesToBeDeleted += get_bytes_to_be_deleted( $cliProtocol, $destination,       $flashPartition,       $flashDirectory,       $filenameOnTftpServer );
	$bytesToBeDeleted += get_bytes_to_be_deleted( $cliProtocol, $activeImageDevice, $activeImagePartition, $activeImageDirectory, $activeImage );
	$bytesAvailable = $bytesAvailableBeforeDeletion + $bytesToBeDeleted;
	if ( $bytesAvailable >= $sizeOfTftpImage )
	{
		return (1);
	}
	else
	{
		return (0);
	}
}

sub get_bytes_to_be_deleted
{
	my ( $cliProtocol, $device, $partition, $directory, $image ) = @_;
	my $response = $cliProtocol->send_and_wait_for( "dir $device:$partition$directory", '#\s*$' );
	my @lines    = split( '\n',                                                         $response );
	my $retval   = 0;
	my $imageNoDirs = $image;
	if ( $imageNoDirs =~ /\/*([^\/]+)$/ )
	{
		$imageNoDirs = $1;
	}
	foreach (@lines)
	{
		if (
			(
				   $_ =~ /\s+(\d+)\s+\w{3}\s+\d+\s+\d{4}\s+\d\d:\d\d:\d\d\s+([-\+]\d\d:\d\d)*\s+$imageNoDirs\s*$/
				|| $_ =~ /\s+(\d+)\s+<no date>\s+$imageNoDirs\s*$/
			)
		  )
		{
			return ($1);
		}
	}
	return (0);
}

sub verify_new_image_on_flash
{
	my ( $cliProtocol, $imageDestination, $flashDirectory, $filenameOnTftpServer, $imageFullPath, $flashPartition ) = @_;
	my ( $dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $sizeOfImageOnTftpServer, $atime, $mtime, $ctime, $blksize, $blocks ) = stat($imageFullPath);
	if ($flashPartition)
	{
		$flashPartition = "$flashPartition:";
	}
	my $response = $cliProtocol->send_and_wait_for( "dir $imageDestination:$flashPartition$flashDirectory", '#$' );
	$fullResponse .= $response;
	my @lines = split( '\n', $response );
	my $sizeOfImageOnFlash;
	foreach (@lines)
	{
		if (   ( $_ =~ /\s+(\d+)\s+\w{3}\s+\d+\s+\d{4}\s+\d\d:\d\d:\d\d\s+([-\+]\d\d:\d\d)*\s+$filenameOnTftpServer\s*$/ )
			|| ( $_ =~ /\s+(\d+)\s+\w{3}\s+\d+\s+\d{4}\s+\d\d:\d\d:\d\d\s+$filenameOnTftpServer\s*$/ )
			|| ( $_ =~ /\s+(\d+)\s+<no\s+date>\s+$filenameOnTftpServer\s*$/ ) )
		{
			$sizeOfImageOnFlash = $1;
		}
	}
	if ( $sizeOfImageOnTftpServer == $sizeOfImageOnFlash )
	{
		return (1);
	}
	return (0);
}

sub check_for_partitions
{
	my ( $cliProtocol, $destination ) = @_;
	my $response = $cliProtocol->send_and_wait_for( "dir $destination:", '#' );
	return ( $response =~ /invalid/i );
}

sub squeeze
{
	my ( $cliProtocol, $destination, $flashPartition ) = @_;
	$cliProtocol->set_timeout(3600);
	my $response = $cliProtocol->send_and_wait_for( "squeeze $destination:$flashPartition", '(\[confirm\]|#)' );
	$fullResponse .= $response;
	if ( $response =~ /confirm/ )
	{
		$fullResponse .= $cliProtocol->send_and_wait_for( '', '(\[confirm\]|#)' );
		$response = $cliProtocol->send_and_wait_for( '', '(\[confirm\]|#)' );
		$fullResponse .= $response;
	}

	if ( $response =~ /Squeeze operation may take a while/ )
	{
		$fullResponse .= $cliProtocol->send_and_wait_for( '', '(\[confirm\]|#)' );
		$fullResponse .= $cliProtocol->send_and_wait_for( '', '(\[confirm\]|#)' );
	}
	$cliProtocol->set_timeout(30);
}
