#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 3;

# rd_kafka_topic_partition_available can only be called in a partitioner function

{
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER);
    my $rkt = RdKafka::Topic->new($rk, "topic 42");

    my $key = "key1";
    my $partition_cnt = 8;
    require bytes;
    my $partition = $rkt->msg_partitioner_random("key1", bytes::length($key), $partition_cnt, "", "");
    # TODO: it always returns 1, I guess that's the only one that exists
    ok($partition >= 0 && $partition < $partition_cnt, "msg_partitioner_random returned a reasonable random value ($partition)");
}

{
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER);
    my $rkt = RdKafka::Topic->new($rk, "topic 42");

    my $key = "key1";
    my $partition_cnt = 8;
    require bytes;
    my $partition = $rkt->msg_partitioner_consistent("key1", bytes::length($key), $partition_cnt, "", "");
    # TODO: it always returns 1, I guess that's the only one that exists
    ok($partition >= 0 && $partition < $partition_cnt, "msg_partitioner_consistent returned a reasonable random value ($partition)");
}

{
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER);
    my $rkt = RdKafka::Topic->new($rk, "topic 42");

    my $key = "key1";
    my $partition_cnt = 8;
    require bytes;
    my $partition = $rkt->msg_partitioner_consistent_random("key1", bytes::length($key), $partition_cnt, "", "");
    # TODO: it always returns 1, I guess that's the only one that exists
    ok($partition >= 0 && $partition < $partition_cnt, "msg_partitioner_consitent_random returned a reasonable random value ($partition)");
}
