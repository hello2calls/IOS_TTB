//
//  PrepareAdModel.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/9.
//
//

#import "PrepareWebAdModel.h"
#import "SeattleFeatureExecutor.h"
#import <Usage_iOS/GTMBase64.h>
#import "VoipUtils.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"

#define PREPARE_PATH    @"prepare2"
#define HTML_PATH       @"%@.html"
#define CONFIG_PATH     @"config.plist"
#define RESOURCE_PATH   @"resource.plist"
#define RESOURCE_DELETE @"delete.plist"
#define RESOURCE_SHARE  @"share.plist"

#define TAG @"Prepare"
#define DEAFULT_EXPIRED 10 * 60 * 1000

@interface PrepareWebAdModel() {
    
    NSDictionary *_adResponse;
    NSString *_rootPath;
    PrepareAdItem *_currentPrepareAd;
    PrepareAdItem *_lastShowAd;
    NSString *_uuid;
    NSMutableArray *_items;
}

@end

@implementation PrepareWebAdModel

+ (NSDictionary *)adWebParams:(NSString *)tu uuid:(NSString *)uuid{
    NSDictionary *sizeInfo = [FunctionUtility getADViewSizeWithTu:tu];
    return @{@"at": @"IMG",@"tu": tu,@"w": sizeInfo[@"w"],@"h": sizeInfo[@"h"],@"pf":@(1),@"ck":uuid};
}

- (NSString *)createCurrentAdName {
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *timestatmp = [NSString stringWithFormat:@"%d",time];
    return timestatmp;
}

- (void)expiredPrepare:(PrepareAdItem *)item {
    int second = (item.expired - (long)[[NSDate date] timeIntervalSince1970] * 1000)/1000 + 1;
    if (self.delegate && second > 0) {
        [self.delegate needStartPrepare:self afterDelay:second];
    }
}

- (BOOL)needRequestPrepare {
    for (PrepareAdItem *item in _items) {
        if(![item isItemExpired] && ![item dispaly]) {
            _currentPrepareAd = [item copy];
            return false;
        }
    }
    return true;
}

- (BOOL)deleteAd {
    NSArray *tmp  = [NSArray arrayWithArray:_items];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL changed = false;
    for (PrepareAdItem *item in tmp) {
       NSString *path = [NSString stringWithFormat:@"%@/%@",_rootPath,item.htmlPath];
       if ([item isItemExpired] || item.dispaly || ![fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:NULL];
            [_items removeObject:item];
            changed = true;
        }
    }
    if (changed) {
        NSString *configPath = [NSString stringWithFormat:@"%@/%@",_rootPath,CONFIG_PATH];
        [NSKeyedArchiver archiveRootObject:_items toFile:configPath];
    }
    [self deleteAdResource];
    return true;
}

- (void)deleteAdResource {
    NSString *sharePath = [NSString stringWithFormat:@"%@/%@",_rootPath,RESOURCE_SHARE];
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionaryWithContentsOfFile:sharePath];
    NSString *deletePath = [NSString stringWithFormat:@"%@/%@",_rootPath,RESOURCE_DELETE];
    NSMutableArray *delResource = [NSMutableArray arrayWithContentsOfFile:deletePath];
    if([delResource count] > 0) {
        for (NSString *key in delResource) {
            if (![shareDic objectForKey:key]) {
                NSString *path = [NSString stringWithFormat:@"%@/%@",_rootPath,key];
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
        }
        [delResource removeAllObjects];
        [delResource writeToFile:deletePath atomically:YES];
    }
}


- (BOOL)executePrepareAd {
    _uuid = [FunctionUtility generateUUID];
    _adResponse = [SeattleFeatureExecutor requestCommercialWeb:[PrepareWebAdModel adWebParams:self.tu uuid:_uuid]];
    return _adResponse != nil;
}

- (BOOL)saveAd {
    NSString *pageString = [_adResponse objectForKey:@"page"];
    if ([pageString length] > 0) {
        NSData *data = [GTMBase64 webSafeDecodeString:pageString];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *currentTuName = [self createCurrentAdName];
        NSString *htmlName = [NSString stringWithFormat:HTML_PATH,currentTuName];
        NSError *error = nil;
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@",_rootPath,htmlName];
        BOOL writeSuccess = [string writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!writeSuccess || error != nil) {
            cootek_log(@"%@",[error description]);
        }
        if (writeSuccess) {
            NSDictionary *conf = [_adResponse objectForKey:@"conf"];
            long current = (long)[[NSDate date] timeIntervalSince1970] * 1000;
            int etime = [[conf objectForKey:@"etime"] intValue];
            etime = etime > 0 ? etime : DEAFULT_EXPIRED;
            PrepareAdItem *ad = [PrepareAdItem adItems:htmlName
                                                adPath:@""
                                               request:_uuid
                                               expired:etime + current
                                                  idws:[[_adResponse objectForKey:@"idws"] boolValue]
                                                 wtime:[[_adResponse objectForKey:@"wtime"] intValue]];
            [_items addObject:ad];
            _currentPrepareAd = [ad copy];
            NSString *configPath = [NSString stringWithFormat:@"%@/%@",_rootPath,CONFIG_PATH];
            [NSKeyedArchiver archiveRootObject:_items toFile:configPath];
            NSArray *request = [_adResponse objectForKey:@"resource"];
            if (request) {
                NSString *resourcePath = [NSString stringWithFormat:@"%@/%@",_rootPath,RESOURCE_PATH];
                [request writeToFile:resourcePath atomically:YES];
            }
        }
        
        return writeSuccess;
    }
    return false;
}

- (BOOL)downloadAdResource {
    if (_currentPrepareAd == nil) {
        return false;
    }
    NSString *adRoot =_rootPath;
    NSString *resourcePath = [NSString stringWithFormat:@"%@/%@",adRoot,RESOURCE_PATH];
    NSString *sharePath = [NSString stringWithFormat:@"%@/%@",adRoot,RESOURCE_SHARE];
    NSArray *requestResouce = [NSArray arrayWithContentsOfFile:resourcePath];
    NSMutableArray *failedArray = [NSMutableArray array];
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionaryWithContentsOfFile:sharePath];
    if(shareDic == nil) {
        shareDic = [NSMutableDictionary dictionaryWithCapacity:[requestResouce count]];
    }
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithCapacity:[requestResouce count]];
    for (NSDictionary *res in requestResouce) {
        NSString *destString = res[@"dest"];
        NSString *destPath = [NSString stringWithFormat:@"%@/%@",adRoot,destString];
        int ver = [res[@"ver"] intValue];
        [tmp setObject:@(ver) forKey:destString];
        if (![[NSFileManager defaultManager] fileExistsAtPath:destPath] ||
            [[shareDic objectForKey:destString] intValue] != ver) {
            NSString *srcString = res[@"src"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:srcString]];
            if (data != nil) {
                [shareDic setObject:@(ver) forKey:destString];
                [FileUtils saveFileAtAbsolutePathWithData:data atPath:destPath overWrite:YES];
            } else {
                [failedArray addObject:res];
            }
        }
    }
    if ([shareDic count] > 0) {
        NSString *deletePath = [NSString stringWithFormat:@"%@/%@",adRoot,RESOURCE_DELETE];
        NSMutableArray *delResource = [NSMutableArray arrayWithContentsOfFile:deletePath];
        if (delResource == nil) {
            delResource = [NSMutableArray array];
        }
        NSArray * keys =[NSArray arrayWithArray:[shareDic allKeys]];
        for (NSString *key in keys) {
            if ([tmp objectForKey:key] == nil) {
                [delResource addObject:[key copy]];
                [shareDic removeObjectForKey:key];
            }
        }
        if ([delResource count] > 0) {
            [delResource writeToFile:deletePath atomically:YES];
        }
        if ([shareDic count] > 0) {
            [shareDic writeToFile:sharePath atomically:YES];
        }
    }
    if ([failedArray count] > 0) {
        [failedArray writeToFile:resourcePath atomically:YES];
        return false;
    } else if(requestResouce != nil){
        [[NSFileManager defaultManager] removeItemAtPath:resourcePath error:NULL];
    }
    [self expiredPrepare:_currentPrepareAd];
    return true;
}

- (PrepareWebAdModel *)initWithTu:(NSString *)tu delegate:(id<PrepareAdDelegate>)delegate{
    self = [super initWithTu:tu delegate:delegate];
    if (self) {
        NSString *commercailPath = [VoipUtils absoluteCommercialDirectoryPath:PREPARE_PATH];
        [FileUtils createDir:commercailPath];
        commercailPath  =[commercailPath stringByAppendingPathComponent:tu];
        [FileUtils createDir:commercailPath];
        _rootPath = commercailPath;
        [self initCacheItems];
        for (PrepareAdItem *item in _items) {
            if(![item isItemExpired] && ![item dispaly]) {
                [self expiredPrepare:item];
            }
        }
    }
    return self;
}

- (BOOL)allResourceDownloaded {
    if (!_currentPrepareAd) {
        return true;
    }
    return [self resourceDowloaded];
}

- (BOOL)resourceDowloaded {
    NSString *resourcePath = [NSString stringWithFormat:@"%@/%@",_rootPath,RESOURCE_PATH];
    return ![[NSFileManager defaultManager] fileExistsAtPath:resourcePath];
}

- (void)initCacheItems {
    NSString *configPath = [NSString stringWithFormat:@"%@/%@",_rootPath,CONFIG_PATH];
    NSArray *items = [NSKeyedUnarchiver unarchiveObjectWithFile:configPath];
    if ([items count] > 0) {
        _items = [[NSMutableArray alloc] initWithArray:items];
    } else {
        _items = [NSMutableArray array];
    }
}

- (PrepareAdItem *)currentShow:(PrepareAdItem *)item {
    PrepareAdItem *tmp = [item copy];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",_rootPath,tmp.htmlPath];
    tmp.fullHtmlPath = fullPath;
    return tmp;
}

- (PrepareAdItem *)prepareItem {
    if (_lastShowAd && ![_lastShowAd isItemExpired] && ![_lastShowAd dispaly]) {
        return [self currentShow:_lastShowAd];
    }
    _lastShowAd = nil;
    if ([_items count] > 0) {
        for (PrepareAdItem *item in _items) {
            if (![item isItemExpired] && ![item dispaly] && [self resourceDowloaded]) {
                _lastShowAd = item;
                break;
            }
        }
        if (_lastShowAd) {
            return [self currentShow:_lastShowAd];
        }
    }
    return nil;
}

- (void)didShowPrepareAd {
    if (_lastShowAd && [_items containsObject:_lastShowAd]) {
        _lastShowAd.dispaly = YES;
        NSString *configPath = [NSString stringWithFormat:@"%@/%@",_rootPath,CONFIG_PATH];
        [NSKeyedArchiver archiveRootObject:_items toFile:configPath];
        [self prepareNewAd];
    }
}

- (void)prepareNewAd {
    if (self.delegate) {
        [self.delegate needStartPrepare:self afterDelay:0];
    }
}

@end
