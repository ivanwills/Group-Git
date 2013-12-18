package Group::Git::Gitosis;

# Created on: 2013-05-04 20:18:43
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
use Path::Class;

our $VERSION     = version->new('0.2.0');

extends 'Group::Git';

sub _repos {
    my ($self) = @_;

    if ( -d '.gitosis' ) {
        local $CWD = '.gitosis';
        system 'git', 'pull';
    }
    else {
        system 'git', 'clone', $self->conf->{gitosis}, '.gitosis';
    }

    my $data = Config::Any->load_files({
        files         => ['.gitosis/gitosis.conf'],
        use_ext       => 0,
        force_plugins => ['Config::Any::INI'],
    });
    $data = {
        map {
            %$_
        }
        map {
            values %$_
        }
        @{$data}
    };

    my $base = $self->conf->{gitosis};
    $base =~ s{([:/]).*?$}{$1};

    my %repos = %{ $self->SUPER::_repos() };
    for my $group ( keys %$data ) {
        for my $sub_group ( keys %{ $data->{$group} } ) {
            for my $type (qw/readonly writable/) {
                next if !$data->{$group}{$sub_group}{$type};

                for my $name ( split /\s+/, $data->{$group}{$sub_group}{$type} ) {
                    $repos{$name} = Group::Git::Repo->new(
                        name => dir($name),
                        git  => "$base$name.git",
                    );
                }
            }
        }
    }

    return \%repos;
}

1;

__END__

=head1 NAME

Group::Git::Gitosis - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Group::Git::Gitosis version 0.2.0.


=head1 SYNOPSIS

   use Group::Git::Gitosis;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

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
