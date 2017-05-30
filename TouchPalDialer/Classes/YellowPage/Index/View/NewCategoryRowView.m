//
//  NewCategoryRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "NewCategoryRowView.h"
#import "NewCategoryCellView.h"
#import "IndexConstant.h"
#import "SectionNewCategory.h"
#import "ImageUtils.h"

@implementation NewCategoryRowView

- (id)initWithFrame:(CGRect)frame andData:(SectionNewCategory*)data andIndexPath:(NSIndexPath*)indexPath andHeader:(BOOL)show
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    self.categoryData = data;
    self.rowIndexPath = indexPath;
    if (self.rowIndexPath.row == 0 && show) {
        UILabel* header = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.origin.x + NEW_CATEGORY_TITLE_MARGIN_LEFT, self.bounds.origin.y, self.bounds.size.width, NEW_CATEGORY_ROW_HEIGHT_HEADER)];
        header.text = data.title;
        header.font = [UIFont systemFontOfSize:FIND_HEADER_SIZE];
        header.textColor = [ImageUtils colorFromHexString:COMMON_TITLE_TEXT_COLOR andDefaultColor:nil];
        
        [self addSubview:header];
        [self addSubview:[self createViewItemWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + header.frame.size.height, frame.size.width, self.bounds.size.height - NEW_CATEGORY_ROW_HEIGHT_HEADER)]];
            [self setTag:CATEGORY_TOP_TAG];
    } else {
        [self addSubview:[self createViewItemWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, frame.size.width, self.bounds.size.height)]];
            [self setTag:CATEGORY_NORMAL_TAG];
    }

    [self resetDataWithCategoryItem:data andIndexPath:indexPath];

    
    return self;
}

- (void) resetDataWithCategoryItem:(SectionNewCategory*)item andIndexPath:(NSIndexPath*)indexPath
{
    self.categoryData = item;
    self.rowIndexPath = indexPath;
    
    int i = 0;
    for (NewCategoryCellView* view in self.categorySubViews) {
        [view resetWithCategoryData:self.categoryData andRowIndex:self.rowIndexPath.row andColumnIndex:i++];
    }
    [self drawView];
}

-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    SectionNewCategory* item = self.categoryData;
    self.categorySubViews = [[NSMutableArray alloc]init];
    
    if([item.items count] > 0) {
        
        int width = frame.size.width / NEW_CATEGORY_COLUMN_COUNT;
        int offset = frame.size.width - width * NEW_CATEGORY_COLUMN_COUNT;
        int startX = 0;
        
        for(int i = 0; i < NEW_CATEGORY_COLUMN_COUNT; i++) {
            int cellwidth = width + (offset-- > 0 ? 1 : 0);
            NewCategoryCellView* cellView = [[NewCategoryCellView alloc] initWithFrame:CGRectMake(startX, 0, cellwidth, frame.size.height)];
            startX = startX + cellwidth;
            [view addSubview:cellView];
            [self.categorySubViews addObject:cellView];
        }
    }
    
    return view;
}

-(void) drawView
{
    SectionNewCategory* item = self.categoryData;
    
    int i = 0;
    for (NewCategoryCellView* view in self.categorySubViews) {
        
        if(item.items.count > self.rowIndexPath.row * NEW_CATEGORY_COLUMN_COUNT + i){
            [view drawView:[item.items objectAtIndex:self.rowIndexPath.row * NEW_CATEGORY_COLUMN_COUNT + i]];
        } else {
            [view drawView: nil];
        }
        i++;
    }
}

+ (int) getCategoryTag:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return CATEGORY_TOP_TAG;
    } else {
        return CATEGORY_NORMAL_TAG;
    }
}

@end