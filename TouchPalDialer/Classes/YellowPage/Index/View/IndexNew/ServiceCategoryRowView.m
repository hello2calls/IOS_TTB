//
//  ServiceCategoryRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/10.
//
//

#import "ServiceCategoryRowView.h"
#import "ServiceCategoryCellView.h"
#import "IndexConstant.h"
#import "ServiceHeaderView.h"


@implementation ServiceCategoryRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:[self createViewItemWithFrame:self.bounds]];
    UIView* emptyView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 0, 0))];
    [self addSubview:emptyView];
    self.emptyView = emptyView;
    [self setTag:ALL_SERVICE_TAG];
    
    return self;
}

- (void) resetDataWithCategoryItem:(SectionService *)service andIndexPath:(NSIndexPath*)indexPath andIsLastCategory:(BOOL)isLastCategory
{
    self.indexPath = indexPath;
    self.service = service;

    int i = 0;
    for (ServiceCategoryCellView* view in self.categorySubViews) {
        [view resetWithCategoryData:service.items andRowIndex:self.indexPath.row andColumnIndex:i++];
    }
    if (isLastCategory) {
        self.emptyView.hidden = NO;
        UIView* view = [self.categorySubViews objectAtIndex:0];
        self.emptyView.frame = CGRectMake(0, view.frame.size.height, 0, 1000);
    } else {
        self.emptyView.hidden = YES;
        self.emptyView.frame = CGRectMake(0, 0, 0, 0);
    }
}


-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    
    cootek_log(@"ServiceCategoryRowView -> createViewItemWithFrame");
    UIView* view = [[UIView alloc] initWithFrame:frame];
    self.categorySubViews = [[NSMutableArray alloc]init];
    int width = frame.size.width / SERVICE_COLUMN_COUNT;
    int offset = frame.size.width - width * SERVICE_COLUMN_COUNT;
    int startX = 0;
    
    for(int i = 0; i < SERVICE_COLUMN_COUNT; i++) {
        int cellwidth = width + (offset-- > 0 ? 1 : 0);
        ServiceCategoryCellView* cellView = [[ServiceCategoryCellView alloc] initWithFrame:CGRectMake(startX, 0, cellwidth, frame.size.height)];
        startX = startX + cellwidth;
        [view addSubview:cellView];
        [self.categorySubViews addObject:cellView];
    }
    return view;
}

@end
