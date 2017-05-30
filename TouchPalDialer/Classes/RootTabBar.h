//
//  RootTabBar.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//
#import "TPUIButton.h"
#import "RootScrollView.h"
@class RootScrollView;

@class RootTabBar;
@protocol RootTabBarDelegate
- (NSDictionary *)attrForTabAtIndex:(NSUInteger)index;
- (int)getSelectedControllerIndex;
- (void)customTabBar:(RootTabBar*)customTabBar clickedButtonAtIndex:(NSUInteger)buttonIndex;
@end

@interface RootTabBar : UIView
{
    NSInteger userSelectedChannelID;
    
}
@property (nonatomic, assign) NSInteger scrollViewSelectedChannelID;
@property (nonatomic, assign)   RootScrollView *rootScrollView;
@property (nonatomic, assign) id <RootTabBarDelegate> delegate;

- (void)loadItemWithCount:(NSUInteger)itemCount;
- (void)firstSelectButtonAtIndex:(NSInteger)index;

- (void)selectTabAtIndex:(NSInteger)index;

- (void)removeGestureTips:(TPUIButton*) button;
- (void)setButtonUnSelect;
- (void)setButtonSelect;
- (void)rootViewAppear;
- (void)rootViewDisappear;
@end
