#!/usr/bin/perl
use strict;
use warnings;
use POSIX ();

use RdKafka;

use Test::More tests => 11;


# get_debug_contexts

{

my $debug_contexts = RdKafka::get_debug_contexts() // 'wtf?';
like($debug_contexts, qr/^[a-z][a-z,]+[a-z]$/, "debug_contexts ($debug_contexts) looks reasonable");

}

# get_err_descs

{

my $descs = RdKafka::get_err_descs() // [];
ok(scalar(keys %$descs),                       "return value of get_err_descs has hash elements");

my $desc = $descs->{0};
ok(ref($desc),                            "0 keys of get_err_descs is a ref");
ok($desc->{name},                         "0 element's 'name' is something ($desc->{name})");
ok($desc->{desc},                         "0 element's 'desc' is something ($desc->{desc})");

}

{

my $unknown_error = RdKafka::RD_KAFKA_RESP_ERR_UNKNOWN;
is($unknown_error, -1,           "RD_KAFKA_RESP_ERR_UNKNOWN from rd_kafka_resp_err_t looks good");

my $errstr = RdKafka::err2str($unknown_error);
ok($errstr,                      "err2str is something ($errstr)");

my $errname = RdKafka::err2name($unknown_error);
ok($errname,                     "err2name is something ($errname)");

my $last_error = RdKafka::last_error();
is($last_error, 0,               "last_error is 0");

my $errcode = RdKafka::errno2err(POSIX::EINVAL);
ok($errcode,                     "errno2err is something ($errcode)");

my $errno = RdKafka::errno();
ok($errno == 0,                  "errno is 0");

}
