#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 2;

{
    my $conf = RdKafka::conf_new();
    my $rk = RdKafka::new(RD_KAFKA_CONSUMER, $conf);

    my $queue = RdKafka::queue_new($rk);
    ok(ref($queue), "new returns a ref");
    my $expected_class = 'rd_kafka_queue_tPtr';
    is(ref($queue), $expected_class, "new ref isa '$expected_class'");
}
