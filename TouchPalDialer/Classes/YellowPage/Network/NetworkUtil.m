//
//  NetworkUtil.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-21.
//
//

#import <Foundation/Foundation.h>
#import "NetworkUtil.h"
#import "NetworkUtility.h"
#import "Reachability.h"
#import "UIDataManager.h"

@implementation NetworkUtil

+ (void) executeWithUrlRequest:(NSURLRequest*)request success:(void(^)(NSData*))resultSuccess failure:(void(^)(NSData*))resultFailure
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] init];
    NSError* error = [[NSError alloc] init];
    NSData* result = [NetworkUtility sendSafeSynchronousRequest:request returningResponse:&response error:&error];
    int status=[response statusCode];
    if (status == 200) {
        if (resultSuccess) {
            resultSuccess(result);
        }
    } else {
        if (resultFailure) {
            resultFailure(result);
        }
    }
    }];
    [[UIDataManager instance].queue addOperation:operation];
}

// 是否wifi
+ (BOOL) IsEnableWIFI {
    return ([Reachability network] >= network_wifi);
}

// 是否3G
+ (BOOL) IsEnable3G {
    return ([Reachability network] >= network_3g);
}

// 是否2G
+ (BOOL) IsEnable2G {
    return ([Reachability network] == network_2g);
}

@end
