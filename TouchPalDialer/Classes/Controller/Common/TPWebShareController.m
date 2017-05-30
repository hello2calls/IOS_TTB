//
//  TPWebShareController.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/3.
//
//

#import "TPWebShareController.h"
#import "TPShareController.h"
#import "QQShareController.h"
#import "TPMFMessageActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "CootekNotifications.h"
#import "TPAnalyticConstants.h"
#import "GroupOperationCommandCreator.h"


#define kWECHAT         @"wechat"
#define kTIMELINE       @"timeline"
#define kQQ             @"qq"
#define kQZONE          @"qzone"
#define kCLIPBOARD      @"clipboard"
#define kSMS            @"sms"
#define kWEIBO          @"weibo"

#define kApproach       @"approach"
#define kShareParam     @"json"

#define kParamTitle     @"title"
#define kParamContent   @"content"
#define kParamUrl       @"url"
#define kParamImageUrl  @"image_url"
#define kParamFrom      @"from"       // this is determined by the server side
#define kParamKeepOrgUrl @"keep_org_url"
#define kParamSMSReciver @"share_dest"
#define kParamShareFrom @"share_from"  // the page from where you reach this web page

#define kShareResult    @"result"
#define kShareError     @"error"

#define kShareDefaultUrl @"http://dialer.cdn.cootekservice.com/web/external/dec2/index.html"

@implementation TPWebShareController

+ (TPWebShareController *)controller
{
    static TPWebShareController *_shareInstance;
    static dispatch_once_t      once;

    dispatch_once(&once, ^{
        _shareInstance = [[TPWebShareController alloc] init];
    });
    return _shareInstance;
}

- (void)handleJSCallWithParam:(id)param responseCallback:(WVJBResponseCallback)responseCallback
{
    NSString        *approach = nil;
    NSDictionary    *jsonParam = nil;

    if (param && [param isKindOfClass:[NSDictionary class]]) {
        approach = param[kApproach];
        id json = param[kShareParam];

        if ([json isKindOfClass:[NSString class]]) {
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            jsonParam = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers| NSJSONReadingMutableLeaves error:&error];

        } else if ([json isKindOfClass:[NSDictionary class]]) {
            jsonParam = json;
        } else {
            jsonParam = nil;
        }
    }

    ShareResultCallback callBack = ^(ShareResult ret, NSString *source, NSString *error) {
        if (responseCallback) {
            responseCallback(@{kApproach:approach ? : @"", kShareResult:@(ret), kShareError:error ? : @""});
        }
        cootek_log(@"TPWebShareController, shareFrom: %@", jsonParam[kParamShareFrom]);
        if ([jsonParam[kParamShareFrom] isEqualToString:CONTACT_DETAIL]) {
            [UserDefaultsManager setBoolValue:YES forKey:INVITING_IN_CONTACT_SUCCEED];
            [[NSNotificationCenter defaultCenter]
                postNotificationName:N_INVITING_IN_CONATCT_DETAIL_SUCCEED object:nil];
        }
    };

    if (!approach || ([jsonParam count] == 0)) {
        callBack(ShareFail, nil, @"参数错误");
        return;
    }

    NSString    *title       = jsonParam[kParamTitle];
    NSString    *msg         = jsonParam[kParamContent];
    NSString    *url         = jsonParam[kParamUrl];
    NSString    *imageUrl    = jsonParam[kParamImageUrl];
    NSString    *shareFrom   = jsonParam[kParamShareFrom];
    BOOL        isKeepOrgUrl = [jsonParam[kParamKeepOrgUrl] boolValue];
    cootek_log(@"TPWebShareController, jsonParam: %@", jsonParam);
    if (url.length == 0) {
        callBack(ShareFail, nil, @"参数错误");
        return;
    }
    
    if (!isKeepOrgUrl) {
        url = [self generateUrl:url approach:approach];
    }
    if ([approach isEqualToString:kWECHAT]) {
        [self shareByWeixin:title andDescription:msg andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom resultCallback:[callBack copy]];
    } else if ([approach isEqualToString:kTIMELINE]) {
        [self shareByWeixinTimeline:title andDescription:nil andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom resultCallback:[callBack copy]];
    } else if ([approach isEqualToString:kQQ]) {
        [self shareByQQ:title andDescription:msg andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom resultCallback:[callBack copy]];
    } else if ([approach isEqualToString:kQZONE]) {
        [self shareByQQZone:title andDescription:nil andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom resultCallback:[callBack copy]];
    } else if ([approach isEqualToString:kSMS]) {
        NSString *message = title;
        if (msg) {
            message = [title stringByAppendingString:msg];

        }
        NSString *phoneNum = jsonParam[kParamSMSReciver];
        [self shareSMS:url andNeedDefault:NO andMessage:message andNumber:phoneNum andFromWhere:shareFrom resultCallback:[callBack copy]];
    } else if ([approach isEqualToString:kCLIPBOARD]) {
        [self sharePasteboard:url andNeedDefault:NO andFromWhere:shareFrom title:nil resultCallback:[callBack copy]];
    } else {
        callBack(ShareFail, nil, @"不支持的分享方式");
        return;
    }
}

- (void)shareSMS:(NSString *)smsUrl andNeedDefault:(BOOL)needDefault andMessage:(NSString *)msg andNumber:(NSString *)phoneNumber andFromWhere:(NSString *)fromWhere resultCallback:(ShareResultCallback)resultBack
{
    [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url) {
        if (needDefault && [smsUrl isEqualToString:url]) {
            url = @"http://t.cn/Rz2PYLn";
        }
         NSString *message = [NSString stringWithFormat:@"%@ %@", msg, url];
        [GroupOperationCommandCreator executeCommandWithTitle:@"群发短信" message:message resultCallback:resultBack];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_SMS, fromWhere), nil];

    }];
   
}

- (void)sharePasteboard:(NSString *)smsUrl andNeedDefault:(BOOL)needDefault andFromWhere:(NSString *)fromWhere title:(NSString *)title resultCallback:(ShareResultCallback)resultBack
{
    [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url) {
        if ((needDefault && [smsUrl isEqualToString:url])) {
            url = @"http://t.cn/Rzt2p5m";
        }

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
        if (title == nil) {
            pasteboard.string = [NSString stringWithFormat:NSLocalizedString(@"voip_copy_share_message", @""), [UserDefaultsManager stringForKey:VOIP_INVITATION_CODE], url];
            cootek_log(pasteboard.string);
        } else if ([title rangeOfString:@"骚扰"].length) {
            pasteboard.string = [NSString stringWithFormat:@"%@ %@", title, url];
        } else {
            pasteboard.string = [NSString stringWithFormat:NSLocalizedString(title, @""), [UserDefaultsManager stringForKey:VOIP_INVITATION_CODE], url];
        }

        if (resultBack) {
            resultBack(ShareSuccess, nil, nil);
        }

        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_copy_success", @"") message:nil];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_COPY, fromWhere), nil];
    }];
}

- (void)shareByWeixin:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere resultCallback:(ShareResultCallback)resultBack
{
    [FunctionUtility downloadImage:imageUrl usingBlock:^(UIImage *downloadImage){
        [[TPShareController controller] voipWechatShare:title andDescription:msg andUrl:url andImage:downloadImage andIfTimeLine:NO resultCallback:resultBack];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_WECHAT, fromWhere), nil];
    }];
    
}

- (void)shareByWeixinTimeline:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere resultCallback:(ShareResultCallback)resultBack
{
    [FunctionUtility downloadImage:imageUrl usingBlock:^(UIImage *downloadImage){
        [[TPShareController controller] voipWechatShare:title andDescription:msg andUrl:url andImage:downloadImage andIfTimeLine:YES resultCallback:resultBack];
        [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_TIMELINE_WECHAT, fromWhere), nil];
    }];
}

- (void)shareByQQ:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere resultCallback:(ShareResultCallback)resultBack
{
    [[QQShareController instance] shareQQMessage:title andDescription:msg andUrl:url andImageUrl:imageUrl andIfQQZone:NO resultCallback:resultBack];
    [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_SINGLE_QQ, fromWhere), nil];
}

- (void)shareByQQZone:(NSString *)title andDescription:(NSString *)msg andUrl:(NSString *)url andImageUrl:(NSString *)imageUrl andFromWhere:(NSString *)fromWhere resultCallback:(ShareResultCallback)resultBack
{
    [[QQShareController instance] shareQQMessage:title andDescription:msg andUrl:url andImageUrl:imageUrl andIfQQZone:YES resultCallback:resultBack];
    [DialerUsageRecord recordpath:EV_VOIP_SHARE kvs:Pair(EV_VOIP_SHARE_QZONE_QQ, fromWhere), nil];
}

- (NSString *)generateUrl:(NSString *)url approach:(NSString *)approach
{
    NSDictionary *temptIdDic = @{kWECHAT   :@"weixin020",
                                 kTIMELINE :@"timeline020",
                                 kQQ       :@"qq020",
                                 kQZONE    :@"qzone020",
                                 kCLIPBOARD:@"clipboard020",
                                 kSMS      :@"sms020",
                                 kWEIBO    :@"weibo020"};
    NSDictionary *fromWhereDic = @{kWECHAT   :@"friends",
                                   kTIMELINE :@"timeline",
                                   kQQ       :@"qq",
                                   kQZONE    :@"qzone",
                                   kCLIPBOARD:@"clipboard",
                                   kSMS      :@"sms",
                                   kWEIBO    :@"weibo"};

    if (approach.length == 0 || url.length == 0) {
        return url;
    }

    return [FunctionUtility generateUrlMessage:url andTemptId:temptIdDic[approach] andFrom:fromWhereDic[approach]];
}

@end
