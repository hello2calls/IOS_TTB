//
//  DataFileUtility.h
//  TouchPalDialer
//
//  Created by Chen Lu on 1/31/13.
//
//

#import <Foundation/Foundation.h>

#define FILE_MARKETING_AD_IMAGE @"FILE_MARKETING_AD_IMAGE"

@interface DataFileUtility : NSObject

+ (void)saveData:(NSData *)data asFile:(NSString *)fileName;
+ (NSData *)readDataFromFile:(NSString *)fileName;

@end
