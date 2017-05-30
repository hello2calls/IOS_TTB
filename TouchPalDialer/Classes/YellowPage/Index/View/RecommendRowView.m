//
//  RecommendRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "RecommendRowView.h"
#import "CategoryItem.h"
#import "RecommendCellView.h"
#import "IndexConstant.h"
#import "SectionRecommend.h"
#import "UserDefaultsManager.h"
#import "ActivityItem.h"
#import "UIDataManager.h"

@implementation RecommendRowView


- (id)initWithFrame:(CGRect)frame andData:(SectionRecommend *)section andIndex:(NSIndexPath *)path
{
    self = [super initWithFrame:frame];
    self.sectionRecommend = section;
    self.indexPath = path;
    [self addSubview:[self createViewItemWithFrame:frame]];
    [self resetDataWithRecommendItem:section andIndexPath:path];
    [self setTag:RECOMMEND_TAG];
    return self;
}

-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    UIView* view = [[UIView alloc] initWithFrame:frame];
    
    NSArray* dataArray = self.sectionRecommend.items;
    NSMutableArray* tempViews = [[NSMutableArray alloc]initWithCapacity:RECOMMEND_COLUMN_COUNT];
    self.cellViews = tempViews;
    
    if([dataArray count] > 0) {
        int width = (frame.size.width  - 2 * RECOMMEND_MARGIN_LEFT) / RECOMMEND_COLUMN_COUNT;
        int offset = (frame.size.width  - 2 * RECOMMEND_MARGIN_LEFT) - width * RECOMMEND_COLUMN_COUNT;
        int startX = RECOMMEND_MARGIN_LEFT;
        for(int i = 0; i < RECOMMEND_COLUMN_COUNT; i++) {
            int cellWidth = width + (offset-- > 0 ? 1 : 0);
            RecommendCellView* cellView = nil;
            
            if ( (i + RECOMMEND_COLUMN_COUNT * self.indexPath.row) < [dataArray count]) {
                cellView = [[RecommendCellView alloc] initWithFrame:CGRectMake(startX, 0, cellWidth, frame.size.height) andData:[dataArray objectAtIndex:i + RECOMMEND_COLUMN_COUNT * self.indexPath.row]];
                
            } else {
                cellView = [[RecommendCellView alloc] initWithFrame:CGRectMake(startX, 0, cellWidth, frame.size.height) andData: nil];
            }
            startX = startX + cellWidth;
            
            [self.cellViews addObject:cellView];
            [view addSubview:cellView];
        }
    }
    return view;
}

- (void) resetDataWithRecommendItem:(SectionRecommend*)item andIndexPath:(NSIndexPath*)indexPath
{
    self.sectionRecommend = item;
    self.indexPath = indexPath;
    [self drawView];
    for (RecommendCellView* view in self.cellViews) {
        [view redrawHighLight];
    }
}
-(void) drawView
{
    int i = 1 + RECOMMEND_COLUMN_COUNT * self.indexPath.row;
    NSArray* dataArray = self.sectionRecommend.items;
    for (RecommendCellView* view in self.cellViews) {
        if (i <= dataArray.count) {
            int count = dataArray.count;
            BOOL isLastRow = ((self.indexPath.row == (count + RECOMMEND_COLUMN_COUNT - 1 )/ RECOMMEND_COLUMN_COUNT - 1) ? YES : NO);
            [view drawViewWithIndex:i andisLastRow:isLastRow andItem:[dataArray objectAtIndex:(i-1)]];
            i++;
        } else {
            [view drawViewWithIndex:i andisLastRow:YES andItem:nil];
        }
        
    }
}

- (void) dealRecommendArray:(SectionRecommend*)item
{
    self.sectionRecommend = [SectionRecommend new];
    CategoryItem* lastItem = [item.items lastObject];
    if ([RECOMMEND_ALLSERVICE isEqualToString:lastItem.identifier]) {
        if ([UIDataManager instance].hasCategory) {
            for (CategoryItem* c in item.items) {
                if (![lastItem isEqual:c]) {
                    [self.sectionRecommend.items addObject:c];
                }
            }
        } else {
            CategoryItem* removeTarget = [item.items objectAtIndex:item.items.count - 2];
            for (CategoryItem* c in item.items) {
                if (![removeTarget isEqual:c]) {
                    [self.sectionRecommend.items addObject:c];
                }
            }
        }
    } else {
        for (CategoryItem* c in item.items) {
            [self.sectionRecommend.items addObject:c];
        }
    }
}
@end
