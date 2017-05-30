//
//  NSString+TPHandleNil.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/24/12.
//
//

#import "NSString+TPHandleNil.h"

@implementation NSString (TPHandleNil)

+(NSString *)nilToEmpty:(NSString *)aString
{
    return aString ? aString : @"";
}

+(NSString *)nilToEmptyTrimmed:(NSString *)aString
{
    return [[self nilToEmpty:aString] stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (BOOL) isNilOrEmpty: (NSString *) str {
    if (!str || str.length == 0) {
        return YES;
    }
    return NO;
}
@end
