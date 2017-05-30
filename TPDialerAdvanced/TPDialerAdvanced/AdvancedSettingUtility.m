//
//  AdvancedSettingUtility.m
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-15.
//
//

#import "Util.h"
#import "AdvancedSettingUtility.h"

#define FILE_PATH_APPLICATIONS      @"/private/var/mobile/Applications"
#define FILE_PATH_TOUCHPALDIALER    @"TouchPalDialer.app"
#define FILE_PATH_DOCUMENTS         @"Documents"
#define FILE_PATH_NUMBER_ATTR       @"numberAttr.img"
#define FILE_PATH_MAIN_DATABASE     @"data.sqlite"
#define FILE_PATH_SEATTLE_DATABASE  @"seattle.sqlite"
#define FILE_PATH_CITY_DATA         @"cityData"
#define FILE_PATH_ADVANCED_SETTING  @"advancedSetting.plist"

#define ADVANCED_PREFIX @"ADVANCED_SETTING_PREFIX"

@implementation AdvancedSettingUtility

static NSString* appPath;

+(NSString*) dialerAppPath
{
    @synchronized (self) {
        NSFileManager* fm = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if(appPath != nil && [fm fileExistsAtPath:appPath isDirectory:&isDir]) {
            if(isDir) {
                return appPath;
            } else {
                appPath = nil;
            }
        } else {
            appPath = nil;
        }
        
        //search for folder
        NSString *rootDir = FILE_PATH_APPLICATIONS;
        NSArray *dirs = [fm contentsOfDirectoryAtPath:rootDir error:nil];
        
        for(NSString* str in dirs) {
            NSString* temp = [NSString stringWithFormat:@"%@/%@/%@", rootDir, str, FILE_PATH_TOUCHPALDIALER];
            cootek_log(@"check for %@", temp);
            if ([fm fileExistsAtPath:temp]) {
                appPath = [[NSString stringWithFormat:@"%@/%@", rootDir, str] retain];
                break;
            }
        }
        
        return appPath;
    }
}

+(NSString*) dialerDocumentPath {
   return [NSString stringWithFormat:@"%@/%@", [self dialerAppPath], FILE_PATH_DOCUMENTS];
}

+(NSString*) dialerApplicationPath {
    return [NSString stringWithFormat:@"%@/%@", [self dialerAppPath], FILE_PATH_TOUCHPALDIALER];
}

+(NSString*) numberAttributePath {
    return [NSString stringWithFormat:@"%@/%@", [self dialerApplicationPath], FILE_PATH_NUMBER_ATTR];
}

+(NSString*) mainDatabasePath {
    return [NSString stringWithFormat:@"%@/%@", [self dialerDocumentPath], FILE_PATH_MAIN_DATABASE];
}

+(NSString*) seattleDatabasePath {
    return [NSString stringWithFormat:@"%@/%@", [self dialerDocumentPath], FILE_PATH_SEATTLE_DATABASE];
}

+(NSString*) cityDataFolderPath {
    return [NSString stringWithFormat:@"%@/%@", [self dialerDocumentPath], FILE_PATH_CITY_DATA];
}

+(NSString*) advancedSettingPath {
    return [NSString stringWithFormat:@"%@/%@", [self dialerDocumentPath], FILE_PATH_ADVANCED_SETTING];
}

+(id) querySetting:(NSString*) key {
    cootek_log_function;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString* settingPath = [self advancedSettingPath];
    NSDictionary* dict;
    if([manager fileExistsAtPath:settingPath] && [manager isReadableFileAtPath:settingPath]) {
        dict = [NSDictionary dictionaryWithContentsOfFile:settingPath];
        return [dict objectForKey:key];
    }
    
    return nil;
}

+(id) queryAdvancedSetting:(NSString*) key {
    return [self querySetting:[NSString stringWithFormat:@"%@_%@", ADVANCED_PREFIX, key]];
}

+(void) setSetting:(NSString*) key
             value:(NSString*) value {
    cootek_log_function;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString* settingPath = [self advancedSettingPath];
    NSDictionary* dict;
    if([manager fileExistsAtPath:settingPath] && [manager isReadableFileAtPath:settingPath]) {
        dict = [NSDictionary dictionaryWithContentsOfFile:settingPath];
        [dict setValue:value forKey:key];
        [dict writeToFile:settingPath atomically:YES];
    }
}

+(void) setAdvancedSetting:(NSString*) key
                     value:(NSString*) value {
    [self setSetting:[NSString stringWithFormat:@"%@_%@", ADVANCED_PREFIX, key]
               value:value];
}


@end
