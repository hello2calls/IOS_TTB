//
//  GYChangeTextView.m
//  GYShop
//
//  Created by mac on 16/6/13.
//  Copyright © 2016年 GY. All rights reserved.
//

#import "AnimateVerticalTextView.h"
#import "TPDialerResourceManager.h"

#define DEALY_WHEN_TITLE_IN_MIDDLE  0.0
#define DEALY_WHEN_TITLE_IN_BOTTOM  0.0
#define LIMIT_ANIM_TIMES 10

#define TOUTIAO @"头条"

typedef NS_ENUM(NSUInteger, GYTitlePosition) {
    GYTitlePositionTop    = 1,
    GYTitlePositionMiddle = 2,
    GYTitlePositionBottom = 3
};

@interface AnimateVerticalTextView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) NSArray *contentsAry;
@property (nonatomic, assign) CGPoint topPosition;
@property (nonatomic, assign) CGPoint middlePosition;
@property (nonatomic, assign) CGPoint bottomPosition;
@property (nonatomic, assign) CGFloat needDealy;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL shouldStop;
@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, strong) UILabel* bgLabel;

@end

@implementation AnimateVerticalTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.topPosition    = CGPointMake(self.frame.size.width/2 - 2, -self.frame.size.height/2 - 2);
        self.middlePosition = CGPointMake(self.frame.size.width/2 - 2, self.frame.size.height/2 - 2 );
        self.bottomPosition = CGPointMake(self.frame.size.width/2 - 2, self.frame.size.height/2*3 - 2);
        self.shouldStop = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _bgLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _bgLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:24];
        _bgLabel.text = @"1";
        _bgLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"header_btn_color"];
        [self addSubview:_bgLabel];
        
        UIView* animationView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, CGRectGetWidth(frame) - 4, CGRectGetHeight(frame) - 4)];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.layer.bounds = CGRectMake(0, 0, CGRectGetWidth(animationView.frame), CGRectGetHeight(animationView.frame));
        _textLabel.layer.position = self.middlePosition;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"header_btn_color"];
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.text = TOUTIAO;
        [animationView addSubview:_textLabel];
        animationView.clipsToBounds = YES;
        [self addSubview: animationView];
        
        
        self.needDealy = DEALY_WHEN_TITLE_IN_MIDDLE;    /*控制第一次显示时间*/
        self.currentIndex = 0;
    }
    return self;
}

- (void)animation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.contentsAry = [NSArray arrayWithObjects:TOUTIAO,TOUTIAO,TOUTIAO, nil];
        [self startAnimation];
    });
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //highlight
    if (self.pressed) {
        _bgLabel.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
        _textLabel.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
    } else {
        _bgLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"header_btn_color"];
        _textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"header_btn_color"];
    }
}

- (void) start
{
    _count = 0;
    self.shouldStop = NO;
    [self startAnimation];
}

- (void)startAnimation {
    if (_count < LIMIT_ANIM_TIMES) {
        _count ++;
    } else {
        self.shouldStop = YES;
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.05 delay:self.needDealy options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if ([weakSelf currentTitlePosition] == GYTitlePositionTop) {
            weakSelf.textLabel.layer.position = weakSelf.middlePosition;
        } else if ([weakSelf currentTitlePosition] == GYTitlePositionMiddle) {
            weakSelf.textLabel.layer.position = weakSelf.bottomPosition;
        }
    } completion:^(BOOL finished) {
        if ([weakSelf currentTitlePosition] == GYTitlePositionBottom) {
            weakSelf.textLabel.layer.position = weakSelf.topPosition;
            weakSelf.needDealy = DEALY_WHEN_TITLE_IN_BOTTOM;
            weakSelf.currentIndex ++;
            weakSelf.textLabel.text = [weakSelf.contentsAry objectAtIndex:[weakSelf realCurrentIndex]];
        } else {
            weakSelf.needDealy = DEALY_WHEN_TITLE_IN_MIDDLE;
        }
        if (!weakSelf.shouldStop) {
            [weakSelf startAnimation];
        } else { //停止动画后，要设置label位置和label显示内容
            weakSelf.textLabel.layer.position = weakSelf.middlePosition;
            weakSelf.textLabel.text = [weakSelf.contentsAry objectAtIndex:[weakSelf realCurrentIndex]];
            if (self.delegate) {
                [_delegate animationDone];
            }
            
        }
    }];
    
    
}

- (void)stop {
    _count = 0;
    self.shouldStop = YES;
}

- (NSInteger)realCurrentIndex {
    return self.currentIndex % [self.contentsAry count];
}

- (GYTitlePosition)currentTitlePosition {
    if (self.textLabel.layer.position.y == self.topPosition.y) {
        return GYTitlePositionTop;
    } else if (self.textLabel.layer.position.y == self.middlePosition.y) {
        return GYTitlePositionMiddle;
    }
    return GYTitlePositionBottom;
}

- (void)doClick {
    if ([self.delegate respondsToSelector:@selector(gyChangeTextView:didTapedAtIndex:)]) {
        [self.delegate gyChangeTextView:self didTapedAtIndex:[self realCurrentIndex]];
    }
}

@end
