package ZipTie::Adapters::GenericAdapter;

use strict;
use warnings;

use File::Temp;
use MIME::Base64 'encode_base64';
use Switch;
use ZipTie::Adapters::Utils qw(mask_to_bits get_cli_commands_filehandle close_model_filehandle get_crep);
use ZipTie::Logger;
use ZipTie::Model::XmlPrint;
use ZipTie::TransferProtocolFactory;

my $LOGGER = ZipTie::Logger::get_logger();

sub execute_cli_commands
{
	my $adapter     = shift;
	my $cliProtocol = shift;
	my $commands    = shift;
	my $promptRegex = shift;
	my $printStdout = ($commands->{printStdout} =~ /false/i) ? 0 : 1;
	my $filehandle  = get_cli_commands_filehandle( $adapter, $cliProtocol->get_ip_address() );
	my $printer     = ZipTie::Model::XmlPrint->new($filehandle);
	$printer->open_element('ZiptieDeviceCommmandDetails') if $printStdout;
	my @commandArray = @{ $commands->{commandData} };
	my $length       = @commandArray;
	
	my $results;

	for ( my $i = 0 ; $i < $length ; $i++ )
	{
		my $command        = $commandArray[$i];
		my $timestamp      = time;
		my $commandDetails = {
			command   => $command->{command},
			timestamp => $timestamp,
		};
		
		my $tempPrompt = $promptRegex;
		
		# Initialize the response
		my $response = "";
		
		# Special case: If the last command is an exit command, don't bother waiting for anything
		if ( ( $i == $length - 1 ) && ( $commandDetails->{command} =~ /^\s*(exit|logout|quit|q)\s*$/i ) )
		{
            $cliProtocol->send( $command->{command} );
		}
		
		# Otherwise, send and wait for the prompt as one would expect
		else
		{
			# Override the prompt if specified
			if ( $command->{promptOverride} )
			{
				$tempPrompt = $command->{promptOverride};
			}
			
			# Send and wait for the response of the command
			$response = $cliProtocol->send_and_wait_for( $command->{command}, $tempPrompt, 180 );
			
			# TODO: Don't blindly strip the command that was sent from the response.  If you are in a configure mode and
			# issuing configuration commands, you will most likely want to see the echo of which commands you sent
	        #$response =~ s/^$command->{command}//;
	        
	        $response =~ s/$promptRegex// if ( $command->{stripPrompt} eq 'true' );    # remove the prompt at the end if told to
		
		    # If the CLIProtocol has been set up to handle the more prompt or any paging, strip it out of the response
            if ( defined $cliProtocol->{more_prompt} )
            {
                # Strip out any dollar sign ($) from the prompt.  Odds are that it will not properly match
                my $modifiedMorePrompt = $cliProtocol->{more_prompt}->{prompt};
                $modifiedMorePrompt =~ s/\$//;
                
                # Strip out the more prompt and any erroneous ASCII characters
                $response =~ s/$modifiedMorePrompt[\x00-\x20]*//sg;
            }
		}
		
		# Encode the device response and print out the details of this specific command
		$commandDetails->{response} = encode_base64($response);
		$printer->print_element( 'commandDetails', $commandDetails ) if $printStdout;
		push (@{$results->{commands}}, $commandDetails);
	}
	$printer->close_element('ZiptieDeviceCommmandDetails') if $printStdout;
	return $results;
}

sub get_snmp
{
	my $session = shift;

	# OIDs for various system info...
	my $keySysDescr = '.1.3.6.1.2.1.1.1.0';
	my $keyOid      = '.1.3.6.1.2.1.1.2.0';
	my $keyContact  = '.1.3.6.1.2.1.1.4.0';
	my $keyName     = '.1.3.6.1.2.1.1.5.0';
	my $keyLoc      = '.1.3.6.1.2.1.1.6.0';

	my $result = $session->get_request( -varbindlist => [ $keySysDescr, $keyOid, $keyContact, $keyName, $keyLoc, ] );

	unless ($result)
	{
		my $net_snmp_error = $session->error();
		if ( !defined($net_snmp_error) )
		{
			$net_snmp_error = "No Net::SNMP error could be found!";
		}
		$LOGGER->fatal("[$SNMP_ERROR]\nError getting SNMP request: $net_snmp_error");
	}

	my $snmp = {
		"sysDescr"    => $result->{$keySysDescr},
		"sysName"     => $result->{$keyName},
		"sysContact"  => $result->{$keyContact},
		"sysLocation" => $result->{$keyLoc},
		"sysObjectId" => $result->{$keyOid},
	};
	return $snmp;
}

sub get_interfaces
{
	my $session = shift;

	# OIDs for various interface information...
	my $interfacesOid = '.1.3.6.1.2.1.2';
	my $ifDescr       = $interfacesOid . '.2.1.2';
	my $ifType        = $interfacesOid . '.2.1.3';
	my $ifMtu         = $interfacesOid . '.2.1.4';
	my $ifSpeed       = $interfacesOid . '.2.1.5';
	my $ifPhysAddress = $interfacesOid . '.2.1.6';
	my $ifAdminStatus = $interfacesOid . '.2.1.7';

	my $ipAddrTable = '.1.3.6.1.2.1.4.20';

	my $interfaces = {};

	use ZipTie::SNMP;
	my $r1 = ZipTie::SNMP::walk( $session, $ifDescr );
	foreach my $key ( sort ( keys(%$r1) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			$interfaces->{$1}->{"name"} = $r1->{$key};
			$interfaces->{$1}->{"ifIndex"} = $1;
		}
	}
	
	my $r2 = ZipTie::SNMP::walk( $session, $ifType );
	foreach my $key ( sort ( keys(%$r2) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			$interfaces->{$1}->{"interfaceType"} = $r2->{$key};
		}
	}
	
	my $r3 = ZipTie::SNMP::walk( $session, $ifMtu );
	foreach my $key ( sort ( keys(%$r3) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			$interfaces->{$1}->{"mtu"} = int( $r3->{$key} );
		}
	}
	
	my $r4 = ZipTie::SNMP::walk( $session, $ifSpeed );
	foreach my $key ( sort ( keys(%$r4) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			$interfaces->{$1}->{"speed"} = int( $r4->{$key} );
		}
	}
	
	my $r5 = ZipTie::SNMP::walk( $session, $ifPhysAddress );
	foreach my $key ( sort ( keys(%$r5) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			$r5->{$key} =~ s/\x00$//;
			my $hexValue = $r5->{$key};
			if ($hexValue)
			{
				my $mac = _get_mac($hexValue);
				$interfaces->{$1}->{"interfaceEthernet"}->{"macAddress"} = $mac if $mac;
			}
		}
	}

	my $r6 = ZipTie::SNMP::walk( $session, $ifAdminStatus );
	foreach my $key ( sort ( keys(%$r6) ) )
	{
		if ( $key =~ /(\d+)$/ )
		{
			my $statusString = "down";
			if ( int( $r6->{$key} ) == 1 )
			{
				$statusString = "up";
			}
			$interfaces->{$1}->{"adminStatus"} = $statusString;
		}
	}

	my $results = ZipTie::SNMP::walk( $session, $ipAddrTable );

	my $ifIndex = {};
	foreach my $key ( sort ( keys(%$results) ) )
	{
		if ( $key =~ /^$ipAddrTable\.1\.2\.(\d+\.\d+\.\d+\.\d+)/ )
		{
			$ifIndex->{$1} = $results->{$key};
		}
		elsif ( $key =~ /^$ipAddrTable\.1\.3\.(\d+\.\d+\.\d+\.\d+)/ )
		{
			my $ip   = $1;
			my $mask = $results->{$key};

			my $ipConfiguration = {
				"ipAddress" => $ip,
				"mask"      => mask_to_bits($mask),
			};
			push( @{ $interfaces->{ $ifIndex->{$ip} }->{"interfaceIp"}->{"ipConfiguration"} }, $ipConfiguration );
		}
	}

	# arrange in a nicer hash for printing to XML
	my $readyInts = {};
	foreach my $key ( sort ( keys(%$interfaces) ) )
	{
		my $thisInterface = $interfaces->{$key};

		# set the physical boolean and the type string
		( $thisInterface->{interfaceType}, $thisInterface->{physical} ) = resolve_type( $thisInterface->{interfaceType} );
		push( @{ $readyInts->{interface} }, $thisInterface );
	}
	return $readyInts;
}

sub scp_restore
{
	my ( $connection_path, $restoreFile ) = @_;
	my $scpFileServer = $connection_path->get_file_server_by_name("SCP");
	my $scpProtocol   = $connection_path->get_protocol_by_name("SCP");

	# write the config to a temp file
	my $tempFile = new File::Temp();
	print $tempFile $restoreFile->get_blob();
	$tempFile->close();

	my $xfer_client = ZipTie::TransferProtocolFactory::create("SCP");
	$xfer_client->connect(
		$connection_path->get_ip_address(),
		$scpProtocol->get_port(),
		$connection_path->get_credential_by_name("username"),
		$connection_path->get_credential_by_name("password")
	);
	$xfer_client->put( $tempFile->filename(), $restoreFile->get_path() );
	$xfer_client->disconnect();
}

# get the real MAC from something like 0x0000ffff0000
sub _get_mac
{
	my $hex = shift;
	$hex =~ s/^0x//;
	$hex =~ s/[^A-Fa-f0-9\\.:\\-\\*\\?]//g;    # remove non hex chars
	
	my $MAC = get_crep('mac1');
	
	if ( $hex =~ /$MAC/mio )
	{
		return $hex;
	}
	else
	{
		return undef;
	}
}

# given an ifType value, match it to one of the allowed ZipTie interface types
sub resolve_type
{
	my $ifType   = shift;
	my $type     = "other";
	my $physical = "true";

	switch ($ifType)
	{
		case [1] { $type = "other" };
		case [24] { $type = "softwareLoopback"; $physical = "false" };
		case [ 37, 49, 114, 152, 189, 197 ] { $type = "atm" };
		case [ 80, 134, 149 ] { $type = "atm"; $physical = "false" };
		case [ 6, 26, 62, 69, 117 ] { $type = "ethernet" };
		case [ 32, 44, 58, 92 ] { $type = "frameRelay" };
		case [ 63, 75, 76 ] { $type = "isdn" };
		case [48] { $type = "modem" };
		case [ 23, 108 ] { $type = "ppp" };
		case [22] { $type = "serial" };
		case [ 39, 50, 51, 185 ] { $type = "sonet" };
		case [ 8,   9 ]  { $type     = "tokenRing" };
		case [ 131, 53 ] { $physical = "false" };
	}
	return ( $type, $physical );

}

1;

__END__

=head1 NAME

ZipTie::Adapters::GenericAdapter

=head1 SYNOPSIS

    use ZipTie::Adapters::GenericAdapter;
	ZipTie::Adapters::GenericAdapter::execute_cli_commands($cli_protocol, $commands, $defaultPrompt);

=head1 DESCRIPTION

This module contains methods that can be of use to any adapter.  For example, they use
the ZipTie::CliProtocol or use public SNMP mibs through the ZipTie::SNMP module.

=head2 METHODS

=over 12

=item C<execute_cli_commands($cli_protocol, $commands, $defaultPrompt)>

Runs a series of CLI based commands against the provided $cli_protocol object.

	$cli_protocol - Implementation of ZipTie::CLIProtocol
	$commands - Implementation of ZipTie::CommandSet
	$defaultPrompt - a regex for the prompt
	
An XML document containing the adapter responses will be printed to STDOUT or
whichever filehandle the Utils call offers up.

=item C<get_snmp($snmp_session)>

Using the provided Net::SNMP->session object, this method retrieves common:SNMP elements
as explained by the SNMP element of the ZiptieElementDocument XSD.

=item C<get_interfaces($snmp_session)>

Using the provided Net::SNMP->session object, this method retrieves common:Interface elements
as explained by the SNMP element of the ZiptieElementDocument XSD.

=item C<scp_restore($connectionPath, $restoreFile)>

Does an SCP 'put' of the provided $restoreFile
	$connectionPath - an instance of ZipTie::ConnectionPath
	$restoreFile - an instance of ZipTie::RestoreFile

=back

=head1 LICENSE

 The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS"
 basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 License for the specific language governing rights and limitations
 under the License.

=head1 AUTHOR

  Contributor(s): rkruse
  Date: Aug 24, 2007

=cut
