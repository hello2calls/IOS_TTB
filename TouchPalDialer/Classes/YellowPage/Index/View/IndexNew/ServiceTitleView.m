//
//  SearviceTitleView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/9.
//
//

#import "ServiceTitleView.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "CootekNotifications.h"

@implementation ServiceTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:self.bounds];
    label.textColor = [ImageUtils colorFromHexString:SERVICE_CELL_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    self.title = label;
    
    self.highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:self.highLightView];
    [self setTag:ALL_SERVICE_TAG];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
  
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString: SERVICE_CELL_BG_COLOR andDefaultColor:nil].CGColor);
    CGContextFillRect(context, rect);
    
    //highlight
    if (self.item.isSelected) {
        self.title.textColor = [ImageUtils colorFromHexString:SERVICE_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SERVICE_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil] andFromX:rect.size.width - 1 andFromY:0 andToX:rect.size.width - 1 andToY:rect.size.height andWidth:SERVICE_BORDER_SELECT_WIDTH];
    } else {
        self.title.textColor = [ImageUtils colorFromHexString:SERVICE_CELL_TEXT_COLOR andDefaultColor:nil];
//        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:SERVICE_TITILE_BORDER_COLOR andDefaultColor:nil] andFromX:rect.size.width - 1 andFromY:0.0f andToX:rect.size.width - 1 andToY:rect.size.height andWidth:0.3f];
    }
   
}

- (void) doClick
{
    for (ServiceItem* item in _serviceArray) {
        item.isSelected = NO;
    }
    self.item.isSelected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SELECTED_SERVICE object:nil userInfo:nil];
    
}

- (void) drawView:(ServiceItem*) service {
    
}

- (void) resetWithService:(NSArray*) serviceArray andIndexPath:(NSIndexPath*) indexPath
{
    self.serviceArray = (NSMutableArray *)serviceArray;
    self.item = [serviceArray objectAtIndex:indexPath.section];
    self.title.text = self.item.title;
    
    [self setNeedsDisplay];
}
@end
