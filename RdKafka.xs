/* make this a compile flag? */
#define SCOTT 1

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

MODULE = RdKafka    PACKAGE = RdKafka    PREFIX = rd_kafka_

### VERSION

int
rd_kafka_version()

const char *
rd_kafka_version_str()


### CONSTANTS, ERRORS, TYPES

## deprecated RD_KAFKA_DEBUG_CONTEXTS is omitted

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

## (note: rd_kafka_topic_partition_new is in rdkafka_partition.h and not marked as RD_EXPORT)
## "This must not be called for elements in a topic partition list."
## For now there is no wrapping, until I figure out if you can create "topic partitions" outside of a list.
## void
## rd_kafka_topic_partition_destroy(rd_kafka_topic_partition_t *rktpar)

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



MODULE = RdKafka    PACKAGE = rd_kafka_topic_partition_tPtr    PREFIX = rd_kafka_

#ifdef SCOTT

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
#ifdef SCOTT
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
#ifdef RD_KAFKA_MSG_F_BLOCK
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_BLOCK", newSViv(RD_KAFKA_MSG_F_BLOCK));
#endif
  /*
    EVENT
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
/* TODO: just added? could also be generated from rd_kafka_get_err_descs in Perl
  newCONSTSUB(stash, "RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE", newSViv(RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE));
 */
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
