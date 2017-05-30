//
//  CategoryContentCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#import <Foundation/Foundation.h>
#import "CategoryContentCellView.h"
#import "CategoryItem.h"
#import "VerticallyAlignedLabel.h"
#import "HighLightView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "CTUrl.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "HighLightItem.h"
#import "UIDataManager.h"

@interface CategoryContentCellView(){
    NSInteger itemType;
    NSInteger rowIndex;
    NSInteger columnIndex;
    HighLightView* highLightView;
}
@property(nonatomic,retain) CategoryItem* categoryData;
@property(nonatomic,retain) VerticallyAlignedLabel* itemLabel;

@end

@implementation CategoryContentCellView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:self.bounds];
    label.textColor = [ImageUtils colorFromHexString:CATEGORY_ITEM_CONTENT_CELL_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    self.itemLabel = label;
    rowIndex = -1;
    
    highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CATEGORY_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    BOOL topLine = NO;
    CGFloat fromY = 0;
    CGFloat toY = rect.size.height;
    
    switch (itemType) {
        case CATEGORY_ITEM_CONTENT_TYPE_NORMAL:
            topLine = YES;
            break;
        case CATEGORY_ITEM_CONTENT_TYPE_BOTTOM:
            topLine = NO;
            break;
        default:
            break;
    }
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:rect.size.height andToX:rect.size.width andToY:rect.size.height andWidth:CATEGORY_BORDER_WIDTH];
    
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:fromY andToX:0.0f andToY:toY andWidth:CATEGORY_BORDER_WIDTH];
    
    if (topLine) {
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:0.0f andToX:rect.size.width andToY:0.0f andWidth:CATEGORY_BORDER_WIDTH];
    }
    self.itemLabel.text = self.categoryData.title;
    [self.itemLabel setNeedsDisplay];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.categoryData == nil) {
        self.pressed = NO;
        return;
    }
    [super touchesBegan:touches withEvent:event];
}

- (void) doClick {
    [self.categoryData startWebView];
    [[UIDataManager instance] addTrack:self.categoryData];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CATEGORY_CONTENT_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title", self.categoryData.title), Pair(@"url", self.categoryData.ctUrl.url), nil];
}

- (void) drawView:(CategoryItem*) categoryItem andRoxIndex:(NSInteger)rowIdx
{
    
    if ([categoryItem shouldShowHighLight]) {
        [self drawHighLightView:categoryItem.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }

    if (rowIdx == 0) {
        itemType = CATEGORY_ITEM_CONTENT_TYPE_NORMAL;
    } else {
        itemType = CATEGORY_ITEM_CONTENT_TYPE_BOTTOM;
    }
    if (categoryItem.subTitle != nil && categoryItem.subTitle.length > 0) {
        self.itemLabel.textColor = [ImageUtils colorFromHexString:CATEGORY_ITEM_CONTENT_CELL_ALL_TEXT_COLOR andDefaultColor:nil];
    } else {
        self.itemLabel.textColor = [ImageUtils colorFromHexString:CATEGORY_ITEM_CONTENT_CELL_TEXT_COLOR andDefaultColor:nil];
    }
    self.itemLabel.text = categoryItem.title;
    [self setNeedsDisplay];
}


- (void) drawHighLightView:(HighLightItem*)highLightItem
{
    if (highLightItem && highLightItem.type.length > 0) {
        if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:highLightItem.type]
            || [STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:highLightItem.type]) {
            [highLightView drawView:highLightItem andPoints:nil withLine:YES];
        } else {
            [highLightView drawView:nil andPoints:nil withLine:NO];
        }
    } else {
        [highLightView drawView:nil andPoints:nil withLine:NO];
    }
}


- (void) resetWithCategoryData:(CategoryItem*)data andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx
{
    self.categoryData = data;
    rowIndex = rowIdx;
    columnIndex = columnIdx;
}
@end
