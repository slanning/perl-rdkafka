#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw/tempfile/;
use Test::More tests => 3;

use RdKafka qw/:enums :syslog/;

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);
    my @brokers;
    my $expected = @brokers;

    my $num_added = $rk->brokers_add(join(',', @brokers));
    is($num_added, $expected, "brokers_add added $expected brokers");
}

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    # it succeeds if the brokers are invalid, but outputs a warning:
    # %3|1482400119.181|FAIL|rdkafka#consumer-2| broker1.example.com:9092/bootstrap: Failed to resolve 'broker1.example.com:9092': Name or service not known
    # %3|1482400119.181|ERROR|rdkafka#consumer-2| broker1.example.com:9092/bootstrap: Failed to resolve 'broker1.example.com:9092': Name or service not known
    # %3|1482400119.181|FAIL|rdkafka#consumer-2| broker2.example.com:9092/bootstrap: Failed to resolve 'broker2.example.com:9092': Name or service not known
    # %3|1482400119.181|ERROR|rdkafka#consumer-2| broker2.example.com:9092/bootstrap: Failed to resolve 'broker2.example.com:9092': Name or service not known

    #my @brokers = qw/broker1.example.com broker2.example.com/;
    #my $expected = @brokers;

    #my $num_added = $rk->brokers_add(join(',', @brokers));
    #is($num_added, $expected, "brokers_add added $expected brokers");
}

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    # void return, and I'm not sure how to get at the log level..
    # (internally it's just: rk->rk_conf.log_level = level;
    #  I think I need to expose struct rd_kafka_conf_t (huge))
    $rk->set_log_level(LOG_WARNING);
}

my $dump_output_re = qr/^rd_kafka_t /ms;

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    my ($fh, $filename) = tempfile(undef, UNLINK => 1);

    $rk->dump($fh);

    close($fh);

    open(my $fh2, $filename);
    my $buf = do { local $/; <$fh2> };
    close($fh2);
    like($buf, $dump_output_re, "dump works with a file filehandle");
}

{
    my $rk = RdKafka->new(RD_KAFKA_CONSUMER);

    my $buf = "";
    open(my $fh, ">", \$buf) or die("Can't open variable for writing: $!");

    $rk->dump($fh);

    close($fh);

    like($buf, $dump_output_re, "dump works with a scalar reference filehandle");
}
