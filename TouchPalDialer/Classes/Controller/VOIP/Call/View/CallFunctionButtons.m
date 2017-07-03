//
//  CallFunctionButtons.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/15.
//
//

#import "CallFunctionButtons.h"
#import "VoipSimpleButton.h"
#import "VoipConsts.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "CommonCoverGuide.h"
#import "DefaultUIAlertViewHandler.h"
#import "VoipShareAllView.h"
#import <AVFoundation/AVAudioSession.h>

typedef enum {
    Hangup = 1,
    Close,
    Hidden,
}HangupButtonStyle;

@interface CallFunctionButtons() {
    CallFunctionButtonsType _currentType;
    __strong VoipSimpleButton *_backCallButton;
    __strong VoipSimpleButton *_speakerButton;
    __strong VoipSimpleButton *_muteButton;
    __strong VoipSimpleButton *_shareButton;
    __strong VoipSimpleButton *_hideButton;
    __strong UIButton *_hangupButton;
    __weak UIButton *_closeButton;
    __strong UIButton *_acceptButton;
    __strong UIButton *_keyboardButton;
    __weak id<CallFunctionButtonDelegate>_delegate;
    __weak UIView *_hostView;
    __weak UIView *_backCallGuide;
    UIView *_firstLineView;
    CGRect _twoButtonLeftFrame;
    CGRect _twoButtonRightFrame;
    CGRect _threeButtonLeftFrame;
    CGRect _threeButtonMiddleFrame;
    CGRect _threeButtonRightFrame;
    CGRect _hangupButtonFrame;
    CGSize _viewSize;
}
@end

@implementation CallFunctionButtons

- (id)initWithHostView:(UIView *)hostView andDelegate:(id<CallFunctionButtonDelegate>)delegate{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _delegate = delegate;
        _hostView = hostView;
        float scaleRatio = WIDTH_ADAPT;
        float actionButtonW = (TPScreenHeight() < 500 ? 60 : 65) * scaleRatio;
        float actionButtonH = actionButtonW + (TPScreenHeight() < 500 ? 20 : 30)*scaleRatio;
        float buttonGap = 10 * scaleRatio;
        float buttonGapV = 10 *scaleRatio;
        
        _firstLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), actionButtonH)];
        [self addSubview:_firstLineView];
        float functionButtonY = 0;
        
        buttonGap = 20*scaleRatio;
        //for three button frame
        float leftButtonX = (TPScreenWidth() - (2*buttonGap + 3*actionButtonW))/2;
        float rightButtonX = TPScreenWidth() - leftButtonX - actionButtonW;
        float middleButtonX = leftButtonX + actionButtonW + buttonGap;
        _threeButtonLeftFrame = CGRectMake(leftButtonX, functionButtonY, actionButtonW, actionButtonH);
        _threeButtonMiddleFrame = CGRectMake(middleButtonX, functionButtonY, actionButtonW, actionButtonH);
        _threeButtonRightFrame = CGRectMake(rightButtonX, functionButtonY, actionButtonW, actionButtonH);
        
        functionButtonY = functionButtonY + actionButtonH + buttonGapV;
        //for two button frame
        buttonGap = 100*scaleRatio;
        leftButtonX = (TPScreenWidth() - 2 * actionButtonW - buttonGap)/2;
        rightButtonX = leftButtonX + actionButtonW + buttonGap;
        _twoButtonLeftFrame = CGRectMake(leftButtonX, functionButtonY, actionButtonW, actionButtonH);
        _twoButtonRightFrame = CGRectMake(rightButtonX, functionButtonY, actionButtonW, actionButtonH);
        
        _keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _keyboardButton.frame = CGRectMake(_threeButtonLeftFrame.origin.x, functionButtonY, actionButtonW, actionButtonW);
        _keyboardButton.layer.masksToBounds = YES;
        [_keyboardButton setImage:[TPDialerResourceManager getImage:@"voip_key_hide@2x.png"] forState:UIControlStateNormal];
        [_keyboardButton setImage:[TPDialerResourceManager getImage:@"voip_key_show@2x.png"] forState:UIControlStateSelected];
        [_keyboardButton addTarget:self action:@selector(onKeyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_keyboardButton];
        
        UIButton *hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        hangupButton.frame = CGRectMake(_threeButtonMiddleFrame.origin.x, functionButtonY, actionButtonW, actionButtonW);
        hangupButton.layer.cornerRadius = actionButtonW/2;
        hangupButton.layer.masksToBounds = YES;
        UIColor *color = [UIColor colorWithRed:COLOR_IN_256(0xfd) green:COLOR_IN_256(0x49) blue:COLOR_IN_256(0x5b) alpha:1];
        [hangupButton setBackgroundImage:[FunctionUtility imageWithColor:color] forState:UIControlStateNormal];
        color = [UIColor colorWithRed:COLOR_IN_256(0xca) green:COLOR_IN_256(0x3a) blue:COLOR_IN_256(0x49) alpha:1];
        [hangupButton setBackgroundImage:[FunctionUtility imageWithColor:color] forState:UIControlStateHighlighted];
        color = [UIColor blackColor];
        [hangupButton setBackgroundImage:[FunctionUtility imageWithColor:color] forState:UIControlStateDisabled];
        hangupButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:34];
        [hangupButton setTitle:@"R" forState:UIControlStateNormal];
        [hangupButton addTarget:_delegate action:@selector(onHangupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hangupButton];
        _hangupButton = hangupButton;
        _hangupButtonFrame = hangupButton.frame;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(_threeButtonRightFrame.origin.x, functionButtonY, actionButtonW, actionButtonW);
        closeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateHighlighted];
        [closeButton addTarget:_delegate action:@selector(onCloseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        _closeButton = closeButton;
        _closeButton.hidden = YES;
        
        _viewSize = CGSizeMake(TPScreenWidth(), buttonGapV + actionButtonH + actionButtonH);
        [_hostView addSubview:self];
    }
    return self;
}

- (CGSize)size {
    return _viewSize;
}

- (void)createMuteButton {
    VoipSimpleButton *muteButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonLeftFrame];
    muteButton.fontIconText = @"2";
    muteButton.fontIconTextPressed = @"3";
    __weak id<CallFunctionButtonDelegate> delegate = _delegate;
    muteButton.pressBlock = ^{
        [delegate onMuteButtonPressed];
    };
    muteButton.persistPressed = YES;
    muteButton.text = NSLocalizedString(@"voip_outgoing_mute", @"");
    [_firstLineView addSubview:muteButton];
    _muteButton = muteButton;
}

- (void)createSpeakerButton {
    VoipSimpleButton *speakerButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonRightFrame];
    speakerButton.fontIconText = @"4";
    speakerButton.fontIconTextPressed = @"5";
    speakerButton.text = NSLocalizedString(@"voip_outgoing_speaker", @"");
    speakerButton.persistPressed = YES;
    __weak id<CallFunctionButtonDelegate> delegate = _delegate;
    speakerButton.pressBlock = ^ {
        [delegate onSpeakerButtonPressed];
    };
    [_firstLineView addSubview:speakerButton];
    _speakerButton = speakerButton;
}

- (void)createShareButton {
    _shareButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonMiddleFrame];
    _shareButton.fontIconText = @"b";
    _shareButton.fontIconTextPressed = @"S";
    _shareButton.text = NSLocalizedString(@"voip_share", @"");
    __weak id<CallFunctionButtonDelegate> delegate = _delegate;
    __weak CallFunctionButtons *bself = self;
    _shareButton.pressBlock = ^ {
        [bself shareByTimeline];
        [delegate onShareButtonPressed];
    };
    [_firstLineView addSubview:_shareButton];
}

- (void)createHideButton {
    _hideButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonRightFrame];
    _hideButton.persistPressed = NO;
    _hideButton.fontIconText = @"F";
    _hideButton.fontIconTextPressed = @"F";
    _hideButton.text = NSLocalizedString(@"voip_hide", @"");
    __weak id<CallFunctionButtonDelegate> delegate = _delegate;
    _hideButton.pressBlock = ^ {
        [delegate onCloseButtonPressed];
    };
}

- (void)createBackCallButton{
    VoipSimpleButton *redialButton = [[VoipSimpleButton alloc] initWithFrame:_threeButtonLeftFrame];
    redialButton.persistPressed = NO;
    redialButton.fontIconText = @"V";
    redialButton.fontIconTextPressed = @"W";
    __weak id<CallFunctionButtonDelegate> delegate = _delegate;
    redialButton.pressBlock = ^{
        [delegate onBackCallButtonPressed];
    };
    redialButton.text = @"回拨";
    [_firstLineView addSubview:redialButton];
    _backCallButton = redialButton;
}

- (void)createAcceptButton {
    UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptButton.frame = CGRectMake(_twoButtonRightFrame.origin.x, _twoButtonRightFrame.origin.y, _twoButtonRightFrame.size.width, _twoButtonRightFrame.size.width);
    acceptButton.layer.cornerRadius = _twoButtonRightFrame.size.width/2;
    acceptButton.layer.masksToBounds = YES;
    UIColor *color = [UIColor colorWithRed:COLOR_IN_256(0x37) green:COLOR_IN_256(0xc7) blue:COLOR_IN_256(0x63) alpha:1];
    [acceptButton setBackgroundImage:[FunctionUtility imageWithColor:color] forState:UIControlStateNormal];
    color = [UIColor colorWithRed:COLOR_IN_256(0x2c) green:COLOR_IN_256(0x9f) blue:COLOR_IN_256(0x4f) alpha:1];
    [acceptButton setBackgroundImage:[FunctionUtility imageWithColor:color] forState:UIControlStateHighlighted];
    color = [UIColor blackColor];
    acceptButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:34];
    [acceptButton setTitle:@"D" forState:UIControlStateNormal];
    [acceptButton addTarget:self action:@selector(onAcceptButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:acceptButton];
    _acceptButton = acceptButton;
}



- (void)showBackCallStyle{
    if (_shareButton) {
        _shareButton.hidden = NO;
    } else {
        [self createShareButton];
    }
    _shareButton.frame = _twoButtonLeftFrame;
    [self addSubview:_shareButton];
    if (_hideButton) {
        _hideButton.hidden = NO;
    } else {
        [self createHideButton];
    }
    _hideButton.frame = _twoButtonRightFrame;
    [self addSubview:_hideButton];
}


- (void)displayBackMuteSpeaker:(BOOL)ifTest{
    if (!_backCallButton) {
//        [self createBackCallButton];
    }
    _backCallButton.hidden = NO;
    if (!_muteButton) {
        [self createMuteButton];
    }
    _muteButton.hidden = NO;
    if (!_speakerButton) {
        [self createSpeakerButton];
    }
    _speakerButton.hidden = NO;
    if (![UserDefaultsManager boolValueForKey:VOIP_BACK_CALL_ENABLE]) {
        _backCallButton.alpha = 0.3;
        _backCallButton.userInteractionEnabled = NO;
    }
    if(ifTest){
        [_speakerButton setPressed:YES];
        _backCallButton.userInteractionEnabled = NO;
        _shareButton.userInteractionEnabled = NO;
    }
}

- (void)displayAcceptAndHangupButton {
    if (_hangupButton.hidden) {
        _hangupButton.hidden = NO;
    }
    _hangupButton.frame = CGRectMake(_twoButtonLeftFrame.origin.x, _twoButtonLeftFrame.origin.y, _twoButtonLeftFrame.size.width, _twoButtonLeftFrame.size.width);
    if (_acceptButton) {
        _acceptButton.hidden = NO;
    } else {
        [self createAcceptButton];
    }
    _acceptButton.frame = CGRectMake(_twoButtonRightFrame.origin.x, _twoButtonRightFrame.origin.y, _twoButtonRightFrame.size.width, _twoButtonRightFrame.size.width);
}

- (void) shareByTimeline
{
    VoipShareAllView *view = [[VoipShareAllView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    view.fromWhere = @"VoipCall";
    [_hostView addSubview:view];
}

- (void)onAcceptButtonPressed {
    [UIView animateWithDuration:0.5 animations:^{
        _hangupButton.frame = _hangupButtonFrame;
    }];
    [_acceptButton removeFromSuperview];
    [_delegate onAccpetButtonPressed];
}


- (void)setType:(CallFunctionButtonsType)type {
    if (_currentType == type) {
        return;
    }
    _currentType = type;
    [self hideAllButton];
    switch (type) {
        case Calling:
            [self displayBackMuteSpeaker:NO];
            break;
        case BackCalling: {
            [self showBackCallStyle];
            _hangupButton.hidden = YES;
            _keyboardButton.hidden = YES;
            break;
        }
        case Test:
            [self displayBackMuteSpeaker:YES];
            break;
        case Connected:
            break;
        case Incoming:
            [self displayAcceptAndHangupButton];
            _keyboardButton.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)disableKeybardButton {
    _keyboardButton.enabled = NO;
    _keyboardButton.alpha = 0.3;
}

- (void)disableHangupButton {
    _hangupButton.enabled = NO;
    _hangupButton.alpha = 0.3;
}

- (void)hideAllButton {
    _muteButton.hidden = YES;
    _speakerButton.hidden = YES;
    _backCallButton.hidden = YES;
    _shareButton.hidden = YES;
    _hideButton.hidden = YES;
    
    _speakerButton.userInteractionEnabled = YES;
    _backCallButton.userInteractionEnabled = YES;
    _shareButton.userInteractionEnabled = YES;
}

- (void)hideFirstLineFunctionButtons {
    [UIView animateWithDuration:0.2 animations:^{
        _firstLineView.alpha = 0;
    }];
}

- (void)showFirstLineFunctionButtons {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        _firstLineView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)onKeyButtonPressed {
    _keyboardButton.selected = !_keyboardButton.selected;
    [_delegate onKeyButtonPressed];
}




@end
