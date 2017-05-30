//
//  PJCoreUtil.m
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/13.
//
//

#import "PJCoreUtil.h"
#import "TouchPalVersionInfo.h"
#import "PhoneNumber.h"
#import "SIPConst.h"
#import "VoipUtils.h"
#import <CoreTelephony/CTCallCenter.h>

@implementation PJCoreUtil

+ (BOOL)isNormalCalling {
    CTCallCenter* callCenter = [[CTCallCenter alloc] init];
    return [callCenter currentCalls] != nil;
}

+ (NSString *)userSipAgent:(const char *)sipVersion {
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@/%@", @"com.cootek.smartdialer",
                           CURRENT_TOUCHPAL_VERSION, @"iOS"];

    return [NSString stringWithFormat:@"%@;pjsip%s", userAgent, sipVersion];
}

+ (char *)getSipUri:(NSString *)number {
    NSString *normNumber = [PhoneNumber getCNnormalNumber:number];
    char* uri_str = (char*)[[NSString stringWithFormat:@"<sip:%@@%@%s>",
                             normNumber,
                             [self getGroup:normNumber],
                             USE_DEBUG_SERVER ? SIP_DOMAIN_DEBUG : SIP_DOMAIN] UTF8String];
    return uri_str;
}

+ (char *)getConferenceUri:(NSString *)account {
    NSString *normNumber = [PhoneNumber getCNnormalNumber:account];
    char* uri_str = (char*)[[NSString stringWithFormat:@"<sip:%@@%@%s>",
                             @"conference",
                             [self getGroup:normNumber],
                             USE_DEBUG_SERVER ? SIP_DOMAIN_DEBUG : SIP_DOMAIN] UTF8String];
    return uri_str;
}

+ (NSString *)stringWith:(const char *)pstr andLen:(int)len {
    if (len > 0) {
        char *str2 = malloc(sizeof(char) * (len + 1));
        for (int i = 0; i< len; i++) {
            str2[i] = pstr[i];
        }
        str2[len] = '\0';
        NSString *back = [NSString stringWithUTF8String:str2];
        free(str2);
        return back;
    }
    return nil;
}

+ (NSString *)getGroup:(NSString *)number {
    NSMutableString *groupString = [NSMutableString stringWithString:@""];
    if ([number hasPrefix:@"+861"]) {
        [groupString appendString:@"reg"];
        NSString *last4 = [number substringFromIndex:number.length - 4];
        int last4Digit = [last4 intValue];
        int groupNum = (last4Digit % 64) + 1;
        NSString *groupNumString = [NSString stringWithFormat:@"%d", groupNum];
        if (groupNumString.length == 1) {
            [groupString appendString:@"0"];
        }
        [groupString appendString:groupNumString];
    } else {
        [groupString appendString:@"phone"];
    }
    return groupString;
}

+ (char *)turnServer:(NSString *)host
{
    NSString *t = nil;
    if (USE_DEBUG_SERVER) {
        t = [NSString stringWithFormat:@"%@:%d",host,DEBUG_EDGE_TURN_PORT];
    } else {
        t =  [NSString stringWithFormat:@"%@:%d;transport=tcp;lr", host,DEFAULT_TURN_PORT];
    }
    return (char *)([t cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (char *)getSipProxy:(IPAddress *)host
{
    NSString *p = nil;
    p =  [NSString stringWithFormat:@"sip:%@:%d;transport=tcp;lr", host.host,host.port];
    char * proxy = (char *)[p cStringUsingEncoding:NSUTF8StringEncoding];
    return proxy;
}

+ (NSDictionary *)parceSipMessage:(pjsip_event *)e
                         imcoming:(BOOL)incoming {
    
    NSString *type = nil;
    NSString *balance = nil;
    NSString *promotion = nil;
    NSString *code = nil;
    NSString *reason = nil;
    NSString *registered = nil;
    NSString *msgType = nil;
    NSString *ratio = nil;
    NSString *callMode = nil;
    NSString *callIdString = nil;
    NSString *isActive = nil;
    NSLog(@"parceSipMessage start");
    if (e == NULL || e->type != PJSIP_EVENT_TSX_STATE) {
        return nil;
    }
    char *msg = NULL;
    int len = 0;
    if (!incoming && e->body.tsx_state.type == PJSIP_EVENT_RX_MSG &&
        e->body.tsx_state.src.rdata != NULL &&
        e->body.tsx_state.src.rdata->msg_info.msg_buf != NULL) {
        msg = e->body.tsx_state.src.rdata->msg_info.msg_buf;
        len = e->body.tsx_state.src.rdata->msg_info.len;
    } else if (incoming && e->body.tx_msg.tdata != NULL &&
               e->body.tx_msg.tdata->info != NULL) {
        msg = e->body.tx_msg.tdata->info;
        NSString *info = [self stringWith:msg andLen:strlen(msg)];
        if ([info length] > 0) {
            NSString *header = [info componentsSeparatedByString:@"/"][0];
            if ([header rangeOfString:@"487"].length > 0) {
                reason = @"terminated";
                code = @"487";
            }
        }
    }
    if (len < 10000 && len > 20 ) {
        //incase a wrong length happened
        NSString *sipMessage = [self stringWith:msg andLen:len];
        NSArray *attrs = [[PJCoreUtil getFirstLine:sipMessage] componentsSeparatedByString:@" "];
        if (attrs.count >= 3 && [attrs[0] hasPrefix:@"SIP/"]) {
            code = attrs[1];
            NSMutableString *reasonMutable = [[NSMutableString alloc] initWithString:@""];
            for (int i=2; i<attrs.count; i++) {
                [reasonMutable appendString:attrs[i]];
            }
            reason = reasonMutable;
        }
        NSArray *byeEndArray = [[self getSpecificLine:@"X-CooTek-End-Call:"
                                            inMessage:sipMessage]
                                  componentsSeparatedByString:@" "];
        if (byeEndArray.count == 2) {
            reason = byeEndArray[1];
        }
        NSArray *cseqArray = [[PJCoreUtil getSpecificLine:@"CSeq:"
                                                inMessage:sipMessage]
                              componentsSeparatedByString:@" "];
        if (cseqArray.count == 3) {
            msgType = cseqArray[2];
        }
        
        NSArray *callModeArray = [[self getSpecificLine:@"X-Call-Mode:"
                                              inMessage:sipMessage]
                                  componentsSeparatedByString:@" "];
        if (callModeArray.count ==2) {
            callMode = callModeArray[1];
        }
        if (callIdString == nil) {
            NSArray *callIdArray = [[self getSpecificLine:@"Call-ID" inMessage:sipMessage]
                                    componentsSeparatedByString:@" "];
            if (callIdArray.count >=2) {
                callIdString = callIdArray[1];
            }
        }
        NSDictionary *callInfo = [VoipUtils extractCallInfo:sipMessage];
        if (callInfo) {
            type = [callInfo objectForKey:@"type"];
            promotion  = [callInfo objectForKey:@"promotion"];
            registered = [callInfo objectForKey:@"registered"];
            ratio = [callInfo objectForKey:@"ratio"];
            balance = [callInfo objectForKey:@"balance"];
            isActive = [callInfo objectForKey:@"isActive"];
        }
        
    }
    NSLog(@"parceSipMessage callId=%@",callIdString);
    reason = [reason lowercaseString];
    return @{@"type":[VoipUtils dictString:type], @"balance":[VoipUtils dictString:balance],
             @"promotion":[VoipUtils dictString:promotion], @"registered":[VoipUtils dictString:registered],
             @"reason":[VoipUtils dictString:reason], @"code":[VoipUtils dictString:code],
             @"msgType":[VoipUtils dictString:msgType], @"ratio":[VoipUtils dictString:ratio],
             @"callMode":[VoipUtils dictString:callMode],@"callId":[VoipUtils dictString:callIdString],
             @"isActive":[VoipUtils dictString:isActive]};
}

+ (NSString *)getTagString:(NSString *)tag inString:(NSString *)string {
    if ([string rangeOfString:tag].length <= 0) {
        return nil;
    }
    NSRange range = [string rangeOfString:tag];
    NSInteger i = range.location + range.length;
    for (; i<string.length; i++) {
        if ([string characterAtIndex:i] == ';') {
            break;
        }
    }
    NSRange targetRange;
    targetRange.length = i - (range.location + range.length);
    targetRange.location = range.location + range.length;
    return [string substringWithRange:targetRange];
}

+ (NSString *)getFirstLine:(NSString *)message {
    NSRange range = [message rangeOfString:@"\r\n"];
    return [message substringToIndex:range.location];
}

+ (NSString *)getSpecificLine:(NSString *)specific inMessage:(NSString *)message{
    NSRange range = [message rangeOfString:specific];
    if (range.length <= 0) {
        return nil;
    }
    NSString *subString = [message substringFromIndex:range.location];
    NSRange range2 = [subString rangeOfString:@"\r\n"];
    if (range2.length > 0) {
        NSRange targetRange;
        targetRange.location = 0;
        targetRange.length = range2.location;
        NSString *targetString = [subString substringWithRange:targetRange];
        return targetString;
    }
    return nil;
}

+ (BOOL)isAstriskIncoming:(NSString *)msg {
    NSString *line = [self getSpecificLine:@"User-Agent:" inMessage:msg];
    return [line rangeOfString :@"Asterisk"].length>0;
    
}

+ (int)parseErrorReason:(NSString *)reason code:(NSString *)code startTime:(long)startTime{
    int error = 0;
    if ([reason isEqualToString:@"canttouchturn"]) {
        error = CAN_NOT_TOUCH_TURN;
        return error;
    }
    
    if ([reason isEqualToString:@"servermaintain"]) {
        error = SERVER_MAITAIN;
        return error;
    }
    
    if ([reason isEqualToString:@"gone"]) {
        error = GONE;
        return error;
    }
    
    if ([reason isEqualToString:@"can'tfindtarget"]) {
        error = DECLINED;
        return error;
    }
    
    if ([reason isEqualToString:@"declined"]) {
        if([[NSDate date] timeIntervalSince1970]*1000 - startTime > 5) {
             error = DECLINED_LONGER;
        }else {
             error = DECLINED;
        }
        return error;
    }
    
    if ([reason isEqualToString:@"busyeverywhere"]) {
        error = BUSY_EVERYWHERE;
        return error;
    }
    
    if ([reason isEqualToString:@"decline"]) {
        error = DECLINE;
        return error;
    }
    
    if ([reason isEqualToString:@"authenticationfailed"]) {
        error = AUTH_FAILED;
        return error;
    }
    
    if ([reason isEqualToString:@"versionexpired"]) {
        error = VERSION_EXPIRED;
        return error;
    }
    
    if ([reason isEqualToString:@"serviceunavailable"]) {
        error = SERVICE_UNAVAILIABLE;
        return error;
    }
    
    if ([reason isEqualToString:@"limit"]) {
        error = ERR_REASON_BYE_SERVER;
    }
    
    if ([reason isEqualToString:@"forbidden"]) {
        error = FORBIDDEN;
        return error;
    }
    
    if ([reason isEqualToString:@"mediainiterror"]) {
        error = MEDIA_INIT_ERROR;
        return error;
    }
    
    if ([reason isEqualToString:@"requesttimeout"]) {
        error = REQUEST_TIME_OUT;
        return error;
    }
    
    if ([reason isEqualToString:@"nortptimeout"]) {
        error = NO_RTP_TIME_OUT_C2P;
        return error;
    }
    
    if ([reason rangeOfString:@"loopdetected"].length > 0) {
        error = LOOP_DETECTED;
        return error;
    }
    
    if ([reason hasPrefix:@"transportfailure"]) {
        error = TRANSPORT_FAILURE;
        return error;
    }
    
    if ([reason isEqualToString:@"connectiontimeout"]) {
        error = CONNECTION_TIME_OUT;
        return error;
    }
    
    if ([reason rangeOfString:@"connectionresetbypeer"].length > 0) {
        error = CONNECTION_RESET;
        return error;
    }
    
    if ([reason rangeOfString:@"endoffile"].length > 0) {
        error = CONNECT_INTERRUPT;
        return error;
    }
    
    if ([reason rangeOfString:@"flowfailed"].length > 0) {
        error = FLOW_FAILED;
        return error;
    }
    
    if ([reason rangeOfString:@"badrequest"].length > 0) {
        error = BAD_REQUEST;
        return error;
    }
    
    if ([reason rangeOfString:@"blacklist"].length > 0) {
        error = BLACK_LIST;
        return error;
    }
    
    if ([reason rangeOfString:@"countryoffline"].length > 0) {
        error = ERR_REASON_COUNTRY_OFFLINE;
        return error;
    }
    
    if ([reason rangeOfString:@"countryunsupported"].length > 0) {
        error = ERR_REASON_COUNTRY_UNSUPPORT;
        return error;
    }
    
    if ([reason rangeOfString:@"excessivecalls"].length > 0) {
        error = ERR_REASON_EXCESSIVE_CALLS;
        return error;
    }
    
    if ([reason rangeOfString:@"invalidcaller"].length > 0) {
        error = ERR_REASON_INVALID_CALLER;
        return error;
    }
    
    if ([reason rangeOfString:@"harassing"].length > 0) {
        error = ERR_REASON_HARASSING;
        return error;
    }
    
    if ([reason rangeOfString:@"fixednumberunsupported"].length > 0) {
        error = ERR_REASON_CALLEE_NUMBER_UNSPORRT;
        return error;
    }
    
    if ([reason rangeOfString:@"calleetypeunsupported"].length > 0) {
        error = ERR_REASON_CALLEE_TYPE_UNSPORRT;
        return error;
    }
    
    if ([reason rangeOfString:@"calleeuseroffline"].length > 0) {
        error = ERR_REASON_CALLEE_OFFLINE_UNSPORRT;
        return error;
    }
    if ([reason rangeOfString:@"calleeuserisnottouchpal"].length > 0) {
        error = ERR_REASON_CALLEE_TOUCHPAL;
        return error;
    }
    
    if ([reason rangeOfString:@"callerlocationinfoempty"].length > 0) {
        error = ERR_REASON_CALLER_LOCATION;
        return error;
    }
    
    if (code.length > 0 && ![code hasPrefix:@"2"]
        && ![code hasPrefix:@"1"] && ![code isEqualToString:@"407"]
        && reason.length > 0 && ![reason isEqual:@"busyhere"]) {
        error = UNKNOWN_ERROR;
        return error;
    }
    return error;
}
@end
