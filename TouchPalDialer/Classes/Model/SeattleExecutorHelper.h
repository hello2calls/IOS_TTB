//
//  SeattleExecutorHelper.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-31.
//
//

#import <Foundation/Foundation.h>
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"

@interface SeattleExecutorHelper : NSObject

+ (NSArray *)queryCallerIdInfo:(NSArray *)numbers;
+ (BOOL)activateTouchPalForInstallation;
@end
