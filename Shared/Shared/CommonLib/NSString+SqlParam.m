//
//  NSString+SqlParam.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-4-27.
//
//

#import "NSString+SqlParam.h"

@implementation NSString (SqlParam)

+ (NSString *)safeSqlParam:(NSString *)str
{
    if (str == nil) {
        return @"";
    }
    return [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

@end
