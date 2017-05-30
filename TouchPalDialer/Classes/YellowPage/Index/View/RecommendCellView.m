//
//  RecommendCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import <Foundation/Foundation.h>
#import "RecommendCellView.h"
#import "TPDialerResourceManager.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "CategoryItem.h"
#import "CTUrl.h"
#import "RecommendHighLightView.h"
#import "HighLightItem.h"
#import "UserDefaultsManager.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "UpdateService.h"
#import "UIDataManager.h"
#import "IndexData.h"
#import "IndexConstant.h"
#import "CategoryExtendViewController.h"
#import "SubCategoryItem.h"
#import "NewCategoryItem.h"
#import "TouchPalDialerAppDelegate.h"
#import "AccountInfoManager.h"

@interface RecommendCellView ()
{
    RecommendHighLightView* highLightView;
    NSString* url;
    BOOL isFirstLine;
}
@property(nonatomic, assign)BOOL isLastRow;
@end

@implementation RecommendCellView

- (id)initWithFrame:(CGRect)frame andData:(CategoryItem*)item
{
    
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor whiteColor];
    self.categoryData = item;
    
    highLightView = [[RecommendHighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float _scaleRatio = 1;
    float iconWidth = rect.size.width / 1.7;
    float iconHeight = RECOMMEND_ICON_HEIGHT / 1.7;
    if (self.icon.size.height > self.icon.size.width) {
        _scaleRatio = self.icon.size.width / self.icon.size.height;
        iconWidth = _scaleRatio * iconHeight;
    } else {
        _scaleRatio = self.icon.size.height / self.icon.size.width;
        iconHeight = _scaleRatio * iconHeight;
    }
    
    CGFloat topY = RECOMMEND_TOP_MARGIN;
    if (!isFirstLine) {
        topY = RECOMMEND_TOP_MARGIN * 3 / 5;
    }
    
    CGRect rectN = CGRectMake((rect.size.width - iconWidth - RECOMMEND_ICON_TO_BOUND)/2 , topY, RECOMMEND_ICON_TO_BOUND + iconWidth, RECOMMEND_ICON_TO_BOUND + iconWidth);
    
    CGSize size = [self.categoryData.title sizeWithFont:[UIFont systemFontOfSize:RECOMMEND_TEXT_SIZE]];
    [self.icon drawInRect:rectN];
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:RECOMMEND_TEXT_COLOR andDefaultColor:nil].CGColor);
    if (self.isLastRow) {
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:FIND_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:self.frame.size.height andToX:self.frame.size.width andToY:self.frame.size.height andWidth:FIND_BORDER_WIDTH];
    }
    [self.categoryData.title drawInRect:CGRectMake((rect.size.width - size.width)/2, rectN.origin.y + rectN.size.height + RECOMMEND_TEXT_TO_ICON, size.width, size.height - 2.0) withFont:[UIFont systemFontOfSize:RECOMMEND_TEXT_SIZE]];
    if (self.pressed && self.categoryData) {
        CGContextSetFillColorWithColor(context,
                                       [ImageUtils colorFromHexString:RECOMMEND_PRESSED_BG_COLOR andDefaultColor:nil].CGColor);
        CGContextFillEllipseInRect(context, rectN);
    } else {
        CGContextSetFillColorWithColor(context,
                                       [UIColor clearColor].CGColor);
        CGContextFillEllipseInRect(context, rectN);
    }
}

- (void) doClick {
    if (self.categoryData) {
        CategoryItem* item = self.categoryData;
        
        if(item.reloadAssetAfterBack) {
            [[AccountInfoManager instance] setRequestAccountInfo:YES];
        }
        
        if ([item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMRECOMMEND]) {
            SubCategoryItem* subItem = [item.subItems objectAtIndex:0];
            if (item.subItems.count == 1 && subItem.cellCategories.count == 1) {
                CategoryItem* categoryItem = [subItem.cellCategories objectAtIndex:0];
                [categoryItem startWebView];
                [[UIDataManager instance] addTrack:categoryItem];
            } else {
                [self startExtendCatgoryViewControllerWithItem:item];
            }
            
        } else if ([item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMCATEGORY]){
            [self startExtendCatgoryViewControllerWithItem:item];
        } else {
            [item startWebView];
        }
        
        [[UIDataManager instance] addTrack:item];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_RECOMMEND_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title", item.title),nil];
    }
}

- (void) startExtendCatgoryViewControllerWithItem:(CategoryItem*)item
{
    
    CategoryExtendViewController* controller = [[CategoryExtendViewController alloc] init];
    controller.item = item;
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}


- (void) drawViewWithIndex:(int)index andisLastRow:(BOOL)isLastRow andItem:(CategoryItem *)item
{
    self.categoryData = item;
    isFirstLine = index <= RECOMMEND_COLUMN_COUNT;
    self.isLastRow = isLastRow;
    if (item) {
        NSString* filePath = nil;
        if ([UserDefaultsManager boolValueForKey:INDEX_HAS_ACTIVITY]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cacheDirectory = [paths objectAtIndex:0];
            NSString *unzipFilePath = [cacheDirectory stringByAppendingPathComponent:INDEX_UNZIP_FILEPATH];
            filePath = [NSString stringWithFormat:@"%@%@/%d.png",unzipFilePath,YP_ACTIVITI_FILEPATH, index];
            self.icon = [UIImage imageWithContentsOfFile:filePath];
        } else {
            filePath = [NSString stringWithFormat:@"%@%@", [[UpdateService instance] getWebSearchPath],[self.categoryData iconPath]];
            self.icon = [ImageUtils getImageFromFilePath:filePath];
        }
        
        url = self.categoryData.iconLink;
        if (self.icon == nil) {
            self.icon = [ImageUtils getImageFromLocalWithUrl:url];
        }
        if (self.icon == nil) {
            [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
        }
        if ([self.categoryData shouldShowHighLight]) {
            [self drawHighLightView:self.categoryData.highlightItem];
        } else {
            [self drawHighLightView:nil];
        }
    } else {
        self.icon = nil;
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

- (void) redrawHighLight
{
    if ([self.categoryData shouldShowHighLight]) {
        [self drawHighLightView:self.categoryData.highlightItem];
    } else {
        [self drawHighLightView:nil];
    }
}

- (void) drawHighLightView:(HighLightItem*)highLightItem
{
    if (highLightItem.type.length > 0) {
        if ([STYLE_HIGHLIGHT_TYPE_REDPOINT isEqualToString:highLightItem.type]) {
            
            CGPoint* points = (CGPoint*)malloc(1*sizeof(CGPoint));
            points[0] = CGPointMake(self.bounds.size.width * 3 / 4 - RED_SIZE_OFFSET, self.bounds.size.height / 4 - RED_POINT_HEIGHT_OFFSET);
            [highLightView drawView:highLightItem andPoints:points withLine:YES];
        } else if ([STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:highLightItem.type]) {
            CGSize size = [highLightItem.hotKey sizeWithFont:[UIFont boldSystemFontOfSize:RECTANGLE_TEXT_SIZE]];
            CGPoint* points = (CGPoint*)malloc(2*sizeof(CGPoint));
            CGFloat startX = 0;
            CGFloat endX = 0;
            if ([highLightItem.hotKey length] > 2) {
                startX = self.bounds.size.width - size.width - RECTANGLE_MARGIN_LEFT;
                endX = self.bounds.size.width;
            } else {
                startX = self.bounds.size.width -size.width - RECTANGLE_MARGIN_LEFT - RECTANGLE_SIZE_OFFSET;
                endX = self.bounds.size.width - RECTANGLE_SIZE_OFFSET;
            }
            
            CGFloat topY = RECTANGLE_MARGIN_TOP + RECTANGLE_PADDING_TOP;
            if (!isFirstLine) {
                topY = topY - RECOMMEND_TOP_MARGIN / 2;
            }
            
            points[0] = CGPointMake(startX, topY);
            points[1] = CGPointMake(endX, size.height + RECTANGLE_MARGIN_TOP + topY);
            [highLightView drawView:highLightItem andPoints:points withLine:YES];
        } else if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:highLightItem.type]) {
            CGPoint* points = (CGPoint*)malloc(1*sizeof(CGPoint));
            points[0] = CGPointMake(self.bounds.size.width * 3 / 4 - NORMAL_SIZE_OFFSET, self.bounds.size.height / 4 - NORMAL_HEIGHT_OFFSET);
            [highLightView drawView:highLightItem andPoints:points withLine:YES];
        } else {
            [highLightView drawView:nil andPoints:nil withLine:NO];
        }
        
    } else {
        [highLightView drawView:nil andPoints:nil withLine:NO];
    }
}
@end
