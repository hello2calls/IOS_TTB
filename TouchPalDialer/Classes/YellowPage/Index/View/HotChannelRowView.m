//
//  HotChannelRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/12.
//
//

#import "HotChannelRowView.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "AllServiceViewController.h"
#import "TouchPalDialerAppDelegate.h"

@implementation HotChannelRowView


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        VerticallyAlignedLabel* title = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(20, 0, 100, self.frame.size.height)];
        title.textColor = [ImageUtils colorFromHexString:HOT_CHANNEL_TITLE_TEXT_COLOR andDefaultColor:nil];
        title.font = [UIFont systemFontOfSize:HOT_CHANNEL_TITLE_TEXT_SIZE];
        title.textAlignment = NSTextAlignmentLeft;
        title.verticalAlignment = VerticalAlignmentMiddle;
        title.text = @"热门频道";
        [self addSubview:title];
        
        
//        VerticallyAlignedLabel* showAll = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(120, 0, self.frame.size.width - 160, self.frame.size.height)];
//        
//        showAll.textColor = [ImageUtils colorFromHexString:HOT_CHANNEL_ALL_TEXT_COLOR andDefaultColor:nil];
//        showAll.font = [UIFont systemFontOfSize:HOT_CHANNEL_TITLE_TEXT_SIZE];
//        showAll.textAlignment = NSTextAlignmentRight;
//        showAll.text = @"查看全部";
//        showAll.verticalAlignment = VerticalAlignmentMiddle;
//        [self addSubview:showAll];
        
//        VerticallyAlignedLabel* arrow = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 40, 0, 20, self.frame.size.height)];
//        
//        arrow.textColor = [ImageUtils colorFromHexString:HOT_CHANNEL_ALL_TEXT_COLOR andDefaultColor:nil];
//        arrow.font = [UIFont fontWithName:IPHONE_ICON_2 size:HOT_CHANNEL_TITLE_TEXT_SIZE];
//        arrow.text = @"n";
//        arrow.textAlignment = NSTextAlignmentRight;
//        arrow.verticalAlignment = VerticalAlignmentMiddle;
//        [self addSubview:arrow];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:HOT_CHANNEL_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:HOT_CHANNEL_BG_COLOR andDefaultColor:nil].CGColor);
    }
    CGContextFillRect(context, rect);
}

- (void) doClick
{
    AllServiceViewController* controller = [[AllServiceViewController alloc] init];
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT + TPHeaderBarHeightDiff());
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}

@end
