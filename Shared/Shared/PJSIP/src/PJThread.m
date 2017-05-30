//
//  PJSIPCore.m
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/12.
//
//

#import "PJThread.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "VoipUtils.h"
#import "TouchPalVersionInfo.h"
#import "SeattleExecutorHelper.h"
#import "PJCoreUtil.h"
#import "SIPConst.h"
#import "Reachability.h"
#import "PJCore.h"
#import "CallRingUtil.h"
#include "stream.h"

#define THIS_FILE "PJThread"

#define STATUS_SUCCESS(x,code) if(x != PJ_SUCCESS) \
{\
if(self.delegate) {\
[self.delegate onCallErrorWithCode:code];\
}\
return false; \
}


/*SIP HEADER*/

#define USER_AGENT "User-Agent"
#define COOTEK_CLIENT_ENV "X-CooTek-Client-Env"
#define COOTEK_CLIENT_OPRTION "X-CooTek-Option-Udp"
#define RTP_HEADER_NAME "X-audio-select"
#define VOIP_TOKEN_NAME "X-Device-Token"
#define COOTEK_CALL_CONFERENCE "X-Call-Conference"
#define CONFERENCE(x)  [x isEqualToString:@"conference"]

@interface PJThread(){
    NSString *_callIdString;
    int _callId;
    int _accountId;
    int _retryCount;
    int _weakupCount;
    BOOL _startWeakup;
    CLLocationManager *_locationManager;
}


@property(nonatomic,assign)id<CallStateChangeDelegate> delegate;

@end

const char *defaultData  = "iOS";

@implementation PJThread

- (id)initWithDelegate:(id<CallStateChangeDelegate> )delegate {
    self = [super init];
    if (self != nil) {
        self.delegate = delegate;
        _callId = PJSUA_INVALID_ID;
        _accountId = PJSUA_INVALID_ID;
    }
    return self;
}

- (void)weakup {
    if(_accountId > PJSUA_INVALID_ID) {
        _startWeakup = YES;
        [self weakupPJThread];
    }
}

- (void)weakupPJThread {
    if (_startWeakup && _weakupCount <= 200) {
        _weakupCount ++;
        pjsua_wakeup();
        cootek_log(@"retryWeakup ... %d",_weakupCount);
        [self performSelector:@selector(weakupPJThread) withObject:nil afterDelay:0.2];
    } else {
        _startWeakup = NO;
        _weakupCount = 0;
    }
}

- (void)stopPJThread {
    
    _callId = PJSUA_INVALID_ID;
    _accountId = PJSUA_INVALID_ID;
    self.delegate  = nil;
}

- (void)main {
    @autoreleasepool {
        self.name = @"PJThread";
        while (![self isCancelled]) {
            _startWeakup = NO;
            [self runSchedule];
        }
    }
}

- (void)runSchedule {
    if (_accountId > PJSUA_INVALID_ID) {
        pjsua_state state = pjsua_get_state();
        if (state > PJSUA_STATE_CREATED && state != PJSUA_STATE_CLOSING) {
            pjsua_handle_events(1000000);
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
        } else {
            _accountId = PJSUA_INVALID_ID;
        }
    } else {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        sleep(1);
    }
}

- (NSString *)parseIncomingNumber:(int)call_id {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    _callId = call_id;
    NSString *info = [PJCoreUtil stringWith:ci.remote_info.ptr andLen:ci.remote_info.slen];
    NSRange range = [info rangeOfString:@"(\\d+)" options:NSRegularExpressionSearch];
    if (range.length == 13) {
        range.location += 2;
        range.length -= 2;
    }
    NSString *number = [info substringWithRange:range];
    return number;
}

- (void)onIncoming:(int)call_id pre:(NSString *)preCallIdString addSdp:(BOOL)isAddSdp {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    NSString *current = [PJCoreUtil stringWith:ci.call_id.ptr andLen:ci.call_id.slen];
    cootek_log(@"onIncoming ......precall=%@,%@",preCallIdString,current);
    if (_callId != PJSUA_INVALID_ID) {
        if (![current isEqualToString:preCallIdString]) {
            pjsua_call_hangup(call_id, PJSIP_SC_BUSY_EVERYWHERE, NULL, NULL);
        }
    } else if([PJCoreUtil isNormalCalling]) {
        pjsua_call_hangup(call_id, PJSIP_SC_BUSY_EVERYWHERE, NULL, NULL);
    } else {
        if ([preCallIdString isEqualToString:current]) {
            pjsua_call_hangup(call_id, 0, NULL, NULL);
        } else {
            NSString *number = [self parseIncomingNumber:call_id];
            cootek_log(@"Incoming call from %@,%@", number,current);
            _callIdString = current;
            _callId = call_id;
            if(isAddSdp){
                pjsua_msg_data data_opus;
                pjsua_msg_data_init(&data_opus);
                pjsip_generic_string_hdr header;
                pj_str_t name_opus = pj_str("x-cootek-codec");
                pj_str_t value_opus = pj_str("opus/16000/20");
                pjsip_generic_string_hdr_init2(&header, &name_opus, &value_opus);
                pj_list_push_back(&data_opus.hdr_list, &header);
                pjsua_call_answer(_callId, PJSIP_SC_RINGING, NULL, &data_opus);
            }else{
                pjsua_call_answer(_callId, PJSIP_SC_RINGING, NULL,NULL);
            }
            [self.delegate onIncoming:number];
        }
    }
    
}

- (pj_status_t)configAccount:(IPAddress *)edgeAddress keepOnline:(BOOL)isOnline {
    
    pj_status_t status;
    pjsua_acc_config acc_cfg;
    pjsua_acc_config_default(&acc_cfg);
    NSString *secrectCode = [UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE];
    char* passwd = (char*)[[FunctionUtility simpleDecodeForString:secrectCode]  UTF8String];
    NSString *userNumber = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    char* pj_id = (char*)[[NSString stringWithFormat:@"<sip:%@@%s>",
                           userNumber, USE_DEBUG_SERVER ? SIP_DOMAIN_REGISTER_DEBUG : SIP_DOMAIN_REGISTER] UTF8String];
    
    acc_cfg.id = pj_str(pj_id);
    acc_cfg.reg_uri = pj_str((char *)[[NSString stringWithFormat:@"sip:%@%s",
                                       [PJCoreUtil getGroup:userNumber], USE_DEBUG_SERVER ? SIP_DOMAIN_DEBUG : SIP_DOMAIN] UTF8String]);
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].realm = pj_str("*");
    acc_cfg.cred_info[0].scheme = pj_str("digest");
    acc_cfg.cred_info[0].username = pj_str((char *)[userNumber UTF8String]);
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = pj_str(passwd);
    acc_cfg.reg_timeout = SIP_ACCOUNT_TIMEOUT;
    acc_cfg.reg_delay_before_refresh = SIP_ACCOUNT_TIMEOUT_BEFORE;
    acc_cfg.register_on_acc_add = isOnline;
    
    pjsip_generic_string_hdr header;
    pj_str_t name = pj_str(COOTEK_CLIENT_ENV);
    pj_str_t value = pj_str((char *)[[VoipUtils getVoipEnvironmentString:NO] UTF8String]);
    pjsip_generic_string_hdr_init2(&header, &name, &value);
    pj_list_push_back(&acc_cfg.reg_hdr_list, &header);
    
    NSString *token = [UserDefaultsManager stringForKey:APPLE_VOIP_PUSH_TOKEN defaultValue:nil];
    if ([token length] > 0) {
        pjsip_generic_string_hdr header;
        pj_str_t name = pj_str(VOIP_TOKEN_NAME);
        pj_str_t value = pj_str((char *)[token UTF8String]);
        pjsip_generic_string_hdr_init2(&header, &name, &value);
        pj_list_push_back(&acc_cfg.reg_hdr_list, &header);
    }
    
    
    acc_cfg.proxy_cnt = 1;
    acc_cfg.proxy[0] = pj_str([PJCoreUtil getSipProxy:edgeAddress]);
    
    acc_cfg.ice_cfg.enable_ice = false;
    acc_cfg.ice_cfg.ice_max_host_cands = 0;
    acc_cfg.media_stun_use = PJSUA_STUN_USE_DISABLED;
    acc_cfg.sip_stun_use = PJSUA_STUN_USE_DISABLED;
    acc_cfg.ka_interval = KEEP_ACCOUNT_ALIVE_INTERVAL;
    acc_cfg.lock_codec = 0;
    
    acc_cfg.turn_cfg.turn_server = pj_str([PJCoreUtil turnServer:edgeAddress.host]);
    acc_cfg.rfc5626_instance_id = pj_str((char *)([[NSString stringWithFormat:@"<urn:uuid:%@>",
                                                    [SeattleFeatureExecutor getToken]] UTF8String]));
    acc_cfg.use_rfc5626 = 1;
    
    
    if ( _accountId != PJSUA_INVALID_ID) {
        status = pjsua_acc_modify(_accountId, &acc_cfg);
        cootek_log(@"account modify result: %d", status);
    }else {
        int try_count = 0;
        status = -1;
        while (status != PJ_SUCCESS && try_count < 2) {
            status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &_accountId);
            try_count++;
            cootek_log(@"account add result: %d,%d", status,try_count);
        }
    }
    return status;
    
}

- (BOOL)inviteCall:(NSString *)number
              mode:(NSString *)mode
               rtp:(NSString *)ip
          location:(NSString *)location {
    if (_callId != PJSUA_INVALID_ID) {
        return NO;
    }
    pj_status_t status = -1;
    pjsua_msg_data data;
    pjsua_msg_data_init(&data);

    if (ip != nil) {
        NSString *pjip = [ip mutableCopy];
        pjsip_generic_string_hdr header1;
        pj_str_t name1 = pj_str(RTP_HEADER_NAME);
        pj_str_t value1 = pj_str((char *)[pjip UTF8String]);
        pjsip_generic_string_hdr_init2(&header1, &name1, &value1);
        pj_list_push_back(&data.hdr_list, &header1);
    }
    pj_str_t uri;
    if (CONFERENCE(mode)) {
        NSString *userNumber = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
        uri = pj_str([PJCoreUtil getConferenceUri:userNumber]);
        pjsip_generic_string_hdr header2;
        pj_str_t name2 = pj_str(COOTEK_CALL_CONFERENCE);
        pj_str_t value2 = pj_str((char *)[number UTF8String]);
        pjsip_generic_string_hdr_init2(&header2, &name2, &value2);
        pj_list_push_back(&data.hdr_list, &header2);
    } else {
        uri = pj_str([PJCoreUtil getSipUri:number]);
    }
    
    pjsip_generic_string_hdr header;
    pj_str_t name = pj_str(COOTEK_CLIENT_ENV);
    NSString *env = [VoipUtils getVoipEnvironmentString:mode];
    if(location != nil) {
        env = [NSString stringWithFormat:@"%@%@",env,location];
    }
    pj_str_t value = pj_str((char *)[env UTF8String]);
    pjsip_generic_string_hdr_init2(&header, &name, &value);
    pj_list_push_back(&data.hdr_list, &header);
    
    pjsua_call_setting setting;
    pjsua_call_setting_default(&setting);
    setting.aud_cnt = 1;
    setting.vid_cnt = 0;
    [self usePlayAndRecordDevice];
    status = pjsua_call_make_call(_accountId, &uri, &setting, (void*)defaultData, &data, &_callId);
    
    STATUS_SUCCESS(status,INVITE_CALL_FAILED)
    pjsua_call_info ci;
    status =  pjsua_call_get_info(_callId, &ci);
    if (status == PJ_SUCCESS) {
        _callIdString = [PJCoreUtil stringWith:ci.call_id.ptr andLen:ci.call_id.slen];
        cootek_log(@"%@:%@%@",@"PJThread", @"inviteCall success =",_callIdString);
    }
   
    return true;
}

- (BOOL)inviteCall:(NSString *)number mode:(NSString *)mode location:(NSString *)location{
    return [self inviteCall:number mode:mode rtp:nil location:location];
}

- (BOOL)doOption:(NSString *)ip {
    NSString *pjip = [ip mutableCopy];
    pj_str_t uri = pj_str("sip:fake@phone.chubao.cn");
    pj_status_t status;
    if ([ip length] > 0) {
        pjsua_msg_data data;
        pjsua_msg_data_init(&data);
        data.target_uri = uri;
        pjsip_generic_string_hdr header;
        pj_str_t name = pj_str(COOTEK_CLIENT_OPRTION);
        pj_str_t value = pj_str((char *)[[NSString stringWithFormat:@"udp_id=%@",pjip] UTF8String]);
        pjsip_generic_string_hdr_init2(&header, &name, &value);
        pj_list_push_back(&data.hdr_list, &header);
        status = pjsua_options_send(_accountId,&uri, &data, NULL);
    } else {
        status = pjsua_options_send(_accountId,&uri, NULL, NULL);
    }
    return status == PJ_SUCCESS;
}

- (BOOL)initPJsip:(IPAddress *)edgeAddress keepOnline:(BOOL)isOnline {
    
    pj_status_t status;
    status = pjsua_create();
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    pjsua_config cfg;
    pjsua_config_default(&cfg);
    cfg.cb.on_call_media_state = &onMediaState;
    cfg.cb.on_call_state = &onCallState;
    cfg.cb.on_incoming_call = &onIncomingCall;
    cfg.cb.on_stream_destroyed = &onDestroyStrem;
    cfg.cb.on_reg_state2 = &onRegisterChanged;
    cfg.cb.on_transport_state = &onTransoprtState;
    cfg.cb.on_options_response = &onOptionResponse;
    cfg.thread_cnt = 0;
    NSString *agent = [PJCoreUtil userSipAgent:pj_get_version()];
    cfg.user_agent = pj_str((char *)[agent UTF8String]);
    pjsua_logging_config log_cfg;
    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level = PJ_LOG_LEVEL;
    log_cfg.level = PJ_LOG_LEVEL;
    log_cfg.msg_logging = PJ_TRUE;
    log_cfg.cb = &onLog;
    
    pjsua_media_config media_cfg;
    pjsua_media_config_default(&media_cfg);
    NSString *configs = [UserDefaultsManager stringForKey:VOIP_CONFIG_STRING];
    NSArray *attrs = [configs componentsSeparatedByString:@"$"];
    if (configs.length > 0 && attrs.count >= 3) {
        media_cfg.fec_enabled = [[attrs objectAtIndex:0] intValue];
        media_cfg.grp_pkts = [[attrs objectAtIndex:1] intValue];
        media_cfg.src_pkts = [[attrs objectAtIndex:2] intValue];
        cootek_log(@"using voip fec config: %@", configs);
    } else {
        media_cfg.fec_enabled = 1;
        media_cfg.grp_pkts = 7;
        media_cfg.src_pkts = 5;
        cootek_log(@"using voip default fec config");
    }
    NSString *level = [UserDefaultsManager stringForKey:VOIP_FEC_CONFIG_LEVEL defaultValue:nil];
    if ([level length] == 0) {
        level = FEC_CONFIG_LEVEL;
    }
    media_cfg.fec_ratio = pj_str((char *)[level UTF8String]);
    //close slient delect
    media_cfg.no_vad = 1;
    status = pjsua_init(&cfg, &log_cfg, &media_cfg);
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    
    int max_priority = (pj_uint8_t)PJMEDIA_CODEC_PRIO_HIGHEST;
    pj_str_t codec_str = pj_str("opus/16000/1");
    status = pjsua_codec_set_priority(&codec_str, max_priority);
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    
    max_priority = (pj_uint8_t)PJMEDIA_CODEC_PRIO_HIGHEST - 10;
    codec_str = pj_str("iLBC/8000/1");
    status = pjsua_codec_set_priority(&codec_str, max_priority);
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    
    pjsua_transport_config cfg_transport;
    pjsua_transport_config_default(&cfg_transport);
    status = pjsua_transport_create(TCP ? PJSIP_TRANSPORT_TCP : PJSIP_TRANSPORT_UDP, &cfg_transport, NULL);
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    
    status = [self configAccount:edgeAddress keepOnline:isOnline];
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    status = pjsua_start();
    STATUS_SUCCESS(status,STATE_CORE_NOT_READY);
    return true;
}

- (void)destoryCore {
    _accountId = PJSUA_INVALID_ID;
    pjsua_state state = pjsua_get_state();
    if (state > PJSUA_STATE_CREATED && state != PJSUA_STATE_CLOSING) {
        pjsua_destroy();
        cootek_log(@"pjsua_memory destroyed");
    }
}

- (int)callDuration {
    if (_callId == PJSUA_INVALID_ID ) {
        return 0 ;
    }
    pjsua_call_info ci;
    pjsua_call_get_info(_callId, &ci);
    return ci.connect_duration.sec;
}

- (int)callId {
    return _callId;
}

- (BOOL)currentCall:(NSString *)callString {
    return [_callIdString isEqualToString:callString];
}

- (long)recPackage {
    if (_callId == PJSUA_INVALID_ID) {
        return 0;
    }
    pjsua_state state = pjsua_get_state();
    if (state == PJSUA_STATE_RUNNING) {
        pjsua_call_info ci;
        if(pjsua_call_get_info(_callId, &ci) == PJ_SUCCESS) {
            if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
                pjsua_stream_stat stat;
                if (pjsua_call_get_stream_stat(_callId, 0, &stat) == PJ_SUCCESS) {
                    pjmedia_rtcp_stream_stat rss = stat.rtcp.rx;
                    return rss.pkt;
                }
            }
        }
    }
    return 0;
}

- (void)disconnectTcp:(pjsip_transport *)tp {
    if (_accountId == PJSUA_INVALID_ID) {
        pjsip_transport_shutdown(tp);
    } else {
        pjsua_acc_tcp_disconnect(_accountId);
    }
}

- (void)doKeepAlive {
    if (_accountId == PJSUA_INVALID_ID) {
        return;
    }
    pjsua_acc_keep_alive(_accountId);
}

- (BOOL)setRegister:(BOOL)enable {
    
    if (_accountId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    BOOL isOnline = YES;
    if(enable || (enable == false && isOnline)) {
        pjsip_generic_string_hdr header;
        pj_str_t name = pj_str(COOTEK_CLIENT_ENV);
        pj_str_t value = pj_str((char *)[[VoipUtils getVoipEnvironmentString:NO] UTF8String]);
        pjsip_generic_string_hdr_init2(&header, &name, &value);
        pjsip_hdr tmp_hdr_list;
        pj_list_init(&tmp_hdr_list);
        pj_list_push_back(&tmp_hdr_list, &header);
        
        NSString *token = [UserDefaultsManager stringForKey:APPLE_VOIP_PUSH_TOKEN defaultValue:nil];
        if ([token length] > 0) {
            pjsip_generic_string_hdr header;
            pj_str_t name = pj_str(VOIP_TOKEN_NAME);
            pj_str_t value = pj_str((char *)[token UTF8String]);
            pjsip_generic_string_hdr_init2(&header, &name, &value);
            pj_list_push_back(&tmp_hdr_list, &header);
        }
        
        pjsua_acc_set_register_headers(_accountId,&tmp_hdr_list);
        pj_status_t status = pjsua_acc_set_registration(_accountId,enable ? 1:0);
        return status == PJ_SUCCESS;
    }
    return YES;
}

- (void)delAccount {
    if (_accountId == PJSUA_INVALID_ID) {
        return;
    }
    pjsua_acc_del(_accountId);
    _accountId = PJSUA_INVALID_ID;
}

- (void)sendDTMF:(NSString *)chr {
    
    if (chr.length != 1 || _callId == PJSUA_INVALID_ID) {
        return;
    }
    
    char buf[2];
    buf[0] = [chr characterAtIndex:0];
    buf[1] = 0;
    
    pjmedia_tone_digit d[16];
    unsigned i, count = strlen(buf);
    struct my_call_data *cd;
    
    void *user_data = pjsua_call_get_user_data(_callId);
    
    if (!user_data || (char *)user_data == defaultData) {
        cd = call_init_tonegen(_callId);
    } else {
        cd = user_data;
    }
    
    if (count > PJ_ARRAY_SIZE(d))
        count = PJ_ARRAY_SIZE(d);
    
    pj_bzero(d, sizeof(d));
    for (i=0; i<count; ++i) {
        d[i].digit = buf[i];
        d[i].on_msec = 200;
        d[i].off_msec = 300;
        d[i].volume = 0;
    }
    
    pj_status_t result = pjmedia_tonegen_play_digits(cd->tonegen, count, d, 0);
    cootek_log(@"send dtmf result: %d", result);
}

- (void)onMediaDisConnnect {
    if (_callId == PJSUA_INVALID_ID) {
        return;
    }
    pjsua_call_info ci;
    pjsua_call_get_info(_callId, &ci);
    pjsua_conf_disconnect(ci.conf_slot, 0);
    pjsua_conf_disconnect(0, ci.conf_slot);
    [self disableDevice];
    cootek_log(@"%s:no sound device %d",THIS_FILE,ci.media_status);
}

- (void)hangup {
    if (_callId == PJSUA_INVALID_ID) {
        return;
    }
    pjsua_call_hangup(_callId, 0, NULL, NULL);
    call_deinit_tonegen(_callId);
    pjsua_call_set_user_data(_callId, NULL);
    [self onMediaDisConnnect];
    _callId = PJSUA_INVALID_ID;
    _callIdString = nil;
    pjsua_state state = pjsua_get_state();
    if (state < PJSUA_STATE_INIT) {
        return;
    }
    float volume = 1.0f;
    pjsua_conf_adjust_rx_level(0, volume);
    
}

- (void)answer {
    if (_callId == PJSUA_INVALID_ID) {
        return;
    }
    [self usePlayAndRecordDevice];
    pjsua_call_answer(_callId,PJSIP_SC_OK, NULL, NULL);
}

- (void)checkResponse:(NSString *)mode callId:(NSString *)callId {
    if (_callId == PJSUA_INVALID_ID || ![callId isEqualToString:_callIdString]) {
        return;
    }
    pjsua_call_info ci;
    if(pjsua_call_get_info(_callId, &ci) != PJ_SUCCESS){
        return;
    }
    pjsip_inv_state state = ci.state;
    if (state == PJSIP_INV_STATE_NULL ||
        state == PJSIP_INV_STATE_CALLING) {
        if ([mode isEqualToString:VOIP_CALL_BACK]) {
            [self.delegate onCallErrorWithCode:STATE_CALL_ERROR_BACK];
        } else {
            [self.delegate onCallErrorWithCode:STATE_CALL_ERROR_DIR];
        }
    }
}

- (void)usePlayAndRecordDevice {
    int capture;
    int playback;
    pjsua_get_snd_dev(&capture, &playback);
    pjsua_set_snd_dev(capture, playback);
}

- (void)disableDevice {
    cootek_log(@"disableDevice...");
    pjsua_set_no_snd_dev();
}

- (void)setStreamWifiNetwork:(BOOL)iswifi {
    if (_callId == PJSUA_INVALID_ID) {
        return;
    }
    int type = iswifi ? 1 : 0;
    pjsua_call_stream_set_network_type(_callId,0,type);
}

- (void)setPostKidsAddress:(NSString *)address interval:(int)interval rate:(float)rate {
    int length = address.length;
    if (_callId == PJSUA_INVALID_ID || length == 0) {
        return;
    }
    const char *str = [address UTF8String];
    pjsua_call_stream_set_postkid_addr(_callId,0,str,length,interval,rate);
}

- (void)onMediaConnect {
    if (_callId == PJSUA_INVALID_ID) {
        return;
    }
    [self usePlayAndRecordDevice];
    // When media is active, connect call to sound device.
    pjsua_call_info ci;
    pjsua_call_get_info(_callId, &ci);
    pjsua_conf_connect(ci.conf_slot, 0);
    pjsua_conf_connect(0, ci.conf_slot);
}

struct my_call_data
{
    pj_pool_t          *pool;
    pjmedia_port       *tonegen;
    pjsua_conf_port_id  toneslot;
};

void call_deinit_tonegen(pjsua_call_id call_id)
{
    void *user_data = pjsua_call_get_user_data(call_id);
    
    if (!user_data || (char *)user_data == defaultData)
        return;
    struct my_call_data *cd;
    
    cd = (struct my_call_data*) pjsua_call_get_user_data(call_id);
    pjsua_conf_remove_port(cd->toneslot);
    pjmedia_port_destroy(cd->tonegen);
    pj_pool_release(cd->pool);
    
}

struct my_call_data *call_init_tonegen(pjsua_call_id call_id)
{
    pj_pool_t *pool;
    struct my_call_data *cd;
    pjsua_call_info ci;
    
    pool = pjsua_pool_create("mycall", 512, 512);
    cd = PJ_POOL_ZALLOC_T(pool, struct my_call_data);
    cd->pool = pool;
    
    pjmedia_tonegen_create(cd->pool, 8000, 1, 160, 16, 0, &cd->tonegen);
    pjsua_conf_add_port(cd->pool, cd->tonegen, &cd->toneslot);
    
    pjsua_call_get_info(call_id, &ci);
    pjsua_conf_connect(cd->toneslot, ci.conf_slot);
    
    pjsua_call_set_user_data(call_id, (void*) cd);
    
    return cd;
}

void onMediaState(pjsua_call_id call_id)
{
    if (call_id == PJSUA_INVALID_ID) {
        return;
    }
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    cootek_log(@"Call %d media state=%d, slot: %d", call_id, ci.media_status, ci.conf_slot);
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        [[PJCore instance] onMediaConnect];
    }
}

void onRegisterChanged(pjsua_acc_id acc_id,
                       pjsua_reg_info *info) {
    if (acc_id == PJSUA_INVALID_ID) {
        return;
    }
    BOOL active = NO;
    int code = 200;
    if (info != NULL && info->cbparam) {
        active = (info->cbparam->status == PJ_SUCCESS);
        code = info->cbparam->code;
    }
    [[PJCore instance] onRegister:active sipCode:code];
}

void onCallState(pjsua_call_id call_id,
                 pjsip_event *e)
{
    cootek_log(@"onCallState .......");
    if (call_id == PJSUA_INVALID_ID ) {
        return;
    }
    if (pjsua_call_get_user_data(call_id) == NULL) {
        return;
    }
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    [[PJCore instance] onCallStateChanged:ci.state
                                   callId:[PJCoreUtil stringWith:ci.call_id.ptr andLen:ci.call_id.slen]
                                    event:e];
}

void onIncomingCall(pjsua_acc_id acc_id,
                    pjsua_call_id call_id,
                    pjsip_rx_data *rdata)
{
    
    if (call_id == PJSUA_INVALID_ID ) {
        return;
    }
    BOOL isAddSdp = NO;
    if (rdata != NULL && rdata->msg_info.msg_buf != NULL) {
        NSString *info = [PJCoreUtil stringWith:rdata->msg_info.msg_buf
                                         andLen:rdata->msg_info.len];
        if ([PJCoreUtil isAstriskIncoming:info]) {
            cootek_log(@"onIncomingCall PJSIP_SC_CALL_TSX_DOES_NOT_EXIST");
            pjsua_call_hangup(call_id, PJSIP_SC_CALL_TSX_DOES_NOT_EXIST, NULL, NULL);
            return;
        }
        NSString *info_sdp = [PJCoreUtil stringWith:rdata->msg_info.msg->body->data
                                             andLen:rdata->msg_info.msg->body->len];
        NSRange range = [info_sdp rangeOfString:@"opus"];
        if (range.location != NSNotFound) {
            isAddSdp = YES;
        }
    }
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    pjsua_call_set_user_data(call_id,(void *)defaultData);
    [[PJCore instance] onIncomingCall:call_id addSdp:isAddSdp];
}

void onLog(int level, const char *data, int len)
{
    if (data == NULL || len==0 || len > 10000) {
        return;
    }
    NSString *msg = [PJCoreUtil stringWith:data andLen:len];
    cootek_log(@"%d: %@", level, msg);
    [[PJCore instance] onLog:msg];
}

void onDestroyStrem(pjsua_call_id call_id,
                    pjmedia_stream *strm,
                    unsigned stream_idx) {
    if (call_id == PJSUA_INVALID_ID ) {
        return;
    }
    
    if(pjsua_call_get_user_data(call_id) == NULL) {
        return;
    }

    pj_sockaddr socket;
    unsigned type;
    pjmedia_stream_get_final_postkid(strm, &socket, &type);
    char buf[30];
    pj_sockaddr_print(&socket, buf, 30, 1);
    
    cootek_log(@"onDestroyStream = %x,%d,%s,%d",strm,call_id,buf,type);
    NSString *kids = nil;
    if (type == POSTKID) {
        kids = [PJCoreUtil stringWith:buf andLen:strlen(buf)];
    }
    [[PJCore instance] onDestroyStream:call_id poskid:kids];
    
}

void onTransoprtState(pjsip_transport *tp,
                      pjsip_transport_state state,
                      const pjsip_transport_state_info *info) {
    [[PJCore instance] onTransportState:state transport:tp];
}

void onOptionResponse(pjsua_call_id call_id,
                      const pj_str_t *to,
                      void *user_data,
                      pjsip_status_code status,
                      const pj_str_t *reason,
                      pjsip_tx_data *tdata,
                      pjsip_rx_data *rdata,
                      pjsua_acc_id acc_id) {
    if (acc_id == PJSUA_INVALID_ID) {
        return;
    }
    NSString *ip = nil;
    if (status == PJSIP_SC_OK && rdata != NULL && rdata->msg_info.msg_buf != NULL) {
        NSString *info = [PJCoreUtil stringWith:rdata->msg_info.msg_buf andLen:rdata->msg_info.len];
        NSArray *selectArray = [[PJCoreUtil getSpecificLine:@"X-audio-select:"
                                                  inMessage:info]
                                componentsSeparatedByString:@" "];
        if ([selectArray count] >=2) {
            ip = selectArray[1];
        }
    }
    [[PJCore instance] onOptionResonse:ip];
}

@end
