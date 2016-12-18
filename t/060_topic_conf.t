#!/usr/bin/perl
use strict;
use warnings;
use RdKafka;

use Test::More tests => 4;

{
    my $conf = RdKafka::TopicConf->new();
    ok(ref($conf), "new returns a ref");
    my $expected_class = 'RdKafka::TopicConf';
    ok(ref($conf) eq $expected_class, "new ref isa '$expected_class'");

    my $dup  = $conf->dup();
    ok(ref($conf), "dup returns a ref");
    $expected_class = 'RdKafka::TopicConf';
    ok(ref($conf) eq $expected_class, "dup ref isa '$expected_class'");
}

#{
#    my $conf = RdKafka::topic_conf_new();
#    RdKafka::topic_conf_set($conf, "auto.offset.reset" => "smallest"   );
#}

