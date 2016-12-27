#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
    my $err = $rk->poll_set_consumer();

    # I guess this is expected?
    is($err, RD_KAFKA_RESP_ERR__UNKNOWN_GROUP, "poll_set_consumer gives an error ($err)");
}
