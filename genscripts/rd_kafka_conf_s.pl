#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper; { package Data::Dumper; our ($Indent, $Sortkeys, $Terse, $Useqq) = (1)x4 }

my $rdkafka_parsed = do "./genscripts/parse-xml-0.9.1.out";
unless ($rdkafka_parsed) {
    die("omg: \$\@: $@ \$\!: $!");
}
my ($rd_kafka_conf_s) = grep { $_->{name} eq 'rd_kafka_conf_s' } values(%{ $rdkafka_parsed->{Struct} });

foreach my $field (@{$rd_kafka_conf_s->{fields}}) {
    my ($name, $return, $nodename, $pointer, $ignored) = ($field->{name}, $field->{type}{full_name}, $field->{type}{node_name}, $field->{type}{pointer}, $field->{ignored});
    next if $ignored;

    unless ($return) {
        $return = "no return:";
    }

    # skip quite a few here
    my $commented = ($nodename ne 'FundamentalType') ? '## ' : '';

    printf("%s%s\n%s%s(RdKafka::Conf conf)\n%s  CODE:\n%s    RETVAL = conf->%s;\n%s  OUTPUT:\n%s    RETVAL\n\n",
           $commented, $return,
           $commented, $name,
           $commented,
           $commented, $name,
           $commented,
           $commented,
       );
}
