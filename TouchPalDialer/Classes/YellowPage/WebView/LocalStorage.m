//
//  LocalStorage.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-10.
//
//

#import <Foundation/Foundation.h>
#import "LocalStorage.h"
#import "UserDefaultsManager.h"
#import "UIDataManager.h"
#import "NSStack.h"
#import "FunctionUtility.h"
#import "FLWebViewProvider.h"
#import "TPVoipPrivilegeADView.h"

#define LOCALSTORAGE_KEY_PREFIX @"yp_storage_"
#define SYNC_JS_STORAGE @"sync_js_storage"

#define STORAGE_ITEM_ACTION @"action"
#define STORAGE_ITEM_KEY @"value"

#define STORAGE_ACTION_UPDATE @"update"
#define STORAGE_ACTION_REMOVE @"remove"

@implementation LocalStorage

+ (id) getItemWithKey:(NSString*)key
{
    NSString* mappingKey = [LocalStorage getMappingKeyFromKey:key];
    if([QUERY_PARAM_LATITUDE isEqualToString:mappingKey]) {
        NSString* location = (NSString*)[UserDefaultsManager objectForKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, @"native_param_location"]];
        NSArray *stringArray = [location componentsSeparatedByString: @","];
        if(stringArray != nil && stringArray.count > 0) {
            NSArray *arrays = [stringArray[0] componentsSeparatedByString:@"["];
            if(arrays != nil && arrays.count > 1) {
               return arrays[1];
            }
        }
        return @"";
    } else if([QUERY_PARAM_LONGITUDE isEqualToString:mappingKey]) {
        NSString* location = (NSString*)[UserDefaultsManager objectForKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, @"native_param_location"]];
        NSArray *stringArray = [location componentsSeparatedByString: @","];
        if(stringArray != nil && stringArray.count > 1) {
            NSArray *arrays = [stringArray[1] componentsSeparatedByString:@"]"];
            if(arrays != nil && arrays.count > 0) {
                return arrays[0];
            }
        }
        return @"";
    }
    NSString* city = (NSString*)[UserDefaultsManager objectForKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, mappingKey]];
    return city ? city : @"";
}

+ (void) setItemForKey:(NSString*)key andValue:(NSString*)value
{
    NSString* mappingKey = [LocalStorage getMappingKeyFromKey:key];
   
    @try {

        //h5 storage
        if([UIDataManager instance].stackWebview.count > 0) {
            UIView<FLWebViewProvider>* webview = [[UIDataManager instance].stackWebview top];
            if (webview && [webview getDelegateViews]) {
                [FunctionUtility executeJavaScript:webview withScript:[NSString stringWithFormat:@"setItemToStorage('%@','%@');", mappingKey, value == nil ? @"":value]];
            }
        }
        

    }
    @catch (NSException *exception) {
        cootek_log(@"crash log --> %@ : %@",exception.name, exception.reason);
    }
    @finally {
        [LocalStorage setItemForKeyFromWeb:mappingKey andValue:value];
    }
}

+ (void) setItemForKeyFromWeb:(NSString *)key andValue:(NSString *)value
{
    
    NSMutableDictionary* storageDic = (NSMutableDictionary*)[self getToJsStorage];
    if(!storageDic) {
        storageDic = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary* storageValue = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:value, STORAGE_ACTION_UPDATE, nil] forKeys:[NSArray arrayWithObjects:STORAGE_ITEM_KEY, STORAGE_ITEM_ACTION, nil]];
    
    [storageDic setObject:storageValue forKey:key];
    [UserDefaultsManager setObject:storageDic forKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, SYNC_JS_STORAGE]];
    
    //native
    [UserDefaultsManager setObject:value forKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, key]];
}

+ (void) removeKey:(NSString*)key
{
    @try {
        //h5 storage
        if([UIDataManager instance].stackWebview.count > 0) {
            NSString* mappingKey = [LocalStorage getMappingKeyFromKey:key];
            [FunctionUtility executeJavaScript:[[UIDataManager instance].stackWebview top]  withScript:[NSString stringWithFormat:@"removeItemFromStorage('%@');", mappingKey]];
        }
    }
    @catch (NSException *exception) {
        cootek_log(@"crash log --> %@ : %@",exception.name, exception.reason);
    }
    @finally {
        [LocalStorage removeKeyFromWeb:key];
    }
}


+ (void) removeKeyFromWeb:(NSString*)key
{
    NSString* mappingKey = [LocalStorage getMappingKeyFromKey:key];
    
    NSDictionary* storageDic = [self getToJsStorage];
    NSDictionary* storageValue = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:STORAGE_ACTION_UPDATE, nil] forKeys:[NSArray arrayWithObjects:STORAGE_ITEM_ACTION, nil]];
    
    [storageDic setValue:storageValue forKey:mappingKey];
    [UserDefaultsManager setObject:storageDic forKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, SYNC_JS_STORAGE]];

    
    [UserDefaultsManager removeObjectForKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, mappingKey]];
}

+ (NSMutableDictionary*) getToJsStorage
{
    return (NSMutableDictionary*)[UserDefaultsManager objectForKey:[NSString stringWithFormat:@"%@%@", LOCALSTORAGE_KEY_PREFIX, SYNC_JS_STORAGE]];
}
    
+ (void) nativeItemToStorage:(UIView<FLWebViewProvider>*)webview
{
    NSDictionary* jsStorage = [self getToJsStorage];
    
    for (NSString* keyValue in [jsStorage allKeys]) {
        NSDictionary* item = [jsStorage objectForKey:keyValue];
        if ([STORAGE_ACTION_REMOVE isEqualToString:[item objectForKey:STORAGE_ITEM_ACTION]]) {
             [FunctionUtility executeJavaScript:webview withScript:[NSString stringWithFormat:@"removeItemFromStorage('%@');", keyValue]];
        } if ([STORAGE_ACTION_UPDATE isEqualToString:[item objectForKey:STORAGE_ITEM_ACTION]]) {
            NSString* value = [item objectForKey:STORAGE_ITEM_KEY];
            [FunctionUtility executeJavaScript:webview withScript:[NSString stringWithFormat:@"setItemToStorage('%@', '%@');",keyValue,value == nil ? @"":value]];
            if ([keyValue isEqualToString:VOIP_VIP_AD]) {
                cootek_log(@"LocalStorage, key: %@, value: %@", keyValue, value);
                value = value == nil ? @"": value;
                value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
                [FunctionUtility executeJavaScript:webview withScript:[NSString stringWithFormat:@"localStorage.setItem('%@','%@');", keyValue, value]];
            }
        }
    }
}

+ (NSString*) getMappingKeyFromKey:(NSString*)key
{
    NSString* ret = key;
    if([QUERY_PARAM_CITY isEqualToString:key]) {
        ret = @"city";
    } else if([QUERY_PARAM_LOC_CITY isEqualToString:key]) {
        ret = @"loc_city";
    }

    return ret;
}

@end
