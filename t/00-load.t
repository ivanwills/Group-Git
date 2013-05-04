#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'Group::Git' );
}

diag( "Testing Group::Git $Group::Git::VERSION, Perl $], $^X" );
