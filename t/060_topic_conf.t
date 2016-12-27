#!/usr/bin/perl
use strict;
use warnings;
use RdKafka qw/:enums/;

use Test::More tests => 6;

{
    my $topic_conf = RdKafka::TopicConf->new();
    ok(ref($topic_conf), "new returns a ref");
    my $expected_class = 'RdKafka::TopicConf';
    ok(ref($topic_conf) eq $expected_class, "new ref isa '$expected_class'");

    my $dup  = $topic_conf->dup();
    ok(ref($topic_conf), "dup returns a ref");
    $expected_class = 'RdKafka::TopicConf';
    ok(ref($topic_conf) eq $expected_class, "dup ref isa '$expected_class'");

    $topic_conf->destroy();
}

{
    my $topic_conf = RdKafka::TopicConf->new();

    test_topic_conf_set_get($topic_conf, @$_[0..1]) for (
        ['request.required.acks', -1],
        ['auto.commit.enable', 'false'],
    );

    $topic_conf->destroy();
}

sub test_topic_conf_set_get {
    my ($topic_conf, $name, $value) = @_;
    $topic_conf->set($name, $value);
    my ($err, $got) = $topic_conf->get($name);
    is($got, $value, "conf $name set/get ($value)");
}
