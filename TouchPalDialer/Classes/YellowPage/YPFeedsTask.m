//
//  YPFeedsTask.m
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import "YPFeedsTask.h"
#import "NetworkUtil.h"
#import "CTUrl.h"
#import "TouchPalVersionInfo.h"
#import "IndexConstant.h"
#import "SeattleFeatureExecutor.h"
#import "UpdateService.h"
#import "FindNewsBonusResult.h"

#define BONUS_DATA @"TRAFFIC"
#define BONUS_PERMANENT_VOIP @"FOREVER_MINUTES"
#define BONUS_TEMPORARY_VOIP @"TMP_MINUTES"

@interface YPFeedsTask()
{
    BOOL finishTask;
}

@end


@implementation YPFeedsTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak YPFeedsTask* wBase = self;
        [self addExecutionBlock:^{
            [wBase executeTask];
        }];
    }
    return self;
}

- (void)executeTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString* url;
            
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            NSString* eventName = @"";
            if (self.requestType == YP_RED_PACKET_REQUEST_QUERY) {
                if (USE_DEBUG_SERVER) {
                    url = [NSString stringWithFormat:@"%@%@",YP_DEBUG_SERVER, YP_DEBUG_FEEDs_RED_PACKET_QUERY_URL_PATH];
                } else {
                    url = YP_FEEDs_RED_PACKET_QUERY_URL;
                }
                
                switch (self.type) {
                    case YP_RED_PACKET_FEEDS_LIST:
                        eventName = @"list_redpacket";
                        [params setObject:eventName forKey:@"event_name"];
                        break;
                    case YP_RED_PACKET_FEEDS_DETAIL:
                        eventName = @"detail_redpacket";
                        [params setObject:eventName forKey:@"event_name"];
                    default:
                        [params setObject:eventName forKey:@"event_name"];
                        break;
                }
                
            } else {
                if (USE_DEBUG_SERVER) {
                    url = [NSString stringWithFormat:@"%@%@",YP_DEBUG_SERVER, YP_DEBUG_FEEDs_RED_PACKET_ACQUIRE_URL_PATH];
                } else {
                    url = YP_FEEDs_RED_PACKET_ACQUIRE_URL;
                }
                [params setObject:[self.queryResult getS] forKey:@"s"];
                [params setObject:[self.queryResult getBonusId] forKey:@"reward_id"];
                [params setObject:[self.queryResult getTimestamp] forKey:@"ts"];
                [params setObject: [self.queryResult getBonusAmount] forKey:@"amount"];
                [params setObject:[self.queryResult getEventName] forKey:@"event_name"];
                [params setObject:[self.queryResult getRewardType] forKey:@"reward_type"];
            }
            
            //TODO
            [params setObject:[SeattleFeatureExecutor getToken] forKey:@"_token"];
//            [params setObject:@"0ac73112-57de-49ff-81fd-d5c4a7fb6c5b" forKey:@"_token"];
       
            url = [url stringByAppendingString:@"?"];
            url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
            
            NSString *parseUrl = [CTUrl encodeRequestUrl:url];
            NSURL *urlRequest=[NSURL URLWithString:parseUrl];
            __block NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc]initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
            
            [NetworkUtil executeWithUrlRequest:httpRequest success:^(NSData *data) {
                NSError* error;
                NSMutableDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
                
                FindNewsBonusResult* result = nil;
                if (self.requestType == YP_RED_PACKET_REQUEST_QUERY) {
                    result = [FindNewsBonusResult new];
                    NSDictionary *resultData = [retDic objectForKey:@"result"];
                    NSNumber* errorCode = [resultData objectForKey:@"error_code"];
                    [result setResultCode:errorCode];
                    [result setS:[resultData objectForKey:@"s"]];
                    [result setTimestamp:[resultData objectForKey:@"ts"]];
                    [result setBonusId:[resultData objectForKey:@"reward_id"]];
                    [result setEventName:eventName];
                    if (errorCode.integerValue == 2000) {
                        NSArray* dic = [resultData objectForKey:@"reward_info"];
                        if (dic && dic.count > 0) {
                            NSString* type = [[dic objectAtIndex:0] objectForKey:@"reward_type"];
                            [result setRewardType:type];
                            if ([BONUS_DATA isEqualToString: type]) {
                                [result setBonusType:YP_FEEDS_BONUS_TRAFFIC];
                            } else if([BONUS_PERMANENT_VOIP isEqualToString: type]) {
                                [result setBonusType:YP_FEEDS_BONUS_FREE_MINUTES];
                            } else {
                                [result setBonusType:YP_FEEDS_BONUS_MINUTES];
                            }
                            [result setBonusResult:[dic objectAtIndex:0]];
                            NSString* amount = [[dic objectAtIndex:0] objectForKey:@"amount"];
                            if ([amount isKindOfClass:[NSNumber class]]) {
                                amount = [NSString stringWithFormat: @"%d", amount.intValue];
                            }
                            [result setBonusAmount: amount];
                        }
                    }
                } else if (self.requestType == YP_RED_PACKET_REQUEST_ACQUIRE) {
                    result = [FindNewsBonusResult new];
                    NSDictionary *resultData = [retDic objectForKey:@"result"];
                    NSNumber* errorCode = [resultData objectForKey:@"error_code"];
                    [result setResultCode:errorCode];
                    if (errorCode.integerValue == 2000) {
                        [result setBonusType:[self.queryResult getBonusType]];
                        [result setBonusAmount:[self.queryResult getBonusAmount]];
                        [result setRewardType:[self.queryResult getRewardType]];
                    }
                }
                [self setBonusResult:result];
                finishTask = YES;
                
            } failure:^(NSData *errorResult) {
                NSString *responseString=[[NSString alloc] initWithData:errorResult encoding:NSUTF8StringEncoding];
                cootek_log(responseString);
                [self setBonusResult:nil];
                finishTask = YES;
            }];
        }
        @catch(NSException *exception) {
            [self setBonusResult:nil];
            finishTask = YES;
            NSString* tasktype = [NSString stringWithFormat:@"%d",self.type];
            cootek_log(@" -----> task exception: %@", exception.reason);
        }
        
    });
    
    while (!finishTask && !self.isCancelled) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
}
@end
