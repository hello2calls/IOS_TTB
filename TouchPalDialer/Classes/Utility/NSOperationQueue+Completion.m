//
//  NSOperationQueue+Completion.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "NSOperationQueue+Completion.h"

@implementation NSOperationQueue(Completion)

- (void)setCompletion:(NSOperationQueueCompletion)completion
{
    NSOperationQueueCompletion copiedCompletion = [completion copy];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cootek_log(@" wait tasks");
        [self waitUntilAllOperationsAreFinished];

        cootek_log(@" task finished , call finish method");
        copiedCompletion();

    });
}

- (void) addOperation:(NSBlockOperation *)operation timeout:(CGFloat)timeout
{
    NSBlockOperation __weak *weakOperation = operation;             // prevent strong reference cycle

    [self addOperation:operation];

    // if unfinished after `timeout`, cancel it

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // if still in existence, and unfinished, then cancel it

        if (weakOperation && ![weakOperation isFinished]) {
            cootek_log(@" ---- timeout -----");
            [weakOperation cancel];
        }
    });
}
@end
