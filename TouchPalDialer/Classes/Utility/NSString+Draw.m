//
//  UIColor+String.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

@implementation NSString (Draw)

- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs withFont:font lineBreakMode:(NSLineBreakMode)mode alignment:(NSTextAlignment)alignment UIColor:(UIColor*)color
{
    if ([self respondsToSelector: @selector(drawWithRect:options:attributes:context:)]) {
        [self drawInRect:rect withAttributes:attrs];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        [self drawInRect:rect  withFont:font lineBreakMode:mode alignment:alignment];
    }
}

- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs withFont:font UIColor:(UIColor*)color
{
    if ([self respondsToSelector: @selector(drawWithRect:options:attributes:context:)]) {
        [self drawInRect:rect withAttributes:attrs];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        [self drawInRect:rect  withFont:font];
    }
}
@end
