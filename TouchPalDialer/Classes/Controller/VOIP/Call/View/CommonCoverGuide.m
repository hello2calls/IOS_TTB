//
//  CommonCoverGuide.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/24.
//
//

#import "CommonCoverGuide.h"
#import "VoipConsts.h"

@implementation CommonCoverGuide {
    NSString *_text;
    CGPoint _point;
    CGSize _textSize;
    CGFloat _rightWidth;
}

- (id)initWithBardisplay:(NSString *)text andGuidePoint:(CGPoint)point {
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        _text = text;
        _point = point;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _textSize = [_text sizeWithFont:[UIFont systemFontOfSize:17*WIDTH_ADAPT]];
        _rightWidth = ((TPScreenWidth() - _point.x) / TPScreenWidth()) * _textSize.width;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGFloat x = _point.x;
    CGFloat y = _point.y;
    CGContextMoveToPoint(context, x, y);
    x += 12;
    y -= 10;
    CGContextAddLineToPoint(context, x, y);
    x += _rightWidth;
    CGContextAddLineToPoint(context, x, y);
    y -= (_textSize.height + 20);
    CGContextAddLineToPoint(context, x, y);
    x -= (_textSize.width + 20);
    CGFloat rectx = x + 10;
    CGFloat recty = y + 10;
    CGContextAddLineToPoint(context, x, y);
    y += (_textSize.height + 20);
    CGContextAddLineToPoint(context, x, y);
    x = _point.x;
    y = _point.y - 10;
    CGContextAddLineToPoint(context, x, y);
    CGContextAddLineToPoint(context, _point.x, _point.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [_text drawInRect:CGRectMake(rectx, recty, _textSize.width, _textSize.height) withFont:[UIFont systemFontOfSize:17*WIDTH_ADAPT]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}

@end
