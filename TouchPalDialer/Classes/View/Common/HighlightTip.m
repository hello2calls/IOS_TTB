//
//  TPUIButton+Tips.m
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HighlightTip.h"
#import "BasicUtil.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"

@interface HighlightTip () {
    UIImageView * tipsView_;
    BOOL (^conditionCheckBlock_)(void);
    void (^removeTipActionBlock_)(void);
}
- (void)executeClickAction:(UIButton*) button;
@end

@implementation HighlightTip

- (id)initWithCondition:(BOOL (^)())conditionCheck removeTipAction:(void (^)())removeTipAction
{
    self = [super init];
    if(self) {
        conditionCheckBlock_ = [conditionCheck copy];
        removeTipActionBlock_ = [removeTipAction copy];
    }
    return self;
}

- (void)attachToButton:(UIButton*) button atPosition:(CGPoint) origin
{
    [self attachToButton:button atPosition:origin removeWhenClick:YES];
}

- (void)attachToButton:(UIButton*) button atPosition:(CGPoint) origin removeWhenClick:(BOOL)flag
{
    UIImage *icon =  [[TPDialerResourceManager sharedManager] getImageByName:@"gesture_tips_new@2x.png"];
    [self attachToButton:button atPosition:origin removeWhenClick:flag  image:icon];
}

- (void)attachToButton:(UIButton*) button atPosition:(CGPoint) origin removeWhenClick:(BOOL)flag image:(UIImage *)icon
{
    [self attachToView:button atPosition:origin image:icon];
    if(flag){
        [button addTarget:self action:@selector(executeClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)attachToButton:(UIButton*) button atPosition:(CGPoint) origin image:(UIImage *)icon
{
    [self attachToButton:button atPosition:origin removeWhenClick:YES image:icon];
}

- (void)executeClickAction:(UIButton*) button
{
    [self removeTip];
}

- (void)removeTip
{
    if(tipsView_ != nil) {
        [self detach];
        
        if(removeTipActionBlock_) {
            removeTipActionBlock_();
        }
    }
}

- (void)attachToView:(UIView*) parentView atPosition:(CGPoint) origin image:(UIImage *)icon
{
    if(conditionCheckBlock_ && conditionCheckBlock_()) {
        if (tipsView_ == nil) {
            tipsView_ = [[UIImageView alloc] initWithFrame:CGRectMake(origin.x, origin.y, icon.size.width, icon.size.height)];
            tipsView_.image = icon;
            [parentView addSubview:tipsView_];
        }
    }
}

- (void)attachToView:(UIView*) parentView atPosition:(CGPoint) origin
{
    UIImage *icon =  [[TPDialerResourceManager sharedManager] getImageByName:@"gesture_tips_new@2x.png"];
    [self attachToView:parentView atPosition:origin image:icon];
}

- (void)detach
{
    [tipsView_ removeFromSuperview];
}
@end

@interface UserSettingHighlightTip() {
    NSString* __strong settingKey_;
    id  __strong expectedValue_;
}
@end

@implementation UserSettingHighlightTip

- (id)initWithUserSetting:(NSString*) settingKey expectedValue:(id) expectedValue {
    
    self = [super initWithCondition:^() {
        id obj = [UserDefaultsManager objectForKey:settingKey];
        cootek_log(@"key: %@  value: %@ expected: %@", settingKey, obj, expectedValue);
        if(obj != nil) {
            if([BasicUtil object:obj equalTo:expectedValue_]) {
                return NO;
            } else {
                return YES;
            }
        }
        return YES;
    }
         removeTipAction:^() {
             [UserDefaultsManager setObject:expectedValue forKey:settingKey];
         }];
    
    if(self) {
        settingKey_ = settingKey;
        expectedValue_ = expectedValue;
    }
    
    return self;
}
@end