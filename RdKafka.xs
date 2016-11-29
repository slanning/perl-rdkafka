#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include <rdkafka.h>


MODULE = RdKafka    PACKAGE = RdKafka

### VERSION

int
rd_kafka_version()

const char *
rd_kafka_version_str()


### CONSTANTS, ERRORS, TYPES

const char *
rd_kafka_get_debug_contexts()

void
rd_kafka_get_err_descs(const struct rd_kafka_err_desc **errdescs, size_t *cntp)

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

void
rd_kafka_topic_partition_destroy(rd_kafka_topic_partition_t *rktpar)

rd_kafka_topic_partition_list_t *
rd_kafka_topic_partition_list_new(int size)

void
rd_kafka_topic_partition_list_destroy(rd_kafka_topic_partition_list_t *rkparlist)

rd_kafka_topic_partition_t *
rd_kafka_topic_partition_list_add(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition)

void
rd_kafka_topic_partition_list_add_range(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t start, int32_t stop)

int
rd_kafka_topic_partition_list_del(rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition)

int
rd_kafka_topic_partition_list_del_by_idx(rd_kafka_topic_partition_list_t *rktparlist, int idx)

rd_kafka_topic_partition_list_t *
rd_kafka_topic_partition_list_copy(const rd_kafka_topic_partition_list_t *src)

rd_kafka_resp_err_t
rd_kafka_topic_partition_list_set_offset (rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition, int64_t offset)

rd_kafka_topic_partition_t *
rd_kafka_topic_partition_list_find (rd_kafka_topic_partition_list_t *rktparlist, const char *topic, int32_t partition)


### MESSAGES

void
rd_kafka_message_destroy(rd_kafka_message_t *rkmessage)

# static RD_INLINE const char *
# RD_UNUSED 
# rd_kafka_message_errstr(const rd_kafka_message_t *rkmessage) {
static const char *
rd_kafka_message_errstr(const rd_kafka_message_t *rkmessage)

int64_t
rd_kafka_message_timestamp(const rd_kafka_message_t *rkmessage, rd_kafka_timestamp_type_t *tstype)


### CONFIGURATION

rd_kafka_conf_t *
rd_kafka_conf_new()

void
rd_kafka_conf_destroy(rd_kafka_conf_t *conf)

rd_kafka_conf_t *
rd_kafka_conf_dup(const rd_kafka_conf_t *conf)

rd_kafka_conf_res_t
rd_kafka_conf_set(rd_kafka_conf_t *conf, const char *name, const char *value, char *errstr, size_t errstr_size)

void
rd_kafka_conf_set_events(rd_kafka_conf_t *conf, int events)

# @deprecated See rd_kafka_conf_set_dr_msg_cb()
# void rd_kafka_conf_set_dr_cb(rd_kafka_conf_t *conf,
#			      void (*dr_cb) (rd_kafka_t *rk,
#					     void *payload, size_t len,
#					     rd_kafka_resp_err_t err,
#					     void *opaque, void *msg_opaque))

void
rd_kafka_conf_set_dr_msg_cb(rd_kafka_conf_t *conf, void (*dr_msg_cb) (rd_kafka_t *rk, const rd_kafka_message_t *rkmessage, void *opaque))

void
rd_kafka_conf_set_consume_cb(rd_kafka_conf_t *conf, void (*consume_cb) (rd_kafka_message_t *rkmessage, void *opaque))

void
rd_kafka_conf_set_rebalance_cb(rd_kafka_conf_t *conf, void (*rebalance_cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, rd_kafka_topic_partition_list_t *partitions, void *opaque))

void
rd_kafka_conf_set_offset_commit_cb(rd_kafka_conf_t *conf, void (*offset_commit_cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, rd_kafka_topic_partition_list_t *offsets, void *opaque))

void
rd_kafka_conf_set_error_cb(rd_kafka_conf_t *conf, void (*error_cb) (rd_kafka_t *rk, int err, const char *reason, void *opaque))

void
rd_kafka_conf_set_throttle_cb(rd_kafka_conf_t *conf, void (*throttle_cb) (rd_kafka_t *rk, const char *broker_name, int32_t broker_id, int throttle_time_ms, void *opaque))

void
rd_kafka_conf_set_log_cb(rd_kafka_conf_t *conf, void (*log_cb) (const rd_kafka_t *rk, int level, const char *fac, const char *buf))

void
rd_kafka_conf_set_stats_cb(rd_kafka_conf_t *conf, int (*stats_cb) (rd_kafka_t *rk, char *json, size_t json_len, void *opaque))

void
rd_kafka_conf_set_socket_cb(rd_kafka_conf_t *conf, int (*socket_cb) (int domain, int type, int protocol, void *opaque))

void
rd_kafka_conf_set_connect_cb(rd_kafka_conf_t *conf, int (*connect_cb) (int sockfd, const struct sockaddr *addr, int addrlen, const char *id, void *opaque))

void
rd_kafka_conf_set_closesocket_cb(rd_kafka_conf_t *conf, int (*closesocket_cb) (int sockfd, void *opaque))

#ifndef _MSC_VER
void rd_kafka_conf_set_open_cb(rd_kafka_conf_t *conf, int (*open_cb) (const char *pathname, int flags, mode_t mode, void *opaque))
#endif

void
rd_kafka_conf_set_opaque(rd_kafka_conf_t *conf, void *opaque)

void *
rd_kafka_opaque(const rd_kafka_t *rk)

void
rd_kafka_conf_set_default_topic_conf(rd_kafka_conf_t *conf, rd_kafka_topic_conf_t *tconf)

rd_kafka_conf_res_t
rd_kafka_conf_get (const rd_kafka_conf_t *conf, const char *name, char *dest, size_t *dest_size)

rd_kafka_conf_res_t
rd_kafka_topic_conf_get (const rd_kafka_topic_conf_t *conf, const char *name, char *dest, size_t *dest_size)

# The dump must be freed with `rd_kafka_conf_dump_free()`.
const char **
rd_kafka_conf_dump(rd_kafka_conf_t *conf, size_t *cntp)
const char **
rd_kafka_topic_conf_dump(rd_kafka_topic_conf_t *conf, size_t *cntp)

void
rd_kafka_conf_dump_free(const char **arr, size_t cnt)

void
rd_kafka_conf_properties_show(FILE *fp)


### TOPIC CONFIGURATION

rd_kafka_topic_conf_t *
rd_kafka_topic_conf_new()

rd_kafka_topic_conf_t *
rd_kafka_topic_conf_dup(const rd_kafka_topic_conf_t *conf)

void
rd_kafka_topic_conf_destroy(rd_kafka_topic_conf_t *topic_conf)

rd_kafka_conf_res_t
rd_kafka_topic_conf_set(rd_kafka_topic_conf_t *conf, const char *name, const char *value, char *errstr, size_t errstr_size)

void
rd_kafka_topic_conf_set_opaque(rd_kafka_topic_conf_t *conf, void *opaque)

void
rd_kafka_topic_conf_set_partitioner_cb (rd_kafka_topic_conf_t *topic_conf, int32_t (*partitioner) (const rd_kafka_topic_t *rkt, const void *keydata, size_t keylen, int32_t partition_cnt, void *rkt_opaque, void *msg_opaque))

int
rd_kafka_topic_partition_available(const rd_kafka_topic_t *rkt, int32_t partition)


### PARTITIONERS

int32_t
rd_kafka_msg_partitioner_random(const rd_kafka_topic_t *rkt, const void *key, size_t keylen, int32_t partition_cnt, void *opaque, void *msg_opaque)

int32_t
rd_kafka_msg_partitioner_consistent(const rd_kafka_topic_t *rkt, const void *key, size_t keylen, int32_t partition_cnt, void *opaque, void *msg_opaque)

int32_t
rd_kafka_msg_partitioner_consistent_random(const rd_kafka_topic_t *rkt, const void *key, size_t keylen, int32_t partition_cnt, void *opaque, void *msg_opaque)



### MAIN HANDLES


rd_kafka_t *
rd_kafka_new(rd_kafka_type_t type, rd_kafka_conf_t *conf, char *errstr, size_t errstr_size)

void
rd_kafka_destroy(rd_kafka_t *rk)

const char *
rd_kafka_name(const rd_kafka_t *rk)

char *
rd_kafka_memberid(const rd_kafka_t *rk)

rd_kafka_topic_t *
rd_kafka_topic_new(rd_kafka_t *rk, const char *topic, rd_kafka_topic_conf_t *conf)

void
rd_kafka_topic_destroy(rd_kafka_topic_t *rkt)

const char *
rd_kafka_topic_name(const rd_kafka_topic_t *rkt)

void *
rd_kafka_topic_opaque(const rd_kafka_topic_t *rkt)

int
rd_kafka_poll(rd_kafka_t *rk, int timeout_ms)

void
rd_kafka_yield(rd_kafka_t *rk)

rd_kafka_resp_err_t
rd_kafka_pause_partitions(rd_kafka_t *rk, rd_kafka_topic_partition_list_t *partitions)

rd_kafka_resp_err_t
rd_kafka_resume_partitions(rd_kafka_t *rk, rd_kafka_topic_partition_list_t *partitions)

rd_kafka_resp_err_t
rd_kafka_query_watermark_offsets(rd_kafka_t *rk, const char *topic, int32_t partition, int64_t *low, int64_t *high, int timeout_ms)

rd_kafka_resp_err_t
rd_kafka_get_watermark_offsets(rd_kafka_t *rk, const char *topic, int32_t partition, int64_t *low, int64_t *high)

# leave this out?
void
rd_kafka_mem_free(rd_kafka_t *rk, void *ptr)


### QUEUE API

rd_kafka_queue_t *
rd_kafka_queue_new(rd_kafka_t *rk)

void
rd_kafka_queue_destroy(rd_kafka_queue_t *rkqu)

rd_kafka_queue_t *
rd_kafka_queue_get_main(rd_kafka_t *rk)

rd_kafka_queue_t *
rd_kafka_queue_get_consumer(rd_kafka_t *rk)

void
rd_kafka_queue_forward(rd_kafka_queue_t *src, rd_kafka_queue_t *dst)

size_t
rd_kafka_queue_length(rd_kafka_queue_t *rkqu)

void
rd_kafka_queue_io_event_enable(rd_kafka_queue_t *rkqu, int fd, const void *payload, size_t size)


### (simple legacy consumer API is omitted)


### KAFKACONSUMER API

rd_kafka_resp_err_t
rd_kafka_subscribe(rd_kafka_t *rk, const rd_kafka_topic_partition_list_t *topics)

rd_kafka_resp_err_t
rd_kafka_unsubscribe(rd_kafka_t *rk)

rd_kafka_resp_err_t
rd_kafka_subscription(rd_kafka_t *rk, rd_kafka_topic_partition_list_t **topics)

rd_kafka_message_t *
rd_kafka_consumer_poll(rd_kafka_t *rk, int timeout_ms)

rd_kafka_resp_err_t
rd_kafka_consumer_close(rd_kafka_t *rk)

rd_kafka_resp_err_t
rd_kafka_assign(rd_kafka_t *rk, const rd_kafka_topic_partition_list_t *partitions)

rd_kafka_resp_err_t
rd_kafka_assignment(rd_kafka_t *rk, rd_kafka_topic_partition_list_t **partitions)

rd_kafka_resp_err_t
rd_kafka_commit(rd_kafka_t *rk, const rd_kafka_topic_partition_list_t *offsets, int async)

rd_kafka_resp_err_t
rd_kafka_commit_message(rd_kafka_t *rk, const rd_kafka_message_t *rkmessage, int async)

rd_kafka_resp_err_t
rd_kafka_commit_queue(rd_kafka_t *rk, const rd_kafka_topic_partition_list_t *offsets, rd_kafka_queue_t *rkqu, void (*cb) (rd_kafka_t *rk, rd_kafka_resp_err_t err, rd_kafka_topic_partition_list_t *offsets, void *opaque), void *opaque)

rd_kafka_resp_err_t
rd_kafka_committed(rd_kafka_t *rk, rd_kafka_topic_partition_list_t *partitions, int timeout_ms)

rd_kafka_resp_err_t
rd_kafka_position(rd_kafka_t *rk, rd_kafka_topic_partition_list_t *partitions)


### PRODUCER API

int
rd_kafka_produce(rd_kafka_topic_t *rkt, int32_t partition, int msgflags, void *payload, size_t len, const void *key, size_t keylen, void *msg_opaque)

int
rd_kafka_produce_batch(rd_kafka_topic_t *rkt, int32_t partition, int msgflags, rd_kafka_message_t *rkmessages, int message_cnt)

rd_kafka_resp_err_t
rd_kafka_flush(rd_kafka_t *rk, int timeout_ms)


### METADATA API

rd_kafka_resp_err_t
rd_kafka_metadata(rd_kafka_t *rk, int all_topics, rd_kafka_topic_t *only_rkt, const struct rd_kafka_metadata **metadatap, int timeout_ms)

void
rd_kafka_metadata_destroy(const struct rd_kafka_metadata *metadata)


### CLIENT GROUP INFORMATION

rd_kafka_resp_err_t
rd_kafka_list_groups(rd_kafka_t *rk, const char *group, const struct rd_kafka_group_list **grplistp, int timeout_ms)

void
rd_kafka_group_list_destroy(const struct rd_kafka_group_list *grplist)


### MISCELLANEOUS

int
rd_kafka_brokers_add(rd_kafka_t *rk, const char *brokerlist)

# RD_EXPORT RD_DEPRECATED
# void rd_kafka_set_logger(rd_kafka_t *rk,
#			  void (*func) (const rd_kafka_t *rk, int level,
#					const char *fac, const char *buf));

void
rd_kafka_set_log_level(rd_kafka_t *rk, int level)

void
rd_kafka_log_print(const rd_kafka_t *rk, int level, const char *fac, const char *buf)

void
rd_kafka_log_syslog(const rd_kafka_t *rk, int level, const char *fac, const char *buf)

int
rd_kafka_outq_len(rd_kafka_t *rk)

void
rd_kafka_dump(FILE *fp, rd_kafka_t *rk)

int
rd_kafka_thread_cnt()

int
rd_kafka_wait_destroyed(int timeout_ms)


### EXPERIMENTAL API

rd_kafka_resp_err_t
rd_kafka_poll_set_consumer(rd_kafka_t *rk)


### EVENTS INTERFACE

rd_kafka_event_type_t
rd_kafka_event_type(const rd_kafka_event_t *rkev)

const char *
rd_kafka_event_name(const rd_kafka_event_t *rkev)

void
rd_kafka_event_destroy(rd_kafka_event_t *rkev)

const rd_kafka_message_t *
rd_kafka_event_message_next(rd_kafka_event_t *rkev)

size_t
rd_kafka_event_message_array(rd_kafka_event_t *rkev, const rd_kafka_message_t **rkmessages, size_t size)

size_t
rd_kafka_event_message_count(rd_kafka_event_t *rkev)

rd_kafka_resp_err_t
rd_kafka_event_error(rd_kafka_event_t *rkev)

const char *
rd_kafka_event_error_string(rd_kafka_event_t *rkev)

void *
rd_kafka_event_opaque(rd_kafka_event_t *rkev)

int
rd_kafka_event_log(rd_kafka_event_t *rkev, const char **fac, const char **str, int *level)

rd_kafka_topic_partition_list_t *
rd_kafka_event_topic_partition_list(rd_kafka_event_t *rkev)

rd_kafka_topic_partition_t *
rd_kafka_event_topic_partition(rd_kafka_event_t *rkev)

rd_kafka_event_t *
rd_kafka_queue_poll(rd_kafka_queue_t *rkqu, int timeout_ms)


BOOT:
{
  HV *stash = gv_stashpvn("RdKafka", 7, TRUE);

#ifdef RD_KAFKA_PARTITION_UA
  newCONSTSUB(stash, "RD_KAFKA_PARTITION_UA", newSViv(RD_KAFKA_PARTITION_UA));
#endif

#ifdef RD_KAFKA_MSG_F_FREE
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_FREE", newSViv(RD_KAFKA_MSG_F_FREE));
#endif
#ifdef RD_KAFKA_MSG_F_COPY
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_COPY", newSViv(RD_KAFKA_MSG_F_COPY));
#endif
#ifdef RD_KAFKA_MSG_F_BLOCK
  newCONSTSUB(stash, "RD_KAFKA_MSG_F_BLOCK", newSViv(RD_KAFKA_MSG_F_BLOCK));
#endif

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


}
