//
//  PersonalCenterUtility.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/12.
//
//

#import <Foundation/Foundation.h>
#import "NoahManager.h"

@interface PersonalCenterUtility : NSObject

+(UIImage *)getHeadViewUIImage ;
+(UIImage *)getHeadViewPhotoWithName:(NSString*)name ;
+ (NSInteger)getHeadViewPhotoIndex:(NSString*)name;
+ (NSString*)getHeadViewPhotoNameFromIndex:(NSInteger)index;
+ (NSArray*) getMarketInnerGifArray:(NSString*)dirName;
+ (UIImage*) getMarketBannerImage:(NSString*)dirName;
+ (NSArray*) getMarketOutterGifArray:(NSString*)dirName;
+ (ExtensionStaticToast*) getPersonalMarketExtensionStaticToast;

@end
