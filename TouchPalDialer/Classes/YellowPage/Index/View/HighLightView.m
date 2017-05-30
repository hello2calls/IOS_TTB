//
//  HighLightView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-17.
//
//

#import <Foundation/Foundation.h>
#import "HighLightView.h"
#import "HighLightItem.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "VerticallyAlignedLabel.h"

@interface HighLightView()
{
    VerticallyAlignedLabel* itemLabel;

}
@end
@implementation HighLightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];

    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(frame.size.width - 32, -5, 37, 37)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.font = [UIFont boldSystemFontOfSize:9];
    label.userInteractionEnabled = YES;
    label.hidden = YES;
    [self addSubview:label];
    itemLabel = label;
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.highLightItem == nil) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, rect);
        itemLabel.text = @"";
        return;
    }
    
    CGColorRef bgColor = [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    
    if (self.drawWithLine) {
        CGContextSetRGBStrokeColor(context,1,1,1,1);
    } else {
        CGContextSetRGBStrokeColor(context,0,0,0,0);
    }
    
    itemLabel.hidden = YES;
    if ([STYLE_HIGHLIGHT_TYPE_REDPOINT isEqualToString:self.highLightItem.type]) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextAddArc(context, self.drawPoints[0].x, self.drawPoints[0].y, RED_POINT_RADIUS, 0, 360, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    } else if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:self.highLightItem.type] || [STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:self.highLightItem.type]) {
        CGContextMoveToPoint(context, rect.size.width - 35, 0);
        CGContextAddLineToPoint(context, rect.size.width - 18, 0);
        CGContextAddLineToPoint(context, rect.size.width, 18);
        CGContextAddLineToPoint(context, rect.size.width, 35);
        CGContextAddLineToPoint(context, rect.size.width - 35, 0);
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_ROTATE_BG_COLOR andDefaultColor:nil].CGColor);
        CGContextFillPath(context);
        itemLabel.text = self.highLightItem.hotKey;
        itemLabel.textAlignment = NSTextAlignmentCenter;
        itemLabel.transform=CGAffineTransformMakeRotation(M_PI/4);
        itemLabel.hidden = NO;
        [itemLabel setNeedsDisplay];
    }
}


- (void)drawView:(HighLightItem*)item andPoints:(CGPoint[])points withLine:(BOOL)drawLine
{
    if([item.type isEqualToString: STYLE_HIGHLIGHT_TYPE_REDPOINT] || [self checkIfExpriedWithItem:item]) {
        self.highLightItem = item;
    }
    self.drawPoints = points;
    self.drawWithLine = drawLine;
    [self setNeedsDisplay];
}

- (BOOL)checkIfExpriedWithItem:(HighLightItem *)item {
    if (item != nil && item.highlightStart.integerValue > 0) {
        NSDate *dateNow = [NSDate date];
        NSDate *expiredData = [NSDate dateWithTimeIntervalSince1970:item.highlightStart.integerValue+item.highlightDuration.integerValue];
        return([expiredData compare:dateNow] == NSOrderedDescending);
    }
    return YES;
}

- (void)dealloc
{
    free(self.drawPoints);
    self.drawPoints = nil;
}

@end