#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 7;

{
    my $conf = RdKafka::conf_new();
    ok(ref($conf), "conf_new returns a ref");
    my $expected_class = 'rd_kafka_conf_tPtr';
    is(ref($conf), $expected_class, "conf_new ref isa '$expected_class'");

    my $dup  = RdKafka::conf_dup($conf);
    ok(ref($conf), "conf_dup returns a ref");
    is(ref($conf), $expected_class, "conf_dup ref isa '$expected_class'");
}

{
    my $conf = RdKafka::conf_new();

    my $test_name = "conf_set compression.codec succeeded";
    eval {  # such a crappy interface...
        RdKafka::conf_set($conf, "compression.codec", "snappy");
        ok(1, $test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        fail("$test_name ($err)");
    };
}

{
    my $conf = RdKafka::conf_new();

    my $test_name = "conf_set batch.num.messages invalid";
    eval {
        RdKafka::conf_set($conf, "batch.num.messages", "none, please");
        fail($test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        ok(1, "$test_name ($err)");
    };
}

{
    my $conf = RdKafka::conf_new();

    my $test_name = "conf_set w.t.f. unknown";
    eval {
        RdKafka::conf_set($conf, "w.t.f.", "this is crazy!");
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
    my $conf = RdKafka::conf_new();

    ## "events is a bitmask of RD_KAFKA_EVENT_* of events to enable
    ## for consumption by `rd_kafka_queue_poll()`"

    ## turns out Kafka 0.9.1 (which I have a package installed for)
    # doesn't have events yet (I was basing things on 0.9.2)
    ##conf_set_events($conf, RD_KAFKA_EVENT_LOG | RD_KAFKA_EVENT_ERROR);
    # I hope they have accessor functions,
    # because the rd_kafka_conf_t struct is huge...
    # (making/maintaining accessors for it in XS will suck)
}
