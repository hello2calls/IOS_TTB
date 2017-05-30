//
//  NewCategoryCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-2.
//
//

#import <Foundation/Foundation.h>
#import "NewCategoryCellView.h"
#import "NewCategoryItem.h"
#import "VerticallyAlignedLabel.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "DialerUsageRecord.h"
#import "CTUrl.h"
#import "TPAnalyticConstants.h"
#import "SectionNewCategory.h"
#import "SubCategoryItem.h"
#import "CategoryItem.h"
#import "CategoryExtendViewController.h"
#import "UIDataManager.h"
#import "YellowPageMainTabController.h"
#import "HighLightItem.h"
#import "HighLightView.h"
#import "TouchPalDialerAppDelegate.h"
#import "AllServiceViewController.h"
#import "IconFontImageView.h"

@interface NewCategoryCellView()
{
    NSInteger itemType;
    HighLightView* highLightView;
    NSString* url;
}
@property(nonatomic,retain) SectionNewCategory* categoryData;
@property(nonatomic,assign) NSInteger rowIndex;
@property(nonatomic,assign) NSInteger columnIndex;
@property(nonatomic,retain) VerticallyAlignedLabel* titleLabel;
@property(nonatomic,retain) VerticallyAlignedLabel* subTitleLabel;
@property(nonatomic,retain) UIImage* icon;
@property(nonatomic, retain) IconFontImageView* iconFontImageView;
@property(nonatomic, retain) NSString* font;
@property(nonatomic, retain) NSString* fontColor;

@end

@implementation NewCategoryCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, self.bounds.origin.y + INDEX_ROW_HEIGHT_NEW_CATEGORY-NEW_CATEGORY_ROW_HEIGHT_TITLE - NEW_CATEGORY_MARGIN_BOTTOM, frame.size.width, NEW_CATEGORY_ROW_HEIGHT_SUB_TITLE)];
    label.textColor = [ImageUtils colorFromHexString:NEW_CATEGORY_CELL_SUB_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:NEW_CATEGORY_SUB_TITLE_SIZE];
    [self addSubview:label];
    self.subTitleLabel = label;
    
    VerticallyAlignedLabel* titleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, self.bounds.origin.y + INDEX_ROW_HEIGHT_NEW_CATEGORY - NEW_CATEGORY_ROW_HEIGHT_TITLE - NEW_CATEGORY_ROW_HEIGHT_SUB_TITLE - NEW_CATEGORY_MARGIN_BOTTOM, frame.size.width, NEW_CATEGORY_ROW_HEIGHT_TITLE)];
    titleLabel.textColor = [ImageUtils colorFromHexString:NEW_CATEGORY_CELL_TITLE_TEXT_COLOR andDefaultColor:nil];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.verticalAlignment = VerticalAlignmentMiddle;
    titleLabel.userInteractionEnabled = YES;
    titleLabel.font = [UIFont systemFontOfSize:NEW_CATEGORY_TITLE_SIZE];
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    
    highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    
    int height = INDEX_ROW_HEIGHT_NEW_CATEGORY - NEW_CATEGORY_ROW_HEIGHT_TITLE - NEW_CATEGORY_ROW_HEIGHT_SUB_TITLE - NEW_CATEGORY_MARGIN_BOTTOM;
    IconFontImageView *iconFontImageView = [[IconFontImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    self.iconFontImageView = iconFontImageView;
    [self addSubview:iconFontImageView];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:NEW_CATEGORY_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:NEW_CATEGORY_CELL_TITLE_TEXT_COLOR andDefaultColor:nil].CGColor);
    [self.titleLabel setNeedsDisplay];
    [self.subTitleLabel setNeedsDisplay];
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:NEW_CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:0.0f andToX:rect.size.width andToY:0.0f andWidth:NEW_CATEGORY_BORDER_WIDTH];
    
    CGFloat fromY = 0;
    CGFloat toY = 0;
    
    switch (itemType) {
        case NEW_CATEGORY_ITEM_TYPE_BOTTOM:
            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:NEW_CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:rect.size.height andToX:rect.size.width andToY:rect.size.height andWidth:NEW_CATEGORY_BORDER_WIDTH];
            break;
        case NEW_CATEGORY_ITEM_TYPE_NORMAL:
            break;
        default:
            return;
    }
    
    fromY = 0;
    toY = rect.size.height;
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:NEW_CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:fromY andToX:0.0f andToY:toY andWidth:NEW_CATEGORY_BORDER_WIDTH];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.rowIndex * NEW_CATEGORY_COLUMN_COUNT + self.columnIndex >= self.categoryData.items.count) {
        self.pressed = NO;
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) doClick {
    NewCategoryItem* item = [self getNewCategoryItem];
    [self onItemClick:item];
}

- (void) onItemClick:(NewCategoryItem*) item
{    
    if ([item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMRECOMMEND]) {
        SubCategoryItem* subItem = [item.subItems objectAtIndex:0];
        if (item.subItems.count == 1 && subItem.cellCategories.count == 1) {
            CategoryItem* categoryItem = [subItem.cellCategories objectAtIndex:0];
            [categoryItem startWebView];
            [[UIDataManager instance] addTrack:categoryItem];
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_NEW_CATEGORY_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title",categoryItem.title), Pair(@"url", categoryItem.ctUrl.url), nil];
        } else {
            [self startExtendCatgoryViewControllerWithItem:item];
        }
        
    } else if ([item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMCATEGORY]){
        [self startExtendCatgoryViewControllerWithItem:item];
    } else if ([item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMMORE]) {
        AllServiceViewController* controller = [[AllServiceViewController alloc] init];
        controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT + TPHeaderBarHeightDiff());
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
}


- (void) startExtendCatgoryViewControllerWithItem:(NewCategoryItem*)item
{
    
    CategoryExtendViewController* controller = [[CategoryExtendViewController alloc] init];
    controller.item = item;
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}

- (void) drawView:(NewCategoryItem*) categoryItem
{
    self.titleLabel.text = categoryItem.title;
    self.subTitleLabel.text = categoryItem.subTitle;
    [self.iconFontImageView resetFrameWithData:categoryItem];
    if ([categoryItem shouldShowHighLight]) {
        [self drawHighLightView:categoryItem.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
    [self setType];
    [self setNeedsDisplay];
}

- (void)downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.icon = [ImageUtils getImageFromLocalWithUrl:url];
            [self setNeedsDisplay];
        });
    }
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

- (void) resetWithCategoryData:(SectionNewCategory*)data andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx
{
    self.categoryData = data;
    self.rowIndex = rowIdx;
    self.columnIndex = columnIdx;
}

- (void) setType
{
    if(self.rowIndex == ((self.categoryData.count.intValue + NEW_CATEGORY_COLUMN_COUNT - 1) / NEW_CATEGORY_COLUMN_COUNT) - 1){
        itemType = NEW_CATEGORY_ITEM_TYPE_BOTTOM;
    } else {
        itemType = NEW_CATEGORY_ITEM_TYPE_NORMAL;
    }
}

- (NewCategoryItem*) getNewCategoryItem
{
    if ((NEW_CATEGORY_COLUMN_COUNT * self.rowIndex + self.columnIndex) < self.categoryData.items.count) {
        return [self.categoryData.items objectAtIndex:NEW_CATEGORY_COLUMN_COUNT * self.rowIndex + self.columnIndex];
    }
    return nil;
}

@end
