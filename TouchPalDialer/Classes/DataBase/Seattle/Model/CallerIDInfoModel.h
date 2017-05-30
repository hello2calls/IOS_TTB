//
//  CallerIDInfoModel.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeattleDataModel.h"

#define CLASSIFY_TYPE_FRAUD @"fraud"
#define CLASSIFY_TYPE_CRANK @"crank"
#define CLASSIFY_TYPE_MAYBE_FRAUD @"maybe fraud"
#define CLASSIFY_TYPE_MAYBE_CRANK @"maybe crank"

typedef enum {
    CallerIDQueryFailedLevel = 0,
    CallerIDQueryNotFindLevel = 1,
    CallerIDQueryNetWorkLevel = 2,
    CallerIDQueryLocalLevel = 3,
    CallerIDQueryMarkLevel = 4,
    CallerIDQueryGuessAreaCodeLevel = 5,
    
}CallerIDCacheLevel;

@interface CallerIDInfoModel : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *number;
@property(nonatomic,copy)NSString *callerType;
@property(nonatomic,copy)NSString *versionTime;
@property(nonatomic,copy)NSString *guessedAreaCode;
@property(nonatomic,assign)unsigned int vipID;
@property(nonatomic,assign)BOOL isVerified;
@property(nonatomic,assign)CallerIDCacheLevel callerIDCacheLevel;
@property(nonatomic,assign)NSInteger markCount;
@property(nonatomic,retain)SurveyInfo *surveyInfo;

+ (id)modelWithNumber:(NSString *)number
                 name:(NSString *)name
                 type:(NSString *)type;

- (id)initWithCloudData:(CloudCallerIdInfo *)info;

- (BOOL) isCallerIdUseful;

- (BOOL) hasTag;

- (NSString*)localizedTag;

- (NSString*)validCallerType;

- (NSString *)getUsefulString;

+ (NSString *)knownCallerTypeOrEmpty:(NSString *)callerType;

@end
