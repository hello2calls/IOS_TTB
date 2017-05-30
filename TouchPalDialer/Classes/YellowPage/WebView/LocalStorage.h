//
//  LocalStorage.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-10.
//
//

#ifndef TouchPalDialer_LocalStorage_h
#define TouchPalDialer_LocalStorage_h

#import "FLWebViewProvider.h"

//READ ONLY
#define QUERY_PARAM_CITY @"_city"              //"上海"
#define QUERY_PARAM_LOC_CITY @"_loc_city"      //"上海"
#define QUERY_PARAM_LATITUDE @"_lat"           //"121.3249"
#define QUERY_PARAM_LONGITUDE @"_lng"          //"31.34283"

//location for
#define QUERY_LAST_PARAM_CITY @"_city_last"
#define QUERY_LAST_CACHE_TIME_CITY @"_city_last_cache_time"

//backdoor for test
#define YP_BACKDOOR_LOCATION @"yp_backdoor_location"

@interface LocalStorage : NSObject

+ (id) getItemWithKey:(NSString*)key;

+ (void) setItemForKey:(NSString*)key andValue:(NSString*)value;

+ (void) setItemForKeyFromWeb:(NSString*)key andValue:(NSString*)value;

+ (void) removeKey:(NSString*)key;

+ (void) removeKeyFromWeb:(NSString*)key;

+ (NSDictionary*) getToJsStorage;

+ (void) nativeItemToStorage:(UIView<FLWebViewProvider>*)webview;
@end

#endif


