//
//  PJCore.m
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/13.
//
//

#import "PJCore.h"
#import "PJCoreUtil.h"
#import "VoipUtils.h"
#import "UserDefaultsManager.h"
#import "SIPConst.h"
#import "EdgeSelector.h"
#import "FunctionUtility.h"
#import "TouchPalVersionInfo.h"
#import "SeattleFeatureExecutor.h"
#import "PJSIPManager.h"
#import "PhoneNumber.h"
#import "LocalStorage.h"
#import "VOIPCall.h"
#import "LoginController.h"
#import "CootekSystemService.h"
#import "AppSettingsModel.h"
#import "TPCallActionController.h"
#import "DefaultLoginController.h"
#import "Calllog.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "VoipBackCall.h"
#import "DialerUsageRecord.h"
#import "CallRingUtil.h"
#import "NSString+TPHandleNil.h"
#import "C2CCallProvider.h"
#import "VoipUsageConst.h"
#import "IncomingNotificationManager.h"
#import "VoIPSocketManager.h"
#import "sip_transport_tcp.h"

#define THIS_FILE @"PJCore"

#define CHECK_NO_RESPONSE_INTERVAL 10*1000
#define CHECK_NO_RTP_INTERVAL 10*1000
#define RETRY_MAX_TIMES 5
#define MAX_RETRY_COUNT 15

#define CALLBACK(x)  [x isEqualToString:@"back"]
#define CONFERENCE(x)  [x isEqualToString:@"conference"]

static PJCore *sCore = nil;

@interface VoipCall : NSObject

@property(nonatomic,copy) NSString *number;
@property(nonatomic,assign) long startTime;
@property(nonatomic,assign) long connectTime;
@property(nonatomic,copy) NSString *callMode;
@property(nonatomic,assign) BOOL callbackSuccess;
@property(nonatomic,assign) BOOL isAuto;
@property(nonatomic,assign) BOOL isCToP;
@property(nonatomic,assign) long lastRecPackage;
@property(nonatomic,assign) BOOL isIncoming;
@property(nonatomic,assign) BOOL userhangup;
@property(nonatomic,assign) BOOL isConnect;
@property(nonatomic,assign) long ringStart;
@property(nonatomic,assign) int  errorCode;
@property(nonatomic,assign) int  retryCount;
@property(nonatomic,assign) BOOL speaker;
@property(nonatomic,assign) BOOL mute;
@property(nonatomic,assign) BOOL accept;
@property(nonatomic,copy) NSString *location;

+ (VoipCall *)createVoipCall:(NSString *)number incoming:(BOOL)isincoming;

@end

@implementation VoipCall

+ (VoipCall *)createVoipCall:(NSString *)number
                    incoming:(BOOL)isincoming {
    VoipCall *call = [[VoipCall alloc] init];
    call.number = number;
    call.startTime = [[NSDate date] timeIntervalSince1970]*1000;
    call.isCToP = NO;
    call.lastRecPackage = -1;
    call.isIncoming = isincoming;
    call.errorCode = 0;
    call.connectTime = 0;
    return call;
    
}

@end

@interface PJCore () <CallStateChangeDelegate,CLLocationManagerDelegate>{
    PJThread *_thread;
    C2CCallProvider *_c2cProvider;
    VoIPSocketManager *_socketManager;
    pjsip_transport *callTransport;
    volatile enum CoreStatus _status;
    
    NSMutableDictionary *_callAttrs;
    NSString *_preCallId;
    EdgeSelectPara *_currentTurnHost;
    VoipCall *_callinfo;
    ClientNetworkType _netType;
    id<CallStateChangeDelegate> _delegate;
    int _retryCount;
    BOOL _userUnregister;
    BOOL _initializePJ;
    
    NSMutableArray *_c2cList;
    NSMutableArray *_c2pList;
    CLLocationManager *_locationManager;
    NSDictionary *_callParm;
    BOOL _inviteLocationCompeleted;
}

- (void)inviteLocationInPJ;

@end


@implementation PJCore

+ (BOOL)meetc2cEnvironment {
    ClientNetworkType netType = [[Reachability shareReachability] networkStatus];
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
    && [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
    if (!isVoipOn) {
        return NO;
    }
    if ([UserDefaultsManager boolValueForKey:VOIP_ENABLE_CELL_DATA]
        && netType >= network_3g) {
        return YES;
    }
    if ([UserDefaultsManager boolValueForKey:VOIP_INTERNATIONAL_ENABLE_CELL_DATA]
        && netType >= network_3g && ![FunctionUtility isInChina]) {
        return YES;
    }
    return netType >= network_wifi;
}

+ (void)initialize {
    cootek_log(@"[%@]:%@",THIS_FILE,@"initialize ...");
    sCore = [[PJCore alloc] init];
    [sCore initThread];
}

+ (PJCore *)instance {
    @synchronized(self) {
        return  sCore;
    }
}

- (void)initThread {
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread],@"start init PJThread");
    _thread = [[PJThread alloc] initWithDelegate:self];
    [_thread start];
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread],@"init core end");
    if (IOS_10_OR_LATER) {
        _c2cProvider = [[C2CCallProvider alloc] init];
    }
    _socketManager = [[VoIPSocketManager alloc] init];
    [self initLocateManager];
}

/*below methord call for public*/

- (void)setCallStatusDelegate:(id<CallStateChangeDelegate>)delegate {
    cootek_log(@"%@[%@]:%@:%@",THIS_FILE,[NSThread currentThread].name,@"set delegate ",delegate);
    @synchronized(self) {
        _delegate = delegate;
    }
}

- (void)setCallSpeaker:(BOOL)isSpeaker {
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"set Call Speaker");
    if (_callinfo != NULL) {
        _callinfo.speaker = isSpeaker;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                               error:NULL];
        if(isSpeaker) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
        } else {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:NULL];
        }
    }

}

- (void)setCallMute:(BOOL)mute {
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"set Call mute");
    if (_callinfo != NULL) {
    _callinfo.mute = mute;
    [self performSelector:@selector(setMutePJ)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
    }
}

- (void)setCallMute {
    if (![self isCalling]){
        return;
    }
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"set Call mute");
    if (_callinfo != NULL) {
        _callinfo.mute = !_callinfo.mute;
        [self performSelector:@selector(setMutePJ)
                     onThread:_thread
                   withObject:nil
                waitUntilDone:NO
                        modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
        [self weakupPJThread];
    }
}

- (NSString *)callNumber {
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"get Call number");
    if ([self isCalling] && _callinfo) {
        return _callinfo.number;
    }
    return nil;
}

- (void)weakupPJThread {
    @synchronized(self) {
        [_thread weakup];
    }
}

- (void)networkChanged {
    cootek_log(@"%@[%@]:%@=%@",THIS_FILE,[NSThread currentThread].name,@"Call network changed",[NSThread callStackSymbols]);
    [self performSelector:@selector(eventNetworkChanged)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
    
}

- (void)recordCallbackIncoming {
    NSDictionary * dic = [UserDefaultsManager dictionaryForKey:VOIP_LAST_CALLBACK_SUCCESS];
    if (dic != nil) {
        long time = [[dic.allValues objectAtIndex:0] longValue];
        if ([[NSDate date] timeIntervalSince1970] - time <= 30) {
            _callAttrs[CALLBACKINCOMING] = @"iphone";
            NSString *callId = [dic.allKeys objectAtIndex:0];
            NSLog(@"VOIP_CALLBACK_INCOMINGCALL callId= %@",callId);
            [DialerUsageRecord recordpath:PATH_VOIP_CALLBACK_INCOMINGCALL kvs:Pair(KEY_CALLID, callId), nil];
        }
    }
}

- (BOOL)isCurrentCall:(NSString *)uuid {
    if(_c2cProvider) {
        return [_c2cProvider isCurrent:uuid];
    }
    return false;
}

- (BOOL)isTouchPalVoipCall:(NSString *)uuid {
    if(_c2cProvider) {
        return [_c2cProvider isTouchPalVoipCall:uuid];
    }
    return false;
}

- (void)systemCall:(SystemCallStatus)status {
    cootek_log(@"%@:%@:%d",THIS_FILE,@"systemCall.....",_status);
    if (_status == CoreStatusCallTalking) {
        [self performSelector:@selector(resetSoundDevice:)
                     onThread:_thread
                   withObject:@(status)
                waitUntilDone:NO
                        modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
        [self weakupPJThread];
        
    } else {
        if (SystemCallStatusIncoming == status) {
            [_callAttrs[INFO_FLOW] appendFormat:@"%@|",@"callbackincoming"];
            [_callAttrs[STATUS_FLOW] appendFormat:@"%@|",@"callbackincoming"];
            [self recordCallbackIncoming];
        }
        if((_status == CoreStatusIncoming || _status == CoreStatusOutgoning) &&
           status == SystemCallStatusConnect) {
            [self onCallErrorWithCode:SYSTEM_CALL_INCOMING];
        }
        if (status ==SystemCallStatusDisconnect && [Reachability network] != network_wifi) {
            cootek_log(@"%@:%@:%d",THIS_FILE,@"systemCall.....refresh register",status);
            [self performSelector:@selector(networkChanged) withObject:nil afterDelay:5];
        }
    }
}

- (void)connectDevice {
    
    if(![self isCalling]) {
        return;
    }
    cootek_log(@"%@:%@",THIS_FILE,@"connectDevice.....");
    [self performSelector:@selector(connectDevicePJ)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)initCore {
    if (_status != CoreStatusShutDown) {
        cootek_log(@"%@:%@",THIS_FILE,@"waring have init core then return");
        return;
    }
    [self performSelector:@selector(initPJCore)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

- (void)deinitPJCore {
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"deinit PJCore");
    [self performSelector:@selector(destoryCore)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (BOOL)isInit {
    @synchronized(self) {
        return _status != CoreStatusShutDown && _initializePJ;
    }
}

- (BOOL)isCalling {
    @synchronized(self) {
        return (_status == CoreStatusCallTalking
                || _status == CoreStatusOutgoning
                || _status == CoreStatusIncoming);
    }
}

- (int)callDuration {
    if(_callinfo && _callinfo.connectTime > 0) {
        return ([[NSDate date] timeIntervalSince1970] *1000 - _callinfo.connectTime)/1000;
    }
    return 0;
}

- (BOOL)isAnswerIncomingCall {
    return _callinfo.accept;
}

- (void)keepOnline {
    if (_status == CoreStatusShutDown) {
        [self initPJCore];
        return;
    }
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"keepOnline");
    [self performSelector:@selector(eventRegitsering)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)unregister {
    _userUnregister = YES;
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"unregister");
    [self performSelector:@selector(eventUnregister)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)hangup:(NSString *)info {
    cootek_log(@"hangup info=%@",[NSThread callStackSymbols]);
    if(![self isCalling]) {
        cootek_log(@"is not in calling......");
        return;
    }
    @synchronized(self) {
        _callAttrs[FINAL_BEV] = [info mutableCopy];
        _callinfo.userhangup = true;
        if(_callinfo.isIncoming) {
            [CallRingUtil stop];
        }
    }
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@"execute call hangup");
    [self performSelector:@selector(hangupParaPJ:)
                 onThread:_thread
               withObject:@(YES)
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    
    [self weakupPJThread];
}

- (void)answer {
    if (![self isCalling]) {
        return;
    }
    @synchronized (self) {
        _callinfo.accept = YES;
    }
   
    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@" call answer");
    [self performSelector:@selector(answerPJ)
                 onThread:_thread
               withObject:nil
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)sendDTMF:(NSString *)chr {
    if (![self isCalling]) {
        return;
    }

    cootek_log(@"%@[%@]:%@",THIS_FILE,[NSThread currentThread].name,@" call sendDTMF");
    [self performSelector:@selector(playDTMF:)
                 onThread:_thread
               withObject:[chr mutableCopy]
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)inviteCall:(NSString *)number
              mode:(NSString *)back
          delegate:(id<CallStateChangeDelegate>)delegate {
    if (_callAttrs != nil) {
        [self clearStat];
    }
    cootek_log(@"%@[%@]:%@:%d",THIS_FILE,[NSThread currentThread].name,@" call invite",_status);
    if ([number length] > 0 && delegate != nil && [back length] > 0) {
        if (_c2cProvider && !CONFERENCE(back)) {
            [_c2cProvider reportOutgoingCall:number];
        }
        _inviteLocationCompeleted = NO;
        _callParm = @{@"number":[number mutableCopy],@"mode":[back mutableCopy],@"delegate":delegate};
        [_locationManager startUpdatingLocation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_inviteLocationCompeleted == NO) {
                [self inviteLocationInPJ];
            }
        });
    }
}


- (void)initLocateManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.delegate = self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (_inviteLocationCompeleted == YES) {
        return;
    }
  
    NSMutableDictionary *param = [_callParm mutableCopy];
    if(newLocation != nil) {
        NSString *location = [NSString stringWithFormat:@";lat=%.6f;lng=%.6f",
                    newLocation.coordinate.latitude,
                    newLocation.coordinate.longitude];
        [param setValue:location forKey:@"location"];
    }

    _inviteLocationCompeleted  = YES;
    [_locationManager stopUpdatingLocation];
    cootek_log(@"%@[%@]:%@:%d",THIS_FILE,[NSThread currentThread].name,@" call inviteCallPJ",_status);
    [self performSelector:@selector(inviteCallPJ:)
                 onThread:_thread
               withObject:[param copy]
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)inviteLocationInPJ
{
    _inviteLocationCompeleted  = YES;
    [_locationManager stopUpdatingLocation];

    cootek_log(@"%@[%@]:%@:%d",THIS_FILE,[NSThread currentThread].name,@" call inviteCallPJ",_status);
    [self performSelector:@selector(inviteCallPJ:)
                 onThread:_thread
               withObject:[_callParm copy]
            waitUntilDone:NO
                    modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    [self weakupPJThread];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (_inviteLocationCompeleted == YES) {
        return;
    }
    [self inviteLocationInPJ];
}

- (int)avg:(NSArray *)list {
    int count = list.count;
    int sum = 0;
    for (int i = 0; i< count; i++) {
        sum = sum + [[list objectAtIndex:i] intValue];
    }
    int ave = 0;
    if (count > 0) {
        ave = sum/count;
    }
    return ave;
}

- (void)uploadUsageStat {
    int c2pMax = 0;
    int c2pAve = 0;
    int c2cMax = 0;
    int c2cAve = 0;
    if (_c2cList != nil && _c2cList.count > 0) {
        [_c2cList sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            return [obj1 intValue] > [obj2 intValue];
        }];
        c2cMax = [[_c2cList lastObject] integerValue];
        c2cAve = [self avg:_c2cList];
    }
    if (_c2pList != nil && _c2pList.count > 0) {
        [_c2pList sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
            return [obj1 intValue] > [obj2 intValue];
        }];
        c2pMax = [[_c2pList lastObject] integerValue];
        c2pAve = [self avg:_c2pList];
    }
    _callAttrs[TS_DELAY_INFO] = [NSString stringWithFormat:@"aveC2c:%d aveC2p:%d maxC2c:%d maxC2p:%d",c2cAve,c2pAve,c2cMax,c2pMax];
    [VoipUtils uploadCallStat:[_callAttrs copy]];
}

/*below methord runing on PJThread*/

- (void)setMutePJ {
    NSLog(@"setMutePJ %d",_status);
    pjsua_state state = pjsua_get_state();
    if (state < PJSUA_STATE_INIT) {
        return;
    }
    float volume = _callinfo.mute ? 0.0f : 1.0f;
    pjsua_conf_adjust_rx_level(0, volume);
}

- (void)playDTMF:(NSString *)chr {

    [_thread sendDTMF:chr];
}

- (void)connectDevicePJ {
    [_thread disableDevice];
    [_thread usePlayAndRecordDevice];
}

- (void)resetSoundDevice:(SystemCallStatus) status {
    NSLog(@"resetSoundDevice %d",status);
    switch (status) {
        case SystemCallStatusDisconnect:
        {
            if (!CALLBACK(_callinfo.callMode)) {
                [_thread usePlayAndRecordDevice];
                _callinfo.mute = false;
                [self setMutePJ];
            }
            break;
        }
            
        case SystemCallStatusConnect:
        {
            if (!CALLBACK(_callinfo.callMode)) {
                _callinfo.mute = true;
                [self setMutePJ];
            }
            break;
        }
        case SystemCallStatusCalling:
        case SystemCallStatusIncoming:
        {
            if (!CALLBACK(_callinfo.callMode)) {
                [_thread disableDevice];
            }
            break;
        }
    }
}

- (void)eventNetworkChanged {
    ClientNetworkType type = [[Reachability shareReachability] networkStatus];
    cootek_log(@"%@[%@][%d][%d=%d]",THIS_FILE,@"eventNetworkChanged",_status,_netType,type);
    if (_netType == type) {
        return;
    }
    if (_status == CoreStatusShutDown) {
        if (type > network_3g) {
            [self initPJCore];
        }
    } else {
        if ( _status == CoreStatusOutgoning
            && _netType != type
            && !CALLBACK(_callinfo.callMode)) {
            if (type == network_none) {
                [self onCallErrorWithCode:NETWORK_DISCONNECT];
            } else {
                cootek_log(@"%@%@%d",THIS_FILE,@"eventNetworkChanged calling = ",_callinfo.errorCode);
                _callinfo.errorCode = NETWORK_CHANGED;
            }
        }
        if(_status != CoreStatusRegistering) {
            if (type < network_3g) {
                [self eventUnregister];
            } else if(_netType == network_wifi && _status == CoreStatusOutgoning){
                if (callTransport != NULL && callTransport->is_shutdown == 0) {
                    cootek_log(@"eventNetworkChanged shutdown tcp ......",_status);
                    [_thread disconnectTcp:callTransport];
                } else {
                    callTransport = NULL;
                }
            } else {
                [self eventConnectFailed];
            }
        }
    }
}

- (void)eventConnectFailed {
    _retryCount  = 0;
    EdgeSelector *selector = [[EdgeSelector alloc] initWithEdge:nil initPJ:_initializePJ];
    [selector selectEdge:^(EdgeSelectPara *edge) {
        if (edge != nil) {
            cootek_log(@"%@[%@]pre:%@ cur:%@",THIS_FILE,@"eventConnectFailed ",_currentTurnHost.edge.host,edge.edge.host);
            if (![_currentTurnHost.edge.host isEqualToString:edge.edge.host]) {
                _currentTurnHost = [edge copy];
                [self eventAccountChanged:_currentTurnHost.edge];
            } else {
                [self eventRegitsering];
            }
        }
    } needRetry:NO];
}

- (void)eventAccountChanged:(IPAddress *)edge {
    cootek_log(@"%@[%@]",THIS_FILE,@"eventAccountChanged=PJ");
    @synchronized(self) {
        if (CoreStatusIdle == _status) {
            _status = CoreStatusRegistering;
        }
    }
    pj_status_t status = [_thread configAccount:edge keepOnline:[PJCore meetc2cEnvironment]];
    if (status != PJ_SUCCESS) {
        [self eventRetry];
    }
}

- (void)eventRegitsering {
    cootek_log(@"eventRegitsering = %d",_status);
    @synchronized(self) {
        if (_status == CoreStatusIdle) {
            _status = CoreStatusRegistering;
        }
    }
    [self enterRegitsering];
    
}

- (void)invitePara:(NSDictionary *)dict {
    NSString *number = [dict objectForKey:@"number"];
    NSString *mode = [dict objectForKey:@"mode"];
    NSString *location = [dict objectForKey:@"location"];
    id<CallStateChangeDelegate> delegate = [dict objectForKey:@"delegate"];
    ClientNetworkType netwrokType = [[Reachability shareReachability] networkStatus];
    BOOL autoback = network_3g > netwrokType && CALLBACK(mode);
    [self setCallStatusDelegate:delegate];
    cootek_log(@"%@[%@]:%@(%@,%d)",THIS_FILE,[NSThread currentThread].name,@"invitePara=",mode,_status);
    
    _callinfo = [VoipCall createVoipCall:number incoming:NO];
    _callinfo.callMode = mode;
    _callinfo.isAuto = autoback;
    _callinfo.location = location;
    int type  = 0;
    if(CALLBACK(mode)) {
        type = (_callinfo.isAuto ? 3:2);
    } else if(CONFERENCE(mode)) {
        type = 4;
    }
    [self recordNormalCallAttrs:number callType:type];
}

- (void)inviteCallPJ:(NSDictionary *)dict {
    [self invitePara:dict];
    if (_callinfo.isAuto) {
        cootek_log(@"inviteAutoCallback UDP");
        [self inviteAutoCallback];
    } else {
        if (_initializePJ) {
            _status = CoreStatusOutgoning;
        }
        cootek_log(@"inviteCallPJ TCP call Start");
        if(!_initializePJ) {
            [self initPJCore];
        } else {
            [self eventCall:_callinfo.number mode:_callinfo.callMode];
        }
    }
}

- (void)eventCallWhenInit:(NSString *)number
                     mode:(NSString *)mode {
    @synchronized(self) {
        _status = CoreStatusOutgoning;
    }
    [self eventCall:number mode:mode];
}

- (void)eventCall:(NSString *)number
             mode:(NSString *)mode {
    if (CALLBACK(mode) || CONFERENCE(mode)) {
        [DialerUsageRecord recordpath:PATH_VOIP_SWITCH_CALLBACK kvs:Pair(KEY_CALLTYPE, @"manaul"), nil];
        [_thread inviteCall:number mode:mode location:_callinfo.location];
    } else if([number length] > 0 && [mode length] > 0){
        [DialerUsageRecord recordpath:PATH_VOIP_CALL_DIRECT_DIAL kvs:Pair(KEY_COUNT, @(1)), nil];
        _callAttrs[OPTION_REQUEST_TIME] = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
        BOOL result = [_thread doOption:_currentTurnHost.source.host];
        if (result == false) {
            result = [_thread inviteCall:number mode:mode location:_callinfo.location];
        }
    } else {
        cootek_log(@"eventCall error....number nil");
        @synchronized (self) {
            _status = CoreStatusIdle;
        }
    }
}

- (void)initPJCore {
    if (_status != CoreStatusShutDown) {
        return;
    }
    EdgeSelector *selector = [[EdgeSelector alloc] initWithEdge:nil
                                                         initPJ:_initializePJ];
    @synchronized(self) {
        _status = CoreStatusRegistering;
    }
    [selector selectEdge:^(EdgeSelectPara *edge) {
        if (edge == nil) {
            [self onCallErrorWithCode:NETWORK_ERROR];
        } else {
            _currentTurnHost = [edge copy];
            bool isC2C = [PJCore meetc2cEnvironment];
            BOOL result = [_thread initPJsip:edge.edge keepOnline:isC2C];
            if (result) {
                _initializePJ = YES;
                cootek_log(@"initPJCore = %d",_status);
                @synchronized(self) {
                    if (!isC2C) {
                        _netType = [[Reachability shareReachability] networkStatus];
                        _status = CoreStatusIdle;
                        [self enterIdle];
                    }
                }
             
                if (_callinfo != nil) {
                    [self eventCallWhenInit:_callinfo.number mode:_callinfo.callMode];
                }
            } else {
                @synchronized(self) {
                    _initializePJ = NO;
                    _status = CoreStatusShutDown;
                }
            }
        }
    } needRetry:NO];
}

- (void)answerPJ {
    [self setCallSpeaker:_callinfo.speaker];
    [_thread answer];
}

- (void)resetCallValue {
    cootek_log(@"%@:resetCallValue delegate = nil... %d",THIS_FILE,_status);
    [DialerUsageRecord recordpath:PATH_CALL_ERROR kvs:Pair(KEY_ERROR,@(_callinfo.errorCode)), nil];
    _preCallId = _callAttrs[CALL_ID];
    if (!_callinfo.callbackSuccess) {
        [self clearStat];
    }
    _callinfo = nil;
    _delegate = nil;
}

- (void)saveCallData:(int)duration {
    __block BOOL isDirect = !CALLBACK(_callinfo.callMode);
    dispatch_async(dispatch_get_main_queue(), ^{
        [TPCallActionController onVoipCallHangupWithCallDur:duration isDirectCall:isDirect];
    });
    _callAttrs[FINISH_TIME] = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
    if (_callinfo.callbackSuccess) {
            [self resetCallValue];
        cootek_log(@"%@:callback success ,upload usage waitting sys incoming... %d",THIS_FILE,_status);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self uploadUsageStat];
            [self clearStat];
        });
    } else {
        [self uploadUsageStat];
        [self resetCallValue];
    }
}

- (void)hangupParaPJ:(NSNumber *)num {
    [self hangupPJ:[num boolValue]];
}

- (void)hangupPJ:(BOOL)notify {
    @synchronized(self) {
        cootek_log(@"hangupPJ = %d",_status);
        if(_status > CoreStatusRegistering) {
            _status = CoreStatusIdle;
        }
    }
    
    int call_id = [_thread callId];
    if (call_id == PJSUA_INVALID_ID && _callinfo == nil) {
        return;
    }
    cootek_log(@"%@[%@]:%@%@",THIS_FILE,[NSThread currentThread].name,@"hangupPJ=",_callinfo.callMode);
    
    int duration = [_thread callDuration];
    [self recordPackage:[_thread callId]];
    
    if (call_id != PJSUA_INVALID_ID) {
        [_thread hangup];
        [self endCallKeepAliveInMobileUnRegister];
    }
    if (notify == YES) {
        [self onDisconected:duration];
    }
    [self setCallSpeaker:NO];
    [self saveCallData:duration];
}

- (void)destoryCore {
    cootek_log(@"destoryCore = %d",_status);
    @synchronized(self) {
        _initializePJ = NO;
        _status = CoreStatusShutDown;
    }
    
    _currentTurnHost = nil;
    if ([self isCalling]) {
        _callAttrs[FINAL_BEV] = @"deinit core";
        [self hangupPJ:YES];
    }
    [_thread destoryCore];
    
}

- (void)inviteAutoCallback {
    
    [DialerUsageRecord recordpath:PATH_VOIP_SWITCH_CALLBACK kvs:Pair(KEY_CALLTYPE, @"auto"), nil];
    if (_currentTurnHost == nil) {
        EdgeSelector *selector = [[EdgeSelector alloc] initWithEdge:nil
                                                             initPJ:_initializePJ];
        [selector selectEdge:^(EdgeSelectPara *edge) {
            if (edge == nil) {
                [self onCallErrorWithCode:NETWORK_ERROR];
            } else {
                _currentTurnHost = [edge copy];
                [self eventUDPCall:_callinfo.number];
            }
        } enableSchedule:NO];
    } else {
        [self eventUDPCall:_callinfo.number];
    }
}

- (void)eventUDPCall:(NSString *)number {
    VoipBackCall *callbackInvite = [[VoipBackCall alloc] initWithNumber:_callinfo.number
                                                                   edge:_currentTurnHost.edge.host
                                                               location:_callinfo.location
                                                            andDelegate:self];
    [callbackInvite sendInviteMsg];
}


/*below methord notify UI update*/

- (void)onSwitchingToC2P {
    _callinfo.isCToP  = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate == nil) {
            return ;
        }
        [_delegate onSwitchingToC2P];
    });
}

- (void)onRinging {
    cootek_log(@"%@...onRinging",THIS_FILE);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate == nil) {
            return ;
        }
        [_delegate onRinging];
    });
    _callinfo.ringStart =  [[NSDate date] timeIntervalSince1970]*1000;
    _callAttrs[RING_START] = @(_callinfo.ringStart);
}

- (void)onConnected {
    _callinfo.isConnect = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        cootek_log(@"%@:onConnected = %@",THIS_FILE,_delegate);
        if (_delegate !=nil) {
            [_delegate onConnected];
        }
        if (_c2cProvider && !_callinfo.isIncoming) {
            [_c2cProvider reportOutgoingCallConnected];
        }
    });
}

- (void)onCallStateInfo:(NSDictionary *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate != nil) {
            cootek_log(@"%@:onCallStateInfo = %@",THIS_FILE,_callinfo.callMode);
            [_delegate onCallStateInfo:info];
        }
    });
    
}

- (void)showBackgroundMissedC2CNotification:(NSString *)number {
    [[IncomingNotificationManager instance] notifyMissedCall:number];
}

- (void)onDisconected:(int)duration {
    __block id<CallStateChangeDelegate> tmp = _delegate;
    NSString *number = [_callinfo.number copy];
    BOOL userHangup = _callinfo.userhangup;
    dispatch_async(dispatch_get_main_queue(), ^{
         cootek_log(@"onDisconected in MainThread = %@",_delegate);
        if([_c2cProvider currentUseSystemUICalling]) {
            [_c2cProvider reportHangup:^() {
                if(tmp != nil) {
                    [tmp onDisconected];
                }
            }];
            if(duration == 0 && !userHangup && [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
                [self showBackgroundMissedC2CNotification:number];
            }
        } else if(tmp != nil) {
            [tmp onDisconected];
            tmp = nil;
        } else if(_callinfo.isIncoming && !_callinfo.isConnect) {
            [CallRingUtil stop];
        }
    });
}

- (void)onCallErrorWithCode:(int)errorCode
                   delegate:(id<CallStateChangeDelegate>)delegate {
    [self recordFinalBehave:errorCode];
    if ([NSThread currentThread] == _thread) {
        cootek_log(@"onCallErrorWithCode in PJThread =%d",errorCode);
        [self hangupPJ:NO];
    } else {
        cootek_log(@"onCallErrorWithCode not in PJThread =%d",errorCode);
        [self performSelector:@selector(hangupParaPJ:)
                     onThread:_thread
                   withObject:@(NO)
                waitUntilDone:NO
                        modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
        [self weakupPJThread];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_c2cProvider) {
            [_c2cProvider reportHangup:^() {
                if (delegate) {
                    [delegate onCallErrorWithCode:errorCode];
                }
            }];
        } else if (delegate != nil) {
            [delegate onCallErrorWithCode:errorCode];
        }
    });
}

- (void)onCallErrorWithCode:(int)errorCode {
    [self onCallErrorWithCode:errorCode delegate:_delegate];
}

- (void)updateCallModeUsage:(NSString *)callMode {
    if (CALLBACK(callMode) && !_callinfo.callbackSuccess) {
        _callAttrs[FINAL_BEV] = @"Busy here";
        [_callAttrs[INFO_FLOW] appendFormat:@"%@|",@"callbacksuccess"];
        [_callAttrs[STATUS_FLOW] appendFormat:@"%@|",@"callbacksuccess"];
        _callinfo.callbackSuccess = YES;
        _callAttrs[RING_START] = @((long)[[NSDate date] timeIntervalSince1970] * 1000);
        NSString *type = _callinfo.isAuto ? @"auto" : @"manaul";
        if (!CALLBACK(_callinfo.callMode)) {
            _callinfo.callMode = callMode;
            _callAttrs[CALL_TYPE] = @(2);
            _callAttrs[CALLBACKTYPE] = @"direct_server";
            type = @"direct_server";
        }
        if(_callAttrs) {
            NSString *callIdString = _callAttrs[CALL_ID];
            if (callIdString) {
                [DialerUsageRecord recordpath:PATH_VOIP_SWITCH_CALLBACK_SUCCESS
                                          kvs:Pair(KEY_CALLTYPE,type),Pair(KEY_CALLID,callIdString), nil];
                [UserDefaultsManager setObject:@{callIdString:@([[NSDate date] timeIntervalSince1970])}
                                        forKey:VOIP_LAST_CALLBACK_SUCCESS];
            }
        }
        
        if (_callinfo.isAuto) {
            [self saveCallData:0];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate != nil) {
            cootek_log(@"%@:onCallModeSet = %@",THIS_FILE,callMode);
            [_delegate onCallModeSet:callMode];
        }
    });
}

- (void)onCallModeSet:(NSString *)callMode {
    if ([NSThread currentThread] == _thread) {
        [self updateCallModeUsage:callMode];
    } else {
        [self performSelector:@selector(updateCallModeUsage:)
                     onThread:_thread
                   withObject:[callMode copy]
                waitUntilDone:NO
                        modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
        [self weakupPJThread];
    }

}

- (void)notifyEdgeNotStable:(id<CallStateChangeDelegate>)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (delegate != nil) {
            [delegate notifyEdgeNotStable];
        }
    });
}

- (void)onIncoming:(NSString *)number {
    if ([number length] == 0) {
        cootek_log(@"ERROR onIncoming number don't nil");
        return;
    }
    cootek_log(@"onIncoming = %d",_status);
    @synchronized(self) {
        _status = CoreStatusIncoming;
    }
    _callinfo = [VoipCall createVoipCall:number incoming:YES];
    [self recordNormalCallAttrs:number callType:1];
    [_callAttrs[STATUS_FLOW] appendFormat:@"INCOMING|"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_c2cProvider) {
            [_c2cProvider reportIncomingCall:number];
        } else {
            [VOIPCall onIncomingCall:number];
        }
        CallLogDataModel *model = [[CallLogDataModel alloc] init];
        model.number = number;
        model.callType = CallLogIncomingType;
        [CallLog addPendingCallLog:model];
    });
}

- (void)showNeedLoginAlert {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [VOIPCall needToRegisterAgainWithOkBlock:^{
            [LoginController checkLoginWithDelegate:
             [DefaultLoginController withOrigin:@"call_reloagin"]];
        }
                                     cancelBlock:nil];
        [LoginController removeLoginDefaultKeys];
    });
}


/*below methord pjsip callback*/

- (void)onMediaConnect {
    if (!CALLBACK(_callinfo.callMode)) {
        BOOL iswifi = [[Reachability shareReachability] networkStatus] == network_wifi;
        [_thread setStreamWifiNetwork:iswifi];
        [_thread onMediaConnect];
    }
}

- (NSArray *)parseOptionResponse:(NSString *)info {
    if (info) {
        _callAttrs[RTP_SERVER_CANDINATE] = [info mutableCopy];
        NSArray *ips = [info componentsSeparatedByString:@";"];
        int count = ips.count;
        if (count > 0) {
            NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:count];
            for (NSString * ip in ips) {
                if(ip.length > 0) {
                    IPAddress * data = [IPAddress edgeDataWith:ip
                                                          port:DEFAULT_TURN_PORT];
                    [tmp addObject:data];
                }
            }
            return tmp;
        }
    }
    return nil;
}

- (void)onOptionResonse:(NSString *)info {
    cootek_log(@"onOptionResonse result=%@",info);
    _callAttrs[OPTION_RESPONSE_TIME] = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
    if (_status != CoreStatusOutgoning) {
        return;
    }
    
    NSArray *tmp = [self parseOptionResponse:info];
    if (tmp == nil || tmp.count == 0) {
        [_thread inviteCall:_callinfo.number
                       mode:_callinfo.callMode
                   location:_callinfo.location];
    } else {
        EdgeSelector *selector = [[EdgeSelector alloc] initWithEdge:[NSArray arrayWithArray:tmp]
                                                             initPJ:_initializePJ];
        [selector selectEdge:^(EdgeSelectPara *edge) {
            _callAttrs[RTP_SELECT_TIME] = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
            if (_status != CoreStatusOutgoning) {
                cootek_log(@"onOptionResonse edge select finish,call is end");
                return ;
            }
            if (edge != nil) {
                _callAttrs[RTP_SELECT_CANDINATE] = edge.edge.host;
                [_thread inviteCall:_callinfo.number
                               mode:_callinfo.callMode
                                rtp:edge.edge.host
                           location:_callinfo.location];
            } else {
                [_thread inviteCall:_callinfo.number
                               mode:_callinfo.callMode
                           location:_callinfo.location];
            }
        } enable2GSelect:YES];
    }
}

- (void)onLog:(NSString *)msg {
    if ([msg rangeOfString:@"pk_log"].length > 0 && [_callAttrs[POSTKID_FLOW] length] < 20000) {
        msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [_callAttrs[POSTKID_FLOW] appendFormat:@"%@|",msg];
        if([_callAttrs[RELAY_1] length] == 0 && [msg rangeOfString:@"snd r1:"].length >0) {
            _callAttrs[RELAY_1] = [[[msg componentsSeparatedByString:@"snd r1:"] lastObject] mutableCopy];
        }
        if([_callAttrs[RELAY_2] length] == 0 && [msg rangeOfString:@"snd r2:"].length >0) {
            _callAttrs[RELAY_2] = [[[msg componentsSeparatedByString:@"snd r2:"] lastObject] mutableCopy];
        }
    } else if ([msg rangeOfString:@"invalid_gp_log"].length > 0 && [_callAttrs[INVALID_INFO_FLOW] length] < 16000) {
        msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [_callAttrs[INVALID_INFO_FLOW] appendFormat:@"%@|",msg];
    } else if ([msg rangeOfString:@"fec_gap_stat"].length > 0 && msg.length < 16000){
        _callAttrs[GAP_STAT] = [msg mutableCopy];
    } else if ([msg rangeOfString:@"rtt_peer"].length > 0 ){
        NSUInteger tmp = [[[msg componentsSeparatedByString:@":"] lastObject]  integerValue];
        cootek_log(@"rtt_par_peer:%d",tmp);
        [_c2cList addObject:@(tmp)];
    } else if ([msg rangeOfString:@"rtt_first"].length > 0 ){
        NSUInteger tmp = [[[msg componentsSeparatedByString:@":"] lastObject]  integerValue];
        cootek_log(@"rtt_first:%d",tmp);
        [_c2pList addObject:@(tmp)];
    }
}

- (void)onIncomingCall:(int)callid  addSdp:(BOOL)isAddSdp{
    [_thread onIncoming:callid pre:_preCallId addSdp:isAddSdp];
}

- (void)onDestroyStream:(int)callid poskid:(NSString *)kids {
    NSString *bssid = VOIP_LAST_MOBILE_POSTKID;
    if ([[Reachability shareReachability] networkStatus] == network_wifi) {
        bssid =  [FunctionUtility currentWifiBase];
    }
    cootek_log(@"onDestroyStream key=%@,%@",bssid,kids);
    if (bssid != nil && kids != nil) {
        _callAttrs[FINAL_POST_KID] = kids;
        [UserDefaultsManager setObject:kids forKey:bssid];
    }
    [self recordPackage:callid];
}

- (void)fdSocket:(pjsip_transport *)tp createSocket:(BOOL)created {
    if (tp != NULL && strncmp("TCP",tp->type_name,3) == 0) {
        struct tcp_transport *tcp = (struct tcp_transport*)tp;
        if (tcp != NULL) {
            int fd = (int)tcp->sock;
            if (created) {
                [_socketManager onSocketCreated:fd];
            } else {
                [_socketManager onSocketClosed:fd];
            }
        }
    }
}

- (void)onTransportState:(pjsip_transport_state)state transport:(pjsip_transport *)tp {
    cootek_log(@"%@:%@:%d(%p)",THIS_FILE,@"onTransportState = ",state,tp);
    if (state == PJSIP_TP_STATE_SHUTDOWN && callTransport == tp) {
        [self fdSocket:tp createSocket:NO];
        if([PJCore meetc2cEnvironment] && !_userUnregister &&
           _status != CoreStatusRegistering) {
            [self eventConnectFailed];
        }
        callTransport = NULL;
        _userUnregister = NO;
        [self eventOnTransportShutdown];
    } else if(callTransport != tp && state == PJSIP_TP_STATE_CONNECTED) {
        [self fdSocket:tp createSocket:YES];
        callTransport = tp;
    } else if(state == PJSIP_TP_STATE_DESTROY && callTransport == tp){
        callTransport = NULL;
    }
}

- (void)eventOnTransportShutdown {
    if (_callinfo.errorCode == NETWORK_CHANGED && _callinfo.retryCount < 3) {
        cootek_log(@"%@:%@:%d",THIS_FILE,@"onTransportState RETYR CALL ERROR= ",_callinfo.errorCode);
        _callinfo.retryCount ++ ;
        _callinfo.errorCode = 0;
        [_thread hangup];
        SEL methord = @selector(reinviteOnNetworkChanged);
        NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
        NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
        [invocatin setTarget:self];
        [invocatin setSelector:methord];
        [invocatin retainArguments];
        [self scheduleTimer:200 invocation:invocatin];
    } else if(_callinfo.errorCode == NETWORK_CHANGED) {
        cootek_log(@"%@:%@:%d",THIS_FILE,@"onTransportState FINAL ERROR= ",_callinfo.errorCode);
        [self onCallErrorWithCode:_callinfo.errorCode];
    }
}

- (void)reinviteOnNetworkChanged {
    cootek_log(@"%@:%@",THIS_FILE,@"reinviteOnNetworkChanged");
    [_thread inviteCall:_callinfo.number
                   mode:_callinfo.callMode
                    rtp:_callAttrs[RTP_SELECT_CANDINATE]
               location:_callinfo.location];
}

- (void)enterRegitsering {
    _retryCount ++ ;
    cootek_log(@"enterRegitsering .....%d",_retryCount);
    BOOL isEnableC2C = [PJCore meetc2cEnvironment];
    if (isEnableC2C) {
        BOOL result = [_thread setRegister:YES];
        if (result == false) {
            [self eventRetry];
        }
    } else {
        [self eventUnregister];
    }
}

- (void)eventRetry {
    SEL methord = @selector(eventRegitsering);
    NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
    NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
    [invocatin setTarget:self];
    [invocatin setSelector:methord];
    [invocatin retainArguments];
    if (_retryCount < MAX_RETRY_COUNT) {
        [self scheduleTimer:_retryCount * 15 *1000  invocation:invocatin];
    } else {
        [self scheduleTimer:60*60*1000  invocation:invocatin];
    }
}

- (void)eventUnregister {
    cootek_log(@"eventUnregister = %d",_status);
    if (_status == CoreStatusRegistering) {
        @synchronized(self) {
            _status = CoreStatusIdle;
        }
        [self enterIdle];
    }
    [_thread setRegister:NO];
    
}

- (void)enterIdle {
    _retryCount = 0;
}

- (void)onRegister:(BOOL)active
           sipCode:(int)code {
    cootek_log(@"%@:onRegister = (%d,%d,%d)",THIS_FILE,_status,active,code);
    _netType = [[Reachability shareReachability] networkStatus];
    BOOL isC2C = [PJCore meetc2cEnvironment] && !_userUnregister;
    if (SIP_CODE_SERVER_BUSY == code) {
        SEL methord = @selector(eventRegitsering);
        NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
        NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
        [invocatin setTarget:self];
        [invocatin setSelector:methord];
        [invocatin retainArguments];
        [self scheduleTimer:60*60*1000 invocation:invocatin];
    } else if (!active && !isC2C) {
        [self eventUnregister];
    } else if(!active && isC2C) {
        [self eventRetry];
    } else if (_status == CoreStatusRegistering){
        @synchronized(self) {
            _status = CoreStatusIdle;
        }
        [self enterIdle];
    } else if ([self isCalling] && active) {
        _retryCount = 0;
    } else if(active && !isC2C) {
        [_thread disconnectTcp:callTransport];
    }
}

- (void)onCallStateChanged:(int)state
                    callId:(NSString *)callId
                     event:(pjsip_event *)e {
    if (![_thread currentCall:callId] && state != PJSIP_INV_STATE_CALLING) {
        cootek_log(@"call not exits,then ingore");
        return;
    }
    
    NSDictionary *dic = [PJCoreUtil parceSipMessage:e
                                           imcoming:_callinfo.isIncoming];
    NSString *reason = [dic objectForKey:@"reason"];
    NSString *code = [dic objectForKey:@"code"];
    NSString *callMode = [dic objectForKey:@"callMode"];
    NSString *callFeeType = [dic objectForKey:@"type"];
    NSString *callIdString = callId;
    _callAttrs[CALL_ID] = callIdString;
    
    cootek_log(@"%@:onCallStateChanged:(%@,%@,%@,%@,%d,%d)",THIS_FILE,reason,code,callMode,callFeeType,state,_status);
    if ([reason length] > 0) {
        [_callAttrs[INFO_FLOW] appendFormat:@"%@|", reason];
    }
    
    if ([self failedToCall:reason code:code]) {
        return;
    }
    if (callFeeType.length > 0) {
        [self onCallStateInfo:dic];
    } else if (callMode.length > 0) {
        [self onCallModeSet:callMode];
    }
    
    [self setCoreStatus:state];
    if (state == PJSIP_INV_STATE_CALLING) {
        [_callAttrs[STATUS_FLOW] appendFormat:@"CALLING|"];
        _callAttrs[LAST_STATE] = @"before ringing";
        SEL methord = @selector(checkResponse:);
        NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
        NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
        [invocatin setTarget:self];
        [invocatin setSelector:methord];
        [invocatin setArgument:&callId atIndex:2];
        [invocatin retainArguments];
        [self scheduleTimer:CHECK_NO_RESPONSE_INTERVAL invocation:invocatin];
    } else if(state == PJSIP_INV_STATE_DISCONNECTED){
        [_callAttrs[STATUS_FLOW] appendFormat:@"DISCONNCTD|"];
        _callAttrs[LAST_STATE] = @"CallState Disconnect";
        [self hangupPJ:YES];
    } else if (state == PJSIP_INV_STATE_EARLY) {
        [_callAttrs[STATUS_FLOW] appendFormat:@"EARLY|"];
        if([reason isEqualToString:@"switchingtoc2p"]) {
            [self onSwitchingToC2P];
        } else if ([reason isEqualToString:@"ringing"]
                   || [reason isEqualToString:@"sessionprogress"]) {
            if (!_callinfo.isIncoming && _callinfo.ringStart == 0) {
                NSLog(@"VOIP_CALL_DIRECT_RING callId= %@",callIdString);
                [DialerUsageRecord recordpath:PATH_VOIP_CALL_DIRECT_RING
                                          kvs:Pair(KEY_CALLID, callIdString), nil];
            }
            
            _callAttrs[LAST_STATE] = @"ringring";
            _callAttrs[CALL_C2X] = @(_callinfo.isCToP ? 1 : 0);
            [self onRinging];
        }
    } else if (state == PJSIP_INV_STATE_CONNECTING) {
        [_callAttrs[STATUS_FLOW] appendFormat:@"CONNECTING|"];
        [self onRinging];
    } else if (state == PJSIP_INV_STATE_CONFIRMED) {
        [_callAttrs[STATUS_FLOW] appendFormat:@"CONFIRMED|"];
        _callAttrs[LAST_STATE] = @"talking";
        _callinfo.connectTime = (long)([[NSDate date] timeIntervalSince1970] * 1000);
        _callAttrs[TALK_START] = @(_callinfo.connectTime);
        _callAttrs[IS_ANSWERED] = @(1);
        if (_callinfo.lastRecPackage < 0) {
            [self checkNoRtp:_callinfo.connectTime];
        }
        if (!_callinfo.isIncoming && !_callinfo.isConnect) {
            NSLog(@"VOIP_CALL_DIRECT_CONNECT callId= %@",callIdString);
            [DialerUsageRecord recordpath:PATH_VOIP_CALL_DIRECT_CONNECT kvs:Pair(KEY_CALLID, callIdString), nil];
        }
        if (!_callinfo.isConnect) {
            [self startCallKeepAliveInMobileUnRegister];
            [self setPostKids];
        }
        [self onConnected];
    }
}


/*below inner methord*/

- (BOOL)failedToCall:(NSString *)reason
                code:(NSString *)code {
    if ([reason isEqualToString:@"terminated"]) {
        _callAttrs[FINAL_BEV] = @"terminated";
        [self hangupPJ:YES];
        return YES;
    }
    int error = [PJCoreUtil parseErrorReason:reason code:code startTime:_callinfo.startTime];
    if (error == AUTH_FAILED||error==ERR_REASON_INVALID_CALLER) {
        // something about the token is wrong, so do some recording work
        NSDictionary *usageInfo = @{
            @"error": @(error),
            @"reason": [NSString nilToEmpty:reason],
            @"code": [NSString nilToEmpty:code],
            @"token": [NSString nilToEmpty:[SeattleFeatureExecutor getToken]]
        };
        [DialerUsageRecord recordpath:PATH_RELOGIN
                                  kvs:Pair(RELOGIN_FROM_PJCORE, usageInfo), nil];
        
        [self showNeedLoginAlert];
    }
    if (error != 0) {
        [self onCallErrorWithCode:error];
        return YES;
    }
    return NO;
}

- (void)startCallKeepAliveInMobileUnRegister {
    cootek_log(@"start keep alive %d  add......",_status);
    if (_status != CoreStatusCallTalking ||
        callTransport == NULL || [PJCore meetc2cEnvironment])  {
        return;
    }
    pjsip_transport_add_ref(callTransport);
    [self doCallKeepAlive];
}

- (void)endCallKeepAliveInMobileUnRegister {
    cootek_log(@"end keep alive %d  ......",_status);
    if(callTransport == NULL || [PJCore meetc2cEnvironment]) {
        return;
    }
    if (callTransport->is_shutdown == 0) {
         cootek_log(@"end keep alive %d dec ......",_status);
        pjsip_transport_dec_ref(callTransport);
    } else {
        callTransport = NULL;
    }
}

- (void)doCallKeepAlive {
    if (_status != CoreStatusCallTalking || callTransport == NULL) {
        return;
    }
    cootek_log(@"keep alive %d  send......",_status);
    pjsip_tcp_transport_send_ka(callTransport);
    int interval = KEEP_ACCOUNT_ALIVE_INTERVAL;
    SEL methord = @selector(doCallKeepAlive);
    NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
    NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
    [invocatin setTarget:self];
    [invocatin setSelector:methord];
    [invocatin retainArguments];
    [self scheduleTimer: interval* 1000 invocation:invocatin];
}

- (void)checkNoRtp:(long)connectTime {
    if (_status != CoreStatusCallTalking || _callinfo.connectTime != connectTime) {
        return;    
    }
    long current = [_thread recPackage];
    cootek_log(@"checkNoRtp cu=%d,last=%d",current,_callinfo.lastRecPackage);
    if (current == _callinfo.lastRecPackage ) {
        if (_callinfo.isCToP) {
            [self onCallErrorWithCode:NO_RTP_TIME_OUT_C2P];
        } else {
            [self onCallErrorWithCode:NO_RTP_TIME_OUT_C2C];
        }
    } else {
        _callinfo.lastRecPackage = current;
        SEL methord = @selector(checkNoRtp:);
        NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
        NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
        [invocatin setTarget:self];
        [invocatin setSelector:methord];
        [invocatin setArgument:&connectTime atIndex:2];
        [invocatin retainArguments];
        [self scheduleTimer:CHECK_NO_RTP_INTERVAL invocation:invocatin];
    }
}

- (void)checkResponse:(NSString *)callId {
    cootek_log(@"checkResponse = %@",callId);
    if (_status != CoreStatusOutgoning) {
        return;
    }
    [_thread checkResponse:_callinfo.callMode callId:callId];
}

- (void)setCoreStatus:(pjsip_inv_state) state {
    cootek_log(@"setCoreStatus = %d",_status);
    @synchronized (self) {
        switch (state) {
            case PJSIP_INV_STATE_CONFIRMED:
                _status = CoreStatusCallTalking;
                break;
            case PJSIP_INV_STATE_CALLING:
            case PJSIP_INV_STATE_CONNECTING:
            case PJSIP_INV_STATE_EARLY:
                _status = CoreStatusOutgoning;
                break;
            case PJSIP_INV_STATE_INCOMING:
                _status = CoreStatusIncoming;
                break;
            case PJSIP_INV_STATE_NULL:
            case PJSIP_INV_STATE_DISCONNECTED:
                _status = CoreStatusIdle;
                break;
        }
    }
}

- (void)setPostKids {
    NSString *bssid = [FunctionUtility currentWifiBase];
    NSString *lastUsePostKids = nil;
    if (bssid.length == 0) {
        bssid = VOIP_LAST_MOBILE_POSTKID;
    }
    lastUsePostKids = [UserDefaultsManager stringForKey:bssid];
    cootek_log(@"setPostKids key=%@,last=%@",bssid,lastUsePostKids);
    float rate = [UserDefaultsManager floatValueForKey:VOIP_REC_GOOD_RATE_THRESHOLD defaultValue:DEAFULT_GOOD_REC_RATE];
    NSString *kids = [EdgeSelector postKidsRank:lastUsePostKids];
    int interval = [UserDefaultsManager intValueForKey:VOIP_POSTKIDS_CHECK_INTERVAL
                                          defaultValue:DEAFULT_POST_KIDS_CHECK_INTERVAL];
    cootek_log(@"setPostKids=%@,interval=%d",kids,interval);

    [_thread setPostKidsAddress:kids interval:interval rate:rate];
}


/*collect voip call relative info*/

- (void)recordFinalBehave:(int)errorCode {
    if (_callAttrs == nil || _callinfo == nil) {
        return;
    }
    _callinfo.errorCode = errorCode;
    _callAttrs[FINAL_BEV] = [NSString stringWithFormat:@"%d",errorCode];
}

- (void)clearStat {
    _callAttrs = nil;
    _c2cList = nil;
    _c2pList = nil;
}

- (void)initStat {
    _callAttrs = [[NSMutableDictionary alloc] init];
    _c2cList = [[NSMutableArray alloc] init];
    _c2pList = [[NSMutableArray alloc] init];
}

- (void)recordNormalCallAttrs:(NSString *)number
                     callType:(int)type {
    NSString *caller = (type == 1 ) ? number : [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    NSString *callee = (type == 1 ) ? [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] : number;
    
    long startInviteTime = _callinfo.startTime;
    [self initStat];
    _callAttrs[CALL_ID] = [self formatCallId:caller
                                      callee:callee
                                        time:startInviteTime];
    if (type == 3) {
        _callAttrs[CALLBACKTYPE] = @"auto";
    } else if(type == 2) {
        _callAttrs[CALLBACKTYPE] = @"mannual";
    }
    _callAttrs[CALL_TYPE] = @(type);
    _callAttrs[INVITE_START] = @(startInviteTime);
    _callAttrs[CHANNEL] = IPHONE_CHANNEL_CODE;
    _callAttrs[VER] = CURRENT_TOUCHPAL_VERSION;
    _callAttrs[SYSTEM] = [[UIDevice currentDevice] systemVersion];
    _callAttrs[IMEI] = @"";
    _callAttrs[MAC] = @"";
    _callAttrs[CALL_C2X] = _callinfo.callMode;
    _callAttrs[EDGE] = _currentTurnHost.edge.host;
    _callAttrs[INFO_FLOW] = [NSMutableString stringWithString:@""];
    _callAttrs[STATUS_FLOW] = [NSMutableString stringWithString:@""];
    _callAttrs[POSTKID_FLOW] = [NSMutableString stringWithString:@""];
    _callAttrs[INVALID_INFO_FLOW] = [NSMutableString stringWithString:@""];
    NSString *networkString = [FunctionUtility networkType];
    _callAttrs[NETWORK_NAME] = networkString;
    _callAttrs[NETWORK_TYPE] = [networkString isEqual:@"wifi"] ? @(-1) : @(0);
    _callAttrs[WIFI_BSSID] = [FunctionUtility currentWifiBase];
    _callAttrs[IS_ANSWERED] = @(0);
    if (startInviteTime*1000 -
        [[LocalStorage getItemWithKey:NATIVE_PARAM_CITY_CACHE_TIME] longLongValue] <= 3*86400*1000) {
        id city = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
        if (city == nil) {
            _callAttrs[CITY] = @"";
        } else {
            _callAttrs[CITY] = city;
        }
    }
    _callAttrs[LONGITUDE] = @([[LocalStorage getItemWithKey:QUERY_PARAM_LONGITUDE] doubleValue]);
    _callAttrs[LATITUDE] = @([[LocalStorage getItemWithKey:QUERY_PARAM_LATITUDE] doubleValue]);
    _callAttrs[LAST_STATE] = @"before invite";
    _callAttrs[PLATFORM] = @"iOS";
  
}

- (NSString *)formatCallId:(NSString *)caller
                    callee:(NSString *)callee
                      time:(long)timeStamp {
    NSString *calleeNumber = [PhoneNumber getCNnormalNumber:callee];
    caller = [caller stringByReplacingOccurrencesOfString:@"+" withString:@""];
    callee = [calleeNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    _callAttrs[CALLEE] = callee;
    _callAttrs[CALLER] = caller;
    return [NSString stringWithFormat:@"%@_%@_%ld", caller, callee, timeStamp];
}

- (void)initStreamStat:(pjsua_stream_stat *)stat {
    /*framestat*/
    stat->rtcp.normal_frame_cnt = 0;
    stat->rtcp.missing_frame_cnt = 0;
    stat->rtcp.zero_empty_frame_cnt = 0;
    stat->rtcp.zero_prefetch_cnt = 0;
    stat->rtcp.plc_cnt = 0;
    stat->rtcp.repaired_cnt = 0;
    stat->rtcp.loss_cnt = 0;
    stat->rtcp.total_cnt = 0;
    stat->rtcp.rtp_put_src_pkt_cnt = 0;
    stat->rtcp.rtp_low_recv_rate_cnt = 0;
    stat->rtcp.rtp_put_decoder_cnt = 0;
    stat->rtcp.rtp_group_cnt = 0;
    stat->rtcp.rtp_invalid_group_cnt = 0;
    stat->rtcp.rtp_group_pkt_miss_cnt[0] = 0;
    stat->rtcp.rtp_group_pkt_miss_cnt[1] = 0;
    stat->rtcp.rtp_group_pkt_miss_cnt[2] = 0;
    stat->rtcp.rtp_group_pkt_miss_cnt[3] = 0;
    stat->rtcp.rtp_group_pkt_miss_cnt[4] = 0;
    stat->rtcp.rtp_list_empty_cnt = 0;
    stat->rtcp.rtp_list_burst_cnt = 0;
    stat->rtcp.rtp_list_prefetch_cnt = 0;
    stat->rtcp.rtp_too_late_cnt = 0;
    stat->rtcp.rtp_seq_jump_cnt = 0;
    stat->rtcp.rtp_pkt_seq_err_cnt = 0;
    stat->rtcp.rtp_consecutive_empty_cnt = 0;
    stat->rtcp.rtp_empty_frm_max = 0;
    stat->rtcp.sec_repaired_cnt = 0;
    
    /*JBUF*/
    stat->jbuf.frame_size = 0;
    stat->jbuf.min_prefetch = 0;
    stat->jbuf.max_prefetch = 0;
    
    /* Status */
    stat->jbuf.burst = 0;
    stat->jbuf.prefetch = 0;
    stat->jbuf.size = 0;
    stat->jbuf.max_count = 0;
    
    /* Statistic */
    stat->jbuf.avg_delay = 0;
    stat->jbuf.min_delay = 0;
    stat->jbuf.max_delay = 0;
    stat->jbuf.dev_delay = 0;
    stat->jbuf.avg_burst = 0;
    stat->jbuf.lost = 0;
    stat->jbuf.discard = 0;
    stat->jbuf.empty =0;

}

- (void)recordPackage:(int)callid {
    if (callid < 0 || CALLBACK(_callinfo.callMode)) {
        return;
    }
    pjsua_stream_stat stat;
    [self initStreamStat:&stat];
    if (pjsua_call_get_stream_stat(callid, 0, &stat) == PJ_SUCCESS) {
        pjmedia_rtcp_stream_stat tss = stat.rtcp.tx;
        _callAttrs[TXTOAL] = @([_callAttrs[TXTOAL] integerValue] + tss.pkt);
        _callAttrs[TXDIS] = @([_callAttrs[TXDIS] integerValue] + tss.discard);
        _callAttrs[TXDUP] = @([_callAttrs[TXDUP] integerValue] + tss.dup);
        _callAttrs[TXLOSS] = @([_callAttrs[TXLOSS] integerValue] + tss.loss);
        _callAttrs[TXRECORDER] = @([_callAttrs[TXLOSS] integerValue] + tss.reorder);
        
        pjmedia_rtcp_stream_stat rss = stat.rtcp.rx;
        _callAttrs[RXTOL] = @([_callAttrs[RXTOL] integerValue] + rss.pkt);
        _callAttrs[RXDIS] = @([_callAttrs[RXDIS] integerValue] + rss.discard);
        _callAttrs[RXDUP] = @([_callAttrs[RXDUP] integerValue] + rss.dup);
        _callAttrs[RXLOSS] = @([_callAttrs[RXLOSS] integerValue] + rss.loss);
        _callAttrs[RXRECORDER] = @([_callAttrs[RXRECORDER] integerValue] + rss.reorder);
        
        pjmedia_rtcp_stat rtcp = stat.rtcp;
        //_callAttrs[RTP_RESEND_CNT] = @([_callAttrs[RTP_RESEND_CNT] integerValue] + rtcp.rtp_resend_cnt);
        _callAttrs[FEC_GROUP_DEL_CNT] = @([_callAttrs[FEC_GROUP_DEL_CNT] integerValue] + rtcp.rtp_grp_del_cnt);
        //_callAttrs[FEC_PUT_FAKE_CNT] = @([_callAttrs[FEC_PUT_FAKE_CNT] integerValue] + rtcp.rtp_put_fake_pkt_cnt);
        _callAttrs[FEC_RX_TOL] = @([_callAttrs[FEC_RX_TOL] integerValue] + rtcp.total_cnt);
        _callAttrs[FEC_REPAIR_PKT] = @([_callAttrs[FEC_REPAIR_PKT] integerValue] + rtcp.repaired_cnt);
        _callAttrs[FEC_LOSS_PKT] = @([_callAttrs[FEC_LOSS_PKT] integerValue] + rtcp.loss_cnt);
        _callAttrs[FEC_GROUP_CNT] = @([_callAttrs[FEC_GROUP_CNT] integerValue] + rtcp.rtp_group_cnt);

        _callAttrs[FEC_INVALID_GROUP_CNT] = @([_callAttrs[FEC_INVALID_GROUP_CNT] integerValue] + rtcp.rtp_invalid_group_cnt);
        _callAttrs[FEC_LIST_BURST_CNT] = @([_callAttrs[FEC_LIST_BURST_CNT] integerValue] + rtcp.rtp_list_burst_cnt);
        _callAttrs[FEC_LIST_EMPTY_CNT] = @([_callAttrs[FEC_LIST_EMPTY_CNT] integerValue] + rtcp.rtp_list_empty_cnt);
        _callAttrs[FEC_LIST_PREFECT_CH_CNT] = @([_callAttrs[FEC_LIST_PREFECT_CH_CNT] integerValue] + rtcp.rtp_list_prefetch_cnt);

        _callAttrs[FEC_PUT_DECODER_CNT] = @([_callAttrs[FEC_PUT_DECODER_CNT] integerValue] + rtcp.rtp_put_decoder_cnt);
        _callAttrs[FEC_SEQ_JUMP_CNT] = @([_callAttrs[FEC_SEQ_JUMP_CNT] integerValue] + rtcp.rtp_seq_jump_cnt);
        _callAttrs[FEC_TOOL_LATE_CNT] = @([_callAttrs[FEC_TOOL_LATE_CNT] integerValue] + rtcp.rtp_too_late_cnt);
        _callAttrs[FEC_PKT_SEQ_ERR_CNT] = @([_callAttrs[FEC_PKT_SEQ_ERR_CNT] integerValue] + rtcp.rtp_pkt_seq_err_cnt);
        _callAttrs[FEC_PUT_SRC_CNT] = @([_callAttrs[FEC_PUT_SRC_CNT] integerValue] + rtcp.rtp_put_src_pkt_cnt);
        _callAttrs[FEC_LOW_RECV_RATE_CNT] = @([_callAttrs[FEC_LOW_RECV_RATE_CNT] integerValue] + rtcp.rtp_low_recv_rate_cnt);
        _callAttrs[FEC_SEC_REPAIRE_CNT] = @([_callAttrs[FEC_SEC_REPAIRE_CNT] integerValue] + rtcp.sec_repaired_cnt);
      
        
        unsigned int miss_1 = [_callAttrs[FEC_GRP_PKT_MISS_1] integerValue] + rtcp.rtp_group_pkt_miss_cnt[0];
        unsigned int miss_2 = [_callAttrs[FEC_GRP_PKT_MISS_2] integerValue] + rtcp.rtp_group_pkt_miss_cnt[1];
        unsigned int miss_3 = [_callAttrs[FEC_GRP_PKT_MISS_3] integerValue] + rtcp.rtp_group_pkt_miss_cnt[2];
        unsigned int miss_4 = [_callAttrs[FEC_GRP_PKT_MISS_4] integerValue] + rtcp.rtp_group_pkt_miss_cnt[3];
        
        _callAttrs[FEC_GRP_PKT_MISS_1] = @(miss_1);
        _callAttrs[FEC_GRP_PKT_MISS_2] = @(miss_2);
        _callAttrs[FEC_GRP_PKT_MISS_3] = @(miss_3);
        _callAttrs[FEC_GRP_PKT_MISS_4] = @(miss_4);
       
        _callAttrs[BUF_NORMAL_FRAME] = @([_callAttrs[BUF_NORMAL_FRAME] integerValue] + rtcp.normal_frame_cnt);
        _callAttrs[BUF_MISS_FRAME] = @([_callAttrs[BUF_MISS_FRAME] integerValue] + rtcp.missing_frame_cnt);
        _callAttrs[BUF_ZERO_FRAME] = @([_callAttrs[BUF_ZERO_FRAME] integerValue] + rtcp.zero_empty_frame_cnt);
        _callAttrs[BUF_PREFECT_ZERO_FRAME] = @([_callAttrs[BUF_PREFECT_ZERO_FRAME] integerValue] + rtcp.zero_prefetch_cnt);
        _callAttrs[BUF_MAX_EMPTY_FRAME] = @([_callAttrs[BUF_MAX_EMPTY_FRAME] integerValue] + rtcp.rtp_empty_frm_max);
        _callAttrs[BUF_EMPTY_OCCUR_CNT] = @([_callAttrs[BUF_EMPTY_OCCUR_CNT] integerValue] + rtcp.rtp_consecutive_empty_cnt);
        
        pjmedia_jb_state  jbuf = stat.jbuf;
        _callAttrs[BUF_SIZE] = @([_callAttrs[BUF_SIZE] integerValue] + jbuf.size);
        _callAttrs[BUF_BURST] = @([_callAttrs[BUF_BURST] integerValue] + jbuf.burst);
        _callAttrs[BUF_AVG_BURST] = @([_callAttrs[BUF_AVG_BURST] integerValue] + jbuf.avg_burst);
        _callAttrs[BUF_DISCARD] = @([_callAttrs[BUF_DISCARD] integerValue] + jbuf.discard);
        _callAttrs[BUF_EMPTY] = @([_callAttrs[BUF_EMPTY] integerValue] + jbuf.empty);
        _callAttrs[BUF_LOST] = @([_callAttrs[BUF_LOST] integerValue] + jbuf.lost);
    }
}

void onTimer(void *user_data) {
    cootek_log(@"onTimer schedule");
    NSInvocation *methord = CFBridgingRelease(user_data);
    user_data = NULL;
    [methord invoke];
    
}

- (void)scheduleTimer:(int)delay
           invocation:(NSInvocation *)invocation {
    cootek_log(@"scheduleTimer index = %d,methord=%@,retrycount=%d",delay,invocation,_retryCount);
    pjsua_state state = pjsua_get_state();
    if (state > PJSUA_STATE_CREATED && state != PJSUA_STATE_CLOSING && _status > CoreStatusShutDown) {
        pjsua_schedule_timer2(&onTimer,(void *)CFBridgingRetain(invocation),delay);
    }
}

@end
