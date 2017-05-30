//
//  DialogUtil.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/15.
//
//

#import <Foundation/Foundation.h>
#import "CootekNotifications.h"

@interface DialogUtil : NSObject
+ (void)showDialogWithContentView:(UIView *)view inRootView:(UIView *)rootView notSeeBgView:(BOOL)notSeeBgView;
+ (void) showDialogWithContentView:(UIView *)view inRootView:(UIView*)rootView;
+ (void) showDialogWithContentView:(UIView *)view withFrame:(CGRect)frame inRootView:(UIView*)rootView;

@end
