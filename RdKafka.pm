package RdKafka;

require Exporter;
push @{ __PACKAGE__ . '::ISA' }, qw/Exporter/;   # no strict 'refs'

use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

use XSLoader ();

XSLoader::load(__PACKAGE__, $VERSION);

# basically copy-pasted from IO
sub import {
    shift;
    my @subclasses = @_ ? @_ : qw//;
    eval(join("", map { "require " . __PACKAGE__ . "::$_;" } @subclasses) . "1;")
      or croak($@);
}

our %EXPORT_TAGS = (
    producer => [qw/
        RD_KAFKA_MSG_F_FREE
        RD_KAFKA_MSG_F_COPY
        RD_KAFKA_MSG_F_BLOCK
    /],
    event => [qw/
        RD_KAFKA_EVENT_NONE
        RD_KAFKA_EVENT_DR
        RD_KAFKA_EVENT_FETCH
        RD_KAFKA_EVENT_LOG
        RD_KAFKA_EVENT_ERROR
        RD_KAFKA_EVENT_REBALANCE
        RD_KAFKA_EVENT_OFFSET_COMMIT
    /],
);
$EXPORT_TAGS{'all'} = [
    'RD_KAFKA_PARTITION_UA',
    map { @{ $EXPORT_TAGS{$_} } } keys %EXPORT_TAGS
];
our @EXPORT_OK = @{ $EXPORT_TAGS{'all'} };
our @EXPORT = ();

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
