//
//  MyPropertyRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "MyPropertyRowView.h"
#import "IndexConstant.h"
#import "MyPropertyCellView.h"
#import "UserDefaultsManager.h"

@implementation MyPropertyRowView

- (id)initWithFrame:(CGRect)frame andData:(SectionMyProperty *)dataArray andIndex:(NSIndexPath*)path
{
    self = [super initWithFrame:frame];
    if (self) {
        self.indexPath = path;
        self.sectionMyProperty = dataArray;
        [self addSubview:[self createViewItemWithFrame:frame]];
        [self resetDataWithMyProperty:dataArray andIndexPath:path];
    }
    
    return self;
}


-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    UIView* view = [[UIView alloc] initWithFrame:frame];
   
    int count = MY_PROPERTY_COLUMN_COUNT;
    if (![UserDefaultsManager boolValueForKey:VOIP_ACCOUNT_IS_CARD_USER defaultValue:NO]) {
        count--;
    }
    
    NSArray* dataArray = self.sectionMyProperty.items;
    NSMutableArray* tempViews = [[NSMutableArray alloc]initWithCapacity:count];
    self.cellViews = tempViews;
    
    if([dataArray count] > 0) {

        int totalWidh = frame.size.width - 2 * MY_PROPERTY_LEFT_MARGIN;
        int width = totalWidh / count;
        int offset = totalWidh - width * count;
        int startX = MY_PROPERTY_LEFT_MARGIN;
        int startY = MY_PROPERTY_TOP_CELL_MARGIN;

        for(int i = 0; i < count; i++) {
            int cellWidth = width + (offset-- > 0 ? 1 : 0);
            MyPropertyCellView* cellView = nil;
            
            if ( (i + count * self.indexPath.row) < [dataArray count]) {
                cellView = [[MyPropertyCellView alloc] initWithFrame:CGRectMake(startX, startY, cellWidth, frame.size.height - startY) andContentType:i];
                
            } else {
                cellView = [[MyPropertyCellView alloc] initWithFrame:CGRectMake(startX, startY, cellWidth, frame.size.height - startY) andContentType:i];
            }
            startX = startX + cellWidth;
            
            [self.cellViews addObject:cellView];
            [view addSubview:cellView];
        }
    }
    return view;
}

-(void) drawView
{
    for (MyPropertyCellView* view in self.cellViews) {
        [view drawView];
    }
}

- (void) resetDataWithMyProperty:(SectionMyProperty*)item andIndexPath:(NSIndexPath*)indexPath
{
    
    self.sectionMyProperty = item;
    self.indexPath = indexPath;
    
    int i = 0;
    for (MyPropertyCellView* view in self.cellViews) {
        [view resetWithMyProperty:item andRowIndex:indexPath.row andColumnIndex:i++];
        
    }
    [self drawView];
}

@end
