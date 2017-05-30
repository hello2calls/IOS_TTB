//
//  AntiharassTools.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/18.
//
//

#import <Foundation/Foundation.h>

static NSString * const ANTIHARASS_DBFILE_NAME = @"anti-harass10.db";
static NSString * const ANTIINTERMEDIARY_DBFILE_NAME = @"anti-intermediary1.db";
static NSString * const ANTIFRAUD_DBFILE_NAME = @"anti-fraud11.db";
static NSString * const ANTIPROMOTE_DBFILE_NAME = @"anti-promote5.db";
static NSString * const ANTIYELLOWPAGE_DBFILE_NAME = @"anti-yellowpage1000.db";

static NSString * const ANTIHARASS_VERSIONFILE_NAME = @"version.txt";
static NSString * const ANTIHARASS_DBFILE_UNZIP_NAME = @"antiharass_ios_0.db";
static NSString * const ANTIHARASS_DBFILE_ZIP_NAME = @"antiharass_ios_0.zip";

@interface AntiharassTools : NSObject

+ (NSString *)antiharassDBDirectory;

+ (NSString *)antiharassUnzipDirectory;

+ (NSString *)dbFilePathWithName:(NSString *)name;

+ (NSString *)antiharassVersionFilePath;

+ (NSString *)antiharassDBZipFilePath;

+ (NSString *)getTagNameFromTag:(NSInteger)tag;

+ (NSArray *)getAnti10DBNameArr;

+ (NSString *)getExtensionIdentifierWithDBPathWithDBPath:(NSString *)dbPath;
@end
