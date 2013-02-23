#!/usr/bin/env perl

use strict;
use warnings;

use ZipTie::Client;
use Term::ReadKey;
use Term::ShellUI;
use Data::Dumper;

&shell();

0;

########################################
# Login
#
sub login
{
	my $password = _read_password("Administrator password: ");

	our $client = ZipTie::Client->new(
		username => 'admin',
		password => $password,
		host     => 'localhost:8080',
	) || die "Could not connect.";

	# Verify connection
	$client->security()->getCurrentUser() || die "Could not connect.";

	return $client;
}

########################################
# Shell
#
sub shell
{
	print "ZipTie Administrative Shell - ^VERSION^\n";
	login();
	print "\n";

	my $term = new Term::ShellUI(
		commands     => get_commands(),
		history_file => undef,
	);

	$term->prompt( [ "[$::client->{host}]\$ ", '>' ] );
	$term->run();

	$::client->logout();
}

sub create_user
{
	my ($user) = shift(@_);

	print "Creating user $user\n" if $user;
	if ( !$user )
	{
		print "Username: ";
		$user = ReadLine;
		chomp($user);
	}

	print "Full name (optional): ";
	my $full_name = ReadLine;
	chomp($full_name);

	my $password = undef;
	while ( !$password )
	{
		$password = _read_password('Password: ');
	}

	my $password2 = "";
	while ( $password2 ne $password )
	{
		$password2 = _read_password('Password confirm: ');
		if ( $password2 ne $password )
		{
			print "Passwords do not match.\n";
		}
	}

	print "Email (optional): ";
	my $email = ReadLine;
	chomp($email);

	my $role;
	my @roles = list_roles('number');
	while (1)
	{
		print "Choose a role by number: ";
		$role = ReadLine;
		chomp($role);
		last if ( $role > 0 && $role - 1 < scalar(@roles) );
	}
	$role = $roles[ $role - 1 ]->{name};

	my $security = $::client->security();
	$security->createUser(
		username => $user,
		fullName => $full_name,
		email    => $email,
		password => $password,
		role     => $role
	);
}

sub modify_user
{
}

sub change_password
{
    my ($user) = shift(@_);

    unless ($user)
    {
        do
        {
            print "Username: ";
            $user = ReadLine;
            chomp($user);
        } while ( $user eq "" )
    }

    my $password = undef;
    while ( !$password )
    {
        $password = _read_password('New Password: ');
    }

    my $password2 = "";
    while ( $password2 ne $password )
    {
        $password2 = _read_password('Confirm New Password: ');
        if ( $password2 ne $password )
        {
            print "Passwords do not match.\n";
        }
    }

    my $security = $::client->security();
    $security->changePassword(
        username => $user,
        password => $password,
    );
}

sub delete_user
{
	my ($user) = shift(@_);

    if ($user)
    {
        print "Deleting user '$user'...\n";
	}
	else
	{
		do
		{
			print "Username: ";
			$user = ReadLine;
			chomp($user);
		} while ( $user eq "" )
	}

	print "Are you sure you want to delete user '$user' (y/n)? ";
	my $confirm = ReadLine;
	chomp($confirm);
	if ( $confirm eq "y" || $confirm eq "Y" )
	{
		my $security = $::client->security();
		$security->deleteUser( username => $user );
	}
}

sub create_role
{
	my ($role) = shift(@_);

	print "Creating role $role\n" if $role;
	if ( !$role )
	{
		print "Role name: ";
		$role = ReadLine;
		chomp($role);
	}

	my $security = $::client->security();
	my @role_perms;
	while (1)
	{
		print
		  "Type the numbers of the desired permissions separated by a space:\n";

		my @global_perms = $security->getAvailablePermissions();
		my %perm_hash    = ();
		my $i            = 1;
		foreach my $perm (@global_perms)
		{
			my ( $id, $desc ) = split( /=/, $perm );
			print "  $i) $desc\n";
			$perm_hash{$i} = $id;
			$i++;
		}

		@role_perms = ();
		print "\nPermissions to grant (eg. 3 5 6 11): ";
		my $perm_set = ReadLine;
		chomp($perm_set);

		# Validate
		my @desired_perm = split( ' ', $perm_set );
		foreach my $perm (@desired_perm)
		{
			if ( !$perm_hash{$perm} )
			{
				print "ERROR: Invalid permission specified.\n\n";
				next;
			}
			push( @role_perms, $perm_hash{$perm} );
		}
		last;
	}

	$security->createRole( role => $role, permissions => \@role_perms );
}

sub modify_role
{
}

sub delete_role
{
	my ($role) = shift(@_);

	print "Deleting role '$role'...\n" if $role;
	if ( !$role )
	{
		my @roles = list_roles('number');
		while (1)
		{
			print "Choose a role by number: ";
			$role = ReadLine;
			chomp($role);
			last if ( $role > 0 && $role - 1 < scalar(@roles) );
		}
		$role = $roles[ $role - 1 ]->{name};
	}

	print "Are you sure you want to delete role '$role' (y/n)? ";
	my $confirm = ReadLine;
	chomp($confirm);
	if ( $confirm eq "y" || $confirm eq "Y" )
	{
		my $security = $::client->security();
		$security->deleteRole( role => $role );
	}
}

sub list_roles
{
	my ($number) = shift(@_);
	my $security = $::client->security();

	print "Roles:\n";
	my @roles = $security->getAvailableRoles();
	my $i     = 1;
	foreach my $role (@roles)
	{
		if ( defined($number) && $number eq "number" )
		{
			print "  $i) $role->{name}\n";
			$i++;
		}
		else
		{
			print "  $role->{name}\n";
		}
	}

	return @roles;
}

sub list_users
{
	my $security = $::client->security();

	my @users = $security->listUsers();

	# print Data::Dumper->Dump([@users]);
	print "Users:\n";
	foreach my $user (@users)
	{
		print "  $user->{name}\n";
	}

	return @users;
}

sub show_user
{
	my ($user) = shift(@_);

	if ( !$user )
	{
		$user = '';
		while ( $user eq "" )
		{
			print "Username: " if !$user;
			$user = ReadLine if !$user;
			chomp($user);
		}
	}

	my $security = $::client->security();
	my $principal = $security->getUser( username => $user );
	if ($principal)
	{
		print "User Information:\n";
		print "  Username : $principal->{name}\n";
		print "  Full name: $principal->{fullName}\n";
		print "  Email    : $principal->{email}\n";
		print "  Role     : $principal->{role}->{name}\n";
	}
}

sub show_role
{
	my ($role) = shift(@_);

	if ( !$role )
	{
		my @roles = list_roles('number');
		while (1)
		{
			print "Choose a role by number: ";
			$role = ReadLine;
			chomp($role);
			last if ( $role > 0 && $role - 1 < scalar(@roles) );
		}
		$role = $roles[ $role - 1 ]->{name};
	}

	my $security     = $::client->security();
	my @global_perms = $security->getAvailablePermissions();
	my %perm_hash    = ();
	foreach my $perm (@global_perms)
	{
		my ( $id, $desc ) = split( /=/, $perm );
		$perm_hash{$id} = $desc;
	}

	my $zrole = $security->getRole( role => $role );
	if ($zrole)
	{
		print "Role Information:\n";
		print "  Role name: $zrole->{name}\n";
		my $perms = $zrole->{permissions};
		foreach my $perm (@$perms)
		{
			print "    $perm_hash{$perm}\n";
		}
	}
	else
	{
		print "No role with name '$role' is defined.\n";
	}
}

sub get_commands()
{
	return {

	   # Temporarily left as an example of a completion callback
	   #        "cd" => {
	   #            desc => "Change to directory DIR",
	   #            maxargs => 1, args => sub { shift->complete_onlydirs(@_); },
	   #            proc => sub { chdir($_[0] || $ENV{HOME} || $ENV{LOGDIR}); },
	   #        },
		"help" => {
			desc   => "Describe a command",
			args   => sub { shift->help_args( undef, @_ ); },
			method => sub { shift->help_call( undef, @_ ); }
		},
		"h"      => { alias => "help", exclude_from_completion => 1 },
		"?"      => { alias => "help", exclude_from_completion => 1 },
		"create" => {
			cmds => {
				"user" => {
					desc => 'Create a new ZipTie user.',
					proc => \&create_user,
				},
				"role" => {
					desc => 'Create a new ZipTie security role.',
					proc => \&create_role,
				},
			},
			desc => 'Create a user or role.',
		},
		"modify" => {
            cmds => {
                "password" => {
                    desc => "Change a user's password.",
                    proc => \&change_password,
                },
                "user" => {
                    desc => 'Modify an existing ZipTie user. (not yet implemented)',
                    proc => \&modify_user,
                },
                "role" => {
                    desc => 'Modify an existing ZipTie security role. (not yet implemented)',
                    proc => \&modify_role,
                },
            },
            desc => 'Modify a user or role.',
		},
		"delete" => {
			cmds => {
				"user" => {
					desc => 'Delete a ZipTie user.',
					proc => \&delete_user,
				},
				"role" => {
					desc => 'Delete a user-defined ZipTie role.',
					proc => \&delete_role,
				},
			},
			desc => 'Delete a user or role.',
		},
		"list" => {
			desc => "List information for various types.",
			cmds => {
				"users" => {
					desc => 'List users defined in ZipTie.',
					proc => \&list_users,
				},
				"roles" => {
					desc => 'List roles defined in ZipTie.',
					proc => \&list_roles,
				}
			},
		},
		"show" => {
			cmds => {
				"user" => {
					desc => 'Show detailed information for a user.',
					proc => \&show_user,
				},
				"role" => {
					desc => 'Show detailed information for a role.',
					proc => \&show_role,
				},
			},
			desc => "Show detailed information on a specific user or role.",
		},
		"exit" => { alias => 'quit' },
		"quit" => {
			desc    => 'Quit this program',
			maxargs => 0,
			method  => sub { shift->exit_requested(1); },
		}
	};
}

sub _read_password
{
	my $prompt = shift;
	print $prompt;
	ReadMode 'noecho';
	my $input = ReadLine;
	chomp $input;
	ReadMode 'normal';
	print "\n";
	return $input;
}
