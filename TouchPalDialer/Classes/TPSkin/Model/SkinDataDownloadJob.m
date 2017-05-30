//
//  SkinDataDownloadJob.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-13.
//
//

#import "SkinDataDownloadJob.h"
#import "TPDialerResourceManager.h"

@implementation SkinDataDownloadJob
@synthesize skin = skin_;

+ (NSString *)identityForSkin:(TPSkinInfo *)skinModel
{
    return [NSString stringWithFormat:@"%@%@", SKIN_DOWNLOAD_IDENTITY_PREFIX, skinModel.skinID];
}

- (id)initWithSkin:(TPSkinInfo *)skinInfo
{
    self = [super init];
    if(self) {
        self.downloadType = NetworkDataDownloaderSkin;
        skin_ = skinInfo;
        self.size = 0.0;
        self.url = skinInfo.resourceURL;
        self.targetPath = [[TPDialerResourceManager downloadSkinPath] stringByAppendingPathComponent:[skinInfo.resourceURL lastPathComponent]];
        self.identity = [SkinDataDownloadJob identityForSkin:skinInfo];
        if ([skinInfo.skinID rangeOfString:@".AD."].length > 0) {
            self.errorMessage = nil;
        } else {
            self.errorMessage = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Network connection failed for downloading package",@""),skinInfo.name];
        }
        
    }
    return self;
}


@end
