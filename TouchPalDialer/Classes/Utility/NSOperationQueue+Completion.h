//
//  NSOperationQueue+Completion.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import <Foundation/Foundation.h>

typedef void (^NSOperationQueueCompletion) (void);

@interface NSOperationQueue(Completion)

- (void)setCompletion:(NSOperationQueueCompletion)completion;

- (void)addOperation:(NSBlockOperation *)op timeout:(CGFloat)timeout;
@end
