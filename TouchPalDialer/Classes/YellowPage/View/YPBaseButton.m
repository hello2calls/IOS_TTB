//
//  YPBaseButton.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-13.
//
//

#import <Foundation/Foundation.h>
#import "YPBaseButton.h"

@interface YPBaseButton()
{
    BOOL pressed;
}
@end
@implementation YPBaseButton

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (pressed) {
        CGContextSetFillColorWithColor(context, self.highlightBgColor ? self.highlightBgColor.CGColor : [UIColor grayColor].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, self.bgColor ? self.bgColor.CGColor : [UIColor whiteColor].CGColor);
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    pressed = YES;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    pressed = NO;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if(!CGRectContainsPoint(self.frame,point)) {
        pressed = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    pressed = NO;
    [self setNeedsDisplay];
    
}


@end