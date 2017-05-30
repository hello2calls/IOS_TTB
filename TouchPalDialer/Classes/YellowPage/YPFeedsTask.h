//
//  YPFeedsTask.h
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import <Foundation/Foundation.h>
#import "FindNewsBonusResult.h"


#define FEEDS_TYPE_LIST @"FEEDS_TYPE_LIST"
#define FEEDS_TYPE_DETAIL @"FEEDS_TYPE_DETAIL"
#define FEEDS_DATE_FORMAT @"yyyy-MM-dd"

@protocol YPFeedsExecutor<NSObject>

@required
- (void)executeTask;

@end

@interface YPFeedsTask : NSBlockOperation<YPFeedsExecutor>

@property(nonatomic, assign, setter=setBonusType:, getter=getBonusType)YPRedPacketType type;
@property(nonatomic, assign, setter=setRequestType:, getter=getRequestType)YPRedPacketRequestType requestType;
@property(nonatomic, strong, setter=setBonusResult:, getter=getBonusResult)FindNewsBonusResult* result;
@property(nonatomic, strong, setter=setQueryResult:, getter=getQueryResult)FindNewsBonusResult* queryResult;


@end
