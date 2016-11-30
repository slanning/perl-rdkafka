#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;

use Test::More tests => 1;

use RdKafka qw/:enums/;
my $unknown_error = RD_KAFKA_RESP_ERR_UNKNOWN;

ok($unknown_error, "RD_KAFKA_RESP_ERR_UNKNOWN exported with :enums exporter class");
