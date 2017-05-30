//
//  GlobalVariables.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>


#define SET_VALUE_IN_GLOBALTABLE(key,value) \
[[GlobalMap getInstance].table setValue:value forKey:key];

#define VALUE_IN_GLOBALTABLE(key) \
[[GlobalMap getInstance].table valueForKey:key];
#define TPDWeakSelf __weak typeof(self) _self = self;

@interface GlobalVariables : NSObject
// 全局字典
@property (nonatomic,strong) NSMutableDictionary* table;

// 打电话信号
@property (nonatomic,strong) RACSubject* onSwitchingToC2PSignal;
@property (nonatomic,strong) RACSubject* onRingingSignal;
@property (nonatomic,strong) RACSubject* onConnectedSignal;
@property (nonatomic,strong) RACSubject* onCallStateInfoSignal;

@property (nonatomic,strong) RACSubject* onCallErrorWithCodeSignal;
@property (nonatomic,strong) RACSubject* onCallModeSetSignal;
@property (nonatomic,strong) RACSubject* startBackCallSignal;
@property (nonatomic,strong) RACSubject* onIncomingSignal;
// 系统电话信号
@property (nonatomic,strong) RACSubject* onSysIncomingCallSignal;
@property (nonatomic,strong) RACSubject* onSysHangupCallSignal;
@property (nonatomic,strong) RACSubject* onSystemCallConnected;

// 应用信号
@property (nonatomic, strong) RACReplaySubject* testSignal;
@property (nonatomic,strong) RACSubject* applicationDidBecomeActiveSignal;
@property (nonatomic,strong) RACSubject* enterCallPageSignal;


@property (nonatomic,strong) NSDate* lastExitTimeFromDiscoverTab;
+(GlobalVariables *)getInstance;
+(void)fetchGlobalVariables;

@end
