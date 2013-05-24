#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use_ok('Group::Git');
use_ok('Group::Git::Bitbucket');
use_ok('Group::Git::Github');
use_ok('Group::Git::Gitosis');
use_ok('Group::Git::Repo');
use_ok('Group::Git::Cmd::Branch');
use_ok('Group::Git::Cmd::Pull');


diag( "Testing Group::Git $Group::Git::VERSION, Perl $], $^X" );
done_testing();
