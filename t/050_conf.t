#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 7;

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

{
    # if version >= 0x000901ff
    #use RdKafka qw/:event/;
    my $conf = RdKafka::Conf->new();

    ## "events is a bitmask of RD_KAFKA_EVENT_* of events to enable
    ## for consumption by `rd_kafka_queue_poll()`"

    ## turns out Kafka 0.9.1 (which I have a package installed for)
    # doesn't have events yet (I was basing things on 0.9.2)
    ##conf_set_events($conf, RD_KAFKA_EVENT_LOG | RD_KAFKA_EVENT_ERROR);
    # I hope they have accessor functions,
    # because the rd_kafka_conf_t struct is huge...
    # (making/maintaining accessors for it in XS will suck)
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
