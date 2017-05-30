//
//  TPUISearchBar.h
//  TouchPalDialer
//
//  Created by 史玮 阮 on 13-8-2.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+WithSkin.h"

@interface TPUISearchBar : UISearchBar <SelfSkinChangeProtocol>
- (void)showBorder;
- (void)hideBorder;

@end
