//
//  ErrorHangupModelGenerator.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import "ErrorHangupModelGenerator.h"
#import "TPDialerResourceManager.h"
#import "VoipUtils.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "TouchPalDialerAppDelegate.h"
#import "UMFeedbackController.h"
#import "LoginController.h"
#import "MarketLoginController.h"
#import "TouchPalVersionInfo.h"
#import "AppSettingsModel.h"
#import "UserDefaultKeys.h"
#import "UIView+Toast.h"
@implementation ErrorHangupModelGenerator {
    NSString *_errorMsg;
    NSString *_detailErrorMsg;
    NSString *_errorRemindText;
    NSString *_solutionText;
    NSString *_solution_action;
}

- (id)initWithHangupModel:(HangupModel *)model {
    self = [super initWithHangupModel:model];
    if (self) {
        _errorMsg = nil;
        _detailErrorMsg = nil;
        _solutionText = nil;
        [VoipUtils translateErrorCode:self.hangupModel.errorCode withCallBack:^(NSString *errorMessage,NSString *extraInfo,NSString *remind,NSString *solution,NSString* solution_action,NSString *dialog_solution_action,NSString *dialog_solution_btn,NSString *dialog_solution_main) {
            _errorMsg = errorMessage;
            _detailErrorMsg = extraInfo;
            _errorRemindText = remind;
            _solutionText = solution;
            _solution_action = solution_action;
            
        }];
        [DialerUsageRecord recordpath:EV_VOIP_CALL_ERROR kvs:Pair(@"errorMessage", _errorMsg), Pair(@"dur", @(self.hangupModel.callDur)),Pair(@"isBackCall", @(self.hangupModel.isBackCall)),Pair(@"usingNewBackProtocol", @(self.hangupModel.usingNewBackCallMode)),Pair(@"errorCode", @(self.hangupModel.errorCode)),nil];
        if (self.hangupModel.errorCompansate > 0) {
            _detailErrorMsg = @"宝仔感到万分抱歉\n特别准备了50分钟作为补偿";
            _errorRemindText = nil;
        }
    }
    return self;
}

- (HeaderViewModel *)getHeaderModel {
    HeaderViewModel *model = [[HeaderViewModel alloc] init];
    model.mainText = @"通话结束";
    model.altText = _errorMsg;
    return model;
}

- (MiddleViewModel *)getMiddleModel {
    MiddleViewModel *model = [[MiddleViewModel alloc] init];
    model.icon = [TPDialerResourceManager   getImage:@"hangup_error_for_compensate@2x.png"];
    model.text = _detailErrorMsg;
    model.isError = YES;
    return model;
}

- (MainActionViewModel *)getMainActionViewModel {
    MainActionViewModel *model  = [[MainActionViewModel alloc] init];
    if (_errorRemindText) {
        model.redialGuideText = _errorRemindText;
    } else {
        if (_solutionText) {
            model.mainButtonTitle = _solutionText;
        if ([_solution_action isEqualToString:@"appeal"]) {
            model.onMainButtonClick = ^ {
                UMFeedbackController *vc = [[UMFeedbackController alloc]init];
                [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
                [self.changeDelegate close];
            };
        } else if ([_solution_action isEqualToString:@"upgrade"]) {
            model.onMainButtonClick = ^ {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TOUCHPAL_DIALER_APP_STORE_URL]];
                [self.changeDelegate close];
            };
        }else if ([_solution_action isEqualToString:@"fix"]) {
            model.onMainButtonClick = ^ {
                [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:NO] forKey:IS_VOIP_ON];
                [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
                [self.changeDelegate close];
                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [uiWindow makeToast:@"问题已修复，重拨一下试试吧！" duration:1.0f position:CSToastPositionBottom];
            };
        }else if([_solution_action isEqualToString:@"launch_activity_center"]){
            model.onMainButtonClick = ^ {
            [LoginController checkLoginWithDelegate:[MarketLoginController withOrigin:@"personal_center_market"]];
            };
        }
    }
        else if (self.hangupModel.errorCompansate > 0) {
            model.mainButtonTitle = @"领取补偿";
            __weak MainActionViewModel *bModel = model;
            model.onMainButtonClick = ^ {
                bModel.buttonState = LOADING_DONE_HIDE;
                bModel.spitGuideText = @"领取成功，通话问题欢迎吐槽";
            };
        }
    }
    model.lightBg = YES;
    return model;
}

- (NSString *)getErrorCode {
    return [NSString stringWithFormat:@"%d", self.hangupModel.errorCode];
}

@end
