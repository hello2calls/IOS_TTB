//
//  TPVoipPrivilegeADView.m
//  TouchPalDialer
//
//  Created by siyi on 16/1/12.
//
//

#import <Foundation/Foundation.h>
#import "TPVoipPrivilegeADView.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "SeattleFeatureExecutor.h"
#import "NSString+TPHandleNil.h"
#import "TouchPalVersionInfo.h"
#import "HandlerWebViewController.h"
#import "FunctionUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "LocalStorage.h"
#import "DialogUtil.h"
#import "LocalStorage.h"
#import "DialerUsageRecord.h"
#import "NSString+TPHandleNil.h"

static NSArray *_taskTypes;
static NSDictionary *_taskActions;
static UIFont *_commonFont15;
static UIFont *_commonFont17;

@implementation TPVoipPrivilegeADView {
    CGFloat _contentWidth;
    HangupCommercialModel *_model;
    NSString *_callType;
}

+ (void) initialize {
    if (!_taskTypes) {
        _taskTypes = @[@"install", @"share", @"view", @"complete", @"register", @"success"];
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:_taskTypes.count];
        for(NSString *type in _taskTypes) {
            NSString *actionKey = [@"voip_privilege_task_action_" stringByAppendingString:type];
            NSString *action = NSLocalizedString(actionKey, nil);
            [tmp setObject:action forKey:type];
        }
        _taskActions = [tmp copy];

        _commonFont15 = [UIFont systemFontOfSize:15];
        _commonFont17 = [UIFont systemFontOfSize:17];
    }
}

- (instancetype) initWithFrame:(CGRect)frame data:(HangupCommercialModel *) model callType:(NSString *) callType {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        _callType = callType;
        CGFloat gY = 0;
        CGFloat padding ;
        if (TPScreenWidth() > 320) {
            padding = 30;
        }else{
            padding = 20;
        }
        _contentWidth = frame.size.width - 2 * padding;

        // alert hint
        NSString *alertHintText = NSLocalizedString(@"voip_privilege_alert_title", nil);
        UIFont *bold17 = [UIFont boldSystemFontOfSize:17];
        CGSize alertHintSize = [alertHintText sizeWithFont:bold17];
        UILabel *alertHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _contentWidth, alertHintSize.height)];
        alertHintLabel.font = _commonFont17;
        alertHintLabel.text = alertHintText;
        alertHintLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        alertHintLabel.textAlignment = NSTextAlignmentCenter;

        gY += alertHintSize.height;

        // task hint
        gY += 30;
        UIView *taskHintContainer = [self getTaskHintView:CGRectMake(0, gY, 0, 0)];
        gY += taskHintContainer.frame.size.height;

        // task description view
        gY += 30;
        UIView *descriptionView = [self getDescriptionView:model];
        if (!descriptionView) {
            NSString *errorInfo = nil;
            if (_model) {
                errorInfo = _model.rawResponseString;
            }
            [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(VIP_DATA_ERROR, [NSString nilToEmpty:errorInfo]), nil];
            return nil;
        }
        descriptionView.frame = CGRectMake(0, gY,
                                           descriptionView.frame.size.width, descriptionView.frame.size.height);
        gY += descriptionView.frame.size.height;

        // button: cancel or confirm
        gY += 30;
        CGSize buttonSize = CGSizeMake((_contentWidth - 20)/2, 46);

        CGRect cancelButtonFrame = CGRectMake(0, gY, buttonSize.width, buttonSize.height);
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
        [cancelButton setTitle:NSLocalizedString(@"voip_privilege_cancel_task", nil) forState:UIControlStateNormal];
        UIColor *cancelButtonNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [cancelButton setTitleColor:cancelButtonNormalColor forState:UIControlStateNormal];

        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelButton.titleLabel.font = _commonFont17;
        cancelButton.layer.borderWidth = 0.5;
        cancelButton.layer.borderColor = cancelButtonNormalColor.CGColor;

        CGRect confirmButtonFrame = CGRectMake(buttonSize.width + 20, gY, buttonSize.width, buttonSize.height);
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:confirmButtonFrame];
        [confirmButton setTitle:NSLocalizedString(@"voip_privilege_do_task", nil) forState:UIControlStateNormal];
        UIColor *confirmButtonNormalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        [confirmButton setTitleColor:confirmButtonNormalColor forState:UIControlStateNormal];
        UIColor *whiteColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        [confirmButton setBackgroundImage:[FunctionUtility imageWithColor:whiteColor]
                                 forState: UIControlStateHighlighted];

        [confirmButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:UIControlStateHighlighted];
        UIColor *blue500 = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        [confirmButton setBackgroundImage:[FunctionUtility imageWithColor:blue500]
                                 forState: UIControlStateHighlighted];

        confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        confirmButton.titleLabel.font = _commonFont17;
        confirmButton.layer.borderColor = confirmButtonNormalColor.CGColor;
        confirmButton.layer.borderWidth = 0.5;

        [self setViewRoundCorners:@[@(4)] view:cancelButton];
        [self setViewRoundCorners:@[@(4)] view:confirmButton];

        gY += buttonSize.height;

        // root view settings
        self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 4;

        // view tree
        CGSize contentContainerSize = CGSizeMake(_contentWidth, gY);
        UIView *contentContainer = [[UIView alloc] initWithFrame:
                                    CGRectMake(20, 30, contentContainerSize.width, contentContainerSize.height)];

        [contentContainer addSubview:alertHintLabel];
        [contentContainer addSubview:taskHintContainer];
        [contentContainer addSubview:descriptionView];
        [contentContainer addSubview:cancelButton];
        [contentContainer addSubview:confirmButton];

        //
        CGSize adViewSize = CGSizeMake(contentContainerSize.width + 20 * 2, contentContainerSize.height + 30 + 20);
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, adViewSize.width, adViewSize.height);

        [self addSubview:contentContainer];

        [cancelButton addTarget:self action:@selector(cancelTask) forControlEvents:UIControlEventTouchUpInside];
        [confirmButton addTarget:self action:@selector(confirmTask) forControlEvents:UIControlEventTouchUpInside];
    }
    BOOL realShown = 0;
    if (self) {
        realShown = 1;
        [self recordToUsage];
        [self asyncWithUAVisitUrlList:_model.ed_monitor_url withappend:@"&show=1"];
    }
    
    return self;
}

-(void)asyncWithUAVisitUrlList:(NSArray<NSString *> *)urlList withappend:(NSString *)append{
    if (urlList.count==0) {
        return;
    }
    for (NSString *url in urlList) {
        NSMutableString *appendUrl = [NSMutableString stringWithString:url];
        if(appendUrl.length==0){
            return;
        }
        if ([urlList indexOfObject:url]==0 && append.length>0 ) {
            [appendUrl appendString:append];
        }
        [FunctionUtility asyncWithUAVisitUrl:[NSString stringWithFormat: @"%@", appendUrl]tryTime:davinciADMaxTime];
    }
}



- (instancetype) initWithModelData:(HangupCommercialModel *) model callType:(NSString *) callType{
    return [self initWithFrame:CGRectMake(0, 0, TPScreenWidth() - 40, 0) data:model callType:callType];
}

- (instancetype) initWithModelData:(HangupCommercialModel *) model {
    return [self initWithModelData:model callType:VIP_DIRECTLY_CALL];
}


- (void) recordToUsage {
    [DialerUsageRecord recordpath:PATH_VIP
                              kvs:Pair(VIP_AD_ID, [NSString nilToEmpty:_model.adId]),
                                Pair(VIP_CALL_TYPE, _callType),
                              nil];
}

- (void) cancelTask {
    if (self.delegate) {
        [self.delegate cancelTask];
    } else {
        [DialerUsageRecord recordpath:PATH_VIP
                                  kvs:Pair(VIP_AD_ID, _model.adId),
                                    Pair(VIP_CALL_TYPE, _callType),
                                    Pair(VIP_ACTION, VIP_ACTION_QUIT),
                                        nil];
        [self dismiss];
    }

}

- (void) confirmTask {
    if (self.delegate) {
        [self.delegate confirmTask];
    } else {
        NSString *urlString = _model.clk_url;
        cootek_log(@"TPVoipPrivilegeADView, curl: %@", urlString);
        if (urlString) {
            [self asyncWithUAVisitUrlList:_model.clk_monitor_url withappend:nil];
            [self saveDataToStorage];
            HandlerWebViewController *webController = [[HandlerWebViewController alloc] init];
            webController.title = @"VIP提醒";
            webController.url_string = _model.clk_url;
            

            UINavigationController *naviController = [TouchPalDialerAppDelegate naviController];
            [naviController pushViewController:webController animated:YES];
        }
        [self removeFromSuperview];
        [DialerUsageRecord recordpath:PATH_VIP
                                  kvs:Pair(VIP_AD_ID, _model.adId),
                                     Pair(VIP_CALL_TYPE, _callType),
                                     Pair(VIP_ACTION, VIP_ACTION_CONTINUE),
                                     nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DIALOG_DISMISS object:nil];
    };

}

- (BOOL) saveDataToStorage {
    NSString *adString = _model.orginalADJSONString;
    if (adString) {
        [LocalStorage setItemForKey:VOIP_VIP_AD andValue:adString];
        return YES;
    }
    return NO;
}

- (void) showInView:(UIView *)view {
    if (!view) return;
    [DialogUtil showDialogWithContentView:self inRootView:view];
}

- (void) showInAppWindow {
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [self showInView:uiWindow];
}

- (void) dismiss {
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:DIALOG_DISMISS object:nil];
}

- (void) setViewRoundCorners: (NSArray *)cornerRadius view: (UIView *)view {
    if (!view) return;
    NSUInteger count = cornerRadius.count;
    CALayer *layer = view.layer;
    switch (count) {
        case 1:
            layer.cornerRadius = [[cornerRadius objectAtIndex:0] doubleValue];
            view.clipsToBounds = YES;
            break;
        case 0:
            layer.cornerRadius = 0;
        default:
            break;
    }
}


- (NSString *) taskTypeString: (NSString *) rawType {
    return nil;
}


- (NSString *) taskReward: (NSString *)rawType {
    return nil;
}


- (UIView *) getDescriptionView:(HangupCommercialModel *)model {
    if (!model) return nil;
//    NSString *action = [_taskActions objectForKey:model.ttype];
    NSData *rdescData = [model.rdesc dataUsingEncoding:NSUTF8StringEncoding];
    cootek_log(@"TPVoipPrivilegeADView, rdesc: %@", model.rdesc);
    NSError *error;
    NSArray *rewards = [NSJSONSerialization JSONObjectWithData:rdescData options:kNilOptions error:&error];
    if (error) {
        return nil;
    }
    NSDictionary *displayedReward = nil;
    if (rewards.count < 1) {
        return nil;

    } else {
        for (NSDictionary *reward in rewards) {
            NSString *cardType = [reward objectForKey:@"card_type"];
            if ([cardType isEqualToString:CARD_TYPE_VOIP_VIP]) {
                displayedReward = reward;
                break;
            }
        }
    }

    if (!displayedReward) {
        return nil;
    }

    NSString *action = model.ttype;
    if (!action) return nil;
    action= [action stringByAppendingString:@"“"];
    CGSize actionSize = [action sizeWithFont:_commonFont17];

    NSString *format = NSLocalizedString(@"voip_privilege_task_bonus_voip", nil);
    NSNumber *dayCount = [[displayedReward objectForKey:@"voip_vip_info"] objectForKey:@"expired"];
    if (!dayCount) {
        return nil;
    } else {
        NSString *dayCountString = [dayCount stringValue];
        if (!dayCountString || dayCountString.length < 1) {
            return nil;
        }
        double count = -1;
        count = [dayCountString doubleValue];
        if (count == 0) {
            // wrong vip days in string
            return nil;
        }
    }

    NSString *rewardText = [@"”" stringByAppendingString:
                                [NSString stringWithFormat:format, [dayCount stringValue]]];
    CGSize rewardSize = [rewardText sizeWithFont:_commonFont17];

    UIColor *grey600 = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
    UIView *descriptionView = [self getADViewByModel:model];

    CGFloat width = actionSize.width + descriptionView.frame.size.width + rewardSize.width;
    CGFloat paddingLeft = (_contentWidth - width ) / 2;
    CGFloat paddingTop = (descriptionView.frame.size.height - actionSize.height ) / 2;

    // aciton label
    UILabel *actionLabel = [[UILabel alloc] init];
    actionLabel.frame = CGRectMake(paddingLeft, paddingTop, actionSize.width, actionSize.height);
    actionLabel.text = action;
    actionLabel.textColor = grey600;
    actionLabel.font = _commonFont17;

    // description view
    CGSize descViewSize = descriptionView.frame.size;
    descriptionView.frame = CGRectMake(CGRectGetMaxX(actionLabel.frame), 0, descViewSize.width, descViewSize.height);

    // reward label
    UILabel *rewardLabel = [[UILabel alloc] init];
    rewardLabel.frame = CGRectMake(CGRectGetMaxX(descriptionView.frame), paddingTop,
                                   rewardSize.width, rewardSize.height);
    rewardLabel.text = rewardText;
    rewardLabel.textColor = grey600;
    rewardLabel.font = _commonFont17;

    UIView *container = [[UIView alloc] init];
    container.frame = CGRectMake(0, 0, _contentWidth, descViewSize.height);

    [container addSubview:actionLabel];
    [container addSubview:descriptionView];
    [container addSubview:rewardLabel];

    return container;

}

- (UIView *) getADViewByModel:(HangupCommercialModel *)model {

//    :model.title iconImage:model.materialPic

    NSString *adTitle = model.title;
    UIImage *iconImage = model.materialPic;

    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    CGSize adIconSize = CGSizeMake(20, 20);
    iconImageView.frame = CGRectMake(0, 0, adIconSize.width, adIconSize.height);

    CGSize adTitleSize = [adTitle sizeWithFont:_commonFont17];
    UILabel *adTitleLabel = [[UILabel alloc] initWithFrame:
                             CGRectMake(
                             adIconSize.width + 4, (adIconSize.height - adTitleSize.height) / 2 ,
                             adTitleSize.width, adTitleSize.height)];
    adTitleLabel.font = _commonFont17;
    adTitleLabel.text = adTitle;
    adTitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];

    UIView *container = [[UIView alloc] initWithFrame:
                         CGRectMake(0, 0, CGRectGetMaxX(adTitleLabel.frame), adIconSize.height)];
    [container addSubview:iconImageView];
    [container addSubview:adTitleLabel];

    return container;
}

- (UIView *) getTaskHintView:(CGRect) frame {
    UIView *taskHintContainer = [[UIView alloc] init];
    NSString *taskHintText = NSLocalizedString(@"voip_privilege_task_hint_voip", nil);
    CGSize taskHintSize = [taskHintText sizeWithFont:_commonFont15];
    CGRect taskHintFrame = CGRectMake((_contentWidth - taskHintSize.width) / 2 , 0,
                                      taskHintSize.width + 8, taskHintSize.height);
    UILabel *taskHintLabel = [[UILabel alloc] initWithFrame:taskHintFrame];
    taskHintLabel.backgroundColor = [UIColor whiteColor];
    taskHintLabel.text = taskHintText;
    taskHintLabel.font = _commonFont15;
    taskHintLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    taskHintLabel.textAlignment = NSTextAlignmentCenter;

    UIView *taskHintSeparator = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, (taskHintSize.height / 2),  _contentWidth, 1)];
    taskHintSeparator.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_150"];

    taskHintContainer.frame = CGRectMake(frame.origin.x, frame.origin.y, _contentWidth, taskHintSize.height);

    [taskHintContainer addSubview:taskHintSeparator];
    [taskHintContainer addSubview:taskHintLabel];

    return taskHintContainer;
}

@end

