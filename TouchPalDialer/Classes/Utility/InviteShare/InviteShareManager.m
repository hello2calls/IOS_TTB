//
//  InviteShareManager.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/7.
//
//

#import "InviteShareManager.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "InviteShareData.h"
#import "InviteShareViewFactory.h"
#import "InviteShareView.h"
#import "TouchPalDialerAppDelegate.h"
#import "VoipShareAllView.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"

#define PATH_HANGUP_INVITE @"path_hangup_invite"
#define SHARE_TYPE @"share_type"
#define TARGET_NUMBER @"number"
#define ACTION @"action"

#define PATH_HANGUP_INVITE_MORE_SHARE @"path_hangup_invite_more_share"
#define KEY_SHARE @"key_share"
#define SOURCE @"source"
#define RESULT_SHARE @"result_share"

@interface InviteShareManager() {
    NSString *_targetPhone;
    NSInteger _shareType;
    NSString *_keyShare;
}

@property (nonatomic, copy) void(^failBlock)();
@property (nonatomic, assign) BOOL isRequest;
@end

static InviteShareManager *instance;

@implementation InviteShareManager

+ (void)initialize {
    instance = [[InviteShareManager alloc]init];
}

+ (instancetype)instance {
    return instance;
}

- (void)requestInviteShare:(NSDictionary *)param withInviteFailBlock:(void(^)())failBlock{
    NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];
    if (accountName == nil) {
        return;
    }
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    NSInteger nextUpdate = [UserDefaultsManager intValueForKey:@"invite_share_next_update_time"];
    if ( now < nextUpdate ){
        failBlock();
        return;
    }
    
    if ( _isRequest ){
        failBlock();
        return;
    }
    if ( ! param || param.count == 0 ){
        cootek_log(@"invitesharemanager error dict is null");
        failBlock();
        self.failBlock = nil;
        return;
    }
    _isRequest = YES;
    self.failBlock = failBlock;
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSDictionary *resultDict = [SeattleFeatureExecutor inviteShareRequest:param];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultDict && resultDict.count ){
                [self showInviteView:resultDict];
            }else{
                self.failBlock();
            }
            _isRequest = NO;
            self.failBlock = nil;
        });

    });

}

- (void)showInviteView:(NSDictionary *)dict{
    _targetPhone = dict[@"share_target_phone"];
    _shareType = [dict[@"share_type"] integerValue];
    _keyShare = [self generateShareKey];
    
    InviteShareData *data = [[InviteShareData alloc]initWithDictionary:dict];
    InviteShareView *view = [InviteShareViewFactory showInviteShareView:data inParent:[TouchPalDialerAppDelegate naviController].topViewController.view];
    __weak InviteShareManager *wself = self;
    view.cancelBlock = ^{
        [wself cancelButtonAction:data];
    };
    view.leftBlock = ^{
        [wself leftButtonAction:data];
    };
    view.rightBlock = ^{
        [wself rightButtonAction:data];
    };
}

- (void)cancelButtonAction:(InviteShareData *)data {
    NSInteger num = [UserDefaultsManager intValueForKey:@"invite_share_close_time" defaultValue:0];
    num = num + 1;
    [UserDefaultsManager setIntValue:num forKey:@"invite_share_close_time"];
    [DialerUsageRecord recordpath:PATH_HANGUP_INVITE kvs:Pair(SHARE_TYPE, @(_shareType)),Pair(TARGET_NUMBER, _targetPhone), Pair(KEY_SHARE, _keyShare), Pair(ACTION, @(0)), nil];
}

- (void)leftButtonAction:(InviteShareData *)data {
    if (!data.shareUrl.length)
        return;
    ShareResultCallback callBack = ^(ShareResult ret, NSString *source, NSString *error) {
        switch (ret) {
            case ShareSuccess:
                [DialerUsageRecord recordpath:PATH_HANGUP_INVITE_MORE_SHARE kvs:Pair(SOURCE, source), Pair(RESULT_SHARE, @(2)), Pair(KEY_SHARE, _keyShare), nil];
                break;
            case ShareFail:
                [DialerUsageRecord recordpath:PATH_HANGUP_INVITE_MORE_SHARE kvs:Pair(SOURCE, source), Pair(RESULT_SHARE, @(1)), Pair(KEY_SHARE, _keyShare),nil];
                break;
            case ShareCancel:
                [DialerUsageRecord recordpath:PATH_HANGUP_INVITE_MORE_SHARE kvs:Pair(SOURCE, source), Pair(RESULT_SHARE, @(0)), Pair(KEY_SHARE, _keyShare),nil];
                break;
            default:
                break;
        }
    };
    VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:data.shareTitle msg:data.shareMessage url:data.shareUrl buttonArray:data.shareList];
    shareAllView.shareResultCallback = [callBack copy];
    [shareAllView setHeadTitle:data.shareHeaderTitle];
    shareAllView.imageUrl = data.shareImgUrl;
    shareAllView.fromWhere = @"invite_share";
    [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
    [DialerUsageRecord recordpath:PATH_HANGUP_INVITE kvs:Pair(SHARE_TYPE, @(_shareType)),Pair(TARGET_NUMBER, _targetPhone), Pair(KEY_SHARE, _keyShare), Pair(ACTION, @(1)), nil];
    
}

- (void)rightButtonAction:(InviteShareData *)data {
    if (!data.shareUrl.length)
        return;
    [FunctionUtility shareSMS:data.shareUrl andNeedDefault:NO andMessage:data.shareMessage andNumber:data.shareTargetPhone andFromWhere:@"invite_share"];
    [DialerUsageRecord recordpath:PATH_HANGUP_INVITE kvs:Pair(SHARE_TYPE, @(_shareType)),Pair(TARGET_NUMBER, _targetPhone), Pair(KEY_SHARE, _keyShare), Pair(ACTION, @(2)), nil];
}

- (NSString *)generateShareKey{
    NSInteger now = [[NSDate date]timeIntervalSince1970];
    NSString *phone = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    return [NSString stringWithFormat:@"%@_%@_%d",phone,_targetPhone,now];
}



@end
