//
//  HeaderBar.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"
#import "UIView+Toast.h"

@interface HeaderBar : UIView <SelfSkinChangeProtocol>

@property (nonatomic) UIImageView *bgView;
@property (nonatomic) UIView *backView;

- (id)initHeaderBar;
- (id)initHeaderBarWithTitle:(NSString *)title;
- (id)initHeaderBarWithFrame:(CGRect)frame title:(NSString *)title;
- (void) clearColor;
@end
