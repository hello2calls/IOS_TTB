//
//  SkinDataDownloadJob.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-13.
//
//

#import "NetworkDataDownloader.h"
#import "TPSkinInfo.h"

#define SKIN_DOWNLOAD_IDENTITY_PREFIX @"SKIN_"

@interface SkinDataDownloadJob : NetworkDownloaderJob

+ (NSString *)identityForSkin:(TPSkinInfo *)skinModel;

- (id)initWithSkin:(TPSkinInfo *)skinInfo;
@property (nonatomic, readonly, strong) TPSkinInfo *skin;

@end
