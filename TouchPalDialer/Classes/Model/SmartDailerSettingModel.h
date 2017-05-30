//
//  SmartDailerSettingModel.h
//  TouchPalDialer
//
//  Created by Ailce on 12-2-20.
//  Refactored by Leon on 13-3-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartDailerSettingModel : NSObject

+ (BOOL)isChinaSim;
+ (SmartDailerSettingModel *)settings;

@property(nonatomic,getter = isRoaming) BOOL roaming;
@property(nonatomic,retain) NSString *residentAreaCode;
@property(nonatomic,getter = isSmartDialAdviceEnabled) BOOL smartDialAdviceEnabled;
@property(nonatomic,getter = isAutoDialEnabled) BOOL autoDialEnabled;

// Sim configurations
@property(nonatomic,retain) NSString *simMnc;
@property(nonatomic,retain) NSString *networkMnc;
@property(nonatomic,retain) NSString *currentChinaCarrier;
- (void)setSimMncWithNonHeadingPlusCountryCode:(NSString *)countryCode;

- (BOOL)isInternationalRoaming;
- (NSInteger)smartDialProfileIDBySim;
- (NSArray *)smartDialProfileRulesBySim;
- (NSString *)countryNameWithTwoCharsBySim;

// Helpers
- (void)reportEnabledVoipRulesToAnalyticManager;
@end
