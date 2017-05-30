//
//  TouchPalDialerAppDelegate+RDVTabBar.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/20.
//
//

#import "TouchPalDialerAppDelegate+RDVTabBar.h"
#import "TPDLib.h"

#import "TPDPersonalCenterController.h"

#import "TPDContactsViewController.h"
#import "FindNewsListViewController.h"
#import "TPDialerResourceManager.h"

@implementation TouchPalDialerAppDelegate (RDVTabBar)
ADD_DYNAMIC_PROPERTY(RDVTabBarController*, tabBarController, setTabBarController)


#pragma mark 重构
- (void)setupAppRootViewController {
    
    NSArray *mapList = @[
                         @{@"class":@"TPDPhoneCallViewController", @"title":@"电话", @"icon":@"common_tabbar_dialer"},
                         @{@"class":@"TPDContactsViewController", @"title":@"联系人", @"icon":@"common_tabbar_contact"},
                         @{@"class":@"TPDDiscoverViewController", @"title":@"发现", @"icon":@"common_tabbar_find"},
                         @{@"class":@"TPDPersonalCenterController", @"title":@"我", @"icon":@"common_tabbar_wall"}
                         ];
     
    NSMutableArray *vcList = [NSMutableArray array];
    for (NSDictionary *dict in mapList) {
        UIViewController *vc = (UIViewController *)[[NSClassFromString(dict[@"class"]) alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBarHidden = YES;
        [vcList addObject:nav];
    }
    self.tabBarController.viewControllers = vcList;
    
    NSArray* tabBarItems = @[[TPDTabBarItem dialTabItem], [TPDTabBarItem contactTabItem], [TPDTabBarItem discoveryTabItem], [TPDTabBarItem meTabItem]];
    
    
    RDVTabBar *tabBar = self.tabBarController.tabBar;
    [tabBar setItems:tabBarItems];
    UIView *subView = [[[UIView alloc] init] tpd_withBackgroundColor:RGB2UIColor(0xcccccc)];
    [tabBar addSubview:subView];
    [subView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(tabBar);
        make.height.equalTo(.3f);
    }];
    
    UIImageView* background = [[UIImageView alloc] initWithImage:[TPDialerResourceManager getImage:@"common_tab_bar_bg@2x.png"]];
    [tabBar insertSubview:background aboveSubview:tabBar.backgroundView];
    [background makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tabBar);
    }];
    [tabBar setHeight:49];
     
    [[NSNotificationCenter defaultCenter] addObserverForName:N_SKIN_DID_CHANGE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [background setImage:[TPDialerResourceManager getImage:@"common_tab_bar_bg@2x.png"]];
        for (TPDTabBarItem* item in tabBarItems) {
            [item reconfig];
        }
    }];
}
@end
