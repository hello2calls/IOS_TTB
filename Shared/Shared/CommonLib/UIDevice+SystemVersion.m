//
//  UIDevice+SystemVersion.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/24/12.
//
//

#import "UIDevice+SystemVersion.h"

@implementation UIDevice (SystemVersion)

+(BOOL)systemVersionLessThanMajor:(NSInteger)major minor:(NSInteger)minor
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    
    if (!ver || [ver length] == 0) {
        return YES;
    }
    
    NSString *reqVer = [NSString stringWithFormat:@"%d.%d",major,minor];
    NSString *curVer = [[UIDevice currentDevice] systemVersion];
    return ([curVer compare:reqVer options:NSNumericSearch] == NSOrderedAscending);
}

+ (BOOL)systemVersionBelongsToVersion:(NSString *)version
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if (!ver || [ver length] == 0) {
        return NO;
    }
    
    return [ver hasPrefix:version];
}

@end
