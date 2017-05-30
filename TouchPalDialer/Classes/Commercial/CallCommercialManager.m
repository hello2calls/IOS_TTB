//
//  CallCommercialManager.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/12.
//
//

#import "CallCommercialManager.h"
#import "GCDAsyncUdpSocket.h"
#import "TouchPalVersionInfo.h"
#import "LocalStorage.h"
#import "UserDefaultKeys.h"
#import "SeattleFeatureExecutor.h"
#import "FunctionUtility.h"
#import <Usage_iOS/GTMBase64.h>
#import "UserDefaultsManager.h"
#import "PhoneNumber.h"
#import "Reachability.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>
#import "AdLandingPageManager.h"
#import "AdMessageModel.h"
#import "AppSettingsModel.h"
#import "NSString+TPHandleNil.h"
#import "VoipUtils.h"
#import "DateTimeUtil.h"


#define COMMERCIAL_SHOW_URL @"http://ws2.cootekservice.com/ad/ed?"
#define COMMERCIAL_CLICK_URL @"http://ws2.cootekservice.com/ad/click?"
//#define COMMERCIAL_CLICK_URL @"http://183.136.223.35:8888/ad/click?"

static CallCommercialManager *sInstance;

@interface CallCommercialManager () <GCDAsyncUdpSocketDelegate>
@property (nonatomic, copy)void(^doneBlock)(void);
@end

@implementation CallCommercialManager {
    udp_response_tData *_model;
    GCDAsyncUdpSocket *_socket;
    NSString *_number;
    NSDictionary *_hosts;
    udp_request_t *_request;
    NSTimer *_timer;
    AdLandingPageManager *_prCallAdLandingPageManager;
    AdShowtimeManager    *_preCallAdShowtimeManager;
    NSMutableDictionary *_commercials;
}


+ (void)initialize {
    sInstance = [[CallCommercialManager alloc] init];
}

+ (CallCommercialManager *)instance {
    return sInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSDictionary *defaultHosts = @{@"113.107.202.66":@(9010), @"120.132.32.210":@(9010), \
                   @"120.132.32.211":@(9010), @"120.132.32.214":@(9010), \
                   @"121.52.250.35":@(9010),@"121.201.55.2":@(9010), \
                   @"121.201.55.3":@(9010),@"211.161.100.114":@(9010), \
                   @"117.135.167.242":@(9010),@"222.73.146.226":@(9010)};
        _hosts = [UserDefaultsManager dictionaryForKey:CALL_AD_UDP_ADDRESSES defaultValue:defaultHosts];
        //_hosts = @{@"120.132.32.210":@(9010)};
        if (_commercials == nil) {
            _commercials = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
    }
    return self;
}

- (void)prepareCommercialFor:(NSString *)number withBlock:(void(^)(void))doneBlock{
    self.doneBlock = doneBlock;
    if (number.length == 0) {
        [self over];
        return;
    }
    _number = [PhoneNumber getCNnormalNumber:number];
    if (_socket) {
        [_socket close];
        if (_timer) {
            [self sendUsageIsTimeOut:YES andErrorCode:0];
            [_timer invalidate];
            _timer = nil;
        }
    }
    [self initSocket];
    [self buildAndSendUdpData];
    
    //如果不是 "只能拨打普通电话"，则尝试请求文字广告，即tu等于kAD_TU_POPUP_TEXT
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
                 && [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
    
    if (isVoipOn && [AppSettingsModel appSettings].dialerMode != DialerModeNormal) {
        [self prepareCommercialForTu:kAD_TU_CALL_POPUP_HTML];
    }
}

- (udp_response_tData *)getCommercialModel {
    return _model;
}


- (void)onShow {
    AdMessageModel *ad = [[AdMessageModel alloc] initWithUdpResponseData:_model  tu:@"2"];
    _preCallAdShowtimeManager = [[AdShowtimeManager alloc] initWithAd:ad];
    [_preCallAdShowtimeManager adDidAppear];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [FunctionUtility visitUrl:[self constructEdUrl]];
    });
}

- (void)onClick {
    if (_model.curl.length > 0) {
        UIViewController *controller = [FunctionUtility openUrl:[self getCurl] withTitle:_model.title];
        AdMessageModel *ad = [[AdMessageModel alloc] initWithUdpResponseData:_model tu:@"2"];
        _prCallAdLandingPageManager = [[AdLandingPageManager alloc] initWithAd:ad webController:controller];
        [self preCallADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [FunctionUtility visitUrl:[self constructCurl]];
        });
    }
}

- (void)preCallADDisappearWithCloseType:(ADCloseType)closeTyep
{
    if (_preCallAdShowtimeManager) {
        [_preCallAdShowtimeManager adDidDisappearWithCloseType:closeTyep];
        _preCallAdShowtimeManager = nil;
    }
}

- (NSString *)constructEdUrl {
    NSString *edUrl = [NSString stringWithFormat:@"%@adid=%d&tu=2&s=%@", [UserDefaultsManager stringForKey:SHOW_COMMERCIAL_URL defaultValue:COMMERCIAL_SHOW_URL], \
                       _model.adid, _model.sid];
    if (_model.hasEdurl && _model.edurl.length > 0) {
        edUrl = [NSString stringWithFormat:@"%@&%@&edurl=%@", edUrl, _model.edurl];
    }
    return edUrl;
}

- (NSString *)constructCurl {
    NSRange     firstDot = [_model.curl rangeOfString:@"."];
    NSRange     lastDot = [_model.curl rangeOfString:@"." options:NSBackwardsSearch];
    
    if ( ! ((firstDot.length > 0) && (lastDot.length > 0) && (firstDot.location < lastDot.location))) {
        return nil;
    }
    
    int iIndex = firstDot.location;
    int kIndex = lastDot.location;
    if (kIndex <= iIndex || iIndex < 0) {
        return nil;
    }
    NSString *iContent = [_model.curl substringToIndex:iIndex];
    iContent = [NSString stringWithFormat:@"s=%@&adid=%d&%@", _model.sid, _model.adid, iContent];
    NSString *jContent = [_model.curl substringWithRange:NSMakeRange(iIndex + 1, kIndex - iIndex - 1)];
    NSString *kContent = [_model.curl substringFromIndex:kIndex + 1];
    NSData *iData = [GTMBase64 encodeData:[iContent dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *jData = [GTMBase64 encodeData:[jContent dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *kData = [GTMBase64 encodeData:[kContent dataUsingEncoding:NSUTF8StringEncoding]];
    
    iContent = [[NSString alloc] initWithData:iData encoding:NSUTF8StringEncoding];
    jContent = [[NSString alloc] initWithData:jData encoding:NSUTF8StringEncoding];
    kContent = [[NSString alloc] initWithData:kData encoding:NSUTF8StringEncoding];
    
    NSString *newCurl = [NSString stringWithFormat:@"%@%@.%@.%@", [UserDefaultsManager stringForKey:CLICK_COMMERCIAL_URL defaultValue:COMMERCIAL_CLICK_URL], \
                         iContent, jContent, kContent];
    return newCurl;
}

- (NSString *)getCurl
{
    // curl:@"bid=1000.curl$=https://www.91zhiwang.com/m/register?target=register&zw_channel=zzcm.at=1&tu=2"
    // 形式如  i.j.k,其中 j 为"curl$=xxx$&key1$=value1$&key2$=vaule2" 用 $& 分割不同的字段，用$=分割key和value

    const NSString *const model_curl = _model.curl;

    NSRange firstDot = [model_curl rangeOfString:@"."];
    NSRange lastDot = [model_curl rangeOfString:@"." options:NSBackwardsSearch];

    if (!((firstDot.length > 0) && (lastDot.length > 0) && (firstDot.location < lastDot.location))) {
        cootek_log(@"getCurl curl error %@",model_curl);
        return nil;
    }

    NSString            *clickString = nil;
    NSMutableDictionary *jDic = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString            *jContent = [model_curl substringWithRange:NSMakeRange(firstDot.location + 1, lastDot.location - firstDot.location - 1)];

    NSArray *jContentList = [jContent componentsSeparatedByString:@"$&"];

    for (NSString *str in jContentList) {
        NSArray *jKeyAndValue = [str componentsSeparatedByString:@"$="];
        if ([jKeyAndValue count] == 1) {
            [jDic setObject:@"" forKey:jKeyAndValue[0]];
        }else if ([jKeyAndValue count] >= 2) {
            [jDic setObject:jKeyAndValue[1] forKey:jKeyAndValue[0]];
        } else {
            cootek_log(@"getCurl error %@", jKeyAndValue);
        }
    }

    clickString = jDic[@"curl"];
    return clickString;
}

- (void)initSocket{
    _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [_socket bindToPort:0 error:&error];
    [_socket beginReceiving:&error];
}

- (network_type_t)getNetType {
    ClientNetworkType type =[Reachability network];
    switch (type) {
        case network_2g:
            return network_type_tTwoG;
        case network_3g:
            return network_type_tThreeG;
        case network_4g:
            return network_type_tFourG;
        case network_wifi:
            return network_type_tWifi;
        default:
            return network_type_tDefaultNetworkType;
    }
}

- (void)buildAndSendUdpData {
    float delay = 0.2;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [self timeUp];
        cootek_log(@"udp data wait time out");
    });
    //for usage record, wait for 30 secondes for the response data
    _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if ([data length] > 4 && _model == nil) {
        NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
        unsigned short len = CFSwapInt16LittleToHost(*(unsigned short *)[lengthData bytes]);
        if (len == data.length - 4) {
            udp_response_t *response = [udp_response_t parseFromData:[data subdataWithRange:NSMakeRange(4, len)]];
            if (response.data.count > 0) {
                _model = [response dataAtIndex:0];
                _prCallAdLandingPageManager = nil;
            }
            [self sendUsageIsTimeOut:NO andErrorCode:response.errorCode];
            cootek_log(@"udp data response size: %d, error code: %d", response.data.count, response.errorCode);
        }
#ifdef DEBUG
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        cootek_log(@"from host: %@, and port: %u", host, port);
#endif
    }
    [_socket close];
    _socket = nil;
    [_timer invalidate];
    _timer = nil;
    [self over];
}

- (void)timeOut {
    [self sendUsageIsTimeOut:YES andErrorCode:0];
    [_timer invalidate];
    _timer = nil;
}

- (void)timeUp {
    if (_socket) {
        [self over];
    }
}

- (void)over{
    if (_doneBlock) {
        _doneBlock();
    }
    _doneBlock = nil;
}

- (void)sendUsageIsTimeOut:(BOOL)timeOut andErrorCode:(int)errCode{
    double current = [[NSDate date] timeIntervalSince1970];
    long ts = (long)(current*1000 - _request.prt);
    if (timeOut) {
        ts = 30 * 1000;
    }
    
    [DialerUsageRecord recordpath:PATH_AD_UDP kvs:Pair(@"c", COOTEK_APP_NAME), Pair(@"v", CURRENT_TOUCHPAL_VERSION), Pair(@"prt", @(_request.prt)),Pair(@"at",@"TXT"), Pair(@"tu",@"2"), Pair(@"adn",@(1)), Pair(@"adclass",@"EMBEDDED"), Pair(@"nt",[[FunctionUtility networkType] uppercaseString]), Pair(@"rt",@"JSON"), Pair(@"w",@(_request.w)), Pair(@"h",@(_request.h)), Pair(@"city",_request.city), Pair(@"addr",_request.addr), Pair(@"longtitude",@(_request.longtitude)), Pair(@"latitude", @(_request.latitude)), Pair(@"other_phone", _request.otherPhone), Pair(@"call_type", @"outgoing"), Pair(@"s",[self safeString:_model.sid]), Pair(@"adid",@(_model.adid)), Pair(@"ts",@(ts)), Pair(@"err",@(errCode)), Pair(@"tn",[NSNull null]), Pair(@"ip",_request.ip), Pair(@"token",_request.token), nil];
    [UsageRecorder send];
}

- (NSString *)safeString:(NSString *)string {
    if (string == nil) {
        return @"";
    }
    return string;
}

- (void) prepareCommercialForTu:(NSString *)tu {
    if ([NSString isNilOrEmpty:tu]) {
        return;
    }
    
    id value = nil;
    switch([tu intValue]) {
        case 36: {
            /* kAD_TU_POPUP_CALL_HTML */
            if ([VoipUtils isCommercialCacheReadyForTu:tu]) {
                value = [VoipUtils popupHTMLName];
                cootek_log(@"ad_pu, isCommercialCacheReadyForTu, %@", value);
            }
            break;
        }
        default: {
            break;
        }
    }
    if (value == nil) {
        value = @"";
    }
    [_commercials setObject:value forKey:tu];
}

- (id) getCommercialForTu:(NSString *)tu {
    if ([NSString isNilOrEmpty:tu]) {
        return nil;
    }
    return [_commercials objectForKey:tu];
}

- (void) removeCommercialForTu:(NSString *)tu shouldDeleteFile:(BOOL)shouldDelete {
    if ([NSString isNilOrEmpty:tu]) {
        return ;
    }
    switch (tu.intValue) {
        case 36: {
            if (shouldDelete) {
                NSString *fileName = [_commercials objectForKey:tu];
                NSString *dir = [VoipUtils absoluteCommercialDirectoryPath:ADResource];
                if (fileName != nil && dir != nil) {
                    NSString *path =  [dir stringByAppendingPathComponent:fileName];
                    if (path != nil) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            [FileUtils removeFileInAbsolutePath:path];
                            cootek_log(@"ad_pu, removeCommercialForTu, remove html: %@", fileName);
                            [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_READY];
                        });

                    }
                }
            }
            
            break;
        }
        default:
            break;
    }
    
    [_commercials removeObjectForKey:tu];
}

- (NSString *) getCachedAdidByTu:(NSString *)tu {
    NSString *adid = nil;
    if (![NSString isNilOrEmpty:tu]) {
        NSDictionary *ad = [VoipUtils firstADFromHTMLFileAtTu:tu];
        if (ad != nil) {
            adid = [ad objectForKey:@"ad_id"];
        }
    }
    return [NSString nilToEmpty:adid];
}

@end
