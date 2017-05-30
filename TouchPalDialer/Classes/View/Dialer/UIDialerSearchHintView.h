//
//  UIDialerSearchHintView.h
//  TouchPalDialer
//
//  Created by Stony Wang on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"
#import "PersonalCenterController.h"


#define CALLLOG_CLEAR_HINT_VIEW_Y (73)
#define CALLLOG_CLEAR_HINT_VIEW_Y_SMALL (22)

@interface UIDialerSearchHintView : UIView <SelfSkinChangeProtocol>
- (instancetype) initWhenNewInstallWithFrame:(CGRect)frame;

@property(nonatomic, retain)UILabel *line1;
@property(nonatomic, retain)UILabel *line2;
@property(nonatomic, retain)UIImageView *imageView;
@property(nonatomic,retain)UIView *hintHolderView;
@property(nonatomic,retain)PersonalCenterController *PersonalCenter;
- (void) hideAllView;
- (void) showAllView;





@end
