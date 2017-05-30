//
//  IndexJsonUtils.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-8.
//
//

@interface IndexJsonUtils : NSObject

+ (NSDictionary*) getDictoryFromLocalFile:(NSString*) fileName;
+ (NSString*) getStringFromNSDictionary:(NSDictionary*)dictionary;
+ (void) addClickHiddenInfo:(NSString*)key;
+ (void) hideClickHiddenInfo:(NSString*)key;
+ (void) saveJsonToFile:(NSString*)url;
+ (void) clearClickHiddenInfo;
+ (BOOL) shouldHideClickHiddenInfo:(NSString*)key;
+ (void)saveIndexFontToFile:(NSString*)url;
+ (void) getIndexFontFromLocalFile:(NSString*)fileName;
@end