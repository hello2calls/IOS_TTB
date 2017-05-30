//
//  CustomButton.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-11.
//
//

#import "VoipSimpleButton.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "VoipConsts.h"

@implementation VoipSimpleButton {
    BOOL _pressed;
    UIFont *_customFont;
    CGPoint _touchBeginPoint;
    BOOL _touchCanceled;
    BOOL _touchResponding;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgHighlighColor = [TPDialerResourceManager getColorForStyle:@"outgoing_button_highlight_color"];
        self.fontIconHighlightColor = [UIColor colorWithRed:COLOR_IN_256(0x0f) green:COLOR_IN_256(0x74) blue:COLOR_IN_256(0xd9) alpha:1];
        self.scaleRatio = 1.0;
        _customFont = [UIFont fontWithName:@"iPhoneIcon3" size:30*(TPScreenWidth()/414)];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect circleRect = CGRectMake(rect.origin.x+1, rect.origin.y+1, rect.size.width-2, rect.size.width-2);
    UIColor *circleColor;
    if (_borderColor) {
        circleColor = _borderColor;
    } else {
        circleColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    }
    CGContextSetStrokeColorWithColor(context, circleColor.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeEllipseInRect(context, circleRect);
    if (_pressed) {
        CGContextSetFillColorWithColor(context, _bgHighlighColor.CGColor);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextSetFillColorWithColor(context, _fontIconHighlightColor.CGColor);
        CGSize iconSize = [_fontIconTextPressed sizeWithFont:_customFont];
        [_fontIconTextPressed drawInRect:CGRectMake((circleRect.size.width - iconSize.width)/2+1, (circleRect.size.height - iconSize.height)/2+1, iconSize.width, iconSize.height) withFont:_customFont];
    } else {
        CGContextSetFillColorWithColor(context, circleColor.CGColor);
        CGSize iconSize = [_fontIconText sizeWithFont:_customFont];
        [_fontIconText drawInRect:CGRectMake((circleRect.size.width - iconSize.width)/2+1, (circleRect.size.height - iconSize.height)/2+1, iconSize.width, iconSize.height) withFont:_customFont];
    }
    CGContextSetFillColorWithColor(context, circleColor.CGColor);
    CGSize size = [_text sizeWithFont:[UIFont systemFontOfSize:13]];
    [_text drawInRect:CGRectMake((rect.size.width - size.width)/2, rect.size.width + 4, size.width, size.height) withFont:[UIFont systemFontOfSize:13]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchBeginPoint = [[touches anyObject] locationInView:self];
    _touchCanceled = NO;
    if (_persistPressed) {
        _pressed = !_pressed;
        [self setNeedsDisplay];
    } else {
        _pressed = YES;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_persistPressed) {
        if (_pressBlock) {
            _pressBlock();
        }
        return;
    }
    if (_touchResponding) {
        return;
    }
    _touchResponding = YES;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        _pressed = NO;
        [self setNeedsDisplay];
        if (_pressBlock && !_touchCanceled) {
            _pressBlock();
        }
        _touchResponding = NO;
    });
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (abs((int)point.x - (int)_touchBeginPoint.x) > 10) {
        _touchCanceled = YES;
    }
}

- (void)setPressed:(BOOL)pressed {
    _pressed = pressed;
    [self setNeedsDisplay];
}

- (BOOL)isPressed {
    return _pressed;
}
@end
