//
//  UIViewController+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/20.
//
//

#import "UIViewController+TPDExtension.h"
#import <Masonry.h>
#import "TPDLib.h"
#import <RDVTabBarController.h>

@implementation UIViewController (TPDExtension)

+ (UIViewController*)tpd_topViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    return [self topViewControllerWithRootViewController:window.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[RDVTabBarController class]]) {
        RDVTabBarController* tabBarController = (RDVTabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:nav.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


- (UIView*)tpd_makeItScrollBase {
    UIScrollView* scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    scroll.bounces = YES;
    scroll.backgroundColor = RGB2UIColor(0xeeeeee);
    scroll.delegate = self;
    
    
    [self.view addSubview:scroll];
    [scroll makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView* contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [scroll addSubview:contentView];
    [contentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.bottom.equalTo(scroll);
    }];
    
    contentView.clipsToBounds = YES;
    return contentView;
}

-(UITableView*)tpd_tableViewOfController{
    UITableView* table = [[UITableView alloc] init];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = RGB2UIColor(0xeeeeee);
    return table;
}


#pragma mark 侧滑返回相关
-(void)tpd_enableSlideReturn{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.navigationController.viewControllers.count == 1)//关闭主界面的右滑返回
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
