//
//  FeedsSignPopupView.m
//  TouchPalDialer
//
//  Created by lin tang on 16/10/21.
//
//

#import "FeedsSignPopupView.h"
#import "VerticallyAlignedLabel.h"
#import "YPImageView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "UIColor+TPDExtension.h"
#import "UIView+TPDExtension.h"
#import "TPDLib.h"
#import "FunctionUtility.h"
#import <ReactiveCocoa.h>
#import "TPDExtension.h"


static CGFloat sPopViewWidth = 260;
static CGFloat sPopViewHeight = 280;
static CGFloat sCloseButtomMarginTop = 90;
static CGFloat sCloseButtonHeight = 48;

@implementation FeedsSignPopupView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    return self;
}

- (instancetype) initWithFrame:(CGRect)rect andContent:(NSString *)content
{
    self = [super initWithFrame:rect];
    if (self != nil) {
        @weakify(self);
        UILabel *titleLabel = [[UILabel tpd_commonLabel] tpd_withText:@"今日签到成功"
                                                      color:[UIColor whiteColor]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *contentLabel = [[UILabel tpd_commonLabel] tpd_withText:content
                                                        color:[UIColor whiteColor]];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView *upperContentContainer = [[UIView alloc] init];
        [upperContentContainer tpd_addSubviewsWithVerticalLayout:@[titleLabel, contentLabel]
                                                    offsets:@[@(0), @(20)]];
        // view tree of upper part
        UIView *upperContainer = [[UIView alloc] init];
        upperContainer.backgroundColor = RGB2UIColor2(250, 110, 95);
        [upperContainer addSubview:upperContentContainer];
        [upperContentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(upperContainer);
        }];
        
        //
        UILabel *greetingLabel = [[UILabel tpd_commonLabel] tpd_withText:@"看天天头条 天天领红包"
                                                         color:RGB2UIColor2(179, 179, 179)];
        greetingLabel.textAlignment = NSTextAlignmentCenter;
        
        UIButton *confirmButton = [[UIButton alloc] init];
        confirmButton.clipsToBounds = YES;
        confirmButton.backgroundColor = RGB2UIColor2(250, 110, 95);
        confirmButton.layer.cornerRadius = sCloseButtonHeight / 2;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            @strongify(self);
            [self closeSelf];
            [DialerUsageRecord recordCustomEvent:PATH_FEEDS
                                          module:FEEDS_MODULE
                                           event:FEEDS_SIGN_CLOSED_BY_OK_BTN];
        }];
        
        // view tree of lower part
        UIView *lowerContainer = [[UIView alloc] init];
        lowerContainer.backgroundColor = [UIColor whiteColor];
        [lowerContainer addSubview:greetingLabel];
        [lowerContainer addSubview:confirmButton];
        
        [greetingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(lowerContainer);
            make.top.mas_equalTo(lowerContainer).offset(30);
        }];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, sCloseButtonHeight));
            make.bottom.mas_equalTo(lowerContainer).offset(-20);
            make.centerX.mas_equalTo(lowerContainer);
        }];
        
        // view tree of content view
        UIView *contentContainer = [[UIView alloc] init];
        contentContainer.clipsToBounds = YES;
        contentContainer.layer.cornerRadius = 8;
        
        [contentContainer addSubview:upperContainer];
        [contentContainer addSubview:lowerContainer];
        
        [upperContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(contentContainer);
            make.height.mas_equalTo(134);
        }];
        [lowerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(contentContainer);
            make.top.mas_equalTo(upperContainer.mas_bottom);
        }];
        
        
        // view tree of self
        UIButton *closeButton = [[UIButton alloc] init];
        closeButton.userInteractionEnabled = YES;
        closeButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:40];
        [closeButton setTitle:@"S" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            @strongify(self);
            [self closeSelf];
            [DialerUsageRecord recordCustomEvent:PATH_FEEDS
                                          module:FEEDS_MODULE
                                           event:FEEDS_SIGN_CLOSED_BY_CLOSE_BTN];
        }];

        // view tree of self
        [self addSubview:contentContainer];
        [self addSubview:closeButton];
        
        [contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.height.mas_equalTo(sPopViewHeight);
            make.width.mas_equalTo(sPopViewWidth);
        }];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentContainer);
            make.top.mas_equalTo(contentContainer.mas_bottom).offset(sCloseButtomMarginTop);
        }];
        
        // config font
        CGFloat smallFontSize = 20;
        CGFloat bigFontSize = 24;
        if ([FunctionUtility systemVersionFloat] >= 9.0) {
            NSString *CNFontName = @"PingFangSC-Regular";
            titleLabel.font = [UIFont fontWithName:CNFontName size:smallFontSize];
            contentLabel.font = [UIFont fontWithName:CNFontName size:bigFontSize];
            greetingLabel.font = [UIFont fontWithName:CNFontName size:smallFontSize];
            confirmButton.titleLabel.font = [UIFont fontWithName:CNFontName size:smallFontSize];
        } else {
            titleLabel.font = [UIFont systemFontOfSize:smallFontSize];
            contentLabel.font = [UIFont systemFontOfSize:bigFontSize];
            greetingLabel.font = [UIFont systemFontOfSize:smallFontSize];
            confirmButton.titleLabel.font = [UIFont systemFontOfSize:smallFontSize];
        }
    }
    
    [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_SIGN_SHOW];
    return self;
}

- (instancetype) initWithContent:(NSString *)content {
    CGRect defaultRect = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
    return [self initWithFrame:defaultRect andContent:content];
}

-(void)closeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}


@end
