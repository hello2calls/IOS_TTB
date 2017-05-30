//
//  CategoryContentRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#import <Foundation/Foundation.h>
#import "CategoryContentRowView.h"
#import "SubCategoryItem.h"
#import "CategoryContentCellView.h"
#import "CategoryItem.h"
#import "IndexConstant.h"

@implementation CategoryContentRowView

- (id)initWithFrame:(CGRect)frame andData:(SubCategoryItem*)data andRowIndex:(NSInteger)rowIndex
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    self.item = data;
    self.rowIndex = rowIndex;
    
    [self addSubview:[self createViewItemWithFrame:self.bounds]];
    [self resetDataWithCategoryItem:data andRowIndex:rowIndex];
    return self;
}

-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    SubCategoryItem* item = self.item;
    self.cellViews = [[NSMutableArray alloc]init];
    
    if([item.cellCategories count] > 0) {
        
        int width = frame.size.width / CATEGORY_ITEM_CONTENT_COLUMN_COUNT;
        int offset = frame.size.width - width * CATEGORY_ITEM_CONTENT_COLUMN_COUNT;
        int startX = 0;
        
        for(int i = 0; i < CATEGORY_ITEM_CONTENT_COLUMN_COUNT; i++) {
            int cellwidth = width + (offset-- > 0 ? 1 : 0);
            CategoryContentCellView* cellView = [[CategoryContentCellView alloc] initWithFrame:CGRectMake(startX, 0, cellwidth, frame.size.height)];
            startX = startX + cellwidth;
            [view addSubview:cellView];
            [self.cellViews addObject:cellView];
        }
    }
    
    return view;
}


- (void) resetDataWithCategoryItem:(SubCategoryItem*)item andRowIndex:(NSInteger)rowIndex
{
    self.item = item;
    self.rowIndex = rowIndex;
    
    int i = 0;
    for (CategoryContentCellView* view in self.cellViews) {
        if (rowIndex * CATEGORY_ITEM_CONTENT_COLUMN_COUNT + i < self.item.cellCategories.count) {
            CategoryItem* categoryItem = [self.item.cellCategories objectAtIndex:rowIndex * CATEGORY_ITEM_CONTENT_COLUMN_COUNT + i];
            [view resetWithCategoryData:categoryItem andRowIndex:self.rowIndex andColumnIndex:i++];
        }

    }
    [self drawView];
}

-(void) drawView
{
    cootek_log(@"****** category content draw view *******");
    SubCategoryItem* item = self.item;
    
    int i = 0;
    for (CategoryContentCellView* view in self.cellViews) {
        
        if(item.cellCategories.count > self.rowIndex * CATEGORY_ITEM_CONTENT_COLUMN_COUNT + i){
            [view drawView:[item.cellCategories objectAtIndex:self.rowIndex * NEW_CATEGORY_COLUMN_COUNT + i] andRoxIndex:self.rowIndex];
        } else {
            [view drawView: nil andRoxIndex:self.rowIndex];
        }
        i++;
    }
}
@end
