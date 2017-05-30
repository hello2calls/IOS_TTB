//
//  CallLogDBA.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-13.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallCountModel.h"

@interface CallLogDBA : NSObject

+ (NSMutableDictionary *) allContinuousMissedCallCount;

+ (NSArray *)calllogsByCondition:(NSArray *)where
                    GroupByCause:(NSArray *)groupBy
                    OrderByCause:(NSArray *)orderby;

+ (NSArray *) querycallogsStart:(NSInteger)startTime
                        endTime:(NSInteger)endTime;

+ (NSArray *) queryRecentlyCallLogsWithCount:(int)count;

+ (void)updateCallLog:(NSArray *)changeCalllg;

+ (BOOL)deleteCalllogByRowId:(NSInteger)row_id;

+ (BOOL)insertCallLogs:(NSArray *)callLogs;

+ (BOOL)deleteCalllogByConditional:(NSArray *)whereby;

+ (BOOL)deleteCalllogByConditionalWithoutNotification:(NSArray *)whereby;

+ (CallCountModel *)callCountReturnByPersonID:(NSInteger)personID;

+ (NSArray *)searchCalllog:(NSString *)number;

+ (NSArray *)queryAllMarkCallogs;

+ (NSArray *)querAllUnknowCallogs;

+ (NSArray *)queryAllRecognitionCallogs;

+ (NSInteger)unknowCalllogCount;

+ (NSArray *)queryTopFrequentContacts:(int)count;

@end
