//
//  DefaultHangupModelGenerator.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import "BaseHangupModelGenerator.h"
#import "TPCallActionController.h"
#import "VoipCallPopUpView.h"
#import "VoipUtils.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
@implementation BaseHangupModelGenerator

- (id)initWithHangupModel:(HangupModel *)model {
    self = [super init];
    if (self) {
        self.hangupModel = model;

    }
    return self;
}

- (HeaderViewModel *)getHeaderModel {

    BOOL ifOversea =  [[TPCallActionController alloc] getCallNumberTypeCustion:_hangupModel.number]==VOIP_OVERSEA;
    HeaderViewModel *model = [[HeaderViewModel alloc] init];
    NSString *mainText = nil;
    NSString *remainingMinute = nil;
    NSString *familyMinute = nil;
    NSMutableAttributedString *attrString;
    UIColor *specialColor;

    BOOL ifFamily = [FunctionUtility CheckIfExistInBindSuccessListarrayWithPhone:_hangupModel.number];
    if (ifFamily && self.hangupModel.isIncomingCall==NO) {
        if (_hangupModel.callDur/60 >0) {
            model.mainText = [NSString stringWithFormat:@"通话结束 获得%d分钟免费时长", _hangupModel.callDur/60];
            familyMinute =[NSString stringWithFormat:@"%d分钟", _hangupModel.callDur/60];
        } else {
            model.mainText = @"通话结束 本通话不扣时长";
        }
        
    } else {
        if (ifOversea) {
            mainText= [NSString stringWithFormat:@"通话结束"];
        } else {
            if (_hangupModel.isPal
                && _hangupModel.userType!=OTHER_INACTIVE) {
                model.mainText = @"通话结束 本通话不扣时长";
                model.altText = @"触宝好友间享去电显号，无限畅打";
            } else {
                if (_hangupModel.remainMinute < 0) {
                    mainText = @"通话结束";
                } else {
                    remainingMinute = [NSString stringWithFormat:@"%d", _hangupModel.remainMinute];
                    mainText = [NSString stringWithFormat:@"通话结束，剩余%@分钟", remainingMinute];
                }
            }
        }
    }
    if (familyMinute) {
        attrString= [[NSMutableAttributedString alloc] initWithString:model.mainText];
        specialColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0xff6896"];
        [attrString addAttribute:NSForegroundColorAttributeName value:specialColor range:[model.mainText rangeOfString:familyMinute]];

        model.mainAttrString = attrString;

    }
    
    if (mainText.length>0) {
        attrString= [[NSMutableAttributedString alloc] initWithString:mainText];
        specialColor = [UIColor colorWithRed:COLOR_IN_256(0xff) green:COLOR_IN_256(0xd5) blue:COLOR_IN_256(0x2f) alpha:1];
    }
    if (remainingMinute.length>0) {
        [attrString addAttribute:NSForegroundColorAttributeName value:specialColor range:[mainText rangeOfString:remainingMinute]];
    }
    
        if (_hangupModel.errorCode > 0 && _hangupModel.errorCode != 4001 && _hangupModel.errorCode != 4002 && _hangupModel.errorCode != 4003 && _hangupModel.errorCode != 4008) {
        if ([VoipUtils ifShowADWithErrorCode:_hangupModel.errorCode ifOutging:!_hangupModel.isIncomingCall]) {
            model.mainText= @"免费电话服务出现异常，请稍后再拨";
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voip_error_code_ad_text" ofType:@"json"]] options:(NSJSONReadingMutableLeaves) error:&error];
            NSString *error_string = nil;
            if (error==nil && dic.allKeys.count > 0)
                error_string = dic[[NSString stringWithFormat:@"%ld",_hangupModel.errorCode]];
            if (error_string.length > 0) {
                model.mainText = error_string;
            }
            model.altText = @"此通电话由以下品牌赞助";
            attrString = nil;
        }
        
    }

    model.mainAttrString = attrString;
    return model;
}

- (MiddleViewModel *)getMiddleModel {
    return nil;
}

- (MainActionViewModel *)getMainActionViewModel {
    return nil;
}

- (UIImage *)getBgImage {
    return nil;
}

- (NSString *)getErrorCode {
    return nil;
}

@end
