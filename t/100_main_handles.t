#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 9;


## For now at least, the conf object is required (even if the default)
## and this will croak if there's an error from rd_kafka_new.
## I'd like to allow conf to be optional and errstr to hold an error,
## but I haven't figured out how to do that.
{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_CONSUMER, $conf);

    ok(ref($rk), "new returns a ref");
    my $expected_class = 'rd_kafka_tPtr';
    is(ref($rk), $expected_class, "new ref isa '$expected_class'");
}
## how do I make new give an error?

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);
    my $name = RdKafka::name($rk);
    # for me it was: rdkafka#producer-2
    like($name, qr/\S/, "name isn't empty");
}

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);
    my $memberid = RdKafka::memberid($rk);
    ok(!defined($memberid), "memberid isn't available...");

    # currently should free this here with mem_free
    # but I hope to fix that
    #RdKafka::mem_free($rk, $memberid);
}

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);

    my $topic_conf = RdKafka::topic_conf_new();
    my $rkt = RdKafka::topic_new($rk, "Scott", $topic_conf);
    # should do this
    #RdKafka::topic_destroy($rkt);
}

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);

    my $topic_conf = RdKafka::topic_conf_new();
    my $expected_name = "Scott";
    my $rkt = RdKafka::topic_new($rk, $expected_name, $topic_conf);

    my $got_name = RdKafka::topic_name($rkt);
    is($got_name, $expected_name, "topic_name was expected ($expected_name)");

    # should do this
    #RdKafka::topic_destroy($rkt);
}

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);

    my $topic_conf = RdKafka::topic_conf_new();
    my $expected_name = "Scott";
    my $rkt = RdKafka::topic_new($rk, $expected_name, $topic_conf);

    my $opaque = RdKafka::topic_opaque($rkt);
    # I guess it's 0 because it's not set so it's NULL?
    is($opaque, 0, "topic_opaque is 0");

    # should do this
    #RdKafka::topic_destroy($rkt);
}

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);

    my $num_events = RdKafka::poll($rk, 10);
    is($num_events, 0, "no events were received by poll");
}

{
    my $list_size = 5;
    my $partitions = RdKafka::topic_partition_list_new($list_size);
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_PRODUCER, $conf);

    my $res = RdKafka::pause_partitions($rk, $partitions);
    is($res, RD_KAFKA_RESP_ERR_NO_ERROR, "pause_partitions had no error");

    $res = RdKafka::resume_partitions($rk, $partitions);
    is($res, RD_KAFKA_RESP_ERR_NO_ERROR, "resume_partitions had no error");

    # how to check failure?
}

# query_watermark_offsets
# get_watermark_offsets

