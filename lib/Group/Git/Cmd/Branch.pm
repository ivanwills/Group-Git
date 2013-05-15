package Group::Git::Cmd::Branch;

# Created on: 2013-05-06 21:57:14
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

our $VERSION     = version->new('0.0.2');

requires 'repos';
requires 'verbose';
requires 'test';

sub branch {
    my ($self, $name) = @_;
    return unless -d $name;

    my $repo = $self->repos->{$name};

    local $CWD = $name;
    my $cmd = "git branch -a";
    $cmd .= " | grep " . join ' ', @ARGV if @ARGV;
    print  "$cmd\n" if $self->verbose || $self->test;
    if ( !$self->test ) {
        if ( @ARGV ) {
            my $out = `$cmd`;
            if ( $out !~ /^\s*$/xms ) {
                print "$name\n$out";
            }
        }
        else {
            print "$name\n";
            system $cmd if !$self->test;
        }
    }

    return;
}

1;

__END__

=head1 NAME

Group::Git::Cmd::Branch - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Group::Git::Cmd::Branch version 0.0.2.


=head1 SYNOPSIS

   use Group::Git::Cmd::Branch;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=over 4

=item C<branch ()>

Runs a git branch -a over each repository and if other arguments are supplied
the branch is pipped through grep with the other arguments

 eg $ group-git branch feature

will return each repository that has that C<feature> branch

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
