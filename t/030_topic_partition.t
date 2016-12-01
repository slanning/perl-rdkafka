#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use RdKafka;

use Test::More tests => 9;


{
    my $expected_allocated_size = 5;

    my $list = RdKafka::topic_partition_list_new($expected_allocated_size);
    ok(ref($list), "topic_partition_list_new returned a ref");
    my $expected_class = 'rd_kafka_topic_partition_list_tPtr';
    ok(ref($list) eq $expected_class, "topic_partition_list_new ref isa '$expected_class'");

    my $num_elements = $list->cnt;
    is($num_elements, 0, "cnt says there are no elements");

    # seems to allocate double the number to topic_partiion_list_new
    my $allocated_size = $list->size;
    ok($allocated_size >= $expected_allocated_size, "size has at least the expected allocated size ($expected_allocated_size)");

    my $element_aref = $list->elems;
    is(scalar(@$element_aref), 0, "elems has no elements");
}
# DESTROY is called implicitly on $list here
# and calls rd_kafka_topic_partition_list_destroy
# (see rd_kafka_topic_partition_list_tPtr in RdKafka.xs)

{
    my $list = RdKafka::topic_partition_list_new(5);

    my $partition = RdKafka::topic_partition_list_add($list, "Scott's test", 0);
    ok(ref($partition), "topic_partition_list_add returned a ref");
    my $expected_class = 'rd_kafka_topic_partition_tPtr';
    is(ref($partition), $expected_class, "topic_partition_list_add ref isa '$expected_class'");

    # how many partitions are there?
}

{
    my $list = RdKafka::topic_partition_list_new(5);

    RdKafka::topic_partition_list_add_range($list, "Scott's test", 5, 7);
    ok(ref($list), "topic_partition_list_add_range list is still a ref");
    my $expected_class = 'rd_kafka_topic_partition_list_tPtr';
    is(ref($list), $expected_class, "topic_partition_list_add_range ref isa '$expected_class'");

    # how many partitions are there?
}

