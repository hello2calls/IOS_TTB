//
//  CTUrl.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-10.
//
//
#import "CTUrl.h"
#import "SeattleFeatureExecutor.h"
#import "LocalStorage.h"
#import "YellowPageWebViewController.h"
#import "UIDataManager.h"
#import "YellowPageMainTabController.h"
#import "BasicUtil.h"
#import "NSDictionary+Default.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultKeys.h"
#import "SeattleFeatureExecutor.h"
#import "CommonCrypto/CommonDigest.h"
#import "CategoryExtendViewController.h"
#import "RootScrollViewController.h"
#import "AllServiceViewController.h"
#import "ControllerManager.h"
#import "FindNewsListViewController.h"
#import "NSString+MD5.h"

@implementation CTUrl

- (id) init
{
    self = [super init];
    if (self) {
        self.newWebView = YES;
        self.allowsInlineMediaPlayback = YES;
    }
    
    return self;
}

- (id) initWithUrl:(NSString *)url
{
    self = [super init];
    self.url = url;
    self.isPost = NO;
    self.newWebView = YES;
    self.allowsInlineMediaPlayback = YES;
    return self;
}

- (id) initBeyondYellowPageWithUrl:(NSString *)url andLocalUrl:(NSString *)localUrl andController:(NSString *)controller andParams:(NSString *)params andNativeParams:(NSArray *)nativeParams andNeedWrap:(BOOL)needWrap andNeedLogin:(BOOL)needLogin andNeedSign:(BOOL)needSign andExternal:(BOOL)external andTitleBar:(NSString *)titleBar andQuitAlert:(NSString *) quitAlert
{
    self = [super init];
    self.url = url;
    self.localUrl = localUrl;
    self.controller = controller;
    self.params = params;
    self.nativeParams = nativeParams;
    self.needWrap = needWrap;
    self.needLogin = needLogin;
    self.needSign = needSign;
    self.external = external;
    self.titleBar = titleBar;
    self.quitAlert = quitAlert;
    self.isPost = NO;
    self.showFloatingPoint = NO;
    self.sendToDeskTop = NO;
    self.newWebView = YES;
    self.loadLocalJs = NO;
    self.allowsInlineMediaPlayback = YES;
    return self;
}

- (id) initWithJson:(NSDictionary *)json
{
    self = [super init];
    self.url = [json objectForKey:@"url"];
    self.localUrl = [json objectForKey:@"localUrl"];
    self.controller = [json objectForKey:@"controller"];
    self.params = [json objectForKey:@"params"];
    self.nativeParams = [json objectForKey:@"nativeParams"];
    self.needWrap = [json objectForKey:@"needWrap" withDefaultBoolValue:YES];
    self.needLogin = [json objectForKey:@"needLogin" withDefaultBoolValue:NO];
    self.needSign = [json objectForKey:@"needSign" withDefaultBoolValue:NO];
    self.external = [json objectForKey:@"external" withDefaultBoolValue:NO];
    self.titleBar = [json objectForKey:@"titleBar"];
    self.quitAlert = [json objectForKey:@"quitAlert"];
    self.newWebView = [json objectForKey:@"newWebView" withDefaultBoolValue:YES];
    self.fullScreen = [json objectForKey:@"screenFullIOS" withDefaultBoolValue:NO];
    self.landscape = [json objectForKey:@"screenSelfAdjust" withDefaultBoolValue:NO];
    self.backConfirm = [json objectForKey:@"backOnceQuitConfirm" withDefaultBoolValue:NO];
    self.needTitle = [json objectForKey:@"needTitle" withDefaultBoolValue:YES];
    self.loadLocalJs = [json objectForKey:@"loadLocalJs" withDefaultBoolValue:NO];
    self.allowsInlineMediaPlayback = [json objectForKey:@"allowsInlineMediaPlayback" withDefaultBoolValue:YES];
    self.showFloatingPoint = [json objectForKey:@"showFloatingPointIOS" withDefaultBoolValue:NO];
    self.shortCutTitle = [json objectForKey:@"shortCutTitle"];
    self.shortCutIcon = [json objectForKey:@"shortCutIcon"];
    self.nativeUrl = [json objectForKey:@"nativeUrl"];
    
    self.isPost = NO;
    
    return self;
}

- (NSDictionary*)jsonFromCTUrl
{
    NSMutableDictionary* json = [[NSMutableDictionary alloc]init];
    [json setValue:self.url forKey:@"url"];
    [json setValue:self.localUrl forKey:@"localUrl"];
    [json setValue:self.controller forKey:@"controller"];
    [json setValue:self.params forKey:@"params"];
    [json setValue:self.nativeParams forKey:@"nativeParams"];
    [json setValue:[NSNumber numberWithBool:self.needWrap] forKey:@"needWrap"];
    [json setValue:[NSNumber numberWithBool:self.needLogin] forKey:@"needLogin"];
    [json setValue:[NSNumber numberWithBool:self.needSign] forKey:@"needSign"];
    [json setValue:[NSNumber numberWithBool:self.external] forKey:@"external"];
    [json setValue:self.titleBar forKey:@"titleBar"];
    [json setValue:self.quitAlert forKey:@"quitAlert"];
    [json setValue:[NSNumber numberWithBool:self.isPost] forKey:@"isPost"];
    [json setValue:[NSNumber numberWithBool:self.newWebView] forKey:@"newWebView"];
    [json setValue:[NSNumber numberWithBool:self.fullScreen] forKey:@"screenFullIOS"];
    [json setValue:[NSNumber numberWithBool:self.landscape] forKey:@"screenSelfAdjust"];
    [json setValue:[NSNumber numberWithBool:self.backConfirm] forKey:@"backOnceQuitConfirm"];
    [json setValue:[NSNumber numberWithBool:self.needTitle] forKey:@"needTitle"];
    [json setValue:[NSNumber numberWithBool:self.loadLocalJs] forKey:@"loadLocalJs"];
    [json setValue:[NSNumber numberWithBool:self.showFloatingPoint] forKey:@"showFloatingPointIOS"];
    [json setValue:[NSNumber numberWithBool:self.sendToDeskTop] forKey:@"sendToDeskTop"];
    [json setValue:self.shortCutTitle forKey:@"shortCutTitle"];
    [json setValue:self.shortCutIcon forKey:@"shortCutIcon"];
    [json setValue:self.nativeUrl forKey:@"nativeUrl"];
    [json setValue:[NSNumber numberWithBool:self.allowsInlineMediaPlayback] forKey:@"allowsInlineMediaPlayback"];
    
    return json;
    
}

- (NSString*) urlWrapper
{
    NSString* ret = self.url;
    if ([self.url rangeOfString:@"?"].location == NSNotFound) {
        ret = [ret stringByAppendingString:@"?"];
    } else {
        ret = [ret stringByAppendingString:@"&"];
    }
    if (self.params && self.params.length > 0) {
        ret = [ret stringByAppendingFormat:@"%@&", self.params];
    }
    
    if (self.nativeParams && self.nativeParams.count > 0) {
        for (NSString* key in self.nativeParams) {
            NSString* value = [LocalStorage getItemWithKey:key];
            if (value) {
                ret = [ret stringByAppendingFormat:@"%@=%@&", key, value ? value : @""];
            }
        }
    }
    
    if (self.needWrap) {
        ret = [ret stringByAppendingFormat:@"_v=3&_token=%@&",[SeattleFeatureExecutor getToken]];
    }
    
    if (self.needSign) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        ret = [ret stringByAppendingFormat:@"_ts=%.0f&",interval];
        ret = [ret stringByAppendingFormat:@"_sign=%@&", [CTUrl signWithUrl:ret andNeedLogin:self.needLogin andTS:interval]];
    }
    
    ret = [ret substringToIndex:ret.length - 1];
    
    return ret;
}

+ (NSString *) signWithUrl:(NSString *)url andNeedLogin:(BOOL)needLogin andTS:(NSTimeInterval) interval
{
    //    NSString* reqStr = @"";
    //
    //    NSArray* urlParam = [url componentsSeparatedByString:@"?"];
    //    if (urlParam.count > 1 && [[urlParam objectAtIndex:1] length] > 0) {
    //        NSArray* params = [[urlParam objectAtIndex:1] componentsSeparatedByString:@"&"];
    //        for (NSString* param in params) {
    //            NSArray* eachParam = [param componentsSeparatedByString:@"="];
    //            if (eachParam.count > 1) {
    //                reqStr = [NSString stringWithFormat:@"%@%@=%@&", reqStr, eachParam[0], eachParam[1]];
    //            }
    //        }
    //    }
    //
    //    reqStr = [NSString stringWithFormat:@"%@%@=%.0f&", reqStr, @"_ts", interval];
    //
    //    NSString* forPath = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    //    NSRange rage = [forPath rangeOfString:@"/"];
    //    NSString* pathWithParam = [forPath substringFromIndex:rage.location];
    //    NSString* path = [[pathWithParam componentsSeparatedByString:@"?"] objectAtIndex:0];
    //
    //    NSString* isPostP = self.isPost ? @"POST&" : @"GET&";
    //    NSString* signStr = [NSString stringWithFormat:@"%@%@&%@", isPostP, path, reqStr];
    //    signStr = [CTUrl toBase64MD5:signStr];
    //    signStr = [[signStr stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    //    signStr = [signStr substringToIndex:signStr.length - 3];
    //    return signStr;
    return @"";
}


+ (NSString *) toBase64MD5:(NSString *)signStr
{
    return [signStr MD5Hash];
}

- (void) addOtherParams {
    if (_url == nil) {
        return;
    }
    if ([_url rangeOfString:@"?"].length == 0) {
        _url = [NSString stringWithFormat:@"%@?_=1", _url];//useless query string, just for the "?"
    }
    long long now = [[NSDate date] timeIntervalSince1970]*1000;
    if (now - [[LocalStorage getItemWithKey:NATIVE_PARAM_CITY_CACHE_TIME] longLongValue] <= 3*86400*1000) {
        NSString *city = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
        if (city.length > 0) {
            _url = [NSString stringWithFormat:@"%@&city=%@", _url, city];
        }
    }
    if ([_url rangeOfString:@"token="].length == 0) {
        _url = [NSString stringWithFormat:@"%@&auth_token=%@", _url, [SeattleFeatureExecutor getToken]];
    }
}

- (UIViewController *) startWebView
{
    [[UIDataManager instance] addUserAgent];
    [UIDataManager instance].startRecordTime = [[NSDate date] timeIntervalSince1970] * 1000;
    if ([[self.nativeUrl allKeys]containsObject:@"ios"]) {
        UIViewController *nativeController = [ControllerManager pushAndGetController:[self.nativeUrl objectForKey:@"ios"]];
        return nativeController;
    } else {
        return [self startWebViewFromUrl];
    }
}

- (UIViewController *) startWebViewFromUrl
{
    //    FindNewsListViewController* controller = [FindNewsListViewController new];
    //    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
    //    return controller;
    YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
    controller.usingWkWebview = self.newWebView;
    controller.backConfirm = self.backConfirm;
    controller.landscape = self.landscape;
    controller.fullScreen = self.fullScreen;
    controller.backConfirmTitle = self.quitAlert;
    controller.needTitle = self.needTitle;
    controller.showFloatingPoint = self.showFloatingPoint;
    controller.ctUrl = self;
    controller.injectJavascript = self.loadLocalJs;
    NSString* url = [self urlWrapper];
    controller.url_string = [CTUrl encodeRequestUrl:url];
    controller.serviceId = self.serviceId;
    controller.allowsInlineMediaPlayback = self.allowsInlineMediaPlayback;
    controller.needFontSettings = self.needFontSizeSettings;
    controller.isNews = self.isNews;
    
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    
    if([[[TouchPalDialerAppDelegate naviController] visibleViewController] isKindOfClass:[RootScrollViewController class]]
       || [[[TouchPalDialerAppDelegate naviController] visibleViewController] isKindOfClass:[CategoryExtendViewController class]]
       || [[[TouchPalDialerAppDelegate naviController] visibleViewController] isKindOfClass:[AllServiceViewController class]]) {
        [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
    } else {
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
    return controller;
    
}

+ (NSString *)encodeUrl:(NSString*)url
{
    NSString* output = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)url, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return output;
}

+ (NSString *)encodeRequestUrl:(NSString*)url
{
    NSString* output = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)url, (CFStringRef)@"!*'();:@&=+$,/?%#[]", NULL, kCFStringEncodingUTF8);
    return output;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    CTUrl* ret = [[[self class] alloc] init];
    ret.url = [self.url copyWithZone:zone];
    ret.localUrl = [self.localUrl copyWithZone:zone];
    ret.controller = [self.controller copyWithZone:zone];
    ret.params = [self.params copyWithZone:zone];
    ret.nativeParams = [self.nativeParams copyWithZone:zone];
    ret.needWrap = self.needWrap;
    ret.needLogin = self.needLogin;
    ret.needSign = self.needSign;
    ret.external = self.external;
    ret.titleBar = [self.titleBar copyWithZone:zone];
    ret.navigateBar = self.navigateBar;
    ret.quitAlert = self.quitAlert;
    ret.fullScreen = self.fullScreen;
    ret.landscape = self.landscape;
    ret.showFloatingPoint = self.showFloatingPoint;
    ret.sendToDeskTop = self.sendToDeskTop;
    ret.shortCutTitle = [self.shortCutTitle copyWithZone:zone];
    ret.shortCutIcon = [self.shortCutIcon copyWithZone:zone];
    ret.serviceId = [self.serviceId copyWithZone:zone];
    ret.isPost = self.isPost;
    ret.newWebView = self.newWebView;
    ret.nativeUrl = self.nativeUrl;
    ret.needTitle = self.needTitle;
    ret.allowsInlineMediaPlayback = self.allowsInlineMediaPlayback;
    ret.isNews = self.isNews;
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    CTUrl* ret = [[[self class] alloc] init];
    ret.url = [self.url mutableCopyWithZone:zone];
    ret.localUrl = [self.localUrl mutableCopyWithZone:zone];
    ret.controller = [self.controller mutableCopyWithZone:zone];
    ret.params = [self.params mutableCopyWithZone:zone];
    ret.nativeParams = [self.nativeParams mutableCopyWithZone:zone];
    ret.needWrap = self.needWrap;
    ret.needLogin = self.needLogin;
    ret.needSign = self.needSign;
    ret.external = self.external;
    ret.titleBar = [self.titleBar mutableCopyWithZone:zone];
    ret.navigateBar = self.navigateBar;
    ret.quitAlert = self.quitAlert;
    ret.fullScreen = self.fullScreen;
    ret.landscape = self.landscape;
    ret.showFloatingPoint = self.showFloatingPoint;
    ret.sendToDeskTop = self.sendToDeskTop;
    ret.shortCutTitle = [self.shortCutTitle mutableCopyWithZone:zone];
    ret.shortCutIcon = [self.shortCutIcon mutableCopyWithZone:zone];
    ret.serviceId = [self.serviceId mutableCopyWithZone:zone];
    ret.isPost = self.isPost;
    ret.newWebView = self.newWebView;
    ret.nativeUrl = self.nativeUrl;
    ret.needTitle = self.needTitle;
    ret.allowsInlineMediaPlayback = self.allowsInlineMediaPlayback;
    ret.isNews = self.isNews;
    
    return ret;
}

- (BOOL) isValid
{
    if (self.url.length > 0) {
        return YES;
    }
    return NO;
}


#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.localUrl = [aDecoder decodeObjectForKey:@"localUrl"];
        self.controller = [aDecoder decodeObjectForKey:@"controller"];
        self.params = [aDecoder decodeObjectForKey:@"params"];
        self.nativeParams = [aDecoder decodeObjectForKey:@"nativeParams"];
        self.needWrap = [aDecoder decodeBoolForKey:@"needWrap"];
        self.needLogin = [aDecoder decodeBoolForKey:@"needLogin"];
        self.needSign = [aDecoder decodeBoolForKey:@"needSign"];
        self.external = [[aDecoder decodeObjectForKey:@"external"] boolValue];
        self.titleBar = [aDecoder decodeObjectForKey:@"titleBar"];
        self.navigateBar = [aDecoder decodeBoolForKey:@"navigateBar"];
        self.quitAlert = [aDecoder decodeObjectForKey:@"quitAlert"];
        self.landscape = [aDecoder decodeBoolForKey:@"landscape"];
        self.fullScreen = [aDecoder decodeBoolForKey:@"fullScreen"];
        self.backConfirm = [aDecoder decodeBoolForKey:@"backConfirm"];
        self.showFloatingPoint = [aDecoder decodeBoolForKey:@"showFloatingPoint"];
        self.sendToDeskTop = [aDecoder decodeBoolForKey:@"sendToDeskTop"];
        self.shortCutTitle = [aDecoder decodeObjectForKey:@"shortCutTitle"];
        self.shortCutIcon = [aDecoder decodeObjectForKey:@"shortCutIcon"];
        self.serviceId = [aDecoder decodeObjectForKey:@"serviceId"];
        self.isPost = [aDecoder decodeBoolForKey:@"isPost"];
        self.newWebView = [aDecoder decodeBoolForKey:@"newWebView"];
        self.nativeUrl = [aDecoder decodeObjectForKey:@"nativeUrl"];
        self.needTitle = [aDecoder decodeBoolForKey:@"needTitle"];
        self.allowsInlineMediaPlayback = [aDecoder decodeBoolForKey:@"allowsInlineMediaPlayback"];
        self.isNews = [aDecoder decodeBoolForKey:@"isNews"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.localUrl forKey:@"localUrl"];
    [aCoder encodeObject:self.controller forKey:@"controller"];
    [aCoder encodeObject:self.params forKey:@"params"];
    [aCoder encodeObject:self.nativeParams forKey:@"nativeParams"];
    [aCoder encodeBool:self.needWrap forKey:@"needWrap"];
    [aCoder encodeBool:self.needLogin forKey:@"needLogin"];
    [aCoder encodeBool:self.needSign forKey:@"needSign"];
    [aCoder encodeBool:self.external forKey:@"external"];
    [aCoder encodeObject:self.titleBar forKey:@"titleBar"];
    [aCoder encodeBool:self.navigateBar forKey:@"navigateBar"];
    [aCoder encodeObject:self.quitAlert forKey:@"quitAlert"];
    [aCoder encodeBool:self.backConfirm forKey:@"backConfirm"];
    [aCoder encodeBool:self.showFloatingPoint forKey:@"showFloatingPoint"];
    [aCoder encodeBool:self.sendToDeskTop forKey:@"sendToDeskTop"];
    [aCoder encodeObject:self.shortCutTitle forKey:@"shortCutTitle"];
    [aCoder encodeObject:self.shortCutIcon forKey:@"shortCutIcon"];
    [aCoder encodeBool:self.landscape forKey:@"landscape"];
    [aCoder encodeBool:self.fullScreen forKey:@"fullScreen"];
    [aCoder encodeObject:self.serviceId forKey:@"serviceId"];
    [aCoder encodeBool:self.isPost forKey:@"isPost"];
    [aCoder encodeBool:self.newWebView forKey:@"newWebView"];
    [aCoder encodeObject:self.nativeUrl forKey:@"nativeUrl"];
    [aCoder encodeBool:self.needTitle forKey:@"needTitle"];
    [aCoder encodeBool:self.allowsInlineMediaPlayback forKey:@"allowsInlineMediaPlayback"];
    [aCoder encodeBool:self.isNews forKey:@"isNews"];
}

@end
