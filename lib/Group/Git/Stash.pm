package Group::Git::Stash;

# Created on: 2013-05-04 20:18:24
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use English qw/ -no_match_vars /;
use IO::Prompt qw/prompt/;
use JSON qw/decode_json/;
use WWW::Mechanize;
use Path::Class;

our $VERSION = version->new('0.4.0');

extends 'Group::Git';

has '+recurse' => (
    default => 1,
);

sub _httpenc {
    my ($str) = @_;
    $str =~ s/(\W)/sprintf "%%%x", ord $1/egxms;
    return $str;
}

sub _repos {
    my ($self) = @_;
    my %repos = %{ $self->SUPER::_repos() };

    my ($conf) = $self->conf;
    #EG curl --user buserbb:2934dfad https://stash.example.com/rest/api/1.0/repos

    my @argv = @ARGV;
    @ARGV = ();
    my $mech  = WWW::Mechanize->new;
    my $user  = _httpenc( $conf->{username} ? $conf->{username} : prompt( -prompt => 'stash username : ' ) );
    my $pass  = _httpenc( $conf->{password} ? $conf->{password} : prompt( -prompt => 'stash password : ', -echo => '*' ) );
    my $url   = "https://$user:$pass\@$conf->{stash_host}/rest/api/1.0/repos?limit=100&start=";
    my $start = 0;
    my $more  = 1;
    @ARGV = @argv;

    while ($more) {
        $mech->get( $url . $start++ );
        my $response = decode_json $mech->content;

        for my $repo (@{ $response->{values} }) {
            my $project = $repo->{project}{name};
            my $url     = $repo->{links}{self}[0]{href};
            my %clone   = map {($_->{name} => $_->{href})} @{ $repo->{links}{clone} };
            my $dir     = $self->recurse ? dir("$project/$repo->{name}") : dir($repo->{name});

            $repos{$dir} = Group::Git::Repo->new(
                name => $dir,
                url  => $url,
                git  => $conf->{clone_type} && $conf->{clone_type} eq 'http' ? $clone{http} : $clone{ssh},
            );
            push @{ $conf->{tags}{$project} }, "$dir";
        }
        $more = !$response->{isLastPage};
    }

    return \%repos;
}

1;

__END__

=head1 NAME

Group::Git::Stash - Adds reading all repositories you have access to on your local Stash server

=head1 VERSION

This documentation refers to Group::Git::Stash version 0.4.0.

=head1 SYNOPSIS

   use Group::Git::Stash;

   # pull (or clone missing) all repositories that joeblogs has created/forked
   my $ggs = Group::Git::Stash->new(
       conf => {
           username => 'joeblogs@example.com',
           password => 'myverysecurepassword',
       },
   );

   # list all repositories
   my $repositories = $ggs->repo();

   # do something to each repository
   for my $repo (keys %{$repositories}) {
       # eg do a pull
       $ggs->pull($repo);
   }

=head1 DESCRIPTION

Reads all repositories for the configured user (if none set user will be
prompted to enter one as well as a password)

=head1 SUBROUTINES/METHODS

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

When using with the C<group-git> command the group-git.yml can be used
to configure this plugin:

C<group-git.yml>

 ---
 type: Stash
 username: stash.user
 password: supperSecret
 stash_host: stash.example.com

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
