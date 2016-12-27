#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums :consumer/;

use Test::More tests => 17;

# I can't see how to test that type isn't undef (gets treated as 0)
#{
#    local $SIG{__WARN__} = sub { };
#
#    my $test_name = "new with no args fails";
#    eval {
#        my $rk = RdKafka->new();
#        fail($test_name);
#        1;
#    } or do {
#        pass($test_name);
#    };
#}
{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    ok(ref($rk), "new with type arg returns a ref");
    my $expected_class = 'RdKafka';
    is(ref($rk), $expected_class, "new ref isa '$expected_class'");
}
# this succeeds for whatever reason, even though 42 isn't valid
# {
#     my $rk = RdKafka->new(42);
#     ok(ref($rk), "new returns a ref");
#     my $expected_class = 'RdKafka';
#     is(ref($rk), $expected_class, "new ref isa '$expected_class'");
# }
{
    my $test_name = "RdKafka->new fails with invalid conf arg";
    eval {
        my $rk = RdKafka->new(RD_KAFKA_PRODUCER, []);
        fail($test_name);
        1;
    } or do {
        pass($test_name);
    };
}
{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER, $conf);

    ok(ref($rk), "new with type and conf args returns a ref");
    my $expected_class = 'RdKafka';
    is(ref($rk), $expected_class, "new ref isa '$expected_class'");
}
{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER, $conf, 2);

    ok(ref($rk), "new with bogus errstr, who cares...");
    my $expected_class = 'RdKafka';
    is(ref($rk), $expected_class, "new ref isa '$expected_class'");
}
## how do I make new give an error?

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);
    my $name = $rk->name;
    # for me it was: rdkafka#producer-2
    like($name, qr/\S/, "name isn't empty");
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);
    my $memberid = $rk->memberid;
    ok(!defined($memberid), "memberid isn't available...");

    # currently should free this here with mem_free
    # but I hope to fix that
    # $rk->mem_free($memberid);
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);

    my $topic_conf = RdKafka::TopicConf->new();
    my $rkt = RdKafka::Topic->new($rk, "Scott", $topic_conf);
    # should do this
    # $rkt->destroy();
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);

    my $topic_conf = RdKafka::TopicConf->new();
    my $expected_name = "Scott";
    my $rkt = RdKafka::Topic->new($rk, $expected_name, $topic_conf);

    my $got_name = $rkt->name;
    is($got_name, $expected_name, "topic name was expected ($expected_name)");

    # should do this
    # $rkt->destroy();
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);

    my $topic_conf = RdKafka::TopicConf->new();
    my $expected_name = "Scott";
    my $rkt = RdKafka::Topic->new($rk, $expected_name, $topic_conf);

    my $opaque = $rkt->opaque;
    # I guess it's 0 because it's not set so it's NULL?
    is($opaque, 0, "topic opaque is 0");

    # should do this
    # $rkt->destroy();
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);

    my $num_events = $rk->poll(10);
    is($num_events, 0, "no events were received by poll");
}

{
    my $list_size = 5;
    my $partitions = RdKafka::TopicPartitionList->new($list_size);
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER, $conf);

    my $res = $rk->pause_partitions($partitions);
    is($res, RD_KAFKA_RESP_ERR_NO_ERROR, "pause_partitions had no error");

    $res = $rk->resume_partitions($partitions);
    is($res, RD_KAFKA_RESP_ERR_NO_ERROR, "resume_partitions had no error");

    # how to check failure?
}

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    # err:-180 low:139851274233000 high:36366712 ??
    my ($err, $low, $high) = $rk->query_watermark_offsets("test topic", 0, 1*1000);
    is($err, RD_KAFKA_RESP_ERR__WAIT_COORD, "query_watermark_offsets gives an error ($err)");
}

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
    my ($err, $low, $high) = $rk->get_watermark_offsets("test topic", 0);
    is($err, 0, "get_watermark_offsets err=0");
    is($low, RD_KAFKA_OFFSET_INVALID, "get_watermark_offsets low invalid");
    is($high, RD_KAFKA_OFFSET_INVALID, "get_watermark_offsets high invalid");
}

#{
#    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
#    my ($err, $topparlist) = $rk->subscription();
#    diag("err: $err topparlist: $topparlist");
#}
