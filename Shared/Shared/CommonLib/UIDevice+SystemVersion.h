//
//  UIDevice+SystemVersion.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/24/12.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (SystemVersion)

+(BOOL) systemVersionLessThanMajor:(NSInteger)major minor:(NSInteger)minor;
+ (BOOL)systemVersionBelongsToVersion:(NSString *)version;
@end
