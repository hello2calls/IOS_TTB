//
//  QueryCallerid.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import "QueryCallerid.h"
#import "LocalCallerUtil.h"
#import "PhoneNumber.h"
#import "PhoneConvertUtil.h"
#import "QueryResult.h"
#import "DatabaseFactory.h"
#import "Reachability.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "CalleridUpdateInfo.h"
#import "NameDB.h"
#import "NameUpdateDB.h"
#import "NationalDB.h"
#import "FileUtils.h"
#import "NetworkUtil.h"

@interface QueryCallerid () {
    dispatch_queue_t queryQueue;
}

@end

@implementation QueryCallerid

@synthesize nationDB;
@synthesize nationUpDB;
@synthesize tagDB;
@synthesize nationId;
@synthesize nationUpId;
@synthesize tagId;

static QueryCallerid *shareInstance;
static int specificKey = 0;

+ (void)initialize {
    shareInstance = [[QueryCallerid alloc]init];
}

+ (QueryCallerid *)shareInstance {
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        nationId = @"1000";
        nationUpId = @"1000_up";
        tagId = @"1100";
        [LocalCallerUtil copyDBIfNotExist];
        NSString *nationDBPath = [FileUtils getAbsoluteFilePath:[LocalCallerUtil getNameDBName]];
        NSString *tagDBPath = [FileUtils getAbsoluteFilePath:[LocalCallerUtil getTagDBName]];
        nationDB = [DatabaseFactory newDataBase:nationDBPath];
        tagDB = [DatabaseFactory newDataBase:tagDBPath];
        [self connectDataBase:nationId];
        [self connectDataBase:tagId];
        queryQueue = dispatch_queue_create("com.touchpal.dialer.callerid.query", NULL);
        CFStringRef specificValue = CFSTR("com.touchpal.dialer.callerid.query");
        dispatch_queue_set_specific(queryQueue, &specificKey, (void*)specificValue, NULL);
    }
    return self;
}

- (CallerIDInfoModel *)getLocalCallerid:(NSString *)number {
    NSString *normalizedNumber = [self normalizedNumber:[[PhoneNumber sharedInstance]getNormalizedNumber:number]];
    CallerIDInfoModel *info;
    if ([self checkPhone:normalizedNumber]) {
        long long convertNumber = [PhoneConvertUtil NSStringToLong:normalizedNumber];
        if (convertNumber > 0) {
            __block QueryResult *result = nil;
            dispatch_sync(queryQueue, ^{
                result = [self queryFromDB:convertNumber];
            });
            if (result) {
                info = [self convertResultToCalleridInfo:result withNumber:number withNormalized:normalizedNumber];
            }
        }
    }
    return info;
}

- (NSString *)longToString:(long)number {
    return [PhoneConvertUtil LongToNSString:number];
}

- (void)checkUpdate {
    cootek_log(@"callerid start checkup");
    if ([Reachability network] < network_wifi) {
        return;
    }
    
    if (![FunctionUtility isTimeUpForEvent:CALLERID_CHECK withSchedule:3600*24 firstTimeCount:YES persistCheck:NO]) {
        return;
    }
    NSString *urlString = [ONLINE_FILE_PATH stringByAppendingPathComponent:[LocalCallerUtil getCheckFileName]];
    [LocalCallerUtil downloadFileFrom:urlString to:[FileUtils getAbsoluteFilePath:[LocalCallerUtil getCheckFileName]] withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UserDefaultsManager setObject:[NSDate date] forKey:CALLERID_CHECK];
        [self readCheckFile];
        cootek_log(@"callerid check update success");
    } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        cootek_log(@"callerid checkup failed:%@",error.description);
    }];
}

- (NSString*)normalizedNumber:(NSString*)number {
    if (!number || number.length < 3 || number.length > 17) {
        return nil;
    }
    if ([number hasPrefix:@"+"]) {
        return number;
    }
    if ([number hasPrefix:@"400"] || [number hasPrefix:@"95"] || [number hasPrefix:@"1010"] || [number hasPrefix:@"10086"] || [number hasPrefix:@"10010"]) {
        return [NSString stringWithFormat:@"+86%@", number];
    }
    if (number.length < 7 && ![number hasPrefix:@"96"]) {
        return [NSString stringWithFormat:@"+86%@", number];
    }
    return number;
}

- (BOOL)checkPhone:(NSString*)normaliedNumber {
    if (![normaliedNumber hasPrefix:@"+8"] || normaliedNumber.length <= 5 || normaliedNumber.length > 18) {
        return NO;
    }
    return YES;
}

- (QueryResult*) queryFromDB:(long long)convertNumber {
    TableItem *item;
    if (nationUpDB) {
        item = [nationUpDB queryCallerid:convertNumber];
    }
    if (item && item.updateType > NORMAL_TYPE) {
        return [self convertTableItemToQueryResult:item];
    }
    if (nationDB) {
        item = [nationDB queryCallerid:convertNumber];
        if ([self checkTableItem:item]) {
            return [self convertTableItemToQueryResult:item];
        }
    }
    if (tagDB) {
        item = [tagDB queryCallerid:convertNumber];
        if ([self checkTableItem:item]) {
            return [self convertTableItemToQueryResult:item];
        }
    }
    return nil;
}


- (QueryResult*) convertTableItemToQueryResult:(TableItem*)item {
    QueryResult *result = [[QueryResult alloc]init];
    if (item.updateType == DELETE_TYPE) {
        return result;
    }
    result.tagIndex = item.tag;
    result.tagName = [self getTagNameFromTagIndex:item.tag];
    result.name = [self unConfuseName:item.name];
    return result;
}

- (CallerIDInfoModel *) convertResultToCalleridInfo:(QueryResult*)result withNumber:(NSString*)number withNormalized:(NSString*)normalized {
    CallerIDInfoModel *info = [[CallerIDInfoModel alloc]init];
    info.name = result.name;
    info.number = number;
    info.callerType = result.tagName;
    info.callerIDCacheLevel = CallerIDQueryLocalLevel;
    info.markCount = 0;
    info.versionTime = [NSString stringWithFormat:@"llu", [[NSDate date]timeIntervalSince1970]];
    return info;
}

- (NSString*) getTagNameFromTagIndex:(NSInteger)tagIndex {
    switch (tagIndex) {
        case 1:
            return @"house agent";
        case 5:
            return @"promote sales";
        case 10:
            return @"crank";
        case 11:
            return @"fraud";
        default:
            return nil;
    }
}

- (NSString*)unConfuseName:(NSData*) nameData {
    NSMutableString *str = [[NSMutableString alloc]init];
    Byte *bytes = (Byte *)[nameData bytes];
    for (int i = 0; i < nameData.length; i++) {
        bytes[i] = (Byte) ((int) bytes[i] ^ 170);
        [str appendString:[NSString stringWithFormat:@"%0.2hhx", bytes[i]]];
    }
    NSString *name = [[NSString alloc]initWithBytes:bytes length:nameData.length encoding:NSUnicodeStringEncoding];
    return name;
}

- (BOOL)checkTableItem:(TableItem*)item {
    if ((!item.name || item.name.length < 1) && (item.tag == 0)) {
        return NO;
    }
    return YES;
}


- (NSString*)queryMainVersion:(NSString*)dbId {
    if ([dbId isEqualToString:nationId] && nationDB) {
        return [nationDB queryVersion:@"main_version"];
    } else if ([dbId isEqualToString:nationUpId] && nationUpDB) {
        return [nationUpDB queryVersion:@"update_version"];
    } else if ([dbId isEqualToString:tagId] && tagDB) {
        return [tagDB queryVersion:@"main_version"];
    }
    return nil;
}

- (NSString*)queryTargetVersion:(NSString*)dbId {
    if ([dbId isEqualToString:nationId] && nationDB) {
        return [nationDB queryVersion:@"target_version"];
    } else if ([dbId isEqualToString:nationUpId] && nationUpDB) {
        return [nationUpDB queryVersion:@"target_version"];
    } else if ([dbId isEqualToString:tagId] && tagDB) {
        return [tagDB queryVersion:@"target_version"];
    }
    return nil;
}


- (void) connectDataBase:(NSString*)dbId {
    if ([dbId isEqualToString:nationId] && ![nationDB isConnectAlive] && [nationDB isClosed]) {
        [nationDB connectDataBase];
    }
    if ([dbId isEqualToString:tagId] && ![tagDB isConnectAlive] && [tagDB isClosed]) {
        [tagDB connectDataBase];
    }
}

- (void) addUpdateDb {
    NSString *nationUpDBPath = [FileUtils getAbsoluteFilePath:[LocalCallerUtil getNameUpDBName]];
    nationUpDB = [DatabaseFactory newDataBase:nationUpDBPath];
    [nationUpDB connectDataBase];
}


- (void) closeDB:(NSString*)fileId {
    if ([fileId isEqualToString:nationId] && nationDB) {
        [nationDB close];
    }
    if ([fileId isEqualToString:nationUpId] && nationUpDB) {
        [nationUpDB close];
        nationUpDB = nil;
    }
    if ([fileId isEqualToString:tagId] && tagDB) {
        [tagDB close];
    }
}


- (void) readCheckFile {
    NSString *checkFile = [FileUtils getAbsoluteFilePath:[LocalCallerUtil getCheckFileName]];
    NSData *data = [NSData dataWithContentsOfFile:checkFile];
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:&error];
        for (int i = 0; i < 2; i++) {
        NSDictionary *dictionary = [array objectAtIndex:i];
        CalleridUpdateInfo *info = [self parseDictionary:dictionary];
        [self checkWhetherNeedDownload:info];
    }
}

- (CalleridUpdateInfo*) parseDictionary:(NSDictionary*)dic {
    CalleridUpdateInfo *info = [[CalleridUpdateInfo alloc]init];
    info.fileId = [dic objectForKey:FILE_ID];
    info.mainVersion = [dic objectForKey:MAIN_VERSION];
    info.mainUrl = [dic objectForKey:MAIN_URL];
    info.updateUrl = [dic objectForKey:UPDATE_URL];
    info.updateVersion = [dic objectForKey:UPDATE_VERSION];
    return info;
}

-  (void) checkWhetherNeedDownload:(CalleridUpdateInfo*)info {
    
    if ([info.fileId isEqualToString:nationId]) {
        NSString *localNationVersion = [self queryMainVersion:nationId];
        NSString *localNationUpVersion = [self queryMainVersion:nationUpId];
        if (localNationVersion && localNationVersion.length > 0 && ![localNationVersion isEqualToString:info.mainVersion]) {
            NSString *urlString = info.mainUrl;
            [self downloadDBFromUrl:urlString withDbid:nationId];
        }
        if (![info.updateVersion isEqualToString:@"-1"] && ![info.updateVersion isEqualToString:localNationUpVersion]) {
            NSString *urlString = info.updateUrl;
            [self downloadAndCreateDBFromUrl:urlString withDbid:nationUpId];
        }
    } else if ([info.fileId isEqualToString:tagId]) {
        NSString *localTagVersion = [self queryMainVersion:tagId];
        if (localTagVersion && localTagVersion.length > 0  && ![localTagVersion isEqualToString:info.mainVersion]) {
            NSString *urlString = info.mainUrl;
            [self downloadDBFromUrl:urlString withDbid:tagId];
        }
    }
}

- (void) downloadDBFromUrl:(NSString*)url withDbid:(NSString*)dbId {
    NSFileManager *fm= [NSFileManager defaultManager];
    NSString *filePath = [FileUtils getAbsoluteFilePath:[url lastPathComponent]];
    NSString *fileName = [FileUtils getAbsoluteFilePath:[NSString stringWithFormat:@"%@.db", dbId]];
    [LocalCallerUtil downloadFileFrom:url to:filePath withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self closeDB:dbId];
        [fm removeItemAtPath:fileName error:nil];
        [FileUtils unzipFile:filePath toFile:[filePath stringByDeletingPathExtension]];
        [fm removeItemAtPath:filePath error:nil];
        NSString *orgPath = [[filePath stringByDeletingPathExtension] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", dbId]];
        if ([fm copyItemAtPath:orgPath toPath:fileName error:nil])
            [fm removeItemAtPath:[filePath stringByDeletingPathExtension] error:nil];
        [self connectDataBase:dbId];
    } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        cootek_log(@"test:%@",error.description);
    }];
}

- (void) downloadAndCreateDBFromUrl:(NSString*)url withDbid:(NSString*)dbId {
    NSFileManager *fm= [NSFileManager defaultManager];
    NSString *filePath = [FileUtils getAbsoluteFilePath:[url lastPathComponent]];
    NSString *fileName = [FileUtils getAbsoluteFilePath:[NSString stringWithFormat:@"%@.db", dbId]];
    [LocalCallerUtil downloadFileFrom:url to:filePath withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self closeDB:dbId];
        [FileUtils unzipFile:filePath toFile:[filePath stringByDeletingPathExtension]];
        [fm removeItemAtPath:filePath error:nil];
        NSString *orgPath = [[filePath stringByDeletingPathExtension] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", dbId]];
        if ([fm fileExistsAtPath:fileName]) {
            [fm removeItemAtPath:fileName error:nil];
        }
        if ([fm copyItemAtPath:orgPath toPath:fileName error:nil])
            [fm removeItemAtPath:[filePath stringByDeletingPathExtension] error:nil];
        [self addUpdateDb];
    } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        cootek_log(@"test:%@",error.description);
    }];
}


@end
