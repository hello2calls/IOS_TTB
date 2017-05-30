//
//  VoipFirstCallView.m
//  TouchPalDialer
//
//  Created by game3108 on 15-1-7.
//
//

#import "VoipFirstCallView.h"
#import "TPDialerResourceManager.h"
#import "FreeCallLoginController.h"
#import "LoginController.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"
#define HEIGHT_ADAPT TPScreenHeight()/640

@interface VoipFirstCallView(){
    UIView *_callBoard;
    UILabel *nameLabel;
    UIButton *normalCallButton;
    BOOL onTouchMove;
}
@end

@implementation VoipFirstCallView
static float scaleRatio;

- (instancetype)initWithFrame:(CGRect)frame ifOversea:(BOOL)oversea{
    self = [super initWithFrame:frame];
    
    if (self){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        scaleRatio = HEIGHT_ADAPT > 1 ? 1 : HEIGHT_ADAPT;
        int globalY = 16 * scaleRatio;
        
        _callBoard = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 220 * scaleRatio )];
        _callBoard.backgroundColor = [UIColor whiteColor];
        [self addSubview:_callBoard];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, globalY, frame.size.width - 32, FONT_SIZE_1_5 * scaleRatio)];
        if(oversea){
            nameLabel.text = NSLocalizedString(@"voip_oversea_you_dont_start_voip", "");
        }else{
            nameLabel.text = NSLocalizedString(@"voip_you_dont_start_voip","");
        }
        nameLabel.font = [UIFont systemFontOfSize:FONT_SIZE_1_5 * scaleRatio];
        nameLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_mainLabel_text_color"];
        nameLabel.backgroundColor = [UIColor clearColor];
        [_callBoard addSubview:nameLabel];
        
        globalY += 40 * scaleRatio;
        UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width-32, VOIP_LINE_HEIGHT * scaleRatio)];
        startButton.layer.masksToBounds = YES;
        startButton.layer.cornerRadius = 4.0f;
        [startButton setTitle:NSLocalizedString(@"voip_start_now", "") forState:UIControlStateNormal];
        [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [startButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_sure_button_onClick_bg_image"] forState:UIControlStateHighlighted];
        [startButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_sure_button_normal_bg_image"] forState:UIControlStateNormal];
        [startButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_sure_button_disable_bg_image"] forState:UIControlStateDisabled];
        [_callBoard addSubview:startButton];
        [startButton addTarget:self action:@selector(startRegister) forControlEvents:UIControlEventTouchUpInside];
        
        
        globalY += startButton.frame.size.height + 16;
        normalCallButton = [[UIButton alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width-32, VOIP_LINE_HEIGHT * scaleRatio)];
        normalCallButton.layer.masksToBounds = YES;
        normalCallButton.layer.cornerRadius = 4.0f;
        [normalCallButton setTitle:NSLocalizedString(@"voip_not_interest", "") forState:UIControlStateNormal];
        [normalCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [normalCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_normal_bg_image"] forState:UIControlStateNormal];
        [normalCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_onClick_bg_image"] forState:UIControlStateHighlighted];
        [_callBoard addSubview:normalCallButton];
        [normalCallButton addTarget:self action:@selector(onClickNormalCallButton) forControlEvents:UIControlEventTouchUpInside];
        [normalCallButton addTarget:self action:@selector(highlightNormalCallButtonBorderColor) forControlEvents:UIControlStateHighlighted];
        [normalCallButton addTarget:self action:@selector(changeNormalCallButtonBorderColor) forControlEvents:UIControlEventTouchUpOutside];
        
        [self showInAnimation:_callBoard];
        
    }
    return self;
}

- (void)changeNormalCallButtonBorderColor{
    normalCallButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_normalbutton_normal_color"].CGColor;
}

- (void)highlightNormalCallButtonBorderColor{
    normalCallButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_normalbutton_disable_color"].CGColor;
}


- (void) showInAnimation:(UIView *)animationView {
    CGRect oldFrame = animationView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         animationView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() - oldFrame.size.height - (20 - TPHeaderBarHeightDiff()) , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }
                     completion:nil];
}

- (void) showOutAnimation:(UIView *)animationView {
    CGRect oldFrame = animationView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         animationView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
                     }
                     completion:^(BOOL finish){
                         if (finish){
                             [self removeFromSuperview];
                         }
                     }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    if (!_callBoard.hidden){
        if (point.y < TPScreenHeight() - _callBoard.frame.size.height && !onTouchMove){
            [self removeShareView];
        }else{
            onTouchMove = NO;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    onTouchMove = YES;
}


- (void)startRegister{
    [DialerUsageRecord recordpath:PATH_LOGIN
                              kvs:Pair(LOGIN_FROM, LOGIN_FROM_FIRST_DIAL_RECOMMEND), nil];
    [_delegate clickRegisterButton];
    [self removeFromSuperview];
}

- (void)onClickNormalCallButton{
    [_delegate clickNoInterestButton];
    [self removeFromSuperview];
}


- (void) removeShareView {
    [self showOutAnimation:_callBoard];
}

- (void) onClickSetting {
    
}
@end
