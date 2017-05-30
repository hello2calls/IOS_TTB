//
//  FindNewsUpdateRecordView.m
//  TouchPalDialer
//
//  Created by lin tang on 16/11/4.
//
//

#import "FindNewsUpdateRecordView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "VerticallyAlignedLabel.h"

@implementation FindNewsUpdateRecordView

@synthesize block;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [ImageUtils colorFromHexString:FEEDS_UPDATE_BG_COLOR andDefaultColor:nil];
        VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc] initWithFrame:self.frame];
        label.verticalAlignment = VerticalAlignmentMiddle;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"上次读到这儿，点击刷新";
        label.textColor = [ImageUtils colorFromHexString:FEEDS_UPDATE_TEXT_COLOR andDefaultColor:nil];
        
        [self addSubview:label];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_NEWS_BORDER_COLOR andDefaultColor:nil] andFromX:5 andFromY:self.frame.size.height  andToX:self.frame.size.width - 10 andToY:self.frame.size.height andWidth:0.3f];
}
@end
