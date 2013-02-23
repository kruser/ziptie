#!/usr/bin/env perl

use Getopt::Long;
use File::Iterator;
use strict;

our @sql_files = (
	"device.sql",
	"netman.sql",
	"quartz.sql",
	"creds.sql",
	"tools.sql",
	"birt.sql",
	"telemetry.sql",
	"security.sql",
	"configstore.sql",
	"launchers.sql",
);

####################################################################
local $SIG{__WARN__} = sub {
	my $warning = shift;
	chomp $warning;
	print STDERR "Warning: $warning\n";
};

our %options = ();
my $rc = GetOptions( \%options, 'db:s', 'user:s', 'pass:s', 'dir:s', 'host:s', 'port:i', 'verbose!' );

my $action = shift(@ARGV) || die print_usage();

if ( $rc == 0 )
{
	print_usage();
	exit(1);
}

our $classpath = create_classpath();

my $ref = \&{"$action"};
&$ref();

0;

####################################################
# Reset the database by calling the appropriate
# reset subroutine and then executing all of the
# SQL files.
#
sub reset
{
	my $database = $options{db};
	my $host     = $options{host};
	my $user     = $options{user};
	my $password = $options{pass} || '';
	my $dir      = $options{dir} || '.';
	my $os 	     = $^O;

	my $resetdb = \&{"reset_$database"};
	&$resetdb( $user, $password, $host, $os );

	my $run_sql = \&{"run_sql_$database"};
	for my $sql_file (@main::sql_files)
	{
		&$run_sql( $user, $password, "$dir/sql/${database}/$sql_file", $host, $os );
	}

	set();
}

sub set
{
	my $database = $options{db};
	print "Setting database property to $database.\n";

	my $dir = $options{dir} || '.';
	mkdir "$dir/osgi-config/database";

	open( PROP, ">$dir/osgi-config/database/db.properties" );
	print PROP "database=$database\n";
	close(PROP);
}

####################################################
# Run the most recent migration script for the
# specified database.
#
sub migrate
{
    my $database = $options{db} || 'derby';
	my $host     = $options{host};
	my $user     = $options{user};
	my $password = $options{pass} || '';
	my $dir      = $options{dir} || '.';
	my $os 	     = $^O;

    my @files = sort(glob("$dir/migration/*.$database.sql"));
    my $sql_file = pop(@files);

    unless ($sql_file)
    {
        die("Could not find a migration file for $database.");
    }

    my $run_sql = \&{"run_sql_$database"};
    &$run_sql( $user, $password, $sql_file, $host, $os );
}

####################################################
# Reset the Derby database
#
sub reset_derby()
{
	my ( $user, $password ) = @_;

	print "Resetting Derby database.\n";

	my $host = $options{host};
	if ( !$host )
	{
		use Config;

		print "Host OS is " . $Config::Config{'osname'} . "\n";
		my $dir = $options{dir} || '.';
		if ( $Config::Config{'osname'} =~ /(?<!dar)win/i )
		{
			system("del /s $dir/derby");
		}
		else
		{
			system("rm -rf $dir/derby");
		}
	}
}

####################################################
# Reset the MySQL database
#
sub reset_mysql()
{
	my ( $user, $password, $host, $os ) = @_;

	print "Resetting MySQL database.\n";

	$host = "localhost" unless $host;
	$user = 'root' unless $user;
	my $cmd = "mysql -h $host -u $user";
	if ($password)
	{
		if ( $os == "linux" )
		{
			$cmd .= " -p$password";
		} else {
			$cmd .= " -p $password";
		}
	}

	my $pid = open( WRITEME, "| $cmd" );
	print WRITEME "DROP DATABASE IF EXISTS ziptie; CREATE DATABASE ziptie DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;";
	close(WRITEME);
}

####################################################
# Reset the PostgreSQL database
#
sub reset_pgsql()
{
	my ( $user, $password ) = @_;

	print "Resetting PostgreSQL database.\n";

	$user = 'postgres' unless $user;
	my $cmd = "psql -U $user -d postgres -a ";
	$cmd .= '-h ' . $options{host} if $options{host};
	$cmd .= '-p ' . $options{port} if $options{port};
	$cmd .= '-c ';
	system( $cmd . '"DROP DATABASE ziptie"' );
	system( $cmd . '"CREATE DATABASE ziptie ENCODING=\'UTF8\'"' );
}

####################################################
# Execute a SQL file in Derby
#
sub run_sql_derby
{
	my ( $user, $password, $sql_file ) = @_;

	print "Processing $sql_file.\n";

	my $dir  = $options{dir} || '.';
	my $host = $options{host};

	$user = 'APP' unless $user;

	my $java_opts = "-Dderby.system.home=$dir/derby";
	if ($host)
	{
		$java_opts .= " -Djdbc.drivers=org.apache.derby.jdbc.ClientDriver";
	}
	else
	{
		$java_opts .= " -Djdbc.drivers=org.apache.derby.jdbc.EmbeddedDriver";
	}

	if ( $Config::Config{'osname'} =~ /(?<!dar)win/i )
	{
		$java_opts .= " -Dij.database=jdbc:derby:ziptie;create=true;user=$user;password=$password";
	}
	else
	{
		$java_opts .= " -Dij.database=jdbc:derby:ziptie\\;create=true\\;user=$user\\;password=$password";
	}

	my $cmd = "java -Duser.timezone=GMT+0 -cp \"$main::classpath\" $java_opts org.apache.derby.tools.ij $sql_file";

	print "$cmd\n";
	system($cmd);

	# my $pid = open(WRITEME, "| $cmd");
	# print WRITEME "DROP DATABASE ziptie; CREATE DATABASE ziptie;";
	# close(WRITEME);
}

####################################################
# Execute a SQL file in MySQL
#
sub run_sql_mysql()
{
	my ( $user, $password, $sql_file, $host, $os ) = @_;

	$user = "root" unless $user;
	$host = "localhost" unless $host;

	print "Processing $sql_file.\n";

	my $cmd = "mysql -h $host -u $user";
	if ($password)
        {
                if ( $os == "linux" )
                {
                        $cmd .= " -p$password";
                } else {
                        $cmd .= " -p $password";
                }
        }
	$cmd .= " ziptie";

	my $sql;
	{
		local ( $/, *SQL );
		open( SQL, "<$sql_file" ) or die "Unable to read file $sql_file\n";
		$sql = <SQL>;
		close SQL;
	}

	my $pid = open( WRITEME, "| $cmd" );
	print WRITEME $sql;
	close(WRITEME);
}

####################################################
# Execute a SQL file in PostgreSQL
#
sub run_sql_pgsql
{
	my ( $user, $password, $sql_file ) = @_;

	$user = 'postgres' unless $user;

	print "Processing $sql_file.\n";

	my $cmd = "psql -U $user -d ziptie ";
	$cmd .= '-q '                  if !$options{verbose};
	$cmd .= '-a '                  if $options{verbose};
	$cmd .= '-h ' . $options{host} if $options{host};
	$cmd .= '-p ' . $options{port} if $options{port};
	$cmd .= "-f $sql_file";
	system($cmd);
}

####################################################
# Create the classpath for Derby
#
sub create_classpath
{
	my $derby_jar       = find_jar("derby-10.3.2.1.jar");
	my $derbyclient_jar = find_jar("derbyclient.jar");
	my $derbytools_jar  = find_jar("derbytools.jar");

	# print "Derby: $derby_jar\n";
	# print "Derby client: $derbyclient_jar\n";
	# print "Derby tools: $derbytools_jar\n";

	# Store our OS name
	my $OS = $Config::Config{'osname'};

	my $classpath = "$derby_jar:$derbyclient_jar:$derbytools_jar";
	if ( $OS =~ /(?<!dar)win/i )
	{
		$classpath =~ s/:/;/g;
	}

	# print "Classpath: $classpath\n";

	return $classpath;
}

####################################################
# Find a jar
#
sub find_jar
{
	my ($jar) = @_;

	my $dir = $options{dir} || '.';
	my $it  = new File::Iterator(
		DIR     => "$dir/core",
		RECURSE => 1,
		FILTER  => sub { $_[0] =~ /$jar/ }
	);

	return $it->next();
}

sub print_usage
{
    print "ZipTie Database Utility - ^VERSION^\n\n";
	print "Usage: dbutil [options] <action>\n\n";
	print "Options:\n";
	print "  --db   database (one of: derby, mysql, pgsql)\n";
	print "  --user the user to connect to the database as (optional)\n";
	print "  --pass the password to connect to the database with (optional)\n";
	print "  --host the hostname of the database server (optional)\n";
	print "  --port the port number of the database server (optional)\n";
	print "  --dir  the ZipTie installation directory (optional)\n";

	print "\nActions:\n";
	print "   reset  reset ZipTie to it's original state\n";
	print "\n";

	exit(1);
}
