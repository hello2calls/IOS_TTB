//
//  BaseTabBar.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseTabBarDelegate <NSObject>

- (void)onClickAtIndexBar:(NSInteger)index;

@end


@interface BaseTabBar : UIView{
    
}
@property(nonatomic,retain)NSMutableArray *buttonArray;
@property(nonatomic,assign)id<BaseTabBarDelegate> delegate;

-(id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count;
-(id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count withWidthPadding:(CGFloat)widthpadding;
- (id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count withWidthPadding:(CGFloat)widthpadding fontSize:(NSInteger)size;
-(void)clickTabIndex:(NSInteger)index;
-(void)tabBarTitle:(NSArray *)titleList;
-(BOOL)isEnableButtonAfterClick;
@end