#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 4;

{
    my $rk = RdKafka::new(RD_KAFKA_CONSUMER);

    ok(ref($rk), "new returns a ref");
    my $expected_class = 'rd_kafka_tPtr';
    is(ref($rk), $expected_class, "new ref isa '$expected_class'");
}

{
    my $buf;

    # RdKafka::new: conf is not of type rd_kafka_conf_tPtr at t/100_main_handles.t line 18.
    my $rk = RdKafka::new(RD_KAFKA_CONSUMER, undef, $buf);

    ok(ref($rk), "new returns a ref");
    my $expected_class = 'rd_kafka_tPtr';
    is(ref($rk), $expected_class, "new ref isa '$expected_class'");
}

