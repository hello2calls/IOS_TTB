//
//  NSString+UUID.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-3-13.
//
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString*)stringWithNewUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef str = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *result = [(__bridge NSString*) str copy];
    CFRelease(str);
    return result;
}

@end
