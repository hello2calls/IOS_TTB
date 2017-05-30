//
//  CallKeyboardDisplay.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/22.
//
//

#import "CallKeyboardDisplay.h"
#import "VoipConsts.h"

@implementation CallKeyboardDisplay {
    UILabel *_inputLabel;
    CallKeyboard *_keyboard;
    NSMutableString *_input;
    __weak id<CallKeyboardDelegate> _delegate;
}
- (id)initWithHolderView:(UIView *)view andDelegate:(id<CallKeyboardDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _input = [[NSMutableString alloc] init];
        
        CGFloat y = 80*WIDTH_ADAPT;
        CGFloat labelHeight = 40 * WIDTH_ADAPT;
        _inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, y, TPScreenWidth() - 60, labelHeight)];
        _inputLabel.backgroundColor = [UIColor clearColor];
        _inputLabel.textAlignment = NSTextAlignmentCenter;
        _inputLabel.font = [UIFont systemFontOfSize:30];
        _inputLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _inputLabel.textColor = [UIColor whiteColor];
        [view addSubview:_inputLabel];
        
        y += labelHeight;
        CGFloat bottomGap = (TPScreenHeight() < 500 ? 120 : 140)*WIDTH_ADAPT;
        CGFloat height = TPScreenHeight() - bottomGap - y;
        CGFloat width = TPScreenWidth() - 2 * 50*WIDTH_ADAPT;
        CallKeyboard *keyboard = [[CallKeyboard alloc] initWithFrame:CGRectMake(50*WIDTH_ADAPT, y, width, height) andDelegate:self];
        _keyboard = keyboard;
        [view addSubview:_keyboard];
        _inputLabel.alpha = 0;
        _keyboard.alpha = 0;
    }
    return self;
}

- (void)onKeyPressed:(NSString *)key {
    [_input appendString:key];
    _inputLabel.text = _input;
    [_delegate onKeyPressed:key];
}

- (void)hideDisplay {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveLinear animations:^{
        _inputLabel.alpha = 0;
        _keyboard.alpha = 0;
    } completion: nil];
}

- (void)showDisplay {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        _inputLabel.alpha = 1;
        _keyboard.alpha = 1;
    } completion: nil];
}

- (void)dealloc {

}
@end
