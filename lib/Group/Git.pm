package Group::Git;

# Created on: 2013-05-04 16:16:56
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Path::Class;
use File::chdir;
use Group::Git::Repo;

our $VERSION = version->new('0.3.2');
our $AUTOLOAD;

has conf => (
    is  => 'rw',
    isa => 'HashRef',
);
has repos => (
    is          => 'rw',
    isa         => 'HashRef[Group::Git::Repo]',
    builder     => '_repos',
    lazy_build => 1,
);
has recurse => (
    is  => 'rw',
    isa => 'Bool',
);
has verbose => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
has test => (
    is  => 'rw',
    isa => 'Bool',
);
has runs => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

# load all roles in the namespace Group::Git::Cmd::*
my %modules;
for my $dir (@INC) {
    next if !-d "$dir/Group/Git/Cmd";
    local $CWD = $dir;
    my @commands = glob "Group/Git/Cmd/*.pm";

    for my $command (@commands) {
        my $module = $command;
        $module =~ s{/}{::}g;
        $module =~ s{[.]pm$}{};
        if ( !$modules{$module}++ ) {
            require $command;
            with $module;
        }
    }
}

sub _repos {
    my ($self) = @_;
    my %repos;
    my @files = dir('.')->children;

    while ( my $file = shift @files ) {
        next unless -d $file;
        my $config = $file->file('.git', 'config');

        if ( !-f $config ) {
            push @files, $file->children if $self->recurse && $file->basename ne '.git';
            next;
        }

        my ($url) = grep {/^\s*url\s*=\s*/} $config->slurp;
        if ($url) {
            chomp $url;
            $url =~ s/^\s*url\s*=\s*//;
        }
        else {
            $url = '';
        }

        $repos{$file} = Group::Git::Repo->new(
            name => $file,
            git  => $url,
        );
    }

    return \%repos;
}

sub cmd {
    my ($self, $command, $project) = @_;
    return if !$project || !-d $project;

    local $CWD = $project;
    local @ARGV = @ARGV;
    my $cmd = join ' ', 'git', map { $self->shell_quote } $command, @ARGV;

    return `$cmd`;
}

sub shell_quote {
    s{ ( [^\w\-./?*] ) }{\\$1}gxms;
    return $_;
}

sub AUTOLOAD {

    # ignore the method if it is the DESTROY method
    return if $AUTOLOAD =~ /DESTROY$/;

    # make sure that this is being called as a method
    croak( "AUTOLOAD(): This function is not being called by a ref: $AUTOLOAD( ".join (', ', @_)." )\n" ) unless ref $_[0];

    # get the object
    my $self = shift;

    # get the function name sans package name
    my ($method) = $AUTOLOAD =~ /::([^:]+)$/;

    return $self->cmd($method, @_);
}

1;

__END__

=head1 NAME

Group::Git - Base module for group of git repository operations.

=head1 VERSION

This documentation refers to Group::Git version 0.3.2.

=head1 SYNOPSIS

   use Group::Git;

   my $group = Group::Git->new( conf => {...} );

   # pull remote versions for all repositories
   $group->pull();

   # any other arbitary command
   $group->log;

=head1 DESCRIPTION

This is the base module it will try to use all roles in the C<Group::Git::Cmd::*>
namespace. This allows the creation of new command by just putting a role in that
namespace. Classes may extend this class to implement their own methods for
finding repositories (eg L<Group::Git::Github>, L<Group::Git::Bitbucket>,
L<Group::Git::Gitosis> and L<Group::Git::Stash>)

=head2 Group-Git vs Git Submodule

It has been pointed out that something similar could be achieved using the git
submodule command so here are some reasons for using C<Group-Git>:

=over 4

=item *

No git repository needed to manage all the repositories in fact no configuration
is required at all.

=item *

Group-Git just cares about repositories not their commits as submodule does.

=item *

When using one of github.com / bitbucket.com or gitosis configurations when
new repositories are added the next C<group-git pull> will get those new
repositories.

=item *

You can add your own commands to C<group-git> currently via perl modules but
in the future in the same fashion as C<git> does (eg adding a program called
C<group-git-command> somewhere on your path will result in you being able to
run C<group-git command>)

=back

=head1 SUBROUTINES/METHODS

=over 4

=item C<cmd ($name)>

Run the git command C<$name> for each repository.

=item C<shell_quote ()>

Returns the shell quoted string for $_

=back

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
