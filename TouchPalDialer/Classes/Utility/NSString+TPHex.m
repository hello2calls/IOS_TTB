//
//  NSString+TPHex.m
//  TouchPalDialer
//
//  Created by Chen Lu on 12/17/12.
//
//

#import "NSString+TPHex.h"

@implementation NSString (TPHex)

- (NSString *)hexRepresentation
{
    NSMutableString *s = [NSMutableString stringWithCapacity:[self length] * 2];
    
    NSUInteger length = [self length];
    
    for (int i = 0; i < length; i ++) {
        unichar c = [self characterAtIndex:i];
        [s appendFormat:@"%x",c];
        if (i != length - 1) {
            [s appendString:@" "];
        }
    }
    return s;
}

@end
