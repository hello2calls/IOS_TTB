//
//  SignBtnManager.h
//  TouchPalDialer
//
//  Created by lin tang on 16/11/15.
//
//

#import <Foundation/Foundation.h>
#import "DiscoverAnimationButton.h"

@interface SignBtnManager : NSObject

@property(strong) UIView* signView;
@property(strong) UIView* signParentView;

+ (SignBtnManager *)instance;
- (void ) createSignBtn:(UIView* ) parentView;
- (void) updateBackgroundColor:(BOOL) isSelected;
- (void) showSignBtnWithAnimation;
- (void) hideSignBtn;
@end
