package ZipTie::Adapters::Dell::PowerConnect;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Dell::PowerConnect::AutoLogin;
use ZipTie::Adapters::Dell::PowerConnect::GetConfig qw(get_config);
use ZipTie::Adapters::Dell::PowerConnect::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Dell::PowerConnect::Disconnect qw(disconnect);
use ZipTie::Adapters::Dell::PowerConnect::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Adapters::GenericAdapter;
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $package_name = shift;
	my $backup_doc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Dell PowerConnect', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$prompt_regex = '('.$prompt_regex.'|More: <space>)';

	$responses->{'running-config'} = get_config( $cli_protocol, $connection_path, 'running-config' );
	$responses->{'startup-config'} = get_config( $cli_protocol, $connection_path, 'startup-config' );
	$responses->{version}	= get_implode_output($cli_protocol, "show version", $prompt_regex);
	$responses->{'system'}	= get_implode_output($cli_protocol, "show system", $prompt_regex);
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{version};
	delete $responses->{'system'};

	create_config( $responses, $printer );

	$responses->{interfaces}	= get_implode_output($cli_protocol, "show interfaces configuration", $prompt_regex);
	$responses->{stp}			= get_implode_output($cli_protocol, "show spanning-tree", $prompt_regex);
	parse_interfaces( $responses, $printer );
	delete $responses->{interfaces};

	parse_local_accounts( $responses, $printer );

	parse_snmp( $responses, $printer );

	parse_stp( $responses, $printer );
	delete $responses->{stp};

	delete $responses->{'running-config'};
	delete $responses->{'startup-config'};

	$responses->{vlans} = get_implode_output($cli_protocol, "show vlan", $prompt_regex);
	parse_vlans( $responses, $printer );
	delete $responses->{vlans};

	# Disconnect from the device
	disconnect($cli_protocol);

	# close out the ZiptieElementDocument
	$printer->close_model();
	
	# Make sure to close the model file handle
	close_model_filehandle($filehandle);
}

sub get_implode_output
{
	my $cli_protocol	= shift;
	my $command			= shift;
	my $regex			= shift;
	my $response		= "";
	my $more_info		= 1;

	while ( $more_info )
	{
		if ( $command =~ /^20$/ )
		{
			$cli_protocol->send_as_bytes( $command );
		}
		else
		{
			$cli_protocol->send( $command );
		}

		$command	= "20";
		$_			= $cli_protocol->wait_for( $regex );

		if ( /More: <space>/mi )
		{
			s/More: <space>.*//mig; # remove any More prompt lines
		}
		else
		{
			$more_info = undef;
		}
		$response .= $_;
	}

	$_		  = $cli_protocol->get_prompt_by_name("prompt");
	$response =~ s/^show .+$//mig; # remove leading cruft from the 'show' command output
	$response =~ s/% Unrecognized command.+$//is; # remove the error message
	$response =~ s/$_//mi; # remove the prompt
	$response =~ s/\x1b\[.{1}//mg; # remove the garbage after send_as_byte

	return $response;
}

sub commands
{
	my $package_name = shift;
	my $command_doc = shift;
	
	my ( $connection_path, $commands ) = ZipTie::Typer::translate_document( $command_doc, 'connectionPath' );
	my ( $cli_protocol, $device_prompt_regex ) = _connect( $connection_path );
	
	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands('Dell PowerConnect', $cli_protocol, $commands, '(#|\$|>)\s*$');
	disconnect($cli_protocol);
	return $result;
}

sub _connect
{
	# Grab our arguments
	my $connection_path = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cli_protocol = ZipTie::CLIProtocolFactory::create($connection_path);

	# Make a connection to and successfully authenticate with the device
	my $device_prompt_regex = ZipTie::Adapters::Dell::PowerConnect::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;