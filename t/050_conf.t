#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 9;

{
    my $conf = RdKafka::Conf->new();
    ok(ref($conf), "conf_new returns a ref");
    my $expected_class = 'RdKafka::Conf';
    is(ref($conf), $expected_class, "conf_new ref isa '$expected_class'");

    my $dup  = $conf->dup();
    ok(ref($conf), "conf_dup returns a ref");
    is(ref($conf), $expected_class, "conf_dup ref isa '$expected_class'");
}

{
    my $conf = RdKafka::Conf->new();

    my $test_name = "conf_set compression.codec succeeded";
    eval {  # such a crappy interface...
        $conf->set("compression.codec", "snappy");
        ok(1, $test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        fail("$test_name ($err)");
    };
}

{
    my $conf = RdKafka::Conf->new();

    my $test_name = "conf_set batch.num.messages invalid";
    eval {
        $conf->set("batch.num.messages", "none, please");
        fail($test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        ok(1, "$test_name ($err)");
    };
}

{
    my $conf = RdKafka::Conf->new();

    my $test_name = "conf_set w.t.f. unknown";
    eval {
        $conf->set("w.t.f.", "this is crazy!");
        fail($test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        ok(1, "$test_name ($err)");
    };
}

SKIP: {
    skip("need version >= 0.9.2", 2)
      unless RdKafka::version() >= 0x000902ff;

    # event" is not defined in %RdKafka::EXPORT_TAGS
    require RdKafka;
    RdKafka->import(qw/:event/);

    my $conf = RdKafka::Conf->new();

    ## "events is a bitmask of RD_KAFKA_EVENT_* of events to enable
    ## for consumption by `rd_kafka_queue_poll()`"
    is($conf->enabled_events, 0, "initially no events enabled");    # TODO: is this right?

    no strict 'subs';  # Bareword not allowed
    my $expected_events = RD_KAFKA_EVENT_LOG | RD_KAFKA_EVENT_ERROR;
    $conf->set_events($expected_events);

    is($conf->enabled_events, $expected_events, "expected events enabled");
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER, $conf);

    my $expected_opaque = "heyyyy";
    $conf->set_opaque($expected_opaque);

    # is this only useable in callbacks, or what?
    #my $got_opaque = $rk->opaque;
    #is($got_opaque, $expected_opaque, "got expected opaque ($got_opaque)");
}

{
    my $conf = RdKafka::Conf->new();
    my $topic_conf = RdKafka::TopicConf->new();
    $conf->set_default_topic_conf($topic_conf);
    # don't have a way to get the topic_conf back (yet)
}

{
    my $conf = RdKafka::Conf->new;
    # the int and char* fields of rd_kafka_conf_t are wrapped,
    # look in RdKafka.x for the struct accessors
    diag("max_msg_size: " . $conf->max_msg_size);
    diag("broker_version_fallback: " . $conf->broker_version_fallback);
}

