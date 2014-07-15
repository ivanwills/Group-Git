package Group::Git::Cmd::Watch;

# Created on: 2013-05-06 21:57:07
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose::Role;
use version;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use File::chdir;
use Getopt::Alt;
use YAML::Syck qw/LoadFile DumpFile/;

our $VERSION = version->new('0.2.1');

requires 'repos';
requires 'verbose';

my $config;
my $opt = Getopt::Alt->new(
    {
        help   => __PACKAGE__,
        default => {
            config => 'group-git-watch.yml',
            sleep  => 60,
        }
    },
    [
        'show|w',
        'once|o',
        'sleep|s=i',
        'save|v',
        'all|a',
        'config|c=s',
    ]
);

has watch_run => (
    is  => 'rw',
    isa => 'Bool',
);

sub watch {
    my ($self, $name) = @_;
    return unless -d $name;

    if ( !$self->runs ) {
        $self->runs(2);

        if ($self->warch_run) {
            system @ARGV;
            $self->warch_run(undef);
        }

        sleep $opt->opt->sleep if $self->runs == 1;
    }

    my $repo = $self->repos->{$name};
    if ( !%{ $opt->opt || {} } ) {
        $opt->process;
        $config = $opt->opt->save && -f $opt->opt->config ? LoadFile($opt->opt->config) : {};
    }

    my $dump;
    {
        local $CWD = $name;
        my ($id, $out);
        `git fetch`;

        if ($opt->opt->all) {
            ($out) = `git reflog --all`;
            ($id) = $out =~ /^([0-9a-f]+)\s/;
        }
        else {
            ($out) = `git show`;
            ($id) = $out =~ /commit\s+([0-9a-f]+)/
        }

        if (!$config->{$name} || $config->{$name} ne $id) {
            $config->{$name} = $id;
            $dump = 1;

            return "changed" if $opt->opt->show;

            if ($opt->opt->once) {
                $self->warch_run(1);
            }
            else {
                system @ARGV;
            }
        }
    }

    if ($dump && $opt->opt->save) {
        DumpFile($opt->opt->config, $config);
    }

    return;
}

sub watch_end {
    return "Do you have any repositories?\n";
}

1;

__END__

=head1 NAME

Group::Git::Cmd::Watch - watch for changes in repositories and run a command

=head1 VERSION

This documentation refers to Group::Git::Cmd::Watch version 0.2.1.


=head1 SYNOPSIS

    group-git watch [options] ([--show|-w]|command)

 Options:
    -w --show   Show when a repository has changed
    -o --once   Run the command only once for each itteration through all
                repositories when one or more repositories change.
    -s --sleep[=]seconds
                Sleep for this number of seconds between each checking if
                the repositories have changed (Default 60)
    -v --save   Store the state of each repository so if re-run the program
                changes since the last run are shown.
    -a --all    Check all branches (not just the current branch) for changes
    -c --config[=]file
                Use inconjunction with --save to name the file to save to
                (Default group-git-watch.yml)

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=over 4

=item C<watch ($name)>

Runs git watch on each directory if the watch message includes:

 "nothing to commit"

The watch is suppressed to keep the output clean. This can be overridden
if verbose is set.

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
