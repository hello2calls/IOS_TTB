//
//  VoipBackCall.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/3.
//
//

#import "VoipBackCall.h"
#import "GCDAsyncUdpSocket.h"
#import "UserDefaultsManager.h"
#import "PhoneNumber.h"
#import "NSString+MD5.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"
#import "STUNClient.h"
#import "VoipUtils.h"
#import "PJSIPManager.h"
#import "EdgeSelector.h"
#import "TPCallActionController.h"
#import "VOIPCall.h"
#import "LoginController.h"
#import "DefaultLoginController.h"
#import "PJCoreUtil.h"
#import "SIPConst.h"
#import "DialerUsageRecord.h"
#import "NSString+TPHandleNil.h"
#import "SeattleFeatureExecutor.h"


#define UDP_SERVER_PORT 5069
#define UDP_CLIENT_PORT 3434

@interface VoipBackCall() {
    int _tryCount;
    long _startTime;
}

@property (nonatomic, copy)NSString *number;
@property (nonatomic, copy)NSString *edge;
@property (nonatomic, copy) NSString *loaction;
@property (nonatomic, retain)GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, copy)NSData *inviteData;

@property (nonatomic, assign)id<CallStateChangeDelegate> backCallDelegate;

@end

@implementation VoipBackCall


- (id)initWithNumber:(NSString *)number
                edge:(NSString *)edge
            location:(NSString *)location
         andDelegate:(id<CallStateChangeDelegate>)delegate{
    self = [super init];
    if (self) {
        _tryCount = 5;
        _startTime = [[NSDate date] timeIntervalSince1970];
        _backCallDelegate = delegate;
        self.number = number;
        self.edge = edge;
        GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        if(![socket bindToPort:0 error:nil]) {
            [self  onError:UNKNOWN_ERROR];
            socket = nil;
            return nil;
        }
        if (![socket beginReceiving:nil]) {
            [self  onError:UNKNOWN_ERROR];
            socket = nil;
            return nil;
        }
        self.udpSocket = socket;
        self.loaction = location;
        self.inviteData = [self getInviteData];

    }
    return self;
}


- (void)dealloc {
    [TPCallActionController onVoipCallHangupWithCallDur:0 isDirectCall:NO];
    if (_udpSocket) {
        [_udpSocket close];
    }
}

- (void)onError:(int)code {
    if (_backCallDelegate) {
        [_backCallDelegate onCallErrorWithCode:code];
        _backCallDelegate = nil;
    }

}

- (void)sendInviteMsg {
    NSString *server = self.edge;
    cootek_log(@"VoipCallback sendInviteMsg(%@:%d)",server,UDP_SERVER_PORT);
    [_udpSocket sendData:_inviteData toHost:server
                    port:UDP_SERVER_PORT withTimeout:1 tag:0];
    [self performSelector:@selector(onTryingTimeUp) withObject:nil afterDelay:1];
}

- (void)onTryingTimeUp {
    if (_tryCount > 0) {
        [self sendInviteMsg];
        _tryCount --;
    } else if (_tryCount == 0) {
        [self onError:WAIT_TRYING_TIME_OUT];
    }
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    cootek_log(@"VoipCallback didSendDataWithTag =%d",tag);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
     cootek_log(@"VoipCallback didNotSendDataWithTag =%d,%@",tag,error);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    cootek_log(@"VoipBackCall didReceiveData = %@",data);
    if (!data) {
        return;
    }
    NSString *msg = [NSString stringWithUTF8String:[data bytes]];
    NSString *state = [msg componentsSeparatedByString:@";"][0];
    NSString *callId = [self getCallIdInMsg:msg];
    if (![callId isEqual:_callId]) {
        return;
    }
    NSString *reason = [[self getReason:msg] lowercaseString];
    cootek_log(@"VoipBackCall callid=%@ reason=%@ state=%@",callId,reason,state);
    if ([state isEqualToString:@"TRYING"]) {
        _tryCount = -1;
        [self performSelector:@selector(onResultTimeUp) withObject:nil afterDelay:15];
    } else {
        NSDictionary *callInfo = [VoipUtils extractCallInfo:msg];
        if ([state isEqualToString:@"result=true"]) {
            if (_backCallDelegate) {
                [_backCallDelegate onCallStateInfo:callInfo];
            }
            if (_backCallDelegate) {
                [_backCallDelegate onCallModeSet:VOIP_CALL_BACK];
            }
            _backCallDelegate = nil;
            [UserDefaultsManager setObject:@{callId:@([[NSDate date] timeIntervalSince1970])}
                                    forKey:VOIP_LAST_CALLBACK_SUCCESS];
            _tryCount = -2;
            [self sendAck];
        } else if ([state isEqualToString:@"result=false"]) {
            _tryCount = -2;
            [self sendAck];
            reason = [[reason stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
            int error = [PJCoreUtil parseErrorReason:reason code:@"" startTime:_startTime];
            if (error == AUTH_FAILED||error == ERR_REASON_INVALID_CALLER) {
                // something about the token is wrong, so do some recording work
                NSDictionary *usageInfo = @{
                    @"error": @(error),
                    @"reason": [NSString nilToEmpty:reason],
                    @"state": [NSString nilToEmpty:state],
                    @"callerId": [NSString nilToEmpty:callId],
                    @"token": [NSString nilToEmpty:[SeattleFeatureExecutor getToken]]
                };
                [DialerUsageRecord recordpath:PATH_RELOGIN
                                          kvs:Pair(RELOGIN_FROM_BACK_CALL, usageInfo), nil];
                
                [VOIPCall needToRegisterAgainWithOkBlock:^{
                    [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"call_reloagin"]];
                } cancelBlock:nil];
                [LoginController removeLoginDefaultKeys];
            }
            [self onError:error];
        }
        
    }
}

- (void)onResultTimeUp {
    if (_tryCount != -2) {
        [self onError:WAIT_RESULT_TIME_OUT];
    }
}

- (NSString *)getCallIdInMsg:(NSString *)msg {
    NSString *firstLine = [msg componentsSeparatedByString:@"\r\n"][0];
    NSArray *subs = [firstLine componentsSeparatedByString:@"call-id="];
    return subs[subs.count - 1];
}

- (NSString *)getReason:(NSString *)msg {
    return [FunctionUtility getTagString:@"reason=" inString:[msg componentsSeparatedByString:@"\r\n"][0]];
}

- (NSData *)getAckData {
    NSString *msg = [NSString stringWithFormat:@"ACK;call-id=%@", _callId];
    return [msg dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)sendAck {
    [_udpSocket sendData:[self getAckData] toHost:self.edge port:UDP_SERVER_PORT withTimeout:1 tag:0];
}

- (NSData *)getInviteData {
    NSData *data = nil;
    NSString *from = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    NSString *to = [PhoneNumber getCNnormalNumber:_number];
    NSDate *expiredDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *expired = [formater stringFromDate:expiredDate];
    NSString *auth = [NSString stringWithFormat:@"%@%@%@", from, expired, [self getReversedString:from]];
    NSString *authMd5 = [auth MD5Hash];
    long timestamp = (long)[[NSDate date] timeIntervalSince1970] * 1000;
    NSString *call_id = [NSString stringWithFormat:@"%@-%@-%ld",
                         [from substringFromIndex:1],
                         [to substringFromIndex:1],
                         timestamp];
    NSString *env = [NSString stringWithFormat:@"%@", [VoipUtils getVoipEnvironmentString:@"back"]];
    if (self.loaction != nil) {
        env = [NSString stringWithFormat:@"%@%@",env,self.loaction];
    }
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@/%@/%@", COOTEK_APP_NAME,
                           CURRENT_TOUCHPAL_VERSION, @"iOS",IPHONE_CHANNEL_CODE];
    

    NSString *msg = [NSString stringWithFormat:@"INVITE;from=%@;to=%@;auth=\"auth=%@;expired=\"%@\"\";call-id=%@;ua=%@;env=%@", from, to, authMd5, expired, call_id, userAgent, env];
    data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    cootek_log(@"callback invite 2G = %@",msg);
    self.callId = call_id;
    return data;
}

- (NSString *)getReversedString:(NSString *)from {
    int len = from.length;
    NSMutableString *reversedFrom = [NSMutableString stringWithCapacity:len];
    while (len > 0) {
        [reversedFrom appendFormat:@"%C",[from characterAtIndex:--len]];
    }
    return reversedFrom;
}

@end
