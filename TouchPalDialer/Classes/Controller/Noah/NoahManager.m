//
//  NoahMananger.m
//  TouchPalDialer
//
//  Created by game3108 on 14-12-16.
//
//

#import "NoahManager.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "SeattleFeatureExecutor.h"
#import "Reachability.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import "TouchPalVersionInfo.h"
#import "VoipUtils.h"
#import "PublicNumberListController.h"
#import <Usage_iOS/UsageRecorder.h>
#import "CTUrl.h"
#import "YellowPageWebViewController.h"


@interface NoahManager() <ActionDriverDelegate,NativeAppInfoDelegate, PresentStatisticDelegate>{
    BOOL receiveNewUpdate;
    NSMutableArray *fuwuhaoDummyArray;
}
@end

@implementation NoahManager
static NoahManager *noahManager = nil;
static PresentationSystem *ps = nil;
static BOOL sIsReady = NO;

+ (void)initialize{
    noahManager = [[NoahManager alloc]init];
    noahManager->fuwuhaoDummyArray = [NSMutableArray array];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance{
    return noahManager;
}

+ (id)sharedPSInstance{
    return ps;
}


- (void)initNoah:(BOOL) newUpdate{
    cootek_log(@"Noah start!");
    receiveNewUpdate = newUpdate;
    [self initNoahInner];
}

- (void)initNoahInner {
    ps = [PresentationSystem sharedInstance];
    ps.actionDriverDelegate = self;
    ps.nativeAppInfoDelegate = self;
    ps.statisticDelegate = self;
    if (USE_DEBUG_SERVER || [UserDefaultsManager boolValueForKey:NOAH_SHOULD_COPY_LOCAL_FILE defaultValue:YES]) {
        [UserDefaultsManager setBoolValue:NO forKey:NOAH_SHOULD_COPY_LOCAL_FILE];
        [self copyConfigFileToDocument];
        [ps clearAllPresentations];
    }
    [ps presentationInitialize];
    self.actionConformDic = [NSMutableDictionary dictionary];
    cootek_log(@"Noah initialize over!");
}

- (void)copyConfigFileToDocument {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self configFileName]];
    [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[self configFileName]] error:NULL];
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                            toPath:[documentsDirectory stringByAppendingPathComponent:[self configFileName]]
                                             error:NULL];
}

- (NSString *)initialPresentationFilePath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[self configFileName]];
}

- (void)gettoast
{
    DummyToast *dummy = [ps getDummyToast];
    int count = 0;
    while (dummy && count < 10) {
        if ([@"voip_callback_numbers" isEqualToString:dummy.tag]) {
            NSString *numberStr = dummy.display;
            NSArray *numbers = [numberStr componentsSeparatedByString:@"$"];
            [VoipUtils updateBackCallNumberPerson:numbers];
        }
        if ([@"fuwuhao_noah_toast" isEqualToString:dummy.tag]){
            NSString *token = [SeattleFeatureExecutor getToken];
            if ( token ){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self fuwuhaoActivate:dummy];
                });
            }else{
                [self->fuwuhaoDummyArray addObject:dummy];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenActivate) name:N_ACTIVATE_SUCCESS object:nil];
            }
        }
        if ([@"voip_error_code" isEqualToString:dummy.tag]){
            cootek_log(@"%@",[dummy getDownloadFilePathInner]);
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[dummy getDownloadFilePathInner]];
            [VoipUtils  updateVoipErrorCodeJsonWithPath:path withVersion:dummy.display];
        }
        [ps shown:dummy.toastId];
        [ps clicked:dummy.toastId];
        [ps cleaned:dummy.toastId];
        dummy = [ps getDummyToast];
        cootek_log(@"get dummy toast count: %d", ++count);
    }
}

- (void)tokenActivate{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( DummyToast *toast in self->fuwuhaoDummyArray ){
            [self fuwuhaoActivate:toast];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:N_ACTIVATE_SUCCESS object:nil];
        [self->fuwuhaoDummyArray removeAllObjects];
    });
}

- (void)fuwuhaoActivate:(DummyToast *)dummy{
    NSString *description = dummy.summary;
    NSString *normalDescription = [description stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSMutableDictionary *descriptionDic = [NSJSONSerialization JSONObjectWithData:[normalDescription dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSString *serviceId = [descriptionDic objectForKey:@"service_id"];
    if ( serviceId ){
        [PublicNumberListController requestForPublicNumberInfoByServiceId:serviceId];
        [PublicNumberListController addPublicNumberMessage:descriptionDic];
    }
}

#pragma mark ActionDriverDelegate

- (void)endLoadPresentation:(BOOL)result {
    if (result) {
        sIsReady = YES;
        [UserDefaultsManager setObject:[NSDate date] forKey:NOAH_CONFIG_FILE_CHECK];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gettoast];
            [ps getBackgroundImageToast];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_NOAH_LOAD_CONFIG_SUCCESS object:nil];
        });
    }
}

- (BOOL)receiveNewUpdateNotification{
    return receiveNewUpdate;
}

- (NSString *)storagePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    return path;
}

- (NSString *)configFileName
{
    return @"presentation_ios.xml";
}

- (void) showActionConfirmDialog:(NSString *)toastId and:(NSString *) confirmText{
    [DefaultUIAlertViewHandler showAlertViewWithTitle:confirmText message:nil
                                          cancelTitle:NSLocalizedString(@"Cancel", "")
                                              okTitle:NSLocalizedString(@"Ok", "")
                                  okButtonActionBlock:^(){
                                      [ps actionPerformed:toastId];
                                      [[NoahManager sharedPSInstance] cleaned:toastId];
                                      if ( [[[NoahManager sharedInstance] actionConformDic] objectForKey:toastId] ){
                                          void(^block)(void) = [[[NoahManager sharedInstance] actionConformDic] objectForKey:toastId];
                                          block();
                                      }
                                  }
                                    cancelActionBlock:^(){
                                        [[NoahManager sharedPSInstance] cleaned:toastId];
                                        if ( [[[NoahManager sharedInstance] actionConformDic] objectForKey:toastId] ){
                                            void(^block)(void) = [[[NoahManager sharedInstance] actionConformDic] objectForKey:toastId];
                                            block();
                                        }
                                    }];
    
}

- (BOOL) openUrl:(NSString *) url WebTitle:(NSString *)webTitle RequestToken:(BOOL)requestToken{
    NSString *newUrl =  url;
    
    HandlerWebViewController *controller = [[HandlerWebViewController alloc] init];
    controller.isNoah = YES;
    controller.header_title = webTitle;
    NSString *token = [SeattleFeatureExecutor getToken];
    if(requestToken && token.length>0){
         newUrl = [NSString stringWithFormat:@"%@&_token=%@",url,token];
    }

    CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:newUrl];
    UIViewController *webController = [ctUrl startWebView];
    if ([webController isKindOfClass:[YellowPageWebViewController class]]) {
        ((YellowPageWebViewController *)webController).needTitle = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    return YES;
}

- (BOOL)lauchLocalController:(NSString *)controllerName {
    Class nameClass = NSClassFromString(controllerName);
    if (nameClass == nil) {
        return NO;
    }
    
    if (![[[TouchPalDialerAppDelegate naviController]topViewController] isKindOfClass:nameClass]) {
        UIViewController *controller = [[NSClassFromString(controllerName) alloc] init];
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
    return YES;
}
//to do onlyDefault
- (BOOL) changeBoolSetting:(NSString *)key Value:(BOOL)value OnlyDefault:(BOOL)onlyDefault{
    [UserDefaultsManager setBoolValue:value forKey:key];
    return YES;
}
- (BOOL) changeIntSetting:(NSString *)key Value:(int)value OnlyDefault:(BOOL)onlyDefault{
    [UserDefaultsManager setIntValue:value forKey:key];
    return YES;
}
- (BOOL) changeStringSetting:(NSString *)key Value:(NSString *)value OnlyDefault:(BOOL)onlyDefault{
    [UserDefaultsManager setObject:value forKey:key];
    return YES;
}
- (BOOL) changeLongSetting:(NSString *)key Value:(long long)value OnlyDefault:(BOOL)onlyDefault{
    [UserDefaultsManager setObject:[NSNumber numberWithLong:value] forKey:key];
    return YES;
}

- (void) close:(NSString *)toastId{
    
}


#pragma NativeAppInfoDelegate

-(NSString *) getStringSetting:(NSString *)key{
    return (NSString *)[UserDefaultsManager objectForKey:key];
}
-(int) getIntSetting:(NSString *)key{
    return [UserDefaultsManager intValueForKey:key];
}
-(long) getLongSetting:(NSString *)key{
    return [((NSNumber *)[UserDefaultsManager objectForKey:key]) longValue];
}
-(BOOL) getBoolSetting:(NSString *)key{
    return [UserDefaultsManager boolValueForKey:key];
}
-(int) getInitialQuietDays{
    return 0;
}
-(int) getInitialMobileQuietDays{
    return 0;
}
-(NSString *)getAuthToken{
    return [SeattleFeatureExecutor getToken];
}

- (long long)getFirstInstallTimestamp{
    if ( [UserDefaultsManager objectForKey:FIRST_LOAD_TOUCHPAL_TIME] ){
        return [((NSDate *)[UserDefaultsManager objectForKey:FIRST_LOAD_TOUCHPAL_TIME]) timeIntervalSince1970];
    }else{
        return 0;
    }
}

- (BOOL)canExtend:(NSString *)extensionPoint and:(NSString *) extensionConditions{
    return YES;
}

- (BOOL)canPointSelfShow:(NSString *)guidePointId and:(NSString *)selfShowConditions{
    if ([guidePointId isEqualToString:GUIDEPOINT_HELP]) {
        return ([UserDefaultsManager intValueForKey:UMFEEDBACK_MESSAGE_COUNT defaultValue:0] > 0);
    } else if ([guidePointId isEqualToString:GUIDEPOINT_MARKET]) {
        return ([UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_MARKET defaultValue:YES]);
    } else if ([guidePointId isEqual:GUIDEPOINT_SKIN]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_SKIN defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_REDBAG]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_REDBAG defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_VOIP]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_VOIP defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_BACKFEE]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_BACKFEE defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_ANTIHARASS]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_ANTIHARASS defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_WALLET]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_WALLET defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_CARD]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_CARD defaultValue:YES];
    } else if ([guidePointId isEqual:GUIDEPOINT_FREE_MINUTE]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_FREE_MINUTE defaultValue:YES];
    }else if ([guidePointId isEqual:GUIDEPOINT_TRAFFIC ]){
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_TRAFFIC defaultValue:YES];
    }else if ([guidePointId isEqual:GUIDEPOINT_SETTING]) {
        return [UserDefaultsManager boolValueForKey:NOAH_GUIDE_POINT_PERSONAL_SETTING defaultValue:YES];
    }
    return YES;
}

- (BOOL)canPointHolderShow:(NSString *)guidePointId and:(NSString *)holderShowConditions and:(NSString *)extensionId{
    if (holderShowConditions) {
        NSArray *array = [[NoahManager sharedPSInstance] getExtensionStaticToastAndKeyName:holderShowConditions];
        return array.count > 0;
    }
    return YES;
}

- (void)closeToolBarToast{
//Todo ask Jiawen
//    if ( [self actionConformDic] ){
//        NSArray *keys = [[self actionConformDic] allKeys];
//        if ( keys && [keys count] != 0 ){
//            for ( NSString * toastId in keys ){
//                [self close:toastId];
//            }
//        }
//    }
//    cootek_log(@"close toolbar toast finish");
}

- (NSString *)domainName {
    if (ENABLE_NOAH_TEST_DEBUG) {
         return [NSString stringWithFormat:@"%@:%d",NOAH_TEST_DEDUG_SERVER_HOST, NOAH_TEST_DEBUG_HTTP_PORT];
    }
    if (USE_DEBUG_SERVER && !NOAH_LOCAL_DEBUG) {
        return [NSString stringWithFormat:@"%@:%@", @"docker-ws2.cootekservice.com", @"80"];
    }
    if ([UserDefaultsManager boolValueForKey:OPENNOAH_TESTSERVICE]) {
        return [NSString stringWithFormat:@"%@:%@", @"ararat-test.cootekservice.com", @"80"];
    }
    else{
        return [NSString stringWithFormat:@"%@:%@", @"ws2.cootekservice.com", @"80"];
    }
    return @"";
}

#pragma mark UsageRecord Delegate
-(void)saveToUsageWithDictionary:(NSDictionary *)dict andUsagePath:(NSString *)usagePath andUsageRecordType:(NSString *)usageRecordType {
    [DialerUsageRecord record:usageRecordType path:usagePath values:dict];
    [UsageRecorder send];
}


- (void)onAppEnterBackground {
    
}

+ (BOOL)isReady {
    return sIsReady;
}


@end
