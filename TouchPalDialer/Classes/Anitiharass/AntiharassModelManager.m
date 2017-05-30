//
//  AntiharassModelManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import "AntiharassModelManager.h"
#import "FileUtils.h"
#import "AntiharassInfo.h"
#import "AntiharassAdressbookUtil.h"
#import "UserDefaultsManager.h"
#import "AntiharassManager.h"
#import "AntiharassDB.h"
#import "CootekNotifications.h"
#import "DialerUsageRecord.h"

@interface AntiharassModelManager(){
    dispatch_queue_t antiharassQueue;
    
    AntiharassDB *_antiDB;
    AntiharassModelStep _lastStep;
    
    BOOL _isBgRefreshing;
}

@end

static int specificKey = 0;

@implementation AntiharassModelManager
- (instancetype)init{
    self = [super init];
    if ( self ){
        antiharassQueue = dispatch_queue_create("com.touchpal.dialer.antiharass", NULL);
        CFStringRef specificValue = CFSTR("com.touchpal.dialer.antiharass");
        dispatch_queue_set_specific(antiharassQueue, &specificKey, (void*)specificValue, NULL);
        _isBgRefreshing = NO;
        
    }
    return self;
}

- (void) doTask:(AntiharassModelStep)step{
    switch (step) {
        case ANTIHARASS_NEW_BUILD_UPDATE_STEP:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [self checkUpdate:step];
            });
            break;
        }
        case ANTIHARASS_NEW_BUILD_DOWNLOAD_STEP:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [self downloadDB];
            });
            break;
        }
        case ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK:
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [_delegate refreshLoadingViewStage:step];
                    [self removeAntiharassAddressbook:step];
                
                
            });
            break;
        }
        case ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK_IN_BACKGROUND:
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [self removeAntiharassAddressbook:step];

            });
            break;
        }
        case ANTIHARASS_NEW_BUILD_BUILD_ADDRESSBOOK:
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [_delegate refreshLoadingViewStage:step];
                
                [self buildAntiharassAddressbook];
            });
            break;
        }
        case ANTIHARASS_NEW_BUILD_BUILD_ADDRESSBOOK_IN_BACKGROUND:
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
             [self buildAntiharassAddressbook];
            });
            break;
        }
        case ANTIHARASS_REMOVE_ADDRESSBOOK:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [self removeAntiharassAddressbook:step];
            });
            break;
        }
        case ANTIHARASS_START_UPDATE:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [self checkUpdate:step];
            });
            break;
        }
        case   ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _lastStep = step;
                [self checkUpdate:step];
            });
            break;
        }
        case ANTIHARASS_UPDATE_IN_BACKGROUND:{
            if ( !_isBgRefreshing ){
                _isBgRefreshing = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self checkUpdate:step];
                });
                break;
            }
        }
        default:
            break;
    }
}

- (void) setLastTask:(AntiharassModelStep)step{
    _lastStep = step;
}

- (void) doLastTask{
    [self doTask:_lastStep];
}

- (void) checkUpdate:(AntiharassModelStep)step{
    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_CACHE_DOWNLOAD_FAILD];
    NSString *urlString = [ANTIHARASS_FILE_PATH stringByAppendingString:[AntiharassUtil getVersionFileName]];
    [AntiharassUtil downloadFileFrom:urlString to:[FileUtils getAbsoluteFilePath:[AntiharassUtil getVersionFileName]] withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        cootek_log(@"antiharass: download update file success");
        [self readVersionFile:step];
        if (step==ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil userInfo:nil];
        }
    } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        cootek_log(@"antiharass: download update cache file failed : %@",[error description]);
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NETWORK_ERROR_TYPE, @"check_update_err"), nil];
        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_CACHE_DOWNLOAD_FAILD];
        NSString *directUrlString = [ANTIHARASS_DIRECT_FILE_PATH stringByAppendingString:[AntiharassUtil getVersionFileName]];
        [AntiharassUtil downloadFileFrom:directUrlString to:[FileUtils getAbsoluteFilePath:[AntiharassUtil getVersionFileName]] withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            cootek_log(@"antiharass: download update direct file success");
            [self readVersionFile:step];
            if (step==ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND) {
                [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil userInfo:nil];
            }
        } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            cootek_log(@"antiharass: download update direct file failed : %@",[error description]);
            if ( step == ANTIHARASS_UPDATE_IN_BACKGROUND ){
                _isBgRefreshing = NO;
            }else{
                [_delegate doModelResult:ANTIHARASS_NETWORK_ERROR];
            }
        }];
    }
     ];
}


- (void) readVersionFile:(AntiharassModelStep)step{
    NSString *versionFile = [FileUtils getAbsoluteFilePath:[AntiharassUtil getVersionFileName]];
    NSData *data = [NSData dataWithContentsOfFile:versionFile];
    NSString *responseString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ( responseString.length != 8 ){
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NETWORK_ERROR_TYPE, @"version_lenth_err"), nil];
        [_delegate doModelResult:ANTIHARASS_NETWORK_ERROR];
        return;
    }
    NSString *urlVersion = [[responseString componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    [self checkWhetherNeedUpdate:urlVersion andStep:step];
}

- (void) checkWhetherNeedUpdate:(NSString *)urlVersion andStep:(AntiharassModelStep)step{
    NSString *dbVersion = (NSString *)[UserDefaultsManager objectForKey:ANTIHARASS_VERSION];
    if ( urlVersion.length == 8 ){
        [UserDefaultsManager setObject:urlVersion forKey:ANTIHARASS_REMOTE_VERSION];
    }
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOW_DOT];
    switch (step) {
        case ANTIHARASS_UPDATE_IN_DIALERVC:
        case ANTIHARASS_NEW_BUILD_UPDATE_STEP:{
            if ( ![dbVersion isEqualToString:urlVersion] && [urlVersion integerValue] > [dbVersion integerValue] ){
                if (step != ANTIHARASS_UPDATE_IN_DIALERVC) {
                     [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
                }else{
                    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON]) {
                        [_delegate doModelResult:ANTIHARASS_NEW_VERSION_NEED_UPDATE];
                    }
                    else{
                    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
                        
                    [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW object:nil userInfo:nil];
                    }
                }
               
            }else{
                if(step != ANTIHARASS_UPDATE_IN_DIALERVC){
                if ( [self ifDBFileExist] ){
                    if ( [AntiharassUtil ifDBTypeChanged] )
                        [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
                    else
                        [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NOT_NEED_UPDATE];
                }else{
                    [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
                }
                }
            }
            break;
        }
        case ANTIHARASS_START_UPDATE:{
            if ( ![dbVersion isEqualToString:urlVersion] && [urlVersion integerValue] > [dbVersion integerValue]  ){
                [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
            }else{
                if ( [AntiharassUtil ifDBTypeChanged] )
                    [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
                else
                    [_delegate doModelResult:ANTIHARASS_VERSION_IS_NEWEST];
            }
            break;
        }
        case ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND:{
            if ( ![dbVersion isEqualToString:urlVersion] && [urlVersion integerValue] > [dbVersion integerValue]  ){
                [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
            }else{
                if ( [AntiharassUtil ifDBTypeChanged] )
                    [_delegate doModelResult:ANTIHARASS_NEW_BUILD_NEED_UPDATE];
                else
                    [_delegate doModelResult:ANTIHARASS_VERSION_IS_NEWEST];
            }
            
            break;
        }

        case ANTIHARASS_UPDATE_IN_BACKGROUND:{
            if ( ![dbVersion isEqualToString:urlVersion] && [urlVersion integerValue] > [dbVersion integerValue]  ){
                [_delegate doModelResult:ANTIHARASS_NEW_VERSION_NEED_UPDATE];
            }else{
                if ( ![AntiharassUtil ifDBTypeChanged] )
                    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOW_DOT];
            }
            _isBgRefreshing = NO;
            break;
        }
        default:
            break;
    }
}

- (BOOL) ifDBFileExist{
    AntiharassType type = [UserDefaultsManager intValueForKey:ANTIHARASS_TYPE defaultValue:0];
    if ( type == 0 )
        return NO;
    NSString *dbName = [AntiharassUtil getDBName:type];
    NSString *filePATH = [FileUtils getAbsoluteFilePath:dbName];
    NSFileManager *fm= [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePATH])
        return NO;
    return YES;
}


- (BOOL) initAntiDB{
    if ( ![self ifDBFileExist] )
        return NO;
    AntiharassType type = [UserDefaultsManager intValueForKey:ANTIHARASS_TYPE defaultValue:0];
    NSString *dbName = [AntiharassUtil getDBName:type];
    NSString *filePATH = [FileUtils getAbsoluteFilePath:dbName];
    _antiDB = [[AntiharassDB alloc]initWithDBFile:filePATH];
    return YES;
}


- (void) connectAntiDB{
    if ( ![_antiDB isConnectAlive] && [_antiDB isClosed] )
        [_antiDB connectDataBase];
}

- (void) closeAntiDB{
    if ( _antiDB )
        [_antiDB close];
    
}

- (void) buildAntiharassAddressbook{
    if ( ![self initAntiDB] ){
        [_delegate doModelResult:ANTIHARASS_FAILED];
        return;
    }
    [self connectAntiDB];
    __block NSArray *array = nil;
    dispatch_sync(antiharassQueue, ^{
        array = [_antiDB queryAllAntiharassInfo];
    });
    BOOL ifError = NO;
    
    int numbersPerContact = 1000; // harass phone numbers per contact
    int number = array.count / numbersPerContact + (array.count % numbersPerContact == 0 ? 0: 1);
    for ( int i = 0 ; i < number ; i ++ ){
        NSRange range = NSMakeRange(i * numbersPerContact,
                                    ((i+1)>=number)? array.count - i * numbersPerContact : numbersPerContact );
        NSArray *subArray = [array subarrayWithRange:range];
        BOOL success = [AntiharassAdressbookUtil addAntiharassToAddressbook:subArray andIndex:i];
        if ( !success ){
            ifError = YES;
            break;
        }
        [_delegate refreshLoadingViewPercent:(i+1) * 100 / number];
    }
    
    NSString *version = [self queryDBVersion];
    [self closeAntiDB];
    if ( !ifError ){
        NSString *remoteVersion = [UserDefaultsManager stringForKey:ANTIHARASS_REMOTE_VERSION defaultValue:@""];
        if ( [version isEqualToString:remoteVersion] ){
            [UserDefaultsManager setObject:version forKey:ANTIHARASS_VERSION];
        }
        else{
            if ( remoteVersion.length == 8 ){
                [UserDefaultsManager setObject:remoteVersion forKey:ANTIHARASS_VERSION];

            }
            else{
                [UserDefaultsManager setObject:version forKey:ANTIHARASS_VERSION];

            }
        }
        [_delegate doModelResult:ANTIHARASS_BUILD_SUCCESS];
    }else{
        [_delegate doModelResult:ANTIHARASS_FAILED];
    }
}

- (void) removeAntiharassAddressbook:(AntiharassModelStep)step{
    BOOL finish = [AntiharassAdressbookUtil removeAntiharassAddressbook];
    if ( finish ){
        if ( step == ANTIHARASS_REMOVE_ADDRESSBOOK ){
            [_delegate doModelResult:ANTIHARASS_REMOVE_SUCCESS];
        }else if ( step == ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK ){
            [_delegate doModelResult:ANTIHARASS_NEW_BUILD_REMOVE];
        }
    }else{
        [_delegate doModelResult:ANTIHARASS_FAILED];
    }
}

- (NSString *)queryDBVersion{
    if ( _antiDB ){
        __block NSString *version;
        dispatch_sync(antiharassQueue, ^{
            version = [_antiDB queryVersion:@"main_version"];
        });
        return version;
    }
    
    return nil;
}

- (void) downloadDB{
    NSFileManager *fm= [NSFileManager defaultManager];
    AntiharassType type = [UserDefaultsManager intValueForKey:ANTIHARASS_TYPE defaultValue:0];
    if ( type == 0 ){
        [_delegate doModelResult:ANTIHARASS_FAILED];
        return;
    }
    NSString *dbZipName = [AntiharassUtil getZipName:type];
    NSString *dbName = [AntiharassUtil getDBName:type];
    NSString *urlString = [[UserDefaultsManager boolValueForKey:ANTIHARASS_CACHE_DOWNLOAD_FAILD]?ANTIHARASS_DIRECT_FILE_PATH:ANTIHARASS_FILE_PATH stringByAppendingString:dbZipName];;
    NSString *filePath = [FileUtils getAbsoluteFilePath:dbZipName];
    NSString *fileName = [FileUtils getAbsoluteFilePath:dbName];
    
    [AntiharassUtil downloadFileFrom:urlString to:filePath withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        cootek_log(@"antiharass: download db file success");
        [self closeAntiDB];
        if ( [fm fileExistsAtPath:fileName] ){
            [fm removeItemAtPath:fileName error:nil];
        }
        [FileUtils unzipFile:filePath toFile:[filePath stringByDeletingPathExtension]];
        [fm removeItemAtPath:filePath error:nil];
        NSString *orgPath = [[filePath stringByDeletingPathExtension] stringByAppendingPathComponent:dbName];
        if ([fm copyItemAtPath:orgPath toPath:fileName error:nil])
            [fm removeItemAtPath:[filePath stringByDeletingPathExtension] error:nil];
        if ( ![fm fileExistsAtPath:fileName] ){
            cootek_log(@"download file error!");
            [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NETWORK_ERROR_TYPE, @"file_not_exist_err)"), nil];
            [_delegate doModelResult:ANTIHARASS_NETWORK_ERROR];
        }else{
            [_delegate doModelResult:ANTIHARASS_DOWNLOAD_SUCCESS];
        }
    } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        cootek_log(@"antiharass: download db file failed : %@",[error description]);
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NETWORK_ERROR_TYPE, @"download_db_err"), nil];
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NETWORK_ERROR_CODE, @(operation.response.statusCode)), nil];
        [_delegate doModelResult:ANTIHARASS_NETWORK_ERROR];
    }];
    
}

@end
