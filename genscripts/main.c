/* guesses at includes needed */

#define __need_IOV_MAX
#include "bits/stdio_lim.h"
#include "setjmp.h"


/* includes from rdkafka.c */

#define _GNU_SOURCE
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "rdkafka_int.h"
#include "rdkafka_msg.h"
#include "rdkafka_broker.h"
#include "rdkafka_topic.h"
#include "rdkafka_partition.h"
#include "rdkafka_offset.h"
#include "rdkafka_transport.h"
#include "rdkafka_cgrp.h"
#include "rdkafka_assignor.h"
#include "rdkafka_request.h"

#if WITH_SASL
#include "rdkafka_sasl.h"
#endif

#include "rdtime.h"
#ifdef _MSC_VER
#include <sys/types.h>
#include <sys/timeb.h>
#endif

/* includes from rdkafka_conf.h */

#include "rdkafka_int.h"
#include "rd.h"

#include <stdlib.h>
#include <ctype.h>
#include <stddef.h>

#include "rdkafka_int.h"
#include "rdkafka_feature.h"


int main(int argc, char *argv[]) {
    return 0;
}
