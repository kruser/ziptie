#!/bin/perl
#
# Determines to see if the following Perl requirments have been met:
#
#   * On Windows, a version of 5.8.1 or high of ActiveState's Perl distribution should be installed.
#
# Checks to see if all of the specified Perl modules are already installed.
# If any of the modules are missing, the following logic is enforced:
#
#   * On Windows, the missing modules will be installed one by one via PPM.  If any of the autmoatic installs
#     fails, then a list of the failed modules plus the command used to install them will be displayed.
#
#   * On Linux/Mac OS X, the missing modules will be listed along with the OS specific command that should
#     be used to install the missing modules.
use strict;
use Config;

# Grab the name of OS that this script is being run on
my $OS = $Config::Config{'osname'};

# Check to see if we have at least version 5.8.1 of ActiveState Perl on Windows.
if ( $OS =~ /MSWin32/i )
{
	unless ( $] >= 5.008001 )
	{
		die "Sorry, you need at least ActiveState Perl build 5.8.1\n";
	}
}

# Specify the modules required for ZipTie
my @required_modules = (
	'IPC::Run',          'Net::Telnet',
	'XML::Simple',       'LWP::UserAgent',
	'HTTP::Response',    'HTTP::Request',
	'XML::Twig',         'Net::TFTP',
	'IO::Zlib',          'Term::VT102',
	'XML::SemanticDiff', 'File::Iterator',
	'XML::XPath',        'Compress::Zlib',
	'Archive::Tar',      'XML::Parser',
	'Time::HiRes',       'MIME::Base64',
	'Scalar::Util',      'List::Util',
	'Crypt::SSLeay',     'IO::Socket::INET6',
	'Net::IP',           'Text::CSV',
	'Term::ShellUI',     'Term::ReadKey',
	'SOAP::Lite 0.69',   'ZipTie::Client',
	'Math::BigInt',      'Math::BigInt::GMP',
);

# Get absolute path of ppm ( we suppose ppm is located in the same directory as perl executable).
$_ = $^X;
my $ppmExePath = (/^(.+)(\\|\/)[^\\\/]+$/) ? $1 . $2 . 'ppm' : 'ppm';

# Add certain required modules if we are not running on Windows.
# For Windows users, these are provided by ZipTie (sorry *nix peeps)
if ( $OS !~ /MSWin32/i )
{
	push( @required_modules,
		'Socket6',      'Crypt::DES', 'Net::SNMP',
		'Digest::SHA1', 'Digest::HMAC', );
}

# Create a list that can contain all the missing modules
my @missing_modules = ();

# For each module specified, check to see if it is already installed.
foreach my $curr_module (@required_modules)
{
	my $eval_cmd = 'local $SIG{__DIE__}; use ' . $curr_module;
	eval($eval_cmd);

# If there was an error message, then the module is not installed.
# Compute a hash that contains the name of the module and the command to install it
	if ($@)
	{
		push( @missing_modules, $curr_module );
	}
}

# Create a list that can contain all the modules that failed to install
my @failed_modules = ();

# Analyze the modules missing
if ( @missing_modules > 0 )
{

	# On Windows, attempt to install all of the missing modules
	if ( $OS =~ /MSWin32/i )
	{
		my $perl510 = 0;
		if ( $] >= 5.010000 )
		{
			$perl510 = 1;
		}

		_add_repos();

		# Store the number of missing modules
		my $num_of_missing_modules = @missing_modules;

		print(
"$num_of_missing_modules required Perl module(s) is/are missing.  Attempting to install missing modules ...\n\n"
		);
		foreach my $module (@missing_modules)
		{
			$module =~ s/\s+.*$//;

# Convert '::' in the module definition to a single '-' to be compatible with PPM
			$module =~ s/::/-/g;

			# Install the Perl module
			print("Installing '$module' using PPM ...\n");

			my $command = "$ppmExePath install $module";

			# some modules come from a different repository
			if ( $module =~ /ssleay/i )
			{
				_install_with_defaults('Crypt-SSLeay');
				next;
			}
			elsif ( $module eq "IO-Socket-INET6" )
			{
				$command = "$ppmExePath install INET6";
			}
			elsif ( $module eq 'SOAP-Lite' )
			{
				if ($perl510)
				{
					$command =
"$ppmExePath install http://cpan.uwinnipeg.ca/PPMPackages/10xx/SOAP-Lite.ppd";
				}
				else
				{
					$command =
"$ppmExePath install http://theoryx5.uwinnipeg.ca/ppms/SOAP-Lite.ppd";
				}
			}

			my $ppm_error_code = system($command);

			# If the Perl module failed to install, remember it
			if ( $ppm_error_code > 0 )
			{
				push( @failed_modules, $module );
			}
		}

		# Check to see if any Perl modules failed to install
		if ( @failed_modules > 0 )
		{
			print(
"\nThe following required Perl module(s) failed to be installed automatically.  Here is the list of the missing module(s) and the command(s) used to install:\n\n"
			);
			foreach my $module (@failed_modules)
			{
				print( "\t" . $module . "\tppm install $module\n" );
			}
		}
		else
		{
			print(
"\nAll of the missing Perl modules were successfully installed!  Yatta!\n"
			);
		}
	}

# Otherwise, just display the modules that are missing and the commands to install them
	else
	{
		print(
"\nThe following required Perl module(s) is/are missing.  Here is the list of the missing module(s) and the command(s) to use to install:\n\n"
		);
		foreach my $module (@missing_modules)
		{
			$module =~ s/\s+.*$//;
			print(  "\t" 
				  . $module
				  . "\tsudo $^X -MCPAN -e 'install \"$module\"'\n" );
		}
	}
}

# Otherwise, we have all our the Perl modules install properly.
else
{
	print(
"All the Perl modules required by ZipTie are already installed!  Yatta!\n"
	);
}

sub _add_repos
{
	my $repoList = `$ppmExePath repo list --csv`;

	my $trouchelle;
	my $winnipeg;
	if ( $] < 5.010000 )
	{
		$trouchelle = 'http://trouchelle.com/ppm/';
		$winnipeg   = 'http://theoryx5.uwinnipeg.ca/ppms/';
	}
	else
	{
		$trouchelle = 'http://trouchelle.com/ppm10/';
		$winnipeg   = 'http://cpan.uwinnipeg.ca/PPMPackages/10xx/';

		_ppm_add_repo( 'http://www.bribes.org/perl/ppm/', $repoList, 'bribes' );
	}

	_ppm_add_repo( $trouchelle, $repoList, 'trouchelle' );
	_ppm_add_repo( $winnipeg,   $repoList, 'winnipeg' );

}

sub _ppm_add_repo
{
	my ( $newRepo, $currentRepos, $match ) = @_;
	if ( $currentRepos !~ /$match/i )
	{
		print("Adding $newRepo repository using PPM ...\n");
		my $command        = "$ppmExePath rep add $newRepo";
		my $ppm_error_code = system($command);

		# If the ppm repository failed to install, just warn about it
		if ( $ppm_error_code > 0 )
		{
			print("Failed adding repository: $newRepo ...\n");
		}
	}
	else
	{
		print("$newRepo already present\n");
	}

}

sub _install_with_defaults
{

	# install and accept the default answers to any questions
	my $module = shift;
	require IPC::Run;

	$_ = $^X;
	my $ppmExePath = (/^(.+)(\\|\/)[^\\\/]+$/) ? $1 . $2 . 'ppm' : 'ppm';

	my @cmds = ( $ppmExePath, 'install', $module );
	my ( $in, $out, $err );
	my $harness = IPC::Run::start( \@cmds, \$in, \$out, \$err );

	while (1)
	{
		eval {
			$harness->pump until $out =~ /(\[[^\[\]]+\]|^done)\s*$/m;
			print $out. "\n";
			if ( $out =~ /^done\s*$/m )
			{
				$harness->finish();
				return;
			}
			else
			{
				$in .= "\n";
			}
			$out = '';
		};
		if ($@)
		{
			print "Finished installing $module\n";
			$harness->finish();
			return;
		}
	}

}
