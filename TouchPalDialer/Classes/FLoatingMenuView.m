//
//  FLoatingMenuView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/1/27.
//
//

#import "FLoatingMenuView.h"
#import "IndexConstant.h"
#import "ImageUtils.h"


#define COMMEN_HEIGHT 50
#define MENUS_WIDTH 180


@implementation FLoatingMenuView



- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.hidden) {
        // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
        CGFloat radius = COMMEN_HEIGHT / 2;
        CGFloat startX = 0;
        CGFloat startY = rect.origin.y;
        
        CGFloat width = MENUS_WIDTH;
        CGFloat height = COMMEN_HEIGHT;
        CGContextRef context = UIGraphicsGetCurrentContext();
        // 移动到初始点
        CGContextMoveToPoint(context, startX + radius, startY);
        
        // 绘制第1条线和第1个1/4圆弧
        CGContextAddLineToPoint(context, startX + width - radius, startY);
        CGContextAddArc(context, startX + width - radius, startY + radius, radius, -0.5 * M_PI, 0.0, 0);
        
        // 绘制第2条线和第2个1/4圆弧
        CGContextAddLineToPoint(context, startX + width, startY + height - radius);
        CGContextAddArc(context, startX + width - radius, startY + height - radius, radius, 0.0, 0.5 * M_PI, 0);
        
        // 绘制第3条线和第3个1/4圆弧
        CGContextAddLineToPoint(context, startX + radius, startY + height);
        CGContextAddArc(context, startX + radius, startY + height - radius, radius, 0.5 * M_PI, M_PI, 0);
        
        // 绘制第4条线和第4个1/4圆弧
        CGContextAddLineToPoint(context, startX, startY + radius);
        CGContextAddArc(context, startX + radius, startY + radius, radius, M_PI, 1.5 * M_PI, 0);
        
        // 闭合路径
        CGContextClosePath(context);
        
        // 填充背景色
        if (self.isPressed) {
            CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:FLOATING_MENUS_COLOR andDefaultColor:nil].CGColor);
        } else {
            CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:FLOATING_MENUS_COLOR andDefaultColor:nil].CGColor);
        }
        CGContextDrawPath(context, kCGPathFill);
    }
}


@end
