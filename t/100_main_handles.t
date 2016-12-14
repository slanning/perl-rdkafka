#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;

use Test::More tests => 1;

{
    my $kafka = RdKafka::topic_new(   );
    #...
    ok(1, "hello, there");
}
