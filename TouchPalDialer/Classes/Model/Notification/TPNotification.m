//
//  TPNotification.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-15.
//
//

#import "TPNotification.h"
#import "UILayoutUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultKeys.h"
#import "SettingsModelCreator.h"
#import "UserDefaultKeys.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "TouchPalPutToBottomReminderView.h"
#import "EditVoipViewController.h"
#import "LoginController.h"
#import "FreeCallLoginController.h"
#import "UserStreamViewController.h"
#import "FlowEditViewController.h"
#import "SeattleFeatureExecutor.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultKeys.h"
#import "CallFlowPacketLoginController.h"
#import "NotificationAlertManger.h"
#import "PersonalCenterController.h"
#import "MarketLoginController.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "TaskBonusManager.h"
#import "VoipInternationalRoamingView.h"

typedef enum{
  TPNotificationPriorityFoundCallerId = 1,
  TPNotificationPriorityPutAppToBottom = 2,
  TPNotificationPrioritySwipe = 3,
  TPNotificationPriorityInterfaceInvestigate =5,
  TPNotificationPriorityDefault =3,
}TPNotificationPriority;

@implementation TPNotification

static NSString* code_key_action = @"action";
static NSString* code_key_body = @"body";

@synthesize action;
@synthesize body;

-(void) handleNotificationInApplication:(UIApplication*) application {
    if(self.uniqueKeyInUserDefaults != nil && self.uniqueKeyInUserDefaults.length > 0) {
        if([UserDefaultsManager objectForKey:self.uniqueKeyInUserDefaults]) {
            return;
        }
    }
    
    UINavigationController* controller = ((TouchPalDialerAppDelegate*) [application delegate]).activeNavigationController;
    [self handleNotificationInNavigationController:controller];
    
    if(self.uniqueKeyInUserDefaults != nil && self.uniqueKeyInUserDefaults.length > 0) {
        [UserDefaultsManager setBoolValue:YES forKey:self.uniqueKeyInUserDefaults];
        [UserDefaultsManager synchronize];
    }
}

-(void) handleNotificationInNavigationController:(UINavigationController*) controller {
    //override this method to do the jobs for different notification
}

-(NSTimeInterval) delayTime {
    // For test: change the number to make the notification been invoked shortly.
    //return 1;
    return 60*60*24; // default delay 1 day to show notification
}

-(NSInteger) priority {
    return TPNotificationPriorityDefault;
}

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.action forKey:code_key_action];
    [aCoder encodeObject:self.body forKey:code_key_body];
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.action = [aDecoder decodeObjectForKey:code_key_action];
        self.body = [aDecoder decodeObjectForKey:code_key_body];
    }
    
    return self;
}

@end

@implementation TPPutAppToBottomNotification

+(id) notification {
    TPPutAppToBottomNotification* noti = [[TPPutAppToBottomNotification alloc] init];
    noti.action = NSLocalizedString(@"Now",@"");
    noti.body = NSLocalizedString(@"Help information",@"");
    return noti;
}

-(void) handleNotificationInNavigationController:(UINavigationController*) controller {
    [controller.view addSubview:[TouchPalPutToBottomReminderView view]];
}

-(NSInteger) priority {
    return TPNotificationPriorityPutAppToBottom;
}

-(NSString*) uniqueKeyInUserDefaults {
    return IS_PUT_APP_TO_BOTTOM_REMINDER_ALREADY_SHOWN;
}

@end

@implementation TPFirstCallFriendWithoutVoipNotification

+(id) notification {
    TPFirstCallFriendWithoutVoipNotification* noti = [[TPFirstCallFriendWithoutVoipNotification alloc] init];
    noti.action = NSLocalizedString(@"Now",@"");
    noti.body = @"试试打一通免费电话吧";
    return noti;
}

-(void) handleNotificationInNavigationController:(UINavigationController*) controller {
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
        PersonalCenterController *controller = [[PersonalCenterController alloc] init];
        [navigationController pushViewController:controller animated:YES];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"启用免费电话，需要先绑定手机号。这仅用于身份识别，不会用于任何商业目的。" message:nil cancelTitle:@"取消" okTitle:@"确定" okButtonActionBlock:^(){
            [LoginController checkLoginWithDelegate:[FreeCallLoginController withOrigin:@"handle_voip_notification"]];
        }];
    }
    
}

-(NSInteger) priority {
    return TPNotificationPriorityFoundCallerId;
}

-(NSString*) uniqueKeyInUserDefaults {
    return IS_FIRST_CALL_FRIEND_WITHOUT_VOIP;
}

@end

@implementation TPTaskGetBonusNotification

+(id) notification:(NSString *)body andTaskId:(NSInteger)taskId{
    TPTaskGetBonusNotification* noti = [[TPTaskGetBonusNotification alloc] init];
    noti.action = NSLocalizedString(@"Now",@"");
    noti.body = body;
    noti.taskId = taskId;
    return noti;
}

-(void) handleNotificationInNavigationController:(UINavigationController*) controller {
    [LoginController checkLoginWithDelegate:[MarketLoginController withOrigin:@"handle_flow_notification"]];
    if ( self.taskId == FLOW_CALL_ID )
        [DialerUsageRecord recordpath:EV_ACITIVYT_MARKET_NOTIFICATION_FLOW_CALL_ENTER kvs:Pair(@"count", @(1)), nil];
    else if ( self.taskId == INTERNATIONAL_ROMAING )
        [DialerUsageRecord recordpath:EV_ACITIVYT_MARKET_NOTIFICATION_INTERNATIONAL_ROMAING_ENTER kvs:Pair(@"count", @(1)), nil];

}


-(NSInteger) priority {
    return TPNotificationPriorityFoundCallerId;
}


@end

@implementation TPBackgroundSearchIfCallerIdNotification

+(id) notification:(NSString *)body{
    TPTaskGetBonusNotification* noti = [[TPTaskGetBonusNotification alloc] init];
    noti.action = NSLocalizedString(@"Now",@"");
    noti.body = body;
    return noti;
}

-(void) handleNotificationInNavigationController:(UINavigationController*) controller {
}


-(NSInteger) priority {
    return TPNotificationPriorityFoundCallerId;
}


@end

@implementation TPInternationalRoamingNotification

+(id) notification{
    TPInternationalRoamingNotification* noti = [[TPInternationalRoamingNotification alloc] init];
    noti.action = NSLocalizedString(@"Now",@"");
    noti.body = @"出国用触宝，也能免费打电话哦！";
    return noti;
}

-(void) handleNotificationInNavigationController:(UINavigationController*) controller {
    VoipInternationalRoamingView *view = [[VoipInternationalRoamingView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow addSubview:view];
    [uiWindow bringSubviewToFront:view];
}


-(NSInteger) priority {
    return TPNotificationPriorityFoundCallerId;
}


@end

