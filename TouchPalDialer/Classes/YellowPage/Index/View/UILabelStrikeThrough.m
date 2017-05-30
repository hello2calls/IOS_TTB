//
//  UILabelStrikeThrough.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-18.
//
//

#import "UILabelStrikeThrough.h"

@interface UILabelStrikeThrough()
{
    BOOL isWithStrikeThrough;
}
@property (nonatomic, assign) BOOL isWithStrikeThrough;

@end

@implementation UILabelStrikeThrough
@synthesize isWithStrikeThrough;
- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(c, black);
    CGContextSetLineWidth(c, 0.2);
    CGContextBeginPath(c);
    CGFloat halfWayUp = (self.bounds.size.height - self.bounds.origin.y) / 2.0;
    CGContextMoveToPoint(c, self.bounds.origin.x, halfWayUp );
    CGContextAddLineToPoint(c, self.bounds.origin.x + self.bounds.size.width, halfWayUp);
    CGContextStrokePath(c);
    
    [super drawRect:rect];
}

@end
