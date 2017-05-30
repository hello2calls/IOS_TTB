//
//  SubBannerRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/11.
//
//

#import "SubBannerRowView.h"
#import "SubBannerCellView.h"
#import "IndexConstant.h"
#import "SubBannerFirstCellView.h"

@interface SubBannerRowView()
{
    SubBannerFirstCellView* largeCellView;
    NSMutableArray* smallCellViewArray;
}

@end

@implementation SubBannerRowView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTag:SUB_BANNER_TAG];
    }
    
    return self;
}

-(void) createViewItem
{
    if (!self.subViews) {
        UIView* view = [[UIView alloc] initWithFrame:self.bounds];
        SectionSubBanner* item = self.banner;
        self.subViews = [[NSMutableArray alloc]init];
        
        if([item.items count] > 0) {
            int width = self.bounds.size.width / SUBBANNER_COLUMN_COUNT;
            int startX = 0;
            SubBannerFirstCellView* firstCellView = [[SubBannerFirstCellView alloc]initWithFrame:CGRectMake(startX, 0, width, self.bounds.size.height)];
            largeCellView = firstCellView;
            [view addSubview:firstCellView];
            [self.subViews addObject:firstCellView];
            
            smallCellViewArray = [[NSMutableArray alloc]init];
            for(int i = 0; i < SUBBANNER_COLUMN_COUNT; i++) {
                SubBannerCellView* rightCellView = [[SubBannerCellView alloc] initWithFrame:CGRectMake(startX + width, i * self.bounds.size.height / 2, self.bounds.size.width - width - startX, self.bounds.size.height / 2)];
                [view addSubview:rightCellView];
                [self.subViews addObject:rightCellView];
                [smallCellViewArray addObject:rightCellView];
            }
        }
        [self addSubview:view];
    }
}

- (void) resetDataWithItem:(SectionSubBanner*)item andIndexPath:(NSIndexPath*)indexPath
{
    self.banner = item;
    self.indexPath = indexPath;
    int height = 0;
    if ((item.items.count % 2) && indexPath.row == 0) {
        height =  INDEX_ROW_HEIGHT_SUB_BANNER * 2;
    } else {
        height = INDEX_ROW_HEIGHT_SUB_BANNER;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    [self createViewItem];
    float widthRatio = 0.5f;
    if (!([item.items count] % 2)) {
        largeCellView.hidden = YES;
        ((SubBannerCellView*)smallCellViewArray[0]).frame = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
        ((SubBannerCellView*)smallCellViewArray[1]).frame = CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width - self.bounds.size.width / 2, self.bounds.size.height);
    } else if ((([item.items count] % 2) && indexPath.row > 0)) {
        largeCellView.hidden = YES;
        ((SubBannerCellView*)smallCellViewArray[0]).frame = CGRectMake(0, 0, self.bounds.size.width * widthRatio, self.bounds.size.height);
        ((SubBannerCellView*)smallCellViewArray[1]).frame = CGRectMake(self.bounds.size.width * widthRatio, 0, self.bounds.size.width - self.bounds.size.width * widthRatio, self.bounds.size.height);
    } else {
        largeCellView.hidden = NO;
        largeCellView.frame = CGRectMake(0, 0, self.bounds.size.width * widthRatio, self.bounds.size.height);
        ((SubBannerCellView*)smallCellViewArray[0]).frame = CGRectMake(self.bounds.size.width * widthRatio, 0, self.bounds.size.width * (1 - widthRatio), self.bounds.size.height / 2);
        ((SubBannerCellView*)smallCellViewArray[1]).frame = CGRectMake(self.bounds.size.width * widthRatio, self.bounds.size.height / 2, self.bounds.size.width * (1 - widthRatio), self.bounds.size.height / 2);
    }
    
    int i = 0;
    int indexStart = ([item.items count] % 2 && self.indexPath.row) ? 1 : 0;
    for (id view in self.subViews) {
        if (!((UIView*)view).hidden) {
            [view resetWithData:[item.items objectAtIndex:(self.indexPath.row * 2 + i + indexStart)] withColumn:self.indexPath.row * 2 + i + indexStart withTotalCount:item.items.count];
            i++;
        }
    }
}

@end
