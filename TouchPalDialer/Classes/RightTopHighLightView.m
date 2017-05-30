//
//  RightTopHighLightView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/16.
//
//

#import "RightTopHighLightView.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "PublicNumberMessageView.h"
#import "VerticallyAlignedLabel.h"

@interface RightTopHighLightView()
{
    RightTopItem* rightTopItem;
}
@end
@implementation RightTopHighLightView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef bgColor = [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    
    CGContextSetRGBStrokeColor(context,0,0,0,0);
    
    
    if ([STYLE_HIGHLIGHT_TYPE_REDPOINT isEqualToString:rightTopItem.highlightItem.type])
    {
        CGContextSetLineWidth(context, 1);
        CGContextAddArc(context, self.frame.origin.x + self.frame.size.width - RED_POINT_RADIUS, self.frame.origin.y + self.frame.size.height / 2, RED_POINT_RADIUS, 0, 360, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    } else if ([STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:rightTopItem.highlightItem.type]){
        
        CGSize size = [PublicNumberMessageView getSizeByText:rightTopItem.highlightItem.hotKey andUIFont:[UIFont boldSystemFontOfSize:RECTANGLE_TEXT_SIZE] andWidth:self.frame.size.width];
        CGRect rect = CGRectMake(self.frame.size.width - size.width - 10, (self.frame.size.height - size.height) / 2 - 1, size.width + 10, size.height + 2);
        
        CGFloat radius = rect.size.height / 2;
        CGPoint topLeft = CGPointMake(rect.origin.x, rect.origin.y);
        CGPoint bottomRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:topLeft andPointBottomRight:bottomRight andRadius:radius];
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [rightTopItem.highlightItem.hotKey drawInRect:CGRectMake(topLeft.x + 5, topLeft.y, size.width, size.height) withFont:[UIFont boldSystemFontOfSize:RECTANGLE_TEXT_SIZE]];
    }
}

-(void) drawView:(RightTopItem *)item
{
    rightTopItem = item;
    [self setNeedsDisplay];
}
@end
