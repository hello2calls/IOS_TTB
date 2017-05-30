//
//  DialerGuideAnimationView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import "DialerGuideAnimationView.h"
#import "DialerGuideAnimationStringView.h"
#import "DialerGuideAnimationKeyboardView.h"
#import "DialerGuideAnimationBottomTabView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "DialerGuideAnimationBoardView.h"
#import "DialerUsageRecord.h"

@interface DialerGuideAnimationView()<DialerGuideAnimationKeyboardViewDelegate>{
    DialerGuideAnimationStringView *_stringView;
    
    UILabel *firstLabel;
    UILabel *secondLabel;
    UILabel *thirdLabel;
    
    DialerGuideAnimationKeyboardView *keyboardView;
    UIButton *chooseButton;
    UIButton *escapeButton;
    
    BOOL _ifFinish;
}

@end

@implementation DialerGuideAnimationView

- (instancetype)init{
    
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    
    if ( self ){
        self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_850"];
        
        _ifFinish = NO;
        
        UIButton *pressButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-70, 20, 60, 44)];
        pressButton.backgroundColor = [UIColor clearColor];
        [pressButton addTarget:self action:@selector(onPressButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pressButton];
        
        escapeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 24)];
        [escapeButton setTitle:@"跳过" forState:UIControlStateNormal];
        [escapeButton setBackgroundColor:[UIColor clearColor]];
        [escapeButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"] forState:UIControlStateNormal];
        [escapeButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"] withFrame:escapeButton.bounds]  forState:UIControlStateHighlighted];
        escapeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12];
        escapeButton.layer.masksToBounds = YES;
        escapeButton.layer.cornerRadius = 2.0f;
        escapeButton.layer.borderWidth = 1.0f;
        escapeButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"].CGColor;
        [escapeButton addTarget:self action:@selector(onEscapeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [pressButton addSubview:escapeButton];
        
        float globalY = 70;
        
        firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, self.frame.size.width, 20)];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.textColor = [UIColor whiteColor];
        firstLabel.text = @"要快速找人？";
        firstLabel.alpha = 0;
        firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
        [self addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 6;
        
        secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, self.frame.size.width, 20)];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.textColor = [UIColor whiteColor];
        secondLabel.text = @"拨号盘输入姓名拼音快速搜索";
        secondLabel.alpha = 0;
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
        [self addSubview:secondLabel];
        
        globalY += secondLabel.frame.size.height + 25;
        
        thirdLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, self.frame.size.width, 20)];
        thirdLabel.textAlignment = NSTextAlignmentCenter;
        thirdLabel.textColor = [UIColor whiteColor];
        thirdLabel.text = @"如输入\"5474\",找";
        thirdLabel.alpha = 0;
        thirdLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
        [self addSubview:thirdLabel];
        
        globalY += thirdLabel.frame.size.height + 10;
        
        _stringView = [[DialerGuideAnimationStringView alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), 30)];
        _stringView.alpha = 0;
        [self addSubview:_stringView];
        
        DialerGuideAnimationBottomTabView *tabView = [[DialerGuideAnimationBottomTabView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-TAB_BAR_HEIGHT,self.frame.size.width, TAB_BAR_HEIGHT)];
        [self addSubview:tabView];
        
        keyboardView = [[DialerGuideAnimationKeyboardView alloc]initWithFrame:[self calculatePhonePadFrame]];
        keyboardView.delegate = self;
        [self addSubview:keyboardView];
        keyboardView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

        
        
        chooseButton = [[UIButton alloc]initWithFrame:CGRectMake(0, TPScreenHeight(), TPScreenWidth(), 0)];
        [chooseButton setTitle:@"赶紧试试吧>>" forState:UIControlStateNormal];
        [chooseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        chooseButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
        [chooseButton setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"]];
        chooseButton.alpha = 0;
        [chooseButton addTarget:self action:@selector(onEscapeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chooseButton];
        
        if ([[UIDevice currentDevice] systemVersion].floatValue<7.0) {
            firstLabel.backgroundColor = [UIColor clearColor];
            secondLabel.backgroundColor = [UIColor clearColor];
            thirdLabel.backgroundColor = [UIColor clearColor];
        }
        
        [self startAnimation];
    }
    
    return self;
}

- (void)onPressButtonTouchUpInside{
    [escapeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)startAnimation{
    [self performSelector:@selector(fristLabelAnimation) withObject:nil afterDelay:1.0f];
}

- (void)fristLabelAnimation{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         firstLabel.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         if ( !finished )
                             return;
                         [self performSelector:@selector(secondLabelAnimation) withObject:nil afterDelay:0.3f];
                     }];
}

- (void)secondLabelAnimation{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         secondLabel.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         if ( !finished )
                             return;
                         [self performSelector:@selector(thirdLabelAnimation) withObject:nil afterDelay:0.3f];
                     }];
}

- (void)thirdLabelAnimation{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         thirdLabel.alpha = 1;
                         _stringView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         if ( !finished )
                             return;
                         [self performSelector:@selector(keyboardAnimation) withObject:nil afterDelay:0.8f];
                     }];
}

- (void)keyboardAnimation{
    [keyboardView startAnimation];
}

- (CGRect)calculatePhonePadFrame
{
    if ([[UIDevice currentDevice] systemVersion].floatValue<7.0) {
        return CGRectMake(0, TPAppFrameHeight()-TAB_BAR_HEIGHT-(TPKeypadHeight()+5)+TPHeaderBarHeightDiff()+20, TPScreenWidth(), TPKeypadHeight()+5);
    }
    return CGRectMake(0, TPAppFrameHeight()-TAB_BAR_HEIGHT-(TPKeypadHeight()+5)+TPHeaderBarHeightDiff(), TPScreenWidth(), TPKeypadHeight()+5);
}

- (void)onAnimationOver{
    [self buttonAnimationUp];
}

- (void)buttonAnimationUp{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         chooseButton.alpha = 1.2;
                         chooseButton.frame = CGRectMake(0, TPScreenHeight() - TAB_BAR_HEIGHT*1.2 , TPScreenWidth(), TAB_BAR_HEIGHT * 1.2);
                     }
                     completion:^(BOOL finished){
                         if ( !finished )
                             return;
                         [self performSelector:@selector(buttonAnimationDown) withObject:nil];
                     }];
}

- (void)buttonAnimationDown{
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         chooseButton.alpha = 1;
                         chooseButton.frame = CGRectMake(0, TPScreenHeight() - TAB_BAR_HEIGHT , TPScreenWidth(), TAB_BAR_HEIGHT);
                     }
                     completion:^(BOOL finish){
                         _ifFinish = YES;
                     }];
}

- (void)onEscapeButtonPressed{
    if ( _ifFinish ){
        [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(DIALER_GUIDE_ANIMATION_ESCAPE_ANIMATION_FINISH, @(1)), nil];
    }else{
        [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(DIALER_GUIDE_ANIMATION_ESCAPE_ANIMATION_NOT_FINISH, @(1)), nil];
    }
    
    if ( _delegate != nil )
        [_delegate onEscapeButtonPressed];
}

-(void)dealloc{
    _delegate = nil;
}

#pragma mark DialerGuideAnimationKeyboardViewDelegate

- (void)onStartAnimation:(NSInteger)time{
    [_stringView refreshStringView:time];
}

@end
