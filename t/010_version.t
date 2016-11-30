#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;

use Test::More tests => 2;

# 590335
my $version = RdKafka::version() // 'wtf?';
like($version, qr/^[0-9]+$/, "version ($version) looks reasonable");

# 0.9.1
my $version_str = RdKafka::version_str() // 'wtf?';
like($version_str, qr/^([0-9]+\.)*[0-9]+$/, "version_str ($version_str) looks reasonable");
