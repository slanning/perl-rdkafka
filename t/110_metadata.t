#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

#{
#    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
#    my ($err, $metadata) = $rk->metadata();
#    diag("err:$err metadata:$metadata");
#}

ok(1,"hi");

