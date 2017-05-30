#ifndef __PJMEDIA_RTP_JBUF_H__
#define __PJMEDIA_RTP_JBUF_H__

#include <pjmedia/types.h>
#define RTP_JBUF_MAX_LOST_COUNTER 8

typedef struct rtp_jbuf
{
    pj_int32_t *seq_buf;
    pj_uint32_t head;
    pj_uint32_t size;  // buffer's max size
    pj_uint32_t origin;
    pj_uint32_t count; // valid rtp count
    pj_uint32_t src_cnt; // valid rtp count include repaired rtp.

    pj_uint32_t last_seq;
    pj_uint32_t last_recv_seq;

    // statistics
    pj_uint32_t late;
    pj_uint32_t lost[RTP_JBUF_MAX_LOST_COUNTER];
    pj_uint32_t total;
    pj_uint32_t total_src_cnt;
    pj_uint32_t total_lost;
    pj_uint32_t duplicate;

    pj_uint32_t last_period_lost;
    pj_uint32_t last_period_total;
    pj_uint32_t last_period_duplicate;
    pj_uint32_t last_ssrc;
    pj_uint32_t last_timestamp;
    pj_uint32_t last_csrc;

    pj_timestamp last_calcu_time;
    pj_timestamp last_report_time;
    pj_bool_t first_round;

    pj_uint32_t buf_size;
}rtp_jbuf;


rtp_jbuf *rj_create(pj_uint32_t size, pj_uint32_t bufsize);

void rj_reset(rtp_jbuf *rj);

void rj_put(rtp_jbuf *rj, pj_uint16_t seq, pj_uint32_t ssrc,
    pj_uint32_t time_stamp, pj_uint32_t csrc, pj_bool_t repaired);

void rj_free(rtp_jbuf *rj);

#endif
