//
//  CallCommercialCell.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/12.
//
//

#import "CallCommercialCell.h"
#import "TPDialerResourceManager.h"
#import "CallCommercialManager.h"
#import "NSString+Draw.h"

@implementation CallCommercialCell {
    udp_response_tData *_model;
    UIColor *_normalBg;
    UIColor *_htBg;
    CGFloat _logoWidth;
    UIFont *_logoFont;
    CGPoint _touchPoint;
    BOOL _touchCanceld;
}

- (id)initWithFrame:(CGRect)frame andModel:(udp_response_tData *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        _normalBg = [UIColor colorWithRed:COLOR_IN_256(0xee) green:COLOR_IN_256(0xee) blue:COLOR_IN_256(0xee) alpha:1];
        _htBg = [UIColor colorWithRed:COLOR_IN_256(0xcc) green:COLOR_IN_256(0xcc) blue:COLOR_IN_256(0xcc) alpha:1];
        _logoWidth = frame.size.height - 2*5;
        self.backgroundColor = _normalBg;
        
        if (_model.brand.length == 2) {
            _logoFont = [UIFont systemFontOfSize:14];
        } else {
            _logoFont = [UIFont systemFontOfSize:12];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //draw logo
    CGRect drawR = CGRectMake(15, 5, _logoWidth, _logoWidth);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, drawR);
    UIColor *textColor = [UIColor colorWithRed:COLOR_IN_256(0x29) green:COLOR_IN_256(0x99) blue:COLOR_IN_256(0xee) alpha:1];
    NSDictionary *textAttr = @{NSFontAttributeName : _logoFont, NSForegroundColorAttributeName : textColor};
    CGSize textSize;
    CGFloat leftGap = 15;
    CGFloat topGap = 5;
    if (_model.brand.length <= 3) {
        textSize = [_model.brand sizeWithFont:_logoFont];
        drawR = CGRectMake(leftGap + (_logoWidth - textSize.width)/2, topGap + (_logoWidth - textSize.height)/2, textSize.width, textSize.height);
        [[_model.brand substringToIndex:2] drawInRect:drawR withAttributes:textAttr withFont:_logoFont UIColor:textColor];
    } else {
        textSize = [[_model.brand substringToIndex:2] sizeWithFont:_logoFont];
        //uper
        drawR = CGRectMake(leftGap + (_logoWidth - textSize.width)/2, topGap + (_logoWidth - textSize.height * 2)/2, textSize.width, textSize.height);
        [_model.brand drawInRect:drawR withAttributes:textAttr withFont:_logoFont UIColor:textColor];
        //lower
        drawR = CGRectMake(leftGap + (_logoWidth - textSize.width)/2, topGap + (_logoWidth - textSize.height * 2)/2 + textSize.height, textSize.width, textSize.height);
        [[_model.brand substringFromIndex:2] drawInRect:drawR withAttributes:textAttr withFont:_logoFont UIColor:textColor];
    }
    
    UIFont *textFont = [UIFont systemFontOfSize:14];
    textSize = [_model.title sizeWithFont:textFont];
    CGFloat textTopGap = (rect.size.height - 2 * textSize.height)/2;
    textColor = [UIColor colorWithRed:COLOR_IN_256(0x33) green:COLOR_IN_256(0x33) blue:COLOR_IN_256(0x33) alpha:1];
    [_model.title drawInRect:CGRectMake(leftGap + _logoWidth + 7.5, textTopGap, textSize.width, textSize.height) withAttributes:@{NSFontAttributeName : textFont, NSForegroundColorAttributeName : textColor} withFont:textFont UIColor:textColor];
    
    CGSize descSize = [_model.desc sizeWithFont:textFont];
    textColor = [UIColor colorWithRed:COLOR_IN_256(0xff) green:COLOR_IN_256(0x66) blue:COLOR_IN_256(0x00) alpha:1];
    [_model.desc drawInRect:CGRectMake(leftGap + _logoWidth + 7.5, textTopGap + textSize.height, descSize.width, descSize.height) withAttributes:@{NSFontAttributeName : textFont, NSForegroundColorAttributeName : textColor} withFont:textFont UIColor:textColor];
    
    NSString *clickText = @"点击查看";
    CGSize clickSize = [clickText sizeWithFont:textFont];
    textColor = [UIColor colorWithRed:COLOR_IN_256(0x99) green:COLOR_IN_256(0x99) blue:COLOR_IN_256(0x99) alpha:1];
    textAttr = @{NSFontAttributeName: textFont, NSForegroundColorAttributeName : textColor};
    [clickText drawInRect:CGRectMake(leftGap + _logoWidth + 7.5 + descSize.width + 5, textTopGap + textSize.height, clickSize.width, clickSize.height) withAttributes:textAttr withFont:_logoFont UIColor:textColor];
    
    //draw a line
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    CGContextMoveToPoint(context, leftGap + _logoWidth + 12.5 + descSize.width, textTopGap + textSize.height + clickSize.height);
    CGContextAddLineToPoint(context, leftGap + _logoWidth + 12.5 + descSize.width + clickSize.width, textTopGap + textSize.height + clickSize.height);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //draw touchpal promotion
    UIImage *proImage = [TPDialerResourceManager getImage:@"tp_promotion@2x.png"];
    [proImage drawInRect:CGRectMake(rect.size.width - 10 - proImage.size.width, 0, proImage.size.width, proImage.size.height)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = _htBg;
    _touchPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint movePoint = [[touches anyObject] locationInView:self];
    if (fabs(movePoint.x - _touchPoint.x) > 20 || fabs(movePoint.y - _touchPoint.y) > 20) {
        _touchCanceld = YES;
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchCanceld) {
        self.backgroundColor = _normalBg;
        _touchCanceld = NO;
        return;
    }
    if (_onClick) {
        _onClick();
    }
    [[CallCommercialManager instance] onClick];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.backgroundColor = _normalBg;
    });
}

@end
