//
//  AntiharassTools.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/18.
//
//

#import "AntiharassTools.h"
#import "AntiharassDataManager.h"
static NSString * const ANTIHARASS_DIRECTORY = @"antiharass";
static NSString * const ANTIHARASS_TMP_DIRECTORY = @"tmp";


@implementation AntiharassTools

+ (NSArray *)getAnti10DBNameArr {
    NSArray *dbNameArr = @[ANTIHARASS_DBFILE_NAME,
                   ANTIINTERMEDIARY_DBFILE_NAME,
                   ANTIFRAUD_DBFILE_NAME,
                   ANTIPROMOTE_DBFILE_NAME,
                   ANTIYELLOWPAGE_DBFILE_NAME];
    return dbNameArr;
}

+ (NSArray *)getAnti10KID {
    NSArray *kIDArr = @[kCallDirectoryID,kIntermediaryCallID,kFraudCallID,kPromoteCallID,kYellowPageCallID];
    return kIDArr;
}


+ (NSString *)antiharassDBDirectory {
    NSString *docWithDb = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:ANTIHARASS_DIRECTORY];
    if (![[NSFileManager defaultManager] fileExistsAtPath:docWithDb]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docWithDb withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return docWithDb;
    
}

+ (NSString *)antiharassUnzipDirectory {
    
    return [[self antiharassDBDirectory] stringByAppendingPathComponent:ANTIHARASS_TMP_DIRECTORY];
    
}

+ (NSString *)dbFilePathWithName:(NSString *)name {
    
    return [[self antiharassDBDirectory] stringByAppendingPathComponent:name];
    
}

+ (NSString *)antiharassVersionFilePath {
    
    return [[self antiharassDBDirectory] stringByAppendingPathComponent:ANTIHARASS_VERSIONFILE_NAME];
    
}

+ (NSString *)antiharassDBZipFilePath {
    
    return [[self antiharassDBDirectory] stringByAppendingPathComponent:ANTIHARASS_DBFILE_ZIP_NAME];
    
}

+ (NSString *)getTagNameFromTag:(NSInteger)tag {
    
    switch (tag) {
        case 1:
            return  @"房产中介";
        case 5:
            return  @"业务推销";
        case 10:
            return  @"骚扰电话";
        case 11:
            return  @"诈骗钓鱼";
        default:
            return @"";
    }

}
@end
