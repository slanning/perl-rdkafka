use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pkg = 'RdKafka';

WriteMakefile(
    NAME => $pkg,
    VERSION_FROM => "$pkg.pm",
    AUTHOR => 'Scott Lanning <slanning@cpan.org>',
    META_MERGE => {
        no_index => {
            directory => [ qw/t examples/ ],
        },
    },
);
