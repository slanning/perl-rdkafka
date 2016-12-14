#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:producer/;

use Test::More tests => 2;

ok(RD_KAFKA_MSG_F_FREE, "RD_KAFKA_MSG_F_FREE exported with :producer exporter class");

SKIP: {
    skip("need version >= 0.9.2", 1)
      unless RdKafka::version() >= 0x000902ff;

    no strict 'subs';  # Bareword not allowed
    ok(RD_KAFKA_MSG_F_BLOCK, "RD_KAFKA_MSG_F_BLOCK exported with :producer for version >= 0.9.2");
}
