#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw/tempfile/;
use RdKafka qw/:enums/;

use Test::More tests => 19;

{
    my $conf = RdKafka::Conf->new();
    ok(ref($conf), "conf_new returns a ref");
    my $expected_class = 'RdKafka::Conf';
    is(ref($conf), $expected_class, "conf_new ref isa '$expected_class'");

    my $dup  = $conf->dup();
    ok(ref($conf), "conf_dup returns a ref");
    is(ref($conf), $expected_class, "conf_dup ref isa '$expected_class'");
}

{
    my $conf = RdKafka::Conf->new();

    my $test_name = "conf_set compression.codec succeeded";
    eval {  # such a crappy interface...
        $conf->set("compression.codec", "snappy");
        ok(1, $test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        fail("$test_name ($err)");
    };
}

{
    my $conf = RdKafka::Conf->new();

    my $test_name = "conf_set batch.num.messages invalid";
    eval {
        $conf->set("batch.num.messages", "none, please");
        fail($test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        ok(1, "$test_name ($err)");
    };
}

{
    my $conf = RdKafka::Conf->new();

    my $test_name = "conf_set w.t.f. unknown";
    eval {
        $conf->set("w.t.f.", "this is crazy!");
        fail($test_name);
        1;
    } or do {
        my $err = $@ || "zombies?";
        ok(1, "$test_name ($err)");
    };
}

SKIP: {
    skip("need version >= 0.9.2", 2)
      unless RdKafka::version() >= 0x000902ff;

    # event" is not defined in %RdKafka::EXPORT_TAGS
    require RdKafka;
    RdKafka->import(qw/:event/);

    my $conf = RdKafka::Conf->new();

    ## "events is a bitmask of RD_KAFKA_EVENT_* of events to enable
    ## for consumption by `rd_kafka_queue_poll()`"
    is($conf->enabled_events, 0, "initially no events enabled");    # TODO: is this right?

    no strict 'subs';  # Bareword not allowed
    my $expected_events = RD_KAFKA_EVENT_LOG | RD_KAFKA_EVENT_ERROR;
    $conf->set_events($expected_events);

    is($conf->enabled_events, $expected_events, "expected events enabled");
}

{
    my $conf = RdKafka::Conf->new();
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER, $conf);

    my $expected_opaque = "heyyyy";
    $conf->set_opaque($expected_opaque);

    # is this only useable in callbacks, or what?
    #my $got_opaque = $rk->opaque;
    #is($got_opaque, $expected_opaque, "got expected opaque ($got_opaque)");
}

{
    my $conf = RdKafka::Conf->new();
    my $topic_conf = RdKafka::TopicConf->new();
    $conf->set_default_topic_conf($topic_conf);
    # don't have a way to get the topic_conf back (yet)
}

{
    my $conf = RdKafka::Conf->new();
    my $name = 'broker.version.fallback';
    my ($ret, $value) = $conf->get($name);
    is($ret, RD_KAFKA_CONF_OK, "conf name $name is OK");
    ok($value, "conf has a $name");
}

{
    my $conf = RdKafka::Conf->new();
    my $name = 'broke.back.mountain';
    my ($ret, $value) = $conf->get($name);
    is($ret, RD_KAFKA_CONF_UNKNOWN, "conf name $name is unknown");
    ok(!$value, "conf doesn't have a $name");
}

{
    my $conf = RdKafka::Conf->new;
    # the int and char* fields of rd_kafka_conf_t are wrapped;
    # look in RdKafka.x for the struct accessors
    ok($conf->max_msg_size, "max_msg_size access works");
    ok($conf->broker_version_fallback, "broker_version_fallback access works");
}

{
    my $conf = RdKafka::Conf->new;
    my $dump = $conf->dump();
    ok(scalar(keys(%$dump)), "conf dump returns a hash with keys");
    is($dump->{'client.id'}, 'rdkafka', "client.id eq 'rdkafka'");   # tried to pick one that wouldn't change (?)
}

my $dump_output_re = qr/builtin\.features/ms;
{
    my $conf = RdKafka::Conf->new();
    my ($fh, $filename) = tempfile(undef, UNLINK => 1);
    $conf->properties_show($fh);
    close($fh);
    open(my $fh2, $filename);
    my $buf = do { local $/; <$fh2> };
    close($fh2);

    like($buf, $dump_output_re, "dump works with a file filehandle");
}

{
    my $conf = RdKafka::Conf->new();

    my $buf = "";
    open(my $fh, ">", \$buf) or die("Can't open variable for writing: $!");
    $conf->properties_show($fh);
    close($fh);

    like($buf, $dump_output_re, "dump works with a scalar reference filehandle");
}
