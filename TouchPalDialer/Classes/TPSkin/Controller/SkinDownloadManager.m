//
//  SkinDownloadManager.m
//  TouchPalDialer
//
//  Created by game3108 on 16/4/28.
//
//

#import "SkinDownloadManager.h"
#import "TPDialerResourceManager.h"
#import "WebSkinInfoProvider.h"
#import "TouchPalVersionInfo.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "NSString+TPHandleNil.h"
#import "TPDialerResourceManager.h"
#import "CommercialSkinManager.h"
@interface SkinDownloadManager(){
    DownloadBlock _downloadBlock;
}

@end

static SkinDownloadManager *instance = nil;

@implementation SkinDownloadManager
+ (void)initialize
{
    instance = [[SkinDownloadManager alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(skinDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(skinDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_FAIL
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(skinDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_PROGRESS
                                               object:nil];
}

+ (instancetype) sharedInstrance{
    return instance;
}

- (SkinDownloadType) getSkinDownloadTypeBySkinID:(NSString *)skinID{
    SkinDownloadType downloadType = SkinItemNotDownloaded;
    if ([[[TPDialerResourceManager sharedManager] skinTheme] isEqualToString:skinID]) {
        downloadType = SkinItemUsed;
    } else if ([[TPDialerResourceManager sharedManager] isSkinExisting:skinID]) {
        if ([[TPDialerResourceManager sharedManager] isSkinExpired:skinID]){
            downloadType = SkinItemNotDownloaded;
        } else {
            downloadType = SkinItemDownloaded;
        }
    } else {
        // not existing
        downloadType = SkinItemNotDownloaded;
    }
    return downloadType;
}

- (TPSkinInfo *) genereateSkinInfo:(NSDictionary *)dictionary{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *skinRootForDownload = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"Skin"];
    
    NSString *resource = [dictionary objectForKey:@"resource"];
    TPSkinInfo *skinInfo = [[TPSkinInfo alloc]init];
    
    skinInfo.isDefault      = false;
    skinInfo.isNew          = false;
    skinInfo.name           = [dictionary objectForKey:NSLocalizedString(@"theme_name_en_us", @"")];
    skinInfo.author         = NSLocalizedString(@"skin_author", @"触宝");
    skinInfo.skinID         = [dictionary objectForKey:@"id"];
    skinInfo.hasSound       = [[dictionary objectForKey:@"sound"] boolValue];
    skinInfo.version        = [[dictionary objectForKey:@"version"] intValue];
    skinInfo.isBuiltIn      = false;
    skinInfo.resourceURL    = [dictionary objectForKey:@"resourceURL"];
    skinInfo.skinDir        = [skinRootForDownload stringByAppendingPathComponent:resource];
    if (skinInfo.isBuiltIn) {
        skinInfo.previewPath = [WebSkinInfoProvider previewImagePathForBuiltinSkin:resource];
    } else {
        skinInfo.previewPath = [WebSkinInfoProvider previewImagePath:resource];
    }
    skinInfo.previewUrl     = [dictionary objectForKey:@"previewUrl"];
    [UserDefaultsManager setIntValue: [[NSDate date] timeIntervalSince1970] forKey:[NSString stringWithFormat:@"%@_time",skinInfo.skinID]];
    return skinInfo;
}

- (void) startSkinDownload:(TPSkinInfo *)skinInfo andStepBlock:(DownloadBlock)block{
    _downloadBlock = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:skinInfo.skinDir error:nil];
    
    
    SkinDataDownloadJob *job = [[SkinDataDownloadJob alloc] initWithSkin:skinInfo];
    NetworkDataDownloaderWrapper *downloader = [NetworkDataDownloadWrapperManager downloaderForJob:job];
    
    if(downloader.downloadStatus == NetworkDataDownloadNotStarted || downloader.downloadStatus == NetworkDataDownloadFailed) {
        downloader.downloadBlock = block;
        downloader.skinID = skinInfo.skinID;
        [downloader download];
    }else{
        if ( block != nil )
            block(0);
    }
}

- (void) useSkin:(NSString *)skinID{
    if ([NSString isNilOrEmpty:skinID]
        || ![skinID hasPrefix:SKIN_ID_PRFIX]) {
        return;
    }
    [[TPDialerResourceManager sharedManager] loadAllSkinInfoList];
    [TPDialerResourceManager sharedManager].skinTheme = skinID;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SKIN_SHOULD_CHANGE object:nil];
}

#pragma mark downloadstatus

- (void)skinDownloaderStatusChanged:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(skinDownloaderStatusChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    id sender = [notification object];
    if(![sender isKindOfClass:[NetworkDataDownloaderWrapper class]]) {
        return;
    }
    
    NetworkDataDownloaderWrapper *downloader = sender;
    if(downloader) {
        [self refreshDownloaderStatus:downloader];
    }
}

- (void)refreshDownloaderStatus:(NetworkDataDownloaderWrapper *)downloader{
    DownloadBlock block = downloader.downloadBlock;
    switch (downloader.downloadStatus) {
        case NetworkDataDownloadCompleted: {
            if ( block != nil ) {
                block(1);
                block = nil;
            }
            
            if ([downloader.skinID rangeOfString:@".AD."].length > 0) {
                if([CommercialSkinManager checkIfCommercialSkinAndFileExistWithSkinID:downloader.skinID]){
                     [self useSkin:downloader.skinID];
                    [UserDefaultsManager setBoolValue:YES forKey:[@"ifAutoShowSkin" stringByAppendingString:downloader.skinID]];

                }
            } else {
                [self useSkin:downloader.skinID];
            }
            break;
        }
        case NetworkDataDownloadNotStarted:
        case NetworkDataDownloadFailed: {
            if ( block != nil )
                block(0);
            break;
        }
        case NetworkDataDownloadStarting:
        case NetworkDataDownloadDownloading: {
            break;
        }
        default:
            break;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:instance];
}
@end
