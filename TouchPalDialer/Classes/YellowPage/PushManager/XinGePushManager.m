//
//  XinGePushManager.m
//  TouchPalDialer
//
//  Created by lei meng on 8/3/15.
//
//

#import <Foundation/Foundation.h>
#import "XingePushManager.h"
#import "XGPush.h"
#import "SeattleFeatureExecutor.h"
#import "NetworkUtility.h"
#import "PushConstant.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "Reachability.h"
#import "PublicNumberProvider.h"

@implementation XinGePushManager

+ (void) startApp
{
    [XGPush startApp:2200137984 appKey:@"IPUM277UH31V"];
    //[XGPush startApp:2290000353 appKey:@"key1"];
    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
}

+ (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

+ (void) registerPush {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

+ (void) registerDevice:(NSString *)deviceToken {
    
    NSString* authToken = [SeattleFeatureExecutor getToken];
    if (authToken == nil) {
        return;
    }
    
    __block BOOL isSuccess = [UserDefaultsManager boolValueForKey:XINGE_ADDUSER_SUCCESS defaultValue:NO];
    if (isSuccess) {
        return;
    }
    
    if ([Reachability network] < network_2g) {
        cootek_log(@"network is not available!");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString* url;
        if (USE_DEBUG_SERVER) {
            url = [NSString stringWithFormat:XINGE_REGISTER_DEBUG_DEVICE_URL, YP_DEBUG_SERVER];
        } else {
            url = [NSString stringWithFormat:XINGE_REGISTER_DEVICE_URL, SEARCH_SITE];
        }
        
        NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@?_token=%@&clientid=%@", url, authToken, deviceToken]];
        
        NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
        cootek_log(@"registerDevice --> url : %@", url);
        [httpIndexRequest setHTTPMethod:@"GET"];
        NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
        NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
        NSInteger status=[response_url statusCode];
        if (status == 200) {
            NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
            NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error =nil;
            NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
            int resultCode = [[returnData objectForKey:@"error_code"]integerValue];
            if (resultCode == 0) {
                [UserDefaultsManager setBoolValue:YES forKey:XINGE_ADDUSER_SUCCESS];
            }
        }
    });
}


@end
