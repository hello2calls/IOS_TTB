//
//  LaunchCommercialManager.m
//  TouchPalDialer
//
//  Created by siyi on 16/2/22.
//
//

#import <Foundation/Foundation.h>
#import "LaunchCommercialManager.h"
#import "SeattleFeatureExecutor.h"
#import "AdMessageModel.h"
#import "CootekNotifications.h"
#import "FileUtils.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "UserDefaultKeys.h"
#import "NSString+TPHandleNil.h"
#import "DialerUsageRecord.h"
static LaunchCommercialManager *sInstance;
static NSMutableArray *_delegates;
@implementation LaunchCommercialManager {
}

+ (void)initialize {
    sInstance = [[LaunchCommercialManager alloc] init];
    _delegates = [[NSMutableArray alloc] initWithCapacity:1];
}

+ (instancetype) instance {
    return sInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _cachedModel = nil;
        _lastModel = nil;
    }
    return self;
}

- (void) onMaterialPicDownloaded {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    int delegateCount = _delegates.count;
    BOOL freshModelReady = self.lastModel && self.lastModel.materialPic;
    if (delegateCount == 0) {
        // no consumers right now
        if (freshModelReady) {
            [self cacheToDisk];
        }
        
    } else {
        // consumers are hungry
        HangupCommercialModel *modelToBeConsumed = nil;
        if (freshModelReady) {
            modelToBeConsumed = self.lastModel;
        } else {
            modelToBeConsumed = [self getCachedModel];
        }
        if (modelToBeConsumed && _delegates.count > 0) {
            for (id<LaunchCommercialDelegate> delegate in _delegates) {
                [delegate didFetchAD:modelToBeConsumed isFresh:freshModelReady];
            }
        }
    }
}

- (void) asyncFetchAD {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *adInfo = [SeattleFeatureExecutor fetchLaunchAD];
        HangupCommercialModel *model = adInfo[kAD_TU_LAUNCH];
        self.lastModel = model;
        if (model) {
            // get the ad(maybe no img yet)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaterialPicDownloaded) name:N_LAUNCH_AD_MATERIAL_PIC_DOWNLOADED object:nil];
        } else {
            //failed to fetch the ad
            [self onMaterialPicDownloaded];
        }
    });
}

- (void) registerDelegate:(id<LaunchCommercialDelegate>)delegate {
    if (!delegate) {
        return;
    }
    [_delegates addObject:delegate];
}

- (void) removeDelegate:(id<LaunchCommercialDelegate>)delegate {
    if (!delegate) {
        return;
    }
    [_delegates removeObject:delegate];
}

- (void) clearLastModel {
    self.lastModel = nil;
}

- (HangupCommercialModel *) getCachedModel {
    NSString *cachedImgPath = [self getAbsoluteCachedImagePath];
    NSString *cachedADPath = [self getAbsoluteCachedFilePath];
    if ([NSString isNilOrEmpty:cachedImgPath]
        || [NSString isNilOrEmpty:cachedADPath]) {
        return nil;
    }
    // either img or plist is gone, return nil
    if (![FileUtils fileExistAtAbsolutePath:cachedADPath]
        || ![FileUtils fileExistAtAbsolutePath:cachedImgPath]) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *adinfo = [[NSDictionary alloc] initWithContentsOfFile:cachedADPath];
    if (!adinfo || adinfo.count == 0 || error) {
        return nil;
    }
    
    HangupCommercialModel *model = [[HangupCommercialModel alloc] init];
    model.localMaterial = cachedImgPath;
    NSArray *adPkgs = [adinfo objectForKey:@"ad"];
    
    if (adPkgs && adPkgs.count > 0) {
        NSDictionary *adPkg = adPkgs[0];
        NSArray *ads = [adPkg objectForKey:@"ads"];
        if (!ads || ads.count == 0) {
            return nil;
        }
        
        model.expireTimestamp = [[adinfo objectForKey:@"extt"] longLongValue];
        long long ttNow = (long long ) ([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
        if (ttNow > model.expireTimestamp) {
            [self deleteCacheFromDisk];
            return nil;
        }
        
        if (_cachedModel) {
            return _cachedModel;
        }
        
        @try {
            model.wtime = [[adPkg objectForKey:@"wtime"] longLongValue];
            model.tu = (NSString *)[adPkg objectForKey:@"tu"];
            model.idws = [[adPkg objectForKey:@"idws"] boolValue];
            model.s = (NSString *)[adPkg objectForKey:@"s"];
            
            NSDictionary *ad = ads[0];
            model.w = [[ad objectForKey:@"w"] doubleValue];
            model.h = [[ad objectForKey:@"h"] doubleValue];
            
            model.ec = [[ad objectForKey:@"ec"] boolValue];
            model.dtime = [[ad objectForKey:@"dtime"] longLongValue];
            model.etime = [[ad objectForKey:@"etime"] longLongValue];
            
            model.adId = (NSString *)[ad objectForKey:@"ad_id"];
            model.turl = (NSString *)[ad objectForKey:@"turl"];
            model.curl = (NSString *)[ad objectForKey:@"curl"];
            model.edurl = (NSString *)[ad objectForKey:@"edurl"];
            model.surl = (NSString *)[ad objectForKey:@"surl"];
            
            model.src = (NSString *)[ad objectForKey:@"src"];
            model.title = (NSString *)[ad objectForKey:@"title"];
            model.brand = (NSString *)[ad objectForKey:@"brand"];
            model.material = (NSString *)[ad objectForKey:@"material"];
            model.at = (NSString *)[ad objectForKey:@"at"];
            model.reserved = (NSString *)[ad objectForKey:@"reserved"];
            
            model.clk_url = (NSString *)[ad objectForKey:@"clk_url"];
            NSArray *clk_monitor_url_Arr = (NSArray *)[ad objectForKey:@"clk_monitor_url"];
            model.clk_monitor_url = [clk_monitor_url_Arr mutableCopy];
            NSArray *ed_monitor_url_Arr = (NSArray *)[ad objectForKey:@"ed_monitor_url"];
            model.ed_monitor_url  = [ed_monitor_url_Arr mutableCopy];
            
            model.ttype = (NSString *)[ad objectForKey:@"ttype"];
            model.tstep = (NSString *)[ad objectForKey:@"tstep"];
            model.rdesc = (NSString *)[ad objectForKey:@"rdesc"];
            
            model.desc = (NSString *)[ad objectForKey:@"desc"];
            model.checkcode = (NSString *)[ad objectForKey:@"checkcode"];
            
        } @catch(NSException *e) {
            model = nil;
            
        } @finally {
            _cachedModel = model;
            return model;
        }
    }
    return nil;
}

- (void) cacheToDisk {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        if (!self.lastModel  ||
            ![self.lastModel.tu isEqualToString:kAD_TU_LAUNCH]) {
            return;
        }
        NSError *error = nil;
        NSDictionary *adinfo = [NSJSONSerialization JSONObjectWithData:[self.lastModel.rawResponseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (error) {
            return;
        }
        NSMutableDictionary *extendAdInfo = [[NSMutableDictionary alloc] initWithDictionary:adinfo];
        [extendAdInfo setObject:@(self.lastModel.expireTimestamp) forKey:@"extt"];
        NSString *filePath = [self getAbsoluteCachedFilePath];
        if (filePath) {
            [extendAdInfo writeToFile:filePath atomically:YES];
            [UIImagePNGRepresentation(self.lastModel.materialPic) writeToFile:[self getAbsoluteCachedImagePath] atomically:YES];
        }
        self.lastModel = nil;
    });
}

- (NSString *) getAbsoluteCachedFilePath {
    NSString *adDir = [self getADCacheDir];
    if (adDir) {
        return [adDir stringByAppendingPathComponent:FILE_LAUNCH_AD];
    }
    return nil;
}

- (NSString *) getAbsoluteCachedImagePath {
    NSString *adDir = [self getADCacheDir];
    if (adDir) {
        return [adDir stringByAppendingPathComponent:FILE_LAUNCH_IMG];
    }
    
    return nil;
}

- (NSString *) getADCacheDir {
    NSString *documentPath = [FileUtils absolutePathOfDocument];
    if (!documentPath) {
        return nil;
    }
    NSString *adDirPath = [documentPath stringByAppendingPathComponent:DIR_ADS];
    if (![FileUtils fileExistAtAbsolutePath:adDirPath]) {
        [FileUtils createDir:adDirPath];
    }
    return adDirPath;
}

- (void) deleteCacheFromDisk:(BOOL) keepImage {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSString *adDir = [self getADCacheDir];
    NSArray *files = [fm contentsOfDirectoryAtPath:adDir error:&error];
    if (!error) {
        for(NSString *file in files) {
            if (keepImage && [file rangeOfString:@".png"].location != NSNotFound) {
                continue;
            }
            NSString *filePath = [adDir stringByAppendingPathComponent:file];
            [fm removeItemAtPath:filePath error:nil];
        }
    }
}

- (void) deleteCacheFromDisk {
    [self deleteCacheFromDisk:NO];
    [self clearLastModel];
    _cachedModel = nil;
}

- (void) dealloc {
    _cachedModel = nil;
    _delegates = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end