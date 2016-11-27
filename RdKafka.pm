package RdKafka;
use strict;
use warnings;
use Carp;

use XSLoader ();

our $VERSION = '0.01';

XSLoader::load(__PACKAGE__, $VERSION);

# basically copy-pasted from IO
sub import {
    shift;
    my @subclasses = @_ ? @_ : qw/  /;
    eval join("", map { "require " . __PACKAGE__ . "::$_;" } @subclasses)
      or croak($@);
}

1;
__END__

=head1 NAME

RdKafka - Perl bindings for librdkafka C library

=head1 SYNOPSIS

  use RdKafka;
  # ...

=head1 DESCRIPTION

Perl bindings for librdkafka C library from
https://github.com/edenhill/librdkafka

=head1 SEE ALSO

https://metacpan.org/pod/Kafka has a pure Perl library.

=head1 AUTHOR

Scott Lanning E<lt>slanning@cpan.orgE<gt>

For licensing info, see F<README.txt>.

=cut
