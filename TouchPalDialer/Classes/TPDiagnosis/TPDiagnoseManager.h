//
//  TPDiagnoseManager.h
//  TouchPalDialer
//
//  Created by siyi on 16/7/20.
//
//

#ifndef TPDiagnoseManager_h
#define TPDiagnoseManager_h

#import <Foundation/Foundation.h>
#import "TPDiagnose.h"
#import "AdDebugStatsManager.h"

@interface TPDiagnoseManager : NSObject

- (BOOL) isDiagnoseCode:(NSString *)codeString;
- (void) showDiagnoseInfoByCode:(NSString *)codeString;

- (NSString *) diagnoseClassNameByCode:(NSString *)codeString;

+ (NSString *) getCallTypeDescription:(NSString *)callMode;
+ (NSString *) getVoipPriviledgeDescription:(BOOL)isVoip;
+ (NSString *) getForcedOfflineDescription:(BOOL)isForcedOffline;
+ (NSString *) getAdPageTypeDescription:(NSString *)adPageType;
+ (NSString *) getDefaultAdReasonDescription:(AdDefaultReason)reason;

@end

#endif /* TPDiagnoseManager_h */
