//
//  ControllerManager.h
//  TouchPalDialer
//
//  Created by tanglin on 15/9/17.
//
//

#import <UIKit/UIKit.h>

@interface ControllerManager : UIView

+ (UIViewController *) pushAndGetController:(NSDictionary* )nativeDic;
+ (void) pushController:(NSDictionary* )nativeDic;
+ (void) pushController:(NSDictionary* )nativeDic withAnimate:(BOOL)animate;
@end
