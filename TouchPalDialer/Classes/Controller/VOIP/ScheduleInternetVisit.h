//
//  VOIPScheduleCall.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-6.
//
//

#import <Foundation/Foundation.h>

@interface ScheduleInternetVisit : NSObject
+ (void)onAppDidBecomeActive;
+ (void)writeVoipLog:(NSString *)log;
+ (void)checkVoipConfigFiles:(BOOL)forceCheck;
+ (NSString *)getStoredVoipLog;
+ (void)cleanVoipLog;
+ (void)onAppDataLoaded;
+ (void)rainbowActivate;
+ (void)recordVoipAttr:(NSDictionary *)attr;
@end
