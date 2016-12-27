#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
    my ($err, $metadata) = $rk->metadata();

    # I guess this is normal?
    is($err, RD_KAFKA_RESP_ERR__TRANSPORT, "metadata error ($err)");

}
