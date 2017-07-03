//
//  CallProceedingDisplay.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import "CallProceedingDisplay.h"
#import "VoipTopSectionMiddleView.h"
#import "CallingAnimateTextView.h"
#import "VoipConsts.h"
#import "TPDialerResourceManager.h"
#import "CallFeeReminderView.h"
#import "UserDefaultsManager.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"
#import "UILabel+TPHelper.h"
#import "VoipCallPopUpView.h"
#import "NSString+TPHandleNil.h"
#import "FunctionUtility.h"
#import "UILayoutUtility.h"
#import "TPCallActionController.h"

@implementation CallProceedingDisplay {
    VoipTopSectionMiddleView *_breathingView;
    CallingAnimateTextView *_stateView;
    __weak UIView *_holderView;
    CallMode _callMode;
    BOOL _displayingPromotion;
    BOOL _isPal;
    UIView *_reminderView;
    UIColor *_palColor;
    UIColor *_errorColor;
    UILabel *_infoLabel;
    CallAvatarGroup *_avatarGroup;
    UIView *_infoBoxView;
    BOOL _arrowAnimationStarted;
    BOOL _faddingAnimationStarted;
    BOOL _displayHidden;
    NSString *_otherPhoneNumber;
}

@synthesize hiddenProceeding = _hiddenProceeding;
- (id)initWithHostView:(UIView *)view andDisplayArea:(CGRect)frame callMode:(CallMode)callMode otherPhoneNumberArr:(NSArray *)otherPhoneNumberArr{
    
    self = [super init];
    if (self) {
        _otherPhoneNumber = otherPhoneNumberArr[0];
        _arrowAnimationStarted = NO;
        _faddingAnimationStarted = NO;
        _displayHidden = NO;
        
        CGFloat gY = frame.origin.y;
        CGFloat gX = (TPScreenWidth() - STATUS_INFO_BOX_WIDTH) / 2;
        CGFloat boxHeight = STATUS_INFO_BOX_HEIGHT_SMALL;
        if (isIPhone5Resolution()) {
            boxHeight = STATUS_INFO_BOX_HEIGHT;
        }
        
        _holderView = view;
        float width = frame.size.width;
        VoipTopSectionMiddleView *breathingView = [[VoipTopSectionMiddleView alloc] initWithFrame:frame];
//        [_holderView addSubview:breathingView];
        [breathingView setInnerCircleImage:[TPDialerResourceManager getImage:@"voip_middle_view_basic_bg@2x.png"]];
        _breathingView = breathingView;
        
        //the state on breathing view
        float stateWidth = width - 50*WIDTH_ADAPT;
        if (TPScreenHeight() < 500) {
            stateWidth += 10;
        }
        CallingAnimateTextView *stateView = [[CallingAnimateTextView alloc] initWithFrame:CGRectMake(
            (frame.size.width - stateWidth)/2, (width - stateWidth)/2, stateWidth, stateWidth)];
        [_breathingView addSubview:stateView];
        _stateView = stateView;
        
        _palColor = [UIColor colorWithRed:COLOR_IN_256(0x0f) green:COLOR_IN_256(0x74) blue:COLOR_IN_256(0xd9) alpha:1];
        _errorColor = [UIColor colorWithRed:COLOR_IN_256(0x99) green:COLOR_IN_256(0x00) blue:COLOR_IN_256(0x66) alpha:1];
        
        // avatar group view
        NSString *callerNumber = nil;
        NSString *calleeNumber = nil;
        NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];
        
        if (callMode == CallModeOutgoingCall
            || callMode == CallModeBackCall
            || callMode == CallModeTestType) {
            callerNumber = accountName;
            calleeNumber = otherPhoneNumberArr[0];
            
        } else if (callMode == CallModeIncomingCall) {
            callerNumber = otherPhoneNumberArr[0];
            calleeNumber = accountName;
        }
        
        if (otherPhoneNumberArr.count == 1) {
            _avatarGroup = [[CallAvatarGroup alloc] initWithCallMode:callMode callerNumber:callerNumber calleeNumber:calleeNumber];
            _avatarGroup.frame = CGRectMake(gX, gY, _avatarGroup.frame.size.width, _avatarGroup.frame.size.height);
        }else{
            _avatarGroup = [[CallAvatarGroup alloc] initWithCallMode:callMode callerNumber:accountName otherNumArr:otherPhoneNumberArr];
            _avatarGroup.frame = CGRectMake(0, 90, _avatarGroup.frame.size.width, _avatarGroup.frame.size.height);
        }
        
        
        gY += _avatarGroup.frame.size.height;
        
        // info box
        gY += 30;
        _infoBoxView = [[UIView alloc] initWithFrame:CGRectMake(gX, gY, STATUS_INFO_BOX_WIDTH, boxHeight)];
        _infoBoxView.hidden = YES;
        gY += _infoBoxView.frame.size.height;
        
        CGFloat infoWidth = STATUS_INFO_BOX_WIDTH - 12 * 2;
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, infoWidth, 0)];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.numberOfLines = 0;
        _infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _infoLabel.font = [UIFont systemFontOfSize:16];
        _infoLabel.textColor = [UIColor whiteColor];
        
        _infoLabel.text = @" ";
        if (callMode == CallModeOutgoingCall || callMode == CallModeTestType) {
            [self checkCalleeIfOversea:calleeNumber];
        } else if (callMode == CallModeBackCall) {
            [self setInfoWhenBackcall];
        }
        [_infoLabel adjustSizeByFixedWidth];
        
        CGSize infoSize = _infoLabel.frame.size;
        _infoLabel.frame = CGRectMake(_infoLabel.frame.origin.x, (_infoBoxView.frame.size.height - infoSize.height) / 2, infoWidth, infoSize.height);
        
        CGFloat gbX = 0;// box x
        // inclaration
        CGFloat alertMarginHorizontal = 16;
        UIFont *alertFont = [UIFont fontWithName:@"iPhoneIcon2" size:27];
        UILabel *alertLabel = [[UILabel alloc] initWithTitle:@"F" font:alertFont isFillContentSize:YES];
        alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        alertLabel.center = CGPointMake(STATUS_INFO_BOX_WIDTH / 2, 0);
        
        UIColor *lineColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"];
        CGFloat lineWidth = _infoBoxView.frame.size.width / 2 - alertMarginHorizontal - alertLabel.frame.size.width / 2;
        
        // top lef line
        UIView *topLeftLine = [[UIView alloc] initWithFrame:CGRectMake(gbX, 0, lineWidth, 0.5)];
        topLeftLine.backgroundColor = lineColor;
        gbX += topLeftLine.frame.size.width;
        
        gbX += alertMarginHorizontal;
        // top right line
        UIView *topRightLine = [[UIView alloc] initWithFrame:CGRectMake(_infoBoxView.frame.size.width - lineWidth, 0, lineWidth, 0.5)];
        topRightLine.backgroundColor = lineColor;
        
        // bottom line
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, boxHeight - 0.5, STATUS_INFO_BOX_WIDTH, 0.5)];
        bottomLine.backgroundColor = lineColor;
        
        // views: status info box
        [_infoBoxView addSubview:topLeftLine];
        [_infoBoxView addSubview:topRightLine];
        [_infoBoxView addSubview:bottomLine];
        [_infoBoxView addSubview:_infoLabel];
        [_infoBoxView addSubview:alertLabel];
        
        // view tree
        [_holderView addSubview:_infoBoxView];
        [_holderView addSubview:_avatarGroup];
        
    }
    
    return self;
}

- (void)proceedingWithCallMode:(CallMode)callMode{
    _callMode = callMode;
    NSString *initialText = nil;
    if (callMode == CallModeOutgoingCall || callMode == CallModeBackCall||callMode==CallModeTestType) {
        initialText = NSLocalizedString(@"voip_outgoing_connect_server", @"");
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO] ) {
            [_avatarGroup setStatusString:@"VIP专线接通中"];
        }
        if (!_faddingAnimationStarted) {
            [_avatarGroup startFadding];
            _faddingAnimationStarted = YES;
        }
        
    } else if (callMode == CallModeIncomingCall) {
        _userType = OTHTER_CALLING_ACTIVE;
        _avatarGroup.otherAvatarView.userType = OTHTER_CALLING_ACTIVE;
        [self setInfo:@""];
    }
    if (!_arrowAnimationStarted) {
        [_avatarGroup startMovingArrow];
        _arrowAnimationStarted = YES;
    }
}

- (void)showQueryTouchPal {
     BOOL isVip = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    if (_callMode != CallModeIncomingCall) {
        if (isVip) {
            [_avatarGroup setStatusString:@"VIP专线通话中"];
        }else{
        [_avatarGroup setStatusString:@"正在呼叫"];
        }
    }
}

- (void) showCalling {
    [_avatarGroup setStatusString:@"正在呼叫"];
}

- (void)showQueryResultIsPalOrNot:(BOOL)isPal isActive:(BOOL)isActive callType:(NSInteger)callType{
    _isPal = isPal;
    BOOL isVip = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    if (callType == VOIP_OVERSEA) {
        return;
    }
    NSString *statusString = nil;
    _userType = -1;
    if (isVip) {
        statusString = @"VIP专线通话中";
    }else{
        statusString = @"正在呼叫";
    }

    NSString *infoString = nil;
    
    BOOL ifFamily = [FunctionUtility CheckIfExistInBindSuccessListarrayWithPhone:_otherPhoneNumber];
    if (ifFamily) {
        infoString = @"对方是你的亲情号\n打满1分钟，就得1分钟";
    } else {
        if (isPal) {
            // touchpal user
            _userType = OTHER_ACTIVE;
            
            if (!isActive) {
                _userType = OTHER_INACTIVE;
                infoString = @"对方已经没有再使用通通宝了，本次通话扣除免费分钟数";
                
            } else if (isVip) {
                int days = [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY defaultValue:-1];
                if (days > 0) {
                    infoString = [NSString stringWithFormat:@"VIP享高清通话不中断保护\nVIP特权剩余%d天", days];
                }
                
            } else {
                if (_callMode == CallModeTestType) {
                    infoString = @"本次通话不消耗分钟数和流量";
                } else {
                    infoString = @"对方是触宝好友，本次通话不消耗免费时长";
                }
            }
            
        } else {
            // not touchpal user
            _userType = OTHER_UNKNOWN;
            infoString = [NSString stringWithFormat:@"剩余时长%d分钟", _originalMinute];
        }
    }
    
    
    
    _avatarGroup.otherAvatarView.userType = _userType;
    [_avatarGroup stopFadding];
    
    if (!_isBackCall) {
        // discard the info
         _avatarGroup.statusString = statusString;
        [self setInfo:infoString];
    }
}

- (void) checkCalleeIfOversea:(NSString *)number {
    NSInteger callType = [[TPCallActionController controller] getCallNumberTypeCustion:number];
    if (callType == VOIP_OVERSEA) {
        _userType = OTHER_OVERSEA;
        NSString *statusString = @"正在呼叫";
//        NSString *infoString = @"对方为国际号码，本次通话多倍扣除免费分钟数";
        _avatarGroup.otherAvatarView.userType = _userType;
        _avatarGroup.statusString = statusString;
//        [self setInfo:infoString];
        [_avatarGroup stopFadding];
    }
}

- (void) setInfo:(NSString *)info {
    info = [NSString nilToEmpty:info];
    _infoBoxView.hidden = NO;
    _infoLabel.text = info;
    [_infoLabel adjustSizeByFixedWidth];
    CGSize infoSize = _infoLabel.frame.size;
    CGFloat infoWidth = STATUS_INFO_BOX_WIDTH - 12 * 2;;
    _infoLabel.frame = CGRectMake(_infoLabel.frame.origin.x, (_infoBoxView.frame.size.height - infoSize.height) / 2, infoWidth, infoSize.height);
}

- (void)setInfoWhenBackcall {
    [self setInfo:@"请接听通通宝来电，如果您的手机套餐接听收费，运营商将会收取接听或漫游费用"];
    if (_displayHidden) {
        [self showDisplay];
    }
}

- (void)showBackCallDecided {
    [_stateView chaneText:@"等待系统来电" changingBlock:^{
        [_stateView showIndicator];
    }];
}

- (void)showRemainingMinutes:(int)remaining{
    NSAttributedString *attrText = [self getRemainningMinutes:remaining];
    if (remaining == _originalMinute) {
        //first show remaining, need hightlight
        [_stateView hightLightChaneAttrText:attrText withChangingBlock:^{
            [_stateView hideIndicator];
        }];
    } else {
        [_stateView changeAttrText:attrText withChangingBlock:nil];
    }
    if (remaining < 5) {
        if (!_isBackCall) {
            _breathingView.circleColor = [TPDialerResourceManager getColorForStyle:@"outgoing_circle_error_color"];
        }
    }
}

- (NSAttributedString *)getRemainningMinutes:(int)remaining{
    NSString *minutes = [NSString stringWithFormat:@"%d", remaining];
    NSString *text = [NSString stringWithFormat:@"%@\n%@\n %@",NSLocalizedString(@"voip_outgoing_remaining_time", @""), minutes, NSLocalizedString(@"minutes", @"")];
    NSRange range = [text rangeOfString:minutes];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"outgoing_circle_minutes_color"] range:range];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:34*WIDTH_ADAPT] range:range];
    return attrText;
}

- (void)showFreeCallShouldHighlight:(BOOL)highLight{
    NSString *text1 = NSLocalizedString(@"voip_outgoing_touchpal_call1", @"");
    NSString *text2 = NSLocalizedString(@"voip_outgoing_touchpal_call2", @"");
    NSString *text = [NSString stringWithFormat:@"%@\n%@", text1, text2];
    NSRange range = [text rangeOfString:text2];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:34*WIDTH_ADAPT] range:range];
    if (highLight) {
        [_stateView hightLightChaneAttrText:attrText withChangingBlock:^{
            [_stateView hideIndicator];
        }];
    } else {
        [_stateView changeAttrText:attrText withChangingBlock:nil];
    }
}

- (void)ifShowFreeCallPrivilegaMessage{
        NSString *textPrivalega = @"VIP享高清通话不中断保护";
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:textPrivalega];
        NSRange range = [textPrivalega rangeOfString:textPrivalega];
        [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30*WIDTH_ADAPT] range:range];
            [_stateView hightLightChaneAttrText:attrText withChangingBlock:^{
                [_stateView hideIndicator];
            }];
}

- (void)showErrorInfo:(NSString *)info {
    [_stateView forceChangeText:info withDoneBlock:^{
        [_stateView hideIndicator];
        [_stateView setTextColor:_errorColor];
    }];
}

- (void)showRinging {
    if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]) {
        [_stateView chaneText:[NSString stringWithFormat:@"VIP专线接通中\n%@",NSLocalizedString(@"voip_ringing", @"")] changingBlock:^{
            [_stateView showIndicator];
        }];
    }else{
        [_stateView chaneText:NSLocalizedString(@"voip_ringing", @"") changingBlock:^{
            [_stateView showIndicator];
        }];
    }
   
}

- (void)showPalNotDecide {
    [_stateView chaneText:NSLocalizedString(@"voip_pal_not_decide", @"") changingBlock:^{
        [_stateView setTextColor: _palColor];
    }];
}

/**
 *  stop all animations
 */
- (void)stop {
    [_avatarGroup.otherAvatarView stopFadding];
    [_avatarGroup stopMovingArrow];
}

- (UIView *)addCallFeeRemindView {
    CGRect refFrame = _breathingView.frame;
    float width2 = 108*WIDTH_ADAPT;
    float height2 = 107*WIDTH_ADAPT;
    float x = refFrame.origin.x + refFrame.size.width + 20 - width2;
    float y = refFrame.origin.y;
    CallFeeReminderView *reminderView = [[CallFeeReminderView alloc] initWithFrame:CGRectMake(x, y, width2, height2)];
    reminderView.alpha = 0;
    [_holderView addSubview:reminderView];
    return reminderView;
}

- (void)showCallFeeRemindWithRemainingMin:(int)remaining {
    if (_displayingPromotion) {
        [_stateView forceChangeText:[self getRemainningMinutes:remaining] withDoneBlock:^{
            [self innerShowCallFeeRemindWithRemainingMinutes:remaining];
        }];
    } else {
        [self innerShowCallFeeRemindWithRemainingMinutes:remaining];
    }
}

- (void)innerShowCallFeeRemindWithRemainingMinutes:(int)remaining {
    CGRect refFrame = _breathingView.frame;
    UIView *reminderView = [self addCallFeeRemindView];
    _reminderView = reminderView;
    UILabel *label = nil;
    if (remaining < _originalMinute) {
        NSString *text = [NSString stringWithFormat:@"%d",(remaining - _originalMinute)];
        //        float width = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30*_scaleRatio]}].width + 10;
        float width = [text sizeWithFont:[UIFont systemFontOfSize:30*WIDTH_ADAPT]].width + 10;
        float height = 50;
        label = [[UILabel alloc] initWithFrame:CGRectMake(refFrame.origin.x + (refFrame.size.width - width)/2, refFrame.origin.y + (refFrame.size.height - height)/2, width, height)];
        label.text = text;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:30*WIDTH_ADAPT];
        label.textColor = [UIColor brownColor];
        label.alpha = 1;
        label.textAlignment = NSTextAlignmentCenter;
        [_holderView addSubview:label];
    }
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 3, 3);
        label.center = reminderView.center;
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            label.alpha = 0;
            reminderView.alpha = 1;
        } completion: ^(BOOL finished){
            
        }];
    }];
    
}

- (void)checkExchangeDisplayPromotionWithRemainingMinu:(int)remainning {
    if ([_promotion length] > 0) {
        _displayingPromotion = !_displayingPromotion;
        if (_displayingPromotion) {
            [_stateView chaneText:_promotion changingBlock:nil];
        } else {
            if (_isPal) {
                [self showFreeCallShouldHighlight:NO];
            } else {
                [self showRemainingMinutes:remainning];
            }
        }
    }
}

- (void)animateIndicator {
    [_stateView animateIndcator];
}

- (void)showBackCall {
    [_stateView chaneText:@"回拨模式" changingBlock:nil];
}

- (void)hideDisplay {
    [UIView animateWithDuration:0.2 animations:^{
        _infoBoxView.alpha = 0;
        _avatarGroup.alpha = 0;
        _displayHidden = YES;
    }];
}

- (void)hideDisplayAnimations:(void (^)())animations completion:(void (^)(BOOL finished))complete
{
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        _infoBoxView.alpha = 0;
        _avatarGroup.alpha = 0;
        if (animations) {
            animations();
        }
    } completion: complete];
}

- (void)showDisplay {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        _infoBoxView.alpha = 1;
        _avatarGroup.alpha = 1;
    } completion: nil];
}

- (void)setHiddenProceeding:(BOOL)hiddenProceeding
{
    _hiddenProceeding = hiddenProceeding;
    _breathingView.hidden = hiddenProceeding;
    _stateView.hidden = hiddenProceeding;
    _reminderView.hidden = hiddenProceeding;
}

- (BOOL)hiddenProceeding
{
    return _hiddenProceeding;
}

- (void)dealloc {

}

- (void) stopMovingArrow {
    if (_avatarGroup) {
        [_avatarGroup stopMovingArrow];
    }
}

- (void) setStatus:(NSString *)statusString {
    if (!_avatarGroup) {
        return;
    }
    [_avatarGroup setStatusString:statusString];
}

- (void) showTicker:(NSInteger)ticker {
    [_avatarGroup setStatusString:[CallProceedingDisplay translateTickerToTime:ticker] statusColor:[UIColor whiteColor]];
}

#pragma private helper
+ (NSString *)translateTickerToTime:(NSInteger) ticker{
    NSInteger hour = ticker / 3600;
    NSInteger minute = (ticker% 3600) / 60;
    NSInteger second = ticker % 60;
    NSString *hourResult;
    NSString *minuteResult;
    NSString *secondResult;
    if ( hour == 0 ){
        hourResult = @"";
    }else{
        hourResult = [NSString stringWithFormat:@"%d:",hour];
    }
    if (minute < 10){
        minuteResult = [NSString stringWithFormat:@"0%d:",minute];
    }else{
        minuteResult = [NSString stringWithFormat:@"%d:",minute];
    }
    if (second < 10){
        secondResult = [NSString stringWithFormat:@"0%d",second];
    }else{
        secondResult = [NSString stringWithFormat:@"%d",second];
    }
    return [NSString stringWithFormat:@"%@%@%@",hourResult,minuteResult,secondResult];
}

@end
