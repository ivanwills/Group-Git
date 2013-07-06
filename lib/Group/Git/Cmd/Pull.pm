package Group::Git::Cmd::Pull;

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

our $VERSION     = version->new('0.1.4');

requires 'repos';
requires 'verbose';

sub update { shift->pull($_[0], 'update') }
sub pull {
    my ($self, $name, $type) = @_;
    $type ||= 'pull';

    my $repo = $self->repos->{$name};
    my $cmd;
    my $dir;

    if ( !$repo->git ) {
        return;
    }
    elsif ( -d $name ) {
        $dir = $name;
        $cmd = join ' ', 'git', map { $self->shell_quote } $type, @ARGV;
    }
    else {
        $cmd = join ' ', 'git', 'clone', map { $self->shell_quote } $repo->git;
    }

    local $CWD = $dir if $dir;
    warn "$cmd\n" if $self->verbose > 1;
    return `$cmd`;
}

1;

__END__

=head1 NAME

Group::Git::Cmd::Pull - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Group::Git::Cmd::Pull version 0.1.4.


=head1 SYNOPSIS

   use Group::Git::Cmd::Pull;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=over 4

=item C<pull ()>

Runs git pull on all repositories, if a repository doesn't exist on disk this
will clone that repository.

=item C<update ()>

Runs git update on all repositories, if a repository doesn't exist on disk this
will clone that repository.

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
