//
//  CootekViewController.h
//  TouchPalDialer
//
//  Created by Sendor on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UILabel+DynamicHeight.h"

@interface CootekViewController : UIViewController

@property (nonatomic, strong) NSString  * controllerId;
@property (nonatomic, strong) NSString  *headerTitle;
@property (nonatomic, strong) HeaderBar *headerBar;
@property (nonatomic, strong) TPHeaderButton *backButton;
@property (nonatomic, strong) UILabel   *headerTitleLabel;

@property (nonatomic) BOOL  skinDisabled;
@property (nonatomic) UIImage   *headerBackgroundImage;
@property (nonatomic) UIColor   *headerTextColor;
@property (nonatomic) UIView    *backgroundView;

- (void)gotoBack;
- (void)setSkin;
- (void) showInNavigationController:(UINavigationController*) navController;
- (UIView *)getBackGroundView;
- (void) resetHeaderFrame;

@end
