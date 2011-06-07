#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'i18n::Helper' ) || print "Bail out!
";
}

diag( "Testing i18n::Helper $i18n::Helper::VERSION, Perl $], $^X" );
