//
//  ServiceHeaderView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/10.
//
//

#import "ServiceHeaderView.h"
#import "ImageUtils.h"
#import "VerticallyAlignedLabel.h"
#import "IndexConstant.h"

@implementation ServiceHeaderView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = [[VerticallyAlignedLabel alloc]initWithFrame:self.bounds];
        self.title.textColor = [ImageUtils colorFromHexString:SERVICE_TITLE_TEXT_COLOR andDefaultColor:nil];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.verticalAlignment = VerticalAlignmentMiddle;
        self.title.userInteractionEnabled = YES;
        [self addSubview:self.title];
        [self setTag:SERVICE_HEADER_TAG];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat fromY = rect.size.height / 2;
    CGFloat toY = rect.size.height / 2;
    CGFloat fromX = rect.origin.x + SERVICE_BORDER_MARGIN;
    CGFloat toX = fromX + rect.size.width / 2 - SERVICE_BORDER_MARGIN - SERVICE_TITLE_WIDTH / 2;
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SERVICE_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY andToX:toX andToY:toY andWidth:0.5f];
   
    fromX = toX + SERVICE_TITLE_WIDTH;
    toX = rect.origin.x + rect.size.width - SERVICE_BORDER_MARGIN;
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SERVICE_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY andToX:toX andToY:toY andWidth:0.5f];
   
}

- (void) drawTitle:(NSString *)title
{
    self.title.text = title;
    [self setNeedsDisplay];
}

@end
