//
//  CallKeyboard.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/21.
//
//

#import "CallKeyboard.h"
#import "TPDialerResourceManager.h"
#import "VoipConsts.h"

@implementation CallKeyboard {
    CGFloat _width;
    CGFloat _hGap;
    CGFloat _vGap;
    CGFloat _hPadding;
    CGFloat _vPadding;
    __strong NSArray *_numbers;
    CGSize _caracterSize;
    UIFont *_font;
    NSString *_touchCharacter;
    __weak id<CallKeyboardDelegate>_delegate;
    __strong UIColor *_hightlightColor;
    __strong UIColor *_animateColor;
    CGFloat _colorAlpha;
    __weak NSTimer *_timer;
    int _tick;
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id<CallKeyboardDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        float scaleRatio = WIDTH_ADAPT;
        _width = (TPScreenHeight() < 500 ? 60 : 65) * scaleRatio;
        _vGap = 10 * scaleRatio;
        _hGap = 10 * scaleRatio;
        _hPadding = (frame.size.width - 3 * _width - 2*_hGap)/2;
        _vPadding = (frame.size.height - 4 * _width - 2*_vGap)/2;
        self.backgroundColor = [UIColor clearColor];
        _numbers = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"*", @"0", @"#"];
        _font = [UIFont systemFontOfSize:(TPScreenHeight() < 500 ? 24 : 30)];
        _caracterSize = [@"1" sizeWithFont:_font];
        _touchCharacter = nil;
        _delegate = delegate;
        _hightlightColor = [UIColor colorWithRed:COLOR_IN_256(0x0f) green:COLOR_IN_256(0x74) blue:COLOR_IN_256(0xd9) alpha:1];;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    CGContextSetLineWidth(context, 1.0f);
    //draw
    CGFloat hstep = _width + _hGap;
    CGFloat vstep = _width + _vGap;
    CGFloat x = 0;
    CGFloat y = 0;
    for (int v =0; v < 4; v++) {
        y = v * vstep + _vPadding;
        for (int h= 0; h < 3; h++) {
            x = h * hstep + _hPadding;
            NSString *caracter = [_numbers objectAtIndex:(v * 3 + h)];
            CGRect circleRect = CGRectMake(x+1, y+1, _width - 2, _width - 2);
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            CGContextStrokeEllipseInRect(context, circleRect);
            if ([_touchCharacter isEqual:caracter]) {
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextFillEllipseInRect(context, circleRect);
                CGContextSetFillColorWithColor(context, _animateColor.CGColor);
            } else {
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            }
            CGFloat cx = 0.0;
            CGFloat cy = 0.0;
            if ([caracter isEqualToString:@"*"]) {
                UIFont *starFont = [UIFont systemFontOfSize:(TPScreenHeight() < 500 ? 40 : 50)];
                CGSize starSize = [caracter sizeWithFont:starFont];
                cx = x + (_width - starSize.width)/2;
                cy = y + (_width - starSize.height)/2 + 7;
                [caracter drawInRect:CGRectMake(cx, cy, starSize.width+10, starSize.height) withFont:starFont];
            } else {
                cx = x + (_width - _caracterSize.width)/2;
                cy = y + (_width - _caracterSize.height)/2;
                [caracter drawInRect:CGRectMake(cx, cy, _caracterSize.width+10, _caracterSize.height) withFont:_font];
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_timer) {
        [_timer invalidate];
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(CGRectMake(_hPadding, _vPadding, self.frame.size.width - 2*_hPadding, self.frame.size.height - 2*_vPadding), point)) {
        CGPoint tranPoint = CGPointMake(point.x - _hPadding, point.y - _vPadding);
        int j = (tranPoint.x)/(_width + _hGap/2);
        if (j>=3) {
            j = 2;
        }
        int i = tranPoint.y/(_width + _vGap/2);
        if (i >= 4) {
            i = 3;
        }
        _touchCharacter = [_numbers objectAtIndex:i*3+j];
        cootek_log(@"touch character: %@", _touchCharacter);
        _colorAlpha = 1;
        _animateColor = _hightlightColor;
        [self setNeedsDisplay];
        [_delegate onKeyPressed:_touchCharacter];

    }
}

- (void)calculateAnimateColor {
    CGFloat r, g, b;
    [_hightlightColor getRed:&r green:&g blue:&b alpha:nil];
    _animateColor = [UIColor colorWithRed:r green:g blue:b alpha:_colorAlpha];
}

- (void)clearTouch {
    _touchCharacter = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchCharacter == nil) {
        return;
    }
    _tick = 1;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateRefresh) userInfo:nil repeats:YES];
}

- (void)animateRefresh {
    _colorAlpha = 1 - sin(M_PI/20*_tick);
    _tick ++;
    [self calculateAnimateColor];
    if (_tick == 11) {
        [_timer invalidate];
        [self clearTouch];
        _timer = nil;
    }
    [self setNeedsDisplay];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)dealloc {
    cootek_log_function;
}

@end
