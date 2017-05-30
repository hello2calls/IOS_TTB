//
//  NSObject+WebSkinInfoProvider.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 1/6/13.
//
//

#import <Foundation/Foundation.h>

@interface WebSkinInfoProvider : NSObject

// a synchronous method, you call this method in background
+ (NSArray *)onlineSkinInfos;

+ (NSString *)skinRootUrl;
+ (NSString *)previewImageUrl:(NSString *)skinShortName;
+ (NSString *)previewImagePath:(NSString *)skinShortName;
+ (NSString *)previewImagePathForBuiltinSkin:(NSString *)skinShortName;
+ (NSData *) downloadPreviewImageByUrl:(NSURL *) url;
+ (NSData *) downloadPreviewImageByString:(NSString *) urlPath;
+ (NSInteger) calculatePriorityByBuiltIn:(BOOL) isBuiltIn hasSound:(BOOL) hasSound isNew:(BOOL) isNew;
+ (void) sortSkinList:(NSMutableArray *) skinInfoList;
+ (void) sortSkinByTime:(NSMutableArray *)skinInfoList;

+ (void)clearCachedOnlineSkinInfos;
@end
