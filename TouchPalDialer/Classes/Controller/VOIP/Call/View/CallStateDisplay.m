//
//  CallStateDisplay.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import "CallStateDisplay.h"
#import "CallingStateTextView.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"
#import "VoipConsts.h"
#import "CallerIDModel.h"

@implementation CallStateDisplay {
    CallMode _callMode;
    __weak UIView *_holderView;
    __strong NSString *_number;
    __strong CallingStateTextView *_callingView;
}

- (id)initWithHolderView:(UIView *)view andDisplayArea:(CGRect)frame {
    self = [super init];
    if (self) {
        _holderView = view;
        _callingView = [[CallingStateTextView alloc] initWithFrame:frame];
        [_holderView addSubview:_callingView];
        _callingView.layer.borderWidth = 2;
        _callingView.layer.borderColor = [UIColor redColor].CGColor;
    }
    return self;
}



- (void)setNumber:(NSString *)number andCallMode:(CallMode)callMode {
    _number = number;
    _callMode = callMode;
    //clear the before state
    [_callingView setLine1:nil line2:nil line3:nil];
    int personId = [NumberPersonMappingModel queryContactIDByNumber:_number];
    float fontSizeMain = 20*WIDTH_ADAPT;
    float fontSizeAlt = 16*WIDTH_ADAPT;
    NSString *callActionDisplay = nil;
    if (_callMode == CallModeOutgoingCall || _callMode == CallModeTestType) {
        callActionDisplay = NSLocalizedString(@"voip_outgoing_calling", @"");
    }
    
    if (personId > 0) {
        ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
        [_callingView setLine1:contact.displayName line2:_number line3:callActionDisplay];
        [_callingView setFont1:fontSizeMain font2:fontSizeAlt font3:fontSizeAlt];
        [_callingView setNeedsDisplay];
    } else {
        [_callingView setLine1:_number line2:callActionDisplay line3:nil];
        [_callingView setFont1:fontSizeMain font2:fontSizeAlt font3:fontSizeAlt];
        [_callingView setNeedsDisplay];
        [CallerIDModel queryCallerIDWithNumber:_number callBackBlock:^(CallerIDInfoModel * callerId){
            if ([callerId isCallerIdUseful]) {
                NSString *line3 = _callingView.line3;
                if (line3 == nil) {
                    line3 = callActionDisplay;
                }
                if (callerId.name.length > 0) {
                    [_callingView setLine1:[callerId getUsefulString] line2:_number line3:line3];
                } else {
                    [_callingView setLine1:_number line2:[callerId getUsefulString] line3:line3];
                }
                [_callingView setFont1:fontSizeMain font2:fontSizeAlt font3:fontSizeAlt];
                [_callingView setNeedsDisplay];
            }
        }];
    }

}



- (void)showHangupState {
    if (_callingView.line3 == nil) {
        [_callingView setLine2: NSLocalizedString(@"voip_outgoing_hangup", @"")];
    } else {
        [_callingView setLine3: NSLocalizedString(@"voip_outgoing_hangup", @"")];
    }
    [_callingView setNeedsDisplay];
}

- (void)showTicker:(NSInteger)tick {
    if (_callingView.line3 == nil) {
        _callingView.line2 = [self translateTickerToTime:tick];
    } else {
        _callingView.line3 = [self translateTickerToTime:tick];
    }
    [_callingView setNeedsDisplay];
}

- (void)showSystemCallComing {
    if (_callingView.line2 == nil) {
        [_callingView setLine2:@"正在通话"];
    } else {
        [_callingView setLine3:@"正在通话"];
    }
    [_callingView setNeedsDisplay];
}


-(void)changeColor
{
    _callingView.line2Color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    _callingView.line3Color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    if (_callingView.line3 == nil) {
        _callingView.line3 = @"如果您的手机套餐接听收费\n运营商将会收取接听或漫游费用";

    }
    [_callingView setNeedsDisplay];

    
}

-(void)showOperationInLine3
{
    if (_callMode != CallModeOutgoingCall) {
        
            }
    
    
}



- (void)showHardTrying {
    _callingView.line3 = @"";
    if (_callMode != CallModeOutgoingCall) {
        if (_callingView.line2 == nil) {
            _callingView.line3 = @"正在努力回拨，可能要30秒\n   ";
        } else {
            _callingView.line3 = @"正在努力回拨，可能要30秒\n   ";
        }
    } else {
        if ([_callingView.line2 isEqualToString:NSLocalizedString(@"voip_outgoing_calling", @"")]) {
            _callingView.line2 = NSLocalizedString(@"voip_outgoing_hard_calling", @"");
        } else {
            _callingView.line3 = NSLocalizedString(@"voip_outgoing_hard_calling", @"");
        }
    }
    [_callingView setNeedsDisplay];
}

- (NSString *)translateTickerToTime:(NSInteger) ticker{
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

- (void)hideDisplay {
    [UIView animateWithDuration:0.2 animations:^{
        _callingView.alpha = 0;
    }];
}

- (void)showDisplay {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        _callingView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dealloc {
    
}

@end
