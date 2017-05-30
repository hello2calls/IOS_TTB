//
//  FeedsBtnRefreshManager.m
//  TouchPalDialer
//
//  Created by lin tang on 16/11/15.
//
//

#import "FeedsBtnRefreshManager.h"
#import "AnimateVerticalTextView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UIColor+TPDExtension.h"
#import "CootekNotifications.h"
#import "UIButton+TPDExtension.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "RDVTabBarController+TPDExtension.h"

FeedsBtnRefreshManager *feeds_refresh_instance_ = nil;
@implementation FeedsBtnRefreshManager

- (id) init
{
    self = [super init];
    self.status = 0;
    return self;
}

+ (void)initialize
{
    feeds_refresh_instance_ = [[FeedsBtnRefreshManager alloc] init];
}

+ (FeedsBtnRefreshManager *)instance
{
    return feeds_refresh_instance_;
}

- (void) createRefreshBtn:(UIView* ) parentView
{
    if (!self.refreshView) {
        UIView* backgroundView = [[UIView alloc] init];
        self.containerView = backgroundView;
        backgroundView.backgroundColor = [UIColor clearColor];
        [parentView addSubview:self.containerView];
        [backgroundView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(parentView);
            make.left.equalTo(parentView);
            make.size.mas_equalTo(parentView.bounds.size);
        }];
        
        DiscoverAnimationButton* refreshBtn = [[DiscoverAnimationButton alloc] init];
        self.refreshView = refreshBtn;
        [self.containerView addSubview:refreshBtn];
        [refreshBtn remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(backgroundView);
        }];
        refreshBtn.block = ^{
            [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:[NSString stringWithFormat:@"%@_%d", FEEDS_ICON_CLICKED, [FeedsBtnRefreshManager instance].status]];
            [[NSNotificationCenter defaultCenter]postNotificationName:N_FEEDS_REFRESH object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"feeds_icon_click"]];
        };
        self.containerView.hidden = YES;
    }
}

- (void) showRefreshBtnWithAnimation:(UIViewController *) controller
{
    if  (self.containerView.hidden) {
        self.status = 1;
        self.containerView.hidden = NO;
        [self.refreshView show];
        [self resetTabBarItem: YES withController:controller];
        [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:[NSString stringWithFormat:@"%@_%d", FEEDS_ICON_SHOWED, [FeedsBtnRefreshManager instance].status]];
    }
}

- (void) hideRefreshBtn: (UIViewController *) controller
{
    self.status = 0;
    self.containerView.hidden = YES;
    [self resetTabBarItem: NO withController:controller];
}

- (void) resetTabBarItem:(BOOL) show withController:(UIViewController *) controller
{
    TPDTabBarItem *item =  controller.rdv_tabBarController.tabBar.items[2];
    item.hidden = show;
}

- (void) saveRefresStatus: (UIViewController *) controller
{
    //do not reset status
    self.containerView.hidden = YES;
    [self resetTabBarItem: NO withController:controller];
}

- (void) show :(UIViewController *) controller
{
    switch (self.status) {
        case 1:
        {
            self.containerView.hidden = NO;
            [self resetTabBarItem:YES withController:controller];
            break;
        }
        case 2:
        {
//            [self showLargeBalloonWithAnimation];
            break;
        }
        case 0:
        {
            [self hideRefreshBtn: controller];
            break;
        }
        default:
            break;
    }
}
@end
