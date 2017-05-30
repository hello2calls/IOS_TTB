//
//  IndexJsonUtils.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-8.
//
//

#import <Foundation/Foundation.h>
#import "IndexJsonUtils.h"
#import "IndexConstant.h"
#import "UserDefaultsManager.h"
#import "NetworkUtility.h"
#import "LocalStorage.h"
#import "CootekNotifications.h"
#import "UIDataManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
@import CoreText;

#define YP_HIDDEN_INFO_KEY    @"yp_hidden_info_key"

@implementation IndexJsonUtils

+ (NSDictionary*) getDictoryFromLocalFile:(NSString*)fileName
{
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* workPath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];
    NSString* indexFile = [NSString stringWithFormat:@"%@/%@", workPath, fileName];
    
    NSDictionary* dic = nil;
    @try {
        dic = [IndexJsonUtils getIndexDataFromFilePath:indexFile];
    }
    @catch (NSException *exception) {
        cootek_log(@"getDictoryFromLocalFile, exception= %@", exception);
    }
    @finally {
    }
    
    return dic;
}

+ (NSDictionary *)getIndexDataFromFilePath:(NSString *) filePath
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [file readDataToEndOfFile];
    if (data && data.length > 0) {
        NSError *error = nil;
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers| NSJSONReadingMutableLeaves error:&error];
        return dict;
    }
    return nil;
}

+ (void) saveJsonToFile:(NSString*)url
{
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* workPath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];
    NSString* localFilePath = [NSString stringWithFormat:@"%@/%@", workPath, INDEX_REQUEST_FILE];
    
    NSURL *urlRequest=[NSURL URLWithString:url];
    cootek_log(@"saveJsonToFile --> file : %@, url : %@", localFilePath, url);
    
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:10];
    NSString *last_modified_local = [UserDefaultsManager stringForKey:@"Last-Modified"];
    if (last_modified_local != nil) {
        [httpRequest setValue:last_modified_local forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    NSHTTPURLResponse *urlResponse = nil;
    NSData *fileData = [NetworkUtility sendSafeSynchronousRequest:httpRequest
                                                 returningResponse:&urlResponse
                                                             error:nil];
    if ([urlResponse statusCode] == 200 && fileData != nil) {
        NSError *error = nil;
        NSDictionary* dict =[NSJSONSerialization JSONObjectWithData:fileData options: NSJSONReadingMutableContainers| NSJSONReadingMutableLeaves error:&error];
        if (dict != nil) {
            if ([fileData writeToFile:localFilePath atomically:YES]) {
                NSDictionary *dictionary = [urlResponse allHeaderFields];
                NSString *last_modified = [dictionary objectForKey:@"Last-Modified"];
                if (last_modified != nil) {
                    [UserDefaultsManager setObject:last_modified forKey:@"Last-Modified"];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_JSON_REQUEST_SUCCESS object:nil userInfo:nil];
                });
                return;
            }
        } else {
            NSDictionary *dictionary = [urlResponse allHeaderFields];
            NSString *last_modified = [dictionary objectForKey:@"Last-Modified"];
            if (last_modified != nil) {
                [UserDefaultsManager setObject:last_modified forKey:@"Last-Modified"];
            }
        }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_JSON_REQUEST_FAILED object:nil userInfo:nil];
    });
}


+ (void) saveIndexFontToFile:(NSString*)url
{
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:INDEX_FONT_LOCAL_PATH];
    
    NSURL *urlRequest=[NSURL URLWithString:url];
    cootek_log(@"saveIndexFontToFile --> file : %@, url : %@", localFilePath, url);
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:INDEX_FONT_REQUEST_TIME_OUT_INTERVAL];
    NSString *last_modified_local = [UserDefaultsManager stringForKey:YP_FONT_MODIFY_KEY];
    if (last_modified_local != nil) {
        [httpRequest setValue:last_modified_local forHTTPHeaderField:@"If-Modified-Since"];
    }
    NSHTTPURLResponse *urlResponse = nil;
    NSData *fileData = [NetworkUtility sendSafeSynchronousRequest:httpRequest
                                                returningResponse:&urlResponse
                                                            error:nil];
    if ([urlResponse statusCode] == 200 && fileData != nil) {
        if ([fileData writeToFile:localFilePath atomically:YES]) {
            NSDictionary *dictionary = [urlResponse allHeaderFields];
            NSString *last_modified = [dictionary objectForKey:YP_FONT_MODIFY_KEY];
            if (last_modified != nil) {
                [UserDefaultsManager setObject:last_modified forKey:YP_FONT_MODIFY_KEY];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [UIDataManager instance].indexFontName = @"";
                [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_FONT_REQUEST_SUCCESS object:nil userInfo:nil];
            });
            return;
        } else {
            NSDictionary *dictionary = [urlResponse allHeaderFields];
            NSString *last_modified = [dictionary objectForKey:YP_FONT_MODIFY_KEY];
            if (last_modified != nil) {
                [UserDefaultsManager setObject:last_modified forKey:YP_FONT_MODIFY_KEY];
            }
        }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_FONT_REQUEST_FAILED object:nil userInfo:nil];
    });
}

+ (void) getIndexFontFromLocalFile:(NSString*)fileName
{
    if ([UIDataManager instance].indexFontName && [UIDataManager instance].indexFontName.length > 0) {
        return;
    }
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* workPath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];
    NSString* indexFontFile = [NSString stringWithFormat:@"%@/%@", workPath,fileName];
    
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:indexFontFile];
    NSData *data = [file readDataToEndOfFile];
    @try {
        if (data && data.length > 0) {
            NSData *inData = data;
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
            CGFontRef font = CGFontCreateWithDataProvider(provider);
            [UIDataManager instance].indexFontName = (NSString *)CFBridgingRelease(CGFontCopyPostScriptName(font));
            if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                if (errorDescription) {
                    CFRelease(errorDescription);
                }
            }
            if (font) {
                CFRelease(font);
            }
            if (provider) {
                CFRelease(provider);
            }
        } else {
            [UIDataManager instance].indexFontName = @"";
        }
    }
    @catch (NSException *exception) {
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PAGE_INDEX_FONT_FAIL_LOAD_FROM_FILE kvs:Pair(@"indexFont", @"loadFromFile"), Pair(@"fail", @"exception"),nil];
    }

    
    
}

+ (NSString*) getStringFromNSDictionary:(NSDictionary*)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return @"";
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

+ (void) addClickHiddenInfo:(NSString*)key
{
    NSDictionary* keyDictionary = (NSDictionary*)[UserDefaultsManager objectForKey:YP_HIDDEN_INFO_KEY];
    
    if ([keyDictionary objectForKey:key]) {
        return;
    }
    
    if (keyDictionary == nil) {
        keyDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"true", key, nil];
    } else {
        [keyDictionary setValue:@"true" forKey:key];
    }
    [UserDefaultsManager setObject:keyDictionary forKey:YP_HIDDEN_INFO_KEY];
}

+ (void) hideClickHiddenInfo:(NSString*)key
{
    NSDictionary* keyDictionary = (NSDictionary*)[UserDefaultsManager objectForKey:YP_HIDDEN_INFO_KEY];
    NSString* value = [keyDictionary objectForKey:key];
    
    if ([value boolValue]) {
        [keyDictionary setValue:@"false" forKey:key];
        [UserDefaultsManager setObject:keyDictionary forKey:YP_HIDDEN_INFO_KEY];
    }
}

+ (void) clearClickHiddenInfo
{
    [UserDefaultsManager setObject:nil forKey:YP_HIDDEN_INFO_KEY];
}

+ (BOOL) shouldHideClickHiddenInfo:(NSString*)key
{
    NSDictionary* keyDictionary = (NSDictionary*)[UserDefaultsManager objectForKey:YP_HIDDEN_INFO_KEY];
    NSString* value = [keyDictionary objectForKey:key];
    
    if (value && value.length > 0) {
        return [@"true" isEqualToString:value];
    }
    return NO;
}
@end
