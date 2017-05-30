//
//  AntiharassModelManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/10.
//
//

#import <Foundation/Foundation.h>
#import "AntiharassUtil.h"

@interface AntiharassManager : NSObject
+ (AntiharassManager *)instance;
- (void)openAntiharass;
- (void)closeAntiharass;
- (void)updateAntiharass;
- (void)checkUpdateInBackground;
- (void)updateAntiharassInWifiInBackground;
- (NSInteger)judgeNetwork;
@end
