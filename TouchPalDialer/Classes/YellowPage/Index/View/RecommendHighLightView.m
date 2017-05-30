//
//  RecommendHighLightView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-7.
//
//

#import <Foundation/Foundation.h>
#import "RecommendHighLightView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "HighLightItem.h"

@implementation RecommendHighLightView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.highLightItem == nil) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, rect);
        return;
    }
    
    CGColorRef bgColor = [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    
    if (self.drawWithLine) {
        CGContextSetRGBStrokeColor(context,1,1,1,1);
    } else {
        CGContextSetRGBStrokeColor(context,0,0,0,0);
    }
    
    if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:self.highLightItem.type]) {
        
        CGSize size = [self.highLightItem.hotKey sizeWithFont:[UIFont boldSystemFontOfSize:NORMAL_TEXT_SIZE]];
        float radius = (size.width > size.height ? size.width + 2 : size.height + 2) / 2;
        
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextAddArc(context, self.drawPoints[0].x, self.drawPoints[0].y, radius, 0, 360, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        
        float x = self.drawPoints[0].x - size.width / 2;
        float y = self.drawPoints[0].y - size.height / 2;
        [self.highLightItem.hotKey drawInRect:CGRectMake(x, y, size.width, size.height) withFont:[UIFont boldSystemFontOfSize:NORMAL_TEXT_SIZE]];
    } else if ([STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:self.highLightItem.type]) {
        if (self.drawPoints) {
            CGFloat radius = (self.drawPoints[1].y - self.drawPoints[0].y) / 2;
            [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:self.drawPoints[0] andPointBottomRight:self.drawPoints[1] andRadius:radius];
            CGContextDrawPath(context, kCGPathFillStroke);
            CGSize size = [self.highLightItem.hotKey sizeWithFont:[UIFont boldSystemFontOfSize:RECTANGLE_TEXT_SIZE]];
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGFloat offsetX = (self.drawPoints[1].x - self.drawPoints[0].x - size.width) / 2;
            [self.highLightItem.hotKey drawInRect:CGRectMake(self.drawPoints[0].x + offsetX, self.drawPoints[0].y + RECTANGLE_MARGIN_TOP / 2, size.width, size.height) withFont:[UIFont boldSystemFontOfSize:RECTANGLE_TEXT_SIZE]];
        }
    } else if ([STYLE_HIGHLIGHT_TYPE_REDPOINT isEqualToString:self.highLightItem.type]) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextAddArc(context, self.drawPoints[0].x, self.drawPoints[0].y, RED_POINT_RADIUS, 0, 360, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    }    
}


@end