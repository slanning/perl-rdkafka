#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums RD_KAFKA_PARTITION_UA/;
use RdKafka::Topic;

use Test::More tests => 1;

{
    my $rk = RdKafka->new(RD_KAFKA_PRODUCER);
    my $rkt = RdKafka::Topic->new($rk, "topic 1");

    my $err = $rkt->produce(RD_KAFKA_PARTITION_UA, 0, "hi", 3, "greeting", 8, "");
    is($err, 0, "produce succeeded");

    # need to test the various failures
}

