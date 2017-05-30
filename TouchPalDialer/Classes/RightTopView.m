//
//  RightTopView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/16.
//
//

#import "RightTopView.h"
#import "IndexConstant.h"
#import "PublicNumberMessageView.h"
#import "ImageUtils.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"

@interface RightTopView()
{
    VerticallyAlignedLabel* arrow;
}

@end
@implementation RightTopView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        VerticallyAlignedLabel* iconArrow = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 30, 0, 30, self.frame.size.height)];
        iconArrow.verticalAlignment = VerticalAlignmentMiddle;
        iconArrow.font = [UIFont fontWithName:IPHONE_ICON_2 size:FIND_HEADER_CONTENT_SIZE];
        iconArrow.text = @"n";
        arrow = iconArrow;
        [self addSubview:arrow];
        
        self.highlightView = [[RightTopHighLightView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        [self addSubview:self.highlightView];
        
        self.content = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - iconArrow.frame.size.width - 10, self.frame.size.height)];
        self.content.textAlignment = NSTextAlignmentRight;
        self.content.verticalAlignment = VerticalAlignmentMiddle;
        self.content.font = [UIFont systemFontOfSize:FIND_HEADER_CONTENT_SIZE];
        [self addSubview:self.content];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void) drawView:(RightTopItem *)item
{
    CGSize size = [PublicNumberMessageView getSizeByText:item.text andUIFont:self.content.font andWidth:self.content.frame.size.width];
    self.highlightView.frame = CGRectMake(self.highlightView.frame.origin.x, self.highlightView.frame.origin.y, self.frame.size.width - size.width - 50, self.highlightView.frame.size.height);
    self.content.frame = CGRectMake(self.highlightView.frame.origin.x + self.highlightView.frame.size.width + 10, self.content.frame.origin.y, size.width, self.content.frame.size.height);
    
    if ([item isValid]) {
        arrow.hidden = NO;
    } else {
        arrow.hidden = YES;
    }
    [self.highlightView drawView:item];
    self.content.text = item.text;
    self.item = item;
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.pressed && [self.item isValid]) {
        self.content.textColor = [ImageUtils colorFromHexString:RIGHT_TOP_VIEW_TEXT_COLOR andDefaultColor:nil];
        arrow.textColor = [ImageUtils colorFromHexString:RIGHT_TOP_VIEW_TEXT_COLOR andDefaultColor:nil];
    } else {
        self.content.textColor = [ImageUtils colorFromHexString:RIGHT_TOP_VIEW_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
        arrow.textColor = [ImageUtils colorFromHexString:RIGHT_TOP_VIEW_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
    }
}

- (void) doClick {
    if ([self.item isValid]) {
        [self.item.ctUrl startWebView];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_TOP_RIGHT_ITEM kvs:Pair(@"action", @"selected"), Pair(@"url", self.item.ctUrl.url), Pair(@"text", self.item.text), nil];
    }
}
@end
