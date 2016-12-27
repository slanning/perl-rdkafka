#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
    my ($err, $grplist) = $rk->list_groups();

    # I guess this is expected if there's no broker
    is($err, RD_KAFKA_RESP_ERR__TIMED_OUT, "list_groups timed out");

    $grplist->destroy() if defined($grplist);
}
