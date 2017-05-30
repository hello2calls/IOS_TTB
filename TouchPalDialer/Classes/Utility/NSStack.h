//
//  NSStack.h
//  TouchPalDialer
//
//  Created by tanglin on 15/9/1.
//
//

#import <Foundation/Foundation.h>

@interface NSStack : NSObject
- (void)push:(id)anObject;
- (id)pop;
- (id)top;
- (void)clear;
@property (nonatomic, readonly) int count;
@end
