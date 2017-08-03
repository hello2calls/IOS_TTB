//
//  NoahWebHandler.m
//  TouchPalDialer
//
//  Created by game3108 on 15/2/2.
//
//

#import "CootekWebHandler.h"
#import "UserDefaultsManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalVersionInfo.h"
#import "EditVoipViewController.h"
#import "SeattleFeatureExecutor.h"
#import "TPShareController.h"
#import "DialerUsageRecord.h"
#import "VoipShareView.h"
#import "LoginController.h"
#import "FreeCallLoginController.h"
#import "FunctionUtility.h"
#import "TPShareController.h"
#import "TPDialerResourceManager.h"
#import <TAESDK/TaeWebViewUISettings.h>
#import "DefaultUIAlertViewHandler.h"
#import "LoginController.h"
#import "CallFlowPacketLoginController.h"
#import "FlowEditViewController.h"
#import "FlowInputNameView.h"
#import "Reachability.h"
#import "HandlerWebViewController.h"
#import "VoipShareAllView.h"
#import "AlipayController.h"
#import "ScheduleInternetVisit.h"
#import "VoipFeedbackInfo.h"
#import "LocalStorage.h"
#import "TaskBonusManager.h"
#import "RootScrollViewController.h"
#import "MarketLoginController.h"
#import "IndexConstant.h"
#import "ScanRootViewController.h"
#import "TouchLifeShareMgr.h"
#import "YellowPageLocationManager.h"
#import "YellowPageWebViewController.h"
#import "DownloadOtherAppController.h"
#import "QQShareController.h"
#import "TPMFMessageActionController.h"
#import "ControllerManager.h"
#import "TPWebShareController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"
#import "DialerViewController.h"
#import "VoipInvitationCodeView.h"
#import "CallViewController.h"
#import "SingleGuideViewWithBaozai.h"
#import "NSString+TPHandleNil.h"
#import "ControllerManager.h"
#import "TPAnalyticConstants.h"
#import "HangupCommercialManager.h"
#import "SelectController.h"
#import "YellowPageWebViewController.h"
#import "SkinDownloadManager.h"
#import "ContactInfoModelUtil.h"
#import "PhoneNumber.h"
#import "NumberPersonMappingModel.h"
#import "AdStatManager.h"
#import "TPDLib.h"
#import "TPDPhoneCallViewController.h"
#import "TPDContactsViewController.h"
#import "PersonDBA.h"
#import "ContactCacheDataManager.h"
#import "PersonalCenterUtility.h"
#import "DTBase64Coding.h"
#import "BiBiPairManager.h"

@interface CootekWebHandler()
@property(nonatomic, retain) NSString *callmethodString;
@property(nonatomic, retain) NSString *locateCallmethodString;
@property(nonatomic, retain) NSString *gpsCallmethodString;
@end

@implementation CootekWebHandler{
    NSString __strong *sourceName;
    NSObject<WebViewJavascriptBridgeProvider> __strong *bridge;
    UIViewController __weak *contro;
    UIView<FLWebViewProvider>* __weak web_view;
}

- (instancetype)initWithWebView:(UIView<FLWebViewProvider> *)webView andDelegate:(UIViewController<UIWebViewDelegate, WebViewJavascriptBridgeProvider, WebViewJavascriptBridgeBaseDelegate,WKNavigationDelegate, WKUIDelegate> *)webViewDelegate{
    self = [super init];
    if ( self ){
        if ([webView isKindOfClass:[UIWebView class]]) {
            bridge = [WebViewJavascriptBridge bridgeForWebView:webView
                                               webViewDelegate:webViewDelegate
                                                       handler:^(id data, WVJBResponseCallback responseCallback) {
                                                           cootek_log(@"ObjC received message from JS: %@", data);
                                                           responseCallback(@"Response for message from ObjC");
                                                       }];
        } else {
            bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)webView
                                                 webViewDelegate:webViewDelegate
                                                         handler:^(id data, WVJBResponseCallback responseCallback) {
                                                             cootek_log(@"ObjC received message from JS: %@", data);
                                                             responseCallback(@"Response for message from ObjC");
                                                         }];
        }
        
        contro = webViewDelegate;
        web_view = webView;
    }
    return self;
}

- (void)initPageData{
    NSString *token = [SeattleFeatureExecutor getToken];
    NSDictionary *info = @{@"token":token ? token : @"",
                           @"number":[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:@""],
                           @"platform":@"iOS",
                           @"version":CURRENT_TOUCHPAL_VERSION,
                           @"channel":IPHONE_CHANNEL_CODE,
                           @"jsAPIVersion":@"1.0",
                           @"remainMinutes":[NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:VOIP_BALANCE]],
                           @"isInternationalRoaming":[NSString stringWithFormat:@"%d",![FunctionUtility isInChina]],
                           @"flowBalance":[NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:FLOW_BONUS defaultValue:0]],
                           @"registerTime":[NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME defaultValue:0]],
                           @"secret": [NSString nilToEmpty:[FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]]]
                           };
    [bridge send:info responseCallback:^(id response) {
        NSLog(@"init response:%@", response);
    }];
}

- (void)registerHandler{
    __weak UIViewController *sourceCon = contro;
    __weak UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    sourceName = [NSString stringWithFormat:@"%@_web_view",NSStringFromClass([contro class])];
    
    //API Level 13
    [bridge registerHandler:@"downloadOtherApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"downloadOtherApp called: %@", data);
        if ( data != nil && [data count] > 0 ) {
            [DownloadOtherAppController handleJSCallWithParam:data];
        }
        responseCallback(@"downloadOtherApp success");
    }];
    
    [bridge registerHandler:@"registerVoip" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"RegisterVoip called: %@", data);
        [LoginController checkLoginWithDelegate:[FreeCallLoginController withOrigin:@"webview_register"]];
        responseCallback(@"register voip success");
    }];
    
    [bridge registerHandler:@"dialerRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"dialerRecord called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *path = [data objectForKey:@"path"];
            NSDictionary *dic = [data objectForKey:@"value"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
            for (id key in [dic allKeys]) {
                [array addObject:Pair(key, [dic objectForKey:key])];
            }
            [DialerUsageRecord recordpath:path kvarray:array];
        }
        responseCallback(@"dialerRecord voip success");
    }];
    
    [bridge registerHandler:@"register" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"RegisterVoip called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *type = [data objectForKey:@"type"];
            if ( [type isEqualToString:@"voip"] ){
                [LoginController checkLoginWithDelegate:[FreeCallLoginController withOrigin:@"webview_register"]];
            }else if ( [type isEqualToString:@"flow"] ){
                [LoginController checkLoginWithDelegate:[CallFlowPacketLoginController withOrigin:@"webview_register"]];
            }else if ( [type isEqualToString:@"market"] ){
                [LoginController checkLoginWithDelegate:[MarketLoginController withOrigin:@"webview_register"]];
            }else{
                [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"webview_register"]];
            }
        }
        responseCallback(@"register voip success");
    }];
    
    
    [bridge registerHandler:@"getAuthToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getAuthToken called: %@", data);
        responseCallback([SeattleFeatureExecutor getToken]);
    }];
    
    [bridge registerHandler:@"getOSVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getOSVersion called: %@", data);
        responseCallback([[UIDevice currentDevice] systemVersion]);
    }];
    
    [bridge registerHandler:@"getRemainMinutes" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getRemainMinutes called: %@", data);
        responseCallback([NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:VOIP_BALANCE]]);
    }];
    
    [bridge registerHandler:@"pushViewController" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"RegisterViewController called: %@", data);
        if ( data != nil && [data count] > 0 ){
            [ControllerManager pushController:data];
            responseCallback(@"pushViewController success");
        }else{
            responseCallback(@"pushViewController fail");
        }
        
    }];
   
    [bridge registerHandler:@"closeWindow" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"closeWindow called: %@", data);
       
        if ( navi.topViewController == sourceCon ){
            [navi popViewControllerAnimated:YES];
        } else {
            [FunctionUtility removeFromStackViewController:sourceCon];
        }
        
       responseCallback(@"closeWindow over");
    }];
    
    [bridge registerHandler:@"startControllerWithCloseSelf" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"startControllerWithCloseSelf called: %@", data);
        
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *nativeUrl= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        if ([[nativeUrl allKeys]containsObject:@"ios"]) {
            [navi popViewControllerAnimated:NO];
            [ControllerManager pushController:[nativeUrl objectForKey:@"ios"] withAnimate:NO];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_JAVASCRIPT_START_NATIVE_ITEM kvs:Pair(@"action", @"javascript"), Pair(@"title",@"startControllerWithCloseSelf"), Pair(@"url", nativeUrl), nil];
        }
        
        responseCallback(@"startControllerWithCloseSelf over");
    }];
   
    [bridge registerHandler:@"popToRoot" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"popToRoot called: %@", data);
        [navi popToRootViewControllerAnimated:YES];
        responseCallback(@"popToRoot over");
    }];
    
    [bridge registerHandler:@"getKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getKey called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *key = [data objectForKey:@"key"];
            NSString *type = [data objectForKey:@"type"];
            NSString *value = [data objectForKey:@"defaultValue"];
            id resp;
            if ( [type isEqualToString:@"integer"] ){
                resp = [NSNumber numberWithInt:[UserDefaultsManager intValueForKey:key defaultValue:[value integerValue]]];
            }else if ( [type isEqualToString:@"boolean"] ){
                if ( [value isEqualToString:@"true"] )
                    resp = [NSNumber numberWithInt:[UserDefaultsManager boolValueForKey:key defaultValue:YES]];
                else
                    resp = [NSNumber numberWithInt:[UserDefaultsManager boolValueForKey:key defaultValue:NO]];
            }else if ( [type isEqualToString:@"string"] ){
                resp = [UserDefaultsManager stringForKey:key defaultValue:value];
            }else{
                resp = @"invalid_type";
                return;
            }
            responseCallback(resp);
        }
    }];
    
    [bridge registerHandler:@"setKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setKey called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *key = [data objectForKey:@"key"];
            NSString *type = [data objectForKey:@"type"];
            NSString *value = [data objectForKey:@"value"];
            if ( [type isEqualToString:@"integer"] ){
                [UserDefaultsManager setIntValue:[value integerValue] forKey:key];
            }else if ( [type isEqualToString:@"boolean"] ){
                if ( [value isEqualToString:@"true"] )
                    [UserDefaultsManager setBoolValue:YES forKey:key];
                else
                    [UserDefaultsManager setBoolValue:NO forKey:key];
            }else if ( [type isEqualToString:@"string"] ){
                [UserDefaultsManager setObject:value forKey:key];
            }else{
                responseCallback(@"invalid_type");
                return;
            }
        }
        responseCallback(@"success");
    }];
    
    [bridge registerHandler:@"showDialog" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"showDialog called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *message = [data objectForKey:@"message"];
            NSString *title = [data objectForKey:@"title"];
            NSString *positive_only = [data objectForKey:@"positive_only"];
            NSString *positive_text = [data objectForKey:@"positive_text"];
            NSString *positive_cb = [data objectForKey:@"positive_cb"];
            NSString *negative_text = [data objectForKey:@"negative_text"];
            NSString *negative_cb = [data objectForKey:@"negative_cb"];
            if ( [positive_only isEqualToString:@"true"] ){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:title message:message onlyOkButtonActionBlock:^(){
                    if (positive_cb.length < 1) return;
                    [bridge callHandler:positive_cb data:@"" responseCallback:^(id responseData){
                    }];
                }];
            }else{
                [DefaultUIAlertViewHandler showAlertViewWithTitle:title
                                                          message:message
                                                      cancelTitle:negative_text
                                                          okTitle:positive_text
                                              okButtonActionBlock:^(){
                                                  if (positive_cb.length < 1) return;
                                                    [bridge callHandler:positive_cb data:@"" responseCallback:^(id responseData){
                                                  }];
                                                }
                                                cancelActionBlock:^(){
                                                    if (negative_cb.length < 1) return;
                                                    [bridge callHandler:negative_cb data:@"" responseCallback:^(id responseData){
                                                    }];
                                                }];
            }
            
        }
        responseCallback(@"showDialog over");
    }];
    
    //API Level 13
    [bridge registerHandler:@"webShare" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"webShare called: %@", data);
        [TPWebShareController.controller handleJSCallWithParam:data responseCallback:responseCallback];
    }];
    
    [bridge registerHandler:@"popShareView" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"popShareView called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSArray *approaches = [data objectForKey:@"approaches"];
            NSString *title = [data objectForKey:@"title"];
            NSString *msg = [data objectForKey:@"content"];
            NSString *url = [data objectForKey:@"url"];
            NSString *imageUrl = [data objectForKey:@"image_url"];
            NSString *shareFrom = [data objectForKey:@"from"];
            NSString *headTitle = [data objectForKey:@"dlg_title"];
            [DialerUsageRecord recordpath:EV_FLOW_PUSH_REDBAG kvs:Pair(@"count", @(1)), nil];
            if ( [approaches count] == 0 ){
                VoipShareAllView *view = [[VoipShareAllView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
                view.fromWhere = shareFrom;
                [navi.topViewController.view addSubview:view];
                return;
            }
            if ( url == nil || [url length] == 0){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:@"分享失败！" message:nil onlyOkButtonActionBlock:nil];
                responseCallback(@"popShareView url over");
                return;
            }
            if ( [approaches count] > 1 ){
                VoipShareAllView *view = [[VoipShareAllView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:title msg:msg url:url buttonArray:approaches];
                view.fromWhere = shareFrom;
                view.imageUrl = imageUrl;
                [view setHeadTitle:headTitle];
                [navi.topViewController.view addSubview:view];
            }else if ( [approaches count] == 1 ) {
                NSString *name = [approaches objectAtIndex:0];
                if ( [name isEqualToString:@"wechat"] ){
                    [FunctionUtility shareByWeixin:title andDescription:msg andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom andResultCallback:nil];
                }
                if ( [name isEqualToString:@"timeline"] ){
                    [FunctionUtility shareByWeixinTimeline:title andDescription:nil andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom andResultCallback:nil];
                }
                if ( [name isEqualToString:@"qq"] ){
                    [FunctionUtility shareByQQ:title andDescription:msg andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom andResultCallback:nil];
                }
                if ( [name isEqualToString:@"qzone"] ){
                    [FunctionUtility shareByQQZone:title andDescription:nil andUrl:url andImageUrl:imageUrl andFromWhere:shareFrom andResultCallback:nil];
                }
                if ( [name isEqualToString:@"sms"] ){
                    NSString *smsUrl;
                    if (url != nil )
                        smsUrl = [FunctionUtility generateUrlMessage:url andTemptId:@"sms020" andFrom:@"sms"];
                    else
                        smsUrl = [FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"];
                    NSString *message = [NSString stringWithFormat:@"%@%@",title,msg];
                    [FunctionUtility shareSMS:smsUrl andNeedDefault:NO andMessage:message andNumber:nil andFromWhere:shareFrom];
                }
                if ( [name isEqualToString:@"clipboard"] ){
                    NSString *smsUrl;
                    if ( url != nil )
                        smsUrl = [FunctionUtility generateUrlMessage:url andTemptId:@"clipboard020" andFrom:@"clipboard"];
                    else
                        smsUrl = [FunctionUtility generateWechatMessage:@"clipboard020" andFrom:@"clipboard"];
                    [FunctionUtility sharePasteboard:smsUrl andNeedDefault:NO andFromWhere:shareFrom title:nil];
                }
            }
        }
        responseCallback(@"popShareView over");
    }];
    
    
    [bridge registerHandler:@"doTask" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"popShareView called: %@", data);
        NSInteger taskBonusId = [[data objectForKey:@"task_id"]integerValue];
        if ( [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] ){
            TaskBonusManager *manager = [[TaskBonusManager alloc]init];
            [manager doTaskFunction:taskBonusId];
        }else{
            [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"getTaskBonus" andLoginSuccessBlock:^{
                TaskBonusManager *manager = [[TaskBonusManager alloc]init];
                [manager doTaskFunction:taskBonusId];
            }]];
        }
        responseCallback(@"popShareView over");
    }];
    
    
    
    [bridge registerHandler:@"screenShotShare" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"screenShotShare called: %@", data);
        [DialerUsageRecord recordpath:EV_FLOW_SHOW_FINISH_TASK kvs:Pair(@"count", @(1)), nil];
        UIImage *image = [TPDialerResourceManager getImage:@"flow_wechat_share_pic@2x.png"];
        UIColor *textColor = [TPDialerResourceManager getColorForStyle:@"flow_wechatSharePic_title_color"];
        UIImage *temptImage = [FunctionUtility addLabelToImage:image andTitle:@"我已获得" andRect:CGRectMake(4, 257, image.size.width, 24) andFont:[UIFont systemFontOfSize:24] andColor:textColor];
        UIImage *shareImage = [FunctionUtility addLabelToImage:temptImage andTitle:[NSString stringWithFormat:@"%dMB",[UserDefaultsManager intValueForKey:FLOW_BONUS]] andRect:CGRectMake(4, 288, image.size.width, 36) andFont:[UIFont systemFontOfSize:36] andColor:textColor];
        [[TPShareController controller] voipWechatSharePic:shareImage andIfTimeLine:YES];
        responseCallback(@"screenShotShare over");
    }];

    //打开一个新的controller并且增加
    [bridge registerHandler:@"openWebViewController" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"openWebViewController called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *url = [data objectForKey:@"url"];
            NSString *webTitle = [data objectForKey:@"title"];
            NSString *fileName = [data objectForKey:@"file_name"];
            HandlerWebViewController *controller = [[HandlerWebViewController alloc] init];
            controller.url_string = url;
            controller.header_title = webTitle;
            controller.file_name = fileName;
            UINavigationController *naviController ;
            if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
                naviController = [UIViewController tpd_topViewController].navigationController;

            }else {
            
                naviController = ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;

            }
            [naviController pushViewController:controller animated:YES];
        }
        responseCallback(@"openWebViewController over");
    }];
    
    //打开一个新的controller并且增加
    [bridge registerHandler:@"openWebViewControllerWithFeatureName" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"openWebViewControllerWithFeatureName called: %@", data);
        if ( data != nil){

            
            NSString *featureName = [data objectForKey:@"featureName"];
            if ([featureName isEqualToString:@"openAdWebViewController"]) {
                NSDictionary *infoDic =[data objectForKey:@"info"];
                if (infoDic!=nil) {
                    NSString *url = [infoDic objectForKey:@"url"];
                    NSString *jump = [infoDic objectForKey:@"jumpOutsideFinish"];
                    BOOL  jumpOutsideFinish =  jump.boolValue;
                    NSDictionary *adsDic = [NSJSONSerialization JSONObjectWithData:[[infoDic objectForKey:@"ad"] dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableContainers) error:nil];
                    AdMessageModel *model;
                    NSDictionary *detailAd = [adsDic[@"ads"] objectAtIndex:0];
                    NSString *tu = adsDic[@"tu"];
                    model = [[AdMessageModel alloc] init];
                    if ([tu isEqualToString:kAD_TU_HANGUP]
                        || [tu isEqualToString:kAD_TU_VOIP_PRIVILEGE]
                        || [tu isEqualToString:kAD_TU_LAUNCH]
                        || [tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
                        model = [[HangupCommercialModel alloc] init];
                    }
                    model.w = ((NSNumber *)adsDic[@"w"]).integerValue;
                    model.h = ((NSNumber *)adsDic[@"h"]).integerValue;
                    model.wtime =((NSNumber *)adsDic[@"wtime"]).integerValue;
                    model.idws = ((NSString *)adsDic[@"idws"]).boolValue;
                    model.s = adsDic[@"s"];
                    model.tu = adsDic[@"tu"];
                    if (([model.tu isEqualToString:kAD_TU_HANGUP] || [model.tu isEqualToString:kAD_TU_BACKCALLHANG]) &&  [UserDefaultsManager boolValueForKey:if_hangupcon_closed defaultValue:NO]) {
                        return;
                    }
                    
                    
                    model.adId = detailAd[@"ad_id"];
                    model.title = detailAd[@"title"];
                    model.desc =  detailAd[@"desc"];
                    model.brand = detailAd[@"brand"];
                    model.curl =  detailAd[@"curl"];
                    model.edurl = detailAd[@"edurl"];
                    model.surl = detailAd[@"surl"];
                    model.src = detailAd[@"src"];
                    model.at = detailAd[@"at"];
                    model.turl =detailAd[@"turl"];
                    model.ttype =detailAd[@"ttype"];
                    model.tstep =detailAd[@"tstep"];
                    model.rdesc =detailAd[@"rdesc"];
                    model.checkcode =detailAd[@"checkcode"];
                    model.reserved = detailAd[@"reserved"];
                    model.material =detailAd[@"material"] ;
                    cootek_log(@"ad-info, seattle feature, material: %@", model.material);
                    model.da = ((NSString *)detailAd[@"da"]).boolValue;
                    model.dtime = ((NSNumber *)detailAd[@"dtime"]).integerValue;
                    model.etime = ((NSNumber *)detailAd[@"etime"]).integerValue;
                    model.expireTimestamp = (long long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000 + model.etime);
                    model.ec = ((NSString *)detailAd[@"ec"]).boolValue;
                    
                    // for ad debug stats
                    [UserDefaultsManager setObject:[NSString nilToEmpty:model.adId] forKey:LAST_AD_ID];
                    
                    UINavigationController *naviController = ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
                    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
                        naviController = [TouchPalDialerAppDelegate naviController];
                    }
                    UIViewController *topVC = naviController.topViewController;
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_REMOVE_HANGUP_TIMER object:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"V6_POPUP_AD_CLICK" object:nil];
                    
                    YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
                    controller.jumpOutsideFinish = jumpOutsideFinish;
                    controller.url_string = url;
                    controller.usingWkWebview = YES;
                    controller.needTitle = YES;
                    if (url.length>0){
                        [FunctionUtility setStatusBarHidden:NO];
                        [[HangupCommercialManager instance] hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_CLICKAD];
                        [naviController pushViewController:controller animated:YES];
                        
                        if (![topVC isKindOfClass:[RootScrollViewController class]] && ![topVC isKindOfClass:[RDVTabBarController class]] && ![topVC isKindOfClass:[TPDPhoneCallViewController class]]
                            && (![tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) ) {
                            [FunctionUtility removeFromStackViewController:topVC];
                        }
                        
                    }
                    
                    switch (tu.integerValue) {
                        case 4:
                        case 32:
                            [[HangupCommercialManager instance] setAdLandingPageManager:[[AdLandingPageManager alloc] initWithAd:model webController:controller] ifCallIng:YES] ;
                            [[HangupCommercialManager instance] callingADDisappearWithCloseType:ADCLOSE_SWITCH_WINDOW];
                        break;
                            
                        case 1:
                        case 33:
                            [[HangupCommercialManager instance]setAdLandingPageManager:[[AdLandingPageManager alloc] initWithAd:model webController:controller] ifCallIng:NO];
                            [[HangupCommercialManager instance] hangupADDisappearWithCloseType:ADCLOSE_SWITCH_WINDOW];
                        default:
                        break;
                    }
                }
            }
        }
        responseCallback(@"openWebViewControllerWithFeatureName over");
    }];
    
    
    [bridge registerHandler:@"redirectWeb" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"redirectWeb called: %@", data);
        if ( ![sourceCon isKindOfClass:[CommonWebViewController class]]){
            return;
        }
        CommonWebViewController *con = (CommonWebViewController *)sourceCon;
        if ( data != nil && [data count] > 0 ){
            NSString *url = [data objectForKey:@"url"];
            NSString *webTitle = [data objectForKey:@"webTitle"];
            con.header_title = webTitle;
            [con reloadUrl:url];
        }
        responseCallback(@"redirectWeb over");
    }];
    
    [bridge registerHandler:@"voipFeedback" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"voipFeedback called: %@", data);
        if ( ![sourceCon isKindOfClass:[CommonWebViewController class]]){
            return;
        }
        CommonWebViewController *con = (CommonWebViewController *)sourceCon;
        if ( ![con.relatedObject isKindOfClass:[VoipFeedbackInfo class]]){
            return;
        }
        VoipFeedbackInfo *info = (VoipFeedbackInfo *) con.relatedObject;
        info.reasonId = [data integerValue];
        if (info.shouldUpload) {
            dispatch_async([SeattleFeatureExecutor getQueue], ^{
                [SeattleFeatureExecutor postFeedback:info];
            });
        }
        responseCallback(@"voipFeedback over");
    }];
    
    [bridge registerHandler:@"getOSVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getOSVersion called: %@", data);
        NSNumber *osVersion = @([FunctionUtility systemVersionFloat]);
        responseCallback([osVersion stringValue]);
    }];
    
    [bridge registerHandler:@"makeCall" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"makeCall called: %@", data);
        if ( data != nil && [data count] > 0 ){
            NSString *number = [data objectForKey:@"number"];
            NSString *modeString = [data objectForKey:@"callMode"];
            BOOL removeSelf = [[data objectForKey:@"removeSelf"] isEqualToString:@"true"];
            CallMode callMode = -1;
            if ([modeString isEqualToString:@"CallModeBackCall"]) {
                callMode = CallModeBackCall;
            } else if ([modeString isEqualToString:@"CallModeIncomingCall"]) {
                callMode = CallModeIncomingCall;
            } else if ([modeString isEqualToString:@"CallModeOutgoingCall"]) {
                callMode = CallModeOutgoingCall;
            }
            if (callMode >= CallModeBackCall) {
                CallViewController *callViewController = [CallViewController instanceWithNumber:number andCallMode:callMode];
//                [[TouchPalDialerAppDelegate naviController] pushViewController:callViewController animated:YES];
                NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:[TouchPalDialerAppDelegate naviController].viewControllers];
                if (controllers && controllers.count >= 1) {
                    if (removeSelf) {
                        [controllers removeLastObject];
                    }
                    [controllers addObject:callViewController];
                    [TouchPalDialerAppDelegate naviController].viewControllers = [controllers copy];
                }
            }
        }
        responseCallback(@"makeCall over");
    }];

//    [bridge registerHandler:@"TaobaoFlow" handler:^(id data, WVJBResponseCallback responseCallback) {
//        cootek_log(@"TaobaoFlow called: %@", data);
//        NSInteger flowNumber = [[data objectForKey:@"number"]integerValue];
//        [DialerUsageRecord recordpath:EV_FLOW_EXCHANGE_BY_TAOBAO kvs:Pair(@"count", @(1)), nil];
//        if ( [[TaeClient instance] isLogin] ){
//            TaeUser *user = [[TaeClient instance] getUser];
//            
//            TaeWebViewUISettings *set = [[TaeWebViewUISettings alloc]init];
//            [[TaeClient instance] showpage:sourceCon isNeedPush:YES pageUrl:@"http://h5.m.taobao.com/aliqin/flowwallet/index.html?spm=0.0.0.0" webViewUISettings:set tradeProcessSuccessCallback:^(TaeTradeProcessResult *tradeProcessResult){
//
//            }tradeProcessFailedCallback:^(NSError *error){
//                cootek_log(@"taobao flow error %@",[error localizedDescription]);
//            }];
//            double delayInSeconds = 1.0;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^{
//                ClientNetworkType status = [Reachability network];
//                if ( status < network_2g){
//                    return;
//                }
//                FlowInputNameView *inputView = [[FlowInputNameView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andName:user.nick andFlowNumber:flowNumber andSourceCon:sourceCon];
//                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
//                [uiWindow addSubview:inputView];
//                [uiWindow bringSubviewToFront:inputView];
//                [DialerUsageRecord recordpath:EV_FLOW_SHOW_INPUTNAME_VIEW kvs:Pair(@"count", @(1)), nil];
//            });
//        }else{
//            [[TaeClient instance] showLogin:sourceCon successCallback:^(TaeSession *session){
//                cootek_log(@"TaobaoFlow showloginpage success");
//                TaeUser *user = [session getUser];
//                TaeWebViewUISettings *set = [[TaeWebViewUISettings alloc]init];
//                [[TaeClient instance] showpage:sourceCon isNeedPush:YES pageUrl:@"http://h5.m.taobao.com/aliqin/flowwallet/index.html?spm=0.0.0.0" webViewUISettings:set tradeProcessSuccessCallback:^(TaeTradeProcessResult *tradeProcessResult){
//                }tradeProcessFailedCallback:^(NSError *error){
//                    cootek_log(@"taobao flow error %@",[error localizedDescription]);
//                }];
//                cootek_log(@"TaobaoFlow showloginpage success after showpage");
//                double delayInSeconds = 1.0;
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                dispatch_after(popTime, dispatch_get_main_queue(), ^{
//                    ClientNetworkType status = [Reachability network];
//                    if ( status < network_2g){
//                        return;
//                    }
//                    FlowInputNameView *inputView = [[FlowInputNameView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andName:user.nick andFlowNumber:flowNumber andSourceCon:sourceCon];
//                    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
//                    [uiWindow addSubview:inputView];
//                    [uiWindow bringSubviewToFront:inputView];
//                    [DialerUsageRecord recordpath:EV_FLOW_SHOW_INPUTNAME_VIEW kvs:Pair(@"count", @(1)), nil];
//                });
//                
//            }failedCallback:^(NSError *error){
//                cootek_log(@"taobao flow error %@",[error localizedDescription]);
//                [DefaultUIAlertViewHandler showAlertViewWithTitle:[error localizedDescription] message:nil onlyOkButtonActionBlock:nil];
//            }];
//        }
//        
//        responseCallback(@"TaobaoFlow over");
//    }];
//    
//    [bridge registerHandler:@"TaobaoOpen" handler:^(id data, WVJBResponseCallback responseCallback) {
//        cootek_log(@"TaobaoOpen called: %@", data);
//        [DialerUsageRecord recordpath:EV_FLOW_OPEN_BY_TAOBAO kvs:Pair(@"count", @(1)), nil];
//        if ( [[TaeClient instance] isLogin] ){
//            TaeWebViewUISettings *set = [[TaeWebViewUISettings alloc]init];
//            [[TaeClient instance] showpage:sourceCon isNeedPush:YES pageUrl:@"http://h5.m.taobao.com/aliqin/flowwallet/index.html?spm=0.0.0.0" webViewUISettings:set tradeProcessSuccessCallback:^(TaeTradeProcessResult *tradeProcessResult){
//            }tradeProcessFailedCallback:^(NSError *error){
//                cootek_log(@"taobao open error %@",[error localizedDescription]);
//            }];
//        }else{
//            [[TaeClient instance] showLogin:sourceCon successCallback:^(TaeSession *session){
//                cootek_log(@"TaobaoOpen showloginpage success");
//                TaeWebViewUISettings *set = [[TaeWebViewUISettings alloc]init];
//                [[TaeClient instance] showpage:sourceCon isNeedPush:YES pageUrl:@"http://h5.m.taobao.com/aliqin/flowwallet/index.html?spm=0.0.0.0" webViewUISettings:set tradeProcessSuccessCallback:^(TaeTradeProcessResult *tradeProcessResult){
//                }tradeProcessFailedCallback:^(NSError *error){
//                    cootek_log(@"3333");
//                }];
//                cootek_log(@"TaobaoOpen showloginpage success after showpage");
//            }failedCallback:^(NSError *error){
//                cootek_log(@"taobao open error %@",[error localizedDescription]);
//                [DefaultUIAlertViewHandler showAlertViewWithTitle:[error localizedDescription] message:nil onlyOkButtonActionBlock:nil];
//            }];
//        }
//        
//        responseCallback(@"TaobaoOpen over");
//    }];
//    
    [bridge registerHandler:@"tryShareWithParams" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"tryShare called with data %@", data);
        NSString *params = [data objectForKey:@"params"];
        if (params) {
            [[[TouchLifeShareMgr instance] newTouchLifeShare] checkShare:params notifyAuto:YES];
        }
    }];
    
    [bridge registerHandler:@"tryShareWithReference" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSUInteger ref = [[data objectForKey:@"params"] unsignedIntegerValue];
        if (ref != 0) {
            [[TouchLifeShareMgr instance] shareWithRef:ref];
        }
    }];
    
    [bridge registerHandler:@"queryShareData" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *params = [data objectForKey:@"params"];
        if (params) {
            TouchLifeShare *share = [[TouchLifeShareMgr instance] newTouchLifeShare];
            NSUInteger hash = share.hash;
            share.netOperResultBlock = ^ (BOOL success){
                if (success) {
                    responseCallback([NSString stringWithFormat:@"%lu", hash]);
                }
            };
            [share checkShare:params notifyAuto:NO];
        }
    }];
    
    [bridge registerHandler:@"openUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"openUrl called start");
        BOOL ret = NO;
        if ( data != nil && [data count] > 0 ){
            NSString *url = [data objectForKey:@"url"];
            ret = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        responseCallback([NSNumber numberWithBool:ret]);
        cootek_log(@"openUrl called end");
    }];
    
    //API Level 13
    [bridge registerHandler:@"canOpenUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"canOpenUrl called start");
        BOOL ret = NO;
        if ( data != nil && [data count] > 0 ){
            [TPShareController registerWeiXinApp];
            NSString *url = [data objectForKey:@"url"];
            if (url.length) {
                ret = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
            }
        }
        responseCallback([NSNumber numberWithBool:ret]);
        cootek_log(@"canOpenUrl called end");
    }];
    //API Level ==
    [bridge registerHandler:@"pasteboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"pasteboard called start");
        cootek_log(@"%@",[UIPasteboard generalPasteboard].string);
        if(data != [NSNull null]) {
             NSString *copyPasteString = [data objectForKey:@"copyToPaste"];
            [UIPasteboard generalPasteboard].string = copyPasteString;
        }
        else{
            [DialerUsageRecord recordpath:PATH_INTERNATIONWEB_CHECK kvs:Pair(KEY_ACTION,NATIVE_CLICK_PASTE), nil];
            [FunctionUtility saveLogInDebugToDocFile:@"webHandleLog.txt" withLog:NATIVE_CLICK_PASTE];
            responseCallback([UIPasteboard generalPasteboard].string);
        }
        
        cootek_log(@"pasteboard called end");
    }];
    //API Level ==
    [bridge registerHandler:@"useSeattle" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"useSeattle called start");
         NSString *featureName = [data objectForKey:@"featureName"];
        if ([featureName isEqualToString:@"redeemExchangeCode"]) {
            if ( data != nil && [data count] > 0 ){
           
            NSString *code = [data objectForKey:@"code"];
            [DialerUsageRecord recordpath:PATH_INTERNATIONWEB_CHECK kvs:Pair(KEY_ACTION,NATIVE_CLICK_EXCHANGE), nil];
            [FunctionUtility saveLogInDebugToDocFile:@"webHandleLog.txt" withLog:NATIVE_CLICK_EXCHANGE];
            if (code.length>0&&featureName.length>0) {
                [SeattleFeatureExecutor redeemExchangeUseSeattleWithMessage:code];
            }else{
               [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您输入的邀请码不正确" message:nil onlyOkButtonActionBlock:nil];
            }
          }
        }else if ([featureName isEqualToString:@"testFreeCallGuide"]) {
                [DialerViewController showGuidePopView];
        }
        cootek_log(@"useSeattle called end");
        
    }];
    
    [bridge registerHandler:@"showGuide" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"showGuideView called start");
        NSString  *featureName = ((NSString *)[data objectForKey:@"featureName"]);
        
        if ([featureName isEqualToString:@"guideViewInPersonalOrContactVC"]) {
        NSString  *guideTypeString = ((NSString *)[data objectForKey:@"guideType"]);
        if (guideTypeString!=nil) {
            GUIDETYPE guideType =guideTypeString.integerValue;
            if (guideType>=0 && guideType<=ANTIHARASS) {

            }
        }
        }else if([featureName isEqualToString:@"toast"]){
            NSString  *msg = ((NSString *)[data objectForKey:@"msg"]);
            if (msg.length>0) {
                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [uiWindow makeToast:msg duration:1.0f position:CSToastPositionBottom];
            }
        }
        cootek_log(@"useSeattle called end");
    }];
    
    
    [bridge registerHandler:@"showToast" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"showToast called start");
        NSString  *msg = ((NSString *)[data objectForKey:@"msg"]);
        NSString  *position = ((NSString *)[data objectForKey:@"position"]);
        NSString  *duration = ((NSString *)[data objectForKey:@"duration"]);
            if (msg.length>0) {
                if (duration.length==0) {
                    duration = @"1";
                }
                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [uiWindow makeToast:msg duration:duration.floatValue position:position];
            }
        cootek_log(@"showToast called end");
    }];
    
    
    [bridge registerHandler:@"commercial" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"Commercial called start");
        if (data) {
            NSString  *featureName = [data objectForKey:@"featureName"];
            NSUInteger position = ((NSString *)[data objectForKey:@"position"]).integerValue;
            
            
            if ([featureName isEqualToString:@"callAndHangupWebCommercialAd"] ) {
                if ([data[@"ads"] isKindOfClass:[NSString class]] && ((NSString *)data[@"ads"]).length) {
                NSString *string = data[@"ads"];
                NSDictionary  *adsDic= [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers) error:nil];
                NSArray *adsArr = adsDic[@"ads"];
                AdMessageModel *model;
                if (adsArr.count>0){
                    [HangupCommercialManager instance].adCount = adsArr.count;
                    NSDictionary *detailAd = adsArr[position];
                    NSString *tu = adsDic[@"tu"];
                    model = [[AdMessageModel alloc] init];
                    if ([tu isEqualToString:kAD_TU_HANGUP]
                        || [tu isEqualToString:kAD_TU_VOIP_PRIVILEGE]
                        || [tu isEqualToString:kAD_TU_LAUNCH]) {
                        model = [[HangupCommercialModel alloc] init];
                    }
                    model.w = ((NSNumber *)adsDic[@"w"]).integerValue;
                    model.h = ((NSNumber *)adsDic[@"h"]).integerValue;
                    model.wtime =((NSNumber *)adsDic[@"wtime"]).integerValue;
                    model.idws = ((NSString *)adsDic[@"idws"]).boolValue;
                    model.s = adsDic[@"s"];
                    model.tu = adsDic[@"tu"];
                        
                    model.adId = detailAd[@"ad_id"];
                    model.title = detailAd[@"title"];
                    model.desc =  detailAd[@"desc"];
                    model.brand = detailAd[@"brand"];
                    model.curl =  detailAd[@"curl"];
                    model.edurl = detailAd[@"edurl"];
                    model.clk_monitor_url = detailAd[@"clk_monitor_url"];
                    model.ed_monitor_url = detailAd[@"ed_monitor_url"];
                    model.surl = detailAd[@"surl"];
                    model.src = detailAd[@"src"];
                    model.at = detailAd[@"at"];
                    model.turl =detailAd[@"turl"];
                    model.ttype =detailAd[@"ttype"];
                    model.tstep =detailAd[@"tstep"];
                    model.rdesc =detailAd[@"rdesc"];
                    model.checkcode =detailAd[@"checkcode"];
                    model.reserved = detailAd[@"reserved"];
                    model.material =detailAd[@"material"] ;
                    cootek_log(@"ad-info, seattle feature, material: %@", model.material);
                    model.da = ((NSString *)detailAd[@"da"]).boolValue;
                    model.dtime = ((NSNumber *)detailAd[@"dtime"]).integerValue;
                    model.etime = ((NSNumber *)detailAd[@"etime"]).integerValue;
                    model.expireTimestamp = (long long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000 + model.etime);
                    model.ec = ((NSString *)detailAd[@"ec"]).boolValue;
                }
                    if ([adsDic[@"tu"]  isEqualToString:kAD_TU_HANGUP]||[adsDic[@"tu"]  isEqualToString:kAD_TU_BACKCALLHANG]||[adsDic[@"tu"]  isEqualToString:kAD_TU_LAUNCH]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            HangupCommercialModel *hgmodel = (HangupCommercialModel  *) model;
                            [[HangupCommercialManager instance] setCommercialModel:hgmodel];
                            [[HangupCommercialManager instance] tellShow:YES];
                        });
                    }
                    else if ([adsDic[@"tu"]  isEqualToString:kAD_TU_CALLING]||[adsDic[@"tu"]  isEqualToString:kAD_TU_BACKCALL]){
                        if ([model.material rangeOfString:@"http"].length > 0) {
                            [[HangupCommercialManager instance] callingViewADDidLoad:model];
                        }
                    }
                    responseCallback(@"commercial ok");
                     return ;
                    }
                [[NSNotificationCenter defaultCenter] postNotificationName:N_WEB_NO_AD object:nil];
                }
            }
        cootek_log(@"useSeattle called end");
    }];
    
    //version 5399 以上才可以使用
    [bridge registerHandler:@"selectUserList" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"selectUserList called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"selectUserList data none");
            return;
        }
        NSInteger type = [[data objectForKey:@"type"] integerValue];
        BOOL isSingle = [[data objectForKey:@"isSingle"] boolValue];
        [[SelectController sharedInstance]pushSelectViewControllerBySelectType:type
                                                                   andIfSingle:isSingle
                                                                andResultBlock:
         ^(NSArray *array){
             responseCallback(array);
        }];
        
        cootek_log(@"selectUserList called end");
    }];
    
    //skin相关接口 version 5420以上才可以使用
    [bridge registerHandler:@"skin_getSkinStatusBySkinId" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"skin_getSkinStatusBySkinId called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"skin_getSkinStatusBySkinId data none");
            return;
        }
        NSString *skinID = data[@"skinID"];
        SkinDownloadType downloadType = [[SkinDownloadManager sharedInstrance]getSkinDownloadTypeBySkinID:skinID];
        cootek_log(@"skin_getSkinStatusBySkinId data: %d",downloadType);
        responseCallback(@(downloadType));
        cootek_log(@"skin_getSkinStatusBySkinId called end");
    }];
    
    [bridge registerHandler:@"skin_downloadSkin" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"skin_downloadSkin called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"skin_downloadSkin data none");
            return;
        }
        TPSkinInfo *info = [[SkinDownloadManager sharedInstrance] genereateSkinInfo:data];
        [[SkinDownloadManager sharedInstrance] startSkinDownload:info andStepBlock:^(NSInteger result){
            responseCallback(@(result));
        }];
        
        cootek_log(@"skin_downloadSkin called end");
    }];
    
    [bridge registerHandler:@"skin_useSkin" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"skin_useSkin called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"skin_useSkin data none");
            return;
        }
        NSString *skinID = data[@"skinID"];
        [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_CLICK, skinID), nil];
        [[SkinDownloadManager sharedInstrance] useSkin:skinID];
        cootek_log(@"skin_useSkin called end");
    }];
    
    [bridge registerHandler:@"setHeaderTitle" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setHeaderTitle called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"setHeaderTitle data none");
            return;
        }
        NSString *headerTitle = data[@"title"];
        [_webDelegate setHeaderTitle:headerTitle];
        cootek_log(@"setHeaderTitle called end");
    }];
    
    [bridge registerHandler:@"setWebViewScroll" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setWebViewScroll called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"setWebViewScroll data none");
            return;
        }
        BOOL ifScroll = [data[@"ifScroll"] boolValue];
        [_webDelegate setWebViewScroll:ifScroll];
        cootek_log(@"setWebViewScroll called end");
    }];
    
    [bridge registerHandler:@"shareWechatByImageUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"shareWechatByImageUrl called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"shareWechatByImageUrl data none");
            return;
        }
        NSString *imageUrl  = data[@"image_url"];
        BOOL ifTimeLine     = [data[@"if_timeline"] boolValue];
        NSString *shareFrom = [data objectForKey:@"from"];
        [FunctionUtility shareByWeixinImageByImageUrl:imageUrl andFromWhere:shareFrom andIfTimeLine:ifTimeLine];
        cootek_log(@"shareWechatByImageUrl called end");
    }];
    
    [bridge registerHandler:@"getLastCallAndNumber" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getLastCallAndNumber called start");
        responseCallback(@{@"number":[UserDefaultsManager stringForKey:HANGUP_MODEL_NUMBER defaultValue:@""],
                           @"time":@([UserDefaultsManager intValueForKey:HANGUP_MODEL_TIME defaultValue:0])});
        cootek_log(@"getLastCallAndNumber called end");
    }];
    
    [bridge registerHandler:@"retryEdUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"retryEdUrl called start");
        NSDictionary *dic = data;
        NSString *url = [dic objectForKey:@"url"];
        [[AdStatManager instance] sendUrl:url];
        cootek_log(@"retryEdUrl called end");
    }];
    
    [bridge registerHandler:@"getPersonInfoByNumber" handler:^(id data,WVJBResponseCallback response) {
        NSString *number = data[@"number"];
        NSInteger personId = [NumberPersonMappingModel getCachePersonIDByNumber:number];
        if (personId > 0) {
            ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
            UIImage *image = personData.image ? personData.image : [[BiBiPairManager manager] defualtBibiPhoto];
            NSData *imageData = UIImagePNGRepresentation(image);
            NSString *imageStr = [DTBase64Coding stringByEncodingData:imageData];
            NSDictionary *dic = @{@"name":personData.displayName,@"image":imageStr};
            response(dic);
        } else {
            response(nil);
        }
    }];
    
    [bridge registerHandler:@"getSelfRegisterPhoto" handler:^(id data,WVJBResponseCallback response) {
        UIImage *image = [PersonalCenterUtility getHeadViewUIImage];
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *imageStr = [DTBase64Coding stringByEncodingData:imageData];
        response(imageStr);
    }];
    
    
    
    [bridge registerHandler:@"getCallLogByNumber" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getCallLogByNumber called start");
        if ( data == nil || ![data count] ){
            cootek_log(@"getCallLogByNumber data none");
            return;
        }
        NSString *number = data[@"number"];
        NSInteger maxCount = [data[@"max_count"] integerValue];
        NSInteger ts_start = [data[@"ts_start"] integerValue];;
        NSString *cnNormalNumber = [PhoneNumber getCNnormalNumber:number];
        int personId = [NumberPersonMappingModel queryContactIDByNumber:cnNormalNumber];
        NSArray *callList = nil;
        if (personId > 0) {
            callList = [ContactInfoModelUtil getCallDataListByPersonId:personId];
        }else{
            callList = [ContactInfoModelUtil getCallDataListtByPhoneNumber:cnNormalNumber];
        }
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        for (CallLogDataModel * info in callList){
            if ( info.callTime > ts_start ){
                [mutableArray addObject:@(info.callTime)];
            }
            if ( [mutableArray count] >= maxCount ){
                break;
            }
        }
        
        responseCallback(@{@"count":@([callList count]),
                           @"calllogs_ts":mutableArray});

    }];
    
    [bridge registerHandler:@"finishLaunchAD" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"finishLaunchAD");
        [[NSNotificationCenter defaultCenter] postNotificationName:N_LAUNCH_AD_FINISH object:nil];
    }];
    
    [bridge registerHandler:@"setAllUseful" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setAllUseful called start");
        if (data) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setAllUseful" object:data];
        }
    }];

    [bridge registerHandler:@"setUsefulArea" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setUsefulArea called start");
        if (data) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setUsefulArea" object:data];
        }
    }];
    
    [bridge registerHandler:@"closeWebViewAd" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setUsefulArea called start");
        if (data) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeWebViewAd" object:data];
        }
    }];
    
    [bridge registerHandler:@"getContackPersonName" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getContackPersonName start");
        if (data != nil) {
            NSString *phone = data[@"phone"];
            if (phone.length > 0) {
                NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:phone];
                ContactCacheDataModel *model = [PersonDBA getConatctInfoByRecordID:personID];
                if (model.fullName.length>0) {
                    responseCallback([NSString stringWithFormat:@"%@",model.fullName]);
                }
            }
           
        }
        
    }];

    
    [self registerYellowPageHandler];
    
    
}


- (void)registerYellowPageHandler{
    __weak typeof(self) weakSelf = self;
    //yellowpage start
    //API Level 1
    [bridge registerHandler:@"getApiLevel" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getApiLevel called: getApiLevel");
        responseCallback(WEBVIEW_JAVASCRIPT_API_LEVEL);
    }];
    
    //API Level 1
    [bridge registerHandler:@"log" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"webConsole log called: %@", data);
        responseCallback(@"Response from log");
    }];
    
    //API Level 1
    [bridge registerHandler:@"recordUsage" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(data != nil && [data isKindOfClass:[NSString class]]){
            NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if(dataDict != nil && [dataDict count] >= 3){
                NSString *path = [dataDict objectForKey:@"path"];
                NSString *key = [dataDict objectForKey:@"key"];
                NSString *value = [dataDict objectForKey:@"value"];
                NSString *localLog = [dataDict objectForKey:@"localLog"];
                [DialerUsageRecord recordpath:path kvs:Pair(key, value), nil];
                if ([localLog isEqualToString:@"YES"]) {
                    [FunctionUtility saveLogInDebugToDocFile:@"webHandleLog.txt" withLog:@{path:@{key:value}}];
                }
                responseCallback(@"recordUsage end");
            }else{
                responseCallback(@"recordUsage failed , please check data format");
                
            }
        } else {
            responseCallback(@"recordUsage failed , please check data format");
        }
    }];
    
    //API Level 1
    [bridge registerHandler:@"appendScenarioNode" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"appendScenarioNode called: %@", data);
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        NSMutableArray *kvarray = [NSMutableArray arrayWithCapacity:returnData.allKeys.count];
        for (id key in returnData.allKeys) {
            [kvarray addObject:Pair(key, [returnData objectForKey:key])];
        }
        [DialerUsageRecord recordpath:@"path_websearch_scenario" kvarray:kvarray];
        responseCallback(@"appendScenarioNode end");
    }];
    
    //API Level 1
    [bridge registerHandler:@"locate" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"locate called: %@", data);
        [[YellowPageLocationManager instance] addCallBackBlock:^(BOOL isLocation,CLLocationCoordinate2D location) {
            typeof(self) strongSelf = weakSelf;
            if (isLocation && strongSelf != nil) {
                strongSelf.locateCallmethodString = data;
                [FunctionUtility executeJavaScript:strongSelf->web_view withScript:[NSString stringWithFormat:@"%@();", strongSelf.locateCallmethodString]];
            }
        }];
        [[YellowPageLocationManager instance] locate:NO checkPermission:YES];
        
        responseCallback(@"locate end");
    }];
    
    //API Level 1
    [bridge registerHandler:@"locateGpsFirst" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"locateGpsFirst called: %@", data);
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        [[YellowPageLocationManager instance] addCallBackBlock:^(BOOL isLocation,CLLocationCoordinate2D location) {
            if (isLocation) {
                self.gpsCallmethodString = [returnData objectForKey:@"callback"];
                [FunctionUtility executeJavaScript:web_view withScript:[NSString stringWithFormat:@"%@('%@');",self.gpsCallmethodString,isLocation ? @"true" : @"false"]];
            }
        }];
        if([CLLocationManager locationServicesEnabled] == NO){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Service Disabled", @"")
                                                            message:NSLocalizedString(@"To re-enable, please go to Settings and turn on Location Service for this app.", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            [[YellowPageLocationManager instance] locate:NO checkPermission:YES];
        }
        responseCallback(@"locateGpsFirst end");
    }];
    
    //API Level 1
    //deprecated
    [bridge registerHandler:@"getLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getLocation called: %@", data);
        NSString* newdata = [UserDefaultsManager stringForKey:NATIVE_PARAM_LOCATION defaultValue:@""];
        responseCallback(newdata);
    }];
    
    //API Level 1
    //deprecated
    [bridge registerHandler:@"getAddress" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getAddress called: %@", data);
        responseCallback([UserDefaultsManager stringForKey:NATIVE_PARAM_ADDR defaultValue:@""]);
    }];
    
    //API Level 1
    //deprecated
    [bridge registerHandler:@"getCity" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getCity called: %@", data);
        responseCallback([UserDefaultsManager stringForKey:NATIVE_PARAM_CITY defaultValue:@""]);
    }];
    
    //API Level 1
    //deprecated
    [bridge registerHandler:@"getLocateCacheTime" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getLocateCacheTime called: %@", data);
        responseCallback([UserDefaultsManager stringForKey:NATIVE_PARAM_LOCATION_CACHE_TIME defaultValue:@""]);
    }];
    
    //API Level 1
    //deprecated
    [bridge registerHandler:@"getAddrCacheTime" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getAddrCacheTime called: %@", data);
        responseCallback([UserDefaultsManager stringForKey:NATIVE_PARAM_ADDR_CACHE_TIME defaultValue:@""]);
    }];
    
    //API Level 1
    //deprecated
    [bridge registerHandler:@"getCityCacheTime" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getCityCacheTime called: %@", data);
        responseCallback([UserDefaultsManager stringForKey:NATIVE_PARAM_CITY_CACHE_TIME defaultValue:@""]);
    }];
    
    //API Level 1
    [bridge registerHandler:@"getLocationServiceAvailable" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getLocationServiceAvailable called: %@", data);
        BOOL isAvailable = [Reachability network] >= network_2g;
        
        responseCallback([NSString stringWithFormat:@"%s", isAvailable ? "true" : "false"]);
    }];
    
    //API Level 1
    [bridge registerHandler:@"getNetworkAvailable" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getNetworkAvailable called: %@", data);
        BOOL isAvailable = [Reachability network] >= network_2g;
        
        responseCallback([NSString stringWithFormat:@"%s", isAvailable ? "true" : "false"]);
    }];
    
    //API Level 1
    [bridge registerHandler:@"getLogged" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getLogged called: %@", data);
        if ( [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN ]){
            responseCallback(@"true");
        }else{
            responseCallback(@"false");
        }
    }];
    
    //API Level 1
    //API level 14 增加获取accessToken的回调
    [bridge registerHandler:@"login" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"registerYellowPage called: %@", data);
        if ([[UIDevice currentDevice]systemVersion].floatValue >= 7.0) {
            NSNumber *value = [NSNumber numberWithInt:[[UIDevice currentDevice] orientation]];
            value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
            
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            [[UIApplication sharedApplication] setStatusBarOrientation:
             UIDeviceOrientationPortrait animated:NO];
        } else {
            [[UIApplication sharedApplication] setStatusBarOrientation:
             UIDeviceOrientationPortrait animated:NO];
        }
        
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        self.callmethodString = [returnData objectForKey:@"callback"];
        [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"yellowpage register" andLoginSuccessBlock:^{
            NSDictionary* resultDic = [@{@"isLogged":@"true",@"token":[SeattleFeatureExecutor getToken],@"secret":[FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]],@"loginnumber":[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME],@"accesstoken":[UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_ACCESS_TOKEN]} copy];
            NSString* callbackValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:resultDic options:0 error:nil] encoding:NSUTF8StringEncoding];
            [FunctionUtility executeJavaScript:web_view withScript:[NSString stringWithFormat:@"%@( %@ );",self.callmethodString,callbackValue]];
        } andLoginFailedBlock:^{
            NSDictionary* resultDic = [@{@"isLogged":@"false"} copy];
            NSString* callbackValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:resultDic options:0 error:nil] encoding:NSUTF8StringEncoding];
            [FunctionUtility executeJavaScript:web_view withScript:[NSString stringWithFormat:@"%@( %@ );",self.callmethodString,callbackValue]];
        }]];
        [LoginController setRegisterNumber:[returnData objectForKey:@"phone"]];
        
        responseCallback(@"registerYellowPage end");
    }];
    
    //API Level 1
    [bridge registerHandler:@"alipay" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"alipay called: %@", data);
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        [[AlipayController instance] sendPay:returnData callbackBlock:^(NSDictionary* resultDic){
            self.callmethodString = [returnData objectForKey:@"callback"];
            NSString* callbackValue = [[NSString alloc]
                                        initWithData:[NSJSONSerialization dataWithJSONObject:resultDic options:0 error:nil] encoding:NSUTF8StringEncoding];
            [FunctionUtility executeJavaScript:web_view withScript:[NSString stringWithFormat:@"%@( %@ )",self.callmethodString,callbackValue]];
        }];
        responseCallback(@"alipay end");
    }];
    
    //API Level 1
    [bridge registerHandler:@"weixinpay" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"weixinpay called: %@", data);
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        self.callmethodString = [returnData objectForKey:@"callback"];
        [[TPShareController controller] sendPay:data callbackBlock:^(NSDictionary* resultDic){
            [FunctionUtility executeJavaScript:web_view withScript:[NSString stringWithFormat:@"%@( %@ );",self.callmethodString,[resultDic objectForKey:@"errcode"]]];
        }];
        responseCallback(@"weixinpay end");
    }];
    
    //API Level 1
    [bridge registerHandler:@"getSecret" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getSecret called: %@", data);
        NSString* secret = [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
        if (secret){
            responseCallback(secret);
        }else{
            responseCallback(@"");
        }
    }];
    
    //API Level 1
    [bridge registerHandler:@"jumpToFlowEditView" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"jumpToFlowEditView called: %@", data);
        [LoginController checkLoginWithDelegate:[CallFlowPacketLoginController withOrigin:@"yellow_page_flow"]];
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [SeattleFeatureExecutor getAccountNumbersInfo];
            [SeattleFeatureExecutor queryVOIPAccountInfo];
        });
        responseCallback(@{@"error_code":@(0)});
    }];
    
    //API Level 3
    [bridge registerHandler:@"getLoginNumber" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getLoginNumber called: %@", data);
        NSString* accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
        if(accountName == nil){
            responseCallback(@"");
        }else{
            responseCallback(accountName);
        }
    }];
    
    //API Level 3
    [bridge registerHandler:@"setStorageItem" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"setStorageItem called: %@", data);
        
        if(data != nil && [data isKindOfClass:[NSString class]]){
            NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if(dataDict != nil){
                NSString *key = [dataDict objectForKey:@"key"];
                NSString *value = [dataDict objectForKey:@"value"];
                [LocalStorage setItemForKey:key andValue:value];
                responseCallback(@"setStorageItem success");
                return;
            }
        }
        
        responseCallback(@"setStorageItem failed, please check data format");
    }];
    
    //API Level 3
    [bridge registerHandler:@"removeStorageItem" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"removeStorageItem called: %@", data);
        [LocalStorage removeKey:data];
        responseCallback(@"removeStorageItem end");
    }];
    
    //API Level 3
    [bridge registerHandler:@"backPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"backpage called: %@", data);
        if ([web_view canGoBack]) {
            [web_view stopLoading];
            [web_view goBack];
        } else {
            [contro.navigationController popViewControllerAnimated:YES];
        }
        responseCallback(@"backpage end");
    }];
    
    //API Level 3
    [bridge registerHandler:@"getWeixinAppInstalled" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getWeixinAppInstalled called start");
        if (![WXApi isWXAppInstalled]) {
            responseCallback(@"false");
        } else {
            responseCallback(@"true");
        }
        
        cootek_log(@"getWeixinAppInstalled called end");
    }];
    
    //API Level 3
    [bridge registerHandler:@"getWXPaySupported" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"getWXPaySupported called start");
        if (![WXApi isWXAppSupportApi]) {
            responseCallback(@"false");
        } else {
            responseCallback(@"true");
        }
        
        cootek_log(@"getWXPaySupported called end");
    }];
    
    //API Level 4
    [bridge registerHandler:@"openUrlInBrowser" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"openUrlInBrowser called start");
        if(data != nil && [data isKindOfClass:[NSString class]]){
            [[UIApplication sharedApplication] openURL:data];
        }
        
        cootek_log(@"openUrlInBrowser called end");
    }];
    
    //API Level 4
    [bridge registerHandler:@"shareWXMessage" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"shareWXMessage called start");
        NSError *error =nil;
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *messageData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        NSString* type = [messageData objectForKey:@"type"];
        if ([@"wechat" isEqualToString:type]) {
            NSString* msg = [messageData objectForKey:@"msg"];
            NSString* title = [messageData objectForKey:@"title"];
            NSString* url = [messageData objectForKey:@"url"];
            [self shareByWeixin:title andMsg:msg andUrl:url];
            cootek_log(@"shareWXMessage called success ");
        } else {
            cootek_log(@"shareWXMessage called failed : type is %@", type);
        }
    }];
    
    //API Level 4
    [bridge registerHandler:@"shareWXMoment" handler:^(id data, WVJBResponseCallback responseCallback) {
        cootek_log(@"shareWXMoment called start");
        NSError *error =nil;
         NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *messageData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        NSString* type = [messageData objectForKey:@"type"];
        if ([@"wechat_moment" isEqualToString:type]) {
            NSString* msg = [messageData objectForKey:@"msg"];
            NSString* title = [messageData objectForKey:@"title"];
            NSString* url = [messageData objectForKey:@"url"];
            [self shareByWeixinTimeLine:title andMsg:msg andUrl:url];
            cootek_log(@"shareWXMoment called success ");
        } else {
            cootek_log(@"shareWXMoment called failed : type is %@", type);
        }
    }];
    
    //API Level 6
    [bridge registerHandler:@"scanCode" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            ScanRootViewController *controller = [[ScanRootViewController alloc] init];
            [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
            NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error =nil;
            NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
            if (error) {
                cootek_log(@"%@",error);
            }
            __block NSString* callBack = [returnData objectForKey:@"callback"];
            
            controller.callback = ^(NSString* result){
                [FunctionUtility executeJavaScript:web_view withScript:[NSString stringWithFormat:@"%@( \"%@\" );",callBack,result]];
            };
        } else {
            responseCallback(@"false");
        }
    }];
    
    //API Level 9
    [bridge registerHandler:@"getActivationJsonInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSMutableDictionary * activationJsonInfo = [[NSMutableDictionary alloc] init];
        [activationJsonInfo setValue:COOTEK_APP_NAME forKey:@"app_name"];
        [activationJsonInfo setValue:CURRENT_TOUCHPAL_VERSION forKey:@"app_version"];
        [activationJsonInfo setValue:IPHONE_CHANNEL_CODE forKey:@"channel_code"];
        
        NSString* callbackValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:activationJsonInfo options:0 error:nil] encoding:NSUTF8StringEncoding];
        cootek_log(@"callbackValue = %@", callbackValue);
        responseCallback(callbackValue);
    }];
    
    //API Level 10
    [bridge registerHandler:@"getTicket" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *ticket = [UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_TICKET];
        responseCallback(ticket);
    }];
    
    //API Level 10
    [bridge registerHandler:@"getAccessToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *accessToken = [UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_ACCESS_TOKEN];
        responseCallback(accessToken);
    }];
    
    //API Level 11
    [bridge registerHandler:@"shareMessage" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSError *error =nil;
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *messageData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        NSString* type = [messageData objectForKey:SHARE_PARAM_TYPE];
        NSString* title = [messageData objectForKey:SHARE_PARAM_TITLE];
        NSString* msg = [messageData objectForKey:SHARE_PARAM_MSG];
        NSString* url = [messageData objectForKey:SHARE_PARAM_URL];
        NSString* imgUrl = [messageData objectForKey:SHARE_PARAM_IMG_URL];
        if (imgUrl == nil || [imgUrl length] == 0) {
            imgUrl = @"http://dialer.cdn.cootekservice.com/android/default/voipShare/shareicon_6.jpg";
        }
        if ([SHARE_PARAM_TYPE_QZONE isEqualToString:type]) {
            [[QQShareController instance] shareQQMessage:title andDescription:msg andUrl:url andImageUrl:imgUrl andIfQQZone:YES andBlock:nil];
        } else if ([SHARE_PARAM_TYPE_QQ isEqualToString:type]) {
            [[QQShareController instance] shareQQMessage:title andDescription:msg andUrl:url andImageUrl:imgUrl andIfQQZone:NO andBlock:nil];
        }
    }];
    
    //API Level 11
    [bridge registerHandler:@"sendMessage" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data != nil && [data isKindOfClass:[NSString class]]){
            NSString* phoneNumber = @"";
            UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
            [TPMFMessageActionController sendMessageToNumber:phoneNumber
                                                 withMessage:data
                                                 presentedBy:aViewController];
        }
    }];
    
    //API Level 11
    [bridge registerHandler:@"copyToClipboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data != nil && [data isKindOfClass:[NSString class]]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
            pasteboard.string = data;
        }
    }];
    
    //API Level 11
    [bridge registerHandler:@"startController" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *nativeUrl= [[NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error] mutableCopy];
        if ([[nativeUrl allKeys]containsObject:@"ios"]) {
            NSMutableDictionary *dic =  [nativeUrl[@"ios"] mutableCopy];
            if (dic[@"url_string"]) {
                dic[@"url_string"] = [CTUrl encodeRequestUrl:dic[@"url_string"]];
                [nativeUrl setObject:dic forKey:@"ios"];
            }
            [ControllerManager pushController:[nativeUrl objectForKey:@"ios"]];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_JAVASCRIPT_START_NATIVE_ITEM kvs:Pair(@"action", @"javascript"), Pair(@"title",@"startController"), Pair(@"url", nativeUrl), nil];
           responseCallback(@"call success");
        } else {
           responseCallback(@"call failed");
        }
    }];
    //yellowpage end

    // API Level 12
    /*
     * {
     *   'event_name': <event-name>[NString][mandatory],
     *   'event_value': <event-value>[NSNumber][optional],
     *   '<other-key1>': <other-value1>[optional],
     *   ...[optional]
     * }
     */
    [bridge registerHandler:@"recordCustomEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(data != nil && [data isKindOfClass:[NSDictionary class]]) {
            id eventName = data[CUSTOM_EVENT_NAME];
            id eventValue = data[CUSTOM_EVENT_VALUE];
            if (eventName == nil || ![eventName isKindOfClass:[NSString class]]) {
                responseCallback(@"error, must provide event name");
            } else {
                if (![eventValue isKindOfClass:[NSNumber class]]) {
                    eventValue = nil;
                }
                [DialerUsageRecord recordCustomEvent:eventName metric:eventValue extraInfo:data];
                responseCallback(@"success");
            }
        } else {
            responseCallback(@"invalid usage package, must be dictionary");
        }
    }];
}


- (void) shareByWeixin:(NSString *)title andMsg:(NSString *)msg andUrl:(NSString*)url
{
    [[TPShareController controller] voipWechatShare:title andDescription:msg andUrl:url andIfTimeLine:NO andBlock:nil];
    cootek_log(@"voip share single wechat from noah web");
    [DialerUsageRecord recordpath:EV_VOIP_SHARE_SINGLE_WECHAT kvs:Pair(@"fromWhere", sourceName), nil];
    
}

- (void) shareByWeixinTimeLine:(NSString *)title andMsg:(NSString *)msg andUrl:(NSString*)url
{
    [[TPShareController controller] voipWechatShare:title andDescription:msg andUrl:url andIfTimeLine:YES andBlock:nil];
    cootek_log(@"voip share timeline wechat from noah web");
    [DialerUsageRecord recordpath:EV_VOIP_SHARE_TIMELINE_WECHAT kvs:Pair(@"fromWhere", sourceName), nil];
}

@end
