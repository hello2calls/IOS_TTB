//
//  FeedsBtnRefreshManager.h
//  TouchPalDialer
//
//  Created by lin tang on 16/11/15.
//
//

#import <Foundation/Foundation.h>
#import "DiscoverAnimationButton.h"
#import "UIViewController+TPDExtension.h"

@interface FeedsBtnRefreshManager : NSObject

@property(strong) DiscoverAnimationButton* refreshView;
@property(strong) UIView* containerView;
@property(assign) int status;
+ (FeedsBtnRefreshManager *)instance;
- (void ) createRefreshBtn:(UIView* ) parentView;
- (void) showRefreshBtnWithAnimation:(UIViewController* )controller;
- (void) show:(UIViewController* )controller;
- (void) hideRefreshBtn: (UIViewController *) controller;
- (void) saveRefresStatus:(UIViewController* )controller;

@end
