//
//  CallerDBA.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallerIDInfoModel.h"

@interface CallerDBA : NSObject

+ (void)deleteAllCache;

+ (NSMutableDictionary *)getAllCacheCallerIDs;

+ (NSMutableDictionary *)getAllCacheMarks;

+ (void)addCallers:(NSArray *)callers;

+ (void)addCallers:(NSArray *)callers notify:(BOOL)isNotify;

+ (void)updateCacheAfterCityDown;

+ (CallerIDInfoModel *)queryCacheCallerIdByNumber:(NSString *)number;

+ (void)deleteMarkedCallerForNumber:(NSString *)number;

@end
