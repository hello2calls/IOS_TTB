//
//  InvitingCommand.m
//  TouchPalDialer
//
//  Created by siyi on 16/5/20.
//
//

#import "InvitingCommand.h"
#import "TouchPalDialerAppDelegate.h"
#import "InviteLoginController.h"
#import "HandlerWebViewController.h"
#import "TouchPalVersionInfo.h"

@implementation InvitingCommand

#pragma mark overrides
- (BOOL)canExecute:(OperationSheetType)sheetType {
    return (sheetType == OperationSheetTypeAddContacts);
}

- (NSString *)getCommandName {
    return NSLocalizedString(@"invite_friends", @"邀请有奖");
}


- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray {
    BOOL needLogin = YES;
    if (needLogin) {
        InviteLoginController *loginController = [InviteLoginController withOrigin:@"personal_center_redbag"];
        loginController.shareFrom = @"PersonalCenter";
        [LoginController checkLoginWithDelegate:loginController];
        
    } else {
        HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];
        
        NSString *url = USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;
        NSString *segment = [url rangeOfString:@"?"].length > 0 ? @"&":@"?";
        url = [url stringByAppendingFormat:@"%@%@", segment , @"share_from=group_operation"];
        webVC.url_string = url;
        cootek_log(@"InviteLoginController:%@",url);
        webVC.header_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
        [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
    }
    
}

@end