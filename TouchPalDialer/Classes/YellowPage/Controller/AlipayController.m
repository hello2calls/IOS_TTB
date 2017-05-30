//
//  AlipayController.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-1.
//
//

#import <Foundation/Foundation.h>
#import "AlipayController.h"
#import "Order.h"
#import "AliPayTask.h"


AlipayController *ali_instance_ = nil;

@interface AlipayController()
@property (nonatomic,copy) void(^payCallback)(NSDictionary*);
@end

@implementation AlipayController

+ (void)initialize
{
    ali_instance_ = [[AlipayController alloc] init];
}

+ (AlipayController *)instance
{
    if (!ali_instance_) {
        ali_instance_ = [[AlipayController alloc] init];
    }
    return ali_instance_;
}

- (BOOL)handleResultDic:(NSDictionary *)result
{
    if(self.payCallback){
        self.payCallback(result);
        return YES;
    }
    return NO;
}

- (void) sendPay:(NSDictionary*) returnData callbackBlock:(void(^)(NSDictionary* resultDic))payBackAction
{
    AliPayTask* task = [[AliPayTask alloc] init];
    self.payCallback = payBackAction;
    task.callback = payBackAction;
    
    [task generateOrder:returnData];
}


@end