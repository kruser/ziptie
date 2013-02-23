package ZipTie::Adapters::Nortel::Passport1600;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::Nortel::Passport1600::AutoLogin;
use ZipTie::Adapters::Nortel::Passport1600::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::Nortel::Passport1600::Disconnect qw(disconnect);
use ZipTie::Adapters::Nortel::Passport1600::GetConfig qw(get_config);
use ZipTie::Adapters::Nortel::Passport1600::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
use ZipTie::Model::XmlPrint;
use ZipTie::Logger;
use ZipTie::Adapters::GenericAdapter;

# Grab a reference to the ZipTie::Logger
my $LOGGER = ZipTie::Logger::get_logger();

# Specifies that this adapter is a subclass of ZipTie::Adapters::BaseAdapter
use ZipTie::Adapters::BaseAdapter;
our @ISA = qw(ZipTie::Adapters::BaseAdapter);

sub backup
{
	my $packageName = shift;
	my $backupDoc   = shift;    # how to backup this device

	# Translate the backup operation XML document into ZipTie::ConnectionPath
	my ( $connection_path, $credentials ) = ZipTie::Typer::translate_document( $backupDoc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path, $credentials );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'Nortel Passport1600', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$cli_protocol->set_more_prompt( 'Next Page', '6E');
	my $prompt_regex2	= $cli_protocol->get_prompt_by_name('prompt');
	$prompt_regex2		= '/('.$prompt_regex2.')|(Next Page)/mi';

	$responses->{switch} = $cli_protocol->send_and_wait_for( 'show switch', $prompt_regex );
	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{switch};

	$responses->{'config'} = get_config( $cli_protocol, $connection_path );
	create_config( $responses, $printer );
	delete $responses->{'config'};

	$responses->{ipif}		= $cli_protocol->send_and_wait_for( 'show ipif',	$prompt_regex );
	$responses->{routes}	= $cli_protocol->send_and_wait_for( 'show iproute',	$prompt_regex );
	$responses->{accounts}	= $cli_protocol->send_and_wait_for( 'show account',	$prompt_regex );
	$responses->{snmp}		= $cli_protocol->send_and_wait_for( 'show snmp',	$prompt_regex );

	$cli_protocol->disable_more_prompt();

	$responses->{ports}	= "";
	while (  )
	{
		if ( $responses->{ports} eq '' )
		{
			$cli_protocol->send( 'show ports' );
		}
		else
		{
			$cli_protocol->send_as_bytes('6E');
		}
		$_ = $cli_protocol->get_response(0.25);
		$cli_protocol->get_response(0.25);
		if ( /\b(\d+\s+\S+\s+\S+\s+.*)$/mi )
		{
			if ( $responses->{ports} =~ /$1/mi )
			{
				last;
			}
			else
			{
				$responses->{ports} .= $_."\n";
			}
		}
	}
	$cli_protocol->send_as_bytes('71');

	$cli_protocol->get_response(0.25);

	my ( $fp, $lp );
	while ( $responses->{ports} =~ /\b(\d+)\s+\S+\s+\S+\s+(?:\S+|(?:Link Down))\s+\S+\s*$/mig )
	{
		$fp = $1 if ( !$fp );
		$lp = $1;
	}
	$responses->{stp_ports} = $cli_protocol->send_and_wait_for( "show stp ports $fp-$lp", $prompt_regex2 );
	$cli_protocol->send_as_bytes('71');

	$cli_protocol->send_and_wait_for( 'show mgmt_port', $prompt_regex2 );
	$responses->{port_mgmt} = $cli_protocol->get_response(0.25);
	$cli_protocol->send_as_bytes('71');

	parse_interfaces( $responses, $printer );
	delete $responses->{ipif};
	delete $responses->{port_mgmt};
	delete $responses->{ports};

	parse_local_accounts( $responses, $printer );
	delete $responses->{accounts};

	$cli_protocol->send_and_wait_for( 'show stp', $prompt_regex2 );
	$responses->{stp} = $cli_protocol->get_response(0.25);
	$cli_protocol->send_as_bytes('71');

	parse_snmp( $responses, $printer );
	delete $responses->{snmp};

	parse_stp( $responses, $printer );
	delete $responses->{stp};

	parse_static_routes( $responses, $printer );
	delete $responses->{routes};

	$cli_protocol->send_and_wait_for( 'logout', '.*' );

	# close out the ZiptieElementDocument
	$printer->close_model();

	# Make sure to close the model file handle
	close_model_filehandle($filehandle);

	# Disconnect from the device
	disconnect($cli_protocol);
}

sub commands
{
	my $packageName = shift;
	my $commandDoc  = shift;

	my ( $connectionPath, $commands ) = ZipTie::Typer::translate_document( $commandDoc, 'connectionPath' );
	my ( $cliProtocol, $devicePromptRegex ) = _connect($connectionPath);

	my $result = ZipTie::Adapters::GenericAdapter::execute_cli_commands( 'Nortel Passport1600', $cliProtocol, $commands, $devicePromptRegex . '|(#|\$|>)\s*$' );
	disconnect($cliProtocol);
	return $result;
}

sub _connect
{

	# Grab our arguments
	my $connectionPath = shift;

	# Create a new CLI protocol object by using the ZipTie::CLIProtocolFactory::create sub-routine
	# to examine the ZipTie::ConnectionPath argument for any command line interface (CLI) protocols
	# that may be specified.
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);

	# Make a connection to and successfully authenticate with the device
	my $devicePromptRegex = ZipTie::Adapters::Nortel::Passport1600::AutoLogin::execute( $cliProtocol, $connectionPath );

	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cliProtocol->set_prompt_by_name( 'prompt', $devicePromptRegex );

	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cliProtocol, $devicePromptRegex );
}

1;
