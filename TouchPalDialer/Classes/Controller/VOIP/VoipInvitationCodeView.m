//
//  VoipInvitationCodeView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-14.
//
//[TODO:game3108]

#import "VoipInvitationCodeView.h"
#import "CustomInputTextFiled.h"
#import "TPDialerResourceManager.h"
#import "SeattleFeatureExecutor.h"
#import "DefaultUIAlertViewHandler.h"
#import "Reachability.h"
#import "TouchPalDialerAppDelegate.h"
#import "EditVoipViewController.h"
#import "CootekNotifications.h"



@interface VoipInvitationCodeView() <UITextFieldDelegate> {
    UIView *_boardView;
    UILabel *_alertLabel;
    CustomInputTextFiled *_inputField;
    UIButton *_textFiledButton;
    
    BOOL onTouchMove;
    BOOL keyBoardMove;
    UIActivityIndicatorView *_indicator;
    
    UIView *_middleLine;
}
@end

@implementation VoipInvitationCodeView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _boardView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 200)];
        _boardView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_boardView];
        float globalY = 24;
        _inputField = [[CustomInputTextFiled alloc] initWithFrame:CGRectMake( 16, globalY, frame.size.width - 32, VOIP_LINE_HEIGHT)
                                                   andPlaceHolder:NSLocalizedString(@"voip_input_your_invitation_code", "")
                                                           andID:[TPDialerResourceManager getImage:@"voip_invitation_button_normal@2x.png"]];
        _inputField.keyboardType = UIKeyboardTypeNumberPad;
        [_boardView addSubview:_inputField];
        _inputField.delegate = self;
        _middleLine = _inputField.middleLine;
        [_inputField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
//        [_inputField addTarget:self action:@selector(judgeInvitationCode) forControlEvents:UIControlEventEditingDidEnd];
        
        _textFiledButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _textFiledButton.frame = CGRectMake( 0 , 0 , 72, _inputField.frame.size.height);
        [_textFiledButton setBackgroundImage:[TPDialerResourceManager getImage:@"voip_invitation_button_normal@2x.png"] forState:UIControlStateNormal];
        [_textFiledButton setBackgroundImage:[TPDialerResourceManager getImage:@"voip_invitation_button_disable@2x.png"] forState:UIControlStateDisabled];
        _textFiledButton.enabled = NO;
        _inputField.rightViewMode = UITextFieldViewModeAlways;
        _inputField.rightView = _textFiledButton;
        [_textFiledButton addTarget:self action:@selector(useInvitationCode) forControlEvents:UIControlEventTouchUpInside];
        
        globalY += _inputField.frame.size.height;
        _alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, 48)];
        _alertLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        _alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_alert_view_text_color"];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        [_boardView addSubview:_alertLabel];
        
        globalY += _alertLabel.frame.size.height;
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(16, globalY-1, frame.size.width-32, 1)];
        bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_line_color"];
        [_boardView addSubview:bottomLine];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, globalY, frame.size.width, VOIP_CELL_HEIGHT)];
        [cancelButton setTitle: NSLocalizedString(@"voip_close", "") forState:UIControlStateNormal];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_cancellbutton_normal_color"] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_1_5];
        [cancelButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareview_cancel_button_normal_image"] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareview_cancel_button_hl_image"] forState:UIControlEventTouchUpInside];
        [_boardView addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(removeInvitationCodeView) forControlEvents:UIControlEventTouchUpInside];
        
        [self showInAnimation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)setUseOldInterface:(BOOL)useOldInterface {
    if (useOldInterface) {
        _inputField.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    _useOldInterface = useOldInterface;
}

//- (void)judgeInvitationCode{
//    if ( _inputField.text.length != 10 && _inputField.text.length > 0){
//        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_input_invitation_code_length_error","") message:nil];
//    }
//}

- (void)textFieldDidChange{
    if (_inputField.text.length > 0){
        _textFiledButton.enabled = YES;
    }else{
        _textFiledButton.enabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    int MAX_CHARS = 30;
    
    NSMutableString *newtxt = [NSMutableString stringWithString:_inputField.text];
    [newtxt replaceCharactersInRange:range withString:string];
    
    if (newtxt.length > MAX_CHARS){
         _inputField.text = [newtxt substringToIndex:MAX_CHARS];
        return NO;
    }
    
    return YES;
}

- (void)useInvitationCode{
    if ([_inputField isFirstResponder]) {
        [_inputField resignFirstResponder];
    }
    if (_inputField.text.length > 30) {
        _inputField.text = [_inputField.text substringToIndex:30];
    }
    
    if ( [Reachability network] < network_2g){
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_network_no_error", "") message:nil];
    }else{
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, _textFiledButton.frame.size.height, _textFiledButton.frame.size.height)];
        [_indicator setCenter:CGPointMake(_textFiledButton.frame.size.width/2, _textFiledButton.frame.size.height/2)];
        [_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = YES;
        [_indicator startAnimating];
        [_textFiledButton addSubview:_indicator];
        _textFiledButton.enabled = NO;
        [self startSendInvitationCode];
    }
}

- (void) startSendInvitationCode{
    if (_useOldInterface) {
        [self useTheOldInterface];
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        int resultCode = [SeattleFeatureExecutor useInvitationCode:[[_inputField text] uppercaseString]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *msg = nil;
            _alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_alert_view_text_color"];
            switch (resultCode) {
                case 2000:
                {
                    _alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_alert_view_ok_text_color"];
                    msg = @"你已经成功兑换";
                    dispatch_async([SeattleFeatureExecutor getQueue], ^{
                        [SeattleFeatureExecutor queryVOIPAccountInfo];
                        [SeattleFeatureExecutor getAccountNumbersInfo];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_PERSONAL_INFO object:nil];
                        });
                    });
                    break;
                }
                case REDEEM_ISSUE_FAILED:
                {
                    msg = @"你已经使用过同类兑换码了";
                    break;
                }
                case REDEEM_EXCHANGED:
                {
                    msg = @"该兑换码已经使用过了";
                    break;
                }
                case REDEEM_EXPIRED:
                {
                    msg = @"该兑换码已经过期了";
                    break;
                }
                case REDEEM_NOT_EXIST:
                {
                    msg = @"该兑换码不存在";
                    break;
                }
                case 0:
                {
                    msg = NSLocalizedString(@"voip_network_register_error_and_retry","");
                }
                default:
                    msg = @"服务器凌乱了";
                    break;
            }
            _alertLabel.text = msg;
            [_indicator stopAnimating];
            if (_inputField.text.length>0) {
                _textFiledButton.enabled = YES;
            }
        });
    });
}


- (void) useTheOldInterface{
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSArray *resultArray = [SeattleFeatureExecutor useInvitationCodeOldInterface:[[_inputField text] uppercaseString]];
        int resultCode = [[resultArray objectAtIndex:0] intValue];
        NSString *msg = [resultArray objectAtIndex:2];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (resultCode == 2000){
                _alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_alert_view_ok_text_color"];
            }else{
                _alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_alert_view_text_color"];
            }
            if (resultCode == -1){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_network_register_error_and_retry","") message:nil];
            }
            _alertLabel.text = msg;
            [_indicator stopAnimating];
            if (_inputField.text.length>0)
                _textFiledButton.enabled = YES;
        });
    });
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    if ([_inputField isFirstResponder])
        [_inputField resignFirstResponder];
    if (!keyBoardMove){
        if (point.y < TPScreenHeight() - _boardView.frame.size.height && !onTouchMove){
            [self removeInvitationCodeView];
        }else{
            onTouchMove = NO;
        }
    }else{
        keyBoardMove = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    onTouchMove = YES;
}


- (void) removeInvitationCodeView {
    [self showOutAnimation];
}

- (void) showInAnimation{
    CGRect oldFrame = _boardView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() , oldFrame.size.width,  oldFrame.size.height);
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() - oldFrame.size.height - (20 - TPHeaderBarHeightDiff()) , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }
                     completion:nil];
}

- (void) showOutAnimation {
    CGRect oldFrame = _boardView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight()-oldFrame.size.height - (20 - TPHeaderBarHeightDiff()), oldFrame.size.width,  oldFrame.size.height);
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
                     }
                     completion:^(BOOL finish){
                         if (finish)
                             [self removeFromSuperview];
                     }];
}

#pragma mark keyboardShownObserverSelecter


- (void) keyboardWillBeShown:(NSNotification *) notification
{
    if ([_inputField isFirstResponder]){
        keyBoardMove = YES;
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if (kbSize.height <= 0)
            return;
        CGRect oldFrame = _boardView.frame;
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        CGFloat animationDuration = 0.0f;
        animationDuration = [animationDurationNumber floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight()-oldFrame.size.height-kbSize.height + 120, oldFrame.size.width,  oldFrame.size.height);
        }];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *) notification
{
    if ([_inputField isFirstResponder]){
        keyBoardMove = YES;
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if (kbSize.height <= 0){
            return;
        }
        CGRect oldFrame = _boardView.frame;
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        CGFloat animationDuration = 0.0f;
        animationDuration = [animationDurationNumber floatValue];
        [UIView animateWithDuration:animationDuration animations:^{
            _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight()-oldFrame.size.height , oldFrame.size.width,  oldFrame.size.height);
        }];
    }
}

#pragma mark UITextFieldDelegate

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    _inputField.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_first_responder_color"].CGColor;
//    _inputField.layer.borderWidth = 1.0f;
//    _middleLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_first_responder_color"];
//    _middleLine.frame = CGRectMake(_middleLine.frame.origin.x, _middleLine.frame.origin.y, 1, _middleLine.frame.size.height);
//}
//
//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//    _inputField.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_border_color"].CGColor;
//    _inputField.layer.borderWidth = 0.5f;
//    _middleLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_border_color"];
//    _middleLine.frame = CGRectMake(_middleLine.frame.origin.x, _middleLine.frame.origin.y, 0.5, _middleLine.frame.size.height);
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
