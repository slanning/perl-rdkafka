package RdKafka::Topic;
use strict;
use warnings;

sub new {
    my ($class, $rk, $topic, $topic_conf) = @_;
    $topic_conf ||= RdKafka::TopicConf->new();
    my $self = $class->new_xs($rk, $topic, $topic_conf);
    return($self);
}

1;
__END__
