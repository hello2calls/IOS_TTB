//
//  VoipCommercialPresent.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import "HangupCommercialManager.h"
#import "SeattleFeatureExecutor.h"
#import "FunctionUtility.h"
#import "VoipShareAllView.h"
#import "TouchPalDialerAppDelegate.h"
#import "CTUrl.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "NSString+TPHandleNil.h"
#import "VoipUtils.h"
#import "FileUtils.h"
#import <Usage_iOS/GTMBase64.h>
#import "CootekNotifications.h"
#import "CallViewController.h"
#import "SeattleFeatureExecutor.h"
#import "PrepareAdManager.h"
#import "TPDLib.h"

#define AD_PREFIX_FEATURE @"feature"
#define AD_PREFIX_SHARE @"share"
#define AD_PREFIX_YELLOWPAGE @"yellowpage"
#define AD_PREFIX_JUMPWEB @"jumpweb"
#define AD_PREFIX_DOWNLOAD @"download"

#define RESERVED_TARGET @"target"
#define RESERVED_ICON @"icon"
#define RESERVED_TARGET_CLASS @"className_iOS"

#define SRC_LOCAL @"ct"
#define SRC_COMMERCIAL @"ct_com"

#define COMERICAL_AD_REQUEST_UUID(x) [NSString stringWithFormat:@"commerical_ad_uuid_%@",x]


static HangupCommercialManager *sInstance;
static const NSString *AdTypeImg = @"IMG";
static const NSString *AdTypeVideo= @"VIDEO";

@interface HangupCommercialManager ()
@property (nonatomic,strong) NSMutableArray *notFetchedResouce ;
@property (nonatomic,strong) NSMutableArray *downloadedResoures;
@end

@implementation HangupCommercialManager {
    AdLandingPageManager *_callingAdLandingPageManager;
    AdLandingPageManager *_hangupAdLandingPageManager;
    NSString *_buttonText;
    NSString *_jumpUrl;
    BOOL _gotShow;
    double _startTime;
    NSString * _calltype;
    AdShowtimeManager    *_hangupAdShowtimeManager;
    AdShowtimeManager    *_callingAdShowtimeManager;
    NSMutableDictionary *_uuidMap;
    
}



+ (HangupCommercialManager *)instance {
    return sInstance;
}

+ (void)initialize {
    sInstance = [[HangupCommercialManager alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _observerList = [NSMutableArray array];
        _uuidMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)asyncAskCommercialWithCallingNumber:(NSString *)number
                                andCallType:(NSString *)callType
                                         tu:(NSString *)tu
                                       uuid:(NSString *)uuid {
    [self setCommercialModel:nil];
    [UserDefaultsManager removeObjectForKey:ad_now_resource_arr];
    NSDictionary *sizeInfo = [FunctionUtility getADViewSizeWithTu:tu];
    NSDictionary *dic = @{@"at": @"IMG",
                          @"tu": tu,
                          @"w": sizeInfo[@"w"],
                          @"h": sizeInfo[@"h"],
                          @"other_phone":number,
                          @"vt":callType,
                          @"ck":uuid};
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _lastWebAdRequestTime = [[[NSDate alloc] init] timeIntervalSince1970];
        [self asyncCommercialAd:tu param:dic];
    });
}

- (NSString *) commericalRequestCK:(NSString *)tu {
    return [UserDefaultsManager stringForKey:COMERICAL_AD_REQUEST_UUID(tu)];
}

- (NSDictionary *)asyncCommercialAd:(NSString *)tu param:(NSDictionary *)param {
    [UserDefaultsManager setIntValue:-1 forKey:AD_WEB_HTML_DOWNLOAD_STATUS];
    NSString *ck = [param objectForKey:@"ck"];
    if([ck length] == 0) {
        ck = [FunctionUtility generateUUID];
        [param setValue:ck forKey:@"ck"];
        cootek_log(@"PrepareThread asyncCommercialAd = %@,%@",ck,tu);
    }
    [UserDefaultsManager setObject:ck forKey:COMERICAL_AD_REQUEST_UUID(tu)];
    
    NSDictionary *result = [SeattleFeatureExecutor requestCommercialWeb:param];
    if(result) {
        NSString *pageString = [result objectForKey:@"page"];
        if ([pageString length] > 0) {
            NSData *data = [GTMBase64 webSafeDecodeString:pageString];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [VoipUtils updateHtmlFileWithString:string tu:tu];
            
            NSArray *requestResouce = [result objectForKey:@"resource"];;

            [self downloadWebAdWithRequestResource:requestResouce andTu:tu];
            
        }
    } else {
        [self postNotificationWithName:N_AD_READY_FOR_SHOW userInfo:@{@"tu":tu}];
        [UserDefaultsManager setBoolValue:NO forKey:if_any_ad_resource];
        [UserDefaultsManager setBoolValue:0 forKey:AD_WEB_HTML_DOWNLOAD_STATUS];
        
        if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
            [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_IS_QUERYING];
            cootek_log(@"ad_pu, popup_html, set quering NO, tu: %@", tu);
        }
    
    }
    return result;
    
}

static dispatch_queue_t q ;
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("ad.resource.download.queue", NULL);
    });
}
- (void) downloadWebAdWithRequestResource:(NSArray *)requestResouce andTu:(NSString *)tu {
    
    dispatch_async(q, ^{
        if (requestResouce == nil
            || requestResouce.count == 0) {
            return;
        }
        
        [FunctionUtility writeUsedTimeToReadyResourcePlistWithArray:requestResouce];
        NSString *requestPlistPath = [VoipUtils pathForResoucePlist:REQUEST_RESOURCE_PLIST];
        [requestResouce writeToFile:requestPlistPath atomically:YES];
        
        NSMutableArray *readyResource = [NSMutableArray arrayWithArray:[VoipUtils getResource:READY_RESOURCE_PLIST]];
        self.notFetchedResouce = [NSMutableArray arrayWithArray: [VoipUtils notFetchedFromRequestResource:requestResouce withReadyResources:readyResource]];
        dispatch_group_t group = dispatch_group_create();
        
        int notFetchedSize = self.notFetchedResouce.count;
        cootek_log(@"cola_cola\n, notFetchedSize= %d, tu= %@", notFetchedSize, tu);
        
        self.downloadedResoures = [NSMutableArray array];
        
        if (notFetchedSize == 0) {
            if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
                [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_IS_QUERYING];
                [UserDefaultsManager setBoolValue:YES forKey:CALL_POPUP_HTML_READY];
                cootek_log(@"ad_pu, popup_html, set quering NO, tu: %@", tu);
            }
            [self postNotificationWithName:N_AD_READY_FOR_SHOW userInfo:@{@"tu":tu}];
            
        } else {
            for(int i = 0; i < notFetchedSize; i++) {
                dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSDictionary *res = self.notFetchedResouce[i];
                    STRONG(readyResource)
                    NSString *srcString = res[@"src"];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:srcString]];
                    if (data == nil) {
                        return;
                    }
                    NSString *destString = res[@"dest"];
                    NSString *fullPath = [NSString stringWithFormat:@"/%@/%@/%@",Commercial,ADResource,destString];
                    NSString *destPath = [FileUtils getAbsoluteFilePath:fullPath];
                    [data writeToFile:destPath atomically:YES];
                    [DialerUsageRecord recordCustomEvent:CUSTOM_EVENT_FILE_DOWNLOAD_SIZE
                                                  metric:@(data.length)
                                               extraInfo:@{
                                                       CUSTOM_EVENT_FILE_DOWNLOAD_PATH: [FileUtils getDocumentRelativePath:destPath],
                                                       CUSTOM_EVENT_FILE_DOWNLOAD_TAG: @"ad_realtime"
                                               }];
                    @synchronized (self) {
                        [self.downloadedResoures addObject:res];
                        [strongreadyResource addObject:res];
                    }
                    
                    
                    
                    
                    cootek_log(@"cola_cola, \ndesPath= %@, \nsrcString= %@", destPath, srcString);
                });
            }// end for
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            STRONG(readyResource)
            STRONG(tu)
            [strongreadyResource writeToFile:[VoipUtils pathForResoucePlist:READY_RESOURCE_PLIST] atomically:YES];
            if ([strongtu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
                [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_IS_QUERYING];
                [UserDefaultsManager setBoolValue:YES forKey:CALL_POPUP_HTML_READY];
                cootek_log(@"ad_pu, popup_html, set quering NO, tu: %@", strongtu);
            }
            
            
            [self.notFetchedResouce removeObjectsInArray:self.downloadedResoures];
            
            
            if (self.notFetchedResouce.count == 0
                && ![NSString isNilOrEmpty:strongtu]) {
                cootek_log(@"cola_cola, all fetched!!!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self postNotificationWithName:N_AD_READY_FOR_SHOW userInfo:@{@"tu":strongtu}];
                });
                
            }
        }
        

    });
    
}


- (void) postNotificationWithName:(NSString *)notiName userInfo:(NSDictionary *)userInfo {
    if ([NSString isNilOrEmpty:notiName]) {
        return;
    }
    NSString *tu = [userInfo objectForKey:@"tu"];
    if (tu == nil
        || [tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
        return;
    }
    NSMutableDictionary *extendedUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    NSNumber *postNotiTime = @([[[NSDate alloc] init] timeIntervalSince1970]);
    [extendedUserInfo setObject:postNotiTime forKey:WEB_AD_READY_NOTI_TIME];
    
    // for ad stats
    [UserDefaultsManager setIntValue:1 forKey:AD_WEB_HTML_DOWNLOAD_STATUS];
    // for tu hangup, calling, try to post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:notiName
                                                        object:nil
                                                      userInfo:[extendedUserInfo copy]];
}




- (void)setAdLandingPageManager:(AdLandingPageManager*)AdLandingPageManager ifCallIng:(BOOL)ifCalling{
    if (ifCalling) {
        _callingAdLandingPageManager = AdLandingPageManager;
    }else{
        _hangupAdLandingPageManager = AdLandingPageManager;
    }
}

- (void)setCommercialModel:(HangupCommercialModel *)model {
    _commercialModel = model;
    _buttonText = nil;
    _jumpUrl = nil;
    _hangupAdLandingPageManager = nil;
    _hangupAdShowtimeManager = nil;
}

-(BOOL)checkIfResourceReady {
    _startTime = [[NSDate date] timeIntervalSince1970];
    //
    if ([UserDefaultsManager intValueForKey:AD_WEB_HTML_DOWNLOAD_STATUS] != 1) {
        return NO;
    }
    if (![UserDefaultsManager boolValueForKey:if_any_ad_resource]) {
        return NO;
    }
  
    NSString *readyPath = [NSString stringWithFormat:@"/%@/%@/%@", Commercial,ADResource, READY_RESOURCE_PLIST];
    NSString *absReadyPath = [FileUtils getAbsoluteFilePath:readyPath];
    
    NSString *requestPath = [NSString stringWithFormat:@"/%@/%@/%@", Commercial,ADResource, REQUEST_RESOURCE_PLIST];
    NSString *absRequestPath = [FileUtils getAbsoluteFilePath:requestPath];
    
    if (![FileUtils fileExistAtAbsolutePath:absRequestPath]
        || ![FileUtils fileExistAtAbsolutePath:absRequestPath]) {
        return NO;
    }
    
    NSArray *readyResources = [NSArray arrayWithContentsOfFile:absReadyPath];
    NSArray *requestResources = [NSArray arrayWithContentsOfFile:absRequestPath];
    
    // check request resources
    if (requestResources == nil || requestResources.count == 0) {
        return NO;
    }
    // check ready resources
    if (readyResources == nil || readyResources.count == 0) {
        return NO;
    }
    
    if (requestResources.count > readyResources.count) {
        return NO;
    }
    for(NSDictionary *request in requestResources) {
        BOOL found = NO;
        for(NSDictionary *ready in readyResources) {
            if ([request[@"src"] isEqualToString:ready[@"src"]]
                && [request[@"ver"] isEqualToNumber:ready[@"ver"]]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            return NO;
        }
    }
    return YES;
}

- (NSArray *) getNotReadyAdResources {
    NSString *readyPath = [NSString stringWithFormat:@"/%@/%@/%@", Commercial,ADResource, READY_RESOURCE_PLIST];
    NSString *absReadyPath = [[FileUtils getAbsoluteFilePath:readyPath] copy];
    
    NSString *requestPath = [NSString stringWithFormat:@"/%@/%@/%@", Commercial,ADResource, REQUEST_RESOURCE_PLIST];
    NSString *absRequestPath = [[FileUtils getAbsoluteFilePath:requestPath] copy];
    
    NSArray *emptyArray = @[];
    if (![FileUtils fileExistAtAbsolutePath:absRequestPath]
        || ![FileUtils fileExistAtAbsolutePath:absRequestPath]) {
        return emptyArray;
    }
    
    NSArray *readyResources = [NSArray arrayWithContentsOfFile:absReadyPath];
    NSArray *requestResources = [NSArray arrayWithContentsOfFile:absRequestPath];
    
    // check request resources
    if (requestResources == nil || requestResources.count == 0) {
        return emptyArray;
    }
    // check ready resources
    if (readyResources == nil || readyResources.count == 0) {
        return requestResources;
    }
    
    NSMutableArray *notReadyRes = [[NSMutableArray alloc] init];
    for(NSDictionary *request in requestResources) {
        BOOL found = NO;
        for(NSDictionary *ready in readyResources) {
            if ([request[@"src"] isEqualToString:ready[@"src"]]
                && [request[@"ver"] isEqualToNumber:ready[@"ver"]]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [notReadyRes addObject:request];
        }
    }
    return [notReadyRes copy];
}

- (UIImage *)getImage {
    return nil;
}

- (NSString *)getJumpTitle {
    return _commercialModel.title;
}

- (NSString *)getClickText {
    return _buttonText;
}

- (NSString *)getJumpUrl {
    return _jumpUrl ? _jumpUrl : _commercialModel.curl;
}

- (void)finishPresent {
    if (_gotShow) {
        double now = [[NSDate date] timeIntervalSince1970];
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_DURATION, @(now - _startTime)), nil];
    }
    _gotShow = NO;
}

- (void)tellShow:(BOOL)realShow{
    //hangupAdShowtimeManager
    if (_commercialModel.edurl.length == 0) {
        return;
    }
    
    if (realShow) {
        if (_hangupAdShowtimeManager) {
            _hangupAdShowtimeManager = nil;
        }
        _hangupAdShowtimeManager = [[AdShowtimeManager alloc] initWithAd:_commercialModel];
        [_hangupAdShowtimeManager adDidAppear];
    }
}

- (void)handleClickWithCloseBlock:(void (^)(void))closeBlock {
    if (_commercialModel == nil) {
        return;
    }
    if ([_commercialModel isKindOfClass:[HangupCommercialModel class]]&& _commercialModel.materialPic == nil) {
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_ERROR_HAPPENS, _commercialModel.adId), nil];
    }

    
    [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_CLICK, _commercialModel.adId), nil];
    if ([_commercialModel.adId hasPrefix:AD_PREFIX_SHARE]) {
        NSString *shareUrl = [[_commercialModel reservedDict] objectForKey:RESERVED_TARGET];
        if (shareUrl.length == 0) {
            shareUrl = nil;
        }
        VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:_commercialModel.title msg:_commercialModel.desc url:shareUrl image:nil];
        shareAllView.fromWhere = @"VoipHangupCommercial";
        [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
        [self hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
        [self tellClick];
        return;
    }
    if([_commercialModel.adId hasPrefix:AD_PREFIX_YELLOWPAGE]) {
        NSString *targetUrl = [[_commercialModel reservedDict] objectForKey:RESERVED_TARGET];
        if ([targetUrl hasSuffix:@"_token="]) {
            targetUrl = [NSString stringWithFormat:@"%@%@", targetUrl, [SeattleFeatureExecutor getToken]];
        }
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:targetUrl];
        [ctUrl addOtherParams];
        UIViewController *controller = [ctUrl startWebView];
        _hangupAdLandingPageManager = [[AdLandingPageManager alloc] initWithAd:_commercialModel webController:controller];
        [self hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
        [self tellClick];
        closeBlock();
        return;
    }
    if (_jumpUrl) {
        [self tellClick];
    }
    UIViewController *controller = [FunctionUtility openUrl:[self getJumpUrl] withTitle:[self getJumpTitle]];
    _hangupAdLandingPageManager = [[AdLandingPageManager alloc] initWithAd:_commercialModel webController:controller];
    if (_commercialModel.da) {
        [self hangupADDisappearWithCloseType:ADCLOSE_DIRECT];
    } else {
        [self hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
    }
    
    closeBlock();
}

- (void)tellClick {
    [self asyncVisitUrl:_commercialModel.curl];
}

- (void)asyncVisitUrl:(NSString *)url {
    NSString *newUrl = [NSString stringWithFormat:@"%@", url];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [FunctionUtility visitUrl:newUrl];
    });
}

- (NSString *)getGuideText {
    return @"此通免费电话由以下品牌赞助";
}

- (void)callingViewADDidLoad:(AdMessageModel *)ad  {
    [[HangupCommercialManager instance] setAdLandingPageManager:nil ifCallIng:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<HangupCommercialManagerDelegate> obj in _observerList) {
            if ([obj respondsToSelector:@selector(callingCommercialDataDidLoad:image:)]) {
                [obj callingCommercialDataDidLoad:ad image:nil];
            }
        }
        [_observerList removeAllObjects];
    });
}

- (void)addADObserver:(id<HangupCommercialManagerDelegate>)observer {
    if (observer) {
        [_observerList addObject:observer];
    }
}

- (void)removeADObserver:(id<HangupCommercialManagerDelegate>)observer {
    if (observer) {
        [_observerList removeObject:observer];
    }
}

- (void)didShowAD:(AdMessageModel *)ad show:(BOOL)realShow {
    //callAdShowtimeManager
    if (ad.edurl.length == 0) {
        return;
    }
    
    if ( _callingAdShowtimeManager ) {
        _callingAdShowtimeManager = nil;
    }
    _callingAdShowtimeManager = [[AdShowtimeManager alloc] initWithAd:ad];
    [_callingAdShowtimeManager adDidAppear];

}

- (void)didClickAD:(AdMessageModel *)ad {
    if ( ! ad ) {
        return;
    }
    
    if ( ! [UserDefaultsManager boolValueForKey:IS_CALLING_AD_CLICK_ACTIVE] ) {
        [self asyncVisitUrl:ad.curl];
        return;
    }

    if ([ad.adId hasPrefix:AD_PREFIX_SHARE]) {
        NSString *shareUrl = [[ad reservedDict] objectForKey:RESERVED_TARGET];
        if (shareUrl.length == 0) {
            shareUrl = nil;
        }
        VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:ad.title msg:ad.desc url:shareUrl image:nil];
        shareAllView.fromWhere = @"VoipHangupCommercial";
        [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
        [self asyncVisitUrl:ad.curl];
        [self callingADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
        return;
    }
    if([ad.adId hasPrefix:AD_PREFIX_YELLOWPAGE]) {
        NSString *targetUrl = [[ad reservedDict] objectForKey:RESERVED_TARGET];
        if ([targetUrl hasSuffix:@"_token="]) {
            targetUrl = [NSString stringWithFormat:@"%@%@", targetUrl, [SeattleFeatureExecutor getToken]];
        }
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:targetUrl];
        [ctUrl addOtherParams];
        UIViewController *controller = [ctUrl startWebView];
        _callingAdLandingPageManager = [[AdLandingPageManager alloc] initWithAd:ad webController:controller];
        [self asyncVisitUrl:ad.curl];
        [self callingADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
        return;
    }
    
    NSString *jumpUrl = ad.jumpURL;
    if (jumpUrl) {
        [self asyncVisitUrl:ad.curl];
        UIViewController *controller = [FunctionUtility openUrl:jumpUrl withTitle:ad.title];
        _callingAdLandingPageManager = [[AdLandingPageManager alloc] initWithAd:ad webController:controller];
        [self callingADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
    }
}

- (void)hangupADDisappearWithCloseType:(ADCloseType)closeTyep
{
    if (_hangupAdShowtimeManager) {
        [_hangupAdShowtimeManager adDidDisappearWithCloseType:closeTyep];
        _hangupAdShowtimeManager = nil;
    }
}

- (void)callingADDisappearWithCloseType:(ADCloseType)closeTyep
{
    if (_callingAdShowtimeManager) {
        [_callingAdShowtimeManager adDidDisappearWithCloseType:closeTyep];
        _callingAdShowtimeManager = nil;
    }
}

+ (void)asyncVisitUrl:(NSString *)url
{
    if (url.length) {
        NSString *newUrl = [NSString stringWithFormat:@"%@", url];
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [FunctionUtility visitUrl:newUrl];
        });
    }
}

- (BOOL) isDirectAD {
    return _commercialModel && _commercialModel.da;
}

- (void) showDirectAD {
    [[HangupCommercialManager instance] handleClickWithCloseBlock:^(){}];
    [DialerUsageRecord recordpath:PATH_DIRECT_COMMERCIAL
                              kvs:Pair(COMMERCIAL_SHOW, [NSString nilToEmpty:_commercialModel.adId]) , nil];
    NSString *edurl = _commercialModel.edurl;
    if (edurl) {
        [FunctionUtility asyncVisitUrl:[edurl stringByAppendingString:@"&show=1"]];
    }
}

@end
