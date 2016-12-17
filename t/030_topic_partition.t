#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use RdKafka;

use Test::More tests => 28;

{
    my $expected_allocated_size = 5;

    # returns an RdKafka::TopicPartition object (struct)
    my $list = RdKafka::TopicPartitionList->new($expected_allocated_size);
    test_list($list, $expected_allocated_size);
}
# DESTROY is called implicitly on $list here
# and calls rd_kafka_topic_partition_list_destroy
# (see RdKafka::TopicPartition in RdKafka.xs)

{
    my $list = RdKafka::TopicPartitionList->new(5);

    # returns an RdKafka::TopicPartition object (struct)
    my $expected_topic = "test topic";
    my $expected_partition = 0;
    my $toppar = $list->add($expected_topic, $expected_partition);
    ok(ref($toppar), "topic_partition_list_add returned a ref");
    my $expected_class = 'RdKafka::TopicPartition';
    is(ref($toppar), $expected_class, "topic_partition_list_add ref isa '$expected_class'");

    # testing topic-partition struct accessors
    is($toppar->topic, $expected_topic, "partition topic is '$expected_topic'");
    is($toppar->partition, $expected_partition, "partition is $expected_partition");
    my $offset = $toppar->offset;   # was -1001 for me (dunno why), also in a C test
    like($offset, qr/^-?[0-9]+$/, "offset is an integer ($offset)");
    is($toppar->metadata_size, 0, "metadata_size is 0");
    my $expected_err = RdKafka::RD_KAFKA_RESP_ERR_NO_ERROR;
    is($toppar->err, $expected_err, "err is no error ($expected_err)");
}

{
    my $list = RdKafka::TopicPartitionList->new(5);

    $list->add_range("Scott's test", 5, 7);
    ok(ref($list), "topic_partition_list_add_range list is still a ref");
    my $expected_class = 'RdKafka::TopicPartitionList';
    is(ref($list), $expected_class, "topic_partition_list_add_range ref isa '$expected_class'");

    # how many partitions are there?
}

{
    my $list = RdKafka::TopicPartitionList->new(5);

    my $expected_topic = "test topic";
    my $expected_partition = 1;
    my $toppar = $list->add($expected_topic, $expected_partition);
    is($toppar->partition, $expected_partition, "partition is $expected_partition");

    # returns 1 if partition found+removed, 0 otherwise
    my $found = $list->del($expected_topic . "98239an8br384gfj", $expected_partition);
    is($found, 0, "topic is not found");
    $found = $list->del($expected_topic, $expected_partition + 10);
    is($found, 0, "partition is not found");
    $found = $list->del($expected_topic, $expected_partition);
    is($found, 1, "topic and partition are found, so topic deleted");
}

{
    ;
    # TODO
    ## rd_kafka_topic_partition_list_del_by_idx
    # this deletes from the ->elems list by index;
    # need to figure out how to do this properly
    # esp with the struct accessor handling (rd_kafka_elems in RdKafka.xs)
}

{
    my $expected_allocated_size = 5;
    my $list = RdKafka::TopicPartitionList->new($expected_allocated_size);

    # what is this for? (needed in Perl?)
    my $list_copy = RdKafka::TopicPartitionList->copy($list);

    test_list($list, $expected_allocated_size);
}

{
    # TODO
    # it always returns an "unknown partition" error;
    # I don't understand what this is for yet, so skipping for now

    my $expected_allocated_size = 5;
#    my $list = RdKafka::topic_partition_list_new($expected_allocated_size);
#
#    my $err = RdKafka::topic_partition_list_set_offset($list, "test topic", 1, 3);
#    is($err, RdKafka::RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION, "list_set_offset: unknown partition");
#
#    $err = RdKafka::topic_partition_list_set_offset($list, "test topic", 0, 0);
#diag("err:$err");
}

{
    my $list = RdKafka::TopicPartitionList->new(5);

    # returns an RdKafka::TopicPartition object (struct)
    my $toppar = $list->add("test topic 1", 0);

    my $expected_topic = "test topic 2";
    my $expected_partition = 0;
    my $toppar2 = $list->add($expected_topic, $expected_partition);

    my $toppar_found = $list->find($expected_topic, $expected_partition);
    is($toppar_found->topic, $expected_topic, "partition topic is '$expected_topic'");
    is($toppar_found->partition, $expected_partition, "partition is $expected_partition");
    my $offset = $toppar_found->offset;   # was -1001 for me (dunno why), also in a C test
    like($offset, qr/^-?[0-9]+$/, "offset is an integer ($offset)");
    is($toppar_found->metadata_size, 0, "metadata_size is 0");
    my $expected_err = RdKafka::RD_KAFKA_RESP_ERR_NO_ERROR;
    is($toppar_found->err, $expected_err, "err is no error ($expected_err)");
}

sub test_list {
    my ($list, $expected_allocated_size) = @_;

    ok(ref($list), "topic_partition_list_new returns a ref");
    my $expected_class = 'RdKafka::TopicPartitionList';
    ok(ref($list) eq $expected_class, "topic_partition_list_new ref isa '$expected_class'");

    # testing list struct accessors
    my $num_elements = $list->cnt;
    is($num_elements, 0, "cnt says there are no elements");

    # seems to allocate double the number to topic_partiion_list_new
    my $allocated_size = $list->size;
    ok($allocated_size >= $expected_allocated_size, "size has at least the expected allocated size ($expected_allocated_size)");

    my $element_aref = $list->elems;
    is(scalar(@$element_aref), 0, "elems has no elements");
}
