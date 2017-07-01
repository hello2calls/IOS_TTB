//
//  NotVerifyWithoutCodeViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 14-10-24.
//
//

#import "CommonLoginViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "CustomInputTextFiled.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "Reachability.h"
#import "DefaultUIAlertViewHandler.h"
#import "TimerTickerManager.h"
#import "SeattleFeatureExecutor.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "UserDefaultsManager.h"
#import "CustomUILabel.h"
#import "PushConstant.h"
#import "XinGePushManager.h"
#import "YellowPageMainQueue.h"
#import "NoahManager.h"
#import "TPFilterRecorder.h"
#import "AllViewController.h"
@interface CommnonLoginViewController () <TimerTickerDelegate, UITextFieldDelegate> {
    CustomInputTextFiled *_areaFiled;
    CustomInputTextFiled *_numberFiled;
    CustomInputTextFiled *_verifiFiled;
    UILabel *_indicatorLabel;
    UIButton *_verifyButton;
    UIActivityIndicatorView *_daisy;
    UIButton *_submitButton;
    UILabel *_smsButton;
    UIButton *_clearButton;
    UIButton *_fakeClearButton;
    UILabel *_secondCountLabel;
    NSString *_defaultNumberString;
    TPHeaderButton *_backBtn;
    BOOL _successInput;
    int getAuthcodeCount;
    NSString *_lastInputNumber;
    NSString *_lastInputCode;
}
@property (nonatomic, copy)void (^netBlock)(void);
@property (nonatomic, copy)void (^uiBlock)(void);
@property (nonatomic, copy)void (^failedNetBlock)(void);
@property (nonatomic, copy)void (^failedUIBlock)(void);
@property (nonatomic, retain)NSString *infoText;
@property (nonatomic, retain)NSDictionary *preInfo;
@end


@implementation CommnonLoginViewController

+ (CommnonLoginViewController *)loginWithPreInfo:(NSDictionary *)info successNetBlock:(void (^)(void))netBlock successUIBlock:(void (^)(void))uiBlock {
    CommnonLoginViewController *controller = [[CommnonLoginViewController alloc] init];
    controller.netBlock = netBlock;
    controller.uiBlock = uiBlock;
    controller.preInfo = info;
    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
    return controller;
}

+ (CommnonLoginViewController *)loginWithPreInfo:(NSDictionary *)info successNetBlock:(void (^)(void))netBlock successUIBlock:(void (^)(void))uiBlock failedNetBlock:(void(^)(void))failedNetBlock failedUIBlock:(void(^)(void))failedUIBlock {
    
    CommnonLoginViewController *controller = [[CommnonLoginViewController alloc] init];
    controller.netBlock = netBlock;
    controller.uiBlock = uiBlock;
    controller.failedNetBlock = failedNetBlock;
    controller.failedUIBlock = failedUIBlock;
    controller.preInfo = info;
    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getBackGroundView].backgroundColor = [UIColor whiteColor];
    
    CGRect headerFrame = CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight());
    CommonHeaderBar *headerBar = [[CommonHeaderBar alloc] initWithFrame:headerFrame andHeaderTitle:@"绑定手机号"];
    headerBar.delegate = self;
    [self.view addSubview:headerBar];
    
    CGFloat y = TPHeaderBarHeight();
    CGFloat x = 15;
    CGFloat h = 56;
    CGFloat w = TPScreenWidth() - 2 * x;
    
    if (_preInfo && [_preInfo objectForKey:@"text"]) {
        self.infoText = [_preInfo objectForKey:@"text"];
    } else {
        self.infoText = @"为保证去电显示本机号码，需验证手机号";
    }
    CGFloat textHeight = [_infoText sizeWithFont:[UIFont systemFontOfSize:14]].height;
    _indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + (46-textHeight)/2, w - 20, textHeight)];
    _indicatorLabel.font = [UIFont systemFontOfSize:14];
    _indicatorLabel.text = _infoText;
    _indicatorLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_indicatorLabel];
    y+=46;
    
    
    _areaFiled = [[CustomInputTextFiled alloc] initWithFrame:CGRectMake(x, y, 80, h) andPlaceHolder:@"+234" andID:nil];
    _areaFiled.layer.cornerRadius = 4;
    _areaFiled.layer.masksToBounds = YES;
    _areaFiled.keyboardType = UIKeyboardTypeNumberPad;
    _areaFiled.enabled = NO;
    [self.view addSubview:_areaFiled];
    
    _numberFiled = [[CustomInputTextFiled alloc] initWithFrame:CGRectMake(x+90, y, w-90, h) andPlaceHolder:@"请填写手机号" andID:nil];
    _numberFiled.layer.cornerRadius = 4;
    _numberFiled.layer.masksToBounds = YES;
    _numberFiled.keyboardType = UIKeyboardTypeNumberPad;
    _numberFiled.delegate = self;
    if ( _defaultNumberString != nil ){
        _numberFiled.text = _defaultNumberString;
    }
    [self.view addSubview:_numberFiled];
    [_numberFiled becomeFirstResponder];
    UIImage *image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"login_clear@2x.png"];
    UIImage *image_ht = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"login_clear_ht@2x.png"];
    _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _clearButton.frame = CGRectMake(x + w - image.size.width - 20, y + (h - image.size.height)/2, image.size.width, image.size.height);
    [_clearButton setBackgroundImage:image forState:UIControlStateNormal];
    [_clearButton setBackgroundImage:image_ht forState:UIControlStateHighlighted];
    [_clearButton addTarget:self action:@selector(clearInput) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_clearButton];
    _clearButton.hidden = YES;
    _fakeClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fakeClearButton.frame = CGRectMake(x + w - image.size.width - 40, y, image.size.width + 40, h);
    [_fakeClearButton setBackgroundColor:[UIColor clearColor]];
    [_fakeClearButton addTarget:self action:@selector(clearInput) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fakeClearButton];
    _fakeClearButton.hidden = YES;
    y += h;
    y += 15;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *buttonText = @"获取验证码";
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 4.0f;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:17];
    button.frame = CGRectMake(x + w - 120, y, 120, h);
    [button setTitle:buttonText forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"login_askcode_button_color"]] forState:UIControlStateNormal];
    [button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"login_askcode_button_ht_color"]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"login_askcode_button_disable_color"]] forState:UIControlStateDisabled];
    button.enabled = NO;
    if ([self checkNumberHard:_defaultNumberString]){
        button.enabled = YES;
    }
    [button addTarget:self action:@selector(onSMSButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _verifyButton = button;
    
    _secondCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + w - 120, y, 120, h)];
    _secondCountLabel.layer.masksToBounds = YES;
    _secondCountLabel.layer.cornerRadius = 4.0f;
    _secondCountLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"login_askcode_button_disable_color"];
    _secondCountLabel.textColor = [UIColor whiteColor];
    _secondCountLabel.textAlignment = NSTextAlignmentCenter;
    _secondCountLabel.hidden = YES;
    [self.view addSubview:_secondCountLabel];
    
    _verifiFiled = [[CustomInputTextFiled alloc] initWithFrame:CGRectMake(x, y, w-130, h) andPlaceHolder:@"" andID:nil];
    _verifiFiled.keyboardType = UIKeyboardTypeNumberPad;
    _verifiFiled.layer.cornerRadius = 4;
    _verifiFiled.layer.masksToBounds = YES;
    _verifiFiled.delegate = self;
    [self.view addSubview:_verifiFiled];
    
    y+=h;
    y+=15;
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.layer.cornerRadius = 4;
    submit.layer.masksToBounds = YES;
    submit.frame = CGRectMake(x, y, w, h);
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [submit setTitleColor:[TPDialerResourceManager getColorForStyle:@"login_submit_button_title_normal_color"] forState:UIControlStateNormal];
    [submit setTitleColor:[TPDialerResourceManager getColorForStyle:@"login_submit_button_title_disable_color"] forState:UIControlStateDisabled];
    [submit setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_submit_button_color"]] forState:UIControlStateNormal];
    [submit setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_submit_button_ht_color"]] forState:UIControlStateHighlighted];
    [submit setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_submit_button_disable_color"]] forState:UIControlStateDisabled];
    [submit addTarget:self action:@selector(onSubmitPressed) forControlEvents:UIControlEventTouchUpInside];
    submit.enabled = NO;
    [self.view addSubview:submit];
    _submitButton = submit;
    y = y + h + 35;
    NSMutableAttributedString *smsText = [[NSMutableAttributedString alloc] initWithString:@"尝试语音验证"];
    [smsText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, smsText.length)];
    CustomUILabel *label = [[CustomUILabel alloc] initWithFrame:CGRectMake(x, y, w, 30)];
    label.attributedText = smsText;
    label.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_askcode_video_color"];
    label.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_askcode_video_ht_color"];
    __weak CommnonLoginViewController *bSelf = self;
    label.pressBlock = ^ {
        [bSelf askVoiceVerifyCode];
    };
    label.disableColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_askcode_video_ht_color"];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    _smsButton = label;
    _smsButton.userInteractionEnabled = NO;
    _smsButton.hidden = YES;
    
    if ([TimerTickerManager getTimerTicker:self] > 0){
        [TimerTickerManager setDelegate:self];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FunctionUtility updateStatusBarStyle];
}

- (void)setRegisterNumber:(NSString*)number{
    _defaultNumberString = [number copy];
}

- (void)clearInput {
    _numberFiled.text = @"";
    _clearButton.hidden = YES;
    _fakeClearButton.hidden = YES;
    _verifyButton.enabled = NO;
    [self changeIndicatorText:_infoText isError:NO];
}

- (void)askVoiceVerifyCode {
    if (![self checkNumberHard:[_numberFiled text]]) {
        [self notifyVerifyResult:4102 type:@"voice"];
        return;
    }
    if ([self uiChangesOnAskCode]) {
        [self startVoiceVerification];
    }
}

- (void)startVoiceVerification{
    [self recordForKey:CENTER_CLICK_VOICE_AUTHCODE ForValue:@"1"];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSInteger resultCode = [SeattleFeatureExecutor askVerifyCode:[_numberFiled text] isVoiceType:YES];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self notifyVerifyResult:resultCode type:@"voice"];
            [self recordForKey:CENTER_VOICE_AUTHCODE_RESULT ForValue:[NSString stringWithFormat:@"%d", resultCode]];
        });
    });
    cootek_log(@"start voice verification");
    [DialerUsageRecord recordpath:EV_VOIP_VERIFY_SEND kvs:Pair(@"type", @"voice"), nil];
}

- (void)notifyVerifyResult:(int)resultCode type:(NSString *)type{
    _successInput = NO;
    if (resultCode == 0) {
        [self changeIndicatorText:NSLocalizedString(@"voip_network_verify_error_and_retry", "") isError:YES];
    } else if (resultCode == 2000) {
        NSString *text = @"您将收到一通语音验证的电话";
        if ([type isEqualToString:@"sms"]) {
            text = @"您将收到一条带有验证码的短信";
        }
        [self changeIndicatorText:text isError:NO];
        cootek_log(@"verify success by action:%@", type);
        [DialerUsageRecord recordpath:EV_VOIP_VERIFY_SUCCESS kvs:Pair(@"type", type), nil];
        _successInput = YES;
    } else if (resultCode == 4102) {
        [self changeIndicatorText:NSLocalizedString(@"voip_network_verify_phone_number_error", "") isError:YES];
    } else {
        [self changeIndicatorText:[NSString stringWithFormat:NSLocalizedString(@"voip_network_verify_fail", ""), resultCode] isError:YES];
    }
    
    if (resultCode != 2000) {
        [TimerTickerManager setTimerTickerDownStop:self];
    }
}


- (void)changeIndicatorText:(NSString *)text isError:(BOOL)isError {
    _indicatorLabel.text = text;
    if (isError) {
        _indicatorLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"login_label_error_color"];
    } else {
        _indicatorLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark StaticSendVerificationDelegate
-(void) onTimerStop{
    if([self checkNumber:_numberFiled.text] && [TimerTickerManager getTimerTicker:self]<=0){
        _verifyButton.enabled = YES;
        _smsButton.userInteractionEnabled = YES;
    }
    [_verifyButton setTitle:@"重新获取" forState:UIControlStateNormal];
    _verifyButton.hidden = NO;
    _smsButton.hidden = NO;
    _secondCountLabel.hidden = YES;
}

-(void) onTimerTicker:(NSInteger) ticker{
    NSString *string = [NSString stringWithFormat:@"%d秒",ticker];
    _secondCountLabel.text = string;
    _verifyButton.enabled = NO;
    _verifyButton.hidden = YES;
    _secondCountLabel.hidden = NO;
}

- (BOOL)checkNumber:(NSString *)num
{
    if ([self isPureInt:num] && num.length >= 10) {
        return YES;
    }
    return NO;
}

- (BOOL)checkNumberHard:(NSString *)num {
    if(num.length == 10)
    {
        NSRange range = NSMakeRange(0, 1);
        NSString *checkA  = [num substringWithRange:range];
        if([checkA isEqualToString:@"7"] || [checkA isEqualToString:@"8"] || [checkA isEqualToString:@"9"])
        {
            return YES;
        }
    }
    if(num.length == 11){
        NSRange range = NSMakeRange(0, 2);
        NSString *checkB  = [num substringWithRange:range];
        if([checkB isEqualToString:@"07"] || [checkB isEqualToString:@"08"] || [checkB isEqualToString:@"09"])
        {
            return YES;
        }
    }
    return NO;
}

- (void)onSMSButtonPressed {
    [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_CLICK_TO_GET_VERIFY_CODE, @(1)), nil];
    [self checkInputNumber];
    if (![self checkNumberHard:[_numberFiled text]]) {
        [self notifyVerifyResult:4102 type:@"sms"];
        return;
    }
    if ([self uiChangesOnAskCode]) {
        _verifiFiled.placeholder = @"请填写验证码";
        [self startSMSVerification];
    }
}
- (void)checkInputNumber {
    if (![self isPureInt:_numberFiled.text]) {
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_INPUT, _numberFiled.text), nil];
        _numberFiled.text = _lastInputNumber;
    }
}
- (void)checkInputCode {
    if (![self isPureInt:_verifiFiled.text]) {
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_INPUT, _verifiFiled.text), nil];
        _verifiFiled.text = _lastInputCode;
    }
}

- (BOOL)uiChangesOnAskCode {
    if ([_numberFiled isFirstResponder]) {
        [_numberFiled resignFirstResponder];
    }
    if ([_verifiFiled isFirstResponder]) {
        [_verifiFiled resignFirstResponder];
    }
    [TimerTickerManager startTimerTickerDown:self withTotalTicker:60];
    _smsButton.userInteractionEnabled = NO;
    //_indicatorLabel.text = _infoText;
    _indicatorLabel.textColor = [UIColor blackColor];
    return YES;
}

- (void)startSMSVerification {
    getAuthcodeCount++;
    [self checkInputNumber];
    [self recordForKey:CENTER_CLICK_GET_AUTHCODE_TYPE ForValue:[NSString stringWithFormat:@"%d", getAuthcodeCount]];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSInteger resultCode = 0;
        if ([[Reachability shareReachability] currentReachabilityStatus] != NotReachable) {
            resultCode = [SeattleFeatureExecutor askVerifyCode:_numberFiled.text isVoiceType:NO];
        }
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_RESULT_OF_GET_VERIFY_CODE, @(resultCode)), nil];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self notifyVerifyResult:resultCode type:@"sms"];
            [self recordForKey:CENTER_SMS_AUTHCODE_RESULT ForValue:[NSString stringWithFormat:@"%d", resultCode]];
        });
    });
    cootek_log(@"start sms verification");
    [DialerUsageRecord recordpath:EV_VOIP_VERIFY_SEND kvs:Pair(@"type", @"sms"), nil];
}

- (void)onSubmitPressed {
    [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_CLICK_TO_VERIFY_CODE, @(1)), nil];
    if ([_numberFiled isFirstResponder]) {
        [_numberFiled resignFirstResponder];
    }
    if ([_verifiFiled isFirstResponder]) {
        [_verifiFiled resignFirstResponder];
    }
    
    [self checkInputNumber];
    [self checkInputCode];
//    NSString *accountName = [NSString stringWithFormat:@"+234%@",[_numberFiled text]];
//    if (![self isOtherCountryNumber:accountName]) {
        _submitButton.enabled = NO;
        [self setAllButtonEnabled:NO];
        if (_daisy == nil) {
            _daisy = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, _submitButton.frame.size.height, _submitButton.frame.size.height)];
            [_daisy setCenter:CGPointMake(_submitButton.frame.size.width/2, _submitButton.frame.size.height/2)];
            [_daisy setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            _daisy.hidesWhenStopped = YES;
            [_daisy startAnimating];
            [_submitButton addSubview:_daisy];
        } else {
            [_daisy startAnimating];
        }
        [self startExperience];
        _indicatorLabel.text = _infoText;
        _indicatorLabel.textColor = [UIColor blackColor];
//    } else {
//        [self changeIndicatorText:NSLocalizedString(@"voip_not_chinese_phone", "") isError:YES];
//    }
}

- (BOOL)isOtherCountryNumber:(NSString *)accountName{
    return [accountName hasPrefix:@"+"] && ![accountName hasPrefix:@"+234"];
}

- (void)startExperience {
    [self recordForKey:CENTER_CLICK_LOGIN_CONFIRM ForValue:@"1"];
    [self checkInputNumber];
    [self checkInputCode];
    NSString *number =[_numberFiled text];
    NSRange range = NSMakeRange(0, 2);
    NSString *temp = [number substringWithRange:range];
    if(([temp isEqualToString:@"07"] || [temp isEqualToString:@"08"] || [temp isEqualToString:@"09"]) && number.length == 11)
    {
        range = NSMakeRange(1, number.length - 1);
        number = [number substringWithRange:range];
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSInteger resultCode = 0;
        if ([[Reachability shareReachability] currentReachabilityStatus] != NotReachable) {
            resultCode =  [SeattleFeatureExecutor registerWithNumber:number andVerifyCode:[_verifiFiled text]];
        }
        [TPFilterRecorder recordpath:PATH_LOGIN
                                  kvs:Pair(LOGIN_RESULT_OF_VERIFY_CODE, @(resultCode)), nil];
        BOOL ifParticipate = [SeattleFeatureExecutor ifParticipateVoipOverseaWithPhone:number];
        [UserDefaultsManager setBoolValue:ifParticipate forKey:have_participated_voip_oversea];
        if (resultCode == 2000 && _netBlock) {
                [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
                [AllViewController asyncGetActivityFamilyInfo];

            _netBlock();
            
        } else if(_failedNetBlock) {
            _failedNetBlock();
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self notifyRegisterResult:resultCode];
            [_daisy stopAnimating];
            _submitButton.enabled = YES;
            [self changeHeadBarStyle];
            [self recordForKey:CENTER_LOGIN_CONFIRM_RESULT
                      ForValue:[NSString stringWithFormat:@"%d", resultCode]];
        });
    });
}

- (void)notifyRegisterResult:(int)result{
    _successInput = NO;
    if (result == 0){
        [self changeIndicatorText:NSLocalizedString(@"voip_network_register_error_and_retry", "") isError:YES];
    } else if (result == 2000) {
        [UserDefaultsManager setBoolValue:YES forKey:TOUCHPAL_USER_HAS_LOGIN];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAction" object:nil];
        if (_uiBlock) {
            _uiBlock();
        }
        
        cootek_log(@"login success, xinge userid-clientid begin rebuild new map");
        [UserDefaultsManager setBoolValue:NO forKey:XINGE_ADDUSER_SUCCESS];
        NSString *deviceTokenStr = [UserDefaultsManager stringForKey:XINGE_DEVICE_TOKEN];
        [[NoahManager sharedPSInstance] registerDevice:deviceTokenStr];
        [TPFilterRecorder sendFilterPath:PATH_LOGIN];
        
    } else if (result == 4104){
        [self changeIndicatorText:NSLocalizedString(@"voip_network_register_code_error", "") isError:YES];
    } else if (result == 4101){
        [self changeIndicatorText:NSLocalizedString(@"voip_network_verify_code_overdue", "") isError:YES];
    } else {
        [self changeIndicatorText:NSLocalizedString(@"voip_network_register_fail", "") isError:YES];
    }
    [self setAllButtonEnabled:YES];
    _submitButton.enabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *number = _numberFiled.text;
    NSString *code = _verifiFiled.text;
    if (textField == _numberFiled) {
        if ([self isPureInt:newText]) {
            number = newText;
            _lastInputNumber = number;
        }
        
        if (_numberFiled.text.length > 0) {
            _clearButton.hidden = NO;
            _fakeClearButton.hidden = NO;
        }
    } else {
        if ([self isPureInt:newText]) {
            code = newText;
            _lastInputCode = code;
        }
    }
    if([self checkNumber:number] && [TimerTickerManager getTimerTicker:self]<=0){
        //记录输入的号码
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_USER_INPUT_PHONE_NUMBER, number), nil];
        _verifyButton.enabled = YES;
        _smsButton.userInteractionEnabled = YES;
    } else {
        _verifyButton.enabled = NO;
        _smsButton.userInteractionEnabled = NO;
    }
    if ([self isPureInt:code] && (code.length >= 4) && [self checkNumber:number]) {
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_USER_INPUT_VERIFY_CODE, code), nil];
        _submitButton.enabled = YES;
    } else {
        _submitButton.enabled = NO;
    }
    [self checkIndicatorText];
    return YES;
}

- (void) checkIndicatorText {
    if (!_successInput) {
        [self changeIndicatorText:@"为保证去电显示本机号码，需验证手机号" isError:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_numberFiled isFirstResponder]) {
        [_numberFiled resignFirstResponder];
    }
    if ([_verifiFiled isFirstResponder]) {
        [_verifiFiled resignFirstResponder];
    }
}

- (void) dealloc{
    if (_numberFiled.text.length > 0 && ![_numberFiled.text isEqual:[UserDefaultsManager stringForKey:REGISTER_LAST_INPUT_NUMBER]]) {
        [UserDefaultsManager setObject:_numberFiled.text forKey:REGISTER_LAST_INPUT_NUMBER];
    }
    [TimerTickerManager setTimerTickerDownStop:self];
    [TimerTickerManager removeDelegate:self];
    self.uiBlock = nil;
    self.uiBlock = nil;
    self.failedNetBlock = nil;
    self.failedUIBlock = nil;
    self.infoText = nil;
}

- (void) changeHeadBarStyle {
    NSString *flag = (NSString *) [[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void) recordForKey:(NSString*)key ForValue:(NSString*)value {
    [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(key, value), Pair(CENTER_LOGIN_ORIGIN, [self.preInfo objectForKey:@"origin"]), nil];
}

- (void) setAllButtonEnabled:(BOOL)enabled {
    _submitButton.enabled = enabled;
    _backBtn.enabled = enabled;
    _verifyButton.enabled = enabled;
    _smsButton.userInteractionEnabled = enabled;
}
- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void) viewDidDisappear:(BOOL)animated
{
    if (![UserDefaultsManager objectForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        if (_failedUIBlock) {
            _failedUIBlock();
        }
    }
    cootek_log(@"viewDidDisappear : %@",self.class);
    [super viewDidDisappear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
}

#pragma mark delegate CommonHeaderBarProtocol
- (void) leftButtonAction {
    [self changeHeadBarStyle];
    NSString *origin = [self.preInfo objectForKey:@"origin"];
    if (origin == nil) {
        origin = @"unknown";
    }
    [TimerTickerManager setTimerTickerDownStop:self];
    [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(CENTER_AUTHCODE_TIMES_CLICK_LOGIN_BACK, ([NSString stringWithFormat:@"%d",getAuthcodeCount])),Pair(CENTER_AUTHCODE_CONTENT_INPUT_LOGIN_BACK, ([NSString stringWithFormat:@"%d", _verifiFiled.text && _verifiFiled.text.length == 4])), Pair(CENTER_LOGIN_ORIGIN, origin), nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_BACK, @(1)), nil];
    [TPFilterRecorder sendFilterPath:PATH_LOGIN];
}

@end

