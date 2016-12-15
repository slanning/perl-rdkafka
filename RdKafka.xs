#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "librdkafka/rdkafka.h"


/* make this a compile flag? */
#define PERL_RDKAFKA_DEBUG 1

/* no idea what's reasonable - probably should be configurable somehow */
#define PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE 1024

/* typemap INPUT macros - might not be needed (leftover from a wrong path taken) */

/* T_PTROBJ_IN(conf, ST(1), rd_kafka_conf_t *, rd_kafka_conf_tPtr, new); */
#define T_PTROBJ_IN(var, arg, type, ntype, func) do { \
        if (SvROK(arg) && sv_derived_from(arg, #ntype)) {    \
            IV tmp = SvIV((SV*) SvRV(arg)); \
            var = INT2PTR(type, tmp); \
        } else \
            Perl_croak_nocontext("RdKafka::" #func ": $" #var " is not of type " #ntype); \
    } while (0)
/* T_PV_IN(errstr, ST(1), const *); */
#define T_PV_IN(var, arg, type) do { var = (type)SvPV_nolen(arg) } while (0)
#define T_UV_IN(var, arg, type) do { var = (type)SvUV(arg) } while (0)


MODULE = RdKafka    PACKAGE = RdKafka    PREFIX = rd_kafka_

### VERSION

int
rd_kafka_version()

const char *
rd_kafka_version_str()


### CONSTANTS, ERRORS, TYPES

## omitted: deprecated RD_KAFKA_DEBUG_CONTEXTS

const char *
rd_kafka_get_debug_contexts()

## original:
## void rd_kafka_get_err_descs (const struct rd_kafka_err_desc **errdescs, size_t *cntp)
## instead of IN/OUT params, just return an aref;
## maybe should do { $code => { name => '...', desc => '...' } } instead of an aref of hashes
AV *
rd_kafka_get_err_descs()
  CODE:
    const struct rd_kafka_err_desc *errdesc;
    size_t cnt, i;
    RETVAL = (AV *) sv_2mortal((SV *)newAV());  // AV* have to be made mortal

    rd_kafka_get_err_descs(&errdesc, &cnt);

    for (i = 0; i < cnt; ++i) {
        HV *hv = (HV *) sv_2mortal((SV *) newHV());

        /* between -167 and -1 it's mostly empty (except -100) */
        if (errdesc[i].code == 0 && errdesc[i].name == NULL && errdesc[i].desc == NULL)
            continue;

        hv_store(hv, "code", 4,   newSViv(errdesc[i].code),    0);
        hv_store(hv, "name", 4,   newSVpv(errdesc[i].name, 0), 0);
        hv_store(hv, "desc", 4,   newSVpv(errdesc[i].desc, 0), 0);

        av_push(RETVAL, newRV((SV *) hv));
    }
  OUTPUT:
    RETVAL

const char *
rd_kafka_err2str(rd_kafka_resp_err_t err)

const char *
rd_kafka_err2name(rd_kafka_resp_err_t err)

rd_kafka_resp_err_t
rd_kafka_last_error()

rd_kafka_resp_err_t
rd_kafka_errno2err(int errnox)

int
rd_kafka_errno()


### TOPIC PARTITION

## #if RD_KAFKA_VERSION >= 0x000902ff

## (note: rd_kafka_topic_partition_new is in rdkafka_partition.h and not marked as RD_EXPORT)
## "This must not be called for elements in a topic partition list."
## For now there is no wrapping, until I figure out if you can create "topic partitions" outside of a list.
## void
## rd_kafka_topic_partition_destroy(rd_kafka_topic_partition_t *rktpar)

## #endif

rd_kafka_topic_partition_list_t *
rd_kafka_topic_partition_list_new(int size)

## This is omitted; the Perl DESTROY will call it, in rd_kafka_topic_partition_list_tPtr below
## void
## rd_kafka_topic_partition_list_destroy(rd_kafka_topic_partition_list_t *rkparlist)

rd_kafka_topic_partition_t *
rd_kafka_topic_partition_list_add(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition)

void
rd_kafka_topic_partition_list_add_range(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t start, int32_t stop)

int
rd_kafka_topic_partition_list_del(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition)

int
rd_kafka_topic_partition_list_del_by_idx(rd_kafka_topic_partition_list_t *rktparlist, int idx)

rd_kafka_topic_partition_list_t *
rd_kafka_topic_partition_list_copy(rd_kafka_topic_partition_list_t *src)
###rd_kafka_topic_partition_list_copy(const rd_kafka_topic_partition_list_t *src)

rd_kafka_resp_err_t
rd_kafka_topic_partition_list_set_offset(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition, int64_t offset)

rd_kafka_topic_partition_t *
rd_kafka_topic_partition_list_find(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition)


### MESSAGES

void
rd_kafka_message_destroy(rd_kafka_message_t *rkmessage)

## TODO: maybe should do this in rd_kafka_message_tPtr
## static RD_INLINE const char *
## RD_UNUSED 
## rd_kafka_message_errstr(const rd_kafka_message_t *rkmessage) {
## Gives a compile error, maybe because of the "static"
## static const char *
## rd_kafka_message_errstr(const rd_kafka_message_t *rkmessage)

## TODO: maybe should do this in rd_kafka_message_tPtr
## (tstype is a pointer, meant as a 2nd return value)
int64_t
rd_kafka_message_timestamp(const rd_kafka_message_t *rkmessage, OUT rd_kafka_timestamp_type_t tstype)


### CONFIGURATION

rd_kafka_conf_t *
rd_kafka_conf_new()

## I believe rd_kafka_new will normally destroy this itself (?)
## but I guess if rd_kafka_conf_dup is called...
## (should add something to DESTROY when it goes out of scope, though...)
void
rd_kafka_conf_destroy(rd_kafka_conf_t *conf)

rd_kafka_conf_t *
rd_kafka_conf_dup(rd_kafka_conf_t *conf)
## rd_kafka_conf_dup(const rd_kafka_conf_t *conf)

## rd_kafka_conf_res_t
## rd_kafka_conf_set(rd_kafka_conf_t *conf, const char *name, const char *value, char *errstr, size_t errstr_size)
## TODO?
## just croaking on error for now
void
rd_kafka_conf_set(rd_kafka_conf_t *conf, const char *name, const char *value)
  PREINIT:
    char buf[PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE];
    rd_kafka_conf_res_t res;
  CODE:
    res = rd_kafka_conf_set(conf, name, value, buf, PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE);
    if (res != RD_KAFKA_CONF_OK)
        croak("rd_kafka_conf_set failed (%d): %s", res, buf);


### TODO this conf section  #####

## #if RD_KAFKA_VERSION >= 0x000902ff

### handle version
## void
## rd_kafka_conf_set_events(rd_kafka_conf_t *conf, int events)

## #endif

## @deprecated See rd_kafka_conf_set_dr_msg_cb()
## void rd_kafka_conf_set_dr_cb(rd_kafka_conf_t *conf,
##			      void (*dr_cb) (rd_kafka_t *rk,
##					     void *payload, size_t len,
##					     rd_kafka_resp_err_t err,
##					     void *opaque, void *msg_opaque))

## callbacks - these will need special handling like
## PerlOGRECallback.{c,h} , PerlOGRECallbackManager.{c.h}
## void
## rd_kafka_conf_set_dr_msg_cb(rd_kafka_conf_t *conf, void (*dr_msg_cb) (rd_kafka_t *rk, const rd_kafka_message_t *rkmessage, void *opaque))
##
## void
## rd_kafka_conf_set_consume_cb(rd_kafka_conf_t *conf, void (*consume_cb) (rd_kafka_message_t *rkmessage, void *opaque))
##
## void
## rd_kafka_conf_set_rebalance_cb(rd_kafka_conf_t *conf, void (*rebalance_cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, rd_kafka_topic_partition_list_t *partitions, void *opaque))
##
## void
## rd_kafka_conf_set_offset_commit_cb(rd_kafka_conf_t *conf, void (*offset_commit_cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, rd_kafka_topic_partition_list_t *offsets, void *opaque))
##
## void
## rd_kafka_conf_set_error_cb(rd_kafka_conf_t *conf, void (*error_cb) (rd_kafka_t *rk, int err, const char *reason, void *opaque))
##
## void
## rd_kafka_conf_set_throttle_cb(rd_kafka_conf_t *conf, void (*throttle_cb) (rd_kafka_t *rk, const char *broker_name, int32_t broker_id, int throttle_time_ms, void *opaque))
##
## void
## rd_kafka_conf_set_log_cb(rd_kafka_conf_t *conf, void (*log_cb) (const rd_kafka_t *rk, int level, const char *fac, const char *buf))
##
## void
## rd_kafka_conf_set_stats_cb(rd_kafka_conf_t *conf, int (*stats_cb) (rd_kafka_t *rk, char *json, size_t json_len, void *opaque))
##
## void
## rd_kafka_conf_set_socket_cb(rd_kafka_conf_t *conf, int (*socket_cb) (int domain, int type, int protocol, void *opaque))

## #if RD_KAFKA_VERSION >= 0x000902ff

## void
## rd_kafka_conf_set_connect_cb(rd_kafka_conf_t *conf, int (*connect_cb) (int sockfd, const struct sockaddr *addr, int addrlen, const char *id, void *opaque))
##
## void
## rd_kafka_conf_set_closesocket_cb(rd_kafka_conf_t *conf, int (*closesocket_cb) (int sockfd, void *opaque))

## #endif

## #ifndef _MSC_VER
## void rd_kafka_conf_set_open_cb(rd_kafka_conf_t *conf, int (*open_cb) (const char *pathname, int flags, mode_t mode, void *opaque))
## #endif

void
rd_kafka_conf_set_opaque(rd_kafka_conf_t *conf, void *opaque)

void *
rd_kafka_opaque(const rd_kafka_t *rk)

void
rd_kafka_conf_set_default_topic_conf(rd_kafka_conf_t *conf, rd_kafka_topic_conf_t *tconf)

## TODO: size_t * IN_OUT
## rd_kafka_conf_res_t
## rd_kafka_conf_get (const rd_kafka_conf_t *conf, const char *name, char *dest, size_t *dest_size)

## TODO: size_t * IN_OUT
## rd_kafka_conf_res_t
## rd_kafka_topic_conf_get (const rd_kafka_topic_conf_t *conf, const char *name, char *dest, size_t *dest_size)

## TODO: take care of automatically freeing the dump on DESTROY
## The dump must be freed with `rd_kafka_conf_dump_free()`.
## const char **
## rd_kafka_conf_dump(rd_kafka_conf_t *conf, size_t *cntp)
## const char **
## rd_kafka_topic_conf_dump(rd_kafka_topic_conf_t *conf, size_t *cntp)
## void
## rd_kafka_conf_dump_free(const char **arr, size_t cnt)

void
rd_kafka_conf_properties_show(FILE *fp)


### TOPIC CONFIGURATION

rd_kafka_topic_conf_t *
rd_kafka_topic_conf_new()

rd_kafka_topic_conf_t *
rd_kafka_topic_conf_dup(rd_kafka_topic_conf_t *conf)

## TODO
## rd_kafka_conf_res_t
## rd_kafka_topic_conf_set(rd_kafka_topic_conf_t *conf, const char *name, const char *value, char *errstr, size_t errstr_size)

## void
## rd_kafka_topic_conf_set_opaque(rd_kafka_topic_conf_t *conf, void *opaque)

## TODO
## void
## rd_kafka_topic_conf_set_partitioner_cb (rd_kafka_topic_conf_t *topic_conf, int32_t (*partitioner) (const rd_kafka_topic_t *rkt, const void *keydata, size_t keylen, int32_t partition_cnt, void *rkt_opaque, void *msg_opaque))


### PARTITIONERS

## TODO - deferred until rd_kafka_topic_new is wrapped
## int
## rd_kafka_topic_partition_available(const rd_kafka_topic_t *rkt, int32_t partition)

## int32_t
## rd_kafka_msg_partitioner_random(const rd_kafka_topic_t *rkt, const void *key, size_t keylen, int32_t partition_cnt, void *opaque, void *msg_opaque)

## int32_t
## rd_kafka_msg_partitioner_consistent(const rd_kafka_topic_t *rkt, const void *key, size_t keylen, int32_t partition_cnt, void *opaque, void *msg_opaque)

## int32_t
## rd_kafka_msg_partitioner_consistent_random(const rd_kafka_topic_t *rkt, const void *key, size_t keylen, int32_t partition_cnt, void *opaque, void *msg_opaque)


### MAIN HANDLES

## originally:
## rd_kafka_t *
## rd_kafka_new(rd_kafka_type_t type, rd_kafka_conf_t *conf, char *errstr, size_t errstr_size)
## For now at least, the conf object is required (even if the default)
## and this will croak if there's an error from rd_kafka_new.
## I'd like to allow conf to be optional and errstr to hold an error,
## but I haven't figured out how to do that.
rd_kafka_t *
rd_kafka_new(rd_kafka_type_t type, rd_kafka_conf_t *conf)
  PREINIT:
    char buf[PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE];
    rd_kafka_conf_t *C_conf;
  CODE:
    RETVAL = rd_kafka_new(type, conf, buf, PERL_RDKAFKA_DEFAULT_ERRSTR_SIZE);
    if (RETVAL == NULL)
        croak("rd_kafka_new failed: %s", buf);
  OUTPUT:
    RETVAL

## This is omitted; the Perl DESTROY will call it, in rd_kafka_tPtr below
## void
## rd_kafka_destroy(rd_kafka_t *rk)

const char *
rd_kafka_name(rd_kafka_t *rk)
#rd_kafka_name(const rd_kafka_t *rk)

## TODO
## see rd_kafka_mem_free
char *
rd_kafka_memberid(rd_kafka_t *rk)
#rd_kafka_memberid(const rd_kafka_t *rk)

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
rd_kafka_topic_t *
rd_kafka_topic_new(rd_kafka_t *rk, const char *topic, rd_kafka_topic_conf_t *conf)

## TODO
void
rd_kafka_topic_destroy(rd_kafka_topic_t *rkt)

const char *
rd_kafka_topic_name(rd_kafka_topic_t *rkt)
#rd_kafka_topic_name(const rd_kafka_topic_t *rkt)

void *
rd_kafka_topic_opaque(rd_kafka_topic_t *rkt)
#rd_kafka_topic_opaque(const rd_kafka_topic_t *rkt)

int
rd_kafka_poll(rd_kafka_t *rk, int timeout_ms)

## TODO: tests once callbacks are implemented
void
rd_kafka_yield(rd_kafka_t *rk)


# start testing here


rd_kafka_resp_err_t
rd_kafka_pause_partitions(rd_kafka_t *rk, rd_kafka_topic_partition_list_t *partitions)

rd_kafka_resp_err_t
rd_kafka_resume_partitions(rd_kafka_t *rk, rd_kafka_topic_partition_list_t *partitions)

## TODO: figure out how best to handle both return value (error) and the low/high IN_OUT params
## rd_kafka_resp_err_t
## rd_kafka_query_watermark_offsets(rd_kafka_t *rk, const char *topic, int32_t partition, int64_t *low, int64_t *high, int timeout_ms)
##
## rd_kafka_resp_err_t
## rd_kafka_get_watermark_offsets(rd_kafka_t *rk, const char *topic, int32_t partition, int64_t *low, int64_t *high)

# leave this out?
# "rd_kafka_mem_free() must only be used for pointers returned by APIs
# that explicitly mention using this function for freeing."
# in particular, rd_kafka_memberid needs it,
# but can probably do it when the SV* holding the string goes out of scope
void
rd_kafka_mem_free(rd_kafka_t *rk, void *ptr)



##########

### STRUCT CLASSES

MODULE = RdKafka    PACKAGE = rd_kafka_topic_partition_tPtr    PREFIX = rd_kafka_

#ifdef PERL_RDKAFKA_DEBUG

void
rd_kafka_DESTROY(rd_kafka_topic_partition_t * toppar)
  CODE:
    printf("DESTROY rd_kafka_topic_partition_tPtr\n");
    /* I think this should not be done, (?)
       since rd_kafka_topic_partition_destroy should not be called
       on elements in a topic-partition list
       rd_kafka_topic_partition_destroy(toppar);  */

#endif

## struct rd_kafka_topic_partition_t accessors: topic, partition, offset, [metadata,] metadata_size(?), [opaque,] err

char *
rd_kafka_topic(rd_kafka_topic_partition_t *toppar)
  CODE:
    RETVAL = toppar->topic;
  OUTPUT:
    RETVAL

int32_t
rd_kafka_partition(rd_kafka_topic_partition_t *toppar)
  CODE:
    RETVAL = toppar->partition;
  OUTPUT:
    RETVAL

int64_t
rd_kafka_offset(rd_kafka_topic_partition_t *toppar)
  CODE:
    RETVAL = toppar->offset;
  OUTPUT:
    RETVAL

## TODO: deferred until implementing metadata API (I think)
##        void        *metadata;          /**< Metadata */
## ???
## rd_kafka_metadata(rd_kafka_topic_partition_t *toppar)
##   CODE:
##     RETVAL = toppar->metadata;
##   OUTPUT:
##     RETVAL

size_t
rd_kafka_metadata_size(rd_kafka_topic_partition_t *toppar)
  CODE:
    RETVAL = toppar->metadata_size;
  OUTPUT:
    RETVAL

## TODO: figure out later what "opaque" is
##        void        *opaque;            /**< Application opaque */
## ???
## rd_kafka_opaque(rd_kafka_topic_partition_t *toppar)
##   CODE:
##     RETVAL = toppar->opaque;
##   OUTPUT:
##     RETVAL

rd_kafka_resp_err_t
rd_kafka_err(rd_kafka_topic_partition_t *toppar)
  CODE:
    RETVAL = toppar->err;
  OUTPUT:
    RETVAL


MODULE = RdKafka    PACKAGE = rd_kafka_topic_partition_list_tPtr    PREFIX = rd_kafka_

void
rd_kafka_DESTROY(rd_kafka_topic_partition_list_t * list)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY rd_kafka_topic_partition_list_tPtr\n");
#endif
    rd_kafka_topic_partition_list_destroy(list);

## struct rd_kafka_topic_partition_list_t accessors: cnt, size, elems

int
rd_kafka_cnt(rd_kafka_topic_partition_list_t *list)
  CODE:
    RETVAL = list->cnt;
  OUTPUT:
    RETVAL

int
rd_kafka_size(rd_kafka_topic_partition_list_t *list)
  CODE:
    RETVAL = list->size;
  OUTPUT:
    RETVAL

## I changed this from rd_kafka_topic_partition_t * to aref
AV *
rd_kafka_elems(rd_kafka_topic_partition_list_t *list)
  CODE:
    rd_kafka_topic_partition_t *toppar;
    int cnt;
    RETVAL = (AV *) sv_2mortal((SV *)newAV());  // AV* have to be made mortal

    toppar = list->elems;
    cnt = list->cnt;

    while (--cnt >= 0) {
        SV *sv = newSV(0);
        sv_setref_pv(sv, "rd_kafka_topic_partition_tPtr", toppar);
        av_push(RETVAL, sv);

        ++toppar;
    }
  OUTPUT:
    RETVAL


MODULE = RdKafka    PACKAGE = rd_kafka_message_tPtr    PREFIX = rd_kafka_

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


MODULE = RdKafka    PACKAGE = rd_kafka_conf_tPtr    PREFIX = rd_kafka_

## rd_kafka_new destroys the conf, so can't call rd_kafka_conf_destroy.
## Not sure how to deal with that now.
void
rd_kafka_DESTROY(rd_kafka_conf_t * conf)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY rd_kafka_conf_tPtr\n");
#endif
    /* rd_kafka_conf_destroy(conf); */


MODULE = RdKafka    PACKAGE = rd_kafka_topic_conf_tPtr    PREFIX = rd_kafka_

void
rd_kafka_DESTROY(rd_kafka_topic_conf_t *topic_conf)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY rd_kafka_topic_conf_tPtr\n");
#endif
    /* rd_kafka_topic_conf_destroy(topic_conf); */


MODULE = RdKafka    PACKAGE = rd_kafka_tPtr    PREFIX = rd_kafka_

void
rd_kafka_DESTROY(rd_kafka_t *rk)
  CODE:
#ifdef PERL_RDKAFKA_DEBUG
    printf("DESTROY rd_kafka_tPtr\n");
#endif
    rd_kafka_destroy(rk);  /* should do this? */



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
    }
