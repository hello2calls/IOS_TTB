//
//  ServiceCategoryCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/10.
//
//

#import "ServiceCategoryCellView.h"
#import "VerticallyAlignedLabel.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "HighLightView.h"
#import "CategoryItem.h"
#import "DialerUsageRecord.h"
#import "CTUrl.h"
#import "TPAnalyticConstants.h"
#import "HighLightItem.h"
#import "CategoryExtendViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "UIDataManager.h"
#import "IconFontImageView.h"

@interface ServiceCategoryCellView()
{
    HighLightView* highLightView;
    NSString* url;
}
@property(nonatomic,retain) VerticallyAlignedLabel* titleLabel;
@property(nonatomic,retain) UIImage* icon;
@property(nonatomic, retain) IconFontImageView* iconFontImageView;

@end

@implementation ServiceCategoryCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        VerticallyAlignedLabel* titleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, INDEX_ROW_HEIGHT_SERVICE_CONTENT - SERVICE_CELL_TEXT_HEIGHT_TITLE - SERVICE_MARGIN_BOTTOM, frame.size.width, SERVICE_CELL_TEXT_HEIGHT_TITLE)];
        titleLabel.textColor = [ImageUtils colorFromHexString:SERVICE_CELL_TEXT_COLOR andDefaultColor:nil];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.verticalAlignment = VerticalAlignmentMiddle;
        titleLabel.userInteractionEnabled = YES;
        titleLabel.font = [UIFont systemFontOfSize:SERVICE_CELL_TEXT_SIZE];
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        int height = INDEX_ROW_HEIGHT_SERVICE_CONTENT - SERVICE_CELL_TEXT_HEIGHT_TITLE - SERVICE_MARGIN_BOTTOM;
        IconFontImageView* iconFontImageView = [[IconFontImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
        self.iconFontImageView = iconFontImageView;
        [self addSubview:iconFontImageView];
        highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
        [self addSubview:highLightView];
    }
    
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
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.row * SERVICE_COLUMN_COUNT + self.column >= self.categories.count) {
        self.pressed = NO;
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) doClick {
    CategoryItem* item = [self getCategoryItem];
    [self onItemClick:item];

}

- (void) onItemClick:(CategoryItem*) item
{
    if (item) {
        if ([item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMCATEGORY]){
            [self startExtendCatgoryViewControllerWithItem:item];
            return;
        }
        [item hideClickHiddenInfo];
        [item.ctUrl startWebView];
        [[UIDataManager instance] addTrack:item];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CATEGORY_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title", item.title), Pair(@"url", item.ctUrl.url), nil];
    }

}

- (void) startExtendCatgoryViewControllerWithItem:(CategoryItem*)item
{
    CategoryExtendViewController* controller = [[CategoryExtendViewController alloc] init];
    controller.item = [item mutableCopy];
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}

- (void) drawView:(CategoryItem*) categoryItem
{
    self.titleLabel.text = categoryItem.title;
    [self.iconFontImageView resetFrameWithData:categoryItem];
    if ([categoryItem shouldShowHighLight]) {
        [self drawHighLightView:categoryItem.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
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

- (CategoryItem*) getCategoryItem
{
    if ((SERVICE_COLUMN_COUNT * self.row + self.column) < self.categories.count) {
        return  [self.categories objectAtIndex:SERVICE_COLUMN_COUNT * self.row + self.column];
    }
    return nil;
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

- (void) resetWithCategoryData:(NSArray *)categoryArray andRowIndex:(NSInteger)row andColumnIndex:(NSInteger)column;
{
    self.categories = categoryArray;
    self.row = row;
    self.column = column;
    
    if ((row * SERVICE_COLUMN_COUNT + column) < categoryArray.count) {
        CategoryItem* item = [categoryArray objectAtIndex:(row * SERVICE_COLUMN_COUNT + column)];
        [self drawView:item];
    } else {
        [self drawView:nil];
    }
    
}


@end
