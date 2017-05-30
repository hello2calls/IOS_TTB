//
//  CallLog.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-13.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallLogDataModel.h"

@interface CallLog : NSObject {

}

+ (NSArray *)calllogsByCondition:(NSArray *)where
                    OrderByCause:(NSArray *)orderby;

+ (NSArray *)calllogsByCondition:(NSArray *)where
                    GroupByCause:(NSArray *)groupby
                    OrderByCause:(NSArray *)orderby;

+ (NSArray *)queryAllCalllogs;

+ (NSMutableDictionary *)getPersonCallLogList;

+ (NSMutableDictionary *)allMissedContinue;

+ (BOOL)addCallLog:(CallLogDataModel *)call_log;

+ (BOOL)addCallLogs:(NSArray *)callLogs;

+ (void)addPendingCallLog:(CallLogDataModel *)call_log;

+ (void)clearPendingCallLog;

+ (void)commitPendingCallLog;

+ (void)commitPendingLogWithCallDur:(int)duration isVoipCall:(BOOL)isVoip;

+ (void)syncCalllog;

+ (BOOL)deleteCalllogByRowId:(NSInteger)row_id;

+ (BOOL)deleteCalllogByConditional:(NSArray *)whereby;

+ (BOOL)deleteCalllogByConditionalWithoutNotification:(NSArray *)whereby;

@end
