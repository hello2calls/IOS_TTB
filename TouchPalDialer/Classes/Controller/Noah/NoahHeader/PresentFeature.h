//
//  PresentFeature.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/26.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationSystem.h"
typedef enum : NSInteger{
    PLNormal = 0,
    PLHigh,
    PLRealTime,
}PriorityLevel;

typedef enum : NSInteger{
    STBool = 0,
    STNSInterger,
    STNSString,
}SettingType;

@interface PresentFeature : NSObject

@property (nonatomic, strong) NSString *featureId;
@property (nonatomic, assign) int initialPromptDays;
@property (nonatomic, assign) float promptInterval;
@property (nonatomic, assign) int promptTimes;
@property (nonatomic, assign) PriorityLevel priority;
@property (nonatomic, strong) NSString *dependencySettingKey;
@property (nonatomic, assign) SettingType dependencySettingType;
@property (nonatomic, strong) NSString *dependencySettingValue;
@property (nonatomic, assign) long startDate;
@property (nonatomic, assign) long expiredDate;
@property (nonatomic, assign) int startHour;
@property (nonatomic, assign) int endHour;
@property (nonatomic, strong) NSString *startSelfVersion;
@property (nonatomic, strong) NSString *endSelfVersion;

- (void)generateWithDictonary:(NSDictionary *) dict;
- (BOOL)match:(NSString *)re;
- (BOOL)matchSpecial:(NSString *)re;

@end
