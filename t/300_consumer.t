#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    my $topics = RdKafka::TopicPartitionList->new(2);
    my @topic_partition_add = (
        ["topic 1" => 0],
        ["topic 2" => 0],
    );
    $topics->add(@$_) for @topic_partition_add;

    my $errcode = $rk->subscribe($topics);
    # not sure what it means yet
    is($errcode, RD_KAFKA_RESP_ERR__UNKNOWN_GROUP, "subscribe RD_KAFKA_RESP_ERR__UNKNOWN_GROUP");
}

# examples/rdkafka_consumer_example.c
