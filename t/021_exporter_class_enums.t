#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 2;

ok(RD_KAFKA_RESP_ERR_UNKNOWN, "RD_KAFKA_RESP_ERR_UNKNOWN exported with :enums exporter class");

SKIP: {
    skip("need version >= 0.9.2", 1)
      unless RdKafka::version() >= 0x000902ff;

    no strict 'subs';  # Bareword not allowed
    ok(RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE, "RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE exported with :enums for version >= 0.9.2");
}
