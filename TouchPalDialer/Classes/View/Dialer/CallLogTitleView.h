//
//  CallLogTitleView.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-4-24.
//  Copyright (c) 2012å¹?__MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewUtility.h"
#import "UIView+WithSkin.h"
#import "HeadTabBar.h"

@protocol CalllogTitleClickDelegate <NSObject>

@optional
- (void)callLogTitleTabTypesClicked;
- (void)callLogTitleTabAllClicked;
@end

@interface CallLogTitleView : UIView <SelfSkinChangeProtocol,BaseTabBarDelegate>{
    UILabel *textLabel;
    UILabel *titleLabel;
    UIImageView *showSubItemsView;
    HeadTabBar *titleBar;
}
@property(nonatomic,assign)id<CalllogTitleClickDelegate> delegate;
@property(nonatomic,assign)BOOL isJBCallog;
@property(nonatomic,retain)UILabel *titleLabel;
@property(nonatomic,retain)UIImageView *showSubItemsView;

+ (id)createCallLogTitle:(BOOL)isJB;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title;
- (id)initWithFrame:(CGRect)frame;
- (void)clickAll;
@end
