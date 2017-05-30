//
//  AntiharassDataManager.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/18.
//
//

#import "AntiharassDataManager.h"
#import "AntiharassTools.h"
#import "FMDatabase.h"
#import "UserDefaultsManager.h"
#import "Reachability.h"
#import "AntiharassUtil.h"
#import <ZipArchive/ZipArchive.h>
#import <CallKit/CallKit.h>
#import "AntiharassAdressbookUtil.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"
#import "LocalStorage.h"
#import "CootekNotifications.h"
#import "PhoneConvertUtil.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultKeys.h"
#import <sqlite3.h>
#import "FMDB.h"
#import "FileUtils.h"
#import "DialerUsageRecord.h"
#define ANTIHARASS_DBDATA_VERSION_FILE_URL @"http://touchlife.cootekservice.com/dialer_cdn/iphone/default/antiharass/db-iOS10-new/antiharass_version";

#define ANTIHARASS_DBDATA_ZIPFILE_URL @"http://touchlife.cootekservice.com/dialer_cdn/iphone/default/antiharass/db-iOS10-new/antiharass_ios_0.zip";

#define ANTIHARASS_DBDATA_VERSION_FILE_TEST_URL @"http://121.52.235.231:40009/dialer_cdn/iphone/default/antiharass/db-iOS10-new/antiharass_version";
#define ANTIHARASS_DBDATA_ZIPFILE_TEST_URL @"http://121.52.235.231:40009/dialer_cdn/iphone/default/antiharass/db-iOS10-new/antiharass_ios_0.zip";
#define ANTIHARASS_DBDATA_ZIPFILE_TEST_TOKEN @"8a38406c-c198-4b5b-a1d0-fed69d08a685"

#define ANTI_CITY @"anti_city"
#define ANTI_LOAD_COUNT @"anti_load_count"

@interface AntiharassDataManager ()

@end

@implementation AntiharassDataManager

+ (instancetype)sharedManager {
    
    static AntiharassDataManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

+ (void)updateCallExtensionEnableStatus {
 
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10) {
        [[CXCallDirectoryManager sharedInstance] getEnabledStatusForExtensionWithIdentifier:kCallDirectoryID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error){
            if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                [UserDefaultsManager setBoolValue:YES forKey:kCallDirectoryKey];
                [UserDefaultsManager synchronize];
            } else {
                [UserDefaultsManager setBoolValue:NO forKey:kCallDirectoryKey];
                [UserDefaultsManager synchronize];
            }
        }];
        
        [[CXCallDirectoryManager sharedInstance] getEnabledStatusForExtensionWithIdentifier:kIntermediaryCallID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error){
            if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                [UserDefaultsManager setBoolValue:YES forKey:kIntermediaryKey];
                [UserDefaultsManager synchronize];
            } else {
                [UserDefaultsManager setBoolValue:NO forKey:kIntermediaryKey];
                [UserDefaultsManager synchronize];
            }
        }];

        [[CXCallDirectoryManager sharedInstance] getEnabledStatusForExtensionWithIdentifier:kFraudCallID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error){
            if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                [UserDefaultsManager setBoolValue:YES forKey:kFraudCallKey];
                [UserDefaultsManager synchronize];
            } else {
                [UserDefaultsManager setBoolValue:NO forKey:kFraudCallKey];
                [UserDefaultsManager synchronize];
            }
        }];
        
        [[CXCallDirectoryManager sharedInstance] getEnabledStatusForExtensionWithIdentifier:kYellowPageCallID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error){
            if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                [UserDefaultsManager setBoolValue:YES forKey:kYellowPageCallKey];
                [UserDefaultsManager synchronize];
            } else {
                [UserDefaultsManager setBoolValue:NO forKey:kYellowPageCallKey];
                [UserDefaultsManager synchronize];
            }
        }];
        
        [[CXCallDirectoryManager sharedInstance] getEnabledStatusForExtensionWithIdentifier:kPromoteCallID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error){
            if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                [UserDefaultsManager setBoolValue:YES forKey:kPromoteCallKey];
            } else {
                [UserDefaultsManager setBoolValue:NO forKey:kPromoteCallKey];
                [UserDefaultsManager synchronize];
            }
            
            BOOL resutl = [UserDefaultsManager boolValueForKey:kCallDirectoryKey] ||
            [UserDefaultsManager boolValueForKey:kIntermediaryKey] ||
            [UserDefaultsManager boolValueForKey:kFraudCallKey] ||
            [UserDefaultsManager boolValueForKey:kPromoteCallKey] ||
            [UserDefaultsManager boolValueForKey:kYellowPageCallKey];
            [UserDefaultsManager setBoolValue:resutl forKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION]; // data point
            [DialerUsageRecord recordpath:PATH_ANTIHARASS_SYSTEM_ENABLE kvs:Pair(PATH_ANTIHARASS_SYSTEM_ENABLE, @(resutl)), nil];
            [UserDefaultsManager synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:N_CALLEXTENSION_STATUS_REFRESH object:nil];
            });
        }];
    }
}


- (void)checkUpdateAntiDataInBackground {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkAntiDBVersionIfInHand:NO];
    });
}

- (void)checkUpdateAntiDataInHand {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkAntiDBVersionIfInHand:YES];
    });
}



+ (BOOL)installDBFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    BOOL result = [self moveFileFromPath:fromPath toPath:toPath ];
    if (!result) {
        return NO;
    }
    return YES;
}

+ (BOOL)loadDBWithdbShortName:(NSString *)dbShortName withCity:(NSString *)city {
    cootek_log(@"GroupShare StartloadDB%@ %@",dbShortName,city);

    NSString *dbPath = [AntiharassTools dbFilePathWithName:dbShortName];
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    
    if (![database open]) {
        return NO;
    }
    NSString *identifier =  [self generateExtensionIdentifierWithdbShortName:dbShortName];
    NSString *groupID = [self generateGroupComNameWithdbShortName:dbShortName];
    
#warning 解码之后的测试号码
//18616254335 骚扰电话 18521710010 诈骗电话 13524287239 推销电话 18616342635 房产中介 17317699132 黄页
 
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", @"callerid_table"];
    
    NSMutableArray *array = [NSMutableArray array];
    
    FMResultSet *result = [database executeQuery:sql];
    if (result) {
        while ([result next]){
            @autoreleasepool {
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                long long int number = [result longLongIntForColumn:@"number"];
                number = [PhoneConvertUtil LongToNSStringIOS10Anti:number].longLongValue;
                if (number > 0) {
                    info[@"number"] = @(number);
                    if ([result intForColumn:@"tag"] == 0) {
                        NSData *resultData = [result dataNoCopyForColumn:@"name"];
                        Byte *testByte = (Byte *)[resultData bytes];
                        for (int i = 0; i <=resultData.length; i ++) {
                            testByte[i] = (Byte) ((int) testByte[i] ^ 170);
                        }
                        NSString *tagString =  [[NSString alloc] initWithBytes:testByte length:resultData.length encoding:NSUnicodeStringEncoding];
                        info[@"tag"] = tagString;
                    } else {
                        info[@"tag"] = [AntiharassTools getTagNameFromTag:[result intForColumn:@"tag"]];
                    }
                [array addObject:info];
                }
            }
        }
    }
    
    [database close];

    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *info1 = obj1;
        NSDictionary *info2 = obj2;
        NSNumber *number1 = info1[@"number"];
        NSNumber *number2 = info2[@"number"];
        return  [number1 compare:number2];
    }];
    
    [self creatTableInGroupShareWithGroupIdentifier:groupID withArray:sortArray];
    [[CXCallDirectoryManager sharedInstance] reloadExtensionWithIdentifier:identifier completionHandler:^(NSError * _Nullable error) {
        cootek_log(@"GroupShare reload 结束%@",identifier);
        [AntiharassDataManager saveShouldReloadToExtentionCountWhenEndReload];
        if (error && error.code!=6) {
            cootek_log(@"GroupShare reload %@================%@",identifier,error);
        } else {
            NSString *dbShortName = [AntiharassDataManager generatedbShortNameWithExtensionIdentifier:identifier];
            [AntiharassDataManager reloadExtensionSuccessAndSaveInfoWithdbShortName:dbShortName andCity:city];
        }
        
    }];
    [NSThread sleepForTimeInterval:8];
    return YES;
}

+ (void)checkAsyncLoadDBData {
    cootek_log(@"GroupShare checkAsyncLoadDBData");

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        NSArray *dbNameArr = [AntiharassTools getAnti10DBNameArr];
        __block BOOL success = YES;

        
        NSString *city = [AntiharassDataManager getNowExtentionFileInfoCity];
        NSArray *shouldReloadDbArray = [AntiharassDataManager getdbShortNameArrayShowReloadToExtentionWithExtentionFileInfo];
        if (shouldReloadDbArray.count > 0 && ![AntiharassDataManager checkIfNowReloadExtention]) {
            NSString* unZiptoDirectory = [AntiharassTools antiharassUnzipDirectory];
            for (NSString *dbName in dbNameArr) {
                NSString *fromPath = [unZiptoDirectory stringByAppendingPathComponent:dbName];
                NSString *toPath = [AntiharassTools dbFilePathWithName:dbName];
                if (![AntiharassDataManager installDBFromPath:fromPath toPath:toPath]) {
                    success = NO;
                }
            }
            [AntiharassDataManager saveShowReloadToExtentionCountWhenStartLoad:shouldReloadDbArray.count];
            for (NSString *dbName in shouldReloadDbArray) {
                [AntiharassDataManager loadDBWithdbShortName:dbName withCity:city];
            }
        }
    });
}


- (NSInteger) countTableWithWithGroupIdentifier:(NSString *)groupIdentifier {
    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",groupIdentifier]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        FMDatabase* db = [FMDatabase databaseWithPath:fileName];
        if ([db open]) {
            NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM t_text"];
            FMResultSet *rs = [db executeQuery:sqlstr];
            while ([rs next])
            {
                NSInteger count = [rs intForColumn:@"count"];
                return count;
            }
        }
    }
    return 0;
}


//- (void)creatTableInDocWithGroupIdentifier:(NSString *)groupIdentifier withArray:(NSArray *)array {
//    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",groupIdentifier]];
//    NSError *error;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
//        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
//    }
//    cootek_log(@"fileError%@",error);
//    FMDatabase* db = [FMDatabase databaseWithPath:fileName];
//    BOOL res = [db open];
//    if (res == NO) {
//        cootek_log(@"打开失败");
//        return;
//    }else{
//        cootek_log(@"数据库打开成功");
//    }
//    
//    res = [db executeUpdate:@"create table if not exists t_text (id integer primary key autoincrement,phone text,name text)"];//执行sql语句
//    
//    if (res == NO) {
//        cootek_log(@"创建失败");
//        [db close];//关闭数据库
//        return;
//    }
//    
//    [db beginTransaction];
//    BOOL isRollBack = NO;
//    
//    @try {
//        for (NSDictionary *info in array) {
//            res = [db executeUpdate:@"insert into t_text(phone,name) values (?,?)" values:@[info[@"number"],info[@"tag"]] error:&error];
//            if (res == NO) {
//                cootek_log(@"插入失败");
//            }
//        }
//        
//    }
//    @catch (NSException *exception) {
//        isRollBack = YES;
//        [db rollback];
//    }
//    @finally {
//        if (!isRollBack) {
//            [db commit];
//        }
//    }
//    
//    
//}


+ (void)creatTableInGroupShareWithGroupIdentifier:(NSString *)groupIdentifier withArray:(NSArray *)array {
    NSURL *pathUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier];
    NSString *fileName = [[pathUrl path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",groupIdentifier]];
    
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
    }
    FMDatabase* db = [FMDatabase databaseWithPath:fileName];
    BOOL res = [db open];
    if (res == NO) {
        cootek_log(@"打开失败");
        return;
    }
    
    res = [db executeUpdate:@"create table if not exists t_text (id integer primary key autoincrement,number text,tag text)"];//执行sql语句
    
    if (res == NO) {
        cootek_log(@"创建失败");
        [db close];//关闭数据库
        return;
    }
    
    [db beginTransaction];
    for (NSDictionary *info in array) {
        res = [db executeUpdate:@"insert into t_text(number,tag) values (?,?)" values:@[info[@"number"],info[@"tag"]] error:&error];
        if (res == NO) {
            cootek_log(@"插入失败");
        }
    }

    [db commit];
    
    [db close];
    cootek_log(@"GroupShare数据库写入结束%@",groupIdentifier);

}






- (void)checkAntiDBVersionIfInHand:(BOOL)inHand {
    
    if ([Reachability network] == network_none &&
        [[Reachability shareReachability] currentReachabilityStatus] == NotReachable)  return ;
    
    __weak typeof(self) weakSelf = self;
    NSString *city = [UserDefaultsManager stringForKey:ANTIHARASSEXTENSIONCITY defaultValue:@"全国"];

    NSString *urlStr = ANTIHARASS_DBDATA_VERSION_FILE_URL;
    
    NSString *versionFilePath = [AntiharassTools antiharassVersionFilePath];
    cootek_log(@"GroupShare StartDownLoadVersionFile");
    [[NSFileManager defaultManager] removeItemAtPath:versionFilePath error:nil];
    
    NSString *urlString = [[NSString stringWithFormat:@"%@?_token=%@&city=%@",urlStr,[SeattleFeatureExecutor getToken],city] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [AntiharassUtil downloadFileFrom:urlString to:versionFilePath withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int recentVersion = [NSString stringWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:nil].intValue;
                int currentVersion = [UserDefaultsManager intValueForKey:ANTIHARASS_DATAVERSION_iOS10NEW defaultValue:0];
                if (!inHand) {
                    if (![UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE defaultValue:NO]) {
                        [UserDefaultsManager setIntValue:recentVersion forKey:ANTIHARASS_HAND_TOPVIEW_DATAVERSION];
                        [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_NEED_HAND_UPDATE_NOTICE object:nil];
                        
                    }else {
                        if (recentVersion > currentVersion) {
                            [weakSelf downLoadDBZipWithDBIntVersion:recentVersion city:city ifInHand:NO];
                        }
                    }
                    
                }else{
                    if (recentVersion >= currentVersion) {
                        [weakSelf downLoadDBZipWithDBIntVersion:recentVersion city:city ifInHand:YES];
                    }
                }
                
            });
            
        } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            cootek_log(@"downLoadDBZipWithDBVersionFail = %@",operation,error);
            [[NSNotificationCenter defaultCenter] postNotificationName:N_DOWNLOAD_DB_FILE_FAIL object:nil];
        }];
 
   
    
    
}

- (void)downLoadDBZipWithDBIntVersion:(NSInteger)db_version city:(NSString *)city ifInHand:(BOOL)inHand{
    

    NSString *urlStr = ANTIHARASS_DBDATA_ZIPFILE_URL;
    NSString *urlString = [[NSString stringWithFormat:@"%@?_token=%@&db_version=%d&city=%@",urlStr,[SeattleFeatureExecutor getToken],db_version,city] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *dbZipFilePath = [AntiharassTools antiharassDBZipFilePath];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:dbZipFilePath]) {
        if (![fileManager removeItemAtPath:dbZipFilePath error:nil]) {
            return;
        }
    }
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION];

    [AntiharassUtil downloadFileFrom:urlString to:dbZipFilePath withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            ZipArchive* zip = [[ZipArchive alloc] init];
            
            NSString* unZiptoDirectory = [AntiharassTools antiharassUnzipDirectory];
            
            if( [zip UnzipOpenFile:dbZipFilePath] ) {
                BOOL ret = [zip UnzipFileTo:unZiptoDirectory overWrite:YES];
                if( NO == ret ){
                    cootek_log(@"zip file failed");
                } else {
                    [AntiharassDataManager saveInfoToExtentionFileWithCity:city];
                    [AntiharassDataManager checkAsyncLoadDBData];
                    __block int version = 0;
                        NSString *versionFilePath = [AntiharassTools antiharassVersionFilePath];
                            version = [NSString stringWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:nil].intValue;
                            [UserDefaultsManager setIntValue:version forKey:ANTIHARASS_DATAVERSION_iOS10NEW];
                            cootek_log(@"GroupShare db ok");
                            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!inHand) {
                                    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_UPDATE_SUCCESS_NOTICE];
                                }
                                [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_UPDATE_SUCCESS_NOTICE object:nil];
                            });
                }
                [zip UnzipCloseFile];
            }
            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION];

        });
        
        cootek_log(@"antiharass: download db file success");
        
    } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        cootek_log(@"downLoadDBZipWithDBIntVersionFail = %@",error);
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION];

        [[NSNotificationCenter defaultCenter] postNotificationName:N_DOWNLOAD_DB_FILE_FAIL object:nil];
    }];
    
}
#pragma mark - Private Method
+ (BOOL)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dierctoryPath = [AntiharassTools antiharassDBDirectory];
    if (![fileManager fileExistsAtPath:dierctoryPath isDirectory:nil]) {
        BOOL createDirectory = [fileManager createDirectoryAtPath:dierctoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!createDirectory) {
            cootek_log(@"创建文件夹失败:%@",error);
            return NO;
        }
    }
    
    if ([fileManager fileExistsAtPath:toPath]) {
        if ([fileManager removeItemAtPath:toPath error:nil]) {
            if([fileManager copyItemAtPath:fromPath toPath:toPath error:nil]){
                return YES;
            }
        }
    } else if([fileManager copyItemAtPath:fromPath
                           toPath:toPath error:nil]){
            return YES;
            }
    return NO;
}

+ (void)saveInfoToExtentionFileWithCity:(NSString *)city {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *oldDic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    NSNumber *countNum = [oldDic objectForKey:ANTI_LOAD_COUNT];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:city forKey:ANTI_CITY];
    NSArray *dbNameArr = [AntiharassTools getAnti10DBNameArr];
    for (NSString *dbShortName in dbNameArr) {
        [dic setObject:@(0) forKey:[NSString stringWithFormat:@"%@_%@",city,dbShortName]];
    }
    if (countNum==nil) {
        [dic setObject:@(0) forKey:ANTI_LOAD_COUNT];
    } else {
        [dic setObject:countNum forKey:ANTI_LOAD_COUNT];
    }
    [dic writeToFile:commonFileExtensionDBInfoPath atomically:YES];
}

+ (NSArray *)getdbShortNameArrayShowReloadToExtentionWithExtentionFileInfo {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    
    NSString *city = [dic objectForKey:ANTI_CITY];
    NSMutableArray *dbShortNamearray  = [NSMutableArray array];
    if (dic.allKeys.count==0 || city.length==0)  {
        return nil;
    }
    NSArray *dbNameArr = [AntiharassTools getAnti10DBNameArr];
    for (NSString *dbShortName in dbNameArr) {
        NSNumber *notAdd = [dic objectForKey:[NSString stringWithFormat:@"%@_%@",city,dbShortName]];
        if (notAdd.boolValue==NO) {
            [dbShortNamearray addObject:dbShortName];
        }
    }
    return  dbShortNamearray;
}

+ (void)saveShowReloadToExtentionCountWhenStartLoad:(NSUInteger)count {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    [dic setObject:@(count) forKey:ANTI_LOAD_COUNT];
    [dic writeToFile:commonFileExtensionDBInfoPath atomically:YES];

}

+ (void)saveShouldReloadToExtentionCountWhenEndReload {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    
    NSString *city = [dic objectForKey:ANTI_CITY];
    NSUInteger count = 0;
    if (dic.allKeys.count==0 || city.length==0)  {
        [dic setObject:@(count) forKey:ANTI_LOAD_COUNT];
        [dic writeToFile:commonFileExtensionDBInfoPath atomically:YES];
    } else {
        NSNumber *oldCount = [dic objectForKey:ANTI_LOAD_COUNT];
        if (oldCount!=nil && oldCount.integerValue>0) {
            [dic setObject:@(oldCount.integerValue-1) forKey:ANTI_LOAD_COUNT];
           
        } else{
            [dic setObject:@(0) forKey:ANTI_LOAD_COUNT];
        }
         [dic writeToFile:commonFileExtensionDBInfoPath atomically:YES];
    }
}

+ (void)resetShouldReloadCountToExtentionCountWhenLuanch {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    
    NSString *city = [dic objectForKey:ANTI_CITY];
    if (dic.allKeys.count==0 || city.length==0)  {
        return;
    } else {
        [dic setObject:@(0) forKey:ANTI_LOAD_COUNT];
        [dic writeToFile:commonFileExtensionDBInfoPath atomically:YES];
    }
}

+ (BOOL)checkIfNowReloadExtention {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    
    NSNumber *countNum = [dic objectForKey:ANTI_LOAD_COUNT];
    return countNum.integerValue!=0;
    
}


+ (NSString *)getNowExtentionFileInfoCity {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    NSString *city = [dic objectForKey:ANTI_CITY];
    return  city;
}


+ (void)reloadExtensionSuccessAndSaveInfoWithdbShortName:(NSString *)dbShortName andCity:(NSString *)city {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    [FileUtils createDir:docmentCommonFileDirPath];
    NSString *commonFileExtensionDBInfoPath = [docmentCommonFileDirPath stringByAppendingPathComponent:@"extensionDBInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:commonFileExtensionDBInfoPath];
    NSString *key_cityAndShortName =  [NSString stringWithFormat:@"%@_%@",city,dbShortName];
    NSNumber *valueNumber = [dic valueForKey:key_cityAndShortName];
    if (valueNumber!=nil ) {
        [dic setObject:@(1) forKey:key_cityAndShortName];
        [dic writeToFile:commonFileExtensionDBInfoPath atomically:YES];
    }
}


+ (NSString *)generateKeyWithdbShortName:(NSString *)dbPath {
    
    if ([dbPath isEqualToString:ANTIHARASS_DBFILE_NAME]) {
        return kCallDirectoryKey;
    }
    
    if ([dbPath isEqualToString:ANTIINTERMEDIARY_DBFILE_NAME]) {
        return kIntermediaryKey;
    }
    
    if ([dbPath isEqualToString:ANTIFRAUD_DBFILE_NAME]) {
        return kFraudCallKey;
    }
    
    if ([dbPath isEqualToString:ANTIPROMOTE_DBFILE_NAME]) {
        return kPromoteCallKey;
    }
    
    if ([dbPath isEqualToString:ANTIYELLOWPAGE_DBFILE_NAME]) {
        return kYellowPageCallKey;
    }
    return nil;
}

+ (NSString *)generateGroupComNameWithdbShortName:(NSString *)dbShortName {
    
    if ([dbShortName isEqualToString:ANTIHARASS_DBFILE_NAME]) {
        return @"group.com.cootek.calldirectory";
    }
    
    if ([dbShortName isEqualToString:ANTIINTERMEDIARY_DBFILE_NAME]) {
        return @"group.com.cootek.intermediary";
    }
    
    if ([dbShortName isEqualToString:ANTIFRAUD_DBFILE_NAME]) {
        return @"group.com.cootek.fraud";
    }
    
    if ([dbShortName isEqualToString:ANTIPROMOTE_DBFILE_NAME]) {
        return @"group.com.cootek.promote";
    }
    
    if ([dbShortName isEqualToString:ANTIYELLOWPAGE_DBFILE_NAME]) {
        return @"group.com.cootek.yellowpage";
    }
    
    return nil;
}
+ (NSString *)generateExtensionIdentifierWithdbShortName:(NSString *)dbShortName {
    
    if ([dbShortName isEqualToString:ANTIHARASS_DBFILE_NAME]) {
        return @"com.cootek.Contacts.CallDirectoryExtension";
    }
    
    if ([dbShortName isEqualToString:ANTIINTERMEDIARY_DBFILE_NAME]) {
        return @"com.cootek.Contacts.IntermediaryCallExtension";
    }
    
    if ([dbShortName isEqualToString:ANTIFRAUD_DBFILE_NAME]) {
        return @"com.cootek.Contacts.FraudCallExtension";
    }
    
    if ([dbShortName isEqualToString:ANTIPROMOTE_DBFILE_NAME]) {
        return @"com.cootek.Contacts.PromoteCallExtension";
    }
    
    if ([dbShortName isEqualToString:ANTIYELLOWPAGE_DBFILE_NAME]) {
        return @"com.cootek.Contacts.YellowPageCallExtension";
    }
    
    return nil;
}

+ (NSString *)generatedbShortNameWithExtensionIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"com.cootek.Contacts.CallDirectoryExtension"]) {
        return ANTIHARASS_DBFILE_NAME;
    }
    
    if ([identifier isEqualToString:@"com.cootek.Contacts.IntermediaryCallExtension"]) {
        return ANTIINTERMEDIARY_DBFILE_NAME;
    }
    
    if ([identifier isEqualToString:@"com.cootek.Contacts.FraudCallExtension"]) {
        return ANTIFRAUD_DBFILE_NAME;
    }
    
    if ([identifier isEqualToString:@"com.cootek.Contacts.PromoteCallExtension"]) {
        return ANTIPROMOTE_DBFILE_NAME;
    }
    
    if ([identifier isEqualToString: @"com.cootek.Contacts.YellowPageCallExtension"]) {
        return ANTIYELLOWPAGE_DBFILE_NAME;
    }
}


@end
