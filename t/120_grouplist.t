#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

#{
#    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
#    my ($err, $grplist) = $rk->list_groups();
#}

ok(1, "hi");
