package Group::Git::Repo;

# Created on: 2013-05-05 19:07:36
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;

our $VERSION = version->new('0.4.2');

extends 'Group::Git';

has name => (
    is  => 'rw',
    isa => 'Path::Class::Dir',
);
has url => (
    is  => 'rw',
    isa => 'Str',
);
has git => (
    is  => 'rw',
    isa => 'Str',
);

1;

__END__

=head1 NAME

Group::Git::Repo - Git repository details object.

=head1 VERSION

This documentation refers to Group::Git::Repo version 0.4.2.


=head1 SYNOPSIS

   use Group::Git::Repo;

   # create a new repository object
   my $ggr = Group::Git::Repo->new(
       name => 'some-repo',
       url  => 'http://example.com/some-repo/',
       git  => 'git@example.com/some-repo.git',
   );

=head1 DESCRIPTION

C<Group::Git::Repo> stores the basic information about a git repository for
other L<Group::Git> modules to use. It does nothing by it's self.

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
