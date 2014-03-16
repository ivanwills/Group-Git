use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Group::Git',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/Group/Git.pm',
    requires          => {
        'perl'             => '5.006',
        'Config::Any'      => 0,
        'File::chdir'      => 0,
        'Getopt::Alt'      => '0.1.1',
        'IO::Prompt'       => 0,
        'JSON'             => 0,
        'Moose'            => 0,
        'Moose::Role'      => 0,
        'Net::GitHub'      => '0.57',
        'Path::Class'      => 0,
        'Term::ANSIColor'  => 0,
        'WWW::Mechanize'   => 0,
        'version'          => 0,
    },
    configure_requires => {
        'Module::Build' => 0.38,
    },
    build_requires => {
        'Test::More'       => 0,
        'Test::NoWarnings' => 0,
    },
    add_to_cleanup     => [ 'Group-Git-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge => {
        resources => {
            repository => 'git://github.com/ivanwills/Group-Git.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Group::Git',
        },
    },
);

$builder->create_build_script();
