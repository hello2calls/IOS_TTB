//
//  NSString + Draw.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import <Foundation/Foundation.h>


@interface NSString (Draw)

- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs withFont:font lineBreakMode:(NSLineBreakMode)mode alignment:(NSTextAlignment)alignment UIColor:(UIColor*)color;
- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs withFont:font UIColor:(UIColor*)color;

@end
