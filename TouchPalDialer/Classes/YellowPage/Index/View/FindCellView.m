//
//  FavouriteCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-6-25.
//
//

#import <Foundation/Foundation.h>
#import "FindCellView.h"
#import "SectionFind.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "CTUrl.h"
#import "VerticallyAlignedLabel.h"
#import "UserDefaultKeys.h"
#import "HighLightView.h"
#import "HighLightItem.h"
#import "UIDataManager.h"
#import "CategoryItem.h"
#import "IconFontImageView.h"

@interface FindCellView()
{
    NSInteger itemType;
    HighLightView* highLightView;
    NSString* url;
}
@property(nonatomic,retain) SectionFind* findData;;
@property(nonatomic,assign) NSInteger rowIndex;
@property(nonatomic,assign) NSInteger columnIndex;
@property(nonatomic,retain) VerticallyAlignedLabel* titleLabel;
@property(nonatomic,retain) VerticallyAlignedLabel* subTitleLabel;
@property(nonatomic, retain) IconFontImageView* iconFontImageView;
@end

@implementation FindCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, self.bounds.origin.y + INDEX_ROW_HEIGHT_FIND - FIND_ROW_HEIGHT_TITLE - FIND_MARGIN_BOTTOM, frame.size.width, FIND_ROW_HEIGHT_SUB_TITLE)];
    label.textColor = [ImageUtils colorFromHexString:FIND_CELL_SUB_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:FIND_SUB_TITLE_SIZE];
    [self addSubview:label];
    self.subTitleLabel = label;    
    VerticallyAlignedLabel* titleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, self.bounds.origin.y + INDEX_ROW_HEIGHT_FIND - FIND_ROW_HEIGHT_TITLE - FIND_ROW_HEIGHT_SUB_TITLE - FIND_MARGIN_BOTTOM, frame.size.width, FIND_ROW_HEIGHT_TITLE)];
    titleLabel.textColor = [ImageUtils colorFromHexString:FIND_CELL_TITLE_TEXT_COLOR andDefaultColor:nil];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.verticalAlignment = VerticalAlignmentMiddle;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.font = [UIFont systemFontOfSize:FIND_TITLE_SIZE];
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    int height = INDEX_ROW_HEIGHT_FIND - FIND_ROW_HEIGHT_TITLE - FIND_ROW_HEIGHT_SUB_TITLE - FIND_MARGIN_BOTTOM;
    IconFontImageView *iconFontImageView = [[IconFontImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    self.iconFontImageView = iconFontImageView;
    [self addSubview:iconFontImageView];
    
    highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CategoryItem* item = [self getFindItem];
    if (!item) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:FIND_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:FIND_CELL_TITLE_TEXT_COLOR andDefaultColor:nil].CGColor);
    [self.titleLabel setNeedsDisplay];
    [self.subTitleLabel setNeedsDisplay];
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:0.0f andToX:rect.size.width andToY:0.0f andWidth:FIND_BORDER_WIDTH];
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:rect.size.height andToX:rect.size.width andToY:rect.size.height andWidth:FIND_BORDER_WIDTH];
    
    CGFloat fromY = 0;
    CGFloat toY = 0;
    
    switch (itemType) {
        case FIND_ITEM_TYPE_NONE:
            toY = rect.size.height;
            break;
        case FIND_ITEM_TYPE_NORMAL:
            fromY = 0;
            toY = rect.size.height;
            break;
        default:
            return;
    }
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:fromY andToX:0.0f andToY:toY andWidth:FIND_BORDER_WIDTH];
}

- (void) doClick {
    CategoryItem* item = [self getFindItem];
    if (item) {
        [item startWebView];
        [[UIDataManager instance] addTrack:item];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_ITEM kvs:Pair(@"action", @"selected"),Pair(@"title", item.title), nil];
    }
}

- (void) drawView:(CategoryItem*) item
{
    self.titleLabel.text = item.title;
    self.subTitleLabel.text = item.subTitle;
    if ([item shouldShowHighLight]) {
        [self drawHighLightView:item.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
    [self.iconFontImageView resetFrameWithData:item];
    [self setType];
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

- (void) resetWithFindData:(SectionFind*)data andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx
{
    self.findData = data;
    self.rowIndex = rowIdx;
    self.columnIndex = columnIdx;
}

- (void) setType
{
    if (self.columnIndex + self.rowIndex * FIND_COLUMN_COUNT == self.findData.items.count - 1) {
        itemType = FIND_ITEM_TYPE_NONE;
    } else {
        itemType = FIND_ITEM_TYPE_NORMAL;
    }
}

- (CategoryItem*) getFindItem
{
    if ((FIND_COLUMN_COUNT * self.rowIndex + self.columnIndex) < self.findData.items.count) {
        return [self.findData.items objectAtIndex:FIND_COLUMN_COUNT * self.rowIndex + self.columnIndex];
    }
    return nil;
}

@end