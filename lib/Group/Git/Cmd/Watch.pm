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
        }
    },
    [
        'show|s',
        'all|a',
        'config|c=s',
    ]
);

sub watch {
    my ($self, $name) = @_;
    return unless -d $name;

    $self->runs(1);

    my $repo = $self->repos->{$name};
    if ( !%{ $opt->opt || {} } ) {
        $opt->process;
        $config = -f $opt->opt->config ? LoadFile($opt->opt->config) : {};
    }

    my $dump;
    {
        local $CWD = $name;
        my ($id, $out);

        if ($opt->opt->all) {
            ($out) = `git reflot --all`;
            ($id) = $out =~ /^([0-9a-f]+)\s/;
        }
        else {
            ($out) = `git show`;
            ($id) = $out =~ /commit\s+([0-9a-f]+)/
        }

        if (!$config->{$name} || $config->{$name} ne $id) {
            $config->{$name} = $id;
            $dump = 1;

            warn Dumper $opt->opt, \@ARGV, $config;
            return $name if $opt->opt->show;

            system @ARGV;
        }
    }

    if ($dump) {
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

   use Group::Git::Cmd::Watch;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


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
