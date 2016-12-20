package RdKafka::TopicPartitionList;
use strict;
use warnings;

sub elems {
    my ($self) = @_;
    my $cnt = $self->cnt;
    my @elems = map($self->elem_n($_), 0 .. $cnt - 1);
    return \@elems;
}


1;
__END__
