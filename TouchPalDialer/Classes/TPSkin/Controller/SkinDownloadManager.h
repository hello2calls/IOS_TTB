//
//  SkinDownloadManager.h
//  TouchPalDialer
//
//  Created by game3108 on 16/4/28.
//
//

#import <Foundation/Foundation.h>
#import "TPSkinInfo.h"
#import "SkinDataDownloadJob.h"

typedef NS_ENUM(NSUInteger, SkinDownloadType) {
    SkinItemNotDownloaded = 0,
    SkinItemDownloaded = 1,
    SkinItemUsed = 2,
};

@interface SkinDownloadManager : NSObject
+ (instancetype) sharedInstrance;
- (SkinDownloadType) getSkinDownloadTypeBySkinID:(NSString *)skinID;
- (TPSkinInfo *) genereateSkinInfo:(NSDictionary *)dictionary;
- (void) startSkinDownload:(TPSkinInfo *)skinInfo andStepBlock:(DownloadBlock)block;
- (void) useSkin:(NSString *)skinID;
@end
