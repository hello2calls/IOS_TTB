//
//  GlobalVariables.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import "GlobalVariables.h"

@implementation GlobalVariables
static GlobalVariables *instance = nil;
+(GlobalVariables *)getInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[GlobalVariables alloc] init];
            
            instance.onSwitchingToC2PSignal = [RACSubject subject];
            instance.onRingingSignal = [RACSubject subject];
            instance.onConnectedSignal = [RACSubject subject];
            instance.onCallStateInfoSignal = [RACSubject subject];

            instance.onCallErrorWithCodeSignal = [RACSubject subject];
            instance.onCallModeSetSignal = [RACSubject subject];
            instance.startBackCallSignal = [RACSubject subject];
            instance.onIncomingSignal = [RACSubject subject];
            
            instance.onSysIncomingCallSignal = [RACSubject subject];
            instance.onSysHangupCallSignal = [RACSubject subject];
            instance.onSystemCallConnected = [RACSubject subject];
            
            
            instance.table = [NSMutableDictionary dictionary];
            instance.applicationDidBecomeActiveSignal = [RACSubject subject];
            instance.enterCallPageSignal = [RACSubject subject];
            
            instance.lastExitTimeFromDiscoverTab = [NSDate dateWithTimeIntervalSince1970:0];
        }
    });
    
    
    return instance;
}

+(void)fetchGlobalVariables{

}
@end
