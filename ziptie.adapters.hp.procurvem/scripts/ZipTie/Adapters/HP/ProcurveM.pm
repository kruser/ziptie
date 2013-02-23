package ZipTie::Adapters::HP::ProcurveM;

use strict;
use ZipTie::CLIProtocolFactory;
use ZipTie::CLIProtocol;
use ZipTie::ConnectionPath;
use ZipTie::Credentials;
use ZipTie::Adapters::HP::ProcurveM::AutoLogin;
use ZipTie::Adapters::HP::ProcurveM::Parsers
  qw(parse_routing create_config parse_local_accounts parse_chassis parse_filters parse_snmp parse_system parse_interfaces parse_static_routes parse_vlans parse_stp);
use ZipTie::Adapters::HP::ProcurveM::Disconnect
	qw(disconnect);
use ZipTie::Adapters::HP::ProcurveM::Restore;
use ZipTie::Adapters::Utils qw(get_model_filehandle close_model_filehandle);
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
	my ( $connection_path, $credentials ) = ZipTie::Typer::translate_document( $backup_doc, 'connectionPath' );
	my ( $cli_protocol, $prompt_regex ) = _connect( $connection_path, $credentials );

	# Grab an output filehandle for the model.  This usually points to STDOUT
	my $filehandle = get_model_filehandle( 'ProcurveM', $connection_path->get_ip_address() );

	# initialize the model printer
	my $printer = ZipTie::Model::XmlPrint->new( $filehandle, 'common' );
	$printer->open_model();

	# Begin executing commands on the device.  The results of each command will
	# be stored in a single hashtable ($parsers) and fed into each parsing method
	my $responses = {};

	$cli_protocol->get_response(0.25);    # flush out the buffer
	
	# change terminal type
	#$cli_protocol->turn_vt102_on(150,25); # set terminal size

	# set the --more-- prompt if the term length 0 didn't go through
    #$cli_protocol->set_more_prompt( '(-- MORE --|Press any key to continue)', '20');
	
	if ( not defined $cli_protocol->get_prompt_by_name( "enablePrompt") )
	{
		$cli_protocol->send_as_bytes('31'); # enter the status and counters menu
		$cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('31'); # output the system info
		$responses->{'system'} = $cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('0D'); # exit to the status and counters menu
		$responses->{temp1} = $cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('33'); # output the module info
		$responses->{module} = $cli_protocol->get_response(0.25);
		
		$cli_protocol->send_as_bytes('0D'); # exit to the status and counters menu
		$cli_protocol->get_response(0.25);
		
		$cli_protocol->send_as_bytes('30'); # exit to the main menu
		$cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('35'); # enter to Diagnostics Menu
		$cli_protocol->get_response(0.25);

		$responses->{config_plain}	= "";
		my $moreConfig				= 1;
		my $cfgFileOpt				= '33';
		while ($moreConfig)
		{
			$cli_protocol->send_as_bytes($cfgFileOpt); # get config file
			my $temp_resp = $cli_protocol->get_response(0.25);
			$responses->{config_plain} .= $temp_resp;
			if ( $temp_resp !~ /-- MORE --/mi )
			{
				$moreConfig = undef;
			}
			$cfgFileOpt = '20';
		}

		$cli_protocol->send_as_bytes('30'); # exit to the main menu
		$cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('35'); # enter to Diagnostics Menu
		$cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('34'); # enter to Command Prompt
		$cli_protocol->get_response(0.25);

		$cli_protocol->send_as_bytes('0D'); # confirm default vlan
		$cli_protocol->get_response(0.25);

		my $dv_prompt_regex		= '(DEFAULT_VLAN:)|(-- MORE --)';
		$moreConfig				= 1;
		$cfgFileOpt				= 'config';
		$responses->{'config'}	= "";
		while ($moreConfig)
		{
			my $temp_resp;
			if ( $cfgFileOpt ne 'config' )
			{
				$cli_protocol->send_as_bytes($cfgFileOpt); # get config file
				$temp_resp = $cli_protocol->get_response(0.25);			
			}
			else
			{
				$temp_resp = $cli_protocol->send_and_wait_for( $cfgFileOpt, $dv_prompt_regex );
			}
			$responses->{'config'} .= $temp_resp;
			if ( $temp_resp !~ /-- MORE --/mi )
			{
				$moreConfig = undef;
			}
			$cfgFileOpt = '20';
		} 
	} 
	else
	{	
		$cli_protocol->send( "\n" );
		$responses->{'system'}			= _issue_command( $cli_protocol, 'print show system' );
		$responses->{'module'}			= _issue_command( $cli_protocol, 'print show module' );
		$responses->{'config_plain'}	= _issue_command( $cli_protocol, 'print browse' );
		$responses->{snmp}				= _issue_command( $cli_protocol, 'print show snmp' );
		$responses->{ports}				= _issue_command( $cli_protocol, 'print show port status' );
		$responses->{ports_spantree}	= _issue_command( $cli_protocol, 'print show port spantree' );
		$responses->{ports_ip}			= _issue_command( $cli_protocol, 'print show ip' );
		$responses->{stp}				= _issue_command( $cli_protocol, 'print show spantree' );
		
		$responses->{config}			= _issue_command( $cli_protocol, 'print config' );
		# here if we are in cli command line

		#$cli_protocol->turn_vt102_on(150,25); # set terminal size
		$cli_protocol->send( 'exit' ); # exit from command prompt
		$cli_protocol->send_as_bytes('30'); # exit to the main menu
		$cli_protocol->get_response(0.25);
	}

	parse_system( $responses, $printer );
	parse_chassis( $responses, $printer );
	delete $responses->{module};

	create_config( $responses, $printer );

	parse_interfaces( $responses, $printer );
	delete $responses->{ports};
	delete $responses->{ports_spantree};
	delete $responses->{ports_ip};

	parse_snmp( $responses, $printer );
	delete $responses->{snmp};

	parse_stp( $responses, $printer );
	delete $responses->{stp};
	#parse_static_routes( $responses, $printer );

	parse_vlans( $responses, $printer );

	delete $responses->{'system'};
	delete $responses->{config};

	# close out the ZiptieElementDocument
	$printer->close_model();
	
	# Make sure to close the model file handle
	close_model_filehandle($filehandle);
	
	# Disconnect from the device
	disconnect($cli_protocol);
}

# unique way for this model to work without term len 0
# Watch for "Press RETURN when ready"
# grab everything until "Press RETURN when done"
sub _issue_command
{
	my $cli_protocol = shift;
	my $command	 = shift;	

	my @responses = ();
	# vt102 seems to have limited buffer size, since we are getting around that
	# by using print 'command' anyways, we can turn it off while in the command loop
	push( @responses, ZipTie::Response->new( 'Press RETURN when ready',  \&_send_enter) );

	$cli_protocol->turn_vt102_off();

	$cli_protocol->send($command);
	my $response = $cli_protocol->wait_for_responses( \@responses );

	if ($response)
	{
		my $next_interaction = $response->get_next_interaction();
		return &$next_interaction( $cli_protocol );
	}
}

sub _send_enter
{
	my $cli_protocol = shift;

	my @responses = ();
	push( @responses, ZipTie::Response->new( 'Press RETURN when done',           \&_send_enter_wait_for_prompt) );
	push( @responses, ZipTie::Response->new( 'Press any key when done',          \&_send_enter_wait_for_prompt) );

	$cli_protocol->send_as_bytes('0D');
    my $response	= $cli_protocol->wait_for_responses( \@responses );

	my $last_match	=  $cli_protocol->last_match();
	$last_match		=~ s/(Press RETURN when done|Press any key when done)//g;
	chomp($last_match);

	if ($response)
	{
		return _send_enter_wait_for_prompt( $cli_protocol,  $last_match ) ; 
	}
}

# end of _issue_command cycle
sub _send_enter_wait_for_prompt
{
	my $cli_protocol = shift;
	my $last_response_matched = shift;
	my $prompt_regex = $cli_protocol->get_prompt_by_name( "enablePrompt") ;
	$prompt_regex = $prompt_regex || ':';

	$cli_protocol->send_as_bytes_and_wait('0D', $prompt_regex);
	$cli_protocol->turn_vt102_on(80,250);
	return $last_response_matched;
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
	my $device_prompt_regex = ZipTie::Adapters::HP::ProcurveM::AutoLogin::execute( $cli_protocol, $connection_path );
	
	# Store the regular expression that matches the primary prompt of the device under the key "prompt"
	# on the ZipTie::CLIProtocol object
	$cli_protocol->set_prompt_by_name( 'prompt', $device_prompt_regex );
	
	# Return the created ZipTie::CLIProtocol object and the device prompt encountered after successfully connecting to a device.
	return ( $cli_protocol, $device_prompt_regex );
}

1;

__END__

=head1 NAME

ZipTie::Adapters::HP::ProcurveM - Example adapter for performing various operations against a particular family of devices.

=head1 SYNOPSIS

    use ZipTie::Adapters::HP::ProcurveM;
	ZipTie::Adapters::HP::ProcurveM::backup( $backup_document );

=head1 DESCRIPTION

This module represents an example of an adapter that can be used to perform various operations against a particular
family of devices.

Generally you would run this module through the ZipTie C<invoke.pl> script.

=head1 PUBLIC SUB-ROUTINES

=over 12

=item C<backup($backup_document)>

Performs the backup of the device that is described in the specified XML document.  This XML document contains
a "connectionPath" element that contains the IP/hostname, protocol, credential, and file server information that
may be needed to connect to, authenticate with, and back up the device in question.  This XML will be parsed into
a C<ZipTie::ConnectionPath> object to help easily access this vital information.

The act of backing up a device means that information about a device will be retreived, as well as the configuration
data/files for that device.  All of this collected information will be used to populate the ZipTie Element Document,
which is an open and extensible format for describing a network device.

The return value for this method will be a string containing the successfully populated ZipTie Element Document.

=back

=head1 PRIVATE SUB-ROUTINES

=over 12

=item C<_connect($connection_path)>

Creates the initial CLI connection to the device.  A list is returned containing two elements: the first is a
C<ZipTie::CLIProtocol> object that is a CLI client that can communitcate with the device, and the second is a
regular expression that can be used to match the primary prompt of the device.  This is useful when sending
commands to and receiving responses from the device through the C<ZipTie::CLIProtocol> object and being able to
know when a command has generated all the output and returned back to the primary prompt.

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

The Original Code is Ziptie Client Framework.

The Initial Developer of the Original Code is AlterPoint.
Portions created by AlterPoint are Copyright (C) 2006,
AlterPoint, Inc. All Rights Reserved.

=head1 AUTHOR

Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
Date: August 10, 2007

=cut
