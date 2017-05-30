//
//  SkipButton.h
//  STest
//
//  Created by ALEX on 16/7/13.
//  Copyright © 2016年 ALEX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SkipButtonType)
{
    SkipButtonTypeCircle = 1,
    SkipButtonTypeWave = 2,
    SkipButtonTypeCountDown = 3,
    SkipButtonTypeNormal = 4,
};

@interface SkipButton : UIView

@property (nonatomic,weak,nullable) UIButton *skipBtn;

+ (nullable instancetype) buttonWithType:(SkipButtonType)buttonType;

- (void) setSkipButtonTitle:(nonnull NSString *)title;

- (void) addTarget:(nullable id)target action:(nonnull SEL)action;

- (void) updateProgress:(CGFloat)progress;
@end
