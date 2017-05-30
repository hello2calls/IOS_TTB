//
//  ViewModelGenerator.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/11.
//
//

#import "HangupViewModelGenerator.h"
#import "TPDialerResourceManager.h"
#import "VoipUtils.h"
#import "VoipFeedbackInfo.h"
#import "UserDefaultsManager.h"
#import "PhoneNumber.h"
#import "FunctionUtility.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPCallActionController.h"
#import "UMFeedbackController.h"
#import "TouchPalVersionInfo.h"
#import "LoginController.h"
#import "MarketLoginController.h"
#import "SeattleFeatureExecutor.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "ErrorHangupModelGenerator.h"
#import "FeatureGuideModelGenerator.h"
#import "ErrorHangupModelGenerator.h"
#import "HangupCommercialManager.h"
#import "UMFeedbackFAQController.h"
#import "CootekNotifications.h"

@implementation HangupModel

@end

@implementation HeaderViewModel

@end

@implementation MiddleViewModel

@end

@implementation MainActionViewModel

@end

@interface HangupViewModelGenerator ()

@property (nonatomic,strong) NSDictionary *exceptErrorCodeMap;

@end

@implementation HangupViewModelGenerator {
    BOOL _spitPressed;
    __weak id<ModelChangeDelegate> _delegate;
    BaseHangupModelGenerator *_modelGenerator;
    
    NSString *_errorMsg;
    MainActionViewModel *_mainActionViewModel;
}

- (NSDictionary *)exceptErrorCodeMap
{
    return @{@"4001":@YES,@"4002":@YES,@"4003":@YES,@"4008":@YES};
}

- (id)initWithHangupModel:(HangupModel *)hangupModel andDelegate:(id<ModelChangeDelegate>)delegate{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _hangupModel = hangupModel;
        _errorMsg = nil;
        if (hangupModel.errorCode > 0) {
            [VoipUtils translateErrorCode:hangupModel.errorCode withCallBack:^(NSString *errorMessage,NSString *extraInfo,NSString *remind,NSString *solution,NSString* solution_action,NSString *dialog_solution_action,NSString *dialog_solution_btn,NSString *dialog_solution_main) {
                _errorMsg = errorMessage;
        }];
        }
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(IS_NORMAL_SHOW, @(_errorMsg == nil)), nil];
        if (_errorMsg && ![VoipUtils ifShowADWithErrorCode:hangupModel.errorCode ifOutging:!hangupModel.isIncomingCall] && ![self containExceptErrorCodeWithHangUpModel:hangupModel]) {

            _modelGenerator = [[ErrorHangupModelGenerator alloc] initWithHangupModel:hangupModel];
            
        } else {

            BOOL isFirstNornalHangup = NO;

            if (hangupModel.callDur > 0 && hangupModel.errorCode <= 0 && !hangupModel.isp2pCall) {
                if (![UserDefaultsManager boolValueForKey:HANGUP_SPIT_GUIDE]) {
                    isFirstNornalHangup = YES;
                    [UserDefaultsManager setBoolValue:YES forKey:HANGUP_SPIT_GUIDE];
                }
            }
            _modelGenerator = [[FeatureGuideModelGenerator alloc] initWithHangupModel:hangupModel andIfFirstNormalHangup:isFirstNornalHangup];
        }
        _modelGenerator.changeDelegate = delegate;
    }
    return self;
}

- (id)initWithshowBackCallOrFeatureProviderHangupModel:(HangupModel *)hangupModel andDelegate:(id<ModelChangeDelegate>)delegate{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _hangupModel = hangupModel;
        _errorMsg = nil;

        if (hangupModel.errorCode > 0) {
            [VoipUtils translateErrorCode:hangupModel.errorCode withCallBack:^(NSString *errorMessage,NSString *extraInfo,NSString *remind,NSString *solution,NSString* solution_action,NSString *dialog_solution_action,NSString *dialog_solution_btn,NSString *dialog_solution_main) {
                _errorMsg = errorMessage;
            }];
        }
        
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(IS_NORMAL_SHOW, @(_errorMsg == nil)), nil];
        if (_errorMsg && ![VoipUtils ifShowADWithErrorCode:hangupModel.errorCode ifOutging:!hangupModel.isIncomingCall] && ![self containExceptErrorCodeWithHangUpModel:hangupModel]) {

            _modelGenerator = [[ErrorHangupModelGenerator alloc] initWithHangupModel:hangupModel];
        } else {
            BOOL isFirstNornalHangup = NO;

            if (hangupModel.callDur > 0 && hangupModel.errorCode <= 0 && !hangupModel.isp2pCall) {
                if (![UserDefaultsManager boolValueForKey:HANGUP_SPIT_GUIDE]) {
                    isFirstNornalHangup = YES;
                    [UserDefaultsManager setBoolValue:YES forKey:HANGUP_SPIT_GUIDE];
                }
            }

            _modelGenerator = [[FeatureGuideModelGenerator alloc] initWithshowBackCallOrFeatureProviderHangupModel:hangupModel];
        }
        _modelGenerator.changeDelegate = delegate;
    }
    return self;
}

- (id)initTocheckVoipErrorWithHangupModel:(HangupModel *)hangupModel{
    self = [super init];
    if (self) {
        _hangupModel = hangupModel;
        _errorMsg = nil;

        if (hangupModel.errorCode > 0) {
            [VoipUtils translateErrorCode:hangupModel.errorCode withCallBack:^(NSString *errorMessage,NSString *extraInfo,NSString *remind,NSString *solution,NSString* solution_action,NSString *dialog_solution_action,NSString *dialog_solution_btn,NSString *dialog_solution_main) {
                _errorMsg = errorMessage;
            }];
        }
        
        [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(IS_NORMAL_SHOW, @(_errorMsg == nil)), nil];

        if (_errorMsg && ![VoipUtils ifShowADWithErrorCode:hangupModel.errorCode ifOutging:!hangupModel.isIncomingCall] && ![self containExceptErrorCodeWithHangUpModel:hangupModel]) {
            _modelGenerator = [[ErrorHangupModelGenerator alloc] initWithHangupModel:hangupModel];
        } else {
            BOOL isFirstNornalHangup = NO;
            if (hangupModel.callDur > 0 && hangupModel.errorCode <= 0 && !hangupModel.isp2pCall) {
                if (![UserDefaultsManager boolValueForKey:HANGUP_SPIT_GUIDE]) {
                    isFirstNornalHangup = YES;
                    [UserDefaultsManager setBoolValue:YES forKey:HANGUP_SPIT_GUIDE];
                }
            }
            _modelGenerator = [[FeatureGuideModelGenerator alloc] init];
        }
    }
    return self;
}



- (BOOL)containExceptErrorCodeWithHangUpModel:(HangupModel *)hangUpModel
{
    NSString *key = [NSString stringWithFormat:@"%d",hangUpModel.errorCode];
    return [self.exceptErrorCodeMap valueForKey:key] != nil ? YES : NO;
}

- (HeaderViewModel *)getHeaderModel {
    return [_modelGenerator getHeaderModel];
}

- (MiddleViewModel *)getMiddleModel {
    return [_modelGenerator getMiddleModel];
}

- (MainActionViewModel *)getMainActionViewModel {
    if (_mainActionViewModel) {
        return _mainActionViewModel;
    }
    MainActionViewModel *model = [_modelGenerator getMainActionViewModel];
    __weak HangupViewModelGenerator *bself = self;
    model.onRedialButtonClick = ^ {
        [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
        [bself redial];
    };
    model.onSpitButtonClick = ^ {
        [UserDefaultsManager setBoolValue:YES  forKey:DIALER_GUIDE_ANIMATION_WAIT];
        [bself spit];
    };
    model.onHideButtonClick = ^ {
        [UserDefaultsManager setBoolValue:NO  forKey:DIALER_GUIDE_ANIMATION_WAIT];
        [bself onHideButtonPress];
    };
    _mainActionViewModel = model;
    return model;
}

- (UIImage *)getBgImage {
    return [_modelGenerator getBgImage];
}

- (void)spit {
    int type = _hangupModel.isBackCall;
    VoipFeedbackInfo *info = [[VoipFeedbackInfo alloc]init];
    info.callerNumber = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    info.calleeNumber = [PhoneNumber getCNnormalNumber:_hangupModel.number];
    info.netType = [FunctionUtility networkType];
    info.callType = type;
    info.startTime = _hangupModel.startTime;
    info.duration = _hangupModel.callDur;
    info.shouldUpload = !_spitPressed;
    HandlerWebViewController *con = [[HandlerWebViewController alloc]init];
    con.ifRefreshHidden = YES;
    con.file_name = @"tucao.html";
    con.relatedObject = info;
    [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
    _spitPressed = YES;
    [UserDefaultsManager setBoolValue:YES forKey:VOIP_SHOULD_GUIDE_BACK_CALL];
    [_delegate close];
    [UMFeedbackFAQController setLatestVoipCall];
    [[HangupCommercialManager instance] hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_COMPLAIN];
}

- (void)redial {
    [_delegate close];
    [[TPCallActionController controller] makeCallWithNumber:_hangupModel.number];
    [TPCallActionController logCallFromSource:@"voip_redial"];
    [[HangupCommercialManager instance] hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_REDIALER];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:N_VOIP_PRIVILEGE_AD_TO_SHOW object:nil];
        [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(VIP_REDIAL, @(1)), nil];
    });
}

- (void)onHideButtonPress {
    [_delegate closeAnimate];
     [[HangupCommercialManager instance] hangupADDisappearWithCloseType:ADCLOSE_BUTTEN_CLOSE];
}

- (NSString *)getErrorCode {
    return [_modelGenerator getErrorCode];
}

- (UIColor *)bottomCoverColor {
    if ([self getMainActionViewModel].lightBg) {
        return nil;
    } else {
        return [UIColor blackColor];
    }
}

- (id) getModelGenerator {
    return _modelGenerator;
}
@end
