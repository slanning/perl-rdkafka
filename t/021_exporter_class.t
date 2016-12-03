#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 1;

my $unknown_error = RD_KAFKA_RESP_ERR_UNKNOWN;

ok($unknown_error, "RD_KAFKA_RESP_ERR_UNKNOWN exported with :enums exporter class");
