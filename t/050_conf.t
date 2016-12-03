#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:event/;

use Test::More tests => 1;

{
    my $conf = RdKafka::conf_new();

    my $dup  = RdKafka::conf_dup($conf);
}

{
    my $conf = RdKafka::conf_new();

    # TODO: still thinking about how to handle the error part

    # returns rd_kafka_conf_res_t
    #my $res = RdKafka::conf_set($conf, "compression.codec", "snappy");

    # ???
    # my $errstr;
    # $res = RdKafka::conf_set($conf, "batch.num.messages", "100", $errstr, 1024);   # C-like interface
    # eval { $res = RdKafka::conf_set($conf, "batch.num.messages", "100"); }         # die on error
    # $res = RdKafka::conf_set($conf, "batch.num.messages", "100", "warn please");   # optional warn flag
}

{
    my $conf = RdKafka::conf_new();

    ## "events is a bitmask of RD_KAFKA_EVENT_* of events to enable
    ## for consumption by `rd_kafka_queue_poll()`"

    ## turns Kafka 0.9.1 (which I have a package installed for)
    # doesn't have events yet (I was basing things on 0.9.2)
    ##conf_set_events($conf, RD_KAFKA_EVENT_LOG | RD_KAFKA_EVENT_ERROR);
    # I hope they have accessor functions,
    # because the rd_kafka_conf_t struct is huge...
    # (making/maintaining accessors for it in XS will suck)
}

ok(1,"");## REMOVE ME
