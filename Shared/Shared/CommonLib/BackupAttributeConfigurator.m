//
//  SkipBackupAttributeConfigurator.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-3-7.
//
//

#import "BackupAttributeConfigurator.h"
#import "UIDevice+SystemVersion.h"
#import <sys/xattr.h>

@implementation BackupAttributeConfigurator

+ (void)skipBackupAttributeAtPath:(NSString *)path skipOrBackup:(BOOL)skipOrBackup
{
    if ([UIDevice systemVersionLessThanMajor:5 minor:1]) {
        [self oldAddSkipBackupAttributeToItemAtPath:path skipOrBackup:skipOrBackup];
    } else {
        [self addSkipBackupAttributeToItemAtPath:path skipOrBackup:skipOrBackup];
    }
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path skipOrBackup:(BOOL)skipOrBackup
{
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists) {
        return NO;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:isDirectory];
    NSError *error = nil;
    
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: skipOrBackup]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    return success;
}

+ (BOOL)oldAddSkipBackupAttributeToItemAtPath:(NSString *)path skipOrBackup:(BOOL)skipOrBackup
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    
    const char* filePath = [path fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = skipOrBackup ? 1: 0;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

@end
