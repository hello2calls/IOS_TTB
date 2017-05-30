#ifndef __FEC_UTIL__
#define __FEC_UTIL__

#define FEC_PT_VALUE    102
#if defined(CT_STREAM_APP_BIBI) && CT_STREAM_APP_BIBI != 0
#define MAX_FEC_RTP_PKT_LEN 128
#define SECOND_FEC_PT_VALUE    106
#elif defined(CT_STREAM_APP_DIALER) && CT_STREAM_APP_DIALER != 0
#define SECOND_FEC_PT_VALUE    107
#define MAX_FEC_RTP_PKT_LEN 160
#endif
#define FEC_PT_TEXT     "102"

#define FEC_RF_ATTR_NAME      "fec-repair-flow"
#define FEC_RF_ATTR_VAL       " encoding-id=5; ss-fssi=n:%d,k:%d"

#if defined(CT_STREAM_APP_BIBI) && CT_STREAM_APP_BIBI != 0
#define FEC_RF_ATTR_VAL_2     " encoding-id=5; ss-fssi=n:%d,k:%d,g:%d"
#elif defined(CT_STREAM_APP_DIALER) && CT_STREAM_APP_DIALER != 0
#define FEC_RF_ATTR_VAL_2     " encoding-id=5; ss-fssi=n:%d,k:%d,g2:%d"
#endif

/**
 * Encoder and Decoder must use this default grp_pkts and src_pkts,
 * Because we don't depend on server must release before application.
 */
#define DEFAULT_FEC_GRP_PKTS  7
#define DEFAULT_FEC_SRC_PKTS  5

#if defined(CT_STREAM_APP_BIBI) && CT_STREAM_APP_BIBI != 0
#define DEFAULT_SECOND_FEC_GRP_PKTS 15
#define SECOND_FEC_GROUP_MULTIPLE 3
#elif defined(CT_STREAM_APP_DIALER) && CT_STREAM_APP_DIALER != 0
#define DEFAULT_SECOND_FEC_GRP_PKTS 18
#define SECOND_FEC_GROUP_MULTIPLE 2
#endif

/* FEC encoder declaration. */
typedef struct fec_encoder fec_encoder;

/* FEC decoder declaration. */
typedef struct fec_decoder fec_decoder;

typedef struct fec_ratio_cfg
{
    pj_int32_t end_rate;
    pj_int32_t fec_ratio;
    pj_int32_t second_fec_ratio;
}fec_ratio_cfg;

#define STREAM_FEC_RATIO_MAX_LEVELS    20

typedef struct fec_config
{
    int fec_enabled;
    int grp_pkts;
    int src_pkts;
    int sec_grp_pkts;

    fec_ratio_cfg fec_ratio[STREAM_FEC_RATIO_MAX_LEVELS];
    fec_ratio_cfg wifi_fec_ratio[STREAM_FEC_RATIO_MAX_LEVELS];
}fec_config;

/* FEC decoder group's state. */
typedef struct fec_decoder_grp_stat
{
    pj_uint32_t rtp_put_src_pkt_cnt;
    pj_uint32_t rtp_put_fake_pkt_cnt;
    pj_uint32_t rtp_low_recv_rate_cnt;
    pj_uint32_t rtp_put_decoder_cnt;
    pj_uint32_t rtp_group_cnt;
    pj_uint32_t rtp_group_list_full_cnt;
    pj_uint32_t rtp_full_del_pkt_cnt;
    pj_uint32_t rtp_invalid_group_cnt;
    pj_uint32_t rtp_lost_cnt;
    pj_uint32_t rtp_group_pkt_miss_cnt[DEFAULT_FEC_SRC_PKTS];
    pj_uint32_t rtp_list_empty_cnt;
    pj_uint32_t rtp_list_burst_cnt;
    pj_uint32_t rtp_list_prefetch_cnt;
    pj_uint32_t rtp_too_late_cnt;
    pj_uint32_t rtp_seq_jump_cnt;
    pj_uint32_t rtp_grp_reverse_cnt;
    pj_uint32_t rtp_grp_gap2_cnt;
    pj_uint32_t rtp_grp_gap3_cnt;
    pj_uint32_t rtp_grp_gapbig_cnt;
    pj_uint32_t rtp_grp_gap_max;
    pj_uint32_t rtp_grp_blank_fec_cnt;
    pj_uint32_t rtp_pkt_seq_err_cnt;
    pj_uint32_t rtp_repaired_pkts;
    pj_uint32_t rtp_sec_repaired_pkts;
    pj_uint32_t rtp_list_full_cnt;
    pj_uint32_t rtp_grp_del_cnt;
    pj_uint32_t rtp_gap_put2head[60];
} fec_decoder_grp_stat;

/* Called when we already generate a fec repair packet. */
typedef void (*on_repair_rtp_cb)(void *user_data, void *data, int len);

/* Called when we already can put RTP into jitter buffer. */
typedef int (*on_put_rtp_to_jb_cb)(void *user_data, void *data, int len, int repaired, int need_lock_jb);

/**
 * Create FEC encoder.
 * One FEC group contains source packets and repair packets.
 *
 * @param grp_pkts        One FEC group packets num.
 * @param src_pkts        One FEC group source packets num.
 * @param sec_grp_pkts    One second FEC group packets num.
 * @param pt              RTP payload type for fec repair packet.
 * @param pt_2            RTP payload type for second fec repair packet.
 * @param pkt_len         Max pkt_len of source RTP packet.
 * @param on_repair_rtp   Called when we already generate one fec repair packet.
 * @param user_data       User data used for on_repair_rtp callback.
 *
 * @return                        Return FEC encoder instance or NULL.
 */
fec_encoder* fec_encoder_create(int grp_pkts, int src_pkts, int sec_grp_pkts, fec_ratio_cfg *ratio_cfg,
                                fec_ratio_cfg *wifi_ratio_cfg, int pt, int pt_2, int pkt_len, on_repair_rtp_cb on_repair_rtp, void *user_data);

/**
 * Reset FEC encoder.
 *
 * @param encoder         The encoder instance.
 */
void fec_encoder_reset(fec_encoder *encoder);

/**
 * Free the encoder instance.
 *
 * @param encoder         The encoder instance.
 */
void fec_encoder_free(fec_encoder *encoder);

/**
 * Put source rtp packet into fec encoder, try to generate repair packets.
 *
 * @param encoder         The encoder instance.
 * @param data            Entire source rtp packet, include rtp header.
 * @param len             Source rtp packet length.
 */
void fec_encoder_put_rtp_pkt(fec_encoder *encoder, void *data, int len);

/**
 * Set max group packets num for encoder.
 *
 * @param encoder         The encoder instance.
 * @param max_grp_pkts    Max group packets num.
 */
void fec_encoder_set_max_grp_pkts(fec_encoder *encoder, int max_grp_pkts);

/**
 * Set peer RTP receive rate reported to encoder.
 * We will increase or decrease FEC repair packet according to this rate.
 *
 * @param encoder         The encoder instance.
 * @param recv_rate       The peer RTP recv rate reported.
 * @param network_type    1 wifi 0 other, not decrease grp_pkts in wifi.
 */
void fec_encoder_set_peer_recv_rate(fec_encoder *encoder, float recv_rate, int network_type);


/**
 * Create FEC decoder.
 * One FEC group contains source packets and repair packets.
 *
 * @param grp_pkts        One FEC group packets num.
 * @param src_pkts        One FEC group source packets num.
 * @param sec_grp_pkts    One second FEC group packets num.
 * @param pt              RTP payload type for fec repair packet.
 * @param pt_2            RTP payload type for second fec repair packet.
 * @param pkt_len         Max pkt_len of source RTP packet.
 * @param on_put_to_jb    Called when we already put RTP into jb.
 * @param user_data       User data used for on_put_to_jb callback.
 *
 * @return                Return FEC decoder instance or NULL.
 */
fec_decoder* fec_decoder_create(int grp_pkts, int src_pkts, int sec_grp_pkts, int pt,
    int pt_2, int pkt_len, on_put_rtp_to_jb_cb on_put_to_jb, void *user_data);

void fec_parse_config(const char *str, int length, fec_ratio_cfg *result);

/**
 * Reset FEC decoder.
 *
 * @param encoder         The decoder instance.
 */
void fec_decoder_reset(fec_decoder *decoder);

/**
 * Free the decoder instance.
 *
 * @param encoder         The decoder instance.
 */
void fec_decoder_free(fec_decoder *decoder);

/**
 * Put source or repair rtp packet into fec decoder.
 *
 * @param encoder         The decoder instance.
 * @param data            Entire source or repair rtp packet, include rtp header.
 * @param len             Source or repair rtp packet length.
 */
pj_bool_t fec_decoder_put_rtp_pkt(fec_decoder *decoder, void *data, int len);

/**
 * Get FEC RTP pkt from decoder buffer list.
 *
 * @param encoder         The decoder instance.
 * @param min_frames      Min frames need to put into jitter buffer.
 * @param max_frames      Max frames can put into jitter buffer.
 *
 * @return                0 or appropriate error.
 */
int fec_decoder_get_rtp_pkt(fec_decoder *decoder, int min_frames, int max_frames);

/**
 * Return FEC repaired pkts count.
 *
 * @param encoder         The decoder instance.
 *
 * @return                Repaired pkts count.
 */
int fec_decoder_get_repaired_pkts(fec_decoder *decoder);

/**
 * Return FEC decoder grp pkts stat.
 *
 * @param decoder         The decoder instance.
 *
 * @return fec_decoder_grp_stat
 */
fec_decoder_grp_stat* fec_decoder_get_grp_pkts_stat(fec_decoder *decoder);

/**
 * Set decoder prefetched group num.
 *
 * @param decoder         Input fec decoder
 * @param prefetch_num    Input prefetch num
 *
 * @return
 *
 */
void set_decoder_prefetch_num(fec_decoder *decoder, int prefetch_num);

/**
 * Return how may milliseconds we must wait before suspend.
 *
 * @param encoder         The decoder instance.
 * @param ptime           One frame time in millisecond.
 *
 * @return                How many milliseconds may wait before suspend.
 */
int fec_decoder_flush_buffer(fec_decoder *decoder, int ptime);

/**
 * Return if decoder is in prefetch mode.
 *
 * @param encoder         The decoder instance.
 *
 * @return                1 if decoder is in prefetch mode, otherwise return 0.
 */
int fec_decoder_is_in_prefetch(fec_decoder *decoder);

/**
 * Return if decoder buffer is empty.
 *
 * @param encoder         The decoder instance.
 *
 * @return                1 if decoder buffer is empty, otherwise return 0.
 */
int fec_decoder_buffer_is_empty(fec_decoder *decoder);

/**
 * Clear old ssrc's rtp pkts if decoder buffer is not empty.
 *
 * @param encoder         The decoder instance.
 * @param ssrc            The SSRC identify a RTP session.
 * @param csrc            The CSRC identify a RTP session's sentence.
 *
 * @return                PJ_SUCCESS on success, or the appropriate error code.
 */
int fec_decoder_clear_buffer_pkts(
    fec_decoder *decoder, pj_uint32_t ssrc, pj_uint32_t csrc);

int fec_parse_attr(const char *str, int length, fec_config *result);

#if defined(CT_AUTO_TEST) && CT_AUTO_TEST!=0
int fec_encoder_get_set_grp_pkt_cnt(fec_encoder *encoder);
int fec_encoder_get_set_grp_pkt_cnt_2(fec_encoder *encoder);
#endif

#endif /* __FEC_UTIL__ */
