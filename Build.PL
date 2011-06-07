use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'i18n::Helper',
    license             => 'perl',
    dist_author         => q{Andre Santos <andrefs@cpan.org>},
    dist_version_from   => 'lib/i18n/Helper.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'i18n-Helper-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
