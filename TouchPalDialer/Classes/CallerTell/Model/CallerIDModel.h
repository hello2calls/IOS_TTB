//
//  CallerIDModel.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-9-24.
//
//

#import <Foundation/Foundation.h>
#import "CallerIDInfoModel.h"

#define N_DID_QUERY_CALLERIDS_CALLBACK @"N_DID_QUERY_CALLERIDS_CALLBACK"


@interface CallerIDModel : NSObject
+(CallerIDInfoModel *)queryCallerIDByNumber:(NSString *)number;
+(void)willQueryCallerIDsFromService:(NSArray *)numbers;
+(CallerIDInfoModel *)queryCallerIDByNumberWithOutNotification:(NSString *)number;
+(void)queryCallerIDWithNumber:(NSString *)number callBackBlock:(void (^)(CallerIDInfoModel *))callBackBlock;
+(void)queryCallerIDs:(NSArray *)numbers;
@end
