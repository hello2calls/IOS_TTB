//
//  CommerciaSkinManager.h
//  TouchPalDialer
//
//  Created by wen on 16/9/7.
//
//

#import <Foundation/Foundation.h>
#import "TPSkinInfo.h"
@interface CommercialSkinManager : NSObject
#define SkinInfoUrlSource @"http://touchlife.cootekservice.com/native_index/show_skin_package?_token="


#define CommercialSkinExistPlist @"commercialSkinExist.Plist"



+ (void)asyncGetSkinInfo;
+ (NSDictionary *)getDicFromCommercialSkinPlist ;
+ (void)deleteCommercialSkinInfoWithSkinId:(NSString *)skinid;
+ (BOOL)checkSkinInPlistAndFileWithSkinID:(NSString *)skinID ;
+ (BOOL)checkIfCommercialSkinAndFileExistWithSkinID:(NSString *)skinID;
+ (NSDictionary *)getInAppInfoFromCommercialSkinExistPlistWithSkinID:(NSString *)skinID ;
+ (void)getAnySkinIDFromExtiPlistRightTimeAndUseIt;
+ (BOOL)checkLocalSkinShouldShowWithSkinID:(NSString *)skinID;
@end
