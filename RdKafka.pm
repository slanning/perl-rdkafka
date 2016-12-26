package RdKafka;

require Exporter;
push @{ __PACKAGE__ . '::ISA' }, qw/Exporter/;   # no strict 'refs'

use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

our $DEFAULT_ERRSTR_SIZE = 512;

use XSLoader ();

XSLoader::load(__PACKAGE__, $VERSION);

require RdKafka::Topic;
require RdKafka::TopicPartitionList;

our %EXPORT_TAGS = (
    consumer => [qw/
        RD_KAFKA_OFFSET_BEGINNING
        RD_KAFKA_OFFSET_END
        RD_KAFKA_OFFSET_STORED
        RD_KAFKA_OFFSET_INVALID
    /],
    producer => [qw/
        RD_KAFKA_MSG_F_FREE
        RD_KAFKA_MSG_F_COPY
    /],
    enums => [
        # rd_kafka_resp_err_t
        qw/
        RD_KAFKA_RESP_ERR__BEGIN
        RD_KAFKA_RESP_ERR__BAD_MSG
        RD_KAFKA_RESP_ERR__BAD_COMPRESSION
        RD_KAFKA_RESP_ERR__DESTROY
        RD_KAFKA_RESP_ERR__FAIL
        RD_KAFKA_RESP_ERR__TRANSPORT
        RD_KAFKA_RESP_ERR__CRIT_SYS_RESOURCE
        RD_KAFKA_RESP_ERR__RESOLVE
        RD_KAFKA_RESP_ERR__MSG_TIMED_OUT
        RD_KAFKA_RESP_ERR__PARTITION_EOF
        RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION
        RD_KAFKA_RESP_ERR__FS
        RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC
        RD_KAFKA_RESP_ERR__ALL_BROKERS_DOWN
        RD_KAFKA_RESP_ERR__INVALID_ARG
        RD_KAFKA_RESP_ERR__TIMED_OUT
        RD_KAFKA_RESP_ERR__QUEUE_FULL
        RD_KAFKA_RESP_ERR__ISR_INSUFF
        RD_KAFKA_RESP_ERR__NODE_UPDATE
        RD_KAFKA_RESP_ERR__SSL
        RD_KAFKA_RESP_ERR__WAIT_COORD
        RD_KAFKA_RESP_ERR__UNKNOWN_GROUP
        RD_KAFKA_RESP_ERR__IN_PROGRESS
        RD_KAFKA_RESP_ERR__PREV_IN_PROGRESS
        RD_KAFKA_RESP_ERR__EXISTING_SUBSCRIPTION
        RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS
        RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS
        RD_KAFKA_RESP_ERR__CONFLICT
        RD_KAFKA_RESP_ERR__STATE
        RD_KAFKA_RESP_ERR__UNKNOWN_PROTOCOL
        RD_KAFKA_RESP_ERR__NOT_IMPLEMENTED
        RD_KAFKA_RESP_ERR__AUTHENTICATION
        RD_KAFKA_RESP_ERR__NO_OFFSET
        RD_KAFKA_RESP_ERR__OUTDATED
        RD_KAFKA_RESP_ERR__END
        RD_KAFKA_RESP_ERR_UNKNOWN
        RD_KAFKA_RESP_ERR_NO_ERROR
        RD_KAFKA_RESP_ERR_OFFSET_OUT_OF_RANGE
        RD_KAFKA_RESP_ERR_INVALID_MSG
        RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC_OR_PART
        RD_KAFKA_RESP_ERR_INVALID_MSG_SIZE
        RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE
        RD_KAFKA_RESP_ERR_NOT_LEADER_FOR_PARTITION
        RD_KAFKA_RESP_ERR_REQUEST_TIMED_OUT
        RD_KAFKA_RESP_ERR_BROKER_NOT_AVAILABLE
        RD_KAFKA_RESP_ERR_REPLICA_NOT_AVAILABLE
        RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE
        RD_KAFKA_RESP_ERR_STALE_CTRL_EPOCH
        RD_KAFKA_RESP_ERR_OFFSET_METADATA_TOO_LARGE
        RD_KAFKA_RESP_ERR_NETWORK_EXCEPTION
        RD_KAFKA_RESP_ERR_GROUP_LOAD_IN_PROGRESS
        RD_KAFKA_RESP_ERR_GROUP_COORDINATOR_NOT_AVAILABLE
        RD_KAFKA_RESP_ERR_NOT_COORDINATOR_FOR_GROUP
        RD_KAFKA_RESP_ERR_TOPIC_EXCEPTION
        RD_KAFKA_RESP_ERR_RECORD_LIST_TOO_LARGE
        RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS
        RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS_AFTER_APPEND
        RD_KAFKA_RESP_ERR_INVALID_REQUIRED_ACKS
        RD_KAFKA_RESP_ERR_ILLEGAL_GENERATION
        RD_KAFKA_RESP_ERR_INCONSISTENT_GROUP_PROTOCOL
        RD_KAFKA_RESP_ERR_INVALID_GROUP_ID
        RD_KAFKA_RESP_ERR_UNKNOWN_MEMBER_ID
        RD_KAFKA_RESP_ERR_INVALID_SESSION_TIMEOUT
        RD_KAFKA_RESP_ERR_REBALANCE_IN_PROGRESS
        RD_KAFKA_RESP_ERR_INVALID_COMMIT_OFFSET_SIZE
        RD_KAFKA_RESP_ERR_TOPIC_AUTHORIZATION_FAILED
        RD_KAFKA_RESP_ERR_GROUP_AUTHORIZATION_FAILED
        RD_KAFKA_RESP_ERR_CLUSTER_AUTHORIZATION_FAILED
        RD_KAFKA_RESP_ERR_INVALID_TIMESTAMP
        RD_KAFKA_RESP_ERR_UNSUPPORTED_SASL_MECHANISM
        RD_KAFKA_RESP_ERR_ILLEGAL_SASL_STATE
        RD_KAFKA_RESP_ERR_UNSUPPORTED_VERSION
        RD_KAFKA_RESP_ERR_END_ALL
          /,
        # rd_kafka_type_t
        qw/
        RD_KAFKA_PRODUCER
        RD_KAFKA_CONSUMER
          /,
        # rd_kafka_conf_res_type_t
        qw/
        RD_KAFKA_CONF_UNKNOWN
        RD_KAFKA_CONF_INVALID
        RD_KAFKA_CONF_OK
          /,
    ],
    # I also saw in the source: LOG_PID LOG_CONS
    # but I think they aren't needed from Perl
    syslog => [qw/
        LOG_EMERG
        LOG_ALERT
        LOG_CRIT
        LOG_ERR
        LOG_WARNING
        LOG_NOTICE
        LOG_INFO
        LOG_DEBUG
    /],
);

if (RdKafka::version() >= 0x000902ff) {
    push @{ $EXPORT_TAGS{producer} }, qw/RD_KAFKA_MSG_F_BLOCK/;

    push @{ $EXPORT_TAGS{enums} }, qw/RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE/;

    $EXPORT_TAGS{event} = [qw/
        RD_KAFKA_EVENT_NONE
        RD_KAFKA_EVENT_DR
        RD_KAFKA_EVENT_FETCH
        RD_KAFKA_EVENT_LOG
        RD_KAFKA_EVENT_ERROR
        RD_KAFKA_EVENT_REBALANCE
        RD_KAFKA_EVENT_OFFSET_COMMIT
    /];
}


$EXPORT_TAGS{'all'} = [
    'RD_KAFKA_PARTITION_UA',
    map { @{ $EXPORT_TAGS{$_} } } keys %EXPORT_TAGS
];
our @EXPORT_OK = @{ $EXPORT_TAGS{'all'} };
our @EXPORT = ();


sub new {
    my ($class, $type, $conf) = @_;
    $conf ||= RdKafka::Conf->new();

    my $rk = new_xs($type, $conf);
    return($rk);
}

sub query_watermark_offsets {
    my ($self, $topic, $partition, $timeout_ms) = @_;
    my ($low, $high);
    my $err = $self->query_watermark_offsets_xs($topic, $partition, $low, $high, $timeout_ms);

    # I don't know what a good interface would be...
    return($err, $low, $high);
}

sub get_watermark_offsets {
    my ($self, $topic, $partition) = @_;
    my ($low, $high);
    my $err = $self->get_watermark_offsets_xs($topic, $partition, $low, $high);

    # I don't know what a good interface would be...
    return($err, $low, $high);
}

#sub subscription {
#    my ($self) = @_;
#    my $topparlist;
#    my $err = $self->subscription_xs($topparlist);
#    return($err, $topparlist);
#}

# convenience function used by rd_kafka_dump
# (thanks to Ævar Arnfjörð Bjarmason for the idea)
sub rd_kafka_dump_print_fh {
    my ($fh, $str) = @_;
    printf $fh $str;
    return;
}

#sub metadata {
#    my ($self, $all_topics, $only_rkt, $timeout_ms) = @_;
#    $all_topics ||= 0;
#    $only_rkt ||= RdKafka::Topic->new($self);
#    $timeout_ms //= 1000;
#    my $metadata;
#    my $err = $self->metadata_xs($all_topics, $only_rkt, $metadata, $timeout_ms);
#    return($err, $metadata);
#}

#sub list_groups {
#    my ($self, $group, $timeout_ms) = @_;
#    $timeout_ms //= 1000;
#    my ($err, $grplist) = $self->list_groups_xs($group, $timeout_ms);
#    return($err, $grplist);
#}


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
