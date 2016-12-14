#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;
use Test::More tests => 1;

SKIP: {
    skip("need version >= 0.9.2", 1)
      unless RdKafka::version() >= 0x000902ff;

    # event" is not defined in %RdKafka::EXPORT_TAGS
    require RdKafka;
    RdKafka->import(qw/:event/);

    no strict 'subs';  # Bareword not allowed
    ok(RD_KAFKA_EVENT_NONE, "RD_KAFKA_EVENT_NONE exported with :event for version >= 0.9.2");
}
