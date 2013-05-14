package Group::Git::Github;

# Created on: 2013-05-04 20:18:31
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Net::GitHub;

our $VERSION     = version->new('0.0.2');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

extends 'Group::Git';

has github => (
    is      => 'rw',
    #isa     => 'Net::GitHub',
    builder => '_github',
    lazy    => 1,
);

sub _repos {
    my ($self) = @_;
    my %repos = %{ $self->SUPER::_repos() };

    for my $repo ( $self->github->repos->list ) {
        $repos{ $repo->{name} } = Group::Git::Repo->new(
            name => $repo->{name},
            git  => $repo->{git_url},
        );
    }

    return \%repos;
}

sub _github {
    my ($self) = @_;
    my $conf = $self->conf;

    return Net::GitHub->new(
        login => $conf->{username} ? $conf->{username} : prompt( -prompt => 'github.com username : ' ),
        pass  => $conf->{password} ? $conf->{password} : prompt( -prompt => 'github.com password : ', -echo => '*' ),
    );
}

1;

__END__

=head1 NAME

Group::Git::Github - Adds reading all repositories you have access to on github

=head1 VERSION

This documentation refers to Group::Git::Github version 0.0.2.


=head1 SYNOPSIS

   use Group::Git::Github;

   # pull (or clone missing) all repositories that joeblogs has created/forked
   Group::Git::Github->new(
       conf => {
           username => 'joeblogs@gmail.com',
           password => 'myverysecurepassword',
       },
   )->pull;

=head1 DESCRIPTION

Reads all repositories for the configured user (if none set user will be
prompted to enter one as well as a password)

=head1 SUBROUTINES/METHODS

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
