#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;

use Test::More tests => 4;

{
    my $conf = RdKafka::topic_conf_new();
    ok(ref($conf), "topic_conf_new returns a ref");
    my $expected_class = 'RdKafka::TopicConf';
    ok(ref($conf) eq $expected_class, "topic_conf_new ref isa '$expected_class'");

    my $dup  = RdKafka::topic_conf_dup($conf);
    ok(ref($conf), "topic_conf_dup returns a ref");
    $expected_class = 'RdKafka::TopicConf';
    ok(ref($conf) eq $expected_class, "topic_conf_dup ref isa '$expected_class'");
}

#{
#    my $conf = RdKafka::topic_conf_new();
#    RdKafka::topic_conf_set($conf, "auto.offset.reset" => "smallest"   );
#}

