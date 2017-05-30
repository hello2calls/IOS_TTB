//
//  DataFileUtility.m
//  TouchPalDialer
//
//  Created by Chen Lu on 1/31/13.
//
//

#import "DataFileUtility.h"

@implementation DataFileUtility

+ (void)saveData:(NSData *)data asFile:(NSString *)fileName
{
    if (fileName == nil || [fileName length] == 0) {
        return;
    }
    
    if (data == nil) {
        data = [NSData data];
    }
    
    NSString *filePath = [self persistentFilePath:fileName];
    [data writeToFile:filePath atomically:YES];
}

+ (NSData *)readDataFromFile:(NSString *)fileName
{
    if (fileName == nil || [fileName length] == 0) {
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:[self persistentFilePath:fileName]];
}

+ (NSString *)persistentFilePath:(NSString *)fileName
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}


@end
