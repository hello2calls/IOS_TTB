//
//  CategoryTitleView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import "CategoryTitleView.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "UIDataManager.h"

@implementation CategoryTitleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CATEGORY_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    CGSize size = [self.title sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_MEDIUM]];
    
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CATEGORY_TITLE_ICON_COLOR andDefaultColor:nil].CGColor);
    [self.title drawInRect:CGRectMake(CATEGORY_TITLE_TEXT_MARGIN, (rect.size.height - size.height)/2, size.width, size.height) withFont:[UIFont systemFontOfSize:CELL_FONT_MEDIUM]];

    if (self.categoryData.items.count > CATEGORY_COLUMN_COUNT && self.rowIndexPath.row == 0) {
        [self drawIcon:rect];
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.categoryData.items.count <= CATEGORY_COLUMN_COUNT || self.rowIndexPath.row > 0) {
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) doClick {
    [self.categoryData setIsOpened:!self.categoryData.isOpened];
    
    if (self.categoryData.isOpened) {
        [[UIDataManager instance].tableView insertRowsAtIndexPaths:[self getIndexPaths] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [[UIDataManager instance].tableView deleteRowsAtIndexPaths:[self getIndexPaths] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSArray* pArray = [[NSMutableArray alloc]initWithObjects:self.rowIndexPath, nil];
    [[UIDataManager instance].tableView reloadRowsAtIndexPaths:pArray withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void) drawViews:(SectionCategory*)category
{
    self.backgroundColor = [UIColor clearColor];
    if(self.rowIndexPath.row == 0) {
        self.title = [category name];
    } else {
        self.title = @"";
    }
    [self setNeedsDisplay];
}

- (void) drawIcon:(CGRect)rect
{
    CGFloat startX, startY;
    CGFloat middleX, middleY;
    CGFloat endX, endY;
    
    if (self.categoryData.isOpened) {
        startX = rect.size.width - CATEGORY_TITLE_ICON_RMARGIN -  CATEGORY_TITLE_ICON_HEIGHT * 2 ;
        startY = (rect.size.height + CATEGORY_TITLE_ICON_HEIGHT) / 2;
        
        middleX = startX + CATEGORY_TITLE_ICON_HEIGHT;
        middleY = startY - CATEGORY_TITLE_ICON_HEIGHT;
        
        endX = middleX + CATEGORY_TITLE_ICON_HEIGHT;
        endY = startY;
    } else {
        startX = rect.size.width - CATEGORY_TITLE_ICON_RMARGIN -  CATEGORY_TITLE_ICON_HEIGHT * 2 ;
        startY = (rect.size.height - CATEGORY_TITLE_ICON_HEIGHT) / 2;
        
        middleX = startX + CATEGORY_TITLE_ICON_HEIGHT;
        middleY = startY + CATEGORY_TITLE_ICON_HEIGHT;
        
        endX = middleX + CATEGORY_TITLE_ICON_HEIGHT;
        endY = startY;
    }
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_TITLE_ICON_COLOR andDefaultColor:nil] andFromX:startX andFromY:startY andToX:middleX andToY:middleY andWidth:CATEGORY_TITLE_ICON_WIDTH];
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_TITLE_ICON_COLOR andDefaultColor:nil] andFromX:middleX andFromY:middleY andToX:endX andToY:endY andWidth:CATEGORY_TITLE_ICON_WIDTH];
}

- (void) resetWithCategoryData:(SectionCategory *)cData andRowIndexPath:(NSIndexPath*)idxPath
{
    self.categoryData = cData;
    self.rowIndexPath = idxPath;
}

- (NSArray*) getIndexPaths
{
    NSMutableArray* indexPaths = [[NSMutableArray alloc]init];
    int count = [self.categoryData getRowCount];
    for (int i = 1; i < count; i++) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:self.rowIndexPath.section];
        [indexPaths addObject:path];
    }
    return indexPaths;
}
@end