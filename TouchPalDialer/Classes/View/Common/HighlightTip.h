//
//  TPUIButton+Tips.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighlightTip : NSObject
- (id)initWithCondition:(BOOL (^)())conditionCheck removeTipAction:(void (^)())removeTipAction;
- (void)attachToButton:(UIButton*)button atPosition:(CGPoint)origin;
- (void)attachToButton:(UIButton*)button atPosition:(CGPoint)origin removeWhenClick:(BOOL)flag;
- (void)attachToButton:(UIButton*)button atPosition:(CGPoint)origin image:(UIImage *)icon;
- (void)attachToButton:(UIButton*)button atPosition:(CGPoint)origin removeWhenClick:(BOOL)flag image:(UIImage *)icon;
- (void)attachToView:(UIView*)parentView atPosition:(CGPoint)origin image:(UIImage *)icon;
- (void)attachToView:(UIView*)parentView atPosition:(CGPoint)origin;
- (void)detach;
- (void)removeTip;
@end

@interface UserSettingHighlightTip : HighlightTip
- (id)initWithUserSetting:(NSString*)settingKey expectedValue:(id)expectedValue;
@end
