//
//  SignBtnManager.m
//  TouchPalDialer
//
//  Created by lin tang on 16/11/15.
//
//

#import "SignBtnManager.h"
#import "AnimateVerticalTextView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"

SignBtnManager *disconver_sign_instance_ = nil;
@implementation SignBtnManager

- (id) init
{
    self = [super init];
    return self;
}

+ (void)initialize
{
    disconver_sign_instance_ = [[SignBtnManager alloc] init];
}

+ (SignBtnManager *)instance
{
    return disconver_sign_instance_;
}

- (void) createSignBtn:(UIView* ) parentView;
{
    VerticallyAlignedLabel* abtn = [[VerticallyAlignedLabel alloc] init];
    self.signView = abtn;
    self.signParentView = parentView;
    self.signParentView.hidden = YES;
    abtn.backgroundColor = [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil];
    abtn.textColor = [UIColor whiteColor];
    abtn.font = [UIFont systemFontOfSize:7.0f];
    abtn.text = @"签到";
    abtn.textAlignment= NSTextAlignmentCenter;
    abtn.verticalAlignment = VerticalAlignmentMiddle;
    [parentView addSubview:abtn];
    
    [abtn remakeConstraints:^(MASConstraintMaker *make) {
        // w底部距离父视图centerY的距离为10
        make.top.equalTo(parentView.mas_top).offset(4);
        // 左侧距离父视图centerX距离为20
        make.left.equalTo(parentView.mas_centerX).offset(10);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(12);
    }];
    abtn.layer.masksToBounds = YES;
    abtn.layer.cornerRadius = 6;
    
}

- (void) updateBackgroundColor:(BOOL) isSelected
{
    
}

- (void) showSignBtnWithAnimation
{
    self.signParentView.hidden = NO;
    self.signView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.3f animations:^{
        self.signView.transform = CGAffineTransformMakeScale( 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05f animations:^{
            self.signView.transform = CGAffineTransformMakeScale( 1, 1);
        }];
    }];
}

- (void) hideSignBtn
{
    self.signParentView.hidden = YES;
}

@end
