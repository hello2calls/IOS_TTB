//
//  YPTaskBase.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPTaskBase.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"

@implementation YPTaskBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.result = [NSMutableArray new];
        self.finishTask = NO;
        __weak YPTaskBase* wBase = self;
        [self addExecutionBlock:^{
            [wBase generateTask];
        }];
    }
    return self;
}

- (void) generateTask
{
    
    __weak YPTaskBase* task = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            if (task) {
                cootek_log(@" franktang --- > excute task : %d", self.type);
                [task executeTask];
            }
        }
        @catch(NSException *exception) {
            NSString* tasktype = [NSString stringWithFormat:@"%d",self.type];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"request"), Pair(@"task_type",tasktype), Pair(@"errmsg",exception.reason), nil];
            
            cootek_log(@" -----> task exception: %@", exception.reason);
        }
        
    });
    
    while (!self.finishTask && !self.isCancelled) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    cootek_log(@"task is finished %d", self.type);
}

- (void) setResults:(NSArray *) resultData
{
    if (![self isCancelled]) {
        self.result = resultData;
        self.finishTask = YES;
        
        cootek_log(@" ---- result back ----");
    }
}

- (void) executeTask
{
    
}

- (BOOL) isTaskSucceeded
{
    if (self && [self finishTask] && self.result && self.result.count > 0) {
        return YES;
    }

    return NO;
}



@end
