//
//  CustomTextView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-10.
//
//

#import "CallingStateTextView.h"

@implementation CallingStateTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.line1Color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.line2Color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50];
    self.line3Color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    return self;
}

- (void)setLine1:(NSString *)line1 line2:(NSString *)line2 line3:(NSString *)line3 {
    self.line1 = line1;
    self.line2 = line2;
    self.line3 = line3;
}

- (void)setColor1:(UIColor *)color1 color2:(UIColor *)color2 color3:(UIColor *)color3 {
    self.line1Color = color1;
    self.line2Color = color2;
    self.line3Color = color3;
}

- (void)setFont1:(int)font1 font2:(int)font2 font3:(int)font3 {
    self.font1Size = font1;
    self.font2Size = font2;
    self.font3Size = font3;
}

- (void)drawRect:(CGRect)rect {
    
//    NSDictionary *tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:_font1Size]};
//    CGSize size1 = [_line1 boundingRectWithSize:CGSizeZero
//                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                        attributes:tdic
//                                           context:nil].size;
//    
//    tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:_font2Size]};
//    CGSize size2 = [_line2 boundingRectWithSize:CGSizeZero
//                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                     attributes:tdic
//                                        context:nil].size;
//    
//    tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:_font3Size]};
//    CGSize size3 = [_line3 boundingRectWithSize:CGSizeZero
//                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                     attributes:tdic
//                                        context:nil].size;
    
    CGSize size1 = [_line1 sizeWithFont:[UIFont systemFontOfSize:_font1Size]];
    CGSize size2 = [_line2 sizeWithFont:[UIFont systemFontOfSize:_font2Size]];
    CGSize size3 = [_line3 sizeWithFont:[UIFont systemFontOfSize:_font3Size]];
    float yGap = 5;
    float totalGap = 0;
    if (TPScreenHeight() < 500) {
        yGap = 5;
    }
    if (_line2) {
        totalGap += yGap;
    }
    if (_line3) {
        totalGap += yGap;
    }
    float y1 = (rect.size.height - totalGap - size1.height - size2.height - size3.height)/2;
    float y2 = y1 + size1.height + yGap;
    float y3 = y2 + size2.height + yGap;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _line1Color.CGColor);
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:_font1Size], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:_line1Color};
//    [_line1 drawInRect:CGRectMake(0, y1, rect.size.width, size1.height) withAttributes:tdic];
//    CGContextSetFillColorWithColor(context, _line2Color.CGColor);
//    tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:_font2Size], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:_line2Color};
//    [_line2 drawInRect:CGRectMake(0, y2, rect.size.width, size2.height) withAttributes:tdic];
//    CGContextSetFillColorWithColor(context, _line3Color.CGColor);
//    tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:_font3Size], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:_line3Color};
//    [_line3 drawInRect:CGRectMake(0, y3, rect.size.width, size3.height) withAttributes:tdic];
    [_line1 drawInRect:CGRectMake(0, y1, rect.size.width, size1.height) withFont:[UIFont systemFontOfSize:_font1Size] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
    UIColor *tempColor = _line2Color;
    if (_line3 == nil) {
        tempColor = _line3Color;
    }
    CGContextSetFillColorWithColor(context, tempColor.CGColor);
    [_line2 drawInRect:CGRectMake(0, y2, rect.size.width, size2.height) withFont:[UIFont systemFontOfSize:_font2Size] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
    CGContextSetFillColorWithColor(context, _line3Color.CGColor);
    size3.height+= 25;
    [_line3 drawInRect:CGRectMake(0, y3, rect.size.width, size3.height) withFont:[UIFont systemFontOfSize:_font3Size] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
}
@end
