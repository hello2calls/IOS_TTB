//
//  NSKeyedUnarchiver+TPSafe.m
//  TouchPalDialer
//
//  Created by Chen Lu on 1/14/13.
//
//

#import "NSKeyedUnarchiver+TPSafe.h"
#import "DefaultUIAlertViewHandler.h"

@implementation NSKeyedUnarchiver (TPSafe)

+ (id)safelyUnarchiveObjectWithData:(NSData *)data
{
    if (data == nil) {
        return nil;
    }
    id obj = nil;
    
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        obj = nil;
#ifdef DEBUG
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"exception thrown on unarchive"
                                                  message:exception.description];
#endif
    }
    return obj;
}

+ (id)safelyUnarchiveObjectWithFile:(NSString *)path
{
    if (path == nil || [path length] == 0) {
        return nil;
    }
    id obj = nil;
    
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *exception) {
        obj = nil;
#ifdef DEBUG
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"exception thrown on unarchive"
                                                  message:exception.description];
#endif
    }
    return obj;
}

@end
