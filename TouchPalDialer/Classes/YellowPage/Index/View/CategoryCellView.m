//
//  CategoryCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import <Foundation/Foundation.h>
#import "CategoryCellView.h"
#import "TPDialerResourceManager.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UIDataManager.h"
#import "CTUrl.h"
#import "YellowPageWebViewController.h"
#import "YellowPageMainTabController.h"
#import "HighLightView.h"
#import "HighLightItem.h"
#import "UpdateService.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"

@interface CategoryCellView(){
    NSInteger itemType;
    NSInteger rowIndex;
    NSInteger columnIndex;
    HighLightView* highLightView;

}
@property(nonatomic,retain) SectionCategory* categoryData;
@property(nonatomic,retain) VerticallyAlignedLabel* itemLabel;
@end
@implementation CategoryCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:self.bounds];
    label.textColor = [ImageUtils colorFromHexString:CATEGORY_CELL_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    self.itemLabel = label;
    
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
    
    BOOL bottomLine = NO;
    CGFloat fromY = 0;
    CGFloat toY = 0;
    
    switch (itemType) {
        case CATEGORY_ITEM_TYPE_NONE:
            return;
        case CATEGORY_ITEM_TYPE_NORMAL:
        case CATEGORY_ITEM_TYPE_END:
        case CATEGORY_ITEM_TYPE_BOTTOM_NORMAL:
            fromY = CATEGORY_BORDER_MARGIN;
            toY = rect.size.height - CATEGORY_BORDER_MARGIN;
            break;
        case CATEGORY_ITEM_TYPE_TOP_LEFT:
            fromY = CATEGORY_BORDER_MARGIN;
            toY = rect.size.height;
            bottomLine = YES;
            break;
        case CATEGORY_ITEM_TYPE_TOP_NORMAL:
            fromY = CATEGORY_BORDER_MARGIN;
            toY = rect.size.height - CATEGORY_BORDER_MARGIN;
            bottomLine = YES;
            break;
        case CATEGORY_ITEM_TYPE_MIDDLE_LEFT:
            fromY = 0;
            toY = rect.size.height;
            bottomLine = YES;
            break;
        case CATEGORY_ITEM_TYPE_MIDDLE_NORMAL:
            fromY = CATEGORY_BORDER_MARGIN;
            toY = rect.size.height - CATEGORY_BORDER_MARGIN;
            bottomLine = YES;
            break;
        case CATEGORY_ITEM_TYPE_BOTTOM_LEFT:
            fromY = 0;
            toY = rect.size.height - CATEGORY_BORDER_MARGIN;
            break;
        default:
            break;
    }
  
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:fromY andToX:0.0f andToY:toY andWidth:CATEGORY_BORDER_WIDTH];
    
    if (bottomLine) {
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:rect.size.height andToX:rect.size.width andToY:rect.size.height andWidth:CATEGORY_BORDER_WIDTH];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (itemType == CATEGORY_ITEM_TYPE_END || itemType == CATEGORY_ITEM_TYPE_NONE) {
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) doClick {
    CategoryItem* item = [self getCategoryItem];
    [item startWebView];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CATEGORY_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title", item.title), Pair(@"url", item.ctUrl.url), nil];
}

- (CategoryItem*) getCategoryItem
{
    return [self.categoryData.items objectAtIndex:rowIndex * CATEGORY_COLUMN_COUNT + columnIndex];
}

- (void) resetWithCategoryData:(SectionCategory *)cData andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx
{
    self.categoryData = cData;
    rowIndex = rowIdx;
    columnIndex = columnIdx;
}

- (void) drawView:(CategoryItem*)categoryItem
{
    if ([categoryItem shouldShowHighLight]) {
        [self drawHighLightView:categoryItem.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
    [self setType];
    [self setNeedsDisplay];
}

- (void) drawHighLightView:(HighLightItem*)highLightItem
{
    if (highLightItem && highLightItem.type.length > 0) {
        if ([STYLE_HIGHLIGHT_TYPE_REDPOINT isEqualToString:highLightItem.type]) {
            
            CGPoint* points = (CGPoint*)malloc(1*sizeof(CGPoint));
            points[0] = CGPointMake(self.bounds.size.width * 3 / 4, self.bounds.size.height / 3 - RED_POINT_HEIGHT_OFFSET);
            [highLightView drawView:highLightItem andPoints:points withLine:NO];
        } else if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:highLightItem.type]
              || [STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:highLightItem.type]) {
            CGPoint* points = (CGPoint*)malloc(4*sizeof(CGPoint));
            points[0] = CGPointMake(self.bounds.size.width, 0);
            [highLightView drawView:highLightItem andPoints:points withLine:YES];
        } else {
            [highLightView drawView:nil andPoints:nil withLine:NO];
        }
        
    } else {
        [highLightView drawView:nil andPoints:nil withLine:NO];
    }
}

- (void) setType
{
    CategoryItem* item = [self getCellItem];
    if (item == nil) {
        self.itemLabel.text = @"";
        if (rowIndex * CATEGORY_COLUMN_COUNT + columnIndex == self.categoryData.items.count) {
            itemType = CATEGORY_ITEM_TYPE_END;
        } else {
            itemType = CATEGORY_ITEM_TYPE_NONE;
        }
    } else {
        self.itemLabel.text = item.title;
        if (self.categoryData.isOpened) {
            if (rowIndex == 0) {
                if (columnIndex == 0) {
                    itemType = CATEGORY_ITEM_TYPE_TOP_LEFT;
                } else {
                    itemType = CATEGORY_ITEM_TYPE_TOP_NORMAL;
                }
            } else if(rowIndex == [self.categoryData getRowCount] - 1) {
                if (columnIndex == 0) {
                    itemType = CATEGORY_ITEM_TYPE_BOTTOM_LEFT;
                } else {
                    itemType = CATEGORY_ITEM_TYPE_BOTTOM_NORMAL;
                }
            } else {
                if (columnIndex == 0) {
                    itemType = CATEGORY_ITEM_TYPE_MIDDLE_LEFT;
                } else {
                    itemType = CATEGORY_ITEM_TYPE_MIDDLE_NORMAL;
                }
            }
        } else {
            itemType = CATEGORY_ITEM_TYPE_NORMAL;
        }
    }
}


- (CategoryItem*) getCellItem
{
    if (CATEGORY_COLUMN_COUNT * rowIndex + columnIndex < self.categoryData.items.count) {
        return [self.categoryData.items objectAtIndex:CATEGORY_COLUMN_COUNT * rowIndex + columnIndex];
    }
    return nil;
}

@end
