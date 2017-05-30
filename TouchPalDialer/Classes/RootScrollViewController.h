//
//  RootScrollViewController.h
//  TouchPalDialer
//
//  Created by Scyuan on 14-7-2.
//
//

#import <UIKit/UIKit.h>
#import "RootTabBar.h"
#import "RootScrollView.h"
#import "AllViewController.h"
#import "DialerViewController.h"
#import "FilterContactResultListView.h"

@interface RootScrollViewController : UIViewController<RootTabBarDelegate>

@property(nonatomic,retain) AllViewController *contactViewController;
@property(nonatomic,retain) DialerViewController *dialViewController;
@property(nonatomic,retain) FilterContactResultListView *filterViewController;

@property(nonatomic, retain) RootTabBar* tabBar;
@property(nonatomic, retain) NSArray *viewControllers;
@property(nonatomic, retain) RootScrollView *rootView;
- (void) selectTabIndex:(NSInteger)index;
- (int) getSelectedControllerIndex;
@end
