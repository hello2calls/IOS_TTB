//
//  PrepareAdManager.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/9.
//
//

#import "PrepareAdManager.h"
#import "PrepareWebAdModel.h"
#import "AdMessageModel.h"
#import "Reachability.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "AdStatManager.h"
#import "VoipUtils.h"

#define TIMER_INTERVAL (600)
#define AD_RETRY_INTERVAL (30)
#define AD_RESOURCE_RETRY_INTERVAL (30)


@interface PrepareThread : NSThread <PrepareAdDelegate>{
    NSArray *_preAds;
    NSDictionary *_adIndexMap;
    int _commitRetry;
    int _sendUrlRetry;
}

@end

@implementation PrepareThread

- (void)main {
    @autoreleasepool {
        self.name = @"PrepareThread";
        [self initPrepareModels];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                          target:self
                                                        selector:@selector(checkPrepareUpdate)
                                                        userInfo:nil
                                                         repeats:YES];
        [timer fire];
        while (![self isCancelled]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

- (void)initPrepareModels {
    cootek_log(@"%@ initPrepareModels",self.name);
    
    NSString *oldPreparePath = [VoipUtils absoluteCommercialDirectoryPath:@"prepare"];
    [[NSFileManager defaultManager] removeItemAtPath:oldPreparePath error:NULL];
    PrepareWebAdModel *hangup = [[PrepareWebAdModel alloc] initWithTu:kAD_TU_HANGUP delegate:self];
    PrepareWebAdModel *hangupback = [[PrepareWebAdModel alloc] initWithTu:kAD_TU_BACKCALLHANG delegate:self];
    PrepareWebAdModel *callConfirm = [[PrepareWebAdModel alloc] initWithTu:kAD_TU_CALL_POPUP_HTML delegate:self];
    PrepareWebAdModel *launchConfirm = [[PrepareWebAdModel alloc] initWithTu:kAD_TU_LAUNCH delegate:self];
    _preAds = @[hangup,hangupback,callConfirm,launchConfirm];
    _adIndexMap = [[NSMutableDictionary alloc] init];
    for (int i = 0 ; i < _preAds.count; i++) {
        PrepareAdModel *ad = [_preAds objectAtIndex:i];
        [_adIndexMap setValue:@(i) forKey:ad.tu];
    }
}

- (void)checkPrepareUpdate {
    cootek_log(@"PrepareThread 10min checkPrepareUpdate");
    [self startupPrepare];
}

- (void)netChangeCheckPrepareUpdate {
    [self startupPrepareOnce];
}

- (void)startPrepareAd:(PrepareAdModel *)model {
    model.adRetryCount = 0;
    model.adResourceRetryCount = 0;
    [self prepareAd:model];
}

- (void)startupPrepare {
    for (PrepareAdModel *model in _preAds) {
        if ([model.tu isEqualToString:kAD_TU_LAUNCH]) {
            if (model.launchCount > 0 && model.launchCount < 6) {
                model.launchCount++;
                continue;
            }else{
                model.launchCount = 1;
            }
        }
        [model deleteAd];
        [self startPrepareAd:model];
    }
}

- (void)startupPrepareOnce {
    for (PrepareAdModel *model in _preAds) {
        [model deleteAd];
        [self startPrepareAd:model];
    }
}
- (void)prepareAd:(PrepareAdModel *)model {
    cootek_log(@"%@ prepareAd = %@,retry=%d",self.name,model.tu,model.adRetryCount);
    if ([model needRequestPrepare]) {
        cootek_log(@"%@ prepareAd start request Ad",self.name);
        if ([[Reachability shareReachability] networkStatus] >= network_3g &&
            [model executePrepareAd]) {
            [model saveAd];
            [self prepareDownloadReouce:model];
        }
    } else if(![model allResourceDownloaded]) {
        cootek_log(@"%@ prepareAd start Ad dowloadresouce",self.name);
        [self prepareDownloadReouce:model];
    }
}


- (void)prepareDownloadReouce:(PrepareAdModel *)model {
    cootek_log(@"%@ prepareDownloadReouce = %@,retry=%d",self.name,model.tu,model.adResourceRetryCount);
    if (![model downloadAdResource]) {
        model.adResourceRetryCount ++;
        if (model.adResourceRetryCount < 3) {
            [self performSelector:@selector(prepareDownloadReouce:)
                       withObject:model
                       afterDelay:model.adResourceRetryCount * AD_RESOURCE_RETRY_INTERVAL];
        }
    }

}

- (PrepareAdModel *)getModelByTu:(NSString *)tu {
    int i = [[_adIndexMap objectForKey:tu] integerValue];
    cootek_log(@"%@ getModelByTu = %d,tu=%@",self.name,i,tu);
    if (i < [_preAds count]) {
        return [_preAds objectAtIndex:i];
    }
    return nil;
}

- (void)needStartPrepare:(PrepareAdModel *)model afterDelay:(int)second {
    cootek_log(@"%@ needStartPrepare = %@,delay=%d",self.name,model.tu,second);
    [self performSelector:@selector(needStartPrepare:) withObject:model afterDelay:second];
}

- (void)deleteAd:(NSString *)tu {
    PrepareAdModel *model = [self getModelByTu:tu];
    [model deleteAd];
}

- (void)needStartPrepare:(PrepareAdModel *)model {
    if ([NSThread currentThread] != self) {
        [self performSelector:@selector(startPrepareAd:)
                     onThread:self
                   withObject:model
                waitUntilDone:NO];
    } else {
        [self startPrepareAd:model];
    }
}

- (void)didShowPrepareAd:(NSString *)tu {
    cootek_log(@"%@ didShowPrepareAd =%@",self.name,tu);
    PrepareAdModel *model = [self getModelByTu:tu];
    if (model) {
        [model didShowPrepareAd];
    }
}



@end

@interface PrepareAdManager () {
    PrepareThread *_thread;
}
@end

@implementation PrepareAdManager

PrepareAdManager *sManager =  nil;

+ (void)initialize {
    sManager = [[PrepareAdManager alloc] init];
}

+ (PrepareAdManager *)instance {
    return sManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if(ENABLE_COMMERICAL_PREPARE) {
            _thread = [[PrepareThread alloc] init];
            [_thread start];
            [AdStatManager instance];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                  selector:@selector(checkPrepareUpdateWhenNetWorkChanged)
                                   name:N_REACHABILITY_NETWORK_CHANE
                                   object:nil];
        }

    }
    return self;
}

- (PrepareAdItem *)getPrepareAdItem:(NSString *)tu {
    PrepareAdModel *model = [_thread getModelByTu:tu];
    PrepareAdItem *item = nil;
    if (model) {
        item = [model prepareItem];
    }
    return item;
}

- (void)didShowPrepareAd:(NSString *)tu {
    [_thread performSelector:@selector(didShowPrepareAd:) onThread:_thread withObject:tu waitUntilDone:NO];
}

- (void)checkPrepareUpdateWhenNetWorkChanged {
    cootek_log(@"PrepareThread netWorkChanged checkPrepareUpdate");
    [_thread performSelector:@selector(netChangeCheckPrepareUpdate) onThread:_thread withObject:nil waitUntilDone:NO];
}



@end
