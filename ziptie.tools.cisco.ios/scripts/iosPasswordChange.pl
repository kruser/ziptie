#!/usr/bin/perl

use ZipTie::CLIProtocolFactory;
use ZipTie::Adapters::Cisco::IOS::AutoLogin;
use ZipTie::Adapters::Cisco::IOS::Disconnect qw(disconnect);
use ZipTie::Credentials;
use ZipTie::ConnectionPath;
use ZipTie::Typer;
use ZipTie::Logger;
use ZipTie::Tools::ServerElf qw(update_credential update_dependent_credential);

use strict;

# Get the instance of the ZipTie::Logger module
my $LOGGER = ZipTie::Logger::get_logger();
# Redirect warnings to the Logger so they don't polute Tool output
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	$LOGGER->debug($warning);
};

my ($NEW_ENABLE_SECRET, $NEW_ENABLE_PASSWORD, $NEW_VTY_PASSWORD, $NEW_CONSOLE_PASSWORD, $NEW_ACCOUNT_PASSWORD);
my ($CHANGE_ENABLE_SECRET, $CHANGE_ENABLE_PASSWORD, $CHANGE_VTY_PASSWORD, $CHANGE_CONSOLE_PASSWORD, $CHANGE_ACCOUNT_PASSWORD);
my ($ACCOUNT_USERNAME, $WRITE_STARTUP);

# Store the connection path XML and the ZipTie::ConnectionPath object
my $connectionPathXML;
my $connectionPath;

my $option;
while ($_ = shift(@ARGV))
{
   if (/--enableSecret=/)
   {
       $NEW_ENABLE_SECRET = $';
       $CHANGE_ENABLE_SECRET = (length($NEW_ENABLE_SECRET) > 0)
   }
   elsif (/--enablePassword=/)
   {
       $NEW_ENABLE_PASSWORD = $';
       $CHANGE_ENABLE_PASSWORD = (length($NEW_ENABLE_PASSWORD) > 0)
   }
   elsif (/--vtyPassword=/)
   {
       $NEW_VTY_PASSWORD = $';
       $CHANGE_VTY_PASSWORD = (length($NEW_VTY_PASSWORD) > 0);
   }
   elsif (/--conPassword=/)
   {
       $NEW_CONSOLE_PASSWORD = $';
       $CHANGE_CONSOLE_PASSWORD = (length($NEW_CONSOLE_PASSWORD) > 0);
   }
   elsif (/--acctUser=/)
   {
       $ACCOUNT_USERNAME = $';
   }
   elsif (/--acctPassword=/)
   {
       $NEW_ACCOUNT_PASSWORD = $';
       $CHANGE_ACCOUNT_PASSWORD = (length($ACCOUNT_USERNAME) > 0 && length($NEW_ACCOUNT_PASSWORD) > 0);
   }
   elsif (/--writeMem=/)
   {
       my $tmp = $';
       $WRITE_STARTUP = ($tmp =~ /true/i);
   }
   elsif (/--connectionPath=/)
   {
       $connectionPathXML = $';
       ($connectionPath) = ZipTie::Typer::translate_document( $connectionPathXML, 'connectionPath' );
   }
}

# Store the device IP
my $device = $connectionPath->get_ip_address();
my $managedNetwork = 'Default';

$LOGGER->debug("Enable secret: $NEW_ENABLE_SECRET") if $CHANGE_ENABLE_SECRET;
$LOGGER->debug("Enable password: $NEW_ENABLE_PASSWORD") if $CHANGE_ENABLE_PASSWORD;
$LOGGER->debug("VTY password: $NEW_VTY_PASSWORD") if $CHANGE_VTY_PASSWORD;
$LOGGER->debug("Console password: $NEW_CONSOLE_PASSWORD") if $CHANGE_CONSOLE_PASSWORD;
$LOGGER->debug("Account user:password: $ACCOUNT_USERNAME:$NEW_ACCOUNT_PASSWORD") if $CHANGE_ACCOUNT_PASSWORD;
$LOGGER->debug("Write startup: $WRITE_STARTUP") if $WRITE_STARTUP;
$LOGGER->debug("Device: $device");

# Store all the device responses
my $responses;

# Perform the logic in an eval statement to catch any errors
eval
{
	# Connect to the device and login
	my $cliProtocol = ZipTie::CLIProtocolFactory::create($connectionPath);
	my $enablePrompt = ZipTie::Adapters::Cisco::IOS::AutoLogin::execute( $cliProtocol, $connectionPath );
	
	# Store the found prompt as "enablePrompt" on the specified CLI protocol.
	$cliProtocol->set_prompt_by_name( "enablePrompt", $enablePrompt );
	
	$cliProtocol->send("terminal length 0");
	$responses .= $cliProtocol->wait_for("#");
	    
	$cliProtocol->send("configure terminal");
	$responses .= $cliProtocol->wait_for("#");
	
	if ($CHANGE_ENABLE_SECRET)
	{
		$responses .= changeEnableSecret($cliProtocol, $NEW_ENABLE_SECRET);
	}
	if ($CHANGE_ENABLE_PASSWORD) 
	{
		$responses .= changeEnablePassword($cliProtocol, $NEW_ENABLE_PASSWORD);
	}
	if ($CHANGE_ACCOUNT_PASSWORD) 
	{
		$responses .= changeAccountPassword($cliProtocol, $ACCOUNT_USERNAME, $NEW_ACCOUNT_PASSWORD);
	}
	if ($CHANGE_VTY_PASSWORD) 
	{
		$responses .= changeVtyPassword($cliProtocol, $NEW_VTY_PASSWORD) 
	}
	if ($CHANGE_CONSOLE_PASSWORD) 
	{
		$responses .= changeConsolePassword($cliProtocol, $NEW_CONSOLE_PASSWORD) 
	}
	
	$responses .= $cliProtocol->send_and_wait_for('exit', $enablePrompt);
	if ($WRITE_STARTUP) 
	{
		$responses .= writeStartup($cliProtocol);
	}
	
	disconnect($cliProtocol);
}; # End eval block

# If an error occurred, exit with an error
if ($@)
{
	print "ERROR,$device,Failure\n";
	print "\n";
	print "$@";
}
else
{
    print "OK,$device,Success\n";
    print "\n";
    print "$responses";
}


1;


sub changeEnableSecret 
{
	my ($autoTerminal, $newEnableSecret) = @_;
	my $resp = $autoTerminal->send_and_wait_for("enable secret $newEnableSecret", '#');
	update_credential($device, $managedNetwork, 'enablePassword', $newEnableSecret);
	
	$resp =~ s/$newEnableSecret/\*\*\*\*/;
	$resp;	
}

sub changeEnablePassword 
{
	my ($autoTerminal, $newEnablePassword) = @_;
	my $resp = $autoTerminal->send_and_wait_for("enable password $newEnablePassword", '#');
	update_credential($device, $managedNetwork, 'enablePassword', $newEnablePassword);
	
	$resp =~ s/$newEnablePassword/\*\*\*\*/;
	$resp;
}

sub changeAccountPassword
{
	my ($autoTerminal, $accountUsername, $newAccountPassword) = @_;
	my $resp = $autoTerminal->send_and_wait_for("username $accountUsername password $newAccountPassword", '#');
	update_dependent_credential($device, $managedNetwork, 'password', $newAccountPassword, 'username', $accountUsername);
	
	$resp =~ s/$newAccountPassword/\*\*\*\*/;
	$resp;	
}

sub changeVtyPassword
{
	my ($autoTerminal, $newVtyPassword) = @_;
	my $resp = $autoTerminal->send_and_wait_for("line vty 0 4", '#');
	$resp .= $autoTerminal->send_and_wait_for("password $newVtyPassword", '#');
	$resp .= $autoTerminal->send_and_wait_for('exit', '#');
	update_dependent_credential($device, $managedNetwork, 'password', $newVtyPassword, 'username', '');

	$resp =~ s/$newVtyPassword/\*\*\*\*/;
    $resp;
}

sub changeConsolePassword
{
	my ($autoTerminal, $newConsolePassword) = @_;
	my $resp = $autoTerminal->send_and_wait_for("line console 0", '#');	
	$resp .= $autoTerminal->send_and_wait_for("password $newConsolePassword", '#');
	$resp .= $autoTerminal->send_and_wait_for('exit', '#');

	$resp =~ s/$newConsolePassword/\*\*\*\*/;
    $resp;
}

sub writeStartup
{
	my ($autoTerminal) = @_;
	my $response = $autoTerminal->send_and_wait_for('write mem', '(#|confirm\])$');	
	if ($response =~ /confirm\]$/)
	{
		$autoTerminal->send_and_wait_for('', '#');
	}

    $response;
}