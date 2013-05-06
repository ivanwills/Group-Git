package Group::Git;

# Created on: 2013-05-04 16:16:56
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Path::Class;
use File::chdir;
use Group::Git::Repo;

our $VERSION     = version->new('0.0.1');
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
has verbose => (
    is  => 'rw',
    isa => 'Int',
);
has test => (
    is  => 'rw',
    isa => 'Boolean',
);

# load all roles in the namespace Group::Git::Cmd::*
my %modules;
for my $dir (@INC) {
    next if !-d "$dir/Group/Git/Cmd";
    my @commands = glob "$dir/Group/Git/Cmd/*.pm";

    for my $command (@commands) {
        my $module = $command;
        $module =~ s{$dir/}{};
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

    for my $config (map {file $_} glob('*/.git/config')) {
        my ($url) = grep {/^\s*url\s*=\s*/} $config->slurp;
        chomp $url;
        $url =~ s/^\s*url\s*=\s*//;

        $repos{ $config->parent->parent->basename } = Group::Git::Repo->new(
            name => $config->parent->parent->basename,
            url  => $url,
        );
    }

    return \%repos;
}

sub cmd {
    my ($self, $command) = @_;

    for my $project ( keys %{ $self->repos } ) {
        next if !-d $project;
        print "\n$project\n" if $self->verbose;
        local $CWD = $project;
        system 'git', $command, @ARGV;
    }
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

    return $self->cmd($method);
}

1;

__END__

=head1 NAME

Group::Git - Base module for group of git repository opperations.

=head1 VERSION

This documentation refers to Group::Git version 0.1.

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
finding repositories (eg L<Group::Git::Github>, L<Group::Git::Bitbucket> and
L<Group::Git::Gitosis>)

=head1 SUBROUTINES/METHODS

=over 4

=item C<cmd ($name)>

Run the git command C<$name> for each repository.

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
