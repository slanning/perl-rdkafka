use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pkg = 'RdKafka';

my (@errors, @inc, @libs);

# librdkafka-devel.x86_64
# gcc.x86_64

# I don't know how to do this library-finding stuff properly...

# I'm not sure which version actually works,
# just this is the one I had
$ENV{PKG_CONFIG_PATH} .= '/usr/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/share/pkgconfig';    # ?
my $pc_pkg = 'rdkafka';
@errors = check_pkg_config($pc_pkg, '0.9.1');
if (@errors) {
    warn("Trouble using pkg-config (guessing include and libs paths):\n" . join('', map { "$_$/" } @errors));

    push @inc,  '/usr/local/include';   # ?
    push @libs, '-lrdkafka -lz -lpthread -lrt';
}
else {
    push @inc,  pkg_config($pc_pkg, 'cflags');
    push @libs, pkg_config($pc_pkg, 'libs');
}
print "INC : @inc\nLIBS: @libs\n";

WriteMakefile(
    NAME => $pkg,
    VERSION_FROM => "$pkg.pm",
    ABSTRACT_FROM => "$pkg.pm",
    AUTHOR => 'Scott Lanning <slanning@cpan.org>',
    MAN3PODS => {},
    META_MERGE => {
        no_index => {
            directory => [ qw/t examples/ ],
        },
    },
    INC  => join(' ', @inc),
    LIBS => join(' ', @libs),

    # why do I have to add this to suppress the `make` warning
    # when it's already the default?
    XSPROTOARG => '-noprototypes',
);

###

sub check_pkg_config {
    my ($pkg, $required_version) = @_;

    my $pc = 'pkg-config';
    my @errors = ();

    # Check that pkg-config is installed
    my $pcver = `$pc --version`;
    if ($pcver eq '') {
        push @errors, "$pc not found";
    }
    else {
        # Check that pkg-config knows about the package
        my $pkgexists = `$pc --exists $pkg`;
        if ($?) {
            push @errors, "Package $pkg not found by $pc";
        }
        else {
            # Check that the package is the right version
            my $pkgver = `$pc --atleast-version='$required_version' $pkg`;
            if ($?) {
                push @errors, "Package $pkg is not the right version (at least $required_version)";
            }
        }
    }

    return @errors;
}

sub pkg_config {
    my ($pkg, $option) = @_;

    my $str = `pkg-config --$option $pkg`;
    if ($?) {
        die "pkg-config --$option $pkg: $str\n";
    }
    else {
        chomp $str;
        return $str;
    }
}
