#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;

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

ok(1,"");## REMOVE ME
