//
//  HangupActionView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/11.
//
//

#import "HangupActionView.h"
#import "VoipConsts.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "VoipSimpleButton.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"
CGFloat actionButtonW;
@implementation HangupActionView {
    MainActionViewModel *_model;
    CGFloat _mainButtonH;
    CGFloat _buttonGapV;
    CGRect _threeButtonLeftFrame;
    CGRect _threeButtonMiddleFrame;
    CGRect _threeButtonRightFrame;
    UIColor *_borderTextColor;
}

- (id)initWithModel:(MainActionViewModel *)model {
    _model = model;
    CGFloat scaleRatio = WIDTH_ADAPT;
     actionButtonW = (TPScreenHeight() < 500 ? 60 : 65) * scaleRatio;
    CGFloat actionButtonH = actionButtonW + (TPScreenHeight() < 500 ? 20 : 30)*scaleRatio;
    CGFloat buttonGap = 10 * scaleRatio;
    CGFloat buttonGapV = 16 *scaleRatio;
    _buttonGapV = buttonGapV;
    _mainButtonH = 60 *WIDTH_ADAPT - 10;
    CGFloat width = actionButtonW * 3 + 2 * buttonGap;
    CGFloat height = actionButtonH + buttonGapV + _mainButtonH;
    float leftButtonX = 0;
    float rightButtonX = width - leftButtonX - actionButtonW;
    float middleButtonX = leftButtonX + actionButtonW + buttonGap;
    CGFloat buttonY = _buttonGapV + _mainButtonH;
    if (_model.mainButtonTitle == nil) {
        buttonY = 0;
        height = actionButtonH;
    }
    _threeButtonLeftFrame = CGRectMake(leftButtonX, buttonY, actionButtonW, actionButtonH);
    _threeButtonMiddleFrame = CGRectMake(middleButtonX, buttonY, actionButtonW, actionButtonH);
    _threeButtonRightFrame = CGRectMake(rightButtonX, buttonY, actionButtonW, actionButtonH);
    return [self initWithFrame:CGRectMake(0, 0, width, height)];
}

- (instancetype)initForAdWebWithModel:(MainActionViewModel*)model frame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        _model = model;
        _mainButtonH = 60 *WIDTH_ADAPT - 10;
        self.closeButton = [[HangUpAdButton alloc] initWithFrame:self.bounds];
        [self.closeButton setTitle: @"关闭" forState:(UIControlStateNormal)];
        [self.closeButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        self.closeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        self.closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.closeButton setBackgroundImage:[TPDialerResourceManager  getImageByColorName:@"tp_color_black_transparency_500" withFrame:self.closeButton.bounds] forState:(UIControlStateNormal)];
        [self.closeButton setBackgroundImage:[TPDialerResourceManager  getImageByColorName:@"tp_color_black_transparency_600" withFrame:self.closeButton.bounds] forState:(UIControlStateHighlighted)];
        self.closeButton.pressBlock = _model.onHideButtonClick;

        [self addSubview:self.closeButton];
        
        HangUpAdButton *spitButton = [[HangUpAdButton alloc] initWithFrame:CGRectMake(-20, (self.bounds.size.height-24)/2,95, 24)];
        spitButton.layer.masksToBounds = YES;
        
        HangUpAdButton *nullbtn = [[HangUpAdButton alloc] initWithFrame:CGRectMake(0, 0, 65, 60)];
        nullbtn.backgroundColor = [UIColor clearColor];
        [self addSubview:nullbtn];
        [self addSubview:spitButton];
        [spitButton setTitle: @"   问题反馈" forState:(UIControlStateNormal)];

        [spitButton setTitleColor: [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"] forState:(UIControlStateNormal)];
        spitButton.layer.cornerRadius = 12;
        spitButton.layer.borderWidth = 1;
        spitButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"].CGColor;
        
        spitButton.titleLabel.font = [UIFont systemFontOfSize:12];
        spitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [spitButton setBackgroundImage:[TPDialerResourceManager  getImageByColorName:@"tp_color_black_transparency_0" withFrame:self.closeButton.bounds] forState:(UIControlStateNormal)];
        [spitButton setBackgroundImage:[TPDialerResourceManager  getImageByColorName:@"tp_color_black_transparency_300" withFrame:self.closeButton.bounds] forState:(UIControlStateHighlighted)];
        spitButton.pressBlock = _model.onSpitButtonClick;

        [_model addObserver:self forKeyPath:@"buttonState" options:0 context:NULL];
        [_model addObserver:self forKeyPath:@"spitGuideText" options:0 context:NULL];
        
        [self addMainButtonWithModel:model frame:frame];
    }
    return self;
}

-(void)addMainButtonWithModel:(MainActionViewModel *)model frame:(CGRect)frame{
    _borderTextColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_800"];
    if (_model.onMainButtonClick) {
        UIColor *blueColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        _mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mainButton.frame = CGRectMake(0, 0, ((TPScreenHeight() < 500 ? 60 : 65) * WIDTH_ADAPT) * 3 + 2 * 10 * WIDTH_ADAPT, _mainButtonH);
        UIColor *htColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        UIColor *normalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        if (_model.lightBg) {
            htColor = [TPDialerResourceManager getColorForStyle:@"outgoing_button_normal_color"];
            normalColor = [UIColor clearColor];
        }
        [_mainButton setBackgroundImage:[FunctionUtility imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [_mainButton addTarget:self action:@selector(onMainButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_mainButton setTitle:_model.mainButtonTitle forState:UIControlStateNormal];
        [_mainButton setTitleColor:_borderTextColor forState:UIControlStateNormal];
        
        _mainButton.layer.masksToBounds = YES;
        _mainButton.layer.cornerRadius = _mainButtonH/2;
        _mainButton.layer.borderColor = _borderTextColor.CGColor;
        _mainButton.layer.borderWidth = 1;
        _mainButton.titleLabel.font = [UIFont systemFontOfSize:17];
        if ([@[@"我要申诉",@"升级应用",@"一键修复"] containsObject:_model.mainButtonTitle]) {
            [_mainButton setTitleColor:blueColor forState:UIControlStateNormal];
            _mainButton.layer.borderColor = blueColor.CGColor;
        }
        _mainButton.center = CGPointMake(self.center.x, _mainButton.center.y);
    }
}

-(UIView *)getActionVieWithModel:(MainActionViewModel *)model frame:(CGRect)frame{
    HangupActionView *downView = [[HangupActionView alloc] initForAdWebWithModel:model frame:CGRectMake(0, frame.size.height-60, frame.size.width, 60)];
    UIView *bgClearView = [[UIView alloc] initWithFrame:frame];
    bgClearView.backgroundColor = [UIColor clearColor];
    [bgClearView addSubview:downView.mainButton];
    [bgClearView addSubview:downView];
    return bgClearView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _borderTextColor = [UIColor grayColor];
        if (!_model.lightBg) {
            _borderTextColor = [UIColor colorWithRed:COLOR_IN_256(0xBB) green:COLOR_IN_256(0xBB) blue:COLOR_IN_256(0xBB) alpha:1];
        }
        if (_model.onMainButtonClick) {
            UIColor *blueColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
            UIButton *mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
            mainButton.frame = CGRectMake(0, 0, frame.size.width, _mainButtonH);
            UIColor *htColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            UIColor *normalColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
            if (_model.lightBg) {
                htColor = [TPDialerResourceManager getColorForStyle:@"outgoing_button_normal_color"];
                normalColor = [UIColor clearColor];
            }

            [mainButton setBackgroundImage:[FunctionUtility imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [mainButton setBackgroundImage:[FunctionUtility imageWithColor:htColor] forState:UIControlStateHighlighted];

            [mainButton addTarget:self action:@selector(onMainButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [mainButton setTitle:_model.mainButtonTitle forState:UIControlStateNormal];
            [mainButton setTitleColor:normalColor forState:UIControlStateHighlighted];
            [mainButton setTitleColor:_borderTextColor forState:UIControlStateNormal];

            mainButton.layer.masksToBounds = YES;
            mainButton.layer.cornerRadius = _mainButtonH/2;
            mainButton.layer.borderColor = _borderTextColor.CGColor;
            mainButton.layer.borderWidth = 1;
            mainButton.titleLabel.font = [UIFont systemFontOfSize:17];
            if ([@[@"我要申诉",@"升级应用",@"一键修复"] containsObject:_model.mainButtonTitle]) {
                [mainButton setTitleColor:blueColor forState:UIControlStateNormal];
                mainButton.layer.borderColor = blueColor.CGColor;
            }
            [self addSubview:mainButton];
            _mainButton = mainButton;
        }
        [self addSpitButton];
        [self addRedialButton];
        [self addHideButton];
        if (_model.spitGuideText) {
            [self showFunctionGuide:_model.spitGuideText isRightGuide:YES];
        } else if (_model.redialGuideText) {
            [self showFunctionGuide:_model.redialGuideText isRightGuide:NO];
        }
        [_model addObserver:self forKeyPath:@"buttonState" options:0 context:NULL];
        [_model addObserver:self forKeyPath:@"spitGuideText" options:0 context:NULL];
    }
    return self;
}

- (void)onMainButtonPressed {
    if (_model.onMainButtonClick) {
        [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
        _model.onMainButtonClick();
    }
}

- (void)addSpitButton {
    VoipSimpleButton *spitButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonRightFrame];
    spitButton.fontIconText = @"X";
    spitButton.fontIconTextPressed = @"X";
    spitButton.persistPressed = NO;
    spitButton.bgHighlighColor = [TPDialerResourceManager getColorForStyle:@"outgoing_button_normal_color"];
    spitButton.borderColor = _borderTextColor;
    spitButton.fontIconHighlightColor = _borderTextColor;
    spitButton.pressBlock = _model.onSpitButtonClick;
    spitButton.text = @"吐槽";
    [self addSubview:spitButton];
}

- (void)addRedialButton {
    VoipSimpleButton *redialButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonLeftFrame];
    redialButton.fontIconText = @"T";
    redialButton.fontIconTextPressed = @"T";
    redialButton.text = NSLocalizedString(@"voip_redial", @"");
    redialButton.borderColor = _borderTextColor;
    redialButton.fontIconHighlightColor = _borderTextColor;
    redialButton.pressBlock  = _model.onRedialButtonClick;
    redialButton.bgHighlighColor = [TPDialerResourceManager getColorForStyle:@"outgoing_button_normal_color"];
    [self addSubview:redialButton];
}

- (void)addHideButton{
    VoipSimpleButton *hideButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonMiddleFrame];
    hideButton.persistPressed = NO;
    hideButton.fontIconText = @"F";
    hideButton.fontIconTextPressed = @"F";
    hideButton.bgHighlighColor = [TPDialerResourceManager getColorForStyle:@"outgoing_button_normal_color"];
    hideButton.fontIconHighlightColor = _borderTextColor;
    hideButton.text = @"关闭";
    hideButton.borderColor = _borderTextColor;
    hideButton.pressBlock = _model.onHideButtonClick;
    [self addSubview:hideButton];
}

- (void)showFunctionGuide:(NSString *)guideString isRightGuide:(BOOL)isRight{

    if (guideString.length==0) {
        return;
    }
    UIFont *font = [UIFont systemFontOfSize:16.0 * WIDTH_ADAPT];
    CGSize textSize = [guideString sizeWithFont:font];
    CGFloat width = _threeButtonRightFrame.origin.x-_threeButtonLeftFrame.origin.x + _threeButtonLeftFrame.size.width;
    CGFloat height = textSize.height + 30;
    CGFloat x = 0;
    CGFloat y = _threeButtonRightFrame.origin.y  - height-23;

    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, y, width, height+18)];
//    self.bubbleView = bgView;
    bgView.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, height)];
    label.text = guideString;
    label.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 6;
    [bgView addSubview:label];

    UIImage *image = [TPDialerResourceManager getImage:@"voip_compensation_02@2x.png"];

    UIImageView *triangleBlueView = [[UIImageView alloc] initWithFrame:CGRectMake(_threeButtonLeftFrame.origin.x+ actionButtonW/2-image.size.width/2, CGRectGetMaxY(label.frame)-1, image.size.width, image.size.height)];
    triangleBlueView.image = image;
    [bgView addSubview:triangleBlueView];
    [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(animationWithView:) userInfo:@{@"view":bgView} repeats:YES];
    [self addSubview:bgView];
}

-(void)animationWithView:(NSTimer *)timer{
    UIView *view = timer.userInfo[@"view"];
    [UIView animateWithDuration:0.6 animations:^{
        CGRect oldFrame = view.frame;
        oldFrame.origin.y = oldFrame.origin.y+10;
        view.frame = oldFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 animations:^{
            CGRect oldFrame = view.frame;
            oldFrame.origin.y = oldFrame.origin.y-10;
            view.frame = oldFrame;
        }];
    }];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"buttonState"]) {
        switch (_model.buttonState) {
            case LOADING:
                [self onMainButtonLoading];
                break;
            case LOADING_DONE:
                [self onMainButtonStopLoading:NO];
                break;
            case LOADING_DONE_HIDE:
                [self onMainButtonStopLoading:YES];
                break;
            default:
                break;
        }
    }
    if ([keyPath isEqual:@"spitGuideText"]) {
        if (_model.spitGuideText) {
            [self showFunctionGuide:_model.spitGuideText isRightGuide:YES];
        }
    }
}

- (void)onMainButtonLoading {
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    view.center = _mainButton.center;
    view.tag = 1;
    [self addSubview:view];
    [view startAnimating];
}

- (void)onMainButtonStopLoading:(BOOL)needHideButton{
    UIActivityIndicatorView * view = (UIActivityIndicatorView *)[self viewWithTag:1];
    [view stopAnimating];
    [view removeFromSuperview];
    if (needHideButton) {
        _mainButton.hidden = YES;
    }
}

- (void)dealloc {
    [_model removeObserver:self forKeyPath:@"buttonState"];
    [_model removeObserver:self forKeyPath:@"spitGuideText"];
}


@end
