//
//  NewNoticeView.m
//  NewsBannerDemo
//
//  Created by sunhao－iOS on 16/4/28.
//  Copyright © 2016年 ssyzh. All rights reserved.
//

#import "NewsBanner.h"
#import "Masonry.h"

@interface NewsBanner()
@property (nonatomic ,strong) UIView *view;
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,strong) UIView *notice;


@end

@implementation NewsBanner

static int countInt=0;



-(void)setLeftAndNumberStringList:(NSArray *)leftAndNumberStringList{
    if (_leftAndNumberStringList != leftAndNumberStringList) {
        _leftAndNumberStringList = leftAndNumberStringList;
        if (_leftAndNumberStringList.count != 0) {
            _leftLabelView.text = _leftAndNumberStringList[0][0];
            _textView.text = @"10000";
        }
        
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initContentView];
    }
    
    return self;
}

- (void)initContentView{
    self.clipsToBounds = YES;
    self.notice = [UIView new];
    self.notice.backgroundColor =[UIColor clearColor];
    self.notice.userInteractionEnabled = YES;
    [self addSubview:self.notice];
    
    _textView = [[CustomAutoUpTextLable alloc] init];
    _textView.frame = CGRectMake(0, 0, 100, 40);
    _textView.textAlignment = NSTextAlignmentCenter;
    _textView.font =[UIFont systemFontOfSize:22];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor whiteColor];

    
    _leftLabelView = [[UILabel alloc] init];
    _leftLabelView.font = [UIFont systemFontOfSize:22];
    _leftLabelView.backgroundColor = [UIColor clearColor];
    _leftLabelView.text = @"房产中介";
    _leftLabelView.textColor = [UIColor whiteColor];
    
    _rightLabelView = [[UILabel alloc] init];
    _rightLabelView.font = [UIFont systemFontOfSize:22];
    _rightLabelView.backgroundColor = [UIColor clearColor];
    _rightLabelView.text = @"个号码";
    _rightLabelView.textColor = [UIColor whiteColor];
    
    self.view = [UIView tpd_horizontalLinearLayoutWith:@[_leftLabelView,_textView,_rightLabelView] horizontalPadding:0 verticalPadding:0 interPadding:0];
    self.view.backgroundColor =[UIColor clearColor];
    [self.notice addSubview:self.view];
    
    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo([@"88888" sizeWithFont:self.textView.font]);
    }];
    [self.view makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.notice);
    }];
    
    
    
}

- (void)layoutSubviews{
    self.notice.frame = CGRectMake(0, 20, self.bounds.size.width, self.bounds.size.height-40);
}

-(void)displayNews{
    countInt++;
 
    if (countInt >= [self.leftAndNumberStringList[0] count])
        countInt=0;
    CATransition *animation = [CATransition animation];
    animation.duration = _pushDuration;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.notice.layer addAnimation:animation forKey:@"animationID"];
    
    NSString *numberString = _leftAndNumberStringList[1][countInt];
    NSString *leftString = _leftAndNumberStringList[0][countInt];
    self.leftLabelView.text = leftString;
    [self.textView jumpNumberWithDuration:_lableDuration fromNumber:10000 toNumber: numberString.integerValue animationBlock:^{
        
    } endBlock:^{
        
    }];
    [self setNeedsLayout];
}
- (void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stop {
    [self invalidateTimer];
}

-(void)dealloc {
    [self invalidateTimer];
}

- (void)star
{
    if (self.leftAndNumberStringList.count != 0) {
      self.timer = [NSTimer scheduledTimerWithTimeInterval:_lableDuration+_pushDuration target:self selector:@selector(displayNews) userInfo:nil repeats:YES];
        NSString *numberString = _leftAndNumberStringList[1][0];
        NSString *leftString = _leftAndNumberStringList[0][0];

        [self.textView jumpNumberWithDuration:_lableDuration fromNumber:10000 toNumber:numberString.integerValue animationBlock:^{
            
        } endBlock:^{
            
        }];
        self.leftLabelView.text = leftString;
    }

    
}
@end
