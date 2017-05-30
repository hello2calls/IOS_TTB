//
//  NSObject+WebSkinInfoProvider.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 1/6/13.
//
//

#import "WebSkinInfoProvider.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "NetworkUtility.h"
#import "CooTekServerDef.h"
#import "TouchPalVersionInfo.h"
#import "TPSkinInfo.h"
#import "UserDefaultsManager.h"

#define SKIN_ARRAY @"skinArray"
#define SKINS_INFO_XML @"skinsInfo.xml"
#define SKINS_INFO_PLIST @"skinsInfo.plist"

static NSArray __strong *cachedOnlineSkinInfos = nil;
static NSDate __strong *cachedDate = nil;

@implementation WebSkinInfoProvider

+(NSString *)skinRootUrl
{
    BOOL isUsingTestEnvironment = NO;
    NSString *host;
    if (isUsingTestEnvironment) {
        host = COOTEK_STATIC_SERVICE_HOST_TEST;
    } else {
        host = COOTEK_STATIC_SERVICE_HOST;
    }
    NSString *urlSkinRoot = [NSString stringWithFormat:@"http://%@/iphone/default/skin/v%@",
                             host, VERSION_FOR_DOWNLOAD_SKIN];//
    
    // for skin debugging
    if (ENABLE_SKIN_DEBUG) {
        urlSkinRoot = [NSString stringWithFormat:@"http://%@/iphone/default/skin/v%@", host, @"9999"];
    }
    return urlSkinRoot;
}

+ (void)clearCachedOnlineSkinInfos
{
    @synchronized(self) {
        cachedOnlineSkinInfos = nil;
        cachedDate = nil;
    }
}

+ (NSArray *)onlineSkinInfos
{
    @synchronized(self) {
        if (cachedOnlineSkinInfos == nil || [[NSDate date] timeIntervalSinceDate:cachedDate] > 1 * 3600) {
            [self clearCachedOnlineSkinInfos];
        } else {
            return [NSArray arrayWithArray:cachedOnlineSkinInfos];
        }
    }
    
    NSDictionary *skinsInfo = [self loadSkinInfoFromWeb];
    if (skinsInfo == nil) {
        return [NSArray array];
    }
    NSArray *skins = [skinsInfo objectForKey:SKIN_ARRAY];
    
    NSMutableArray *tmpOnlineSkinInfos = [[NSMutableArray alloc] initWithCapacity:skins.count];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *skinRootForDownload = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"Skin"];
    
    for (NSDictionary *skin in skins) {
        NSString *resourceString = [skin objectForKey:@"resourceURL"];
        NSString *skinDirLastPath = [resourceString substringToIndex:[resourceString rangeOfString:@".zip"].location];
        
        TPSkinInfo *skinInfo = [[TPSkinInfo alloc] init];
        NSString *iconFullName = [NSString stringWithFormat:@"%@_%@%@", SKIN_ICON_IMAGE_PREFIX, skinDirLastPath, @"@2x.png"];
        NSString *skinUrl = [NSString stringWithFormat:@"%@/%@/%@",
                [WebSkinInfoProvider skinRootUrl], ONLINE_ICONS_FOLDER, iconFullName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:skinUrl]
                                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                 timeoutInterval:10];
        NSData *iconData = [NetworkUtility sendSafeSynchronousRequest:request
                                                    returningResponse:nil
                                                                error:nil];
        skinInfo.skinIcon = [UIImage imageWithData:iconData];
        if (skinInfo.skinIcon == nil) {
            return [NSArray array];
        }
        
        skinInfo.isDefault = [[skin objectForKey:@"default"] boolValue];
        skinInfo.isNew = [[skin objectForKey:@"new"] boolValue];
        skinInfo.name = [skin objectForKey:NSLocalizedString(@"theme_name_en_us", @"")];
        skinInfo.author = [skin objectForKey:NSLocalizedString(@"author_name_en_us", @"")] ;
        skinInfo.skinID = [skin objectForKey:@"id"];
        skinInfo.hasSound = [[skin objectForKey:@"sound"] boolValue];
        skinInfo.version = [[skin objectForKey:@"version"] intValue];
        skinInfo.isBuiltIn = [[skin objectForKey:@"builtIn"] boolValue];
        skinInfo.resourceURL = [[WebSkinInfoProvider skinRootUrl] stringByAppendingPathComponent:[skin objectForKey:@"resourceURL"]];
        
        skinInfo.skinDir = [skinRootForDownload stringByAppendingPathComponent:skinDirLastPath];
        //[self saveSkinIconImageWithData:iconData filePath:[NSString stringWithFormat:@"%@/%@/%@", skinInfo.skinDir, IMAGE_DIR, iconFullName]];
         
        //setting preview image's path and url
        if (skinInfo.isBuiltIn) {
            skinInfo.previewPath = [WebSkinInfoProvider previewImagePathForBuiltinSkin:skinDirLastPath];
        } else {
            skinInfo.previewPath = [WebSkinInfoProvider previewImagePath:skinDirLastPath];
        }
        skinInfo.previewUrl = nil;
        if (!skinInfo.isBuiltIn && skinDirLastPath) {
            skinInfo.previewUrl = [WebSkinInfoProvider previewImageUrl:skinDirLastPath];
        } 
        if (ENABLE_SKIN_DEBUG) {
            cootek_log(@"TPSkinInfo, previewUrl: %@, skinDir: %@, dirLastPath: %@, previewPath: %@",
                       skinInfo.previewUrl, skinInfo.skinDir, skinDirLastPath, skinInfo.previewPath);
        }
        if (ENABLE_SKIN_DEBUG) {
            if (arc4random() % 3 == 0) {
                skinInfo.isNew = YES;
            }
        }
        if (skinInfo.isNew) {
            [tmpOnlineSkinInfos insertObject:skinInfo atIndex:0];
        } else {
            [tmpOnlineSkinInfos addObject:skinInfo];
        }
        skinInfo.priority = [WebSkinInfoProvider calculatePriorityByBuiltIn:skinInfo.isBuiltIn
                 hasSound:skinInfo.hasSound isNew:skinInfo.isNew];
    }
    [WebSkinInfoProvider sortSkinList:tmpOnlineSkinInfos];
    if ([tmpOnlineSkinInfos count] != 0) {
        @synchronized(self) {
            cachedOnlineSkinInfos = [[NSArray alloc] initWithArray:tmpOnlineSkinInfos];
            cachedDate = [NSDate date];
        }
    }
    
    return tmpOnlineSkinInfos;
}

// private
+ (BOOL) saveSkinIconImageWithData:(NSData *) data filePath: path {
    if (path == nil) return NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *imagesDirPath = [path stringByDeletingLastPathComponent];
    NSError *error = nil;
    if (![fm fileExistsAtPath:imagesDirPath]) {
        
        [fm createDirectoryAtPath:imagesDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (error != nil) return NO;
    return [data writeToFile:path atomically:YES];
}

// private
+ (NSDictionary *)loadSkinInfoFromWeb
{
    NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[self skinRootUrl],SKINS_INFO_XML]];
    NSMutableURLRequest *httpSkinInfoRequest = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                         timeoutInterval:10];
    NSHTTPURLResponse *urlResponse = nil;
    NSData *skinInfoResult = [NetworkUtility sendSafeSynchronousRequest:httpSkinInfoRequest
                                                      returningResponse:&urlResponse
                                                                  error:nil];
    int status = [urlResponse statusCode];
    NSDictionary *skinsInfo = nil;
    if (status == 200) {
        //write down to localPath
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *skinInfoLocalPath = [NSString stringWithFormat:@"%@/Skin/%@",documentsDirectory,SKINS_INFO_PLIST];
        [skinInfoResult writeToFile:skinInfoLocalPath atomically:YES];
        skinsInfo = [[NSDictionary alloc] initWithContentsOfFile:skinInfoLocalPath];
    }
    
    return skinsInfo;
}

+ (NSString *)previewImageUrl:(NSString *)skinShortName {
    if (skinShortName == nil) return nil;
    NSString *path = [WebSkinInfoProvider skinRootUrl];
    NSString *imageName = [NSString stringWithFormat:@"%@_%@%@", SKIN_PREVIEW_IMAGE_PREFIX, skinShortName, @"@2x.png"];
    NSString *previewImageUrl = [NSString stringWithFormat:@"%@/%@/%@",
                                 path, ONLINE_PREVIEWS_FOLDER, imageName];
    return previewImageUrl;
}

+ (NSString *)previewImagePath:(NSString *)skinShortName {
    if (skinShortName == nil) return nil;
    NSString *path = [NSString stringWithFormat:@"%@/%@" ,[TPDialerResourceManager downloadSkinPath], skinShortName];
    NSString *imageName = [NSString stringWithFormat:@"%@_%@%@", SKIN_PREVIEW_IMAGE_PREFIX, skinShortName, @"@2x.png"];
    NSString *previewImagePath = [NSString stringWithFormat:@"%@/%@/%@", path, @"images", imageName];
    return previewImagePath;
}

+ (NSString *)previewImagePathForBuiltinSkin:(NSString *)skinShortName {
    if (skinShortName == nil) return nil;
    NSString *builtInRootDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Skin"];
    NSString *path = [builtInRootDir stringByAppendingPathComponent:skinShortName];
    NSString *imageName = [NSString stringWithFormat:@"%@_%@%@", SKIN_PREVIEW_IMAGE_PREFIX, skinShortName, @"@2x.png"];
    NSString *previewImagePath = [NSString stringWithFormat:@"%@/%@/%@", path, @"images", imageName];
    return previewImagePath;
}


+ (NSData *) downloadPreviewImageByUrl:(NSURL *) url {
    if (url == nil) return nil;
    int maxTry = 3;
    int getCount = 0;
    NSData *imageData = nil;
    for (; getCount < maxTry; getCount++) {
        imageData = [NSData dataWithContentsOfURL:url];
        if (imageData == nil) {
            continue;
        } else {
            break;
        }
    }
    return imageData;
}

+ (NSData *) downloadPreviewImageByString:(NSString *) urlPath {
    return [self downloadPreviewImageByUrl:[NSURL URLWithString:urlPath]];
}

+ (NSInteger) calculatePriorityByBuiltIn:(BOOL) isBuiltIn hasSound:(BOOL) hasSound isNew:(BOOL) isNew {
    NSInteger priority = 0;
    if (isBuiltIn) {
        // do not consider the builtin now, maybe used in the future
        priority += PRIORITY_BUILT_IN;
    }
    if (hasSound) {
        priority += PRIORITY_SOUND;
    }
    if (isNew) {
        priority += PRIORITY_NEW;
    }
    return priority;
}

+ (void) sortSkinList:(NSMutableArray *) skinInfoList {
    if (skinInfoList == nil || [skinInfoList count] == 0) return;
    [skinInfoList sortUsingComparator:^(id obj1, id obj2){
        if (obj1 == nil || obj2== nil) {
            return NSOrderedSame;
        }
        if (![obj1 isKindOfClass:[TPSkinInfo class]] || ![obj2 isKindOfClass:[TPSkinInfo class]]) {
            return NSOrderedSame;
        }
        TPSkinInfo *info1 = (TPSkinInfo *) obj1;
        TPSkinInfo *info2 = (TPSkinInfo *) obj2;
        if (info1.priority > info2.priority) {
            return NSOrderedAscending;
        } else if (info1.priority < info2.priority) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
        
    }];
}

+ (void) sortSkinByTime:(NSMutableArray *)skinInfoList{
    if (skinInfoList == nil || [skinInfoList count] == 0) return;
    [skinInfoList sortUsingComparator:^(id obj1, id obj2){
        if (obj1 == nil || obj2== nil) {
            return NSOrderedSame;
        }
        if (![obj1 isKindOfClass:[TPSkinInfo class]] || ![obj2 isKindOfClass:[TPSkinInfo class]]) {
            return NSOrderedSame;
        }
        TPSkinInfo *info1 = (TPSkinInfo *) obj1;
        TPSkinInfo *info2 = (TPSkinInfo *) obj2;
        NSTimeInterval info1Time = [UserDefaultsManager intValueForKey:[NSString stringWithFormat:@"%@_time",info1.skinID] defaultValue:0];
        NSTimeInterval info2Time = [UserDefaultsManager intValueForKey:[NSString stringWithFormat:@"%@_time",info2.skinID] defaultValue:0];
        if (info1Time > info2Time) {
            return NSOrderedAscending;
        } else if (info1Time < info2Time) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
        
    }];
}
            

@end
