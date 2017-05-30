//
//  YPUIScrollView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-9.
//
//

#import <Foundation/Foundation.h>
#import "YPUIScrollView.h"
#import "IndexConstant.h"
#import "UIDataManager.h"

@interface YPUIScrollView() {
    CGPoint startPoint;
}
@end

@implementation YPUIScrollView

@synthesize pressed;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:self];
    pressed = YES;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pressed) {
        pressed = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pressed) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGRect rect = CGRectMake(startPoint.x - CLICK_CANCELED_OFFSET, startPoint.y - CLICK_CANCELED_OFFSET,  2 * CLICK_CANCELED_OFFSET, CLICK_CANCELED_OFFSET);
        if (!CGRectContainsPoint(rect,point)) {
            pressed = NO;
            [self setNeedsDisplay];
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (pressed) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            pressed = NO;
            [self setNeedsDisplay];
            if ([[UIDataManager instance] checkDoubleClick]) {
                return;
            }
            [self doClick];
        });
    }
    
}

- (void) doClick {
    
}


@end