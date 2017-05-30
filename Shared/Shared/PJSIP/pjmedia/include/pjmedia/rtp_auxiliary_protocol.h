#ifndef __RTP_AUXILIARY_PROTOCOL_H__
#define __RTP_AUXILIARY_PROTOCOL_H__

#define RTP_AUXILIARY_FILE   "rtp_auxiliary_protocol.h"

// command type for mckinley
#define RTP_AUXILIARY_HDR_MAGIC   0x00AA
#define PT_RTP_START_RELAY        0x02
#define PT_RTP_START_RELAY_ACK    0x03
#define PT_RTP_LOSS_FEEDBACK      0x04
// type 0x05 is for relay message between postkids and postman
#define PT_RTP_STOP_RELAY         0x06
#define PT_RTP_TS_FEEDBACK        0x07

//command type for andes
/* Type 0x07 to 0x0F reserved for your post kids */
#define PT_RTP_CHANNEL_KEEP_ALIVE 0x10
#define PT_END_OF_TALK 0x11
#define PT_TALK_FEEDBACK 0x81 /* The most significant bit set to 1 for responses, 0 for requests */
#define PT_RTP_CHANNEL_KEEP_ALIVE_ACK 0x12

/* Header for information  */
#pragma pack(1)
typedef struct rtp_auxiliary_hdr
{
    uint16_t magic;               /* Magic number 0x00AA, host seq */
    uint16_t len;                 /* Pkt length (include rtp_auxiliary_hdr length and payload length), host seq     */

    /**
     * 0x02: start-relay req,
     * 0x03: start-relay rsp,
     * 0x04: rtp loss feedback,
     * 0x05: start-relay req between postkids and postman,
     * 0x06: stop relay,
     * 0x10: rtp channel keep alive,
     * 0x11: talk info message when this talk is end
     * 0x81: feed back message for 0x11
     */
    uint8_t type;                 /* Payload type         */
    uint8_t reserve;              /* Reserve byte         */
} rtp_auxiliary_hdr;

typedef struct rtp_start_relay
{
    rtp_auxiliary_hdr hdr;           /* Header               */
    uint16_t target_port;         /* Target postman port, host seq */
    uint32_t target_ip;           /* Target postman IP, host seq */

}rtp_start_relay;

typedef struct rtp_start_relay_ack
{
    rtp_auxiliary_hdr hdr;           /* Header               */
    uint16_t client_port;         /* Target postman port host seq */
    uint32_t client_ip;           /* Target postman IP host seq */
    uint16_t relay_port;          /* Postkid relay port, host seq */
    uint32_t relay_ip;            /* Postkid relay IP, host seq */
}rtp_start_relay_ack;

typedef struct rtp_stop_relay
{
    rtp_auxiliary_hdr hdr;           /* Header               */
    uint16_t blank;               /* Not used */
}rtp_stop_relay;

typedef struct rtp_channel_keep_alive
{
    rtp_auxiliary_hdr hdr;
    uint16_t group_ssrc_count; /* Active group count of this client, host seq */
    /* Zero to multiple 32-bit values of currently unmuted group SSRCs, host seq */
} rtp_channel_keep_alive;

typedef struct rtp_channel_keep_alive_ack
{
    rtp_auxiliary_hdr hdr;        /* Header  */
} rtp_channel_keep_alive_ack;

typedef struct end_of_talk
{
    rtp_auxiliary_hdr hdr;
    uint32_t talkroom_id; /* Room id, host seq */
    uint32_t talk_id; /* Talk id, host seq */
    uint32_t rtp_cnt; /* RTP count for this talk, host seq */
} end_of_talk;

typedef struct talk_feedback
{
    rtp_auxiliary_hdr hdr;
    uint32_t talkroom_id; /* Room id, host seq */
    uint32_t talk_id; /* Talk id, host seq */
    uint16_t accepted; /* Return 0 if the loss rate is not acceptable from the server's perspective, 1 if acceptable. Don't put actual loss rate here. host seq */
} talk_feedback;


/* RTP loss feeback struct */
typedef struct rtp_loss_feedback
{
    rtp_auxiliary_hdr hdr;           /* Header               */
    uint16_t last_seq;            /* Last RTP packet seq, host seq  */
    uint32_t last_ssrc;           /* Last RTP packet ssrc, host seq */
    uint32_t last_ts;             /* Last RTP packet ts, host seq   */
    uint32_t packet_recv_rate;          /* Packet recv rate, host seq     */
} rtp_loss_feedback;

typedef struct rtp_fbpkt_hdr
{
    rtp_auxiliary_hdr hdr;        /* Header               */
    uint16_t last_rtp_seq;        /* last rtp seq, host seq           */
    uint32_t last_rtp_ssrc;       /* last rtp ssrc, host seq              */
    uint32_t last_rtp_timestamp;  /* rtp timestamp, host seq */
    float payload_recv_rate;      /* payload recv rate */
    uint16_t network_type;        /* if wifi is 1 , other 0, host seq  */
} rtp_fbpkt_hdr;

typedef struct rtp_fbpkt_ext
{
    struct rtp_fbpkt_hdr base;
    uint32_t lost_rtp_index;      /* lost rtp packet description according to last_rtp_seq by bit. bit 1 set to 1 indicate last_rtp_seq - 1 lost.*/
} rtp_fbpkt_ext;

/* RTP loss feeback struct */
#define RTP_TSFB_PEER       1
#define RTP_TSFB_FIRST_EDGE 2
#define RTP_TSFB_LAST_EDGE  3

typedef struct rtp_ts_feedback
{
    rtp_auxiliary_hdr hdr;           /* Header               */
    uint32_t rtp_ssrc;           /* RTP packet ssrc */
    uint32_t rtp_csrc;           /* RTP packet csrc */
    uint32_t sender_type;        /* The sender of this feedback*/
    uint32_t ts;           /* RTP ts value for calculate delay */
} rtp_ts_feedback;

#pragma pack()

#endif /* __RTP_AUXILIARY_PROTOCOL_H__ */
