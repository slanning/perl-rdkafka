#!/usr/bin/perl
use strict;
use warnings;
use POSIX ();

use RdKafka;

use Test::More tests => 12;


# get_debug_contexts

{

my $debug_contexts = RdKafka::get_debug_contexts() // 'wtf?';
like($debug_contexts, qr/^[a-z][a-z,]+[a-z]$/, "debug_contexts ($debug_contexts) looks reasonable");

}

# get_err_descs

{

my $descs = RdKafka::get_err_descs() // [];

ok(scalar(@$descs),                            "return value of get_err_descs has array elements");

my $last_desc = $descs->[-1];
ok(ref($last_desc),                            "return value of get_err_descs is a ref");
like($last_desc->{code}, qr/^-?[0-9]+$/,       "last element's 'code' is an integer");
ok($last_desc->{name},                         "last element's 'name' is something");
ok($last_desc->{desc},                         "last element's 'desc' is something");

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
