package RdKafka::Conf;
use strict;
use warnings;

sub rd_kafka_conf_properties_show_print_fh {
    my ($fh, $str) = @_;
    printf $fh "%s", $str;
    return;
}


1;
__END__
