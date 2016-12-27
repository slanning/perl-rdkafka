#ifdef __cplusplus
extern "C" {
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* snprintf, tmpfile, rewind, fscanf, fclose */
#include <stdio.h>
/* bzero */
#include <strings.h>
/* errno */
#include <errno.h>

/* LOG_DEBUG etc. constants - is this OK on windows? */
#include <sys/syslog.h>

#include "librdkafka/rdkafka.h"

#ifdef __cplusplus
}
#endif

/* crazy? copied from src/rdkafka_conf.h v0.9.2 - partly manually edited to remove unknown types */
struct rd_kafka_conf_s {
	/*
	 * Generic configuration
	 */
	int     enabled_events;
	int     max_msg_size;
	int     msg_copy_max_size;
        int     recv_max_msg_size;
	int     max_inflight;
	int     metadata_request_timeout_ms;
	int     metadata_refresh_interval_ms;
	int     metadata_refresh_fast_cnt;
	int     metadata_refresh_fast_interval_ms;
        int     metadata_refresh_sparse;
	int     debug;
	int     broker_addr_ttl;
        int     broker_addr_family;
	int     socket_timeout_ms;
	int     socket_blocking_max_ms;
	int     socket_sndbuf_size;
	int     socket_rcvbuf_size;
        int     socket_keepalive;
        int     socket_max_fails;
	char   *client_id_str;
/*        rd_kafkap_str_t *client_id; */
	char   *brokerlist;
	int     stats_interval_ms;
	int     term_sig;
        int     reconnect_jitter_ms;
	int     api_version_request;
	int     api_version_fallback_ms;
	char   *broker_version_fallback;
/*	rd_kafka_secproto_t security_protocol; */

#if WITH_SSL
	struct {
		SSL_CTX *ctx;
		char *cipher_suites;
		char *key_location;
		char *key_password;
		char *cert_location;
		char *ca_location;
		char *crl_location;
	} ssl;
#endif

#if WITH_SASL
	struct {
		char *principal;
		char *mechanisms;
		char *service_name;
		char *kinit_cmd;
		char *keytab;
		int   relogin_min_time;
		char *username;
		char *password;
	} sasl;
#endif


        /* Client group configuration */
        int    coord_query_intvl_ms;

	int    builtin_features;
	/*
	 * Consumer configuration
	 */
	int    queued_min_msgs;
        int    queued_max_msg_kbytes;
        int64_t queued_max_msg_bytes;
	int    fetch_wait_max_ms;
        int    fetch_msg_max_bytes;
	int    fetch_min_bytes;
	int    fetch_error_backoff_ms;
        char  *group_id_str;
/*        rd_kafkap_str_t   *group_id; */   /* Consumer group id */

/*        rd_kafka_pattern_list_t *topic_blacklist; */
        struct rd_kafka_topic_conf_s *topic_conf; /* Default topic config
                                                   * for automatically
                                                   * subscribed topics. */
        int enable_auto_commit;
	int enable_auto_offset_store;
        int auto_commit_interval_ms;
        int group_session_timeout_ms;
        int group_heartbeat_intvl_ms;
/*        rd_kafkap_str_t *group_protocol_type; */
        char *partition_assignment_strategy;
/*        rd_list_t partition_assignors; */
	int enabled_assignor_cnt;
/*        struct rd_kafka_assignor_s *assignor; */

        void (*rebalance_cb) (rd_kafka_t *rk,
                              rd_kafka_resp_err_t err,
			      rd_kafka_topic_partition_list_t *partitions,
                              void *opaque);

        void (*offset_commit_cb) (rd_kafka_t *rk,
                                  rd_kafka_resp_err_t err,
                                  rd_kafka_topic_partition_list_t *offsets,
                                  void *opaque);

/*        rd_kafka_offset_method_t offset_store_method; */
	int enable_partition_eof;

	/*
	 * Producer configuration
	 */
	int    queue_buffering_max_msgs;
	int    queue_buffering_max_kbytes;
	int    buffering_max_ms;
	int    max_retries;
	int    retry_backoff_ms;
	int    batch_num_messages;
/*	rd_kafka_compression_t compression_codec; */
	int    dr_err_only;

	/* Message delivery report callback.
	 * Called once for each produced message, either on
	 * successful and acknowledged delivery to the broker in which
	 * case 'err' is 0, or if the message could not be delivered
	 * in which case 'err' is non-zero (use rd_kafka_err2str()
	 * to obtain a human-readable error reason).
	 *
	 * If the message was produced with neither RD_KAFKA_MSG_F_FREE
	 * or RD_KAFKA_MSG_F_COPY set then 'payload' is the original
	 * pointer provided to rd_kafka_produce().
	 * rdkafka will not perform any further actions on 'payload'
	 * at this point and the application may rd_free the payload data
	 * at this point.
	 *
	 * 'opaque' is 'conf.opaque', while 'msg_opaque' is
	 * the opaque pointer provided in the rd_kafka_produce() call.
	 */
	void (*dr_cb) (rd_kafka_t *rk,
		       void *payload, size_t len,
		       rd_kafka_resp_err_t err,
		       void *opaque, void *msg_opaque);

        void (*dr_msg_cb) (rd_kafka_t *rk, const rd_kafka_message_t *rkmessage,
                           void *opaque);

        /* Consume callback */
        void (*consume_cb) (rd_kafka_message_t *rkmessage, void *opaque);

	/* Error callback */
	void (*error_cb) (rd_kafka_t *rk, int err,
			  const char *reason, void *opaque);

	/* Throttle callback */
	void (*throttle_cb) (rd_kafka_t *rk, const char *broker_name,
			     int32_t broker_id, int throttle_time_ms,
			     void *opaque);

	/* Stats callback */
	int (*stats_cb) (rd_kafka_t *rk,
			 char *json,
			 size_t json_len,
			 void *opaque);

        /* Log callback */
        void (*log_cb) (const rd_kafka_t *rk, int level,
                        const char *fac, const char *buf);
        int    log_level;
	int    log_thread_name;
        int    log_connection_close;

        /* Socket creation callback */
        int (*socket_cb) (int domain, int type, int protocol, void *opaque);

		/* File open callback */
        int (*open_cb) (const char *pathname, int flags, mode_t mode,
                        void *opaque);

	/* Opaque passed to callbacks. */
	void  *opaque;
};


typedef rd_kafka_topic_partition_t *RdKafka__TopicPartition;
typedef rd_kafka_topic_partition_list_t *RdKafka__TopicPartitionList;
typedef rd_kafka_message_t *RdKafka__Message;
typedef rd_kafka_conf_t *RdKafka__Conf;
typedef rd_kafka_topic_conf_t *RdKafka__TopicConf;
typedef rd_kafka_topic_t *RdKafka__Topic;
typedef rd_kafka_t *RdKafka;

typedef struct rd_kafka_metadata *RdKafka__Metadata;
typedef rd_kafka_metadata_broker_t *RdKafka__MetadataBroker;
typedef rd_kafka_metadata_partition_t *RdKafka__MetadataPartition;
typedef rd_kafka_metadata_topic_t *RdKafka__MetadataTopic;
typedef struct rd_kafka_group_member_info *RdKafka__GroupMemberInfo;
typedef struct rd_kafka_group_info *RdKafka__GroupInfo;
typedef struct rd_kafka_group_list *RdKafka__GroupList;
#if RD_KAFKA_VERSION >= 0x000902ff
typedef rd_kafka_event_t *RdKafka__Event;
#endif
typedef rd_kafka_queue_t *RdKafka__Queue;

/* several things like payload, opaque, metadata... use void* which I assume from Perl to be a char* */
typedef char *VOIDBUFFER;

#define T_PTROBJ_IN(var, arg, type, ntype, func) STMT_START { \
        if (SvROK(arg) && sv_derived_from(arg, #ntype)) {    \
            IV tmp = SvIV((SV*) SvRV(arg)); \
            var = INT2PTR(type, tmp); \
        } else \
            Perl_croak_nocontext("RdKafka::" #func ": $" #var " is not of type " #ntype); \
    } STMT_END
#define T_PTROBJ_OUT(arg, ntype, var) STMT_START { \
        sv_setref_pv(arg, #ntype, (void*)var); \
    } STMT_END

/* make this a compile flag? */
// #define PERL_RDKAFKA_DEBUG 1

/* no idea what's reasonable - probably should be configurable somehow */
#define PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE 1024

#define PERL_RDKAFKA_READ_BUF_SIZE 512


MODULE = RdKafka    PACKAGE = RdKafka    PREFIX = rd_kafka_


### VERSION

## (...) so these can be called as class or object methods or functions...
int
rd_kafka_version(...)

const char *
rd_kafka_version_str(...)


### CONSTANTS, ERRORS, TYPES

## omitted: deprecated RD_KAFKA_DEBUG_CONTEXTS

const char *
rd_kafka_get_debug_contexts(...)

## original:
## void rd_kafka_get_err_descs (const struct rd_kafka_err_desc **errdescs, size_t *cntp)
## returns an href like this { $code => { name => '...', desc => '...' } }
SV *
rd_kafka_get_err_descs(...)
  PREINIT:
    const struct rd_kafka_err_desc *errdesc;
    size_t cnt, i;
    char hv_outer_key[8];
    HV *hv_outer, *hv_inner;
    SV *sv;
  CODE:
    rd_kafka_get_err_descs(&errdesc, &cnt);

    hv_outer = newHV();

    for (i = 0; i < cnt; ++i) {
        /* between -167 and -1 it's mostly empty (except -100) */
        if (errdesc[i].code == 0 && errdesc[i].name == NULL && errdesc[i].desc == NULL)
            continue;

        hv_inner = newHV();
        sv = newSVpv(errdesc[i].name, 0);
        if (!hv_store(hv_inner, "name", 4, sv, 0))
            croak("hv_store (name) failed");
        sv = newSVpv(errdesc[i].desc, 0);
        if (!hv_store(hv_inner, "desc", 4, newSVpv(errdesc[i].desc, 0), 0))
            croak("hv_store (desc) failed");

        snprintf(hv_outer_key, 8, "%d", errdesc[i].code);
        hv_store(hv_outer, hv_outer_key, strlen(hv_outer_key), newRV_noinc((SV *)hv_inner), 0);
    }
    /* note: RETVAL is SV*, so automatically mortal */
    RETVAL = newRV_noinc((SV *)hv_outer);
  OUTPUT:
    RETVAL

const char *
rd_kafka_err2str(...)
  PREINIT:
    rd_kafka_resp_err_t err;
    SV *err_sv;
  CODE:
    err_sv = (items == 1) ? ST(0) : ST(1);
    err = (rd_kafka_resp_err_t)SvIV(err_sv);
    RETVAL = rd_kafka_err2str(err);
  OUTPUT:
    RETVAL

const char *
rd_kafka_err2name(...)
  PREINIT:
    rd_kafka_resp_err_t err;
    SV *err_sv;
  CODE:
    err_sv = (items == 1) ? ST(0) : ST(1);
    err = (rd_kafka_resp_err_t)SvIV(err_sv);
    RETVAL = rd_kafka_err2name(err);
  OUTPUT:
    RETVAL

rd_kafka_resp_err_t
rd_kafka_last_error(...)

rd_kafka_resp_err_t
rd_kafka_errno2err(...)
  PREINIT:
    int errnox;
    SV *err_sv;
  CODE:
    err_sv = (items == 1) ? ST(0) : ST(1);
    errnox = SvIV(err_sv);
    RETVAL = rd_kafka_errno2err(errnox);
  OUTPUT:
    RETVAL

int
rd_kafka_errno(...)


### MAIN HANDLES

## original:
## rd_kafka_t *
## rd_kafka_new(rd_kafka_type_t type, rd_kafka_conf_t *conf, char *errstr, size_t errstr_size)
## For now at least, this will croak if there's an error from rd_kafka_new.
RdKafka
rd_kafka_new_xs(rd_kafka_type_t type, RdKafka::Conf conf)
  PREINIT:
    char buf[PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE];
  CODE:
    RETVAL = rd_kafka_new(type, conf, buf, PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE);
    if (!RETVAL)   /* maybe should return &PL_sv_undef */
        croak("RdKafka->new failed ERROR: %s\n", buf);
  OUTPUT:
    RETVAL

## This is omitted; the Perl DESTROY will call it, in rd_kafka_tPtr below
## void
## rd_kafka_destroy(rd_kafka_t *rk)

const char *
rd_kafka_name(RdKafka rk)

## TODO
## see rd_kafka_mem_free
char *
rd_kafka_memberid(RdKafka rk)

int
rd_kafka_poll(RdKafka rk, int timeout_ms)

## TODO: tests once callbacks are implemented
void
rd_kafka_yield(RdKafka rk)

rd_kafka_resp_err_t
rd_kafka_pause_partitions(RdKafka rk, RdKafka::TopicPartitionList partitions)

rd_kafka_resp_err_t
rd_kafka_resume_partitions(RdKafka rk, RdKafka::TopicPartitionList partitions)

rd_kafka_resp_err_t
rd_kafka_query_watermark_offsets_xs(RdKafka rk, const char *topic, int32_t partition, OUT int64_t low, OUT int64_t high, int timeout_ms)
  CODE:
    RETVAL = rd_kafka_query_watermark_offsets(rk, topic, partition, &low, &high, timeout_ms);
  OUTPUT:
    RETVAL
    low
    high

rd_kafka_resp_err_t
rd_kafka_get_watermark_offsets_xs(RdKafka rk, const char *topic, int32_t partition, OUT int64_t low, OUT int64_t high)
  CODE:
    RETVAL = rd_kafka_get_watermark_offsets(rk, topic, partition, &low, &high);
  OUTPUT:
    RETVAL
    low
    high

# leave this out?
# "rd_kafka_mem_free() must only be used for pointers returned by APIs
# that explicitly mention using this function for freeing."
# in particular, rd_kafka_memberid needs it,
# but can probably do it when the SV* holding the string goes out of scope
void
rd_kafka_mem_free(RdKafka rk, void *ptr)

## TODO - after 0.9.2 installed
#if RD_KAFKA_VERSION >= 0x000902ff

RdKafka::Queue
rd_kafka_queue_get_main(RdKafka rk)

RdKafka::Queue
rd_kafka_queue_get_consumer(RdKafka rk)

#endif


## (simple legacy consumer API is omitted)
## do we need it for 0.9.1?


### KAFKACONSUMER API

rd_kafka_resp_err_t
rd_kafka_subscribe(RdKafka rk, RdKafka::TopicPartitionList topics)

rd_kafka_resp_err_t
rd_kafka_unsubscribe(RdKafka rk)

##rd_kafka_resp_err_t
##rd_kafka_subscription_xs(RdKafka rk, OUT RdKafka::TopicPartitionList topics)
##  CODE:
##    RETVAL = rd_kafka_subscription(rk, &topics);
##  OUTPUT:
##    RETVAL
##    topics

RdKafka::Message
rd_kafka_consumer_poll(RdKafka rk, int timeout_ms)

rd_kafka_resp_err_t
rd_kafka_consumer_close(RdKafka rk)

## rd_kafka_resp_err_t
## rd_kafka_assign(RdKafka rk, const RdKafka::TopicPartitionList partitions)

## rd_kafka_resp_err_t
## rd_kafka_assignment(RdKafka rk, rd_kafka_topic_partition_list_t **partitions)

## rd_kafka_resp_err_t
## rd_kafka_commit(RdKafka rk, const RdKafka::TopicPartitionList offsets, int async)

rd_kafka_resp_err_t
rd_kafka_commit_message(RdKafka rk, RdKafka::Message rkmessage, int async)

#if RD_KAFKA_VERSION >= 0x000902ff

## rd_kafka_resp_err_t
## rd_kafka_commit_queue(RdKafka rk, const RdKafka::TopicPartitionList offsets, rd_kafka_queue_t *rkqu, void (*cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, RdKafka::TopicPartitionList offsets, void *opaque), void *opaque)

#endif

## rd_kafka_resp_err_t
## rd_kafka_committed(RdKafka rk, RdKafka::TopicPartitionList partitions, int timeout_ms)

## rd_kafka_resp_err_t
## rd_kafka_position(RdKafka rk, RdKafka::TopicPartitionList partitions)

#if RD_KAFKA_VERSION >= 0x000902ff

rd_kafka_resp_err_t
rd_kafka_flush(RdKafka rk, int timeout_ms)

#endif

VOIDBUFFER
rd_kafka_opaque(RdKafka rk)
  CODE:
    RETVAL = (VOIDBUFFER)rd_kafka_opaque(rk);
  OUTPUT:
    RETVAL


### METADATA API

void
rd_kafka_metadata_xs(RdKafka rk, int all_topics, SV *only_rkt, int timeout_ms)
  PREINIT:
    const struct rd_kafka_metadata *metadatap;
    rd_kafka_resp_err_t err;
    RdKafka__Topic only_rkt_c = 0;
  PPCODE:
    if (SvOK(only_rkt))
        T_PTROBJ_IN(only_rkt_c, only_rkt, RdKafka__Topic, RdKafka::Topic, metadata_xs);
    err = rd_kafka_metadata(rk, all_topics, only_rkt_c, &metadatap, timeout_ms);
    EXTEND(SP, 2);
    PUSHs(sv_2mortal(newSViv(err)));
    ST(1) = sv_newmortal();
    T_PTROBJ_OUT(ST(1), RdKafka::Metadata, metadatap);


### CLIENT GROUP INFORMATION
## https://cwiki.apache.org/confluence/display/KAFKA/A+Guide+To+The+Kafka+Protocol#AGuideToTheKafkaProtocol-GroupMembershipAPI

void
rd_kafka_list_groups_xs(RdKafka rk, SV *group, int timeout_ms)
  PREINIT:
    const char *group_c;
    rd_kafka_resp_err_t err;
    const struct rd_kafka_group_list *grplist;
  PPCODE:
    if (SvOK(group))
        group_c = SvPV_nolen(group);
    err = rd_kafka_list_groups(rk, group_c, &grplist, timeout_ms);
    EXTEND(SP, 2);
    PUSHs(sv_2mortal(newSViv(err)));
    ST(1) = sv_newmortal();
    T_PTROBJ_OUT(ST(1), RdKafka::GroupList, grplist);


### MISCELLANEOUS

## default broker list is in conf: bootstrap.servers (or metadata.broker.list)
int
rd_kafka_brokers_add(RdKafka rk, const char *brokerlist)

## RD_EXPORT RD_DEPRECATED  - use rd_kafka_conf_set_log_cb
## void rd_kafka_set_logger(RdKafka rk,
##			  void (*func) (const rd_kafka_t *rk, int level,
##					const char *fac, const char *buf));

## log levels seem to be from syslog.h
void
rd_kafka_set_log_level(RdKafka rk, int level)

void
rd_kafka_log_print(RdKafka rk, int level, const char *fac, const char *buf)

void
rd_kafka_log_syslog(RdKafka rk, int level, const char *fac, const char *buf)

int
rd_kafka_outq_len(RdKafka rk)

## TODO: make fp default to STDOUT/STDERR?
void
rd_kafka_dump(RdKafka rk, SV *fh)
  INIT:
    FILE *fp;
    char buf[PERL_RDKAFKA_READ_BUF_SIZE];
  CODE:
    fp = tmpfile();
    if (fp == (FILE*)NULL)
        croak("tmpfile failed (errno: %d)", errno);

    rd_kafka_dump(fp, rk);

    rewind(fp);
    for (;;) {
        size_t n = fread(buf, 1, PERL_RDKAFKA_READ_BUF_SIZE, fp);
        if (n) {
            PUSHMARK(SP);
            XPUSHs(fh);
            XPUSHs(sv_2mortal(newSVpvn(buf, n)));
            PUTBACK;
            call_pv("RdKafka::rd_kafka_dump_print_fh", G_VOID);
        }
        if (n < PERL_RDKAFKA_READ_BUF_SIZE)
            break;
    }
    fclose(fp);

int
rd_kafka_thread_cnt(...)

## TODO: should it be a class method, or leave as a function?
int
rd_kafka_wait_destroyed(int timeout_ms)

void
rd_kafka_DESTROY(RdKafka rk)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka\n");
#endif
    rd_kafka_destroy(rk);  /* should do this? */


### EXPERIMENTAL API

rd_kafka_resp_err_t
rd_kafka_poll_set_consumer(RdKafka rk)



##########

### STRUCT CLASSES

MODULE = RdKafka    PACKAGE = RdKafka::TopicPartition    PREFIX = rd_kafka_topic_partition_

### TOPIC PARTITION

#if RD_KAFKA_VERSION >= 0x000902ff

## "This must not be called for elements in a topic partition list."
## rd_kafka_event_topic_partition needs this to destroy its return value.
void
rd_kafka_topic_partition_destroy(RdKafka::TopicPartition rktpar)

#endif

void
rd_kafka_topic_partition_DESTROY(RdKafka::TopicPartition toppar)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::TopicPartition\n");
#endif
    /* I think this should not be done, (?)
       since rd_kafka_topic_partition_destroy should not be called
       on elements in a topic-partition list
       rd_kafka_topic_partition_destroy(toppar);  */

## TODO: needs setters, too
## struct rd_kafka_topic_partition_t accessors: topic, partition, offset, [metadata,] metadata_size(?), [opaque,] err

char *
rd_kafka_topic_partition_topic(RdKafka::TopicPartition toppar)
  CODE:
    RETVAL = toppar->topic;
  OUTPUT:
    RETVAL

int32_t
rd_kafka_topic_partition_partition(RdKafka::TopicPartition toppar)
  CODE:
    RETVAL = toppar->partition;
  OUTPUT:
    RETVAL

int64_t
rd_kafka_topic_partition_offset(RdKafka::TopicPartition toppar)
  CODE:
    RETVAL = toppar->offset;
  OUTPUT:
    RETVAL

## TODO: deferred until implementing metadata API (I think)
##        void        *metadata;          /**< Metadata */
## ???
## rd_kafka_topic_partition_metadata(RdKafka::TopicPartition toppar)
##   CODE:
##     RETVAL = toppar->metadata;
##   OUTPUT:
##     RETVAL

size_t
rd_kafka_topic_partition_metadata_size(RdKafka::TopicPartition toppar)
  CODE:
    RETVAL = toppar->metadata_size;
  OUTPUT:
    RETVAL

## TODO: figure out later what "opaque" is
##        void        *opaque;            /**< Application opaque */
## ???
## rd_kafka_topic_partition_opaque(RdKafka::TopicPartition toppar)
##   CODE:
##     RETVAL = toppar->opaque;
##   OUTPUT:
##     RETVAL

rd_kafka_resp_err_t
rd_kafka_topic_partition_err(RdKafka::TopicPartition toppar)
  CODE:
    RETVAL = toppar->err;
  OUTPUT:
    RETVAL


MODULE = RdKafka    PACKAGE = RdKafka::TopicPartitionList    PREFIX = rd_kafka_topic_partition_list_

RdKafka::TopicPartitionList
rd_kafka_topic_partition_list_new(char *package, int size)
  C_ARGS:
    size

RdKafka::TopicPartition
rd_kafka_topic_partition_list_add(RdKafka::TopicPartitionList rktparlist, const char *topic, int32_t partition)

void
rd_kafka_topic_partition_list_add_range(RdKafka::TopicPartitionList rktparlist, const char *topic, int32_t start, int32_t stop)

int
rd_kafka_topic_partition_list_del(RdKafka::TopicPartitionList rktparlist, const char *topic, int32_t partition)

int
rd_kafka_topic_partition_list_del_by_idx(RdKafka::TopicPartitionList rktparlist, int idx)

RdKafka::TopicPartitionList
rd_kafka_topic_partition_list_copy(RdKafka::TopicPartitionList src)

rd_kafka_resp_err_t
rd_kafka_topic_partition_list_set_offset(RdKafka::TopicPartitionList rktparlist, const char *topic, int32_t partition, int64_t offset)

RdKafka::TopicPartition
rd_kafka_topic_partition_list_find(RdKafka::TopicPartitionList rktparlist, const char *topic, int32_t partition)

void
rd_kafka_topic_partition_list_DESTROY(RdKafka::TopicPartitionList list)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::TopicPartitionList\n");
#endif
    if (list)
        rd_kafka_topic_partition_list_destroy(list);

## struct rd_kafka_topic_partition_list_t accessors: cnt, size, elems

int
cnt(RdKafka::TopicPartitionList list)
  CODE:
    RETVAL = list->cnt;
  OUTPUT:
    RETVAL

int
size(RdKafka::TopicPartitionList list)
  CODE:
    RETVAL = list->size;
  OUTPUT:
    RETVAL

## sub elems is in RdKafka/TopicPartitionList.pm
RdKafka::TopicPartition
elem_n(RdKafka::TopicPartitionList list, int i)
  CODE:
    RETVAL = &list->elems[i];
  OUTPUT:
    RETVAL


MODULE = RdKafka    PACKAGE = RdKafka::Message    PREFIX = rd_kafka_message_

## rd_kafka_resp_err_t err;   /**< Non-zero for error signaling. */
## rd_kafka_topic_t *rkt;     /**< Topic */
## int32_t partition;         /**< Partition */
## void   *payload;           /**< Producer: original message payload.
## 			    * Consumer: Depends on the value of \c err :
## 			    * - \c err==0: Message payload.
## 			    * - \c err!=0: Error string */
## size_t  len;               /**< Depends on the value of \c err :
## 			    * - \c err==0: Message payload length
## 			    * - \c err!=0: Error string length */
## void   *key;               /**< Depends on the value of \c err :
## 			    * - \c err==0: Optional message key */
## size_t  key_len;           /**< Depends on the value of \c err :
## 			    * - \c err==0: Optional message key length*/
## int64_t offset;            /**< Consume:
##                                 * - Message offset (or offset for error
## 			    *   if \c err!=0 if applicable).
##                                 * - dr_msg_cb:
##                                 *   Message offset assigned by broker.
##                                 *   If \c produce.offset.report is set then
##                                 *   each message will have this field set,
##                                 *   otherwise only the last message in
##                                 *   each produced internal batch will
##                                 *   have this field set, otherwise 0. */

### MESSAGES

## TODO: DESTROY?
void
rd_kafka_message_destroy(RdKafka::Message rkmessage)

## TODO: test these once we can consume things
const char *
rd_kafka_message_errstr(RdKafka::Message rkmessage)

void
rd_kafka_message_timestamp(RdKafka::Message rkmessage)
  PREINIT:
    int64_t ts;
    rd_kafka_timestamp_type_t tstype;
  PPCODE:
    ts = rd_kafka_message_timestamp(rkmessage, &tstype);
    EXTEND(SP, 2);
    PUSHs(sv_2mortal(newSViv(ts)));
    PUSHs(sv_2mortal(newSViv(tstype)));


MODULE = RdKafka    PACKAGE = RdKafka::Conf    PREFIX = rd_kafka_conf_

### CONFIGURATION

RdKafka::Conf
rd_kafka_conf_new(char *package)
  C_ARGS:

## TODO (DESTROY?)
## I believe rd_kafka_new will normally destroy this itself (?)
## but I guess if rd_kafka_conf_dup is called...
## (should add something to DESTROY when it goes out of scope, though...)
void
rd_kafka_conf_destroy(RdKafka::Conf conf)

RdKafka::Conf
rd_kafka_conf_dup(RdKafka::Conf conf)

### TODO this conf section  #####

## #if RD_KAFKA_VERSION >= 0x000902ff

### handle version
## void
## rd_kafka_conf_set_events(RdKafka::Conf conf, int events)

## #endif

## @deprecated See rd_kafka_conf_set_dr_msg_cb()
## void rd_kafka_conf_set_dr_cb(RdKafka::Conf conf,
##			      void (*dr_cb) (rd_kafka_t *rk,
##					     void *payload, size_t len,
##					     rd_kafka_resp_err_t err,
##					     void *opaque, void *msg_opaque))

## callbacks - these will need special handling like
## PerlOGRECallback.{c,h} , PerlOGRECallbackManager.{c.h}
## void
## rd_kafka_conf_set_dr_msg_cb(RdKafka::Conf conf, void (*dr_msg_cb) (rd_kafka_t *rk, const RdKafka::Message rkmessage, void *opaque))
##
## void
## rd_kafka_conf_set_consume_cb(RdKafka::Conf conf, void (*consume_cb) (RdKafka::Message rkmessage, void *opaque))
##
## void
## rd_kafka_conf_set_rebalance_cb(RdKafka::Conf conf, void (*rebalance_cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, RdKafka::TopicPartitionList partitions, void *opaque))
##
## void
## rd_kafka_conf_set_offset_commit_cb(RdKafka::Conf conf, void (*offset_commit_cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, RdKafka::TopicPartitionList offsets, void *opaque))
##
## void
## rd_kafka_conf_set_error_cb(RdKafka::Conf conf, void (*error_cb) (rd_kafka_t *rk, int err, const char *reason, void *opaque))
##
## void
## rd_kafka_conf_set_throttle_cb(RdKafka::Conf conf, void (*throttle_cb) (rd_kafka_t *rk, const char *broker_name, int32_t broker_id, int throttle_time_ms, void *opaque))
##
## void
## rd_kafka_conf_set_log_cb(RdKafka::Conf conf, void (*log_cb) (const rd_kafka_t *rk, int level, const char *fac, const char *buf))
##
## void
## rd_kafka_conf_set_stats_cb(RdKafka::Conf conf, int (*stats_cb) (rd_kafka_t *rk, char *json, size_t json_len, void *opaque))
##
## void
## rd_kafka_conf_set_socket_cb(RdKafka::Conf conf, int (*socket_cb) (int domain, int type, int protocol, void *opaque))

## #if RD_KAFKA_VERSION >= 0x000902ff

## void
## rd_kafka_conf_set_connect_cb(RdKafka::Conf conf, int (*connect_cb) (int sockfd, const struct sockaddr *addr, int addrlen, const char *id, void *opaque))
##
## void
## rd_kafka_conf_set_closesocket_cb(RdKafka::Conf conf, int (*closesocket_cb) (int sockfd, void *opaque))

## #endif

## #ifndef _MSC_VER
## void rd_kafka_conf_set_open_cb(RdKafka::Conf conf, int (*open_cb) (const char *pathname, int flags, mode_t mode, void *opaque))
## #endif

## "Sets the application's opaque pointer that will be passed to callbacks"
void
rd_kafka_conf_set_opaque(RdKafka::Conf conf, VOIDBUFFER opaque)

## note: this actually destroys any existing topic conf at conf->topic_conf
void
rd_kafka_conf_set_default_topic_conf(RdKafka::Conf conf, RdKafka::TopicConf tconf)

## rd_kafka_conf_res_t
## rd_kafka_conf_set(RdKafka::Conf conf, const char *name, const char *value, char *errstr, size_t errstr_size)
## TODO?
## just croaking on error for now
void
rd_kafka_conf_set(RdKafka::Conf conf, const char *name, const char *value)
  PREINIT:
    char buf[PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE];
    rd_kafka_conf_res_t res;
  CODE:
    res = rd_kafka_conf_set(conf, name, value, buf, PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE);
    if (res != RD_KAFKA_CONF_OK)
        croak("rd_kafka_conf_set failed (%d): %s", res, buf);

void
rd_kafka_conf_get(RdKafka::Conf conf, const char *name)
  PREINIT:
    rd_kafka_conf_res_t res;
    char dest[512];
    size_t dest_size = sizeof(dest);
  PPCODE:
    /* this can be more dynamic if necessary */
    res = rd_kafka_conf_get(conf, name, dest, &dest_size);
    EXTEND(SP, 2);
    PUSHs(sv_2mortal(newSViv(res)));
    if (res == RD_KAFKA_CONF_OK)
        PUSHs(sv_2mortal(newSVpv(dest, 0)));

## The dump must be freed with `rd_kafka_conf_dump_free()`.
SV *
rd_kafka_conf_dump(RdKafka::Conf conf)
  PREINIT:
    size_t cntp, i;
    const char **dump;
    HV *hv;
  CODE:
    dump = rd_kafka_conf_dump(conf, &cntp);
    hv = newHV();
    for (i = 0; i < cntp; i += 2) {
        const char *key = dump[i];
        const char *val = dump[i + 1];
        if (!hv_store(hv, key, strlen(key), newSVpv(val, 0), 0))
           croak("hv_store (conf_dump) failed");
    }
    rd_kafka_conf_dump_free(dump, cntp);
    RETVAL = newRV_noinc((SV *)hv);
  OUTPUT:
    RETVAL

## void
## rd_kafka_conf_dump_free(const char **arr, size_t cnt)

## fix fp as with rd_kafka_dump
void
rd_kafka_conf_properties_show(RdKafka::Conf conf, FILE *fp)
  C_ARGS:
    fp

## rd_kafka_new destroys the conf, so can't call rd_kafka_conf_destroy.
## Not sure how to deal with that now.
void
rd_kafka_conf_DESTROY(RdKafka::Conf conf)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::Conf\n");
#endif
    /* rd_kafka_conf_destroy(conf); */

## struct rd_kafka_conf_t accessors: (many... not all exposed here yet; it's not really part of the public API)

int
max_msg_size(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->max_msg_size;
  OUTPUT:
    RETVAL

int
recv_max_msg_size(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->recv_max_msg_size;
  OUTPUT:
    RETVAL

int
max_inflight(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->max_inflight;
  OUTPUT:
    RETVAL

int
metadata_request_timeout_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->metadata_request_timeout_ms;
  OUTPUT:
    RETVAL

int
metadata_refresh_interval_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->metadata_refresh_interval_ms;
  OUTPUT:
    RETVAL

int
metadata_refresh_fast_cnt(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->metadata_refresh_fast_cnt;
  OUTPUT:
    RETVAL

int
metadata_refresh_fast_interval_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->metadata_refresh_fast_interval_ms;
  OUTPUT:
    RETVAL

int
metadata_refresh_sparse(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->metadata_refresh_sparse;
  OUTPUT:
    RETVAL

int
debug(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->debug;
  OUTPUT:
    RETVAL

int
broker_addr_ttl(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->broker_addr_ttl;
  OUTPUT:
    RETVAL

int
broker_addr_family(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->broker_addr_family;
  OUTPUT:
    RETVAL

int
socket_timeout_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->socket_timeout_ms;
  OUTPUT:
    RETVAL

int
socket_blocking_max_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->socket_blocking_max_ms;
  OUTPUT:
    RETVAL

int
socket_sndbuf_size(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->socket_sndbuf_size;
  OUTPUT:
    RETVAL

int
socket_rcvbuf_size(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->socket_rcvbuf_size;
  OUTPUT:
    RETVAL

int
socket_keepalive(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->socket_keepalive;
  OUTPUT:
    RETVAL

int
socket_max_fails(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->socket_max_fails;
  OUTPUT:
    RETVAL

char *
client_id_str(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->client_id_str;
  OUTPUT:
    RETVAL

## rd_kafkap_str_t *
## client_id(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->client_id;
##   OUTPUT:
##     RETVAL

char *
brokerlist(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->brokerlist;
  OUTPUT:
    RETVAL

int
stats_interval_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->stats_interval_ms;
  OUTPUT:
    RETVAL

int
term_sig(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->term_sig;
  OUTPUT:
    RETVAL

int
reconnect_jitter_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->reconnect_jitter_ms;
  OUTPUT:
    RETVAL

int
api_version_request(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->api_version_request;
  OUTPUT:
    RETVAL

int
api_version_fallback_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->api_version_fallback_ms;
  OUTPUT:
    RETVAL

char *
broker_version_fallback(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->broker_version_fallback;
  OUTPUT:
    RETVAL

## rd_kafka_secproto_t
## security_protocol(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->security_protocol;
##   OUTPUT:
##     RETVAL

## struct 
## ssl(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->ssl;
##   OUTPUT:
##     RETVAL

int
coord_query_intvl_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->coord_query_intvl_ms;
  OUTPUT:
    RETVAL

int
builtin_features(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->builtin_features;
  OUTPUT:
    RETVAL

int
queued_min_msgs(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->queued_min_msgs;
  OUTPUT:
    RETVAL

int
queued_max_msg_kbytes(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->queued_max_msg_kbytes;
  OUTPUT:
    RETVAL

int64_t
queued_max_msg_bytes(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->queued_max_msg_bytes;
  OUTPUT:
    RETVAL

int
fetch_wait_max_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->fetch_wait_max_ms;
  OUTPUT:
    RETVAL

int
fetch_msg_max_bytes(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->fetch_msg_max_bytes;
  OUTPUT:
    RETVAL

int
fetch_min_bytes(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->fetch_min_bytes;
  OUTPUT:
    RETVAL

int
fetch_error_backoff_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->fetch_error_backoff_ms;
  OUTPUT:
    RETVAL

char *
group_id_str(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->group_id_str;
  OUTPUT:
    RETVAL

## rd_kafkap_str_t *
## group_id(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->group_id;
##   OUTPUT:
##     RETVAL

## rd_kafka_pattern_list_t *
## topic_blacklist(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->topic_blacklist;
##   OUTPUT:
##     RETVAL

## struct rd_kafka_topic_conf_s *
## topic_conf(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->topic_conf;
##   OUTPUT:
##     RETVAL

int
enable_auto_commit(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->enable_auto_commit;
  OUTPUT:
    RETVAL

int
enable_auto_offset_store(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->enable_auto_offset_store;
  OUTPUT:
    RETVAL

int
auto_commit_interval_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->auto_commit_interval_ms;
  OUTPUT:
    RETVAL

int
group_session_timeout_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->group_session_timeout_ms;
  OUTPUT:
    RETVAL

int
group_heartbeat_intvl_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->group_heartbeat_intvl_ms;
  OUTPUT:
    RETVAL

## rd_kafkap_str_t *
## group_protocol_type(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->group_protocol_type;
##   OUTPUT:
##     RETVAL

char *
partition_assignment_strategy(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->partition_assignment_strategy;
  OUTPUT:
    RETVAL

## rd_list_t
## partition_assignors(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->partition_assignors;
##   OUTPUT:
##     RETVAL

int
enabled_assignor_cnt(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->enabled_assignor_cnt;
  OUTPUT:
    RETVAL

## struct rd_kafka_assignor_s *
## assignor(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->assignor;
##   OUTPUT:
##     RETVAL

## no return:
## rebalance_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->rebalance_cb;
##   OUTPUT:
##     RETVAL

## no return:
## offset_commit_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->offset_commit_cb;
##   OUTPUT:
##     RETVAL

## rd_kafka_offset_method_t
## offset_store_method(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->offset_store_method;
##   OUTPUT:
##     RETVAL

int
queue_buffering_max_msgs(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->queue_buffering_max_msgs;
  OUTPUT:
    RETVAL

int
buffering_max_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->buffering_max_ms;
  OUTPUT:
    RETVAL

int
max_retries(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->max_retries;
  OUTPUT:
    RETVAL

int
retry_backoff_ms(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->retry_backoff_ms;
  OUTPUT:
    RETVAL

int
batch_num_messages(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->batch_num_messages;
  OUTPUT:
    RETVAL

## rd_kafka_compression_t
## compression_codec(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->compression_codec;
##   OUTPUT:
##     RETVAL

int
dr_err_only(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->dr_err_only;
  OUTPUT:
    RETVAL

## no return:
## dr_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->dr_cb;
##   OUTPUT:
##     RETVAL

## no return:
## dr_msg_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->dr_msg_cb;
##   OUTPUT:
##     RETVAL

## no return:
## consume_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->consume_cb;
##   OUTPUT:
##     RETVAL

## no return:
## error_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->error_cb;
##   OUTPUT:
##     RETVAL

## no return:
## throttle_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->throttle_cb;
##   OUTPUT:
##     RETVAL

## no return:
## stats_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->stats_cb;
##   OUTPUT:
##     RETVAL

## no return:
## log_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->log_cb;
##   OUTPUT:
##     RETVAL

int
log_level(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->log_level;
  OUTPUT:
    RETVAL

int
log_thread_name(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->log_thread_name;
  OUTPUT:
    RETVAL

int
log_connection_close(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->log_connection_close;
  OUTPUT:
    RETVAL

## no return:
## socket_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->socket_cb;
##   OUTPUT:
##     RETVAL

## no return:
## open_cb(RdKafka::Conf conf)
##   CODE:
##     RETVAL = conf->open_cb;
##   OUTPUT:
##     RETVAL

void *
opaque(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->opaque;
  OUTPUT:
    RETVAL

#if RD_KAFKA_VERSION >= 0x000902ff

int
enabled_events(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->enabled_events;
  OUTPUT:
    RETVAL

int
msg_copy_max_size(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->msg_copy_max_size;
  OUTPUT:
    RETVAL

int
enable_partition_eof(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->enable_partition_eof;
  OUTPUT:
    RETVAL

int
queue_buffering_max_kbytes(RdKafka::Conf conf)
  CODE:
    RETVAL = conf->queue_buffering_max_kbytes;
  OUTPUT:
    RETVAL

#endif


MODULE = RdKafka    PACKAGE = RdKafka::TopicConf    PREFIX = rd_kafka_topic_conf_

### TOPIC CONFIGURATION

RdKafka::TopicConf
rd_kafka_topic_conf_new(char *package)
  C_ARGS:

RdKafka::TopicConf
rd_kafka_topic_conf_dup(RdKafka::TopicConf conf)

void
rd_kafka_topic_conf_get(RdKafka::TopicConf conf, const char *name)
  PREINIT:
    rd_kafka_conf_res_t res;
    char dest[512];
    size_t dest_size = sizeof(dest);
  PPCODE:
    /* this can be more dynamic if necessary */
    res = rd_kafka_topic_conf_get(conf, name, dest, &dest_size);
    EXTEND(SP, 2);
    PUSHs(sv_2mortal(newSViv(res)));
    if (res == RD_KAFKA_CONF_OK)
        PUSHs(sv_2mortal(newSVpv(dest, 0)));

## TODO: errstr+errstr_size
void
rd_kafka_topic_conf_set(RdKafka::TopicConf conf, const char *name, const char *value)
  PREINIT:
    char buf[PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE];
    rd_kafka_conf_res_t res;
  CODE:
    res = rd_kafka_topic_conf_set(conf, name, value, buf, PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE);
    if (res != RD_KAFKA_CONF_OK)
        croak("rd_kafka_topic_conf_set failed (%d): %s", res, buf);

## strangely, rd_kafka_opaque (on RdKafka) is what fetches the opaque..
void
rd_kafka_topic_conf_set_opaque(RdKafka::TopicConf conf, VOIDBUFFER opaque)

## The dump must be freed with `rd_kafka_conf_dump_free()`.
## identical to rd_kafka_conf_dump except for TopicConf in param and rd_kafka_topic_conf_dump call
SV *
rd_kafka_topic_conf_dump(RdKafka::TopicConf conf)
  PREINIT:
    size_t cntp, i;
    const char **dump;
    HV *hv;
  CODE:
    dump = rd_kafka_topic_conf_dump(conf, &cntp);
    hv = newHV();
    for (i = 0; i < cntp; i += 2) {
        const char *key = dump[i];
        const char *val = dump[i + 1];
        if (!hv_store(hv, key, strlen(key), newSVpv(val, 0), 0))
           croak("hv_store (conf_dump) failed");
    }
    rd_kafka_conf_dump_free(dump, cntp);
    RETVAL = newRV_noinc((SV *)hv);
  OUTPUT:
    RETVAL

## TODO
## void
## rd_kafka_topic_conf_set_partitioner_cb(RdKafka::TopicConf topic_conf, int32_t (*partitioner) (const rd_kafka_topic_t *rkt, const void *keydata, size_t keylen, int32_t partition_cnt, void *rkt_opaque, void *msg_opaque))

void
rd_kafka_topic_conf_destroy(RdKafka::TopicConf topic_conf)

void
rd_kafka_topic_conf_DESTROY(RdKafka::TopicConf topic_conf)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::TopicConf\n");
#endif
    /* rd_kafka_topic_conf_destroy(topic_conf); */


MODULE = RdKafka    PACKAGE = RdKafka::Topic    PREFIX = rd_kafka_topic_

## TODO: conf optional
## * \p conf is an optional configuration for the topic created with
## * `rd_kafka_topic_conf_new()` that will be used instead of the default
## * topic configuration.
## * The \p conf object is freed by this function and must not be used or
## * destroyed by the application sub-sequently.
## * See `rd_kafka_topic_conf_set()` et.al for more information.
## *
## * Topic handles are refcounted internally and calling rd_kafka_topic_new()
## * again with the same topic name will return the previous topic handle
## * without updating the original handle's configuration.
## * Applications must eventually call rd_kafka_topic_destroy() for each
## * succesfull call to rd_kafka_topic_new() to clear up resources.
RdKafka::Topic
rd_kafka_topic_new_xs(char *package, RdKafka rk, const char *topic, RdKafka::TopicConf conf)
  CODE:
    RETVAL = rd_kafka_topic_new(rk, topic, conf);
  OUTPUT:
    RETVAL

const char *
rd_kafka_topic_name(RdKafka::Topic rkt)

void *
rd_kafka_topic_opaque(RdKafka::Topic rkt)

## "This function must only be called from inside a partitioner function"
int
rd_kafka_topic_partition_available(RdKafka::Topic rkt, int32_t partition)

## TODO: might have to do some tracking of objects
void
DESTROY(RdKafka::Topic rkt)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::Topic\n");
#endif
    rd_kafka_topic_destroy(rkt);


### N.B. the PREFIX here is special (package RdKafka::Topic is also above with PREFIX=rd_kafka_topic_)
MODULE = RdKafka    PACKAGE = RdKafka::Topic    PREFIX = rd_kafka_

int
rd_kafka_produce(RdKafka::Topic rkt, int32_t partition, int msgflags, VOIDBUFFER payload, size_t len, VOIDBUFFER key, size_t keylen, VOIDBUFFER msg_opaque)

## TODO: rkmessages should be an aref of RdKafka::Message
int
rd_kafka_produce_batch(RdKafka::Topic rkt, int32_t partition, int msgflags, RdKafka::Message rkmessages, int message_cnt)


### N.B. the PREFIX here is special (package RdKafka::Topic is also above with PREFIX=rd_kafka_topic_)
### this is to be able to use INTERFACE
MODULE = RdKafka    PACKAGE = RdKafka::Topic    PREFIX = rd_kafka_

### PARTITIONERS

## TODO: maybe hide keylen; also could make opaque and msg_opaque optional
int32_t
interface_msg_partitioners(RdKafka::Topic rkt, VOIDBUFFER key, size_t keylen, int32_t partition_cnt, VOIDBUFFER opaque, VOIDBUFFER msg_opaque)
  INTERFACE:
    rd_kafka_msg_partitioner_random
    rd_kafka_msg_partitioner_consistent
    rd_kafka_msg_partitioner_consistent_random


### https://cwiki.apache.org/confluence/display/KAFKA/A+Guide+To+The+Kafka+Protocol#AGuideToTheKafkaProtocol-GroupMembershipAPI

MODULE = RdKafka    PACKAGE = RdKafka::GroupMemberInfo

MODULE = RdKafka    PACKAGE = RdKafka::GroupInfo

MODULE = RdKafka    PACKAGE = RdKafka::GroupList    PREFIX = rd_kafka_group_list_

## releases memory of return value of rd_kafka_list_groups
void
rd_kafka_group_list_destroy (RdKafka::GroupList grplist)

void
rd_kafka_group_list_DESTROY(RdKafka::GroupList grplist)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::GroupList\n");
#endif
    /* rd_kafka_group_list_destroy(grplist); */


MODULE = RdKafka    PACKAGE = RdKafka::Event    PREFIX = rd_kafka_event_

### EVENTS INTERFACE

#if RD_KAFKA_VERSION >= 0x000902ff

rd_kafka_event_type_t
rd_kafka_event_type(RdKafka::Event rkev)

const char *
rd_kafka_event_name(RdKafka::Event rkev)

const RdKafka::Message
rd_kafka_event_message_next(RdKafka::Event rkev)

## size_t
## rd_kafka_event_message_array(RdKafka::Event rkev, const rd_kafka_message_t **rkmessages, size_t size)

size_t
rd_kafka_event_message_count(RdKafka::Event rkev)

rd_kafka_resp_err_t
rd_kafka_event_error(RdKafka::Event rkev)

const char *
rd_kafka_event_error_string(RdKafka::Event rkev)

void *
rd_kafka_event_opaque(RdKafka::Event rkev)

## TODO
## int
## rd_kafka_event_log(RdKafka::Event rkev, const char **fac, const char **str, int *level)

RdKafka::TopicPartitionList
rd_kafka_event_topic_partition_list(RdKafka::Event rkev)

RdKafka::TopicPartition
rd_kafka_event_topic_partition(RdKafka::Event rkev)

## used to free the return value from rd_kafka_queue_poll
void
rd_kafka_event_DESTROY(RdKafka::Event rkev)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::Event\n");
#endif
    rd_kafka_event_destroy(rkev);

#endif  /* RD_KAFKA_VERSION >= 0x000902ff */


MODULE = RdKafka    PACKAGE = RdKafka::Queue    PREFIX = rd_kafka_queue_

### QUEUE API

#  "See rd_kafka_consume_start_queue(), rd_kafka_consume_queue(), et.al."
RdKafka::Queue
rd_kafka_queue_new(char *package, RdKafka rk)
  C_ARGS:
    rk

## TODO - after 0.9.2 installed
#if RD_KAFKA_VERSION >= 0x000902ff

void
rd_kafka_queue_forward(RdKafka::Queue src, RdKafka::Queue dst)

size_t
rd_kafka_queue_length(RdKafka::Queue rkqu)

## payload was "const void *"
void
rd_kafka_queue_io_event_enable(RdKafka::Queue rkqu, int fd, VOIDBUFFER payload, size_t size)

## (event API)
RdKafka::Event
rd_kafka_queue_poll(RdKafka::Queue rkqu, int timeout_ms)

#endif   /* RD_KAFKA_VERSION >= 0x000902ff */

void
rd_kafka_queue_DESTROY(RdKafka::Queue rkq)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::Queue\n");
#endif
    rd_kafka_queue_destroy(rkq);


MODULE = RdKafka    PACKAGE = RdKafka::Metadata    PREFIX = rd_kafka_metadata_

void
rd_kafka_metadata_DESTROY(RdKafka::Metadata metadata)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY RdKafka::Metadata\n");
#endif
    /* rd_kafka_metadata_destroy(metadata); */


## why can there not be empty lines in BOOT now??

BOOT:
    {
  HV *stash = gv_stashpvn("RdKafka", 7, TRUE);
  /*
   */
#ifdef RD_KAFKA_PARTITION_UA
  newCONSTSUB(stash, "RD_KAFKA_PARTITION_UA", newSViv(RD_KAFKA_PARTITION_UA));
#endif
  /*
    CONSUMER
   */
#ifdef RD_KAFKA_OFFSET_BEGINNING
  newCONSTSUB(stash, "RD_KAFKA_OFFSET_BEGINNING", newSViv(RD_KAFKA_OFFSET_BEGINNING));
#endif
#ifdef RD_KAFKA_OFFSET_END
  newCONSTSUB(stash, "RD_KAFKA_OFFSET_END", newSViv(RD_KAFKA_OFFSET_END));
#endif
#ifdef RD_KAFKA_OFFSET_STORED
  newCONSTSUB(stash, "RD_KAFKA_OFFSET_STORED", newSViv(RD_KAFKA_OFFSET_STORED));
#endif
#ifdef RD_KAFKA_OFFSET_INVALID
  newCONSTSUB(stash, "RD_KAFKA_OFFSET_INVALID", newSViv(RD_KAFKA_OFFSET_INVALID));
#endif
  /*
    PRODUCER
   */
#ifdef RD_KAFKA_MSG_F_FREE
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_FREE", newSViv(RD_KAFKA_MSG_F_FREE));
#endif
#ifdef RD_KAFKA_MSG_F_COPY
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_COPY", newSViv(RD_KAFKA_MSG_F_COPY));
#endif
  /* RD_KAFKA_MSG_F_BLOCK appeared in 0.9.2 */
#ifdef RD_KAFKA_MSG_F_BLOCK
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_BLOCK", newSViv(RD_KAFKA_MSG_F_BLOCK));
#endif
  /*
    EVENT - 1st appeared in 0.9.2
  */
#ifdef RD_KAFKA_EVENT_NONE
  newCONSTSUB(stash, "RD_KAFKA_EVENT_NONE", newSViv(RD_KAFKA_EVENT_NONE));
#endif
#ifdef RD_KAFKA_EVENT_DR
  newCONSTSUB(stash, "RD_KAFKA_EVENT_DR", newSViv(RD_KAFKA_EVENT_DR));
#endif
#ifdef RD_KAFKA_EVENT_FETCH
  newCONSTSUB(stash, "RD_KAFKA_EVENT_FETCH", newSViv(RD_KAFKA_EVENT_FETCH));
#endif
#ifdef RD_KAFKA_EVENT_LOG
  newCONSTSUB(stash, "RD_KAFKA_EVENT_LOG", newSViv(RD_KAFKA_EVENT_LOG));
#endif
#ifdef RD_KAFKA_EVENT_ERROR
  newCONSTSUB(stash, "RD_KAFKA_EVENT_ERROR", newSViv(RD_KAFKA_EVENT_ERROR));
#endif
#ifdef RD_KAFKA_EVENT_REBALANCE
  newCONSTSUB(stash, "RD_KAFKA_EVENT_REBALANCE", newSViv(RD_KAFKA_EVENT_REBALANCE));
#endif
#ifdef RD_KAFKA_EVENT_OFFSET_COMMIT
  newCONSTSUB(stash, "RD_KAFKA_EVENT_OFFSET_COMMIT", newSViv(RD_KAFKA_EVENT_OFFSET_COMMIT));
#endif
  /*
    rd_kafka_type_t enum
   */
  newCONSTSUB(stash, "RD_KAFKA_PRODUCER", newSViv(RD_KAFKA_PRODUCER));
  newCONSTSUB(stash, "RD_KAFKA_CONSUMER", newSViv(RD_KAFKA_CONSUMER));
  /*
    rd_kafka_conf_res_t
   */
  newCONSTSUB(stash, "RD_KAFKA_CONF_UNKNOWN", newSViv(RD_KAFKA_CONF_UNKNOWN));
  newCONSTSUB(stash, "RD_KAFKA_CONF_INVALID", newSViv(RD_KAFKA_CONF_INVALID));
  newCONSTSUB(stash, "RD_KAFKA_CONF_OK",      newSViv(RD_KAFKA_CONF_OK));
  /*
    rd_kafka_resp_err_t enum
   */
  /* Internal errors to rdkafka: */
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__BEGIN", newSViv(RD_KAFKA_RESP_ERR__BEGIN));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__BAD_MSG", newSViv(RD_KAFKA_RESP_ERR__BAD_MSG));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__BAD_COMPRESSION", newSViv(RD_KAFKA_RESP_ERR__BAD_COMPRESSION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__DESTROY", newSViv(RD_KAFKA_RESP_ERR__DESTROY));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__FAIL", newSViv(RD_KAFKA_RESP_ERR__FAIL));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__TRANSPORT", newSViv(RD_KAFKA_RESP_ERR__TRANSPORT));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__CRIT_SYS_RESOURCE", newSViv(RD_KAFKA_RESP_ERR__CRIT_SYS_RESOURCE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__RESOLVE", newSViv(RD_KAFKA_RESP_ERR__RESOLVE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__MSG_TIMED_OUT", newSViv(RD_KAFKA_RESP_ERR__MSG_TIMED_OUT));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__PARTITION_EOF", newSViv(RD_KAFKA_RESP_ERR__PARTITION_EOF));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION", newSViv(RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__FS", newSViv(RD_KAFKA_RESP_ERR__FS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC", newSViv(RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__ALL_BROKERS_DOWN", newSViv(RD_KAFKA_RESP_ERR__ALL_BROKERS_DOWN));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__INVALID_ARG", newSViv(RD_KAFKA_RESP_ERR__INVALID_ARG));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__TIMED_OUT", newSViv(RD_KAFKA_RESP_ERR__TIMED_OUT));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__QUEUE_FULL", newSViv(RD_KAFKA_RESP_ERR__QUEUE_FULL));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__ISR_INSUFF", newSViv(RD_KAFKA_RESP_ERR__ISR_INSUFF));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__NODE_UPDATE", newSViv(RD_KAFKA_RESP_ERR__NODE_UPDATE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__SSL", newSViv(RD_KAFKA_RESP_ERR__SSL));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__WAIT_COORD", newSViv(RD_KAFKA_RESP_ERR__WAIT_COORD));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__UNKNOWN_GROUP", newSViv(RD_KAFKA_RESP_ERR__UNKNOWN_GROUP));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__IN_PROGRESS", newSViv(RD_KAFKA_RESP_ERR__IN_PROGRESS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__PREV_IN_PROGRESS", newSViv(RD_KAFKA_RESP_ERR__PREV_IN_PROGRESS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__EXISTING_SUBSCRIPTION", newSViv(RD_KAFKA_RESP_ERR__EXISTING_SUBSCRIPTION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS", newSViv(RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS", newSViv(RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__CONFLICT", newSViv(RD_KAFKA_RESP_ERR__CONFLICT));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__STATE", newSViv(RD_KAFKA_RESP_ERR__STATE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__UNKNOWN_PROTOCOL", newSViv(RD_KAFKA_RESP_ERR__UNKNOWN_PROTOCOL));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__NOT_IMPLEMENTED", newSViv(RD_KAFKA_RESP_ERR__NOT_IMPLEMENTED));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__AUTHENTICATION", newSViv(RD_KAFKA_RESP_ERR__AUTHENTICATION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__NO_OFFSET", newSViv(RD_KAFKA_RESP_ERR__NO_OFFSET));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__OUTDATED", newSViv(RD_KAFKA_RESP_ERR__OUTDATED));
#if RD_KAFKA_VERSION >= 0x000902ff
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE", newSViv(RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE));
#endif
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__END", newSViv(RD_KAFKA_RESP_ERR__END));
  /* Kafka broker errors: */
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_UNKNOWN", newSViv(RD_KAFKA_RESP_ERR_UNKNOWN));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_NO_ERROR", newSViv(RD_KAFKA_RESP_ERR_NO_ERROR));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_OFFSET_OUT_OF_RANGE", newSViv(RD_KAFKA_RESP_ERR_OFFSET_OUT_OF_RANGE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_MSG", newSViv(RD_KAFKA_RESP_ERR_INVALID_MSG));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC_OR_PART", newSViv(RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC_OR_PART));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_MSG_SIZE", newSViv(RD_KAFKA_RESP_ERR_INVALID_MSG_SIZE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE", newSViv(RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_NOT_LEADER_FOR_PARTITION", newSViv(RD_KAFKA_RESP_ERR_NOT_LEADER_FOR_PARTITION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_REQUEST_TIMED_OUT", newSViv(RD_KAFKA_RESP_ERR_REQUEST_TIMED_OUT));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_BROKER_NOT_AVAILABLE", newSViv(RD_KAFKA_RESP_ERR_BROKER_NOT_AVAILABLE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_REPLICA_NOT_AVAILABLE", newSViv(RD_KAFKA_RESP_ERR_REPLICA_NOT_AVAILABLE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE", newSViv(RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_STALE_CTRL_EPOCH", newSViv(RD_KAFKA_RESP_ERR_STALE_CTRL_EPOCH));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_OFFSET_METADATA_TOO_LARGE", newSViv(RD_KAFKA_RESP_ERR_OFFSET_METADATA_TOO_LARGE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_NETWORK_EXCEPTION", newSViv(RD_KAFKA_RESP_ERR_NETWORK_EXCEPTION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_GROUP_LOAD_IN_PROGRESS", newSViv(RD_KAFKA_RESP_ERR_GROUP_LOAD_IN_PROGRESS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_GROUP_COORDINATOR_NOT_AVAILABLE", newSViv(RD_KAFKA_RESP_ERR_GROUP_COORDINATOR_NOT_AVAILABLE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_NOT_COORDINATOR_FOR_GROUP", newSViv(RD_KAFKA_RESP_ERR_NOT_COORDINATOR_FOR_GROUP));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_TOPIC_EXCEPTION", newSViv(RD_KAFKA_RESP_ERR_TOPIC_EXCEPTION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_RECORD_LIST_TOO_LARGE", newSViv(RD_KAFKA_RESP_ERR_RECORD_LIST_TOO_LARGE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS", newSViv(RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS_AFTER_APPEND", newSViv(RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS_AFTER_APPEND));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_REQUIRED_ACKS", newSViv(RD_KAFKA_RESP_ERR_INVALID_REQUIRED_ACKS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_ILLEGAL_GENERATION", newSViv(RD_KAFKA_RESP_ERR_ILLEGAL_GENERATION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INCONSISTENT_GROUP_PROTOCOL", newSViv(RD_KAFKA_RESP_ERR_INCONSISTENT_GROUP_PROTOCOL));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_GROUP_ID", newSViv(RD_KAFKA_RESP_ERR_INVALID_GROUP_ID));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_UNKNOWN_MEMBER_ID", newSViv(RD_KAFKA_RESP_ERR_UNKNOWN_MEMBER_ID));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_SESSION_TIMEOUT", newSViv(RD_KAFKA_RESP_ERR_INVALID_SESSION_TIMEOUT));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_REBALANCE_IN_PROGRESS", newSViv(RD_KAFKA_RESP_ERR_REBALANCE_IN_PROGRESS));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_COMMIT_OFFSET_SIZE", newSViv(RD_KAFKA_RESP_ERR_INVALID_COMMIT_OFFSET_SIZE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_TOPIC_AUTHORIZATION_FAILED", newSViv(RD_KAFKA_RESP_ERR_TOPIC_AUTHORIZATION_FAILED));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_GROUP_AUTHORIZATION_FAILED", newSViv(RD_KAFKA_RESP_ERR_GROUP_AUTHORIZATION_FAILED));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_CLUSTER_AUTHORIZATION_FAILED", newSViv(RD_KAFKA_RESP_ERR_CLUSTER_AUTHORIZATION_FAILED));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_INVALID_TIMESTAMP", newSViv(RD_KAFKA_RESP_ERR_INVALID_TIMESTAMP));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_UNSUPPORTED_SASL_MECHANISM", newSViv(RD_KAFKA_RESP_ERR_UNSUPPORTED_SASL_MECHANISM));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_ILLEGAL_SASL_STATE", newSViv(RD_KAFKA_RESP_ERR_ILLEGAL_SASL_STATE));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_UNSUPPORTED_VERSION", newSViv(RD_KAFKA_RESP_ERR_UNSUPPORTED_VERSION));
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR_END_ALL", newSViv(RD_KAFKA_RESP_ERR_END_ALL));
  /*
    SYSLOG
   */
#ifdef LOG_EMERG
  newCONSTSUB(stash, "LOG_EMERG", newSViv(LOG_EMERG));
#endif
#ifdef LOG_ALERT
  newCONSTSUB(stash, "LOG_ALERT", newSViv(LOG_ALERT));
#endif
#ifdef LOG_CRIT
  newCONSTSUB(stash, "LOG_CRIT", newSViv(LOG_CRIT));
#endif
#ifdef LOG_ERR
  newCONSTSUB(stash, "LOG_ERR", newSViv(LOG_ERR));
#endif
#ifdef LOG_WARNING
  newCONSTSUB(stash, "LOG_WARNING", newSViv(LOG_WARNING));
#endif
#ifdef LOG_NOTICE
  newCONSTSUB(stash, "LOG_NOTICE", newSViv(LOG_NOTICE));
#endif
#ifdef LOG_INFO
  newCONSTSUB(stash, "LOG_INFO", newSViv(LOG_INFO));
#endif
#ifdef LOG_DEBUG
  newCONSTSUB(stash, "LOG_DEBUG", newSViv(LOG_DEBUG));
#endif
    }
