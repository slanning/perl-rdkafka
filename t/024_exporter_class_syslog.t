#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:syslog/;
use Test::More tests => 1;

ok(LOG_WARNING, "LOG_WARNING exported with :syslog exporter class");
