//
//  CategoryRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "CategoryRowView.h"
#import "TPDialerResourceManager.h"
#import "CategoryCellView.h"
#import "SectionCategory.h"
#import "CategoryItem.h"
#import "CategoryTitleView.h"
#import "UIDataManager.h"
#import "IndexConstant.h"

@implementation CategoryRowView

@synthesize categorySubViews;
@synthesize categoryTitleView;
@synthesize rowIndexPath;
@synthesize categoryData;

- (id)initWithFrame:(CGRect)frame andData:(SectionCategory *)data andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame];
    self.categoryData = data;
    self.rowIndexPath = indexPath;
    [self addSubview:[self createViewItemWithFrame:frame]];
    [self resetDataWithCategoryItem:data andIndexPath:indexPath];
    [self setTag:CATEGORY_NORMAL_TAG];
    
    return self;
}

-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    SectionCategory* item = self.categoryData;
    categorySubViews = [[NSMutableArray alloc]initWithCapacity:CATEGORY_COLUMN_COUNT];
    
    if([item.items count] > 0) {
        
        int titleWidth = CATEGORY_TITLE_WIDTH;
        
        //Draw category title
        CategoryTitleView *titleView = [[CategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, titleWidth, INDEX_ROW_HEIGHT_CATEGORY)];
        self.categoryTitleView = titleView;
        [view addSubview:titleView];
        
        int width = (frame.size.width - titleWidth) / CATEGORY_COLUMN_COUNT;
        int offset = frame.size.width - titleWidth - width * CATEGORY_COLUMN_COUNT;
        int startX = titleWidth;
        
        for(int i = 0; i < CATEGORY_COLUMN_COUNT; i++) {
            int cellwidth = width + (offset-- > 0 ? 1 : 0);
            CategoryCellView* cellView = [[CategoryCellView alloc] initWithFrame:CGRectMake(startX, 0, cellwidth, frame.size.height)];
            startX = startX + cellwidth;
            [view addSubview:cellView];
            [categorySubViews addObject:cellView];
        }
    }
    
    return view;
}

-(void) drawView
{
    SectionCategory* item = self.categoryData;
    [categoryTitleView drawViews:item];
    
    int i = 0;
    
    for (CategoryCellView* view in categorySubViews) {
        if(item.items.count > rowIndexPath.row * CATEGORY_COLUMN_COUNT + i){
            [view drawView:[item.items objectAtIndex:rowIndexPath.row * CATEGORY_COLUMN_COUNT + i]];
        } else {
            [view drawView: nil];
        }
        i++;
    }
}


- (void) resetDataWithCategoryItem:(SectionCategory*)item andIndexPath:(NSIndexPath*)indexPath
{
    self.categoryData = item;
    self.rowIndexPath = indexPath;
    
    [categoryTitleView resetWithCategoryData:categoryData andRowIndexPath:rowIndexPath];
    
    int i = 0;
    for (CategoryCellView* view in categorySubViews) {
        [view resetWithCategoryData:categoryData andRowIndex:rowIndexPath.row andColumnIndex:i++];
        
    }
    [self drawView];
    
}
@end